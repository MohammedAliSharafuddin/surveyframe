# accessors.R
# Dedicated accessor and exploration methods for the surveyframe classes.
#
# Before 0.4.0 the only way to reach the contents of an instrument or a report
# was `$` on the underlying list. That makes the internal layout part of the
# public contract and gives a user no discoverable way in. These generics and
# the as.data.frame() methods in as_data_frame.R are the supported route.

# ---------------------------------------------------------------------------
# Component lists
# ---------------------------------------------------------------------------

# Components are returned as a classed list so they print as a readable
# summary rather than dumping their internals. Names are the component ids,
# so `sframe_get_items(instr)[["sat_1"]]` is the lookup path.
sframe_component_list <- function(x, what = "component") {
  # Named through sframe_id(), so a component that identifies itself by another
  # field is named by it. A branch carries no `id`, and reading `id` directly
  # gave every branch list an empty name and broke [[ lookup.
  ids <- vapply(x, function(el) {
    out <- try(sframe_id(el), silent = TRUE)
    if (inherits(out, "try-error")) as.character(el$id %||% "")[1] else out
  }, character(1))
  names(x) <- ids
  structure(x, class = "sf_component_list", what = what)
}

#' A list of instrument components
#'
#' The value returned by [sframe_get_items()], [sframe_get_scales()], [sframe_get_choice_sets()],
#' [sframe_get_branches()], [sframe_get_attention_checks()] and [sframe_get_models()]. It is a list of component
#' objects named by their IDs, so a single component is reached with `[[`.
#'
#'
#' @return `print()` returns `x` invisibly. `[` returns an `sf_component_list`.
#' @name sf_component_list
#'
#' @examples
#' item1 <- sframe_item("q1", "First question", type = "text")
#' item2 <- sframe_item("q2", "Second question", type = "text")
#' instr <- sframe_instrument("Demo", components = list(item1, item2))
#'
#' sframe_get_items(instr)
#' sframe_get_items(instr)[["q2"]]
NULL

#' @noRd
#' @exportS3Method print sf_component_list
print.sf_component_list <- function(x, ...) {
  what <- attr(x, "what") %||% "component"
  cat(sprintf("<%s list: %d>\n", what, length(x)))
  for (el in x) {
    # format() is already defined for every component class, so the one-line
    # summary is theirs rather than a second description that could drift.
    line <- tryCatch(format(el), error = function(e) paste0("<", class(el)[1], ">"))
    cat(" ", line, "\n", sep = "")
  }
  invisible(x)
}

#' @noRd
#' @exportS3Method `[` sf_component_list
`[.sf_component_list` <- function(x, i, ...) {
  what <- attr(x, "what")
  out <- NextMethod()
  structure(out, class = "sf_component_list", what = what)
}

# ---------------------------------------------------------------------------
# Generics
# ---------------------------------------------------------------------------

#' Explore a surveyframe object
#'
#' Accessors for the parts of an instrument, a codebook, or a report. They
#' replace reaching into the object with `$`, which ties user code to the
#' internal layout.
#'
#' What each one gives back depends on what it is asked. Given an instrument,
#' the component accessors return the component objects as an
#' [sf_component_list], which prints as a list and is subset with `[` and
#' `[[`. Given a codebook, the same verbs return the table the codebook
#' already holds, a plain data frame with one row per item, scale, choice set,
#' model or plan block.
#'
#' | Accessor | On an `sframe` | On an `sframe_codebook` |
#' | --- | --- | --- |
#' | `sframe_meta()` | list of metadata | list of metadata |
#' | `sframe_get_items()` | `sf_component_list` of items | data frame of items |
#' | `sframe_get_scales()` | `sf_component_list` of scales | data frame of scales |
#' | `sframe_get_choice_sets()` | `sf_component_list` of choice sets | data frame of choice sets |
#' | `sframe_get_branches()` | `sf_component_list` of branching rules | not available |
#' | `sframe_get_attention_checks()` | `sf_component_list` of checks | not available |
#' | `sframe_get_models()` | `sf_component_list` of models | data frame of models |
#' | `sframe_plan()` | list of plan blocks | data frame of plan blocks |
#'
#' `as.data.frame()` on an instrument gives its items as a table, which is one
#' part of it, and a component list has no coercion of its own. For every
#' table an instrument can produce, use [sframe_codebook()].
#'
#'
#' @return A list for `sframe_meta()` and `sframe_plan()` on an instrument, an
#'   [sf_component_list] for the component accessors on an instrument, and a
#'   data frame for any of them on a codebook. See the table above.
#' @name sframe_accessors
#' @aliases sf_accessors
#' @seealso [as_sframe()], [sframe_problems()], [sframe_validation]
#'
#' @examples
#' cs    <- sframe_choice_set("ag5", 1:5,
#'            c("Strongly disagree", "Disagree", "Neutral",
#'              "Agree", "Strongly agree"))
#' item  <- sframe_item("sat_1", "The service met my expectations.",
#'                  type = "likert", choice_set = "ag5", scale_id = "sat")
#' scale <- sframe_scale("sat", "Satisfaction", items = "sat_1")
#' instr <- sframe_instrument("Demo Survey", components = list(cs, item, scale))
#'
#' sframe_meta(instr)$title
#' sframe_get_items(instr)
#' sframe_get_scales(instr)[["sat"]]
#' as.data.frame(instr)
NULL

