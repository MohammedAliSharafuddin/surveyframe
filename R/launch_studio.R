# launch_studio.R

#' Launch the SurveyStudio interface
#'
#' Opens the SurveyStudio Shiny application, a visual shell for the full
#' surveyframe workflow. The studio provides screens to build a survey draft,
#' open an existing instrument, preview the survey, upload responses, review
#' data quality, inspect reliability, and export the instrument or report.
#'
#' An instrument and response data can be pre-loaded at launch time. If
#' neither is supplied, the studio opens at the build screen so the
#' researcher can start authoring interactively.
#'
#' @param instrument An `sframe` object or NULL. When supplied, the studio
#'   opens directly to the preview screen with this instrument loaded.
#' @param responses A `tibble`, `data.frame`, or file path to a CSV, or NULL.
#'   When supplied alongside `instrument`, the studio opens with responses
#'   pre-loaded and the quality dashboard available immediately.
#'
#' @return Launches a Shiny application. Does not return a value.
#' @export
#' @seealso [render_survey()], [read_sframe()], [read_responses()]
#'
#' @examples
#' \dontrun{
#' # Open the studio with no pre-loaded data
#' launch_studio()
#'
#' # Open with an instrument pre-loaded
#' instr <- read_sframe("my_instrument.sframe")
#' launch_studio(instrument = instr)
#'
#' # Open with both instrument and responses ready
#' launch_studio(instrument = instr, responses = "data/responses.csv")
#' }
launch_studio <- function(instrument = NULL, responses = NULL) {
  if (!is.null(instrument)) {
    stopifnot(inherits(instrument, "sframe"))
  }

  app_path <- system.file("shiny", package = "surveyframe")
  if (!nzchar(app_path) || !file.exists(file.path(app_path, "app.R"))) {
    rlang::abort(
      "SurveyStudio app not found. Please reinstall surveyframe.",
      class = "sframe_error"
    )
  }

  # Pass pre-loaded objects via shiny options
  shiny::shinyOptions(
    surveyframe_instrument = instrument,
    surveyframe_responses  = responses
  )

  shiny::runApp(app_path, launch.browser = TRUE)
}
