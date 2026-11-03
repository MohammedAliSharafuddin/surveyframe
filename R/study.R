# R/study.R
#
# D13 (decided 2026-10-30). The study an instrument serves: a problem
# statement, the objectives, and the sampling plan. Bounded so it stays a
# declaration the package can check and not a proposal: objectives are short
# items with ids, each plan block names the objective it serves, and the
# sampling method comes from a fixed list. Inside the content hash, never on
# the respondent's page, and a change to it after collection is a design
# amendment.

sframe_study_fields <- c("problem", "objectives", "sampling")
sframe_sampling_fields <- c("population", "method", "planned_n")

#' Sampling methods a study can declare
#'
#' The fixed list `study$sampling$method` is checked against: 4 probability
#' designs, 4 non-probability designs, a census, and other.
#'
#' @return A character vector.
#' @export
#' @family Design functions
#' @examples
#' sframe_sampling_methods()
sframe_sampling_methods <- function() {
  c("simple_random", "systematic", "stratified", "cluster",
    "convenience", "purposive", "quota", "snowball", "census", "other")
}

#' The study an instrument serves
#'
#' Returns the instrument's `study`: the problem statement, the objectives
#' (each with an `id` such as `"O1"` and its `text`), and the sampling plan
#' (`population`, `method` from [sframe_sampling_methods()] and `planned_n`).
#' Set it with `sframe_instrument(study = )` or by assigning
#' `instrument$study`. Each plan block may name the objective it serves in its
#' `objective` field. The study is never shown to respondents, since telling
#' them the aims can bias their answers.
#'
#' [validate_sframe()] refuses a malformed study, an objective id used twice
#' and a plan block naming an objective that does not exist. It notes, without
#' failing, an objective no research question serves, a research question
#' that names no objective, and a problem statement over 150 words.
#'
#' @param x An `sframe` object.
#' @param ... Ignored.
#' @return A list with `problem`, `objectives` and `sampling`, each `NULL`
#'   when not declared.
#' @export
#' @family Design functions
#' @examples
#' ins <- sframe_instrument("Study", components = list(sframe_item("q1", "Q?", "text")),
#'   study = list(problem = "Why do students leave the course?",
#'                objectives = list(list(id = "O1", text = "Describe the reasons."))))
#' sframe_get_study(ins)$objectives
sframe_get_study <- function(x, ...) {
  sframe_check_instrument(x)
  s <- x$study %||% list()
  list(problem = s$problem, objectives = s$objectives, sampling = s$sampling)
}

# The study as read from JSON, with the shapes R code expects.
sframe_restore_study <- function(study) {
  if (!is.list(study) || length(study) == 0) return(NULL)
  if (!is.null(study$problem)) study$problem <- sframe_as_vector(study$problem, "character")
  if (!is.null(study$objectives)) {
    study$objectives <- lapply(study$objectives, function(o) {
      o$id <- sframe_as_vector(o$id, "character")
      o$text <- sframe_as_vector(o$text, "character")
      o
    })
  }
  if (!is.null(study$sampling$planned_n) && is.numeric(study$sampling$planned_n) &&
      length(study$sampling$planned_n) == 1 && study$sampling$planned_n == round(study$sampling$planned_n)) {
    study$sampling$planned_n <- as.integer(study$sampling$planned_n)
  }
  study
}

# The study as written: only what is declared, and nothing when it is empty,
# so an instrument with no study hashes as it did before the field existed.
sframe_study_plain <- function(study) {
  if (!is.list(study)) return(NULL)
  study <- Filter(function(v) length(v) > 0, study)
  if (!is.null(study$sampling)) {
    study$sampling <- Filter(function(v) length(v) > 0, study$sampling)
    if (!is.null(study$sampling$planned_n) && is.numeric(study$sampling$planned_n) &&
        isTRUE(study$sampling$planned_n == round(study$sampling$planned_n))) {
      study$sampling$planned_n <- as.integer(study$sampling$planned_n)
    }
    if (length(study$sampling) == 0) study$sampling <- NULL
  }
  if (!is.null(study$objectives)) study$objectives <- unname(study$objectives)
  if (length(study) == 0) NULL else study
}

