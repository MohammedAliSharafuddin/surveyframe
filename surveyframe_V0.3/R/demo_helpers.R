# demo_helpers.R

#' Load bundled surveyframe demo data
#'
#' Loads the bundled tourism-services `.sframe` instrument and simulated
#' response dataset used in package examples and statistical workflow demos.
#'
#' @return A list with `instrument`, `responses`, `instrument_path`, and
#'   `responses_path`.
#' @export
sframe_demo_data <- function() {
  instrument_path <- system.file(
    "extdata", "tourism_services_demo.sframe",
    package = "surveyframe"
  )

  responses_path <- system.file(
    "extdata", "tourism_services_responses.csv",
    package = "surveyframe"
  )

  if (!nzchar(instrument_path) || !file.exists(instrument_path)) {
    rlang::abort(
      "Bundled demo instrument not found. Please reinstall surveyframe.",
      class = "sframe_error"
    )
  }

  if (!nzchar(responses_path) || !file.exists(responses_path)) {
    rlang::abort(
      "Bundled demo response file not found. Please reinstall surveyframe.",
      class = "sframe_error"
    )
  }

  instrument <- read_sframe(instrument_path)

  responses <- read_responses(
    responses_path,
    instrument,
    respondent_id = "respondent_id",
    submitted_at = "submitted_at",
    meta_cols = "started_at"
  )

  list(
    instrument = instrument,
    responses = responses,
    instrument_path = instrument_path,
    responses_path = responses_path
  )
}

#' Load bundled input-types demo data
#'
#' Loads the bundled `.sframe` instrument and simulated response dataset that
#' cover all main survey input types supported by surveyframe.
#'
#' @return A list with `instrument`, `responses`, `instrument_path`, and
#'   `responses_path`.
#' @export
sframe_input_types_demo_data <- function() {
  instrument_path <- system.file(
    "extdata", "surveyframe_input_types_demo.sframe",
    package = "surveyframe"
  )

  responses_path <- system.file(
    "extdata", "surveyframe_input_types_responses.csv",
    package = "surveyframe"
  )

  if (!nzchar(instrument_path) || !file.exists(instrument_path)) {
    rlang::abort(
      "Bundled input-types demo instrument not found. Please reinstall surveyframe.",
      class = "sframe_error"
    )
  }

  if (!nzchar(responses_path) || !file.exists(responses_path)) {
    rlang::abort(
      "Bundled input-types demo response file not found. Please reinstall surveyframe.",
      class = "sframe_error"
    )
  }

  instrument <- read_sframe(instrument_path)

  responses <- read_responses(
    x = responses_path,
    instrument = instrument,
    respondent_id = "respondent_id",
    submitted_at = "submitted_at",
    meta_cols = "started_at",
    strict = TRUE
  )

  list(
    instrument = instrument,
    responses = responses,
    instrument_path = instrument_path,
    responses_path = responses_path
  )
}

# file: R/demo_helpers.R

#' Launch SurveyBuilder with the bundled input-types demo
#'
#' Opens a temporary copy of the standalone browser builder preloaded with the
#' bundled input-types `.sframe` instrument.
#'
#' @param open Logical. When `TRUE`, opens the preloaded builder in the system
#'   browser. When `FALSE`, returns the temporary builder path without opening it.
#'
#' @return Invisibly returns paths to the temporary builder and demo `.sframe`
#'   file.
#' @export
launch_builder_demo <- function(open = TRUE) {
  demo <- sframe_input_types_demo_data()

  demo_dir <- file.path(tempdir(), "surveyframe-input-types-demo")
  dir.create(demo_dir, recursive = TRUE, showWarnings = FALSE)

  demo_file <- file.path(demo_dir, "surveyframe_input_types_demo.sframe")
  write_sframe(demo$instrument, demo_file, overwrite = TRUE)

  builder_path <- launch_builder(open = FALSE)

  html <- paste(readLines(builder_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  payload <- paste(readLines(demo_file, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

  injection <- paste0(
    "\n",
    "// surveyframe demo preload injected by launch_builder_demo()\n",
    "(function(){\n",
    "  try {\n",
    "    var p = ", payload, ";\n",
    "    var src = p && p.meta ? p : (p && p.items ? p : null);\n",
    "    if (src) {\n",
    "      S.meta = src.meta || S.meta;\n",
    "      S.choices = src.choices || [];\n",
    "      S.items = src.items || [];\n",
    "      S.scales = src.scales || [];\n",
    "      S.branching = src.branching || [];\n",
    "      S.checks = src.checks || [];\n",
    "      S.analysis_plan = src.analysis_plan || [];\n",
    "      S.models = src.models || [];\n",
    "      S.render = src.render || S.render;\n",
    "      ['welcome', 'thankyou', 'header'].forEach(function(k) {\n",
    "        if (!S.render[k]) S.render[k] = {};\n",
    "      });\n",
    "      selId = null;\n",
    "      dirty = false;\n",
    "      lastSaved = Date.now();\n",
    "      window.__surveyframe_demo_loaded = true;\n",
    "    }\n",
    "  } catch(e) {\n",
    "    console.error('Could not preload surveyframe demo state:', e);\n",
    "  }\n",
    "})();\n"
  )

  marker <- "chkAutoSave();\nrenderItemList();"

  if (!grepl(marker, html, fixed = TRUE)) {
    rlang::abort(
      "Could not locate SurveyBuilder initialisation block for demo preload.",
      class = "sframe_error"
    )
  }

  html <- sub(
    marker,
    paste0(injection, "\n", marker),
    html,
    fixed = TRUE
  )

  demo_builder <- file.path(demo_dir, "survey_builder_demo.html")
  writeLines(html, demo_builder, useBytes = TRUE)

  if (isTRUE(open)) {
    utils::browseURL(paste0("file://", normalizePath(demo_builder, winslash = "/")))
  }

  message("Preloaded SurveyBuilder demo opened from: ", normalizePath(demo_builder))
  message("Demo .sframe file written to: ", normalizePath(demo_file))

  invisible(list(
    builder_path = demo_builder,
    demo_file = demo_file
  ))
}

#' Launch SurveyStudio with the bundled input-types demo
#'
#' Opens SurveyStudio with the bundled input-types questionnaire and simulated
#' response data.
#'
#' @param screen Initial studio screen. Defaults to `"auto"`.
#' @param port TCP port for the Shiny server.
#' @param host Host address for the Shiny server.
#' @param launch.browser Whether to open the browser automatically.
#'
#' @return Called for its side effect.
#' @export
launch_studio_demo <- function(
    screen = "auto",
    port = NULL,
    host = "127.0.0.1",
    launch.browser = interactive()
) {
  demo <- sframe_input_types_demo_data()

  launch_studio(
    instrument = demo$instrument,
    responses = demo$responses,
    screen = screen,
    port = port,
    host = host,
    launch.browser = launch.browser
  )
}

#' Launch the response dashboard with the bundled input-types demo
#'
#' Opens the dashboard with the bundled input-types questionnaire and simulated
#' responses.
#'
#' @param port TCP port for the Shiny server.
#' @param host Host address for the Shiny server.
#' @param launch.browser Whether to open the browser automatically.
#'
#' @return Called for its side effect.
#' @export
launch_dashboard_demo <- function(
    port = NULL,
    host = "127.0.0.1",
    launch.browser = interactive()
) {
  demo <- sframe_input_types_demo_data()

  launch_dashboard(
    instrument = demo$instrument,
    responses = demo$responses,
    port = port,
    host = host,
    launch.browser = launch.browser
  )
}
