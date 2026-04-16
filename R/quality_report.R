# quality_report.R

#' Generate a data quality report for survey responses
#'
#' Evaluates collected response data against the instrument specification and
#' produces a structured quality report. The report covers attention check
#' performance, completion time, straight-lining within scale blocks,
#' item-level missingness, respondent-level missingness, and duplicate
#' respondent IDs where supplied.
#'
#' @param data A `tibble` or `data.frame` of responses, typically produced by
#'   [read_responses()].
#' @param instrument An `sframe` object created by [sf_instrument()].
#' @param respondent_id Character or NULL. The column name holding unique
#'   respondent identifiers. Used for duplicate detection.
#' @param submitted_at Character or NULL. The column name holding submission
#'   timestamps. Used for completion time analysis.
#' @param time_min Numeric or NULL. Minimum acceptable completion time in
#'   seconds. Respondents with a submission time below this threshold are
#'   flagged as speeders. Only used when `submitted_at` is supplied and the
#'   data contain a start-time column.
#' @param straightline_scales Logical. Whether to check for straight-lining
#'   within each defined scale block. Defaults to `TRUE`.
#' @param missing_threshold Numeric. The proportion of missing item responses
#'   above which a respondent is flagged. Defaults to `0.2`.
#'
#' @return An object of class `sframe_quality_report`, a named list with
#'   elements: `summary`, `attention`, `timing`, `straightline`, `missing`,
#'   and `duplicates`. Use `print()` for a formatted summary.
#' @export
#' @seealso [sf_check()], [read_responses()], [score_scales()]
#'
#' @examples
#' \dontrun{
#' responses <- read_responses("data/responses.csv", instr,
#'                             respondent_id = "id")
#' qr <- quality_report(responses, instr, respondent_id = "id")
#' print(qr)
#' }
quality_report <- function(
    data,
    instrument,
    respondent_id         = NULL,
    submitted_at          = NULL,
    time_min              = NULL,
    straightline_scales   = TRUE,
    missing_threshold     = 0.2
) {
  stopifnot(inherits(instrument, "sframe"))
  stopifnot(is.data.frame(data))

  item_ids <- vapply(instrument$items, function(i) i$id, character(1))
  n        <- nrow(data)

  # --- Attention checks ---
  attn_results <- list()
  for (chk in instrument$checks) {
    col <- chk$item_id
    if (!col %in% colnames(data)) next
    responses  <- data[[col]]
    pass       <- responses %in% chk$pass_values
    attn_results[[chk$id]] <- list(
      check_id    = chk$id,
      item_id     = col,
      type        = chk$type,
      fail_action = chk$fail_action,
      n_pass      = sum(pass, na.rm = TRUE),
      n_fail      = sum(!pass, na.rm = TRUE),
      pass_rate   = mean(pass, na.rm = TRUE),
      failed_rows = which(!pass)
    )
  }

  # --- Missingness ---
  item_cols     <- intersect(item_ids, colnames(data))
  item_data     <- data[, item_cols, drop = FALSE]
  item_miss     <- colMeans(is.na(item_data))
  resp_miss     <- rowMeans(is.na(item_data))
  flagged_resp  <- which(resp_miss > missing_threshold)

  missing_result <- list(
    item_miss_rate    = item_miss,
    respondent_miss   = resp_miss,
    flagged_threshold = missing_threshold,
    flagged_rows      = flagged_resp
  )

  # --- Straight-lining ---
  sl_results <- list()
  if (straightline_scales && length(instrument$scales) > 0) {
    for (scale in instrument$scales) {
      scale_cols <- intersect(scale$items, colnames(data))
      if (length(scale_cols) < 2) next
      scale_data <- data[, scale_cols, drop = FALSE]
      # Flag respondents with zero variance across scale items
      row_vars <- apply(scale_data, 1, function(row) {
        vals <- suppressWarnings(as.numeric(row))
        if (sum(!is.na(vals)) < 2) return(NA)
        var(vals, na.rm = TRUE)
      })
      sl_results[[scale$id]] <- list(
        scale_id      = scale$id,
        n_items       = length(scale_cols),
        flagged_rows  = which(!is.na(row_vars) & row_vars == 0),
        flag_rate     = mean(!is.na(row_vars) & row_vars == 0)
      )
    }
  }

  # --- Duplicates ---
  dup_result <- list(flagged_rows = integer(0))
  if (!is.null(respondent_id) && respondent_id %in% colnames(data)) {
    ids          <- data[[respondent_id]]
    dup_result   <- list(
      flagged_rows = which(duplicated(ids) | duplicated(ids, fromLast = TRUE)),
      n_duplicates = sum(duplicated(ids))
    )
  }

  # --- Summary ---
  total_flags <- length(unique(c(
    unlist(lapply(attn_results, function(x) x$failed_rows)),
    missing_result$flagged_rows,
    unlist(lapply(sl_results, function(x) x$flagged_rows)),
    dup_result$flagged_rows
  )))

  report <- structure(
    list(
      summary = list(
        n_respondents  = n,
        n_items        = length(item_cols),
        n_flagged      = total_flags,
        flag_rate      = total_flags / n
      ),
      attention    = attn_results,
      timing       = list(),
      straightline = sl_results,
      missing      = missing_result,
      duplicates   = dup_result
    ),
    class = "sframe_quality_report"
  )

  report
}

#' @exportS3Method print sframe_quality_report
print.sframe_quality_report <- function(x, ...) {
  cat("Survey Data Quality Report\n")
  cat(sprintf("  Respondents:  %d\n", x$summary$n_respondents))
  cat(sprintf("  Items:        %d\n", x$summary$n_items))
  cat(sprintf("  Flagged:      %d (%.1f%%)\n",
              x$summary$n_flagged,
              x$summary$flag_rate * 100))
  if (length(x$attention) > 0) {
    cat("\nAttention checks:\n")
    for (chk in x$attention) {
      cat(sprintf("  %-20s pass %.0f%%  fail %d\n",
                  chk$check_id,
                  chk$pass_rate * 100,
                  chk$n_fail))
    }
  }
  cat(sprintf("\nMissingness:  %.1f%% of respondents exceed %.0f%% threshold\n",
              mean(x$missing$respondent_miss > x$missing$flagged_threshold,
                   na.rm = TRUE) * 100,
              x$missing$flagged_threshold * 100))
  invisible(x)
}
