# Shiny module server for an embedded survey

Renders the survey instrument and collects the respondent's answers.
Returns a `reactive` that holds `NULL` until the form is submitted, then
returns the response as a named list (one element per visible item).

## Usage

``` r
survey_module_server(id, instrument, on_submit = NULL)
```

## Arguments

- id:

  A character string matching the `id` passed to
  [`survey_module_ui()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_ui.md).

- instrument:

  An `sframe` object, or a `reactive` that returns one. Changing the
  reactive value resets the survey.

- on_submit:

  Optional function of one argument. Called immediately after submission
  with the response list. Useful for writing to a database or sending an
  email without waiting for an
  [`shiny::observeEvent()`](https://rdrr.io/pkg/shiny/man/observeEvent.html)
  elsewhere in the app.

## Value

A `reactive` that returns `NULL` before submission and the response list
after.

## See also

[`survey_module_ui()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_ui.md)

## Examples

``` r
# \donttest{
# See survey_module_ui() for a complete example.
# }
```
