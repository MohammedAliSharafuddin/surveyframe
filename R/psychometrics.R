# reliability_report.R

#' Compute reliability statistics for scored scales
#'
#' Produces Cronbach's alpha and McDonald's omega for each scale defined in
#' the instrument, along with the number of items and sample size.
#'
#' @param data A `tibble` or `data.frame` of responses. Item columns must be
#'   present.
#' @param instrument An `sframe` object.
#' @param scales Character vector or NULL. A subset of scale IDs to analyse.
#'   When NULL (default), all scales in the instrument are included.
#' @param alpha Logical. Whether to compute Cronbach's alpha. Defaults to
#'   `TRUE`.
#' @param omega Logical. Whether to compute McDonald's omega. Defaults to
#'   `TRUE`.
#'
#' @return An object of class `sframe_reliability_report`, a list with one
#'   element per scale. Each element is a list of statistics and a summary
#'   tibble.
#' @export
#' @seealso [sf_scale()], [item_report()]
#'
#' @examples
#' \dontrun{
#' rr <- reliability_report(responses, instr)
#' print(rr)
#' }
reliability_report <- function(
    data,
    instrument,
    scales = NULL,
    alpha  = TRUE,
    omega  = TRUE
) {
  stopifnot(inherits(instrument, "sframe"))
  stopifnot(is.data.frame(data))

  target_scales <- instrument$scales
  if (!is.null(scales)) {
    target_scales <- Filter(function(s) s$id %in% scales, target_scales)
  }
  reverse_context <- sframe_reverse_context(instrument)

  results <- lapply(target_scales, function(scale) {
    cols <- intersect(scale$items, colnames(data))
    if (length(cols) < 2) {
      sframe_warn_scoring(
        paste0("Scale '", scale$id,
               "' needs at least 2 items for reliability analysis."),
        scale_id = scale$id
      )
      return(NULL)
    }
    scale_data <- sframe_numeric_scale_data(data, cols, reverse_context)
    scale_data <- scale_data[complete.cases(scale_data), , drop = FALSE]

    result <- list(
      scale_id = scale$id,
      label    = scale$label,
      n_items  = length(cols),
      n        = nrow(scale_data)
    )

    if (alpha) {
      a <- suppressWarnings(
        psych::alpha(scale_data, check.keys = FALSE, warnings = FALSE)
      )
      result$alpha      <- a$total$raw_alpha
      result$alpha_std  <- a$total$std.alpha
    }
    if (omega) {
      tryCatch({
        o <- psych::omega(scale_data, nfactors = 1, plot = FALSE)
        result$omega_h <- o$omega_h
        result$omega_t <- o$omega.tot
      }, error = function(e) {
        sframe_warn_scoring(
          paste0("Omega could not be computed for scale '", scale$id,
                 "': ", conditionMessage(e)),
          scale_id = scale$id
        )
      })
    }

    result
  })

  results <- Filter(Negate(is.null), results)

  structure(results, class = "sframe_reliability_report")
}

#' @exportS3Method print sframe_reliability_report
print.sframe_reliability_report <- function(x, ...) {
  cat("Reliability Report\n\n")
  for (s in x) {
    cat(sprintf("Scale: %s (%s)\n", s$scale_id, s$label))
    cat(sprintf("  Items: %d   N: %d\n", s$n_items, s$n))
    if (!is.null(s$alpha))   cat(sprintf("  Alpha:   %.3f\n", s$alpha))
    if (!is.null(s$omega_h)) cat(sprintf("  Omega h: %.3f\n", s$omega_h))
    if (!is.null(s$omega_t)) cat(sprintf("  Omega t: %.3f\n", s$omega_t))
    cat("\n")
  }
  invisible(x)
}


# item_report.R

