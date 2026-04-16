# conditions.R
# Custom condition classes for surveyframe.
# All validators and exported functions must use these classes.
# Raw stop() calls are not permitted in exported code.

# Null-coalescing operator available throughout the package.
# Imported from rlang via @importFrom in surveyframe-package.R.
# The local alias ensures availability when sourcing files directly.
`%||%` <- function(x, y) if (is.null(x)) y else x

#' Abort with a validation error
#'
#' @param message Character. The error message.
#' @param instrument_title Character or NULL. Title of the instrument being
#'   validated, included in the condition metadata when supplied.
#' @param ... Additional named fields passed to `rlang::abort()`.
#' @keywords internal
sframe_abort_validation <- function(message, instrument_title = NULL, ...) {
  rlang::abort(
    message  = message,
    class    = c("sframe_validation_error", "sframe_error"),
    instrument_title = instrument_title,
    ...
  )
}

#' Abort with an import error
#'
#' @param message Character. The error message.
#' @param path Character or NULL. The file path that failed to import.
#' @param ... Additional named fields passed to `rlang::abort()`.
#' @keywords internal
sframe_abort_import <- function(message, path = NULL, ...) {
  rlang::abort(
    message = message,
    class   = c("sframe_import_error", "sframe_error"),
    path    = path,
    ...
  )
}

#' Abort with a branching error
#'
#' @param message Character. The error message.
#' @param item_id Character or NULL. The item ID involved in the broken rule.
#' @param ... Additional named fields passed to `rlang::abort()`.
#' @keywords internal
sframe_abort_branching <- function(message, item_id = NULL, ...) {
  rlang::abort(
    message = message,
    class   = c("sframe_branching_error", "sframe_error"),
    item_id = item_id,
    ...
  )
}

#' Warn about a data quality issue
#'
#' @param message Character. The warning message.
#' @param respondent_ids Character vector or NULL. IDs of affected respondents.
#' @param ... Additional named fields passed to `rlang::warn()`.
#' @keywords internal
sframe_warn_quality <- function(message, respondent_ids = NULL, ...) {
  rlang::warn(
    message        = message,
    class          = c("sframe_quality_warning", "sframe_warning"),
    respondent_ids = respondent_ids,
    ...
  )
}

#' Warn about missing data
#'
#' @param message Character. The warning message.
#' @param item_id Character or NULL. The item ID with missing data.
#' @param rate Numeric or NULL. The observed missing rate.
#' @param ... Additional named fields passed to `rlang::warn()`.
#' @keywords internal
sframe_warn_missing <- function(message, item_id = NULL, rate = NULL, ...) {
  rlang::warn(
    message = message,
    class   = c("sframe_missing_data_warning", "sframe_warning"),
    item_id = item_id,
    rate    = rate,
    ...
  )
}

#' Warn about a scoring issue
#'
#' @param message Character. The warning message.
#' @param scale_id Character or NULL. The scale ID affected.
#' @param ... Additional named fields passed to `rlang::warn()`.
#' @keywords internal
sframe_warn_scoring <- function(message, scale_id = NULL, ...) {
  rlang::warn(
    message  = message,
    class    = c("sframe_scoring_warning", "sframe_warning"),
    scale_id = scale_id,
    ...
  )
}
