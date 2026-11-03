# R/item_flags.R
#
# The items an item analysis would send for review (session 8a, item d).
# Each cut-off is the usual one with its source, and a flag is a prompt to
# look again, never a deletion rule: content, wording, reverse keying and the
# model's purpose decide. Checked against psych, lavaan and seminr called
# directly (tests/testthat/test-item-flags.R).

sframe_item_flag_rules <- list(
  alpha_if_item_deleted_minus_alpha = list(cutoff = 0, direction = "above",
    source = "Revelle (2025)"),
  corrected_item_total_r = list(cutoff = 0.30, direction = "below",
    source = "Nunnally and Bernstein (1994)"),
  KMO_MSA_item = list(cutoff = 0.50, direction = "below", source = "Kaiser (1974)"),
  absolute_primary_loading = list(cutoff = 0.40, direction = "below",
    source = "Hair et al. (2019)"),
  primary_minus_cross_loading = list(cutoff = 0.20, direction = "below",
    source = "Howard (2016)"),
  absolute_standardised_loading = list(cutoff = 0.50, direction = "below",
    source = "Hair et al. (2019)"),
  AVE = list(cutoff = 0.50, direction = "below", source = "Fornell and Larcker (1981)"),
  HTMT = list(cutoff = 0.85, direction = "above", source = "Henseler et al. (2015)"),
  absolute_outer_loading = list(cutoff = 0.708, direction = "below",
    source = "Hair et al. (2022)")
)

# A value bounded by 1 in APA form, with no leading zero.
sframe_flag_num <- function(x, digits = 2) {
  s <- formatC(x, format = "f", digits = digits)
  sub("^(-?)0\\.", "\\1.", s)
}

