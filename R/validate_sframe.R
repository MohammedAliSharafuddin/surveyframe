# validate_sframe.R

#' Validate an instrument object
#'
#' Checks the internal consistency of an `sframe` instrument object and
#' reports all detected problems. Validation is performed automatically by
#' [write_sframe()] and optionally by [read_sframe()]. It can also be run
#' independently at any point during instrument construction.
#'
#' The following checks are performed:
#' - Duplicate item IDs
#' - Items with missing labels
#' - Items referencing a `choice_set` that is not defined in the instrument
#' - Items referencing a `scale_id` that is not defined in the instrument
#' - Items marked `reverse = TRUE` without a `scale_id`
#' - Choice sets referenced by items but not present in the instrument
#' - Scale `items` vectors containing IDs not present in the instrument
#' - Branching rules referencing item IDs not present in the instrument
#' - Attention checks referencing item IDs not present in the instrument
#'
#' @param instrument An `sframe` object created by [sf_instrument()].
#' @param strict Logical. When `TRUE` (default), any detected problem raises
#'   an error of class `sframe_validation_error`. When `FALSE`, problems are
#'   returned as a character vector of messages without stopping.
#'
#' @return When `strict = TRUE` and the instrument is valid, the instrument
#'   is returned invisibly with `meta$validated` set to `TRUE`. When
#'   `strict = FALSE`, a named list with elements `valid` (logical) and
#'   `problems` (character vector) is returned.
#' @export
#' @seealso [sf_instrument()], [write_sframe()]
#'
#' @examples
#' \dontrun{
#' instr <- sf_instrument("My Survey", components = list(...))
#' validate_sframe(instr)
#' }
validate_sframe <- function(instrument, strict = TRUE) {
  stopifnot(inherits(instrument, "sframe"))

  problems <- character(0)

  item_ids    <- vapply(instrument$items,    function(x) x$id, character(1))
  choice_ids  <- vapply(instrument$choices,  function(x) x$id, character(1))
  scale_ids   <- vapply(instrument$scales,   function(x) x$id, character(1))

  # Duplicate item IDs
  dupes <- item_ids[duplicated(item_ids)]
  if (length(dupes) > 0) {
    problems <- c(problems,
      paste0("Duplicate item IDs: ", paste(dupes, collapse = ", ")))
  }

  for (item in instrument$items) {
    # Missing labels
    if (is.null(item$label) || nchar(trimws(item$label)) == 0) {
      problems <- c(problems,
        paste0("Item '", item$id, "' has an empty label."))
    }
    # Orphan choice set references
    if (!is.null(item$choice_set) && !item$choice_set %in% choice_ids) {
      problems <- c(problems,
        paste0("Item '", item$id, "' references choice_set '",
               item$choice_set, "' which is not defined."))
    }
    # Orphan scale references
    if (!is.null(item$scale_id) && !item$scale_id %in% scale_ids) {
      problems <- c(problems,
        paste0("Item '", item$id, "' references scale_id '",
               item$scale_id, "' which is not defined."))
    }
    # Reverse coded without scale
    if (isTRUE(item$reverse) && is.null(item$scale_id)) {
      problems <- c(problems,
        paste0("Item '", item$id, "' is reverse = TRUE but has no scale_id."))
    }
  }

  # Scale item membership
  for (scale in instrument$scales) {
    missing_items <- setdiff(scale$items, item_ids)
    if (length(missing_items) > 0) {
      problems <- c(problems,
        paste0("Scale '", scale$id, "' references unknown item(s): ",
               paste(missing_items, collapse = ", ")))
    }
  }

  # Branching rule integrity
  for (rule in instrument$branching) {
    if (!rule$item_id %in% item_ids) {
      problems <- c(problems,
        paste0("Branch rule targets unknown item '", rule$item_id, "'."))
    }
    if (!rule$depends_on %in% item_ids) {
      problems <- c(problems,
        paste0("Branch rule depends_on unknown item '", rule$depends_on, "'."))
    }
  }

  # Check item references
  check_item_ids <- vapply(instrument$checks, function(x) x$item_id, character(1))
  missing_check_items <- setdiff(check_item_ids, item_ids)
  if (length(missing_check_items) > 0) {
    problems <- c(problems,
      paste0("Check(s) reference unknown item(s): ",
             paste(missing_check_items, collapse = ", ")))
  }

  if (strict && length(problems) > 0) {
    sframe_abort_validation(
      paste0(
        "Instrument validation failed with ",
        length(problems),
        " problem(s):\n",
        paste0("  - ", problems, collapse = "\n")
      ),
      instrument_title = instrument$meta$title
    )
  }

  if (!strict) {
    return(list(valid = length(problems) == 0, problems = problems))
  }

  # Mark as validated
  instrument$meta$validated <- TRUE
  invisible(instrument)
}
