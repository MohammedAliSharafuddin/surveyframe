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

  An `sframe` object. Required. Calling `launch_dashboard()` with no
  instrument errors with guidance; use
  [`launch_dashboard_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard_demo.md)
  for the bundled demo or
  [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md)
  to upload interactively.

- responses:

  A `data.frame` or `tibble` of survey responses, as produced by
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  or
  [`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md).
  When NULL the dashboard opens with instrument metadata and no response
  summaries.

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

The dashboard is read-only and takes its data from R. It has no upload
screen, so pass `instrument` and `responses` directly. To open and
upload data interactively, use
[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md),
which includes this same dashboard as its Dashboard tab. For a quick
look at bundled demo data, use
[`launch_dashboard_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard_demo.md).

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md),
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# For the bundled demo, use launch_dashboard_demo().
# To upload data interactively, use launch_studio().

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