#' Items past the usual cut-offs in a measurement result
#'
#' Lists the items, or for validity the constructs, whose statistics cross
#' the cut-off usually applied to them, with the value, the rule, its source
#' and a ready reason, such as "org_4: loading .21 in RQ3, below .40". A flag
#' is a prompt to review the item, not a rule to drop it: its content,
#' wording, reverse keying and the purpose of the model still decide. Drop
#' an item with [sframe_drop_items()] and record it with [amend_sframe()].
#'
#' The results read, and the rule applied to each:
#' * a reliability result ([sframe_reliability_results()]): alpha if the item
#'   is deleted above the scale's alpha. Alpha can rise when a scale narrows,
#'   so the reason asks for the item-total correlation and the wording to be
#'   checked too.
#' * an item result ([sframe_item_results()]): corrected item-total
#'   correlation below .30 (Nunnally and Bernstein, 1994).
#' * an EFA readiness result ([sframe_efa_readiness_results()]): item
#'   sampling adequacy (MSA) below .50 (Kaiser, 1974).
#' * an EFA solution ([sframe_efa_solution()]): primary loading below .40
#'   (Hair et al., 2019), and, with 2 or more factors, the 2 largest loadings
#'   less than .20 apart (Howard, 2016), as 2 separate reasons.
#' * a CFA fitted with lavaan, as from the syntax [sframe_syntax_cfa()]
#'   writes: standardised loading below .50 (Hair et al., 2019).
#' * a validity result ([sframe_validity_results()]): AVE below .50 (Fornell
#'   and Larcker, 1981), and HTMT above `htmt` (Henseler et al., 2015).
#' * a PLS model estimated with seminr: outer loading on the item's own
#'   construct below .708 (Hair et al., 2022). Below .40 the item is a strong
#'   removal candidate. From .40 to .708, check AVE and composite reliability
#'   before removing it.
#'
#' A result from [run_analysis_plan()] for one of these methods is read the
#' same way, and its reasons name the block.
#'
#' @param result A result of one of the kinds above.
#' @param htmt The HTMT threshold: `0.85` for conceptually distinct
#'   constructs (the default) or `0.90` for similar ones. The value applied
#'   is kept as the attribute `htmt_threshold`.
#' @param all If `TRUE`, every row is returned, flagged or not.
#' @param block Character or `NULL`. The plan block named in the reasons. A
#'   plan result supplies its own.
#'
#' @return A data frame with columns `result_type`, `block`, `group` (the
#'   scale, factor, construct or construct pair), `item`, `statistic`,
#'   `value`, `cutoff`, `direction`, `flagged`, `reason` and `source`.
#'
#' @references
#' Fornell, C., & Larcker, D. F. (1981). Evaluating structural equation models
#' with unobservable variables and measurement error. *Journal of Marketing
#' Research, 18*(1), 39-50. \doi{10.1177/002224378101800104}
#'
#' Hair, J. F., Black, W. C., Babin, B. J., & Anderson, R. E. (2019).
#' *Multivariate data analysis* (8th ed.). Cengage.
#'
#' Hair, J. F., Hult, G. T. M., Ringle, C. M., & Sarstedt, M. (2022). *A primer
#' on partial least squares structural equation modeling (PLS-SEM)* (3rd
#' ed.). Sage.
#'
#' Henseler, J., Ringle, C. M., & Sarstedt, M. (2015). A new criterion for
#' assessing discriminant validity in variance-based structural equation
#' modeling. *Journal of the Academy of Marketing Science, 43*(1), 115-135.
#' \doi{10.1007/s11747-014-0403-8}
#'
#' Howard, M. C. (2016). A review of exploratory factor analysis decisions and
#' overview of current practices. *Journal of Business Research, 69*(1),
#' 51-62. \doi{10.1016/j.jbusres.2015.08.024}
#'
#' Kaiser, H. F. (1974). An index of factorial simplicity. *Psychometrika,
#' 39*(1), 31-36. \doi{10.1007/BF02291575}
#'
#' Nunnally, J. C., & Bernstein, I. H. (1994). *Psychometric theory* (3rd ed.).
#' McGraw-Hill.
#'
#' Revelle, W. (2025). *psych: Procedures for psychological, psychometric, and
#' personality research* (R package). Northwestern University.
#' \url{https://CRAN.R-project.org/package=psych}
#'
#' @export
#' @family Amendments functions
#'
#' @examples
#' d <- sframe_demo("likert_scale")
#' if (requireNamespace("psych", quietly = TRUE)) {
#'   sframe_item_flags(sframe_item_results(d$responses, d$instrument), all = TRUE)
#' }
sframe_item_flags <- function(result, htmt = 0.85, all = FALSE, block = NULL) {
  if (!is.numeric(htmt) || length(htmt) != 1 || !htmt %in% c(0.85, 0.90)) {
    rlang::abort("`htmt` must be 0.85 or 0.90.",
                 class = c("sframe_validation_error", "sframe_error"))
  }
  report <- if (is.list(result) && !is.null(attr(result, "sframe_runtime"))) {
    block <- block %||% as.character(result$id %||% result$block_id %||% "")[1]
    sframe_runtime(result, "report")
  } else {
    result
  }
  block <- as.character(block %||% "")[1]
  rows <- list()
  add <- function(type, group, item, statistic, value, cutoff = NULL, detail = NULL) {
    rule <- sframe_item_flag_rules[[statistic]]
    cutoff <- cutoff %||% rule$cutoff
    value <- as.numeric(value)
    flagged <- !is.na(value) &&
      if (identical(rule$direction, "below")) value < cutoff else value > cutoff
    rows[[length(rows) + 1L]] <<- data.frame(
      result_type = type, block = block, group = as.character(group),
      item = as.character(item), statistic = statistic, value = value,
      cutoff = cutoff, direction = rule$direction, flagged = flagged,
      reason = if (flagged) sframe_item_flag_reason(statistic, item, group, value,
                                                    cutoff, block, detail) else "",
      source = rule$source, stringsAsFactors = FALSE)
  }

  if (inherits(report, "sframe_reliability_report")) {
    for (s in unclass(report)) {
      drop <- s$alpha_if_deleted
      if (is.null(drop) || is.null(s$alpha)) next
      for (it in names(drop)) {
        add("reliability", s$scale_id, it, "alpha_if_item_deleted_minus_alpha",
            drop[[it]] - s$alpha, detail = c(drop[[it]], s$alpha))
      }
    }
  } else if (inherits(report, "sframe_item_report")) {
    for (s in unclass(report)) {
      dg <- s$diagnostics
      for (k in seq_len(nrow(dg))) {
        add("item_analysis", s$scale_id, dg$item_id[k], "corrected_item_total_r", dg$item_rest_r[k])
      }
    }
  } else if (inherits(report, "sframe_efa_report")) {
    msa <- report$kmo$MSAi
    for (it in names(msa)) add("efa_readiness", "items", it, "KMO_MSA_item", msa[[it]])
  } else if (inherits(report, "sframe_efa_solution")) {
    L <- report$loadings
    mat <- abs(as.matrix(L[, setdiff(names(L), "item_id"), drop = FALSE]))
    for (k in seq_len(nrow(mat))) {
      ord <- order(mat[k, ], decreasing = TRUE)
      prim <- mat[k, ord[1]]
      fac <- colnames(mat)[ord[1]]
      add("efa", fac, L$item_id[k], "absolute_primary_loading", prim)
      if (ncol(mat) >= 2) {
        sec <- mat[k, ord[2]]
        add("efa", fac, L$item_id[k], "primary_minus_cross_loading", prim - sec,
            detail = c(prim, sec))
      }
    }
  } else if (inherits(report, "lavaan")) {
    std <- lavaan::standardizedSolution(report)
    std <- std[std$op == "=~", , drop = FALSE]
    for (k in seq_len(nrow(std))) {
      add("cfa", std$lhs[k], std$rhs[k], "absolute_standardised_loading", abs(std$est.std[k]))
    }
  } else if (inherits(report, "sframe_validity_report")) {
    rel <- report$reliability
    for (k in seq_len(nrow(rel))) add("validity", rel$construct[k], NA_character_, "AVE", rel$AVE[k])
    h <- report$htmt
    if (is.matrix(h) && nrow(h) >= 2) {
      for (i in seq_len(nrow(h) - 1L)) for (j in (i + 1L):ncol(h)) {
        add("validity", paste(rownames(h)[i], colnames(h)[j], sep = "__"), NA_character_,
            "HTMT", h[i, j], cutoff = htmt)
      }
    }
  } else if (inherits(report, "seminr_model")) {
    L <- as.matrix(report$outer_loadings)
    mm <- report$mmMatrix
    for (k in seq_len(nrow(mm))) {
      it <- mm[k, "measurement"]
      con <- mm[k, "construct"]
      if (!it %in% rownames(L) || !con %in% colnames(L)) next
      add("pls", con, it, "absolute_outer_loading", abs(L[it, con]))
    }
  } else {
    rlang::abort(paste0(
      "sframe_item_flags() reads a reliability, item, EFA readiness, EFA, ",
      "validity or plan result, a lavaan CFA or a seminr PLS model."),
      class = c("sframe_validation_error", "sframe_error"))
  }

  out <- if (length(rows)) do.call(rbind, rows) else data.frame(
    result_type = character(0), block = character(0), group = character(0),
    item = character(0), statistic = character(0), value = numeric(0),
    cutoff = numeric(0), direction = character(0), flagged = logical(0),
    reason = character(0), source = character(0), stringsAsFactors = FALSE)
  if (!isTRUE(all)) out <- out[out$flagged, , drop = FALSE]
  rownames(out) <- NULL
  attr(out, "htmt_threshold") <- htmt
  out
}

