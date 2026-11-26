# The \if{latex} line in @details is for the PDF manual. Inline code is
# set in a typewriter font that cannot be hyphenated, so a long function name
# near the end of a line ran past the right margin, 83 times in 0.4.2's
# manual. This page is typeset first, which is why it is no longer marked
# internal, and \global carries the looser line breaking to every page after
# it. HTML help and pkgdown ignore the line.
#' surveyframe: Design, Plan, Seal and Report Questionnaire Studies
#'
#' @details
#' \if{latex}{\out{\global\emergencystretch=3em\global\tolerance=3000\global\hbadness=10000}}
#'
#' ## Start here
#'
#' [launch_studio()] opens SurveyStudio, where you point and click an
#' instrument through every stage below. `launch_studio(demo = "first_survey")`
#' opens it on a whole survey to try. In code, `sframe_demo("first_survey")`
#' loads the same survey, and [sframe_list_demos()] lists 25 teaching demos,
#' each one instrument, its responses and the results surveyframe produced.
#' `vignette("learn-by-example")` teaches from the same library.
#'
#' The stages follow, in order. Each names where it lives in SurveyStudio or
#' SurveyBuilder and the function that does it in code.
#'
#' ## Design
#'
#' In SurveyBuilder, [launch_builder()], the Build mode. In code,
#' [sframe_instrument()] and its makers: [sframe_item()],
#' [sframe_choice_set()], [sframe_scale()], [sframe_branch()] and
#' [sframe_attention_check()]. [validate_sframe()] checks the instrument and
#' [write_sframe()] saves it as a `.sframe` file. `validate_sframe()`
#' returns an `sframe_validation` diagnostic, and [as_sframe()] recovers the
#' validated instrument.
#'
#' ## Plan
#'
#' In SurveyBuilder, the Plan mode. In code, `sframe_plan(x) <- plan`,
#' read back with [sframe_plan()]. [sframe_sample_size_plan()] says how many
#' responses the plan needs.
#'
#' ## Preview
#'
#' In SurveyStudio, the Preview screen. In code, [preview_survey()], which
#' collects nothing, or [run_survey()] for a local Shiny survey.
#'
#' ## Collect
#'
#' In SurveyBuilder, Export survey. In code, [export_survey()] writes a
#' standalone page, optionally saving answers to a Google Sheet through
#' [export_google_sheet()]. [sframe_survey_ui()] and
#' [sframe_survey_server()] put the survey inside your own Shiny app.
#'
#' ## Responses
#'
#' In SurveyStudio, the Responses and Quality screens. In code,
#' [read_responses()] or [read_sheet_responses()], then
#' [sframe_quality_results()]. [export_responses()] writes them with labels
#' for SPSS or Stata.
#'
#' ## Analyse
#'
#' In SurveyStudio, the Explore, Reliability and Analyse screens. In
#' code, [score_scales()] and [run_analysis_plan()], which runs every block of
#' the plan, decision-analysis blocks included. The `_results` functions,
#' such as [sframe_reliability_results()], run one analysis on its own.
#'
#' ## Report
#'
#' In SurveyStudio, the Report screen. In code, [render_report()],
#' [render_results()] and [sframe_codebook()].
#'
#' ## References
#'
#' In SurveyStudio, the References screen. In code, [sframe_reference()] and
#' [sframe_add_references()]. The report lists each work once, at the end.
#'
#' ## Amendments
#'
#' In SurveyStudio, the Amendments screen. In code, [amend_sframe()], read
#' back with [sframe_get_amendments()].
#'
#' ## The instrument object
#'
#' The workflow runs on an `sframe` object. It is the single source of truth
#' for item definitions, scale structure, reverse-coding keys, branching
#' rules, check specifications, analysis plans and optional model
#' specifications. Accessors such as [sframe_meta()], [sframe_get_items()], [sframe_get_scales()],
#' [sframe_plan()], and [sframe_get_models()] read its parts without reaching into the
#' object directly.
#'
#' Some helpers work on plain vectors, for use beside that workflow or on
#' their own: the text helpers such as [sframe_term_frequency()], and the interval
#' helpers [sframe_bootstrap_ci()], [sframe_cohens_d_ci()], [sframe_cramers_v_ci()] and
#' [sframe_eta_sq_ci()].
#'
#' ## How functions are named
#'
#' Names come in 2 kinds, so a function says which stage it belongs to.
#'
#' * The stage verbs name the step a researcher is taking and carry no
#'   prefix: [read_sframe()], [validate_sframe()], [write_sframe()],
#'   [amend_sframe()], [preview_survey()], [run_survey()], [export_survey()],
#'   [read_responses()], [export_responses()],
#'   [score_scales()], [run_analysis_plan()], [render_report()],
#'   [launch_builder()] and [launch_studio()].
#' * Everything else takes `sframe_`: the makers such as [sframe_item()] and
#'   [sframe_scale()], the listers such as [sframe_get_items()], the accessors
#'   such as [sframe_plan()], the `_results` functions such as
#'   [sframe_reliability_results()], which return results and write no file,
#'   the `sframe_syntax_` generators, the plots and the demo library.
#'
#' Lister names use the `sframe_get_` prefix, such as `sframe_get_items()`.
#' The names used before 0.4.3 still work, silently. The help page
#' `?superseded` lists each old name with its replacement.
#'
#' ## File format
#'
#' Instruments are stored as UTF-8 JSON files with the `.sframe` extension.
#' Each file includes a SHA-256 integrity hash for reproducibility auditing.
#'
#' @family Entry points
"_PACKAGE"

## usethis namespace: start
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom rlang abort warn arg_match check_installed %||%
#' @importFrom openssl sha256
#' @importFrom stats cor sd var complete.cases density
#' @importFrom utils capture.output
## usethis namespace: end
NULL
