# read_responses.R

#' Read and validate survey responses
#'
#' Loads survey response data and checks that it conforms to the instrument
#' specification. Column names in the response file must match item IDs defined
#' in the instrument. Non-item columns are allowed only when declared through
#' `respondent_id`, `submitted_at`, or `meta_cols`.
#'
#' @param x A file path to a CSV file, a `data.frame`, or a `tibble`.
#' @param instrument An `sframe` object created by [sf_instrument()].
#' @param respondent_id Character or NULL. The name of the column containing
#'   unique respondent identifiers. If NULL, no respondent ID column is
#'   expected.
#' @param submitted_at Character or NULL. The name of the column containing
#'   submission timestamps.
#' @param meta_cols Character vector or NULL. Additional column names that are
#'   not item IDs but should be retained (for example, condition assignment or
#'   source URL).
#' @param strict Logical. When `TRUE` (default), columns in the response data
#'   that are not declared as item IDs or metadata columns raise an error.
#'   When `FALSE`, undeclared columns are retained with a warning.
#'
#' @return A `tibble` with columns ordered as: metadata columns first, then
#'   item columns in instrument order. Unrecognised columns are dropped when
#'   `strict = TRUE` or appended with a warning when `strict = FALSE`.
#' @export
#' @seealso [quality_report()], [score_scales()]
#'
#' @examples
#' \dontrun{
#' responses <- read_responses(
#'   x             = "data/responses.csv",
#'   instrument    = instr,
#'   respondent_id = "id",
#'   submitted_at  = "timestamp"
#' )
#' }
read_responses <- function(
    x,
    instrument,
    respondent_id = NULL,
    submitted_at  = NULL,
    meta_cols     = NULL,
    strict        = TRUE
) {
  stopifnot(inherits(instrument, "sframe"))

  # Load data
  if (is.character(x)) {
    if (!file.exists(x)) {
      sframe_abort_import(
        paste0("Response file not found: '", x, "'."),
        path = x
      )
    }
    data <- readr::read_csv(x, show_col_types = FALSE)
  } else if (is.data.frame(x)) {
    data <- tibble::as_tibble(x)
  } else {
    rlang::abort(
      "`x` must be a file path, a data.frame, or a tibble.",
      class = c("sframe_import_error", "sframe_error")
    )
  }

  item_ids  <- vapply(instrument$items, function(i) i$id, character(1))
  declared  <- c(respondent_id, submitted_at, meta_cols)
  data_cols <- colnames(data)

  # Check required item columns are present
  missing_items <- setdiff(item_ids, data_cols)
  if (length(missing_items) > 0) {
    sframe_warn_missing(
      paste0(
        length(missing_items),
        " item column(s) are absent from the response data: ",
        paste(missing_items, collapse = ", ")
      )
    )
  }

  # Handle undeclared columns
  undeclared <- setdiff(data_cols, c(item_ids, declared))
  if (length(undeclared) > 0) {
    if (strict) {
      sframe_abort_import(
        paste0(
          length(undeclared),
          " undeclared column(s) found in response data: ",
          paste(undeclared, collapse = ", "),
          ". Declare them in meta_cols or set strict = FALSE."
        )
      )
    } else {
      sframe_warn_quality(
        paste0(
          length(undeclared),
          " undeclared column(s) retained with a warning: ",
          paste(undeclared, collapse = ", ")
        )
      )
    }
  }

  # Reorder: metadata first, then items in instrument order, then undeclared
  ordered_cols <- intersect(
    c(declared, item_ids, undeclared),
    data_cols
  )

  data[, ordered_cols, drop = FALSE]
}
