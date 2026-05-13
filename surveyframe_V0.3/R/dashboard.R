# dashboard.R

#' Launch the interactive response dashboard
#'
#' Opens a Shiny dashboard for exploring survey response data alongside the
#' instrument definition. The dashboard provides five panels:
#'
#' \describe{
#'   \item{Overview}{Response count, date range, and instrument metadata.}
#'   \item{Items}{Per-item frequency bar charts, histograms, and tabulated
#'     frequency counts for choice-type questions.}
#'   \item{Scales}{Scale score distributions with mean overlay, and a
#'     summary table of scale definitions.}
#'   \item{Quality}{Attention check pass rates for each check defined in the
#'     instrument.}
#'   \item{Raw data}{Scrollable response table with a CSV download button.}
#' }
#'
#' The dashboard is read-only. It supports descriptive exploration before
#' running formal analysis via [run_analysis_plan()].
#'
#' @param instrument An `sframe` object.
#' @param responses A `data.frame` or `tibble` of survey responses, as
#'   produced by [read_responses()] or [read_sheet_responses()]. When NULL,
#'   the dashboard opens with instrument metadata and chart stubs only.
#' @param port Integer or NULL. TCP port for the Shiny server. When NULL,
#'   Shiny selects an available port automatically.
#' @param host Character. Host address passed to [shiny::runApp()]. Defaults
#'   to `"127.0.0.1"`.
#' @param launch.browser Logical. Whether to open the dashboard in the
#'   default browser automatically. Defaults to `TRUE` in interactive
#'   sessions.
#'
#' @return Called for its side effect. Returns nothing.
#' @export
#' @seealso [run_analysis_plan()], [quality_report()], [score_scales()]
#'
#' @examples
#' \dontrun{
#' # Open the dashboard with instrument only (no response data)
#' instr <- read_sframe("my_survey.sframe")
#' launch_dashboard(instr)
#'
#' # Open with collected responses
#' responses <- read_responses("data/responses.csv", instr)
#' launch_dashboard(instr, responses)
#' }
launch_dashboard <- function(
    instrument,
    responses      = NULL,
    port           = NULL,
    host           = "127.0.0.1",
    launch.browser = interactive()
) {
  rlang::check_installed("shiny", reason = "to launch the response dashboard.")
  stopifnot(inherits(instrument, "sframe"))

  if (!is.null(responses) && !is.data.frame(responses)) {
    rlang::abort(
      "`responses` must be a data.frame or NULL.",
      class = "sframe_error"
    )
  }

  app_path <- system.file("shiny", "dashboard", package = "surveyframe")
  if (!nzchar(app_path) || !file.exists(file.path(app_path, "app.R"))) {
    rlang::abort(
      "Dashboard app not found. Please reinstall surveyframe.",
      class = "sframe_error"
    )
  }

  # Expose data to the app via environment
  app_env <- new.env(parent = asNamespace("surveyframe"))
  app_env$SFRAME_INSTRUMENT <- instrument
  app_env$SFRAME_RESPONSES  <- responses

  shiny::runApp(
    appDir        = app_path,
    appEnvir      = app_env,
    port          = port,
    host          = host,
    launch.browser= launch.browser,
    quiet         = TRUE
  )
}
