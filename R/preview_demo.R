# R/preview_demo.R
# One line from a demo name to the survey a respondent sees.

#' Preview a demo survey in one line
#'
#' Loads a bundled demo with the standard branding and opens it as a
#' respondent would see it, either as a standalone page in the browser or on
#' SurveyStudio's preview screen. The preview has its collector removed, so
#' trying it is safe.
#'
#' @param name Character. The demo to preview. [sframe_demos()] lists them.
#'   Defaults to `"two_group"`.
#' @param where One of `"browser"`, a standalone HTML page written by
#'   [export_static_survey()], or `"studio"`, the preview screen of
#'   [launch_studio()].
#' @param open Logical. Whether to open the browser. Defaults to
#'   [interactive()].
#'
#' @return For `"browser"`, the path of the HTML page, invisibly. For
#'   `"studio"`, what [launch_studio()] returns.
#' @export
#' @seealso [sframe_demo()], [export_static_survey()], [launch_studio()]
#'
#' @examples
#' path <- preview_demo("two_group", open = FALSE)
#' file.exists(path)
preview_demo <- function(name = "two_group", where = c("browser", "studio"),
                         open = interactive()) {
  where <- match.arg(where)
  demo <- sframe_demo(name, branded = TRUE)
  if (identical(where, "studio")) {
    return(launch_studio(demo$instrument, screen = "preview",
                         launch.browser = open))
  }
  out <- file.path(tempdir(), paste0("surveyframe-preview-", name, ".html"))
  export_static_survey(demo$instrument, output_path = out, open = open,
                       overwrite = TRUE, preview = TRUE)
}
