# Launch the SurveyStudio interface

Opens the SurveyStudio Shiny application, a visual interface for the
complete surveyframe workflow. The studio includes screens to build a
survey draft, open an existing instrument, preview the survey, upload
responses, review data quality, inspect reliability, plan analyses, and
export outputs.

## Usage

``` r
launch_studio(
  instrument = NULL,
  responses = NULL,
  respondent_id = NULL,
  submitted_at = NULL,
  meta_cols = NULL,
  strict = TRUE,
  screen = c("auto", "build", "preview", "data", "quality", "analysis", "dashboard"),
  port = NULL,
  host = "127.0.0.1",
  launch.browser = interactive()
)
```

## Arguments

- instrument:

  An `sframe` object or NULL.

- responses:

  A data.frame, tibble, CSV file path, or NULL.

- respondent_id:

  Character or NULL. Response ID column when `responses` is a CSV path.

- submitted_at:

  Character or NULL. Submission time column when `responses` is a CSV
  path.

- meta_cols:

  Character vector or NULL. Metadata columns when `responses` is a CSV
  path.

- strict:

  Logical. Passed to
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  when `responses` is a CSV path.

- screen:

  Initial studio screen. One of `"auto"`, `"build"`, `"preview"`,
  `"data"`, `"quality"`, `"analysis"`, or `"dashboard"`.

- port:

  TCP port for the Shiny server.

- host:

  Host address passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

- launch.browser:

  Whether to open the browser automatically.

## Value

Called for its side effect.

## See also

[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md),
[`launch_dashboard()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)

## Examples

``` r
if (FALSE) { # \dontrun{
launch_studio()

instr <- read_sframe("my_instrument.sframe")
launch_studio(instrument = instr, launch.browser = FALSE)

launch_studio(
  instrument = instr,
  responses = "data/responses.csv",
  respondent_id = "respondent_id",
  submitted_at = "submitted_at"
)
} # }
```
