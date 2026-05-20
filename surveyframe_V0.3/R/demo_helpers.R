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
#' Opens a temporary preloaded copy of the standalone browser builder with the
#' bundled input-types `.sframe` instrument already loaded.
#'
#' @param open Logical. When `TRUE`, opens the preloaded builder in the system
#'   browser. When `FALSE`, returns the temporary builder path without opening
#'   it.
#'
#' @return Invisibly returns paths to the preloaded builder, demo instrument,
#'   and response file.
#' @export
launch_builder_demo <- function(open = TRUE) {
  demo <- sframe_input_types_demo_data()

  demo_dir <- file.path(tempdir(), "surveyframe-input-types-demo")
  dir.create(demo_dir, recursive = TRUE, showWarnings = FALSE)

  demo_file <- file.path(demo_dir, "surveyframe_input_types_demo.sframe")
  write_sframe(demo$instrument, demo_file, overwrite = TRUE)

  builder_path <- .sframe_demo_builder_path(
    instrument = demo$instrument,
    demo_dir = demo_dir,
    mode = "preview"
  )

  if (isTRUE(open)) {
    utils::browseURL(.sframe_file_uri(builder_path))
  }

  message("SurveyBuilder opened with the input-types demo preloaded.")
  message(
    "A copy of the demo .sframe file was also written to: ",
    normalizePath(demo_file, winslash = "/", mustWork = TRUE)
  )

  invisible(list(
    builder_path = builder_path,
    demo_file = demo_file,
    responses_path = demo$responses_path
  ))
}

.sframe_file_uri <- function(path) {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  paste0("file://", utils::URLencode(path, reserved = FALSE))
}

.sframe_demo_value <- function(x, default) {
  if (is.null(x)) default else x
}

.sframe_demo_builder_payload <- function(instrument) {
  list(
    meta = .sframe_demo_value(
      instrument$meta,
      list(title = "surveyframe Input Types Demo", version = "1.0.0")
    ),
    choices = .sframe_demo_value(instrument$choices, list()),
    items = .sframe_demo_value(instrument$items, list()),
    scales = .sframe_demo_value(instrument$scales, list()),
    branching = .sframe_demo_value(instrument$branching, list()),
    checks = .sframe_demo_value(instrument$checks, list()),
    analysis_plan = .sframe_demo_value(instrument$analysis_plan, list()),
    models = .sframe_demo_value(instrument$models, list()),
    render = .sframe_demo_value(instrument$render, list())
  )
}

.sframe_demo_builder_path <- function(
    instrument,
    demo_dir,
    mode = c("preview", "build", "analyse")
) {
  mode <- match.arg(mode)

  dir.create(demo_dir, recursive = TRUE, showWarnings = FALSE)

  source_builder <- launch_builder(open = FALSE)

  builder_html <- paste(
    readLines(source_builder, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )

  payload_json <- jsonlite::toJSON(
    .sframe_demo_builder_payload(instrument),
    auto_unbox = TRUE,
    null = "null",
    pretty = TRUE
  )

  mode_json <- jsonlite::toJSON(mode, auto_unbox = TRUE)

  preload_js <- paste0(
    "\n/* surveyframe demo preload */\n",
    "(function(){\n",
    "  try {\n",
    "    try { localStorage.removeItem('sf_as'); } catch(e) {}\n",
    "    window.__surveyframe_demo_payload = ", payload_json, ";\n",
    "    S = window.__surveyframe_demo_payload;\n",
    "    selId = null;\n",
    "    dirty = false;\n",
    "    lastSaved = Date.now();\n",
    "    setTimeout(function(){\n",
    "      try {\n",
    "        ra();\n",
    "        var demoMode = ", mode_json, ";\n",
    "        if (demoMode === 'preview') {\n",
    "          setMode('preview');\n",
    "          setPvTab('survey');\n",
    "        } else if (demoMode === 'analyse') {\n",
    "          setMode('analyse');\n",
    "        } else {\n",
    "          setMode('build');\n",
    "        }\n",
    "      } catch(e) {\n",
    "        console.error('Could not render preloaded surveyframe demo', e);\n",
    "      }\n",
    "    }, 0);\n",
    "  } catch(e) {\n",
    "    console.error('Could not preload surveyframe demo instrument', e);\n",
    "  }\n",
    "})();\n"
  )

  marker <- "chkAutoSave();"
  hit <- regexpr(marker, builder_html, fixed = TRUE)[[1]]

  if (hit < 0) {
    rlang::abort(
      "SurveyBuilder preload marker not found. The bundled builder structure may have changed.",
      class = "sframe_error"
    )
  }

  builder_html <- paste0(
    substr(builder_html, 1L, hit - 1L),
    preload_js,
    "\n",
    substr(builder_html, hit, nchar(builder_html))
  )

  demo_builder_path <- file.path(demo_dir, "survey_builder_input_types_demo.html")
  writeLines(builder_html, con = demo_builder_path, useBytes = TRUE)

  demo_builder_path
}

#' Launch SurveyStudio with the bundled input-types demo
#'
#' Opens SurveyStudio with the bundled input-types questionnaire and simulated
#' response data.
#'
#' @param screen Initial studio screen. Defaults to `"preview"`.
#' @param port TCP port for the Shiny server.
#' @param host Host address for the Shiny server.
#' @param launch.browser Whether to open the browser automatically.
#'
#' @return Called for its side effect.
#' @export
launch_studio_demo <- function(
    screen = "preview",
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
