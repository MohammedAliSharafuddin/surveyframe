# score_scales.R

sframe_reverse_context <- function(instrument) {
  item_ids <- vapply(instrument$items, function(i) i$id, character(1))

  reverse_map <- stats::setNames(
    vapply(instrument$items, function(i) isTRUE(i$reverse), logical(1)),
    item_ids
  )

  for (scale in instrument$scales) {
    if (is.null(scale$reverse_items)) {
      next
    }
    for (rid in scale$reverse_items) {
      if (rid %in% names(reverse_map)) {
        reverse_map[rid] <- TRUE
      }
    }
  }

  choice_ranges <- stats::setNames(
    lapply(instrument$choices, function(cs) {
      vals <- suppressWarnings(as.numeric(cs$values))
      vals <- vals[!is.na(vals)]
      if (length(vals) == 0) {
        return(NULL)
      }
      c(min(vals), max(vals))
    }),
    vapply(instrument$choices, function(cs) cs$id, character(1))
  )

  item_choice_sets <- stats::setNames(
    vapply(instrument$items, function(i) i$choice_set %||% "", character(1)),
    item_ids
  )

  list(
    reverse_map = reverse_map,
    choice_ranges = choice_ranges,
    item_choice_sets = item_choice_sets
  )
}

sframe_numeric_scale_data <- function(data, item_ids, reverse_context = NULL) {
  scale_num <- as.data.frame(lapply(data[, item_ids, drop = FALSE], function(col) {
    suppressWarnings(as.numeric(col))
  }))

  if (is.null(reverse_context)) {
    return(scale_num)
  }

  for (col in item_ids) {
    if (!isTRUE(reverse_context$reverse_map[[col]])) {
      next
    }

    vals <- scale_num[[col]]
    cs_id <- reverse_context$item_choice_sets[[col]]
    rng <- if (nzchar(cs_id) && !is.null(reverse_context$choice_ranges[[cs_id]])) {
      reverse_context$choice_ranges[[cs_id]]
    } else {
      observed <- vals[!is.na(vals)]
      if (length(observed) == 0) {
        next
      }
      c(min(observed), max(observed))
    }

    scale_num[[col]] <- (rng[1] + rng[2]) - vals
  }

  scale_num
}

#' Score defined scales from survey responses
#'
#' Applies scale scoring rules from the instrument to response data. Handles
#' reverse coding, composite score computation (mean or sum), and minimum
#' valid item thresholds. Returns a data frame with one scored column per
#' scale.
#'
#' @param data A `tibble` or `data.frame` of responses.
#' @param instrument An `sframe` object.
#' @param keep_items Logical. Whether to retain individual item columns in the
#'   output. Defaults to `TRUE`.
#' @param keep_meta Logical. Whether to retain non-item columns (metadata) in
#'   the output. Defaults to `TRUE`.
#'
#' @return A `tibble` with scored scale columns appended. Scale columns are
#'   named using the scale `id`.
#' @export
#' @seealso [sf_scale()], [reliability_report()]
#'
#' @examples
#' \dontrun{
#' scored <- score_scales(responses, instr)
#' }
score_scales <- function(data, instrument, keep_items = TRUE, keep_meta = TRUE) {
  stopifnot(inherits(instrument, "sframe"))
  stopifnot(is.data.frame(data))

  item_ids <- vapply(instrument$items, function(i) i$id, character(1))
  reverse_context <- sframe_reverse_context(instrument)

  scored <- data

  for (scale in instrument$scales) {
    scale_item_ids <- intersect(scale$items, colnames(data))
    if (length(scale_item_ids) == 0) {
      sframe_warn_scoring(
        paste0("Scale '", scale$id, "' has no matching columns in data."),
        scale_id = scale$id
      )
      next
    }

    scale_num <- sframe_numeric_scale_data(data, scale_item_ids, reverse_context)

    # Minimum valid items
    valid_counts <- rowSums(!is.na(scale_num))
    min_valid    <- scale$min_valid %||% length(scale_item_ids)

    composite <- switch(
      scale$method,
      mean = rowMeans(scale_num, na.rm = TRUE),
      sum  = rowSums(scale_num, na.rm = TRUE)
    )
    composite[valid_counts < min_valid] <- NA

    scored[[scale$id]] <- composite
  }

  # Optionally drop items and metadata
  all_meta  <- setdiff(colnames(data), item_ids)
  keep_cols <- character(0)
  if (keep_meta)  keep_cols <- c(keep_cols, all_meta)
  if (keep_items) keep_cols <- c(keep_cols, intersect(item_ids, colnames(scored)))
  scale_cols <- vapply(instrument$scales, function(s) s$id, character(1))
  keep_cols  <- c(keep_cols, intersect(scale_cols, colnames(scored)))

  tibble::as_tibble(scored[, unique(keep_cols), drop = FALSE])
}
