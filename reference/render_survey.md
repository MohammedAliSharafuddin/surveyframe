# Render a survey from an instrument object

Launches a Shiny survey with a welcome page, configurable header, all
item types, branching logic, required-field enforcement, progress
tracking, standard and conversational (one-question-at-a-time) display
modes, and a customisable thank-you page. Responses can be persisted to
CSV or passed to a callback.

## Usage

``` r
render_survey(
  instrument,
  mode = c("shiny"),
  title = NULL,
  theme = NULL,
  save_responses = c("none", "csv"),
  output_path = NULL,
  on_submit = NULL
)
```

## Arguments

- instrument:

  An `sframe` object.

- mode:

  Character. Deployment mode. Currently `"shiny"`.

- title:

  Character or NULL. Override for the survey title.

- theme:

  Character or NULL. Hex colour for the survey theme.

- save_responses:

  Character. `"none"` (default) or `"csv"`.

- output_path:

  Character or NULL. CSV path when `save_responses = "csv"`.

- on_submit:

  Function or NULL. Callback receiving the submitted row.

## Value

A `shiny.appobj`.

## See also

[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)

## Examples

``` r
if (FALSE) { # \dontrun{
render_survey(instr)
render_survey(instr, save_responses = "csv", output_path = "responses.csv")
} # }
```
