# sframe_methods.R
# S3 methods for the sframe class.

# The status print(), format() and summary() show, from validate_sframe()
# run on the object as Studio's Open Instrument does, never the stored
# meta$validated, which is a cache that a later edit can leave stale. short
# = TRUE drops the pointer to the problem list, for format().
sframe_status_text <- function(x, short = FALSE) {
  check <- tryCatch(validate_sframe(x, strict = FALSE),
                    error = function(e) list(valid = FALSE, problems = conditionMessage(e)))
  n <- length(as.character(check$problems %||% character(0)))
  if (isTRUE(check$valid) && n == 0) return("valid")
  out <- paste0("invalid, ", sframe_count_noun(max(n, 1L), "problem"))
  if (short) out else paste0(out, ". validate_sframe(x, strict = FALSE) lists them")
}

#' Print an sframe instrument object
#'
#' Displays a compact summary of an `sframe` instrument object, showing
#' the title, version, item count, scale count, and validation status. The
#' status comes from [validate_sframe()] run on `x`, not from a stored flag.
#'
#' @param x An object of class `sframe`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return `x`, invisibly.
#' @exportS3Method print sframe
#' @examples
#' item <- sframe_item("q1", "How satisfied are you?", type = "likert",
#'                 choice_set = "agree5")
#' instr <- sframe_instrument("My Survey", components = list(item))
#' print(instr)
#' @family print, format and summary methods
print.sframe <- function(x, ...) {
  n_items  <- length(x$items)
  n_scales <- length(x$scales)
  n_plan   <- length(x$analysis_plan)
  status   <- sframe_status_text(x)

  cat(
    sprintf(
      "<sframe>\n  Title:      %s\n  Version:    %s\n  Items:      %d\n  Scales:     %d\n  Analysis:   %s\n  Status:     %s\n",
      x$meta$title,
      x$meta$version,
      n_items,
      n_scales,
      sframe_count_noun(n_plan, "block"),
      status
    )
  )
  if (isFALSE(attr(x, "sframe_verified"))) {
    cat("  Hash:       unverified, read with verify = FALSE\n")
  }
  invisible(x)
}

#' Format an sframe instrument object as a string
#'
#' @param x An object of class `sframe`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return A single character string.
#' @exportS3Method format sframe
#' @family print, format and summary methods
format.sframe <- function(x, ...) {
  sprintf(
    "<sframe: %s v%s | %s | %s | %s | %s>",
    x$meta$title,
    x$meta$version,
    sframe_count_noun(length(x$items), "item"),
    sframe_count_noun(length(x$scales), "scale"),
    sframe_count_noun(length(x$analysis_plan), "analysis block"),
    sframe_status_text(x, short = TRUE)
  )
}

#' Summarise an sframe instrument object
#'
#' Prints a structured summary of an `sframe` object including metadata,
#' item type counts, scale definitions, branching rules, and check
#' specifications.
#'
#' @param object An object of class `sframe`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return `object`, invisibly.
#' @exportS3Method summary sframe
#' @examples
#' item <- sframe_item("q1", "How satisfied are you?", type = "likert",
#'                 choice_set = "agree5")
#' instr <- sframe_instrument("My Survey", components = list(item))
#' summary(instr)
#' @family print, format and summary methods
summary.sframe <- function(object, ...) {
  types <- vapply(object$items, function(i) i$type, character(1))
  type_counts <- sort(table(types), decreasing = TRUE)

  cat(sprintf("Survey Instrument: %s\n", object$meta$title))
  cat(sprintf("Version:           %s\n", object$meta$version))
  if (!is.null(object$meta$description)) {
    cat(sprintf("Description:       %s\n", object$meta$description))
  }
  cat(sprintf("Languages:         %s\n",
              paste(object$meta$languages, collapse = ", ")))
  cat("\nItems:\n")
  for (nm in names(type_counts)) {
    cat(sprintf("  %-20s %d\n", nm, type_counts[[nm]]))
  }
  cat(sprintf("  %-20s %d\n", "TOTAL", length(object$items)))
  cat(sprintf("\nScales:    %d\n", length(object$scales)))
  cat(sprintf("Branches:  %d\n", length(object$branching)))
  cat(sprintf("Checks:    %d\n", length(object$checks)))
  plan <- object$analysis_plan %||% list()
  cat(sprintf("\nAnalysis plan: %s\n", sframe_count_noun(length(plan), "block")))
  if (length(plan) > 0) {
    methods <- vapply(plan, function(b) {
      as.character(b$method %||% b$test %||% "(unset)")
    }, character(1))
    for (i in seq_along(plan)) {
      cat(sprintf("  %-8s %s\n", plan[[i]]$id %||% sprintf("[%d]", i), methods[i]))
    }
  }
  cat(sprintf("\nStatus:    %s\n", sframe_status_text(object)))
  invisible(object)
}