#' Get survey metadata
#'
#' Reads the title, version, description, language, validation state, and other
#' metadata without depending on the object's internal list layout.
#'
#' @param x A surveyframe object.
#' @param ... Passed to methods.
#' @return A list of instrument or codebook metadata.
#' @seealso [sframe_accessors]
#' @examples
#' sframe_meta(sframe_demo_data()$instrument)
#' @export
sframe_meta <- function(x, ...) UseMethod("sframe_meta")

#' Get survey items
#'
#' Returns the declared question items in instrument order.
#'
#' @inheritParams sframe_meta
#' @return An [sf_component_list] for an instrument or an item data frame for a
#'   codebook.
#' @seealso [sframe_accessors]
#' @examples
#' sframe_get_items(sframe_demo_data()$instrument)
#' @export
sframe_get_items <- function(x, ...) UseMethod("sframe_get_items")

#' Get survey scales
#'
#' Returns the scale definitions, including their item membership and scoring
#' settings.
#'
#' @inheritParams sframe_meta
#' @return An [sf_component_list] for an instrument or a scale data frame for a
#'   codebook.
#' @seealso [sframe_accessors]
#' @examples
#' sframe_get_scales(sframe_demo_data()$instrument)
#' @export
sframe_get_scales <- function(x, ...) UseMethod("sframe_get_scales")

#' Get choice sets
#'
#' Returns the reusable value-and-label sets referenced by closed-response
#' items.
#'
#' @inheritParams sframe_meta
#' @return An [sf_component_list] for an instrument or a choice-set data frame
#'   for a codebook.
#' @seealso [sframe_accessors]
#' @examples
#' sframe_get_choice_sets(sframe_demo_data()$instrument)
#' @export
sframe_get_choice_sets <- function(x, ...) UseMethod("sframe_get_choice_sets")

#' Get branching rules
#'
#' Returns the rules that control whether conditional items are shown.
#'
#' @inheritParams sframe_meta
#' @return An [sf_component_list] of branching rules.
#' @seealso [sframe_accessors]
#' @examples
#' sframe_get_branches(sframe_demo_data()$instrument)
#' @export
sframe_get_branches <- function(x, ...) UseMethod("sframe_get_branches")

#' Get response-quality checks
#'
#' Returns declared attention and other response-quality checks.
#'
#' @inheritParams sframe_meta
#' @return An [sf_component_list] of declared checks.
#' @seealso [sframe_accessors]
#' @examples
#' sframe_get_attention_checks(sframe_demo_data()$instrument)
#' @export
sframe_get_attention_checks <- function(x, ...) UseMethod("sframe_get_attention_checks")

#' Get model specifications
#'
#' Returns declared CFA, SEM, PLS-SEM, mediation, and related model objects.
#'
#' @inheritParams sframe_meta
#' @return An [sf_component_list] for an instrument or a model data frame for a
#'   codebook.
#' @seealso [sframe_accessors]
#' @examples
#' sframe_get_models(sframe_demo_data()$instrument)
#' @export
sframe_get_models <- function(x, ...) UseMethod("sframe_get_models")

#' Get the pre-declared analysis plan
#'
#' Returns the ordered analysis blocks attached to an instrument or codebook.
#'
#' @inheritParams sframe_meta
#' @return A list of analysis blocks for an instrument or a plan data frame for
#'   a codebook.
#' @seealso [sframe_accessors], [sframe_plan<-]
#' @examples
#' sframe_plan(sframe_demo_data()$instrument)
#' @export
sframe_plan <- function(x, ...) UseMethod("sframe_plan")