sframe_item_flag_reason <- function(statistic, item, group, value, cutoff, block, detail) {
  where <- if (nzchar(block)) paste0(" in ", block) else ""
  cut <- sframe_flag_num(cutoff, if (identical(statistic, "absolute_outer_loading")) 3 else 2)
  switch(statistic,
    alpha_if_item_deleted_minus_alpha = sprintf(paste0(
      "%s: alpha if deleted %s%s, above the scale's %s. Check its item-total ",
      "correlation and wording before dropping it."), item,
      sframe_flag_num(detail[1]), where, sframe_flag_num(detail[2])),
    corrected_item_total_r = sprintf("%s: corrected item-total correlation %s%s, below %s",
      item, sframe_flag_num(value), where, cut),
    KMO_MSA_item = sprintf("%s: sampling adequacy (MSA) %s%s, below %s",
      item, sframe_flag_num(value), where, cut),
    absolute_primary_loading = sprintf("%s: loading %s%s, below %s",
      item, sframe_flag_num(value), where, cut),
    primary_minus_cross_loading = sprintf("%s: loadings %s and %s%s, %s apart, below %s",
      item, sframe_flag_num(detail[1]), sframe_flag_num(detail[2]), where,
      sframe_flag_num(value), cut),
    absolute_standardised_loading = sprintf("%s: standardised loading %s%s, below %s",
      item, sframe_flag_num(value), where, cut),
    AVE = sprintf("%s: AVE %s%s, below %s", group, sframe_flag_num(value), where, cut),
    HTMT = sprintf("%s: HTMT %s%s, above %s", sub("__", " and ", group, fixed = TRUE),
      sframe_flag_num(value), where, cut),
    absolute_outer_loading = if (value < 0.40) {
      sprintf("%s: outer loading %s%s, below .40, a strong candidate for removal",
              item, sframe_flag_num(value, 3), where)
    } else {
      sprintf(paste0("%s: outer loading %s%s, below %s. Check AVE and composite ",
                     "reliability before removing it."), item, sframe_flag_num(value, 3), where, cut)
    })
}
