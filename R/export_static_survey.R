# export_static_survey.R

#' Export a self-contained static HTML survey
#'
#' Generates a single HTML file that presents the survey instrument in a
#' browser by itself, offline, with the Shiny server left out. Every item type,
#' branching, required-item checks and multi-page navigation run in the
#' browser's own JavaScript.
#'
#' When `output_path` is `NULL`, the file is written to [tempdir()]. Supply
#' an explicit `output_path` for any production export that should be kept.
#'
#' # How a response reaches you
#'
#' On submission the survey builds a one-row CSV in the browser's memory and
#' shows the thank-you screen. When `endpoint_url` is supplied, it also sends
#' the response as a POST request to that URL, for example a Google Apps
#' Script web app. The browser reads back none of the reply to that request, so the
#' survey treats it as sent and the respondent sees the thank-you screen
#' either way.
#'
#' The thank-you screen offers the CSV as a download button, which the
#' respondent chooses to use. It appears when the instrument's thank-you
#' settings ask for it, and whenever there is no `endpoint_url`, where that
#' file is the only copy of the response.
#'
#' Plan for both parts. Test the endpoint with a pilot submission and confirm
#' the row arrives before collecting, and treat the download as a route a
#' respondent may decline.
#'
#' # For a host page: confirmed delivery, restarts and drafts
#'
#' While a response is being sent, the survey shows a sending screen. A host
#' that can confirm delivery, such as a platform embedding the survey, defines
#' `window.sframeSendResponse(row)` in the page before the survey script runs.
#' The survey then hands each response to that function in place of its own
#' POST. It returns a Promise: resolving to `true`, or to `{confirmed: true}`,
#' shows the response as recorded. Resolving to anything else shows it as sent
#' and unconfirmed, and a rejection shows the failure screen with a retry.
#'
#' The thank-you screen states delivery itself, one line for each outcome:
#' recorded, sent but unconfirmed, not sent, or failed. Write
#' `render$thankyou$message` as thanks, a debrief or contact details, and do
#' not state delivery in it. It appears below the status line in every case
#' except a failed send, and defaults to "Thank you for participating."
#'
#' Two settings in the instrument's `render` block suit a host too.
#' `render$thankyou$show_restart = FALSE` hides "Submit another response".
#' `render$save_draft = TRUE` keeps the answers in the browser's local storage
#' as the respondent goes, under a key drawn from the instrument's content, so
#' a respondent who closes the tab is offered to resume on return. The draft
#' is cleared once the response is submitted, and kept when delivery fails.
#'
#' The exported file works offline. It can be hosted on GitHub Pages,
#' Netlify, any static file server, or e-mailed as an attachment for
#' opening directly from disk.
#'
#' @param instrument An `sframe` object.
#' @param output_path Character. File path for the output HTML. When `NULL`,
#'   a `<survey_title>.html` file is written in [tempdir()].
#' @param open Logical. If `TRUE` (default) and the session is interactive,
#'   the file is opened in the default browser after writing.
#' @param endpoint_url Character or NULL. A URL to which responses are
#'   POSTed as JSON on submission. When NULL, CSV download is the only
#'   collection mechanism.
#' @param overwrite Logical. Whether to overwrite an existing file at
#'   `output_path`. Defaults to `FALSE`.
#' @param preview Logical. `TRUE` exports a survey that collects nothing: the
#'   collector endpoint and the completion redirect are both removed, and the
#'   thank-you screen says the response went nowhere, above the study's own
#'   message as respondents will read it. This is what SurveyStudio's
#'   preview uses, which keeps a test answer away from a live study's collector.
#'   Supplying `endpoint_url` alongside it is an error. Defaults to `FALSE`.
#'
#' @return The output path, invisibly.
#' @export
#' @seealso [launch_studio()], [launch_builder()], [render_survey()]
#'
#' @examples
#' cs    <- sf_choices("ag5", 1:5,
#'            c("Strongly disagree", "Disagree", "Neutral",
#'              "Agree", "Strongly agree"))
#' i1    <- sf_item("sat_1", "Overall I am satisfied with the service.",
#'                  type = "likert", choice_set = "ag5", required = TRUE)
#' i2    <- sf_item("comments", "Any additional comments?", type = "textarea")
#' instr <- sf_instrument("Customer Satisfaction Survey",
#'                        components = list(cs, i1, i2))
#'
#' # Write to a temp file without opening the browser
#' out <- export_static_survey(instr,
#'                              output_path = file.path(tempdir(), "sat.html"),
#'                              open = FALSE)
#' file.exists(out)
#'
#' \donttest{
#' # Write to a temp file and open in the default browser
#' export_static_survey(instr,
#'                      output_path = file.path(tempdir(), "sat_browser.html"),
#'                      overwrite = TRUE)
#'
#' # Write with a Google Apps Script endpoint for server-side collection
#' export_static_survey(
#'   instr,
#'   output_path  = file.path(tempdir(), "sat_endpoint.html"),
#'   endpoint_url = "https://script.google.com/macros/s/XXXXX/exec",
#'   open         = FALSE,
#'   overwrite    = TRUE
#' )
#' }
export_static_survey <- function(
    instrument,
    output_path  = NULL,
    open         = interactive(),
    endpoint_url = NULL,
    overwrite    = FALSE,
    preview      = FALSE
) {
  sframe_check_instrument(instrument)
  rlang::check_installed("jsonlite", reason = "to serialise the instrument as JSON.")

  # A preview has to be unable to collect, rather than merely expected not to.
  # SurveyStudio's preview exported the real instrument and the endpoint fell
  # back to its configured collector below, so test answers could land in a
  # live study's sheet beside real participants'.
  if (isTRUE(preview) && !is.null(endpoint_url)) {
    rlang::abort(
      paste0("A preview export collects nothing, so `endpoint_url` cannot be ",
             "supplied with `preview = TRUE`. Drop one of the two."),
      class = "sframe_error")
  }
  if (isTRUE(preview)) {
    instrument$render$google_sheets_endpoint <- NULL
    # A redirect would carry the researcher out of the preview to whatever the
    # study points at on completion.
    instrument$render$thankyou$redirect_url <- NULL
  }

  # Fix B: fall back to endpoint stored by the builder if no argument supplied
  endpoint_url <- endpoint_url %||%
    instrument$render$google_sheets_endpoint %||% ""

  # Resolve output path
  if (is.null(output_path)) {
    slug <- gsub("[^a-zA-Z0-9]", "_", instrument$meta$title %||% "survey")
    slug <- gsub("_+", "_", slug)
    output_path <- file.path(tempdir(), paste0(slug, ".html"))
  }

  if (file.exists(output_path) && !overwrite) {
    rlang::abort(
      paste0("Output file already exists: '", output_path, "'. ",
             "Set overwrite = TRUE to replace it."),
      class = "sframe_error"
    )
  }

  # Load template
  tpl_path <- system.file("static_survey", "template.html",
                           package = "surveyframe")
  if (!nzchar(tpl_path) || !file.exists(tpl_path)) {
    rlang::abort(
      "Static survey template not found. Please reinstall surveyframe.",
      class = "sframe_error"
    )
  }
  tpl <- paste(readLines(tpl_path, encoding = "UTF-8"), collapse = "\n")

  html_escape <- function(x) {
    x <- gsub("&", "&amp;", x, fixed = TRUE)
    x <- gsub("<", "&lt;", x, fixed = TRUE)
    x <- gsub(">", "&gt;", x, fixed = TRUE)
    x <- gsub('"', "&quot;", x, fixed = TRUE)
    x
  }
  replace_placeholder <- function(x, placeholder, value) {
    paste(strsplit(x, placeholder, fixed = TRUE)[[1]], collapse = value)
  }
  strip_classes <- function(x) {
    if (is.list(x)) {
      x <- lapply(x, strip_classes)
      class(x) <- NULL
    }
    x
  }

  # Serialise instrument, stripping the hash slot to keep the JSON clean.
  instr_list <- strip_classes(instrument)
  instr_list$hash <- NULL
  instr_json <- jsonlite::toJSON(instr_list, auto_unbox = TRUE, null = "null",
                                  digits = NA, pretty = FALSE)
  instr_json <- gsub("<", "\\u003c", instr_json, fixed = TRUE)

  # Resolve theme colour
  theme <- instrument$render$theme %||% "#2563eb"
  if (!grepl("^#[0-9A-Fa-f]{3,6}$", theme)) theme <- "#2563eb"

  # Substitute placeholders
  html <- tpl
  html <- replace_placeholder(html, "{{INSTRUMENT_JSON}}", instr_json)
  html <- replace_placeholder(
    html,
    "{{SURVEY_TITLE}}",
    html_escape(instrument$meta$title %||% "Survey")
  )
  html <- replace_placeholder(html, "{{THEME_COLOR}}", theme)
  html <- replace_placeholder(html, "{{ENDPOINT_URL}}", html_escape(endpoint_url))
  html <- replace_placeholder(html, "{{PREVIEW}}",
                              if (isTRUE(preview)) "true" else "false")

  # Write output
  dir.create(dirname(output_path), showWarnings = FALSE, recursive = TRUE)
  writeLines(html, output_path, useBytes = FALSE)

  size_kb <- round(file.size(output_path) / 1024, 1)
  rlang::inform(
    paste0("Static survey written to '", output_path,
           "' (", size_kb, " KB).")
  )

  if (isTRUE(open)) {
    utils::browseURL(paste0("file://", normalizePath(output_path)))
  }

  invisible(output_path)
}