# What the validator says of a study: problems that fail it, and notes on the
# trace from objective to research question, which do not.
sframe_study_problems <- function(instrument) {
  problems <- character(0)
  notes <- character(0)
  s <- instrument$study
  if (is.null(s) || length(s) == 0) return(list(problems = problems, notes = notes))
  if (!is.list(s) || is.null(names(s))) {
    return(list(problems = "`study` must be a named list with problem, objectives and sampling.",
                notes = notes))
  }
  extra <- setdiff(names(s), sframe_study_fields)
  if (length(extra)) {
    problems <- c(problems, sprintf("`study` has unknown field(s): %s. It holds problem, objectives and sampling.",
                                    paste(extra, collapse = ", ")))
  }
  one_string <- function(x) is.character(x) && length(x) == 1 && !is.na(x)
  if (!is.null(s$problem)) {
    if (!one_string(s$problem)) {
      problems <- c(problems, "`study$problem` must be 1 paragraph of text.")
    } else if (length(strsplit(trimws(s$problem), "\\s+")[[1]]) > 150) {
      notes <- c(notes, paste0("The problem statement runs over 150 words. Keep it to 1 short ",
                               "paragraph: the background belongs in the protocol, not the instrument."))
    }
  }
  ids <- character(0)
  if (!is.null(s$objectives)) {
    if (!is.list(s$objectives)) {
      problems <- c(problems, "`study$objectives` must be a list of objectives, each with an id and text.")
    } else {
      for (k in seq_along(s$objectives)) {
        o <- s$objectives[[k]]
        id <- if (is.list(o)) o$id else NULL
        if (!one_string(id) || !grepl("^[A-Za-z][A-Za-z0-9_]*$", id)) {
          problems <- c(problems, sprintf(paste0("Objective %d needs an id of letters, digits and ",
                                                 "underscores, starting with a letter, such as O1."), k))
          next
        }
        if (!one_string(o$text) || !nzchar(trimws(o$text))) {
          problems <- c(problems, sprintf("Objective '%s' needs its text.", id))
        }
        ids <- c(ids, id)
      }
      dup <- unique(ids[duplicated(ids)])
      if (length(dup)) {
        problems <- c(problems, sprintf("Objective id(s) used more than once: %s.", paste(dup, collapse = ", ")))
      }
    }
  }
  if (!is.null(s$sampling)) {
    sp <- s$sampling
    if (!is.list(sp)) {
      problems <- c(problems, "`study$sampling` must be a list with population, method and planned_n.")
    } else {
      extra <- setdiff(names(sp) %||% character(0), sframe_sampling_fields)
      if (length(extra)) {
        problems <- c(problems, sprintf("`study$sampling` has unknown field(s): %s.", paste(extra, collapse = ", ")))
      }
      if (!is.null(sp$population) && !one_string(sp$population)) {
        problems <- c(problems, "`study$sampling$population` must be a single string.")
      }
      if (!is.null(sp$method) && (!one_string(sp$method) || !sp$method %in% sframe_sampling_methods())) {
        problems <- c(problems, sprintf("`study$sampling$method` must be one of %s.",
                                        paste(sframe_sampling_methods(), collapse = ", ")))
      }
      n <- sp$planned_n
      if (!is.null(n) && (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 1 || n != round(n))) {
        problems <- c(problems, "`study$sampling$planned_n` must be a whole number of 1 or more.")
      }
    }
  }
  # The trace from objective to research question.
  plan <- instrument$analysis_plan %||% list()
  named <- vapply(plan, function(b) as.character(b$objective %||% "")[1], character(1))
  block_ids <- vapply(plan, function(b) as.character(b$id %||% "")[1], character(1))
  unknown <- setdiff(unique(named[nzchar(named)]), ids)
  for (u in unknown) {
    problems <- c(problems, sprintf("Plan block(s) %s name objective '%s', which the study does not declare.",
                                    paste(block_ids[named == u], collapse = ", "), u))
  }
  if (length(ids)) {
    for (id in setdiff(ids, named)) {
      notes <- c(notes, sprintf("Objective '%s' is served by no research question.", id))
    }
    for (b in block_ids[!nzchar(named)]) {
      notes <- c(notes, sprintf("Research question '%s' names no objective.", b))
    }
  }
  list(problems = problems, notes = notes)
}

#' Notes from a validation
#'
#' The notes [validate_sframe()] makes without failing the instrument: an
#' objective no research question serves, a research question that names no
#' objective, and a problem statement over 150 words.
#'
#' @param x An [sframe_validation] object.
#' @return A character vector, empty when there is nothing to note.
#' @export
#' @family Inspect functions
#' @examples
#' sframe_notes(validate_sframe(sframe_demo("likert_scale")$instrument, strict = FALSE))
sframe_notes <- function(x) {
  if (!inherits(x, "sframe_validation")) {
    rlang::abort("`x` must be the result of validate_sframe().",
                 class = c("sframe_validation_error", "sframe_error"))
  }
  as.character(x$notes %||% character(0))
}