#' Generate item-level diagnostics
#'
#' Produces item-total correlations, floor and ceiling effect proportions,
#' and item means and standard deviations for each item within each scale.
#'
#' @param data A `tibble` or `data.frame` of responses.
#' @param instrument An `sframe` object.
#' @param scales Character vector or NULL. A subset of scale IDs to analyse.
#'   When NULL (default), all scales are included.
#'
#' @return An object of class `sframe_item_report`, a list with one tibble
#'   per scale.
#' @export
#' @seealso [reliability_report()], [sf_scale()]
#'
#' @examples
#' \dontrun{
#' ir <- item_report(responses, instr)
#' print(ir)
#' }
item_report <- function(data, instrument, scales = NULL) {
  stopifnot(inherits(instrument, "sframe"))
  stopifnot(is.data.frame(data))

  target_scales <- instrument$scales
  if (!is.null(scales)) {
    target_scales <- Filter(function(s) s$id %in% scales, target_scales)
  }

  results <- lapply(target_scales, function(scale) {
    cols <- intersect(scale$items, colnames(data))
    if (length(cols) < 2) return(NULL)

    scale_data <- as.data.frame(lapply(data[, cols, drop = FALSE],
                                       function(x) suppressWarnings(as.numeric(x))))
    total_score <- rowMeans(scale_data, na.rm = TRUE)

    diagnostics <- lapply(cols, function(col) {
      vals      <- scale_data[[col]]
      item_rest <- stats::cor(vals, total_score - vals, use = "complete.obs")
      col_min   <- min(vals, na.rm = TRUE)
      col_max   <- max(vals, na.rm = TRUE)
      list(
        item_id      = col,
        mean         = mean(vals, na.rm = TRUE),
        sd           = stats::sd(vals, na.rm = TRUE),
        item_rest_r  = item_rest,
        floor_pct    = mean(vals == col_min, na.rm = TRUE),
        ceiling_pct  = mean(vals == col_max, na.rm = TRUE),
        n_missing    = sum(is.na(vals))
      )
    })

    list(
      scale_id    = scale$id,
      label       = scale$label,
      diagnostics = tibble::as_tibble(do.call(rbind, lapply(diagnostics, as.data.frame)))
    )
  })

  structure(Filter(Negate(is.null), results), class = "sframe_item_report")
}

#' @exportS3Method print sframe_item_report
print.sframe_item_report <- function(x, ...) {
  for (s in x) {
    cat(sprintf("Item diagnostics: %s (%s)\n\n", s$scale_id, s$label))
    print(s$diagnostics)
    cat("\n")
  }
  invisible(x)
}


# efa_report.R

#' Prepare a survey instrument for exploratory factor analysis
#'
#' Reports KMO sampling adequacy, Bartlett's test of sphericity, and a
#' parallel analysis scree plot to inform factor number selection. This
#' function does not estimate or return an EFA solution; it prepares the
#' researcher to run one using a separate package such as `psych` or `lavaan`.
#'
#' @param data A `tibble` or `data.frame` of responses.
#' @param instrument An `sframe` object.
#' @param scales Character vector or NULL. Scale IDs whose items to include.
#'   When NULL, all scale items are pooled.
#' @param nfactors Integer or NULL. Suggested number of factors to highlight
#'   on the scree plot. When NULL, the parallel analysis recommendation is
#'   used.
#' @param rotation Character. The rotation method to display in the diagnostic
#'   notes. Does not affect the diagnostics themselves. Defaults to
#'   `"oblimin"`.
#'
#' @return An object of class `sframe_efa_report` with elements `kmo`,
#'   `bartlett`, `parallel`, and `suggested_nfactors`.
#' @export
#' @seealso [reliability_report()], [cfa_syntax()]
#'
#' @examples
#' \dontrun{
#' er <- efa_report(responses, instr)
#' print(er)
#' }
efa_report <- function(
    data,
    instrument,
    scales    = NULL,
    nfactors  = NULL,
    rotation  = "oblimin"
) {
  stopifnot(inherits(instrument, "sframe"))
  stopifnot(is.data.frame(data))

  target_scales <- instrument$scales
  if (!is.null(scales)) {
    target_scales <- Filter(function(s) s$id %in% scales, target_scales)
  }

  all_items <- unique(unlist(lapply(target_scales, function(s) s$items)))
  cols      <- intersect(all_items, colnames(data))

  item_data <- as.data.frame(lapply(data[, cols, drop = FALSE],
                                    function(x) suppressWarnings(as.numeric(x))))
  item_data <- item_data[complete.cases(item_data), , drop = FALSE]

  kmo      <- psych::KMO(item_data)
  bart     <- psych::cortest.bartlett(item_data)
  parallel <- psych::fa.parallel(item_data, plot = FALSE)

  suggested <- nfactors %||% parallel$nfact

  structure(
    list(
      kmo               = kmo,
      bartlett          = bart,
      parallel          = parallel,
      suggested_nfactors = suggested,
      rotation_note     = rotation,
      n_items           = length(cols),
      n                 = nrow(item_data)
    ),
    class = "sframe_efa_report"
  )
}

