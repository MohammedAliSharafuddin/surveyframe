# launch_studio.R

# The screens SurveyStudio has, in navigation order, matching the tabs in
# inst/shiny/app.R.
sframe_studio_screens <- function() {
  c("design", "open", "amendments", "references", "preview", "collect", "responses", "quality",
    "reliability", "analysis", "dashboard", "export")
}

# Resolves the `screen` argument to a screen Studio has. "build" used to be
# offered and quietly opened another screen. Its name is now "design".
sframe_studio_screen <- function(screen) {
  screen <- as.character(screen %||% "auto")[1]
  if (identical(screen, "data")) screen <- "responses"
  if (identical(screen, "build")) {
    rlang::abort(
      paste0("SurveyStudio's screen for building a survey is \"design\". ",
             "launch_builder() opens the builder on its own."),
      class = "sframe_error")
  }
  if (!screen %in% c("auto", sframe_studio_screens())) {
    rlang::abort(
      paste0("Unknown Studio screen '", screen, "'. Use \"auto\", or one of: ",
             paste(sframe_studio_screens(), collapse = ", "), "."),
      class = "sframe_error")
  }
  screen
}

#' Launch the SurveyStudio interface
#'
#' Opens the SurveyStudio Shiny application, the visual interface for working
#' with an instrument. Its screens design an instrument in the SurveyBuilder,
#' open one, record and read amendments, preview the survey, set up its
#' collection, upload responses, review data quality, inspect reliability,
#' work on the analysis plan, read the dashboard, and export.
#'
#' The Design screen holds the SurveyBuilder, and a save there becomes the
#' instrument Studio has open. [launch_builder()] opens the builder on its own.
#'
#' @param instrument An `sframe` object or NULL.
#' @param responses A data.frame, tibble, CSV file path, or NULL.
#' @param respondent_id Character or NULL. Response ID column when `responses`
#'   is a CSV path.
#' @param submitted_at Character or NULL. Submission time column when
#'   `responses` is a CSV path.
#' @param meta_cols Character vector or NULL. Metadata columns when `responses`
#'   is a CSV path.
#' @param strict Logical. Passed to [read_responses()] when `responses` is a
#'   CSV path.
#' @param screen The screen to open on. One of `"auto"`, which picks by what
#'   you supply, or a screen name: `"design"`, `"open"`, `"amendments"`,
#'   `"references"`, `"preview"`, `"collect"`,
#'   `"responses"`, `"quality"`, `"reliability"`, `"analysis"`,
#'   `"dashboard"` or `"export"`. `"data"` is accepted for `"responses"`.
#' @param port TCP port for the Shiny server.
#' @param host Host address passed to [shiny::runApp()].
#' @param launch.browser Whether to open the browser automatically.
#' @param demo Optional. A demo name from [sframe_list_demos()]. Studio then
#'   opens with that demo's instrument and responses loaded, in place of
#'   `instrument` and `responses`, which must be left out.
#'   `"input_types"` uses every input type Studio supports.
#'
#' @return Called for its side effect.
#' @export
#' @seealso [launch_builder()], [read_sframe()],
#'   [read_responses()]
#'
#' @examples
#' \dontrun{
#' launch_studio()
#'
#' # A demo, opened on the preview screen
#' launch_studio(demo = "two_group", screen = "preview")
#'
#' demo <- sframe_demo("tourism_services")
#' launch_studio(instrument = demo$instrument, launch.browser = FALSE)
#'
#' launch_studio(
#'   instrument    = demo$instrument,
#'   responses     = demo$responses,
#'   respondent_id = "respondent_id",
#'   submitted_at  = "submitted_at"
#' )
#' }
#' @family entry points
launch_studio <- function(
    instrument = NULL,
    responses = NULL,
    respondent_id = NULL,
    submitted_at = NULL,
    meta_cols = NULL,
    strict = TRUE,
    screen = "auto",
    port = NULL,
    host = "127.0.0.1",
    launch.browser = interactive(),
    demo = NULL
) {
  sframe_require_shiny("to launch SurveyStudio")

  screen <- sframe_studio_screen(screen)

  if (!is.null(demo)) {
    if (!is.null(instrument) || !is.null(responses)) {
      rlang::abort(
        paste0("Supply `demo` or `instrument` and `responses`, not both. ",
               "`demo` loads its own instrument and responses."),
        class = "sframe_error")
    }
    d <- sframe_demo(demo)
    instrument <- d$instrument
    responses <- d$responses
  }

  if (!is.null(instrument)) {
    sframe_check_instrument(instrument)
  }

  if (!is.null(responses) && is.character(responses)) {
    if (is.null(instrument)) {
      rlang::abort(
        "`instrument` must be supplied when `responses` is a file path.",
        class = "sframe_error"
      )
    }

    responses <- read_responses(
      x = responses,
      instrument = instrument,
      respondent_id = respondent_id,
      submitted_at = submitted_at,
      meta_cols = meta_cols,
      strict = strict
    )
  }

  if (!is.null(responses) && !is.data.frame(responses)) {
    rlang::abort(
      "`responses` must be a data.frame, tibble, CSV file path, or NULL.",
      class = "sframe_error"
    )
  }

  shiny::shinyOptions(
    surveyframe_instrument = instrument,
    surveyframe_responses = responses,
    surveyframe_initial_screen = screen
  )

  on.exit(
    shiny::shinyOptions(
      surveyframe_instrument = NULL,
      surveyframe_responses = NULL,
      surveyframe_initial_screen = NULL
    ),
    add = TRUE
  )

  shiny::runApp(
    appDir = sframe_studio_app(),
    port = port,
    host = host,
    launch.browser = launch.browser,
    quiet = TRUE
  )
}

