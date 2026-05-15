# Shiny module UI for an embedded survey

Places a survey rendered by surveyframe inside a larger Shiny
application. Pair with
[`survey_module_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_server.md)
in the server function. The module renders the full instrument including
welcome page, all item types, branching logic, required-field
validation, and a thank-you screen.

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

## See also

[`survey_module_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_server.md),
[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md),
[`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Minimal embedding example:
library(shiny)
library(surveyframe)

cs    <- sf_choices("ag5", 1:5, c("SD", "D", "N", "A", "SA"))
item  <- sf_item("q1", "Rate your experience.", type = "likert",
                 choice_set = "ag5", required = TRUE)
instr <- sf_instrument("Quick Survey", components = list(cs, item))

ui <- fluidPage(
  survey_module_ui("demo"),
  verbatimTextOutput("result")
)

server <- function(input, output, session) {
  resp <- survey_module_server("demo", instrument = instr)
  output$result <- renderPrint({
    req(resp())
    resp()
  })
}

shinyApp(ui, server)
} # }
```
