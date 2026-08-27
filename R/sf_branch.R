# sf_branch.R

# The `%in%` value reaches an evaluator in 2 shapes, and all 3 of them (the
# static template's JS, sframe_module_eval_op(), and .evaluate_branch()) have to
# accept both or they disagree. sf_branch()'s documented contract is a vector,
# which serialises to a JSON array. A file written by hand, or by an older
# builder, carries one comma-separated string instead. Splitting only a length-1
# value covers both without having to guess which is which.
#
# Before this existed the 3 evaluators each handled a different subset: the JS
# threw on an array, sframe_module_eval_op() read only an array's first element,
# and .evaluate_branch() never split a comma string. A multi-value rule was
# therefore dead in every exported survey, silently, from 0.3.0 to 0.4.0.
sframe_branch_in_values <- function(value) {
  chr <- as.character(value)
  chr <- chr[!is.na(chr)]
  if (length(chr) == 0L) {
    return(character(0))
  }
  if (length(chr) == 1L) {
    chr <- strsplit(chr, ",", fixed = TRUE)[[1]]
  }
  trimws(chr)
}

#' Define a branching rule
#'
#' Creates a single-condition branching rule that shows or hides a survey item
#' depending on the value of a preceding item. Only single-condition
#' rules are supported. Multi-condition AND/OR logic is planned for a later
#' release.
#'
#' @param item_id Character. The `id` of the item whose visibility this rule
#'   controls.
#' @param depends_on Character. The `id` of the item whose response value
#'   triggers this rule.
#' @param operator Character. The comparison operator. One of `"=="`, `"!="`,
#'   `"%in%"`, `">"`, `">="`, `"<"`, or `"<="`.
#' @param value The value to compare against the response to `depends_on`.
#'   For `"%in%"`, supply a character or numeric vector.
#' @param action Character. What to do when the condition is met. Either
#'   `"show"` (default) or `"hide"`.
#'
#' @return An object of class `sf_branch` (a named list).
#' @export
#' @seealso [sf_instrument()], [validate_sframe()]
#'
#' @examples
#' # Show an open-text follow-up only when the respondent selects "Other"
#' rule <- sf_branch(
#'   item_id    = "gender_other",
#'   depends_on = "gender",
#'   operator   = "==",
#'   value      = "other",
#'   action     = "show"
#' )
sf_branch <- function(
    item_id,
    depends_on,
    operator = c("==", "!=", "%in%", ">", ">=", "<", "<="),
    value,
    action   = c("show", "hide")
) {
  operator <- rlang::arg_match(operator)
  action   <- rlang::arg_match(action)

  structure(
    list(
      item_id    = item_id,
      depends_on = depends_on,
      operator   = operator,
      value      = value,
      action     = action
    ),
    class = "sf_branch"
  )
}