# ---------------------------------------------------------------------------
# sframe methods
# ---------------------------------------------------------------------------

#' @noRd
#' @exportS3Method sframe_meta sframe
sframe_meta.sframe <- function(x, ...) x$meta

#' @noRd
#' @exportS3Method sframe_get_items sframe
sframe_get_items.sframe <- function(x, ...) sframe_component_list(x$items, "item")

#' @noRd
#' @exportS3Method sframe_get_scales sframe
sframe_get_scales.sframe <- function(x, ...) sframe_component_list(x$scales, "scale")

#' @noRd
#' @exportS3Method sframe_get_choice_sets sframe
sframe_get_choice_sets.sframe <- function(x, ...) {
  sframe_component_list(x$choices, "choice set")
}

#' @noRd
#' @exportS3Method sframe_get_branches sframe
sframe_get_branches.sframe <- function(x, ...) {
  sframe_component_list(x$branching %||% list(), "branch rule")
}

#' @noRd
#' @exportS3Method sframe_get_attention_checks sframe
sframe_get_attention_checks.sframe <- function(x, ...) {
  sframe_component_list(x$checks %||% list(), "attention check")
}

#' @noRd
#' @exportS3Method sframe_get_models sframe
sframe_get_models.sframe <- function(x, ...) {
  sframe_component_list(x$models %||% list(), "model")
}

#' @noRd
#' @exportS3Method sframe_plan sframe
sframe_plan.sframe <- function(x, ...) x$analysis_plan %||% list()

#' Set the pre-declared analysis plan
#'
#' The replacement counterpart to [sframe_plan()]. Declaring the plan is the step
#' the whole workflow turns on, so it has a named function rather than
#' assignment into the object's internals.
#'
#' @param x An `sframe` object.
#' @param value A list of analysis blocks.
#'
#' @return The updated `sframe` object.
#' @export
#' @seealso [sframe_plan()], [validate_sframe()], [run_analysis_plan()]
#'
#' @examples
#' item  <- sframe_item("q1", "How satisfied are you?", type = "numeric")
#' instr <- sframe_instrument("Demo", components = list(item))
#'
#' sframe_plan(instr) <- list(
#'   list(id = "RQ1", research_question = "What is the average?",
#'        family = "descriptive", method = "descriptives",
#'        roles = list(variables = "q1"))
#' )
#' length(sframe_plan(instr))
`sframe_plan<-` <- function(x, value) UseMethod("sframe_plan<-")

#' @noRd
#' @exportS3Method `sframe_plan<-` sframe
`sframe_plan<-.sframe` <- function(x, value) {
  if (!is.list(value)) {
    rlang::abort("An analysis plan must be a list of blocks.",
                 class = "sframe_error")
  }
  x$analysis_plan <- value
  # The stamp records that this content passed validation. Replacing the plan
  # changes the content, so it goes, and validate_sframe() sets it again.
  x$meta$validated <- FALSE
  x
}

# ---------------------------------------------------------------------------
# Codebook methods. A codebook is the tabular view of an instrument, so the
# same verbs answer for it and return the tables it already holds.
# ---------------------------------------------------------------------------

#' @noRd
#' @exportS3Method sframe_meta sframe_codebook
sframe_meta.sframe_codebook <- function(x, ...) x$instrument_meta

#' @noRd
#' @exportS3Method sframe_get_items sframe_codebook
sframe_get_items.sframe_codebook <- function(x, ...) x$items_table

#' @noRd
#' @exportS3Method sframe_get_scales sframe_codebook
sframe_get_scales.sframe_codebook <- function(x, ...) x$scales_table

#' @noRd
#' @exportS3Method sframe_get_choice_sets sframe_codebook
sframe_get_choice_sets.sframe_codebook <- function(x, ...) x$choices_table

#' @noRd
#' @exportS3Method sframe_get_models sframe_codebook
sframe_get_models.sframe_codebook <- function(x, ...) x$models_table

#' @noRd
#' @exportS3Method sframe_plan sframe_codebook
sframe_plan.sframe_codebook <- function(x, ...) x$plan_table

# ---------------------------------------------------------------------------
# Component identity
# ---------------------------------------------------------------------------

