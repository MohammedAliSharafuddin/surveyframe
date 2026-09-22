# Shiny module UI for an embedded survey

Places a survey inside a larger Shiny application. Pair with
[`survey_module_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_server.md)
in the server function. The module shows a welcome screen, the
instrument's pages with branching and required-item checks, and a
thank-you screen.

## Usage

``` r
survey_module_ui(id, width = "100%")
```

## Arguments

- id:

  A character string. The module namespace ID, passed identically to
  [`survey_module_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_server.md).

- width:

  Character. CSS width for the survey card. Defaults to `"100%"`.

## Value

A `shiny.tag` object.

## Details

Every item type is drawn with the same controls
[`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
uses, so a response collected through the module has the same columns as
one collected there.
[`survey_module_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_server.md)
describes what is returned.

## See also

[`survey_module_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_server.md),
[`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md),
[`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(shiny)
library(surveyframe)

cs    <- sf_choices("ag5", 1:5, c("SD", "D", "N", "A", "SA"))
item  <- sf_item("q1", "Rate your experience.", type = "likert",
                 choice_set = "ag5", required = TRUE)
instr <- sf_instrument("Quick Survey", components = list(cs, item))
store <- file.path(tempdir(), "responses.csv")

ui <- fluidPage(
  survey_module_ui("demo"),
  verbatimTextOutput("result")
)

server <- function(input, output, session) {
  resp <- survey_module_server(
    "demo", instrument = instr,
    # Called before the survey is marked complete. An error here keeps the
    # respondent on the last page with a message, so nothing is lost.
    on_submit = function(response) {
      row <- as.data.frame(response, check.names = FALSE)
      utils::write.table(row, store, sep = ",", row.names = FALSE,
                         col.names = !file.exists(store),
                         append = file.exists(store))
    }
  )
  output$result <- renderPrint({
    req(resp())
    resp()
  })
}

shinyApp(ui, server)
} # }
```
