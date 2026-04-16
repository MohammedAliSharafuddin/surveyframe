# inst/shiny/app.R
# SurveyStudio - build, edit, preview, and analyse surveyframe instruments.

library(shiny)
library(surveyframe)

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

builder_empty_state <- surveyframe:::sframe_builder_empty_state
builder_state_from_instrument <- surveyframe:::sframe_builder_state_from_instrument
builder_validate_draft <- surveyframe:::sframe_builder_validate_draft

status_badge <- function(ok, label_ok = "Ready", label_no = "Not ready") {
  if (ok) {
    tags$span(class = "badge badge-ok", label_ok)
  } else {
    tags$span(class = "badge badge-wait", label_no)
  }
}

trim_or_null <- function(x) {
  x <- trimws(x %||% "")
  if (nzchar(x)) x else NULL
}

parse_lines <- function(text) {
  if (is.null(text) || !nzchar(text)) {
    return(character(0))
  }
  values <- trimws(unlist(strsplit(text, "\n", fixed = TRUE), use.names = FALSE))
  values[nzchar(values)]
}

parse_csv <- function(text) {
  if (is.null(text) || !nzchar(trimws(text))) {
    return(character(0))
  }
  values <- trimws(unlist(strsplit(text, ",", fixed = TRUE), use.names = FALSE))
  values[nzchar(values)]
}

parse_choice_values <- function(text) {
  values <- parse_lines(text)
  if (length(values) == 0) {
    return(values)
  }
  type.convert(values, as.is = TRUE)
}

parse_branch_value <- function(text, operator) {
  raw <- trimws(text %||% "")
  if (!nzchar(raw)) {
    return(NULL)
  }
  if (identical(operator, "%in%")) {
    values <- parse_csv(raw)
    if (length(values) == 0) {
      return(NULL)
    }
    return(type.convert(values, as.is = TRUE))
  }
  type.convert(raw, as.is = TRUE)
}

parse_check_values <- function(text) {
  values <- parse_csv(text %||% "")
  if (length(values) == 0) {
    return(NULL)
  }
  type.convert(values, as.is = TRUE)
}

format_value <- function(x) {
  if (is.null(x) || length(x) == 0) {
    return("")
  }
  paste(as.character(x), collapse = ", ")
}

upsert_component <- function(components, component) {
  if (length(components) == 0) {
    return(list(component))
  }

  ids <- vapply(components, function(x) x$id, character(1))
  idx <- match(component$id, ids)
  if (is.na(idx)) {
    c(components, list(component))
  } else {
    components[[idx]] <- component
    components
  }
}

remove_component <- function(components, id) {
  if (length(components) == 0) {
    return(components)
  }
  Filter(function(component) !identical(component$id, id), components)
}

drop_item_from_builder <- function(builder, item_id) {
  builder$items <- remove_component(builder$items, item_id)

  if (length(builder$scales) > 0) {
    builder$scales <- Filter(function(scale) {
      scale$items <- setdiff(scale$items %||% character(0), item_id)
      scale$reverse_items <- intersect(scale$reverse_items %||% character(0), scale$items)
      length(scale$items) > 0
    }, builder$scales)
  }

  if (length(builder$branching) > 0) {
    builder$branching <- Filter(function(rule) {
      !identical(rule$item_id, item_id) && !identical(rule$depends_on, item_id)
    }, builder$branching)
  }

  if (length(builder$checks) > 0) {
    builder$checks <- Filter(function(check) !identical(check$item_id, item_id), builder$checks)
  }

  builder
}

optional_choices <- function(ids, none_label = "(None)") {
  choices <- stats::setNames(ids, ids)
  c(stats::setNames("", none_label), choices)
}

table_card <- function(title, headers, rows, empty_label) {
  tags$div(class = "card",
    tags$div(class = "card-title", title),
    if (length(rows) == 0) {
      tags$p(class = "hint", empty_label)
    } else {
      tags$table(class = "sf-table",
        tags$thead(tags$tr(do.call(tagList, lapply(headers, tags$th)))),
        tags$tbody(rows)
      )
    }
  )
}

initial_instrument <- shiny::getShinyOption("surveyframe_instrument")
initial_responses <- shiny::getShinyOption("surveyframe_responses")
initial_builder <- builder_state_from_instrument(initial_instrument)

initial_tab <- if (!is.null(initial_responses) && !is.null(initial_instrument)) {
  "quality"
} else if (!is.null(initial_instrument)) {
  "preview"
} else {
  "build"
}

tab_link_class <- function(tab) {
  if (identical(initial_tab, tab)) "active" else NULL
}

screen_class <- function(tab) {
  paste("screen", if (identical(initial_tab, tab)) "active")
}