#' The ID and label of an instrument component
#'
#'
#' @return A single character string. `sframe_label()` returns `""` when the
#'   component carries no label.
#' @name sframe_identity
#' @aliases sf_identity
#'
#' @examples
#' item <- sframe_item("q1", "How satisfied are you?", type = "likert",
#'                 choice_set = "agree5")
#' sframe_id(item)
#' sframe_label(item)
NULL

#' Get an instrument component ID
#'
#' Reads the stable identifier used to refer to a component elsewhere in the
#' instrument.
#'
#' @param x An [sframe_item()], [sframe_choice_set()], [sframe_scale()], [sframe_branch()],
#'   [sframe_attention_check()] or [sframe_model_spec()] object.
#' @param ... Passed to methods.
#' @return A single character identifier.
#' @seealso [sframe_identity], [sframe_label()]
#' @examples
#' sframe_id(sframe_item("q1", "Satisfaction", type = "numeric"))
#' @export
sframe_id <- function(x, ...) UseMethod("sframe_id")

#' Get an instrument component label
#'
#' Reads the respondent- or analyst-facing label attached to a component.
#'
#' @inheritParams sframe_id
#' @return A single character label, or `""` when none is declared.
#' @seealso [sframe_identity], [sframe_id()]
#' @examples
#' sframe_label(sframe_item("q1", "Satisfaction", type = "numeric"))
#' @export
sframe_label <- function(x, ...) UseMethod("sframe_label")

sframe_component_id <- function(x, ...) as.character(x$id %||% "")[1]
sframe_component_label <- function(x, ...) as.character(x$label %||% "")[1]

#' @noRd
#' @exportS3Method sframe_id sf_item
sframe_id.sf_item <- sframe_component_id
#' @noRd
#' @exportS3Method sframe_id sf_choices
sframe_id.sf_choices <- sframe_component_id
#' @noRd
#' @exportS3Method sframe_id sf_scale
sframe_id.sf_scale <- sframe_component_id
#' @noRd
#' @exportS3Method sframe_id sf_branch
# A branch is identified by the item whose visibility it controls. One rule
# per target item, which validation enforces.
sframe_id.sf_branch <- function(x, ...) as.character(x$item_id %||% "")[1]
#' @noRd
#' @exportS3Method sframe_id sf_check
sframe_id.sf_check <- sframe_component_id
#' @noRd
#' @exportS3Method sframe_id sf_model
sframe_id.sf_model <- sframe_component_id

#' @noRd
#' @exportS3Method sframe_label sf_item
sframe_label.sf_item <- sframe_component_label
#' @noRd
#' @exportS3Method sframe_label sf_choices
sframe_label.sf_choices <- sframe_component_label
#' @noRd
#' @exportS3Method sframe_label sf_scale
sframe_label.sf_scale <- sframe_component_label
#' @noRd
#' @exportS3Method sframe_label sf_branch
sframe_label.sf_branch <- sframe_component_label
#' @noRd
#' @exportS3Method sframe_label sf_check
sframe_label.sf_check <- sframe_component_label
#' @noRd
#' @exportS3Method sframe_label sf_model
sframe_label.sf_model <- sframe_component_label

# ---------------------------------------------------------------------------
# Validation accessors
# ---------------------------------------------------------------------------

#' Read a validation diagnostic
#'
#' `sframe_is_valid()` reports whether the object passed. `sframe_problems()` returns
#' the problem messages. `sframe_object()` returns the object that was validated.
#'
#'
#' @return `sframe_is_valid()` returns a single logical. `sframe_problems()` returns a
#'   character vector, empty when the object is valid. `sframe_object()` returns
#'   the validated object.
#' @name sframe_validation_accessors
#' @aliases sf_validation_accessors
#' @seealso [validate_sframe()], [sframe_validation], [as_sframe()]
#'
#' @examples
#' item  <- sframe_item("q1", "How satisfied are you?", type = "text")
#' instr <- sframe_instrument("Demo", components = list(item))
#' v <- validate_sframe(instr, strict = FALSE)
#'
#' sframe_is_valid(v)
#' sframe_problems(v)
NULL

#' Test whether validation passed
#'
#' Reads the overall pass/fail result without inspecting validation internals.
#'
#' @param x An [sframe_validation] object.
#' @param ... Passed to methods.
#' @return A single logical value.
#' @seealso [sframe_validation_accessors], [validate_sframe()]
#' @examples
#' v <- validate_sframe(sframe_demo_data()$instrument, strict = FALSE)
#' sframe_is_valid(v)
#' @export
sframe_is_valid <- function(x, ...) UseMethod("sframe_is_valid")

