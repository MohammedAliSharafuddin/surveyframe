# builder.R

#' Launch the surveyframe visual survey builder
#'
#' Opens the SurveyBuilder, a self-contained HTML application for designing
#' survey instruments visually. The builder runs entirely in the browser with
#' no active R session or Shiny server required. Instruments are saved as
#' `.sframe` files and loaded back into R with [read_sframe()].
#'
#' The builder provides a three-mode interface: Build (item editor with
#' persistent inspector panel), Preview (full survey render with welcome,
#' body, and thank-you pages), and Analyse (research question planning with
#' automatic test suggestion and citation lookup). All changes autosave to
#' browser localStorage. The final instrument is exported as a `.sframe` file.
#'
#' @param open Logical. If `TRUE` (the default), opens the builder in the
#'   default browser. Set to `FALSE` to return the file path without opening,
#'   which is useful for testing.
#'
#' @return Returns the path to the builder HTML file invisibly.
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
    utils::browseURL(paste0("file://", builder_path))
  }
  invisible(builder_path)
}
