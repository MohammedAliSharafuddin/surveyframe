# sf_item.R

#' Define a survey item
#'
#' Creates a single survey item object for inclusion in an `sframe` instrument.
#' Items are the atomic units of a survey instrument. Every item must have a
#' unique `id` within the instrument it is added to.
#'
#' @param id Character. A unique identifier for this item. Must contain only
#'   letters, numbers, and underscores. Used as the column name in response
#'   data.
#' @param label Character. The question text displayed to the respondent.
#' @param type Character. The response type. One of `"single_choice"`,
#'   `"multiple_choice"`, `"likert"`, `"numeric"`, `"text"`, `"textarea"`,
#'   or `"date"`.
#' @param required Logical. Whether the respondent must answer this item before
#'   proceeding. Defaults to `FALSE`.
#' @param choice_set Character or NULL. The `id` of a choice set defined with
#'   [sf_choices()]. Required for `"single_choice"`, `"multiple_choice"`, and
#'   `"likert"` types.
#' @param scale_id Character or NULL. The `id` of the scale this item belongs
#'   to, as defined with [sf_scale()]. Items may belong to at most one scale.
#' @param reverse Logical. Whether this item is reverse-coded within its scale.
#'   Ignored if `scale_id` is `NULL`. Defaults to `FALSE`.
#' @param help Character or NULL. Optional help text displayed beneath the
#'   question label.
#' @param placeholder Character or NULL. Placeholder text for `"text"` and
#'   `"textarea"` types.
#'
#' @return An object of class `sf_item` (a named list).
#' @export
#' @seealso [sf_instrument()], [sf_choices()], [sf_scale()]
#'
#' @examples
#' # A required Likert item linked to a scale
#' item <- sf_item(
#'   id         = "sat_overall",
#'   label      = "Overall, how satisfied are you with the service?",
#'   type       = "likert",
#'   required   = TRUE,
#'   choice_set = "agree5",
#'   scale_id   = "satisfaction"
#' )
#'
#' # A numeric item
#' age <- sf_item("age", "What is your age?", type = "numeric", required = TRUE)
sf_item <- function(
    id,
    label,
    type        = c("single_choice", "multiple_choice", "likert",
                    "numeric", "text", "textarea", "date"),
    required    = FALSE,
    choice_set  = NULL,
    scale_id    = NULL,
    reverse     = FALSE,
    help        = NULL,
    placeholder = NULL
) {
  type <- rlang::arg_match(type)

  structure(
    list(
      id          = id,
      label       = label,
      type        = type,
      required    = required,
      choice_set  = choice_set,
      scale_id    = scale_id,
      reverse     = reverse,
      help        = help,
      placeholder = placeholder
    ),
    class = "sf_item"
  )
}
