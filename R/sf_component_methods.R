# sf_component_methods.R
# S3 methods (print, format, summary) for the sframe component classes:
# sf_choices, sf_item, sf_scale, sf_branch, sf_check, sf_model.
# These give every exported component constructor a visible, documented S3
# surface so that methods(class = "sf_choices") and friends are non-empty.

# sf_choices -----------------------------------------------------------------

#' Print an sf_choices object
#'
#' Prints the choice set's ID and number of options, then a table of each
#' option's value and label.
#'
#' @param x An object of class `sf_choices`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return `x`, invisibly.
#' @exportS3Method print sf_choices
#' @examples
#' cs <- sframe_choice_set("agree5", 1:5,
#'                  c("Strongly disagree", "Disagree", "Neutral",
#'                    "Agree", "Strongly agree"))
#' print(cs)
#' @family printing formatting and summary methods
print.sf_choices <- function(x, ...) {
  cat(sprintf("<sf_choices: %s | %s>\n", x$id, sframe_count_noun(length(x$values), "option")))
  if (length(x$values) > 0) {
    df <- data.frame(value = x$values, label = x$labels,
                     stringsAsFactors = FALSE, check.names = FALSE)
    print(df, row.names = FALSE)
  }
  invisible(x)
}

#' Format an sf_choices object as a string
#'
#' Gives the choice set's ID and number of options as 1 line, the line that
#' `print()` starts with.
#'
#' @param x An object of class `sf_choices`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return A single character string.
#' @exportS3Method format sf_choices
#' @family printing formatting and summary methods
format.sf_choices <- function(x, ...) {
  sprintf("<sf_choices: %s | %s>", x$id, sframe_count_noun(length(x$values), "option"))
}

#' Summarise an sf_choices object
#'
#' Prints the choice set's 1-line format, then whether it offers an "Other"
#' answer and whether it shows its options in random order.
#'
#' @param object An object of class `sf_choices`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return `object`, invisibly.
#' @exportS3Method summary sf_choices
#' @family printing formatting and summary methods
summary.sf_choices <- function(object, ...) {
  cat(format(object), "\n")
  cat(sprintf("  allow_other: %s | randomise: %s\n",
              isTRUE(object$allow_other), isTRUE(object$randomise)))
  invisible(object)
}

# sf_item --------------------------------------------------------------------

#' Print an sf_item object
#'
#' Prints the item's ID, type and question label, with its choice set and
#' scale when it has them.
#'
#' @param x An object of class `sf_item`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return `x`, invisibly.
#' @exportS3Method print sf_item
#' @examples
#' it <- sframe_item("q1", "How satisfied are you?", type = "likert",
#'               choice_set = "agree5")
#' print(it)
#' @family printing formatting and summary methods
print.sf_item <- function(x, ...) {
  cat(sprintf("<sf_item: %s | type: %s>\n", x$id, x$type))
  cat(sprintf("  Label: %s\n", x$label))
  if (!is.null(x$choice_set)) cat(sprintf("  Choice set: %s\n", x$choice_set))
  if (!is.null(x$scale_id))   cat(sprintf("  Scale: %s\n", x$scale_id))
  invisible(x)
}

#' Format an sf_item object as a string
#'
#' Gives the item's ID and type as 1 line, the line that `print()` starts
#' with.
#'
#' @param x An object of class `sf_item`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return A single character string.
#' @exportS3Method format sf_item
#' @family printing formatting and summary methods
format.sf_item <- function(x, ...) {
  sprintf("<sf_item: %s | type: %s>", x$id, x$type)
}

#' Summarise an sf_item object
#'
#' Prints the item's 1-line format, then whether an answer is required and
#' whether the item is reverse-scored.
#'
#' @param object An object of class `sf_item`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return `object`, invisibly.
#' @exportS3Method summary sf_item
#' @family printing formatting and summary methods
summary.sf_item <- function(object, ...) {
  cat(format(object), "\n")
  cat(sprintf("  required: %s | reverse: %s\n",
              isTRUE(object$required), isTRUE(object$reverse)))
  invisible(object)
}

# sf_scale -------------------------------------------------------------------

#' Print an sf_scale object
#'
#' Prints the scale's ID, label, items and scoring method.
#'
#' @param x An object of class `sf_scale`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return `x`, invisibly.
#' @exportS3Method print sf_scale
#' @examples
#' sc <- sframe_scale("sat", "Satisfaction", items = c("q1", "q2", "q3"))
#' print(sc)
#' @family printing formatting and summary methods
print.sf_scale <- function(x, ...) {
  cat(sprintf("<sf_scale: %s | %s>\n", x$id, sframe_count_noun(length(x$items), "item")))
  cat(sprintf("  Label: %s\n", x$label))
  cat(sprintf("  Items: %s\n", paste(x$items, collapse = ", ")))
  cat(sprintf("  Scoring: %s\n", x$method %||% "mean"))
  invisible(x)
}

#' Format an sf_scale object as a string
#'
#' Gives the scale's ID and number of items as 1 line, the line that `print()`
#' starts with.
#'
#' @param x An object of class `sf_scale`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return A single character string.
#' @exportS3Method format sf_scale
#' @family printing formatting and summary methods
format.sf_scale <- function(x, ...) {
  sprintf("<sf_scale: %s | %s>", x$id, sframe_count_noun(length(x$items), "item"))
}

