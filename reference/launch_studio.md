# Launch the SurveyStudio interface

Opens the SurveyStudio Shiny application, the visual interface for
working with an instrument that already exists. Its screens open an
instrument, record and read amendments, preview the survey, upload
responses, review data quality, inspect reliability, work on the
analysis plan, read the dashboard, and export.

## Usage

``` r
launch_studio(
  instrument = NULL,
  responses = NULL,
  respondent_id = NULL,
  submitted_at = NULL,
  meta_cols = NULL,
  strict = TRUE,
  screen = "auto",
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

  The screen to open on. One of `"auto"`, which picks by what you
  supply, or a screen name: `"open"`, `"amendments"`, `"preview"`,
  `"responses"`, `"quality"`, `"reliability"`, `"analysis"`,
  `"dashboard"` or `"export"`. `"data"` is accepted for `"responses"`.

- port:

  TCP port for the Shiny server.

- host:

  Host address passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

- launch.browser:

  Whether to open the browser automatically.

## Value

Called for its side effect.

## Details

Studio reads and analyses an instrument. To author one, question by
question, use
[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md),
and open the result here.

## See also

[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md),
[`launch_dashboard()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard.md),
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)

## Examples

``` r
if (FALSE) { # \dontrun{
launch_studio()

demo <- sframe_demo_data()
launch_studio(instrument = demo$instrument, launch.browser = FALSE)

launch_studio(
  instrument    = demo$instrument,
  responses     = demo$responses,
  respondent_id = "respondent_id",
  submitted_at  = "submitted_at"
)
} # }
```
