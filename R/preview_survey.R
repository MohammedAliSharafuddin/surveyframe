# R/preview_survey.R
# The Preview stage verb: one line from an instrument or a demo name to the
# survey a respondent sees.

#' Preview a survey as a respondent sees it
#'
#' Opens an instrument as a respondent would meet it, either as a standalone
#' page in the browser or on SurveyStudio's preview screen. The preview has
#' its collector removed, so trying it is safe: no answer is sent anywhere.
#'
#' @param x An `sframe` instrument, or a demo name from [sframe_list_demos()].
#'   A demo is shown with the standard demo branding, as
#'   `sframe_demo(name, branded = TRUE)` applies it.
#' @param where One of `"browser"`, a standalone HTML page written by
#'   [export_survey()], or `"studio"`, the preview screen of
#'   [launch_studio()].
#' @param open Logical. Whether to open the browser. Defaults to
#'   [interactive()].
#'
#' @return For `"browser"`, the path of the HTML page, invisibly. For
#'   `"studio"`, what [launch_studio()] returns.
#' @export
#' @seealso [export_survey()] for the page you send to respondents,
#'   [launch_studio()], [sframe_demo()]
#'
#' @examples
#' # A demo by name
#' path <- preview_survey("two_group", open = FALSE)
#' sframe_show(path)
#'
#' # Your own instrument
#' ins <- sframe_demo("first_survey")$instrument
#' path <- preview_survey(ins, open = FALSE)
#' sframe_show(path)
#' @family Preview functions
preview_survey <- function(x, where = c("browser", "studio"),
                           open = interactive()) {
  where <- match.arg(where)
  if (is.character(x) && length(x) == 1L) {
    name <- x
    x <- sframe_demo(name, branded = TRUE, preview = FALSE)$instrument
  } else if (inherits(x, "sframe")) {
    name <- x$meta$id %||% "survey"
  } else {
    rlang::abort(
      "`x` must be an sframe instrument or a demo name from sframe_list_demos().",
      class = "sframe_error")
  }
  if (identical(where, "studio")) {
    return(launch_studio(x, screen = "preview", launch.browser = open))
  }
  out <- file.path(tempdir(), paste0("surveyframe-preview-",
                                     gsub("[^A-Za-z0-9_-]", "_", name), ".html"))
  export_survey(x, output_path = out, open = open, overwrite = TRUE,
                preview = TRUE)
}
