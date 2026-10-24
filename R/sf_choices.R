# sf_choices.R
# What a choice set has to carry before it can be answered. A duplicate code
# gives 2 answers the same stored value, and an empty set gives a respondent
# nothing to pick, both of which used to reach a collection engine unchecked.
sframe_choice_content_problems <- function(values, labels) {
  out <- character(0)
  vals <- as.character(values)
  labs <- as.character(labels)
  if (length(vals) == 0) {
    out <- c(out, "it declares no options.")
    return(out)
  }
  if (anyNA(values) || any(!nzchar(trimws(vals)))) {
    out <- c(out, "every value has to be a non-empty code.")
  }
  if (anyNA(labels) || any(!nzchar(trimws(labs)))) {
    out <- c(out, "every option has to carry a label.")
  }
  dup <- unique(vals[duplicated(vals)])
  if (length(dup) > 0) {
    out <- c(out, paste0("the value(s) ", paste(dup, collapse = ", "),
                         " appear more than once, so 2 options share a code."))
  }
  # read_responses() reads a set whose codes are all numbers as numbers, so
  # codes that read as the same number (1 and 1.0, or 2 and 02) become one
  # option there, and the labelled export then fails on duplicate labels
  # (Ethos request 14). Exact repeats are reported above.
  num <- suppressWarnings(as.numeric(vals))
  if (!anyNA(num)) {
    clash <- unique(num[duplicated(num)])
    clash <- clash[vapply(clash, function(n) length(unique(vals[num == n])) > 1, logical(1))]
    for (n in clash) {
      out <- c(out, paste0("the codes ", paste(unique(vals[num == n]), collapse = " and "),
                           " read as the same number, and responses to an all-numeric ",
                           "set are read as numbers, so 2 options would share a code."))
    }
  }
  out
}


#' Define a reusable choice set
#'
#' Creates a named set of response options that can be referenced by one or
#' more items. Defining choices once and referencing them by `id` keeps the
#' instrument consistent and reduces the risk of label mismatches across items
#' that share the same response format.
#'
#' @param id Character. A unique identifier for this choice set. Referenced in
#'   the `choice_set` argument of [sf_item()].
#' @param values Character or numeric vector. The stored values corresponding
#'   to each response option. Must have the same length as `labels`.
#' @param labels Character vector. The display labels shown to respondents.
#'   Must have the same length as `values`.
#' @param allow_other Logical. Whether to append an open-text "Other" option
#'   at the end of the choice list. Defaults to `FALSE`.
#' @param randomise Logical. Whether to randomise the display order of options
#'   at render time. Defaults to `FALSE`.
#' @param ordered Logical. Whether the options run in a meaningful order, from
#'   least to most or the reverse, as in a frequency or an education scale.
#'   SurveyBuilder and SurveyStudio then treat a `single_choice` item on the
#'   set as ordinal, which opens the methods for ordered categories. Defaults
#'   to `FALSE`, nominal. Written to the file only when `TRUE`, so every
#'   earlier set keeps the hash it had. A `likert` item is ordered by its type.
#'
#' @return An object of class `sf_choices` (a named list).
#' @export
#' @seealso [sf_item()], [sf_instrument()]
#'
#' @examples
#' # A five-point agreement scale
#' agree5 <- sf_choices(
#'   id     = "agree5",
#'   values = 1:5,
#'   labels = c("Strongly disagree", "Disagree", "Neutral",
#'              "Agree", "Strongly agree")
#' )
#'
#' # An ordered set: a single_choice item on it is read as ordinal
#' often <- sf_choices(
#'   id      = "often",
#'   values  = 1:4,
#'   labels  = c("Rarely", "Sometimes", "Often", "Always"),
#'   ordered = TRUE
#' )
sf_choices <- function(
    id,
    values,
    labels,
    allow_other = FALSE,
    randomise   = FALSE,
    ordered     = FALSE
) {
  if (!is.logical(ordered) || length(ordered) != 1 || is.na(ordered)) {
    rlang::abort("`ordered` must be TRUE or FALSE.",
                 class = c("sframe_validation_error", "sframe_error"))
  }
  if (length(values) != length(labels)) {
    rlang::abort(
      "`values` and `labels` must have the same length.",
      class = c("sframe_validation_error", "sframe_error")
    )
  }
  problems <- sframe_choice_content_problems(values, labels)
  if (length(problems) > 0) {
    rlang::abort(
      paste0("Choice set '", as.character(id)[1], "': ",
             paste(problems, collapse = " ")),
      class = c("sframe_validation_error", "sframe_error")
    )
  }

  out <- list(
    id          = id,
    values      = values,
    labels      = labels,
    allow_other = allow_other,
    randomise   = randomise
  )
  # Present only when TRUE, so every set made before the field existed
  # serialises, and hashes, exactly as it did.
  if (ordered) out$ordered <- TRUE
  structure(out, class = "sf_choices")
}

# Whether the choice set `set_id` declares its options ordered.
sframe_choice_set_ordered <- function(instrument, set_id) {
  if (is.null(set_id) || !nzchar(as.character(set_id)[1])) return(FALSE)
  for (cs in instrument$choices %||% list()) {
    if (identical(as.character(cs$id)[1], as.character(set_id)[1])) return(isTRUE(cs$ordered))
  }
  FALSE
}
