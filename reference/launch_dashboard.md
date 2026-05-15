# Launch the interactive response dashboard

Opens a Shiny dashboard to explore collected response data alongside the
instrument definition. Use this interface after response collection for
analysis and quality control. Use
[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md)
to design new questionnaires. The dashboard includes five panels:

## Usage

``` r
launch_dashboard(
  instrument = NULL,
  responses = NULL,
  port = NULL,
  host = "127.0.0.1",
  launch.browser = interactive()
)
```

## Arguments

- instrument:

  An `sframe` object. When `NULL`, the bundled tourism services demo
  instrument is loaded.

- responses:

  A `data.frame` or `tibble` of survey responses, as produced by
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  or
  [`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md).
  When NULL and `instrument` is also NULL, the bundled simulated demo
  responses are loaded. When NULL with a user-supplied instrument, the
  dashboard opens with instrument metadata and no response summaries.

- port:

  Integer or NULL. TCP port for the Shiny server. When NULL, Shiny
  selects an available port automatically.

- host:

  Character. Host address passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).
  Defaults to `"127.0.0.1"`.

- launch.browser:

  Logical. Whether to open the dashboard in the default browser
  automatically. Defaults to `TRUE` in interactive sessions.

## Value

Called for its side effect. Returns nothing.

## Details

- Overview:

  Response count, date range, and instrument metadata.

- Items:

  Per-item frequency bar charts, histograms, and tabulated frequency
  counts for choice-type questions.

- Scales:

  Scale score distributions with mean overlay, and a summary table of
  scale definitions.

- Quality:

  Attention check pass rates for each check defined in the instrument.

- Raw data:

  Scrollable response table with a CSV download button.

The dashboard is read-only. Use it for descriptive exploration after
collecting responses and before running formal analysis with
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md).

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md),
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Open the bundled tourism-services response dashboard.
# To build a questionnaire instead, use launch_builder().
launch_dashboard()

# Open the dashboard with your own instrument and responses
instr <- read_sframe(
  system.file("extdata", "tourism_services_demo.sframe",
              package = "surveyframe")
)
responses <- read_responses(
  system.file("extdata", "tourism_services_responses.csv",
              package = "surveyframe"),
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  meta_cols = "started_at"
)
launch_dashboard(instr, responses)
} # }
```
