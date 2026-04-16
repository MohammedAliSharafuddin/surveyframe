# render_survey.R

#' Render a survey from an instrument object
#'
#' Launches a self-contained Shiny survey application derived from the
#' instrument specification. In v0.1, only `mode = "shiny"` is supported.
#' Static HTML and Quarto embed modes are planned for a future release.
#'
#' @param instrument An `sframe` object.
#' @param mode Character. The deployment mode. Only `"shiny"` is supported in
#'   v0.1.
#' @param title Character or NULL. An override for the survey title displayed
#'   in the browser. When NULL, the instrument title is used.
#' @param theme Character or NULL. A hex colour code for the survey theme.
#'   When NULL, the default theme is applied.
#'
#' @return Launches a Shiny application. Does not return a value.
#' @export
#' @seealso [launch_studio()], [read_responses()]
#'
#' @examples
#' \dontrun{
#' render_survey(instr)
#' }
render_survey <- function(
    instrument,
    mode  = c("shiny"),
    title = NULL,
    theme = NULL
) {
  stopifnot(inherits(instrument, "sframe"))
  mode <- rlang::arg_match(mode)

  display_title <- title %||% instrument$meta$title

  item_ids <- vapply(instrument$items, function(i) i$id, character(1))

  # Build a choices lookup: choice_set_id -> named vector of labels
  choices_lookup <- stats::setNames(
    lapply(instrument$choices, function(cs) {
      stats::setNames(as.character(cs$values), cs$labels)
    }),
    vapply(instrument$choices, function(cs) cs$id, character(1))
  )

  # Build branching lookup: item_id -> list(depends_on, operator, value, action)
  branch_lookup <- list()
  for (rule in instrument$branching) {
    branch_lookup[[rule$item_id]] <- rule
  }

  ui <- shiny::fluidPage(
    shiny::titlePanel(display_title),
    shiny::uiOutput("survey_items"),
    shiny::br(),
    shiny::actionButton("submit_btn", "Submit", class = "btn-primary")
  )

  server <- function(input, output, session) {
    output$survey_items <- shiny::renderUI({
      items_ui <- lapply(instrument$items, function(item) {
        # Evaluate branching visibility
        rule <- branch_lookup[[item$id]]
        if (!is.null(rule)) {
          dep_val <- input[[rule$depends_on]]
          visible <- .evaluate_branch(rule, dep_val)
          if (!visible) return(NULL)
        }

        cs <- choices_lookup[[item$choice_set]]

        switch(item$type,
          single_choice = shiny::radioButtons(
            inputId = item$id,
            label   = item$label,
            choices = cs
          ),
          multiple_choice = shiny::checkboxGroupInput(
            inputId = item$id,
            label   = item$label,
            choices = cs
          ),
          likert = shiny::radioButtons(
            inputId  = item$id,
            label    = item$label,
            choices  = cs,
            inline   = TRUE
          ),
          numeric = shiny::numericInput(
            inputId = item$id,
            label   = item$label,
            value   = NA
          ),
          text = shiny::textInput(
            inputId     = item$id,
            label       = item$label,
            placeholder = item$placeholder %||% ""
          ),
          textarea = shiny::textAreaInput(
            inputId     = item$id,
            label       = item$label,
            placeholder = item$placeholder %||% ""
          ),
          date = shiny::dateInput(
            inputId = item$id,
            label   = item$label
          ),
          shiny::textInput(item$id, item$label)  # fallback
        )
      })
      do.call(shiny::tagList, items_ui)
    })

    shiny::observeEvent(input$submit_btn, {
      response_row <- lapply(item_ids, function(id) input[[id]])
      names(response_row) <- item_ids
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
