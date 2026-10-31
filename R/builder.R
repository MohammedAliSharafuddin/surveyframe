# builder.R

#' Launch the surveyframe visual survey builder
#'
#' Opens the SurveyBuilder, a self-contained HTML application for visual survey
#' design. The builder runs client-side without an R session or Shiny server.
#' Save instruments as `.sframe` files from the browser and load them into R
#' with [read_sframe()].
#'
#' The builder includes a three-mode interface.
#'
#' \describe{
#'   \item{Build}{An item editor with a persistent inspector panel,
#'     drag-to-reorder, undo/redo, and autosave to browser localStorage.}
#'   \item{Preview}{A layout preview of the welcome, body and thank-you
#'     pages, showing wording, order and branding. It renders from the
#'     builder's own markup, so answering, required checks and branching are
#'     left out. Use [export_survey()] and open the file to test the
#'     respondent's path, or SurveyStudio's Preview screen, which exports the
#'     real survey with collection switched off.}
#'   \item{Analyse}{A role-based analysis planner with method-specific
#'     options, planned outputs, reporting references, and decision rules.}
#' }
#'
#' The builder includes a pure-JavaScript SHA-256 fallback for browsers or
#' security policies where `crypto.subtle` is unavailable on `file://`
#' origins. Saved `.sframe` files can be loaded and validated with
#' [read_sframe()].
#'
#' @param open Logical. When `TRUE` (the default), the builder HTML file is
#'   opened in the system's default web browser with [utils::browseURL()].
#'   Set to `FALSE` to return the file path without opening it, which is
#'   useful for automated testing.
#' @param demo Optional. A demo name from [sframe_list_demos()]. The builder
#'   then opens from a temporary copy with that demo's questions, scales and
#'   analysis plan already loaded. `"input_types"` shows every input type
#'   the builder supports.
#'
#' @return The path to the builder HTML file, invisibly: the bundled file, or
#'   the temporary copy when `demo` is given.
#' @export
#' @seealso [launch_studio()], [read_sframe()], [run_analysis_plan()]
#'
#' @examples
#' # Retrieve the builder path for inspection without opening the browser
#' path <- launch_builder(open = FALSE)
#' file.exists(path)
#'
#' # The same builder with a demo preloaded
#' path <- launch_builder(demo = "two_group", open = FALSE)
#' file.exists(path)
#' @family Design functions
launch_builder <- function(open = TRUE, demo = NULL) {
  builder_path <- if (is.null(demo)) {
    system.file("builder", "survey_builder.html", package = "surveyframe")
  } else {
    sframe_builder_demo_html(demo)
  }

  if (!nzchar(builder_path) || !file.exists(builder_path)) {
    rlang::abort(
      paste0(
        "SurveyBuilder HTML not found. ",
        "Please reinstall surveyframe or check inst/builder/."
      ),
      class = "sframe_error"
    )
  }

  if (isTRUE(open)) {
    # Use a file:// URI so the browser can open it without a server.
    # crypto.subtle is available on file:// in Chrome and Edge; Firefox
    # requires --allow-file-access-from-files or serving via localhost.
    # The builder gracefully degrades when crypto.subtle is unavailable.
    utils::browseURL(paste0("file://", normalizePath(builder_path)))
  }

  invisible(builder_path)
}
