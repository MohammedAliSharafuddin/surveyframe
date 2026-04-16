#' surveyframe: A Survey Instrument Workflow for R
#'
#' @description
#' surveyframe defines a survey instrument as a first-class R object and
#' provides a complete workflow from instrument design through data collection,
#' quality checking, scoring, psychometric diagnostics, and reproducible
#' reporting. The SurveyStudio interface, launched with [launch_studio()],
#' provides a visual shell for the full pipeline.
#'
#' ## Core workflow
#'
#' 1. **Define** an instrument with [sf_instrument()] and its component
#'    constructors: [sf_item()], [sf_choices()], [sf_scale()], [sf_branch()],
#'    [sf_check()].
#' 2. **Validate and save** with [validate_sframe()] and [write_sframe()].
#' 3. **Deploy** a Shiny survey with [render_survey()].
#' 4. **Load responses** with [read_responses()].
#' 5. **Check quality** with [quality_report()].
#' 6. **Score and analyse** with [score_scales()], [reliability_report()],
#'    [item_report()], [efa_report()], and [cfa_syntax()].
#' 7. **Report** with [codebook_report()] and [render_report()].
#'
#' ## The instrument object
#'
#' Every function in the package operates on an `sframe` object. The object
#' is the single source of truth for item definitions, scale structure,
#' reverse-coding keys, branching rules, and check specifications.
#'
#' ## File format
#'
#' Instruments are stored as UTF-8 JSON files with the `.sframe` extension.
#' Each file includes a SHA-256 integrity hash for reproducibility auditing.
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom rlang abort warn arg_match check_installed %||%
#' @importFrom tibble as_tibble tibble
#' @importFrom readr read_csv
#' @importFrom dplyr filter
#' @importFrom openssl sha256
#' @importFrom psych alpha omega KMO cortest.bartlett fa.parallel
#' @importFrom stats setNames cor sd var complete.cases
#' @importFrom utils capture.output
#' @importFrom shiny shinyApp fluidPage titlePanel uiOutput renderUI
#'   observeEvent showNotification showModal modalDialog actionButton
#'   radioButtons checkboxGroupInput numericInput textInput textAreaInput
#'   dateInput fileInput downloadButton downloadHandler tagList tags br
#'   reactive req getShinyOption shinyOptions runApp
## usethis namespace: end
NULL
