# demo_helpers.R

# Writes a temporary copy of the SurveyBuilder with a demo instrument injected
# into its JavaScript state, so the questions, scales and analysis plan show
# at once, and returns its path. Used by launch_builder(demo =).
sframe_builder_demo_html <- function(name) {
  demo <- sframe_demo(name, preview = FALSE)

  # Build a plain-list serialisation payload (strips R S3 classes)
  payload <- sframe_serialization_payload(demo$instrument)

  # The builder state needs exactly these keys (no hash / version wrapper)
  state <- list(
    meta          = payload$meta,
    choices       = payload$choices,
    items         = payload$items,
    scales        = payload$scales,
    branching     = payload$branching,
    checks        = payload$checks,
    analysis_plan = payload$analysis_plan,
    models        = payload$models,
    render        = payload$render %||% list(
      mode            = "standard",
      theme           = "#2563eb",
      submit_label    = "Submit",
      welcome         = list(
        title            = "Welcome to this survey",
        intro_text       = "Thank you for taking part.",
        consent_text     = "I understand and agree to participate.",
        consent_required = FALSE,
        start_label      = "Start Survey"
      ),
      thankyou        = list(
        message      = "Thank you for participating.",
        redirect_url = "",
        show_download = FALSE
      ),
      header          = list(
        institution  = "",
        logo_base64  = "",
        show_progress = TRUE
      ),
      google_sheets_url      = "",
      google_sheets_endpoint = ""
    )
  )

  # Compact JSON suitable for inline JavaScript assignment
  state_json <- jsonlite::toJSON(
    state, auto_unbox = TRUE, null = "null", pretty = FALSE
  )

  # Read the bundled builder HTML as a single string for injection
  src_path <- system.file("builder", "survey_builder.html",
                          package = "surveyframe")
  if (!nzchar(src_path) || !file.exists(src_path)) {
    rlang::abort(
      "SurveyBuilder HTML not found. Please reinstall surveyframe.",
      class = "sframe_error"
    )
  }

  builder_html <- paste(
    readLines(src_path, encoding = "UTF-8", warn = FALSE),
    collapse = "\n"
  )

  # 1. Replace the var S={...}; initialisation with the demo state.
  builder_html <- sub(
    "var S=\\{meta:\\{[^;]+\\};",
    paste0("var S=", state_json, ";"),
    builder_html
  )

  # 2. Before chkAutoSave() clears/restores any prior localStorage session,
  #    remove the autosave key so the recovery banner does not appear.
  init_marker <- "chkAutoSave();"
  ls_clear <- "try{localStorage.removeItem('sf_as');}catch(e){}\n"
  builder_html <- sub(
    init_marker,
    paste0(ls_clear, init_marker),
    builder_html,
    fixed = TRUE
  )

  if (!grepl(state_json, builder_html, fixed = TRUE)) {
    rlang::abort(
      paste0(
        "Could not inject the demo state into survey_builder.html. ",
        "Please reinstall surveyframe."
      ),
      class = "sframe_error"
    )
  }

  # Write to a per-session temp file
  demo_dir <- file.path(tempdir(), "surveyframe-builder-demo")
  dir.create(demo_dir, recursive = TRUE, showWarnings = FALSE)
  demo_builder_path <- file.path(demo_dir, paste0("survey_builder_", name, ".html"))
  writeLines(builder_html, demo_builder_path, useBytes = FALSE)
  demo_builder_path
}
