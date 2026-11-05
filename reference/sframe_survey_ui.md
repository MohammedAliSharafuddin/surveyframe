# Shiny module UI for an embedded survey

Places a survey inside a larger Shiny application. Pair with
[`sframe_survey_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_survey_server.md)
in the server function. The module shows a welcome screen, the
instrument's pages with branching and required-item checks, and a
thank-you screen.

## Usage

``` r
sframe_survey_ui(id, width = "100%")
```

## Arguments

- id:

  A character string. The module namespace ID, passed identically to
  [`sframe_survey_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_survey_server.md).

- width:

  Character. CSS width for the survey card. Defaults to `"100%"`.

## Value

A `shiny.tag` object.

## Details

Every item type is drawn with the same controls
[`run_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_survey.md)
uses, so a response collected through the module has the same columns as
one collected there.
[`sframe_survey_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_survey_server.md)
describes what is returned.

## See also

[`sframe_survey_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_survey_server.md),
[`run_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_survey.md),
[`export_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_survey.md)

Other Collect functions:
[`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md),
[`export_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_survey.md),
[`sframe_survey_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_survey_server.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(shiny)
library(surveyframe)

cs    <- sframe_choice_set("ag5", 1:5, c("SD", "D", "N", "A", "SA"))
item  <- sframe_item("q1", "Rate your experience.", type = "likert",
                 choice_set = "ag5", required = TRUE)
instr <- sframe_instrument("Quick Survey", components = list(cs, item))
store <- file.path(tempdir(), "responses.csv")

ui <- fluidPage(
  sframe_survey_ui("demo"),
  verbatimTextOutput("result")
)

server <- function(input, output, session) {
  resp <- sframe_survey_server(
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
