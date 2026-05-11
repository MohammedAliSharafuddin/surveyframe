# builder.R

#' Launch the surveyframe visual survey builder
#'
#' Opens the working SurveyStudio builder interface. The older standalone
#' browser builder remains bundled for inspection and test discovery, but the
#' interactive launch path now uses the Shiny application because it has live
#' server-side handlers for clicks, edits, preview, validation, import, export,
#' and analysis workflow screens.
#'
#' @param open Logical. If `TRUE` (the default), opens the interactive builder
#'   in the default browser through SurveyStudio. Set to `FALSE` to return the
#'   bundled standalone HTML file path without opening it, which is useful for
#'   tests and static inspection.
#'
#' @return Invisibly returns the builder HTML path when `open = FALSE`. When
#'   `open = TRUE`, launches the SurveyStudio Shiny app and blocks the current
#'   R session until the app exits.
#' @export
#' @seealso [launch_studio()], [read_sframe()], [run_analysis_plan()]
#'
#' @examples
#' \dontrun{
#' launch_builder()
#' }
#'
#' # Get path without opening (useful for testing)
#' path <- launch_builder(open = FALSE)
launch_builder <- function(open = TRUE) {
  builder_path <- system.file("builder", "survey_builder.html",
                             package = "surveyframe")
  if (!nzchar(builder_path) || !file.exists(builder_path)) {
    rlang::abort(
      paste0(
        "SurveyBuilder not found. ",
        "Please reinstall surveyframe or check inst/builder/."
      ),
      class = "sframe_error"
    )
  }

  if (isTRUE(open)) {
    launch_studio()
    return(invisible(builder_path))
  }

  invisible(builder_path)
}