#' Summarise an sf_scale object
#'
#' Prints the scale's 1-line format, then its scoring method and how many
#' answered items a score needs.
#'
#' @param object An object of class `sf_scale`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return `object`, invisibly.
#' @exportS3Method summary sf_scale
#' @family printing formatting and summary methods
summary.sf_scale <- function(object, ...) {
  cat(format(object), "\n")
  cat(sprintf("  scoring: %s | min valid: %s\n",
              object$method %||% "mean",
              object$min_valid %||% length(object$items)))
  invisible(object)
}

# sf_branch ------------------------------------------------------------------

#' Print an sf_branch object
#'
#' Prints the question a branching rule controls and the rule itself: its
#' action, the question it depends on, the operator and the value.
#'
#' @param x An object of class `sf_branch`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return `x`, invisibly.
#' @exportS3Method print sf_branch
#' @examples
#' br <- sframe_branch("q2", depends_on = "q1", operator = "==",
#'                 value = "yes", action = "show")
#' print(br)
#' @family printing formatting and summary methods
print.sf_branch <- function(x, ...) {
  cat(sprintf("<sf_branch: %s>\n", x$item_id))
  cat(sprintf("  Rule: %s when %s %s %s\n",
              x$action %||% "show",
              x$depends_on, x$operator,
              paste(x$value, collapse = ", ")))
  invisible(x)
}

#' Format an sf_branch object as a string
#'
#' Gives a branching rule as 1 line: the question it controls, the question it
#' depends on, the operator and the value.
#'
#' @param x An object of class `sf_branch`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return A single character string.
#' @exportS3Method format sf_branch
#' @family printing formatting and summary methods
format.sf_branch <- function(x, ...) {
  sprintf("<sf_branch: %s on %s %s %s>",
          x$item_id, x$depends_on, x$operator,
          paste(x$value, collapse = ", "))
}

#' Summarise an sf_branch object
#'
#' Prints a branching rule's 1-line format, which holds every part of the
#' rule.
#'
#' @param object An object of class `sf_branch`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return `object`, invisibly.
#' @exportS3Method summary sf_branch
#' @family printing formatting and summary methods
summary.sf_branch <- function(object, ...) {
  cat(format(object), "\n")
  invisible(object)
}

# sf_check -------------------------------------------------------------------

#' Print an sf_check object
#'
#' Prints the check's ID and type, the item it reads and the answers that pass
#' it.
#'
#' @param x An object of class `sf_check`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return `x`, invisibly.
#' @exportS3Method print sf_check
#' @examples
#' ck <- sframe_attention_check("attn1", item_id = "q5", type = "attention",
#'                pass_values = 3)
#' print(ck)
#' @family printing formatting and summary methods
print.sf_check <- function(x, ...) {
  cat(sprintf("<sf_check: %s | type: %s>\n", x$id, x$type))
  cat(sprintf("  Item: %s\n", x$item_id))
  if (!is.null(x$pass_values)) {
    cat(sprintf("  Pass values: %s\n", paste(x$pass_values, collapse = ", ")))
  }
  invisible(x)
}

#' Format an sf_check object as a string
#'
#' Gives the check's ID, type and item as 1 line.
#'
#' @param x An object of class `sf_check`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return A single character string.
#' @exportS3Method format sf_check
#' @family printing formatting and summary methods
format.sf_check <- function(x, ...) {
  sprintf("<sf_check: %s | type: %s | item: %s>", x$id, x$type, x$item_id)
}

#' Summarise an sf_check object
#'
#' Prints the check's 1-line format, then what happens to a response that
#' fails it.
#'
#' @param object An object of class `sf_check`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return `object`, invisibly.
#' @exportS3Method summary sf_check
#' @family printing formatting and summary methods
summary.sf_check <- function(object, ...) {
  cat(format(object), "\n")
  cat(sprintf("  fail action: %s\n", object$fail_action %||% "none"))
  invisible(object)
}

# sf_model -------------------------------------------------------------------

#' Print an sf_model object
#'
#' Prints the model's ID, type and number of constructs, then its label and
#' estimation engine.
#'
#' @param x An object of class `sf_model`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return `x`, invisibly.
#' @exportS3Method print sf_model
#' @family printing formatting and summary methods
print.sf_model <- function(x, ...) {
  n_con <- length(x$measurement$constructs %||% list())
  cat(sprintf("<sf_model: %s | type: %s | %s>\n",
              x$id, x$type, sframe_count_noun(n_con, "construct")))
  cat(sprintf("  Label: %s\n", x$label))
  cat(sprintf("  Engine: %s\n", x$engine %||% "lavaan"))
  invisible(x)
}

#' Format an sf_model object as a string
#'
#' Gives the model's ID, type and number of constructs as 1 line, the line
#' that `print()` starts with.
#'
#' @param x An object of class `sf_model`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return A single character string.
#' @exportS3Method format sf_model
#' @family printing formatting and summary methods
format.sf_model <- function(x, ...) {
  n_con <- length(x$measurement$constructs %||% list())
  sprintf("<sf_model: %s | type: %s | %s>", x$id, x$type, sframe_count_noun(n_con, "construct"))
}

#' Summarise an sf_model object
#'
#' Prints the model's 1-line format, then its estimation engine and number of
#' structural paths.
#'
#' @param object An object of class `sf_model`.
#' @param ... Ignored. Present for S3 consistency.
#'
#' @return `object`, invisibly.
#' @exportS3Method summary sf_model
#' @family printing formatting and summary methods
summary.sf_model <- function(object, ...) {
  cat(format(object), "\n")
  n_paths <- length(object$structural$paths %||% list())
  cat(sprintf("  engine: %s | structural paths: %d\n",
              object$engine %||% "lavaan", n_paths))
  invisible(object)
}