#' @exportS3Method print sframe_efa_report
print.sframe_efa_report <- function(x, ...) {
  cat("EFA Readiness Diagnostics\n\n")
  cat(sprintf("  Items:          %d\n", x$n_items))
  cat(sprintf("  Complete cases: %d\n", x$n))
  cat(sprintf("  KMO overall:    %.3f\n", x$kmo$MSA))
  cat(sprintf("  Bartlett chi-sq: %.2f  df: %d  p: %.4f\n",
              x$bartlett$chisq, x$bartlett$df, x$bartlett$p.value))
  cat(sprintf("  Suggested factors (parallel analysis): %d\n",
              x$suggested_nfactors))
  cat(sprintf("  Planned rotation: %s\n", x$rotation_note))
  cat("\nNote: this report does not estimate an EFA solution.\n")
  invisible(x)
}


# cfa_syntax.R

#' Generate lavaan CFA syntax from an instrument object
#'
#' Produces a character string of `lavaan` model syntax derived from the
#' scale structure in the instrument. The syntax can be passed directly to
#' `lavaan::cfa()`. Reverse-coded items are noted in a comment but are not
#' transformed in the syntax; recoding should be applied to the data before
#' fitting the model.
#'
#' @param instrument An `sframe` object.
#' @param scales Character vector or NULL. A subset of scale IDs to include.
#'   When NULL, all scales are included.
#' @param std_lv Logical. Whether to include the `std.lv = TRUE` argument note
#'   in the output comment header. Defaults to `TRUE`.
#'
#' @return A character string of `lavaan` CFA model syntax.
#' @export
#' @seealso [efa_report()], [reliability_report()]
#'
#' @examples
#' \dontrun{
#' syntax <- cfa_syntax(instr)
#' cat(syntax)
#' fit <- lavaan::cfa(syntax, data = scored_data, std.lv = TRUE)
#' }
cfa_syntax <- function(instrument, scales = NULL, std_lv = TRUE) {
  stopifnot(inherits(instrument, "sframe"))

  target_scales <- instrument$scales
  if (!is.null(scales)) {
    target_scales <- Filter(function(s) s$id %in% scales, target_scales)
  }

  item_reverse <- stats::setNames(
    vapply(instrument$items, function(i) isTRUE(i$reverse), logical(1)),
    vapply(instrument$items, function(i) i$id, character(1))
  )
  for (scale in instrument$scales) {
    if (!is.null(scale$reverse_items)) {
      for (rid in scale$reverse_items) item_reverse[rid] <- TRUE
    }
  }

  lines <- character(0)
  lines <- c(lines, "# lavaan CFA syntax generated by surveyframe")
  lines <- c(lines, paste0("# Instrument: ", instrument$meta$title,
                            " v", instrument$meta$version))
  if (std_lv) {
    lines <- c(lines, "# Recommended: lavaan::cfa(model, data = ..., std.lv = TRUE)")
  }
  lines <- c(lines, "")

  for (scale in target_scales) {
    rev_items <- intersect(names(which(item_reverse)), scale$items)
    if (length(rev_items) > 0) {
      lines <- c(lines, paste0("# Reverse-coded in '", scale$id, "': ",
                               paste(rev_items, collapse = ", ")))
    }
    item_str <- paste(scale$items, collapse = " +\n    ")
    lines <- c(lines,
      paste0(scale$id, " =~ ", item_str),
      ""
    )
  }

  paste(lines, collapse = "\n")
}