ui <- fluidPage(
  tags$head(
    tags$title("SurveyStudio"),
    tags$style(HTML("
      body { font-family: 'Helvetica Neue', Arial, sans-serif;
             background: #f7f8fa; color: #1a1a2e; margin: 0; }
      .studio-shell { display: flex; min-height: 100vh; }
      .studio-sidebar {
        width: 240px; min-width: 240px; background: #1a1a2e;
        color: #c8ccd8; padding: 0; display: flex; flex-direction: column;
        position: fixed; top: 0; bottom: 0; left: 0; overflow-y: auto; z-index: 100;
      }
      .studio-logo {
        padding: 24px 20px 16px; font-size: 18px; font-weight: 700;
        color: #ffffff; letter-spacing: 0.02em; border-bottom: 1px solid #2e3250;
      }
      .studio-logo span { color: #5b8dee; }
      .studio-nav { list-style: none; margin: 0; padding: 12px 0; flex: 1; }
      .studio-nav-item a {
        display: flex; align-items: center; gap: 10px;
        padding: 10px 20px; color: #9aa0b8; text-decoration: none;
        font-size: 14px; border-left: 3px solid transparent;
        transition: background 0.15s, color 0.15s;
      }
      .studio-nav-item a:hover,
      .studio-nav-item a.active {
        background: #22274a; color: #ffffff; border-left-color: #5b8dee;
      }
      .studio-status {
        padding: 16px 20px; font-size: 12px;
        border-top: 1px solid #2e3250; color: #9aa0b8;
      }
      .studio-main {
        margin-left: 240px; flex: 1; padding: 32px;
        min-height: 100vh; box-sizing: border-box;
      }
      .screen { display: none; }
      .screen.active { display: block; }
      .card {
        background: #ffffff; border-radius: 8px;
        box-shadow: 0 1px 4px rgba(0,0,0,0.08);
        padding: 24px; margin-bottom: 20px;
      }
      .card-title {
        font-size: 16px; font-weight: 600; margin: 0 0 16px;
        color: #1a1a2e;
      }
      .card-actions {
        display: flex; gap: 10px; flex-wrap: wrap; margin-top: 12px;
      }
      .badge {
        display: inline-block; padding: 3px 10px; border-radius: 12px;
        font-size: 12px; font-weight: 600;
      }
      .badge-ok { background: #e6f4ea; color: #2e7d32; }
      .badge-wait { background: #fef3cd; color: #856404; }
      .badge-warn { background: #fde8e8; color: #b91c1c; }
      .stat-row { display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 16px; }
      .stat-box {
        flex: 1; min-width: 120px; background: #f7f8fa; border-radius: 8px;
        padding: 16px; text-align: center;
      }
      .stat-box .stat-val { font-size: 28px; font-weight: 700; color: #1a1a2e; }
      .stat-box .stat-lbl { font-size: 12px; color: #6b718e; margin-top: 4px; }
      table.sf-table { width: 100%; border-collapse: collapse; font-size: 14px; }
      .sf-table th {
        background: #f7f8fa; text-align: left; padding: 8px 12px;
        font-weight: 600; color: #444; border-bottom: 2px solid #e0e3ea;
      }
      .sf-table td { padding: 8px 12px; border-bottom: 1px solid #f0f1f4; vertical-align: top; }
      .sf-table tr:last-child td { border-bottom: none; }
      .btn-primary {
        background: #5b8dee; color: #fff; border: none; border-radius: 6px;
        padding: 9px 20px; font-size: 14px; cursor: pointer; font-weight: 600;
      }
      .btn-primary:hover { background: #4a7de0; }
      .btn-outline {
        background: transparent; color: #5b8dee; border: 1.5px solid #5b8dee;
        border-radius: 6px; padding: 8px 18px; font-size: 14px;
        cursor: pointer; font-weight: 600;
      }
      .btn-outline:hover { background: #eef3fd; }
      h2.screen-title {
        font-size: 22px; font-weight: 700; margin: 0 0 24px; color: #1a1a2e;
      }
      .hint { font-size: 13px; color: #6b718e; margin-top: 6px; }
      .problem-list { margin: 0; padding-left: 18px; }
      .problem-list li { margin-bottom: 6px; }
      #survey_preview_frame {
        border: 1px solid #e0e3ea; border-radius: 8px; padding: 24px; background: #fff;
      }
    "))
  ),
  tags$div(class = "studio-shell",
    tags$div(class = "studio-sidebar",
      tags$div(class = "studio-logo", "Survey", tags$span("Studio")),
      tags$ul(class = "studio-nav",
        tags$li(class = "studio-nav-item",
          tags$a(href = "#", `data-tab` = "build",
                 class = tab_link_class("build"), "Build Survey")),
        tags$li(class = "studio-nav-item",
          tags$a(href = "#", `data-tab` = "open",
                 class = tab_link_class("open"), "Open Instrument")),
        tags$li(class = "studio-nav-item",
          tags$a(href = "#", `data-tab` = "preview",
                 class = tab_link_class("preview"), "Preview Survey")),
        tags$li(class = "studio-nav-item",
          tags$a(href = "#", `data-tab` = "responses",
                 class = tab_link_class("responses"), "Upload Responses")),
        tags$li(class = "studio-nav-item",
          tags$a(href = "#", `data-tab` = "quality",
                 class = tab_link_class("quality"), "Quality Dashboard")),
        tags$li(class = "studio-nav-item",
          tags$a(href = "#", `data-tab` = "reliability",
                 class = tab_link_class("reliability"), "Reliability")),
        tags$li(class = "studio-nav-item",
          tags$a(href = "#", `data-tab` = "export",
                 class = tab_link_class("export"), "Export"))
      ),
      tags$div(class = "studio-status", uiOutput("sidebar_status"))
    ),
    tags$div(class = "studio-main",
      tags$script(HTML("
        $(document).on('click', '[data-tab]', function(e) {
          e.preventDefault();
          var tab = $(this).data('tab');
          $('.studio-nav-item a').removeClass('active');
          $(this).addClass('active');
          $('.screen').removeClass('active');
          $('#screen-' + tab).addClass('active');
          Shiny.setInputValue('current_tab', tab, {priority: 'event'});
        });

        Shiny.addCustomMessageHandler('surveyframe-switch-tab', function(tab) {
          var link = $('[data-tab=\"' + tab + '\"]');
          if (link.length === 0) return;
          $('.studio-nav-item a').removeClass('active');
          link.addClass('active');
          $('.screen').removeClass('active');
          $('#screen-' + tab).addClass('active');
          Shiny.setInputValue('current_tab', tab, {priority: 'event'});
        });
      ")),

      tags$div(id = "screen-build", class = screen_class("build"),
        tags$h2(class = "screen-title", "Build Survey"),
        fluidRow(
          column(7,
            tags$div(class = "card",
              tags$div(class = "card-title", "Survey metadata"),
              textInput("draft_title", "Survey title", value = initial_builder$meta$title),
              fluidRow(
                column(6, textInput("draft_version", "Version", value = initial_builder$meta$version)),
                column(6, textInput("draft_languages", "Languages", value = format_value(initial_builder$meta$languages)))
              ),
              textInput("draft_authors", "Authors", value = format_value(initial_builder$meta$authors)),
              textAreaInput("draft_description", "Description",
                            value = initial_builder$meta$description %||% "", rows = 4),
              tags$div(class = "card-actions",
                actionButton("go_preview_btn", "Preview Draft", class = "btn-primary"),
                actionButton("new_survey_btn", "New Survey", class = "btn-outline")
              )
            ),

            tags$div(class = "card",
              tags$div(class = "card-title", "Choice sets"),
              fluidRow(
                column(4, textInput("choice_id", "Choice set ID", placeholder = "agree5")),
                column(4, checkboxInput("choice_allow_other", "Allow 'Other'", value = FALSE)),
                column(4, checkboxInput("choice_randomise", "Randomise order", value = FALSE))
              ),
              fluidRow(
                column(6, textAreaInput("choice_values", "Stored values", rows = 5,
                                        placeholder = "One value per line")),
                column(6, textAreaInput("choice_labels", "Display labels", rows = 5,
                                        placeholder = "One label per line"))
              ),
              tags$div(class = "card-actions",
                actionButton("add_choice_btn", "Save Choice Set", class = "btn-primary"),
                selectInput("remove_choice_id", "Delete choice set", choices = character(0)),
                actionButton("remove_choice_btn", "Delete", class = "btn-outline")
              )
            ),
            uiOutput("choices_table"),

            tags$div(class = "card",
              tags$div(class = "card-title", "Items"),
              fluidRow(
                column(4, textInput("item_id", "Item ID", placeholder = "sat_1")),
                column(8, textInput("item_label", "Question text",
                                    placeholder = "Overall, how satisfied are you?"))
              ),
              fluidRow(
                column(4, selectInput("item_type", "Response type",
                                      choices = c("single_choice", "multiple_choice",
                                                  "likert", "numeric", "text",
                                                  "textarea", "date"))),
                column(4, selectInput("item_choice_set", "Choice set", choices = character(0))),
                column(4, checkboxInput("item_required", "Required", value = FALSE))
              ),
              textInput("item_placeholder", "Placeholder", value = ""),
              textAreaInput("item_help", "Help text", value = "", rows = 3),
              tags$div(class = "card-actions",
                actionButton("add_item_btn", "Save Item", class = "btn-primary"),
                selectInput("remove_item_id", "Delete item", choices = character(0)),
                actionButton("remove_item_btn", "Delete", class = "btn-outline")
              )
            ),
            uiOutput("items_table")
          ),

          column(5,
            uiOutput("builder_summary_card"),
            uiOutput("builder_validation_card"),

            tags$div(class = "card",
              tags$div(class = "card-title", "Scales"),
              textInput("scale_id", "Scale ID", placeholder = "satisfaction"),
              textInput("scale_label", "Scale label", placeholder = "Satisfaction"),
              checkboxGroupInput("scale_items", "Items", choices = character(0)),
              radioButtons("scale_method", "Scoring method",
                           choices = c("mean", "sum"), inline = TRUE),
              numericInput("scale_min_valid", "Minimum valid items",
                           value = NA, min = 1, step = 1),
              checkboxGroupInput("scale_reverse_items", "Reverse-coded items", choices = character(0)),
              tags$div(class = "card-actions",
                actionButton("add_scale_btn", "Save Scale", class = "btn-primary"),
                selectInput("remove_scale_id", "Delete scale", choices = character(0)),
                actionButton("remove_scale_btn", "Delete", class = "btn-outline")
              )
            ),
            uiOutput("scales_table"),

            tags$div(class = "card",
              tags$div(class = "card-title", "Branching rules"),
              selectInput("branch_item_id", "Target item", choices = character(0)),
              selectInput("branch_depends_on", "Depends on", choices = character(0)),
              fluidRow(
                column(6, selectInput("branch_operator", "Operator",
                                      choices = c("==", "!=", "%in%", ">", ">=", "<", "<="))),
                column(6, selectInput("branch_action", "Action", choices = c("show", "hide")))
              ),
              textInput("branch_value", "Match value", placeholder = "Use commas for %in%"),
              tags$div(class = "card-actions",
                actionButton("add_branch_btn", "Save Rule", class = "btn-primary"),
                selectInput("remove_branch_key", "Delete rule", choices = character(0)),
                actionButton("remove_branch_btn", "Delete", class = "btn-outline")
              )
            ),
            uiOutput("branching_table"),

            tags$div(class = "card",
              tags$div(class = "card-title", "Quality checks"),
              textInput("check_id", "Check ID", placeholder = "attn_1"),
              selectInput("check_item_id", "Check item", choices = character(0)),
              fluidRow(
                column(6, selectInput("check_type", "Type",
                                      choices = c("attention", "instructional", "trap"))),
                column(6, selectInput("check_fail_action", "Fail action",
                                      choices = c("flag", "exclude")))
              ),
              textInput("check_label", "Label", value = ""),
              textInput("check_pass_values", "Pass values", placeholder = "4 or yes,no"),
              textAreaInput("check_notes", "Notes", value = "", rows = 3),
              tags$div(class = "card-actions",
                actionButton("add_check_btn", "Save Check", class = "btn-primary"),
                selectInput("remove_check_id", "Delete check", choices = character(0)),
                actionButton("remove_check_btn", "Delete", class = "btn-outline")
              )
            ),
            uiOutput("checks_table")
          )
        )
      ),

      tags$div(id = "screen-open", class = screen_class("open"),
        tags$h2(class = "screen-title", "Open Instrument"),
        tags$div(class = "card",
          tags$div(class = "card-title", "Load an existing .sframe"),
          fileInput("instr_file", NULL,
                    accept = ".sframe",
                    buttonLabel = "Browse .sframe file",
                    placeholder = "No file selected"),
          tags$p(class = "hint",
            "Loaded instruments are copied into the builder so you can edit, preview, and re-export them."),
          uiOutput("open_status")
        ),
        uiOutput("instrument_summary_card")
      ),

      tags$div(id = "screen-preview", class = screen_class("preview"),
        tags$h2(class = "screen-title", "Preview Survey"),
        uiOutput("preview_gate"),
        tags$div(id = "survey_preview_frame", uiOutput("survey_preview_items"))
      ),

      tags$div(id = "screen-responses", class = screen_class("responses"),
        tags$h2(class = "screen-title", "Upload Responses"),
        uiOutput("responses_gate"),
        tags$div(class = "card",
          tags$div(class = "card-title", "Response data"),
          fileInput("resp_file", NULL,
                    accept = ".csv",
                    buttonLabel = "Browse CSV file",
                    placeholder = "No file selected"),
          fluidRow(
            column(4, textInput("resp_id_col", "Respondent ID column", placeholder = "e.g. id")),
            column(4, textInput("resp_time_col", "Submitted-at column", placeholder = "e.g. submitted_at")),
            column(4, checkboxInput("resp_strict", "Strict column check", value = TRUE))
          ),
          actionButton("load_responses_btn", "Load responses", class = "btn-primary")
        ),
        uiOutput("responses_summary_card")
      ),

      tags$div(id = "screen-quality", class = screen_class("quality"),
        tags$h2(class = "screen-title", "Quality Dashboard"),
        uiOutput("quality_gate"),
        uiOutput("quality_output")
      ),

      tags$div(id = "screen-reliability", class = screen_class("reliability"),
        tags$h2(class = "screen-title", "Reliability"),
        uiOutput("reliability_gate"),
        uiOutput("reliability_output")
      ),

      tags$div(id = "screen-export", class = screen_class("export"),
        tags$h2(class = "screen-title", "Export"),
        uiOutput("export_gate"),
        tags$div(class = "card",
          tags$div(class = "card-title", "Instrument file"),
          tags$p(class = "hint",
            "Download the current validated draft as a .sframe file."),
          downloadButton("download_sframe_btn", "Download .sframe", class = "btn-primary")
        ),
        tags$div(class = "card",
          tags$div(class = "card-title", "Report contents"),
          checkboxInput("rpt_codebook", "Include codebook", value = TRUE),
          checkboxInput("rpt_quality", "Include quality report", value = TRUE),
          checkboxInput("rpt_reliability", "Include reliability", value = TRUE),
          tags$br(),
          downloadButton("download_report_btn", "Generate HTML report", class = "btn-primary"),
          tags$p(class = "hint",
            "Requires the quarto package. The report is a self-contained HTML file.")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  rv <- reactiveValues(
    builder = initial_builder,
    instrument = initial_instrument,
    responses = NULL
  )

  set_builder_state <- function(state) {
    rv$builder <- state
    invisible(state)
  }

  if (!is.null(initial_responses) && !is.null(rv$instrument)) {
    tryCatch({
      rv$responses <- surveyframe::read_responses(initial_responses, rv$instrument)
    }, error = function(e) NULL)
  }

  switch_tab <- function(tab) {
    session$sendCustomMessage("surveyframe-switch-tab", tab)
  }

  sync_builder_inputs <- function(state) {
    updateTextInput(session, "draft_title", value = state$meta$title %||% "Untitled Survey")
    updateTextInput(session, "draft_version", value = state$meta$version %||% "0.1.0")
    updateTextAreaInput(session, "draft_description", value = state$meta$description %||% "")
    updateTextInput(session, "draft_authors", value = format_value(state$meta$authors))
    updateTextInput(session, "draft_languages", value = format_value(state$meta$languages))
  }

  builder_meta <- reactive({
    languages <- parse_csv(input$draft_languages %||% "")
    list(
      title = trimws(input$draft_title %||% rv$builder$meta$title %||% "Untitled Survey"),
      version = trimws(input$draft_version %||% rv$builder$meta$version %||% "0.1.0"),
      description = trim_or_null(input$draft_description),
      authors = {
        values <- parse_csv(input$draft_authors %||% "")
        if (length(values) == 0) NULL else values
      },
      languages = if (length(languages) == 0) "en" else languages
    )
  })

  draft_result <- reactive({
    builder_validate_draft(
      meta = builder_meta(),
      choices = rv$builder$choices,
      items = rv$builder$items,
      scales = rv$builder$scales,
      branching = rv$builder$branching,
      checks = rv$builder$checks
    )
  })

  preview_instrument <- reactive({
    draft_result()$instrument
  })

  observe({
    if (draft_result()$valid) {
      rv$instrument <- draft_result()$instrument
    }
  })

  observe({
    choice_ids <- vapply(rv$builder$choices, function(choice) choice$id, character(1))
    updateSelectInput(
      session,
      "item_choice_set",
      choices = optional_choices(choice_ids),
      selected = if ((input$item_choice_set %||% "") %in% c("", choice_ids)) input$item_choice_set else ""
    )
    updateSelectInput(session, "remove_choice_id", choices = optional_choices(choice_ids, "(Select one)"))
  })

  observe({
    item_ids <- vapply(rv$builder$items, function(item) item$id, character(1))
    updateSelectInput(session, "remove_item_id", choices = optional_choices(item_ids, "(Select one)"))
    updateCheckboxGroupInput(
      session,
      "scale_items",
      choices = stats::setNames(item_ids, item_ids),
      selected = intersect(input$scale_items %||% character(0), item_ids)
    )
    current_scale_items <- intersect(input$scale_items %||% character(0), item_ids)
    updateCheckboxGroupInput(
      session,
      "scale_reverse_items",
      choices = stats::setNames(current_scale_items, current_scale_items),
      selected = intersect(input$scale_reverse_items %||% character(0), current_scale_items)
    )
    updateSelectInput(session, "branch_item_id", choices = optional_choices(item_ids, "(Select one)"))
    updateSelectInput(session, "branch_depends_on", choices = optional_choices(item_ids, "(Select one)"))
    branch_labels <- if (length(rv$builder$branching) == 0) {
      character(0)
    } else {
      vapply(
        rv$builder$branching,
        function(rule) paste(rule$item_id, rule$action, "when", rule$depends_on, rule$operator, format_value(rule$value)),
        character(1)
      )
    }
    branch_keys <- if (length(rv$builder$branching) == 0) character(0) else seq_along(rv$builder$branching)
    updateSelectInput(session, "remove_branch_key",
                      choices = c(stats::setNames("", "(Select one)"), stats::setNames(as.character(branch_keys), branch_labels)))
    updateSelectInput(session, "check_item_id", choices = optional_choices(item_ids, "(Select one)"))
  })

  observe({
    scale_ids <- vapply(rv$builder$scales, function(scale) scale$id, character(1))
    updateSelectInput(session, "remove_scale_id", choices = optional_choices(scale_ids, "(Select one)"))
  })

  observe({
    check_ids <- vapply(rv$builder$checks, function(check) check$id, character(1))
    updateSelectInput(session, "remove_check_id", choices = optional_choices(check_ids, "(Select one)"))
  })

  session$onFlushed(function() {
    target_tab <- if (!is.null(shiny::isolate(rv$responses))) {
      "quality"
    } else if (!is.null(shiny::isolate(rv$instrument))) {
      "preview"
    } else {
      "build"
    }
    switch_tab(target_tab)
  }, once = TRUE)

  observeEvent(input$new_survey_btn, {
    rv$builder <- builder_empty_state()
    rv$instrument <- NULL
    rv$responses <- NULL
    sync_builder_inputs(rv$builder)
    showNotification("Started a new survey draft.", type = "message")
    switch_tab("build")
  })

  observeEvent(input$go_preview_btn, {
    switch_tab("preview")
  })

  observeEvent(input$add_choice_btn, {
    choice_id <- trim_or_null(input$choice_id)
    values <- parse_choice_values(input$choice_values)
    labels <- parse_lines(input$choice_labels)

    if (is.null(choice_id)) {
      showNotification("Choice set ID is required.", type = "error")
      return()
    }
    if (length(values) == 0 || length(labels) == 0) {
      showNotification("Enter at least one value and label.", type = "error")
      return()
    }
    if (length(values) != length(labels)) {
      showNotification("Choice set values and labels must have the same length.", type = "error")
      return()
    }

    choice <- sf_choices(
      id = choice_id,
      values = values,
      labels = labels,
      allow_other = isTRUE(input$choice_allow_other),
      randomise = isTRUE(input$choice_randomise)
    )
    existing <- choice_id %in% vapply(rv$builder$choices, function(x) x$id, character(1))
    state <- rv$builder
    state$choices <- upsert_component(state$choices, choice)
    set_builder_state(state)
    showNotification(
      if (existing) "Choice set updated." else "Choice set added.",
      type = "message"
    )
  })

  observeEvent(input$remove_choice_btn, {
    choice_id <- trim_or_null(input$remove_choice_id)
    if (is.null(choice_id)) {
      return()
    }
    in_use <- vapply(rv$builder$items, function(item) identical(item$choice_set, choice_id), logical(1))
    if (any(in_use)) {
      showNotification("That choice set is still used by one or more items.", type = "error")
      return()
    }
    state <- rv$builder
    state$choices <- remove_component(state$choices, choice_id)
    set_builder_state(state)
    showNotification("Choice set deleted.", type = "message")
  })

  observeEvent(input$add_item_btn, {
    item_id <- trim_or_null(input$item_id)
    item_label <- trim_or_null(input$item_label)
    item_type <- input$item_type %||% "text"
    choice_set <- trim_or_null(input$item_choice_set)

    if (is.null(item_id) || is.null(item_label)) {
      showNotification("Item ID and question text are required.", type = "error")
      return()
    }
    if (item_type %in% c("single_choice", "multiple_choice", "likert") && is.null(choice_set)) {
      showNotification("Choice items need a choice set.", type = "error")
      return()
    }

    item <- sf_item(
      id = item_id,
      label = item_label,
      type = item_type,
      required = isTRUE(input$item_required),
      choice_set = if (item_type %in% c("single_choice", "multiple_choice", "likert")) choice_set else NULL,
      help = trim_or_null(input$item_help),
      placeholder = if (item_type %in% c("text", "textarea")) trim_or_null(input$item_placeholder) else NULL
    )

    existing <- item_id %in% vapply(rv$builder$items, function(x) x$id, character(1))
    state <- rv$builder
    state$items <- upsert_component(state$items, item)
    set_builder_state(state)
    showNotification(if (existing) "Item updated." else "Item added.", type = "message")
  })

  observeEvent(input$remove_item_btn, {
    item_id <- trim_or_null(input$remove_item_id)
    if (is.null(item_id)) {
      return()
    }
    rv$builder <- drop_item_from_builder(rv$builder, item_id)
    showNotification("Item deleted. Related scale membership, branching, and checks were updated.", type = "message")
  })

  observeEvent(input$add_scale_btn, {
    scale_id <- trim_or_null(input$scale_id)
    scale_label <- trim_or_null(input$scale_label)
    scale_items <- input$scale_items %||% character(0)
    min_valid <- suppressWarnings(as.integer(input$scale_min_valid))

    if (is.null(scale_id) || is.null(scale_label)) {
      showNotification("Scale ID and label are required.", type = "error")
      return()
    }
    if (length(scale_items) == 0) {
      showNotification("Select at least one item for the scale.", type = "error")
      return()
    }
    if (is.na(min_valid) || min_valid < 1) {
      min_valid <- NULL
    }
    if (!is.null(min_valid) && min_valid > length(scale_items)) {
      showNotification("Minimum valid items cannot exceed the number of scale items.", type = "error")
      return()
    }

    scale <- sf_scale(
      id = scale_id,
      label = scale_label,
      items = scale_items,
      method = input$scale_method %||% "mean",
      min_valid = min_valid,
      reverse_items = input$scale_reverse_items %||% NULL
    )
    existing <- scale_id %in% vapply(rv$builder$scales, function(x) x$id, character(1))
    state <- rv$builder
    state$scales <- upsert_component(state$scales, scale)
    set_builder_state(state)
    showNotification(if (existing) "Scale updated." else "Scale added.", type = "message")
  })

  observeEvent(input$remove_scale_btn, {
    scale_id <- trim_or_null(input$remove_scale_id)
    if (is.null(scale_id)) {
      return()
    }
    state <- rv$builder
    state$scales <- remove_component(state$scales, scale_id)
    set_builder_state(state)
    showNotification("Scale deleted.", type = "message")
  })

  observeEvent(input$add_branch_btn, {
    target <- trim_or_null(input$branch_item_id)
    depends_on <- trim_or_null(input$branch_depends_on)
    operator <- input$branch_operator %||% "=="
    value <- parse_branch_value(input$branch_value, operator)

    if (is.null(target) || is.null(depends_on)) {
      showNotification("Select both a target item and a controlling item.", type = "error")
      return()
    }
    if (identical(target, depends_on)) {
      showNotification("A branching rule cannot depend on the same item it targets.", type = "error")
      return()
    }
    if (is.null(value)) {
      showNotification("Enter a match value for the branching rule.", type = "error")
      return()
    }

    rule <- sf_branch(
      item_id = target,
      depends_on = depends_on,
      operator = operator,
      value = value,
      action = input$branch_action %||% "show"
    )

    branch_key <- paste(target, depends_on, operator, input$branch_action %||% "show", sep = "|")
    existing_keys <- if (length(rv$builder$branching) == 0) {
      character(0)
    } else {
      vapply(rv$builder$branching, function(x) {
        paste(x$item_id, x$depends_on, x$operator, x$action, sep = "|")
      }, character(1))
    }

    if (branch_key %in% existing_keys) {
      idx <- match(branch_key, existing_keys)
      state <- rv$builder
      state$branching[[idx]] <- rule
      set_builder_state(state)
      showNotification("Branching rule updated.", type = "message")
    } else {
      state <- rv$builder
      state$branching <- c(state$branching, list(rule))
      set_builder_state(state)
      showNotification("Branching rule added.", type = "message")
    }
  })

  observeEvent(input$remove_branch_btn, {
    branch_key <- suppressWarnings(as.integer(input$remove_branch_key %||% NA))
    if (is.na(branch_key) || branch_key < 1 || branch_key > length(rv$builder$branching)) {
      return()
    }
    state <- rv$builder
    state$branching <- state$branching[-branch_key]
    set_builder_state(state)
    showNotification("Branching rule deleted.", type = "message")
  })

  observeEvent(input$add_check_btn, {
    check_id <- trim_or_null(input$check_id)
    item_id <- trim_or_null(input$check_item_id)
    check_type <- input$check_type %||% "attention"
    pass_values <- parse_check_values(input$check_pass_values)

    if (is.null(check_id) || is.null(item_id)) {
      showNotification("Check ID and check item are required.", type = "error")
      return()
    }
    if (check_type %in% c("attention", "instructional") && is.null(pass_values)) {
      showNotification("Enter at least one pass value for this check.", type = "error")
      return()
    }

    check <- sf_check(
      id = check_id,
      item_id = item_id,
      type = check_type,
      pass_values = pass_values,
      fail_action = input$check_fail_action %||% "flag",
      label = trim_or_null(input$check_label),
      notes = trim_or_null(input$check_notes)
    )

    existing <- check_id %in% vapply(rv$builder$checks, function(x) x$id, character(1))
    state <- rv$builder
    state$checks <- upsert_component(state$checks, check)
    set_builder_state(state)
    showNotification(if (existing) "Check updated." else "Check added.", type = "message")
  })

  observeEvent(input$remove_check_btn, {
    check_id <- trim_or_null(input$remove_check_id)
    if (is.null(check_id)) {
      return()
    }
    state <- rv$builder
    state$checks <- remove_component(state$checks, check_id)
    set_builder_state(state)
    showNotification("Check deleted.", type = "message")
  })

  observeEvent(input$instr_file, {
    req(input$instr_file)
    tryCatch({
      loaded <- surveyframe::read_sframe(input$instr_file$datapath)
      rv$builder <- builder_state_from_instrument(loaded)
      rv$instrument <- loaded
      rv$responses <- NULL
      sync_builder_inputs(rv$builder)
      showNotification("Instrument loaded into the builder.", type = "message")
      switch_tab("build")
    }, error = function(e) {
      showNotification(paste("Error:", conditionMessage(e)), type = "error")
    })
  })

  observeEvent(input$load_responses_btn, {
    req(input$resp_file, rv$instrument)
    id_col <- trim_or_null(input$resp_id_col)
    time_col <- trim_or_null(input$resp_time_col)
    tryCatch({
      rv$responses <- surveyframe::read_responses(
        x = input$resp_file$datapath,
        instrument = rv$instrument,
        respondent_id = id_col,
        submitted_at = time_col,
        strict = isTRUE(input$resp_strict)
      )
      showNotification(paste(nrow(rv$responses), "responses loaded."), type = "message")
      switch_tab("quality")
    }, error = function(e) {
      showNotification(paste("Error:", conditionMessage(e)), type = "error")
    })
  })

  output$sidebar_status <- renderUI({
    draft <- draft_result()
    tagList(
      tags$div(if (draft$valid) "Draft ready" else "Draft needs fixes"),
      tags$div(if (!is.null(rv$instrument)) "Instrument ready" else "No valid instrument"),
      tags$div(if (!is.null(rv$responses)) "Responses loaded" else "No responses")
    )
  })

  output$builder_summary_card <- renderUI({
    draft <- draft_result()
    tags$div(class = "card",
      tags$div(class = "card-title", draft$instrument$meta$title %||% "Survey draft"),
      tags$div(class = "stat-row",
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", length(rv$builder$choices)),
          tags$div(class = "stat-lbl", "Choice sets")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", length(rv$builder$items)),
          tags$div(class = "stat-lbl", "Items")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", length(rv$builder$scales)),
          tags$div(class = "stat-lbl", "Scales")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", if (draft$valid) "Ready" else "Fix"),
          tags$div(class = "stat-lbl", "Status"))
      )
    )
  })

  output$builder_validation_card <- renderUI({
    draft <- draft_result()
    tags$div(class = "card",
      tags$div(class = "card-title", "Draft validation"),
      if (draft$valid) {
        tagList(
          tags$p(status_badge(TRUE, "Validated", "Needs fixes")),
          tags$p(class = "hint",
            "This draft can be previewed, saved as a .sframe, and used for downstream analysis.")
        )
      } else {
        tagList(
          tags$p(status_badge(FALSE, "Validated", "Needs fixes")),
          tags$ul(class = "problem-list",
            do.call(tagList, lapply(draft$problems, tags$li))
          )
        )
      }
    )
  })

  output$choices_table <- renderUI({
    rows <- lapply(rv$builder$choices, function(choice) {
      tags$tr(
        tags$td(choice$id),
        tags$td(length(choice$values)),
        tags$td(format_value(choice$labels)),
        tags$td(if (isTRUE(choice$allow_other)) "Yes" else "No"),
        tags$td(if (isTRUE(choice$randomise)) "Yes" else "No")
      )
    })
    table_card("Current choice sets",
      headers = c("ID", "Options", "Labels", "Other", "Randomise"),
      rows = rows,
      empty_label = "No choice sets yet.")
  })

  output$items_table <- renderUI({
    rows <- lapply(rv$builder$items, function(item) {
      tags$tr(
        tags$td(item$id),
        tags$td(item$type),
        tags$td(item$choice_set %||% ""),
        tags$td(if (isTRUE(item$required)) "Yes" else "No"),
        tags$td(item$label)
      )
    })
    table_card("Current items",
      headers = c("ID", "Type", "Choice set", "Required", "Label"),
      rows = rows,
      empty_label = "No items yet.")
  })

  output$scales_table <- renderUI({
    rows <- lapply(rv$builder$scales, function(scale) {
      tags$tr(
        tags$td(scale$id),
        tags$td(scale$label),
        tags$td(format_value(scale$items)),
        tags$td(scale$method),
        tags$td(scale$min_valid %||% ""),
        tags$td(format_value(scale$reverse_items))
      )
    })
    table_card("Current scales",
      headers = c("ID", "Label", "Items", "Method", "Min valid", "Reverse"),
      rows = rows,
      empty_label = "No scales yet.")
  })

  output$branching_table <- renderUI({
    rows <- lapply(rv$builder$branching, function(rule) {
      tags$tr(
        tags$td(rule$item_id),
        tags$td(rule$depends_on),
        tags$td(rule$operator),
        tags$td(format_value(rule$value)),
        tags$td(rule$action)
      )
    })
    table_card("Current branching rules",
      headers = c("Target", "Depends on", "Operator", "Value", "Action"),
      rows = rows,
      empty_label = "No branching rules yet.")
  })

  output$checks_table <- renderUI({
    rows <- lapply(rv$builder$checks, function(check) {
      tags$tr(
        tags$td(check$id),
        tags$td(check$item_id),
        tags$td(check$type),
        tags$td(format_value(check$pass_values)),
        tags$td(check$fail_action)
      )
    })
    table_card("Current checks",
      headers = c("ID", "Item", "Type", "Pass values", "Fail action"),
      rows = rows,
      empty_label = "No checks yet.")
  })

  output$open_status <- renderUI({
    if (!is.null(rv$instrument)) {
      status_badge(TRUE, "Loaded", "No instrument loaded")
    } else {
      status_badge(FALSE, "Loaded", "No instrument loaded")
    }
  })

  output$instrument_summary_card <- renderUI({
    req(rv$instrument)
    instr <- rv$instrument
    tags$div(class = "card",
      tags$div(class = "card-title", instr$meta$title),
      tags$div(class = "stat-row",
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", length(instr$items)),
          tags$div(class = "stat-lbl", "Items")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", length(instr$scales)),
          tags$div(class = "stat-lbl", "Scales")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", instr$meta$version),
          tags$div(class = "stat-lbl", "Version")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val",
                   if (isTRUE(instr$meta$validated)) "Valid" else "Draft"),
          tags$div(class = "stat-lbl", "Status"))
      )
    )
  })

  output$preview_gate <- renderUI({
    draft <- draft_result()
    if (length(draft$instrument$items) == 0) {
      return(tags$div(class = "card",
        "Add at least one item in Build Survey before previewing."))
    }
    if (!draft$valid) {
      return(tags$div(class = "card",
        tags$p("The current draft has validation issues. Preview is still shown so you can inspect the question flow."),
        tags$ul(class = "problem-list", do.call(tagList, lapply(draft$problems, tags$li)))
      ))
    }
    NULL
  })

  output$survey_preview_items <- renderUI({
    instr <- preview_instrument()
    req(instr)

    choices_lookup <- stats::setNames(
      lapply(instr$choices, function(cs) {
        stats::setNames(as.character(cs$values), cs$labels)
      }),
      vapply(instr$choices, function(cs) cs$id, character(1))
    )

    branch_lookup <- list()
    for (rule in instr$branching) {
      branch_lookup[[rule$item_id]] <- rule
    }

    items_ui <- lapply(instr$items, function(item) {
      rule <- branch_lookup[[item$id]]
      if (!is.null(rule)) {
        dep_val <- input[[rule$depends_on]]
        visible <- switch(rule$operator,
          "==" = identical(dep_val, rule$value),
          "!=" = !identical(dep_val, rule$value),
          "%in%" = length(dep_val) > 0 && any(dep_val %in% rule$value),
          ">" = suppressWarnings(as.numeric(dep_val) > as.numeric(rule$value)),
          ">=" = suppressWarnings(as.numeric(dep_val) >= as.numeric(rule$value)),
          "<" = suppressWarnings(as.numeric(dep_val) < as.numeric(rule$value)),
          "<=" = suppressWarnings(as.numeric(dep_val) <= as.numeric(rule$value)),
          FALSE
        )
        visible <- isTRUE(visible)
        if (identical(rule$action, "hide")) {
          visible <- !visible
        }
        if (!visible) {
          return(NULL)
        }
      }

      cs <- if (!is.null(item$choice_set) && nzchar(item$choice_set)) {
        choices_lookup[[item$choice_set]]
      } else {
        NULL
      }
      input_widget <- switch(
        item$type,
        single_choice = radioButtons(item$id, item$label, choices = cs %||% character(0)),
        multiple_choice = checkboxGroupInput(item$id, item$label, choices = cs %||% character(0)),
        likert = radioButtons(item$id, item$label, choices = cs %||% character(0), inline = TRUE),
        numeric = numericInput(item$id, item$label, value = NA),
        text = textInput(item$id, item$label, placeholder = item$placeholder %||% ""),
        textarea = textAreaInput(item$id, item$label, placeholder = item$placeholder %||% ""),
        date = dateInput(item$id, item$label),
        textInput(item$id, item$label)
      )

      tagList(
        tags$div(style = "margin-bottom: 20px;",
          input_widget,
          if (!is.null(item$help)) tags$p(class = "hint", item$help)
        )
      )
    })

    tagList(
      tags$p(class = "hint", style = "margin-bottom: 16px;",
        "This is a read-only preview. Responses entered here are not saved."),
      do.call(tagList, items_ui)
    )
  })

  output$responses_gate <- renderUI({
    if (is.null(rv$instrument)) {
      tags$div(class = "card",
        "Build or open a valid instrument before uploading responses.")
    }
  })

  output$responses_summary_card <- renderUI({
    req(rv$responses)
    tags$div(class = "card",
      tags$div(class = "card-title", "Loaded response data"),
      tags$div(class = "stat-row",
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", nrow(rv$responses)),
          tags$div(class = "stat-lbl", "Respondents")),
        tags$div(class = "stat-box",
          tags$div(class = "stat-val", ncol(rv$responses)),
          tags$div(class = "stat-lbl", "Columns"))
      )
    )
  })

  output$quality_gate <- renderUI({
    if (is.null(rv$instrument) || is.null(rv$responses)) {
      tags$div(class = "card",
        "Build or open a valid instrument and load responses before running quality checks.")
    }
  })

  quality_result <- reactive({
    req(rv$instrument, rv$responses)
    id_col <- trim_or_null(input$resp_id_col)
    surveyframe::quality_report(rv$responses, rv$instrument, respondent_id = id_col)
  })

  output$quality_output <- renderUI({
    req(rv$instrument, rv$responses)
    qr <- quality_result()
    tagList(
      tags$div(class = "card",
        tags$div(class = "card-title", "Summary"),
        tags$div(class = "stat-row",
          tags$div(class = "stat-box",
            tags$div(class = "stat-val", qr$summary$n_respondents),
            tags$div(class = "stat-lbl", "Respondents")),
          tags$div(class = "stat-box",
            tags$div(class = "stat-val", qr$summary$n_items),
            tags$div(class = "stat-lbl", "Items")),
          tags$div(class = "stat-box",
            tags$div(class = "stat-val", sprintf("%.1f%%", qr$summary$flag_rate * 100)),
            tags$div(class = "stat-lbl", "Flagged"))
        )
      ),
      if (length(qr$attention) > 0) {
        rows <- lapply(qr$attention, function(chk) {
          tags$tr(
            tags$td(chk$check_id),
            tags$td(chk$type),
            tags$td(sprintf("%.1f%%", chk$pass_rate * 100)),
            tags$td(chk$n_fail)
          )
        })
        table_card("Attention checks",
          headers = c("Check ID", "Type", "Pass rate", "Failures"),
          rows = rows,
          empty_label = "No checks.")
      },
      tags$div(class = "card",
        tags$div(class = "card-title", "Missingness"),
        tags$p(sprintf(
          "%.1f%% of respondents exceed the %.0f%% missing threshold.",
          mean(qr$missing$respondent_miss > qr$missing$flagged_threshold, na.rm = TRUE) * 100,
          qr$missing$flagged_threshold * 100
        ))
      )
    )
  })

  output$reliability_gate <- renderUI({
    if (is.null(rv$instrument) || is.null(rv$responses)) {
      tags$div(class = "card",
        "Build or open a valid instrument and load responses to compute reliability.")
    }
  })

  reliability_result <- reactive({
    req(rv$instrument, rv$responses)
    tryCatch(
      surveyframe::reliability_report(rv$responses, rv$instrument),
      error = function(e) NULL
    )
  })

  output$reliability_output <- renderUI({
    req(rv$instrument, rv$responses)
    rr <- reliability_result()
    if (is.null(rr) || length(rr) == 0) {
      return(tags$div(class = "card",
        "No scales with two or more items found in response data."))
    }

    cards <- lapply(rr, function(scale) {
      rows <- list(
        tags$tr(tags$td("Items"), tags$td(scale$n_items)),
        tags$tr(tags$td("N"), tags$td(scale$n))
      )
      if (!is.null(scale$alpha)) {
        rows <- c(rows, list(tags$tr(tags$td("Cronbach alpha"),
                                     tags$td(sprintf("%.3f", scale$alpha)))))
      }
      if (!is.null(scale$omega_h)) {
        rows <- c(rows, list(tags$tr(tags$td("Omega h"),
                                     tags$td(sprintf("%.3f", scale$omega_h)))))
      }
      if (!is.null(scale$omega_t)) {
        rows <- c(rows, list(tags$tr(tags$td("Omega total"),
                                     tags$td(sprintf("%.3f", scale$omega_t)))))
      }

      tags$div(class = "card",
        tags$div(class = "card-title", paste0(scale$label, " (", scale$scale_id, ")")),
        tags$table(class = "sf-table", tags$tbody(rows))
      )
    })

    do.call(tagList, cards)
  })

  output$export_gate <- renderUI({
    if (is.null(rv$instrument)) {
      tags$div(class = "card",
        "Build or open a valid instrument before exporting files.")
    }
  })

  output$download_sframe_btn <- downloadHandler(
    filename = function() {
      title <- draft_result()$instrument$meta$title %||% "survey"
      paste0(gsub("[^a-zA-Z0-9]", "_", title), ".sframe")
    },
    content = function(file) {
      draft <- draft_result()
      if (!draft$valid) {
        stop("Draft validation must pass before exporting a .sframe file.")
      }
      tmp <- tempfile(fileext = ".sframe")
      surveyframe::write_sframe(draft$instrument, tmp, overwrite = TRUE)
      file.copy(tmp, file, overwrite = TRUE)
    }
  )

  output$download_report_btn <- downloadHandler(
    filename = function() {
      paste0(
        gsub("[^a-zA-Z0-9]", "_", (rv$instrument$meta$title %||% "survey")),
        "_report.html"
      )
    },
    content = function(file) {
      tryCatch({
        surveyframe::render_report(
          instrument = rv$instrument,
          data = rv$responses,
          output_file = file,
          include_codebook = isTRUE(input$rpt_codebook),
          include_quality = isTRUE(input$rpt_quality),
          include_reliability = isTRUE(input$rpt_reliability)
        )
      }, error = function(e) {
        showNotification(paste("Report error:", conditionMessage(e)), type = "error")
      })
    }
  )
}

shinyApp(ui = ui, server = server)