#' Get validation problems
#'
#' Returns every actionable validation message in check order.
#'
#' @inheritParams sframe_is_valid
#' @return A character vector, empty when validation passed.
#' @seealso [sframe_validation_accessors], [validate_sframe()]
#' @examples
#' v <- validate_sframe(sframe_demo_data()$instrument, strict = FALSE)
#' sframe_problems(v)
#' @export
sframe_problems <- function(x, ...) UseMethod("sframe_problems")

#' Recover the validated object
#'
#' Returns the original object carried by a validation result, whether or not
#' validation passed.
#'
#' @inheritParams sframe_is_valid
#' @return The object held by a validation result.
#' @seealso [sframe_validation_accessors], [as_sframe()]
#' @examples
#' v <- validate_sframe(sframe_demo_data()$instrument, strict = FALSE)
#' sframe_object(v)
#' @export
sframe_object <- function(x, ...) UseMethod("sframe_object")

#' @noRd
#' @exportS3Method sframe_is_valid sframe_validation
sframe_is_valid.sframe_validation <- function(x, ...) isTRUE(x$valid)

#' @noRd
#' @exportS3Method sframe_problems sframe_validation
sframe_problems.sframe_validation <- function(x, ...) as.character(x$problems)

#' @noRd
#' @exportS3Method sframe_object sframe_validation
sframe_object.sframe_validation <- function(x, ...) x$object

# ---------------------------------------------------------------------------
# Coercion
# ---------------------------------------------------------------------------

#' Coerce to an instrument
#'
#' Recovers the `sframe` instrument from a validation diagnostic. This is the
#' migration path for code that used the `strict = TRUE` return of
#' [validate_sframe()] as an instrument, which it no longer is.
#'
#' @param x An [sframe_validation] object or an `sframe`.
#' @param ... Passed to methods.
#'
#' @return An `sframe` object. When the validation passed, its
#'   `meta$validated` is `TRUE`.
#' @export
#' @seealso [validate_sframe()], [sframe_validation]
#'
#' @examples
#' item  <- sframe_item("q1", "How satisfied are you?", type = "text")
#' instr <- sframe_instrument("Demo", components = list(item))
#'
#' validated <- as_sframe(validate_sframe(instr, strict = TRUE))
#' isTRUE(sframe_meta(validated)$validated)
as_sframe <- function(x, ...) UseMethod("as_sframe")

#' @noRd
#' @exportS3Method as_sframe sframe
as_sframe.sframe <- function(x, ...) x

#' @noRd
#' @exportS3Method as_sframe sframe_validation
as_sframe.sframe_validation <- function(x, ...) {
  if (!identical(x$subject, "instrument")) {
    rlang::abort(
      paste0(
        "This validation result describes a ", x$subject,
        ", so it holds no instrument. Use `sframe_object()` to get the ",
        x$subject, " back."
      ),
      class = "sframe_error"
    )
  }
  x$object
}

# ---------------------------------------------------------------------------
# Report accessors
# ---------------------------------------------------------------------------

#' Read the reportable parts of an analysis or quality result
#'
#' `sframe_apa()` returns the APA-formatted sentence a result carries.
#' `sframe_flagged()` returns the rows a quality report flagged.
#'
#' Given analysis results, `sframe_apa()` answers for every block at once, as a
#' character vector named by block. Given one of the standalone reports that
#' carry a sentence of their own, an assumption report, a descriptives report,
#' a missing-data report or a validity report, it returns that single
#' sentence. A result with no sentence gives an empty string, so the shape of
#' the answer follows the number of blocks asked about.
#'
#' The sentence is plain text. APA 7 asks for italic Latin statistical symbols,
#' so a manuscript needs `t`, `F`, `p`, `r`, `d` and the rest italicised after
#' pasting: a character vector cannot carry that styling. Numbers are already
#' APA-formatted, including no leading zero on `p` and a labelled confidence
#' interval.
#'
#' `sframe_flagged()` returns row positions in the response data, as one sorted
#' vector with each row once, pooling every check the quality report ran:
#' failed attention checks, straight-lining, excess missingness, timing and
#' duplicates. Read the report itself for which check flagged a row.
#'
#'
#' @return `sframe_apa()` returns a character vector: one element per block, named
#'   by block, for analysis results, and one element for a single report.
#'   `sframe_flagged()` returns an integer vector of row positions, sorted, each
#'   row once.
#' @name sframe_report_accessors
#' @aliases sf_report_accessors
#'
#' @examples
#' demo <- sframe_demo_data()
#' qr <- sframe_quality_results(demo$responses, demo$instrument)
#' head(sframe_flagged(qr))
NULL

