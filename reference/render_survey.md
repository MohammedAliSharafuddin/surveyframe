# Render a survey from an instrument object

Launches a self-contained Shiny survey application derived from the
instrument specification. In v0.1, only `mode = "shiny"` is supported.
Static HTML and Quarto embed modes are planned for a future release.

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

  Character. The deployment mode. Only `"shiny"` is supported in v0.1.

- title:

  Character or NULL. An override for the survey title displayed in the
  browser. When NULL, the instrument title is used.

- theme:

  Character or NULL. A hex colour code for the survey theme. When NULL,
  the function uses `instrument$render$theme` when present and otherwise
  falls back to the default theme.

- save_responses:

  Character. Persistence mode for submitted responses. Either `"none"`
  (default) or `"csv"`.

- output_path:

  Character or NULL. Path to a CSV file used when
  `save_responses = "csv"`. Rows are appended if the file already
  exists.

- on_submit:

  Function or NULL. Optional callback invoked with the submitted one-row
  tibble after validation and optional file persistence.

## Value

A `shiny.appobj` object. When called interactively, printing the
returned object launches the Shiny app.

## Details

`render_survey()` can persist submitted responses to CSV for later
import with
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md).
Saved files include `started_at` and `submitted_at` metadata columns
before the instrument item columns.

## See also

[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)

## Examples

``` r
if (FALSE) { # \dontrun{
render_survey(instr)
render_survey(
  instr,
  save_responses = "csv",
  output_path = "responses.csv"
)
} # }
```
