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

#' Launch SurveyBuilder with the bundled input-types demo
#'
#' Opens the standalone browser builder and writes the bundled input-types
#' `.sframe` file to a temporary folder so users can load it through the
#' builder.
#'
#' @param open Logical. Passed to [launch_builder()].
#'
#' @return Invisibly returns paths to the builder and demo `.sframe` file.
#' @export
launch_builder_demo <- function(open = TRUE) {
  demo <- sframe_input_types_demo_data()

  demo_dir <- file.path(tempdir(), "surveyframe-input-types-demo")
  dir.create(demo_dir, recursive = TRUE, showWarnings = FALSE)

  demo_file <- file.path(demo_dir, "surveyframe_input_types_demo.sframe")
  write_sframe(demo$instrument, demo_file, overwrite = TRUE)

  builder_path <- launch_builder(open = open)

  message("Input-types demo .sframe file written to: ", normalizePath(demo_file))
  message("In SurveyBuilder, use Load .sframe and select this file.")

  invisible(list(
    builder_path = builder_path,
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