#' Extract APA-formatted result summaries
#'
#' Returns the report-ready sentence attached to each analysis result.
#'
#' @param x An `sframe_analysis_results`, `sframe_descriptives_report`,
#'   `sframe_missing_data_report`, `sframe_validity_report`, or
#'   `sframe_assumption_report` object.
#' @param ... Passed to methods.
#' @return A character vector containing one APA-formatted summary per result.
#' @seealso [sframe_report_accessors], [run_analysis_plan()]
#' @examples
#' results <- structure(
#'   list(RQ1 = list(apa = "Mean satisfaction was 4.20.")),
#'   class = c("sframe_analysis_results", "list")
#' )
#' sframe_apa(results)
#' @export
sframe_apa <- function(x, ...) UseMethod("sframe_apa")

#' Get rows flagged by response-quality checks
#'
#' Pools failed attention checks, straight-lining, excess missingness, timing,
#' and duplicate checks into one set of response-row positions.
#'
#' @param x An `sframe_quality_report` object.
#' @param ... Passed to methods.
#' @return A sorted integer vector of unique response-row positions.
#' @seealso [sframe_report_accessors], [sframe_quality_results()]
#' @examples
#' demo <- sframe_demo_data()
#' qr <- sframe_quality_results(demo$responses, demo$instrument)
#' sframe_flagged(qr)
#' @export
sframe_flagged <- function(x, ...) UseMethod("sframe_flagged")

#' @noRd
#' @exportS3Method sframe_apa sframe_analysis_results
sframe_apa.sframe_analysis_results <- function(x, ...) {
  out <- vapply(x, function(r) as.character(r$apa %||% "")[1], character(1))
  stats::setNames(out, names(x))
}

# The statistics reports each carry a single APA sentence, so one method
# body serves them all.
sframe_report_apa <- function(x, ...) as.character(x$apa %||% "")[1]

#' @noRd
#' @exportS3Method sframe_apa sframe_descriptives_report
sframe_apa.sframe_descriptives_report <- sframe_report_apa

#' @noRd
#' @exportS3Method sframe_apa sframe_missing_data_report
sframe_apa.sframe_missing_data_report <- sframe_report_apa

#' @noRd
#' @exportS3Method sframe_apa sframe_validity_report
sframe_apa.sframe_validity_report <- sframe_report_apa

#' @noRd
#' @exportS3Method sframe_apa sframe_assumption_report
sframe_apa.sframe_assumption_report <- sframe_report_apa

#' Columns the instrument declares that the responses left out
#'
#' A partial export gives a quality report every column it holds, and none of
#' the ones it dropped. This names the declared columns that never arrived, so
#' a missingness figure can be read against what was expected. They count as
#' missing for every respondent in [sframe_quality_results()]'s rates.
#'
#' @param x An `sframe_quality_report` object.
#' @param ... Passed to methods.
#'
#' @return A character vector of column names, empty where the export carried
#'   every declared column.
#' @export
#' @seealso [sframe_quality_results()], [sframe_flagged()]
#'
#' @examples
#' demo <- sframe_demo_data()
#' qr   <- sframe_quality_results(demo$responses, demo$instrument)
#' sframe_missing_columns(qr)
sframe_missing_columns <- function(x, ...) UseMethod("sframe_missing_columns")

#' @noRd
#' @exportS3Method sframe_missing_columns sframe_quality_report
sframe_missing_columns.sframe_quality_report <- function(x, ...) {
  as.character(x$missing$missing_columns %||% character(0))
}

#' @noRd
#' @exportS3Method sframe_flagged sframe_quality_report
sframe_flagged.sframe_quality_report <- function(x, ...) {
  rows <- unique(c(
    unlist(lapply(x$attention, function(a) a$failed_rows), use.names = FALSE),
    x$timing$flagged_rows,
    x$missing$flagged_rows,
    unlist(lapply(x$straightline, function(s) s$flagged_rows), use.names = FALSE),
    x$duplicates$flagged_rows
  ))
  sort(as.integer(rows))
}
