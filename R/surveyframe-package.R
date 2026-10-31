# The \if{latex} line in @description is for the PDF manual. Inline code is
# set in a typewriter font that cannot be hyphenated, so a long function name
# near the end of a line ran past the right margin, 83 times in 0.4.2's
# manual. This page is typeset first, which is why it is no longer marked
# internal, and \global carries the looser line breaking to every page after
# it. HTML help and pkgdown ignore the line.
#' surveyframe: Survey Instrument Workflows for R
#'
#' @description
#' \if{latex}{\out{\global\emergencystretch=3em\global\tolerance=3000\global\hbadness=10000}}
#' surveyframe defines a survey instrument as a first-class R object and
#' supports a complete workflow from questionnaire design through data
#' collection, quality checking, scoring, psychometric diagnostics, and
#' reproducible reporting. The package covers static HTML survey export,
#' an embeddable Shiny survey module, an interactive response dashboard,
#' a role-based analysis planner with pre-declared research questions, common
#' survey statistics with small-sample alternatives (Hodges-Lehmann,
#' pseudomedian, exact odds-ratio, and Firth logistic regression), multi-
#' criteria decision analysis (AHP, ANP, DEMATEL, VIKOR, MOORA, SMART,
#' WASPAS, PROMETHEE, ELECTRE, and TOPSIS), and model syntax planning for
#' EFA, CFA, CB-SEM, and PLS-SEM.
#'
#' ## Core workflow
#'
#' 1. **Design** an instrument with [launch_builder()] or [sframe_instrument()] and
#'    its component constructors: [sframe_item()], [sframe_choice_set()], [sframe_scale()],
#'    [sframe_branch()], [sframe_attention_check()].
#' 2. **Validate and save** with [validate_sframe()] and [write_sframe()].
#'    `validate_sframe()` returns an `sframe_validation` diagnostic rather
#'    than the instrument itself. Recover a validated instrument with
#'    [as_sframe()].
#' 3. **Deploy** a Shiny survey with [run_survey()].
#' 4. **Load responses** with [read_responses()] or [read_sheet_responses()].
#' 5. **Check quality** with [sframe_quality_results()].
#' 6. **Score and analyse** with [score_scales()], [sframe_descriptives_results()],
#'    [sframe_missing_data_results()], [sframe_reliability_results()], [sframe_item_results()],
#'    [sframe_efa_readiness_results()], [sframe_syntax_cfa()], and [run_analysis_plan()], which also
#'    runs any decision-analysis blocks in the plan.
#' 7. **Report** with [sframe_codebook()], [render_report()], and
#'    [render_results()].
#'
#' ## The instrument object
#'
#' The workflow runs on an `sframe` object. It is the single source of truth
#' for item definitions, scale structure, reverse-coding keys, branching
#' rules, check specifications, analysis plans, and optional model
#' specifications. Accessors such as [sframe_meta()], [sframe_get_items()], [sframe_get_scales()],
#' [sframe_plan()], and [sframe_get_models()] read its parts without reaching into the
#' object directly.
#'
#' Some helpers work on plain vectors, for use beside that workflow or on
#' their own: the text helpers such as [sframe_term_frequency()], and the interval
#' helpers [sframe_bootstrap_ci()], [sframe_cohens_d_ci()], [sframe_cramers_v_ci()] and
#' [sframe_eta_sq_ci()].
#'
#' ## A first session
#'
#' [sframe_list_demos()] lists 22 worked demos, each one instrument, its responses
#' and the results surveyframe produced. `sframe_demo("two_group")` loads one,
#' and `sframe_demo_qmd("two_group")` writes a notebook to edit.
#' `vignette("learn-by-example")` teaches from the same library.
#'
#' ## How functions are named
#'
#' Names come in 2 kinds, so a function says which stage it belongs to.
#'
#' * The stage verbs name the step a researcher is taking and carry no
#'   prefix: [read_sframe()], [validate_sframe()], [write_sframe()],
#'   [amend_sframe()], [run_survey()], [export_survey()], [read_responses()],
#'   [score_scales()], [run_analysis_plan()], [render_report()],
#'   [launch_builder()] and [launch_studio()].
#' * Everything else takes `sframe_`: the makers such as [sframe_item()] and
#'   [sframe_scale()], the listers such as [sframe_get_items()], the accessors
#'   such as [sframe_plan()], the `_results` functions such as
#'   [sframe_reliability_results()], which return results and write no file,
#'   the `sframe_syntax_` generators, the plots and the demo library.
#'
#' No 2 names sit 1 letter apart: a lister is `sframe_get_items()`, never
#' `sframe_items()`. The names used before 0.4.3 still work, silently. See
#' [superseded].
#'
#' ## File format
#'
#' Instruments are stored as UTF-8 JSON files with the `.sframe` extension.
#' Each file includes a SHA-256 integrity hash for reproducibility auditing.
#'
"_PACKAGE"

## usethis namespace: start
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom rlang abort warn arg_match check_installed %||%
#' @importFrom openssl sha256
#' @importFrom stats cor sd var complete.cases density
#' @importFrom utils capture.output
## usethis namespace: end
NULL
