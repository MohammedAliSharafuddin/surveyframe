# render_survey.R

sframe_choices_lookup <- function(instrument) {
  stats::setNames(
    lapply(instrument$choices, function(cs) {
      stats::setNames(as.character(cs$values), cs$labels)
    }),
    vapply(instrument$choices, function(cs) cs$id, character(1))
  )
}

sframe_branch_lookup <- function(instrument) {
  branch_lookup <- list()
  for (rule in instrument$branching) {
    branch_lookup[[rule$item_id]] <- rule
  }
  branch_lookup
}

sframe_theme_colour <- function(instrument, theme = NULL) {
  theme %||% instrument$render$theme %||% "#5b8dee"
}

sframe_show_progress <- function(instrument) {
  isTRUE(instrument$render$show_progress)
}

sframe_label_tag <- function(item) {
  tags$div(
    class = "sf-label-block",
    tags$div(
      class = "sf-label-row",
      tags$span(class = "sf-label-text", item$label),
      if (isTRUE(item$required)) tags$span(class = "sf-required", "*")
    ),
    if (!is.null(item$help) && nzchar(trimws(item$help))) {
      tags$p(class = "sf-help-text", item$help)
    }
  )
}

sframe_item_visible <- function(item, input_values, branch_lookup) {
  rule <- branch_lookup[[item$id]]
  if (is.null(rule)) {
    return(TRUE)
  }

  dep_val <- input_values[[rule$depends_on]]
  .evaluate_branch(rule, dep_val)
}

sframe_visible_items <- function(instrument, input_values, branch_lookup) {
  Filter(
    function(item) sframe_item_visible(item, input_values, branch_lookup),
    instrument$items
  )
}

sframe_missing_value <- function(item, value) {
  if (is.null(value) || length(value) == 0) {
    return(TRUE)
  }

  if (all(is.na(value))) {
    return(TRUE)
  }

  if (item$type %in% c("text", "textarea")) {
    return(!any(nzchar(trimws(as.character(value)))))
  }

  if (item$type == "multiple_choice") {
    return(length(value) == 0 || !any(nzchar(trimws(as.character(value)))))
  }

  if (item$type == "numeric") {
    return(all(is.na(suppressWarnings(as.numeric(value)))))
  }

  if (item$type == "date") {
    return(!any(nzchar(trimws(as.character(value)))))
  }

  FALSE
}

sframe_missing_required_items <- function(instrument, input_values, branch_lookup) {
  visible_items <- sframe_visible_items(instrument, input_values, branch_lookup)

  vapply(
    Filter(function(item) {
      isTRUE(item$required) && sframe_missing_value(item, input_values[[item$id]])
    }, visible_items),
    function(item) item$id,
    character(1)
  )
}

sframe_answered_visible_count <- function(instrument, input_values, branch_lookup) {
  visible_items <- sframe_visible_items(instrument, input_values, branch_lookup)
  if (length(visible_items) == 0) {
    return(list(answered = 0L, total = 0L, pct = 0))
  }

  answered <- sum(vapply(
    visible_items,
    function(item) !sframe_missing_value(item, input_values[[item$id]]),
    logical(1)
  ))

  list(
    answered = answered,
    total = length(visible_items),
    pct = answered / length(visible_items)
  )
}

sframe_serialise_response_value <- function(value) {
  if (is.null(value) || length(value) == 0 || all(is.na(value))) {
    return(NA_character_)
  }

  if (inherits(value, "Date")) {
    return(as.character(value))
  }

  paste(as.character(value), collapse = "|")
}

sframe_response_row <- function(
    instrument,
    input_values,
    branch_lookup,
    started_at,
    submitted_at = Sys.time()
) {
  item_values <- lapply(instrument$items, function(item) {
    if (!sframe_item_visible(item, input_values, branch_lookup)) {
      return(NA_character_)
    }

    sframe_serialise_response_value(input_values[[item$id]])
  })

  names(item_values) <- vapply(instrument$items, function(item) item$id, character(1))

  tibble::as_tibble(as.data.frame(
    c(
      list(
        started_at = format(as.POSIXct(started_at, tz = "UTC"),
                            "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
        submitted_at = format(as.POSIXct(submitted_at, tz = "UTC"),
                              "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
      ),
      item_values
    ),
    stringsAsFactors = FALSE,
    check.names = FALSE
  ))
}

sframe_append_response_csv <- function(path, row) {
  dir_path <- dirname(path)
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE, showWarnings = FALSE)
  }

  exists <- file.exists(path)
  utils::write.table(
    row,
    file = path,
    sep = ",",
    row.names = FALSE,
    col.names = !exists,
    append = exists,
    qmethod = "double",
    na = ""
  )

  invisible(path)
}