# Builds SurveyStudio from inst/shiny/app.R, sourced into an environment
# whose parent is the package namespace, so the app calls internal helpers
# directly (naming decision 6). The app reads its instrument, responses and
# screen from the shiny options launch_studio() sets before calling this.
sframe_studio_app <- function() {
  app_path <- system.file("shiny", package = "surveyframe")
  if (!nzchar(app_path) || !file.exists(file.path(app_path, "app.R"))) {
    rlang::abort(
      "SurveyStudio app not found. Please reinstall surveyframe.",
      class = "sframe_error"
    )
  }
  app_env <- new.env(parent = asNamespace("surveyframe"))
  sys.source(file.path(app_path, "app.R"), envir = app_env)
  # An app object, unlike a folder, does not serve www/ by itself.
  www_dir <- file.path(app_path, "www")
  if (dir.exists(www_dir)) shiny::addResourcePath("sfstudio", www_dir)
  # The Design screen loads the builder from the same origin, so the 2
  # windows can check where each message comes from.
  builder_dir <- system.file("builder", package = "surveyframe")
  if (nzchar(builder_dir)) shiny::addResourcePath("sfbuilder", builder_dir)
  shiny::shinyApp(ui = app_env$ui, server = app_env$server)
}

# The open instrument as .sframe text, for the Design screen to send the
# builder, as list(text, problem). An instrument write_sframe() refuses, as
# one changed with no amendment recorded, is not sent: rewriting it as a new
# instrument would drop its amendment log, and a save in the builder would
# then replace Studio's instrument with one that has no history. `problem`
# says why in plain words. Both are NULL when there is no instrument.
sframe_studio_sframe_text <- function(instrument) {
  if (!inherits(instrument, "sframe")) return(list(text = NULL, problem = NULL))
  tmp <- tempfile(fileext = ".sframe")
  on.exit(unlink(tmp), add = TRUE)
  err <- tryCatch({
    write_sframe(instrument, tmp, overwrite = TRUE)
    NULL
  }, error = function(e) conditionMessage(e))
  if (!is.null(err)) {
    problem <- if (grepl("changed since its last recorded amendment", err, fixed = TRUE)) {
      paste("This instrument has changes that are not recorded as an amendment.",
            "Record an amendment, or save it as a new instrument, before",
            "editing it in Design.")
    } else {
      paste("Design cannot open this instrument, because it cannot be saved",
            "as it is:", err)
    }
    return(list(text = NULL, problem = problem))
  }
  list(text = paste(readLines(tmp, warn = FALSE, encoding = "UTF-8"), collapse = "\n"),
       problem = NULL)
}


# Whether responses loaded for `old` still fit `new` after a Design save:
# NULL when every item id and every item's choice codes are unchanged, as
# after a label, wording, help text or branding edit. Otherwise a message
# for the person saying the responses were cleared and what changed.
sframe_studio_response_change <- function(old, new) {
  codes <- function(instr) {
    sets <- list()
    for (cs in instr$choices) sets[[as.character(cs$id)]] <- as.character(cs$values)
    out <- list()
    for (it in instr$items) {
      cs <- as.character(it$choice_set %||% "")[1]
      out[[as.character(it$id)]] <- if (nzchar(cs) && !is.null(sets[[cs]])) sets[[cs]] else character(0)
    }
    out
  }
  a <- codes(old)
  b <- codes(new)
  changes <- c(
    sprintf("item %s was removed", setdiff(names(a), names(b))),
    sprintf("item %s was added", setdiff(names(b), names(a))))
  for (id in intersect(names(a), names(b))) {
    gone <- setdiff(a[[id]], b[[id]])
    added <- setdiff(b[[id]], a[[id]])
    n <- min(length(gone), length(added))
    if (n > 0) {
      changes <- c(changes, sprintf("choice %s of %s was renamed %s",
                                    gone[seq_len(n)], id, added[seq_len(n)]))
    }
    changes <- c(changes,
      sprintf("choice %s of %s was removed", gone[-seq_len(n)], id),
      sprintf("choice %s of %s was added", added[-seq_len(n)], id))
  }
  if (length(changes) == 0) return(NULL)
  if (length(changes) > 4) {
    changes <- c(changes[1:3], paste(length(changes) - 3, "other changes were made"))
  }
  listed <- if (length(changes) == 1) changes else
    paste(paste(changes[-length(changes)], collapse = ", "), "and", changes[length(changes)])
  paste0("Responses cleared: ", listed, ". Load the responses again.")
}