sframe_render_input <- function(item, choices_lookup) {
  label_tag <- sframe_label_tag(item)
  cs <- choices_lookup[[item$choice_set]]

  switch(item$type,
    single_choice = shiny::radioButtons(
      inputId = item$id,
      label   = label_tag,
      choices = cs
    ),
    multiple_choice = shiny::checkboxGroupInput(
      inputId = item$id,
      label   = label_tag,
      choices = cs
    ),
    likert = shiny::radioButtons(
      inputId = item$id,
      label   = label_tag,
      choices = cs,
      inline  = TRUE
    ),
    numeric = shiny::numericInput(
      inputId = item$id,
      label   = label_tag,
      value   = NA
    ),
    text = shiny::textInput(
      inputId     = item$id,
      label       = label_tag,
      placeholder = item$placeholder %||% ""
    ),
    textarea = shiny::textAreaInput(
      inputId     = item$id,
      label       = label_tag,
      placeholder = item$placeholder %||% ""
    ),
    date = shiny::dateInput(
      inputId = item$id,
      label   = label_tag
    ),
    shiny::textInput(item$id, label_tag)
  )
}

#' Render a survey from an instrument object
#'
#' Launches a self-contained Shiny survey application derived from the
#' instrument specification. In v0.1, only `mode = "shiny"` is supported.
#' Static HTML and Quarto embed modes are planned for a future release.
#'
#' `render_survey()` can persist submitted responses to CSV for later import
#' with [read_responses()]. Saved files include `started_at` and
#' `submitted_at` metadata columns before the instrument item columns.
#'
#' @param instrument An `sframe` object.
#' @param mode Character. The deployment mode. Only `"shiny"` is supported in
#'   v0.1.
#' @param title Character or NULL. An override for the survey title displayed
#'   in the browser. When NULL, the instrument title is used.
#' @param theme Character or NULL. A hex colour code for the survey theme.
#'   When NULL, the function uses `instrument$render$theme` when present and
#'   otherwise falls back to the default theme.
#' @param save_responses Character. Persistence mode for submitted responses.
#'   Either `"none"` (default) or `"csv"`.
#' @param output_path Character or NULL. Path to a CSV file used when
#'   `save_responses = "csv"`. Rows are appended if the file already exists.
#' @param on_submit Function or NULL. Optional callback invoked with the
#'   submitted one-row tibble after validation and optional file persistence.
#'
#' @return A `shiny.appobj` object. When called interactively, printing the
#'   returned object launches the Shiny app.
#' @export
#' @seealso [launch_studio()], [read_responses()]
#'
#' @examples
#' \dontrun{
#' render_survey(instr)
#' render_survey(
#'   instr,
#'   save_responses = "csv",
#'   output_path = "responses.csv"
#' )
#' }
render_survey <- function(
    instrument,
    mode  = c("shiny"),
    title = NULL,
    theme = NULL,
    save_responses = c("none", "csv"),
    output_path = NULL,
    on_submit = NULL
) {
  stopifnot(inherits(instrument, "sframe"))
  mode <- rlang::arg_match(mode)
  save_responses <- rlang::arg_match(save_responses)

  if (!is.null(on_submit) && !is.function(on_submit)) {
    rlang::abort("`on_submit` must be NULL or a function.", class = "sframe_error")
  }

  if (identical(save_responses, "csv") && is.null(output_path)) {
    rlang::abort(
      "`output_path` must be supplied when save_responses = \"csv\".",
      class = "sframe_error"
    )
  }

  display_title <- title %||% instrument$meta$title
  theme_colour <- sframe_theme_colour(instrument, theme)
  show_progress <- sframe_show_progress(instrument)
  choices_lookup <- sframe_choices_lookup(instrument)
  branch_lookup <- sframe_branch_lookup(instrument)
  submit_label <- instrument$render$submit_label %||% "Submit"

  ui <- shiny::fluidPage(
    tags$head(
      tags$style(sprintf("
        .sf-progress {
          margin-bottom: 18px;
        }
        .sf-progress__bar {
          width: 100%%;
          height: 10px;
          background: #e9ecef;
          border-radius: 999px;
          overflow: hidden;
        }
        .sf-progress__fill {
          height: 100%%;
          background: %s;
        }
        .sf-progress__text {
          margin-top: 6px;
          font-size: 12px;
          color: #555;
        }
        .sf-label-block {
          display: block;
        }
        .sf-label-row {
          display: flex;
          align-items: center;
          gap: 6px;
          font-weight: 600;
        }
        .sf-required {
          color: #b91c1c;
        }
        .sf-help-text {
          margin: 4px 0 0;
          font-size: 12px;
          color: #666;
          font-weight: 400;
        }
        .btn-primary {
          background: %s;
          border-color: %s;
        }
      ", theme_colour, theme_colour, theme_colour))
    ),
    shiny::titlePanel(display_title),
    if (show_progress) shiny::uiOutput("survey_progress"),
    shiny::uiOutput("survey_items"),
    shiny::br(),
    shiny::actionButton("submit_btn", submit_label, class = "btn-primary")
  )

  server <- function(input, output, session) {
    started_at <- Sys.time()

    input_values <- shiny::reactive({
      shiny::reactiveValuesToList(input)
    })

    if (show_progress) {
      output$survey_progress <- shiny::renderUI({
        progress <- sframe_answered_visible_count(
          instrument,
          input_values(),
          branch_lookup
        )

        tags$div(
          class = "sf-progress",
          tags$div(
            class = "sf-progress__bar",
            tags$div(
              class = "sf-progress__fill",
              style = sprintf("width: %.1f%%;", progress$pct * 100)
            )
          ),
          tags$div(
            class = "sf-progress__text",
            sprintf("%d of %d visible items answered",
                    progress$answered, progress$total)
          )
        )
      })
    }

    output$survey_items <- shiny::renderUI({
      items_ui <- lapply(instrument$items, function(item) {
        if (!sframe_item_visible(item, input_values(), branch_lookup)) {
          return(NULL)
        }

        sframe_render_input(item, choices_lookup)
      })

      do.call(shiny::tagList, items_ui)
    })

    shiny::observeEvent(input$submit_btn, {
      missing_required <- sframe_missing_required_items(
        instrument,
        input_values(),
        branch_lookup
      )

      if (length(missing_required) > 0) {
        missing_labels <- vapply(
          Filter(function(item) item$id %in% missing_required, instrument$items),
          function(item) item$label,
          character(1)
        )

        shiny::showNotification(
          paste0(
            "Please answer the required item(s): ",
            paste(missing_labels, collapse = ", ")
          ),
          type = "error",
          duration = 6
        )
        return(invisible(NULL))
      }

      response_row <- sframe_response_row(
        instrument,
        input_values(),
        branch_lookup,
        started_at = started_at,
        submitted_at = Sys.time()
      )

      persistence_error <- tryCatch({
        if (identical(save_responses, "csv")) {
          sframe_append_response_csv(output_path, response_row)
        }

        if (is.function(on_submit)) {
          on_submit(response_row)
        }

        NULL
      }, error = function(e) e)

      if (!is.null(persistence_error)) {
        shiny::showNotification(
          paste0("Response could not be saved: ", conditionMessage(persistence_error)),
          type = "error",
          duration = 8
        )
        return(invisible(NULL))
      }

      shiny::showModal(shiny::modalDialog(
        title = "Thank you",
        "Your response has been recorded.",
        easyClose = TRUE
      ))
    })
  }

  shiny::shinyApp(ui = ui, server = server)
}

# Internal branch evaluator
.evaluate_branch <- function(rule, dep_val) {
  if (is.null(dep_val)) return(rule$action == "hide")

  result <- switch(rule$operator,
    "=="  = dep_val == rule$value,
    "!="  = dep_val != rule$value,
    "%in%" = dep_val %in% rule$value,
    ">"   = suppressWarnings(as.numeric(dep_val) > as.numeric(rule$value)),
    ">="  = suppressWarnings(as.numeric(dep_val) >= as.numeric(rule$value)),
    "<"   = suppressWarnings(as.numeric(dep_val) < as.numeric(rule$value)),
    "<="  = suppressWarnings(as.numeric(dep_val) <= as.numeric(rule$value)),
    FALSE
  )
  result <- isTRUE(result)
  if (rule$action == "show") result else !result
}
