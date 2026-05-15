# Render a reproducible survey report

Generates an HTML report that includes the instrument codebook, data
quality summary, reliability diagnostics, and analysis-plan content.
When Quarto and the bundled template are available, the report is
rendered through Quarto. Otherwise, surveyframe writes an internal HTML
fallback so the reporting workflow still runs on machines without
Quarto.

## Usage

``` r
render_report(
  instrument,
  data = NULL,
  output_file = NULL,
  output_path = NULL,
  format = c("html"),
  include_quality = TRUE,
  include_reliability = TRUE,
  include_codebook = TRUE,
  include_missing = TRUE,
  include_descriptives = TRUE,
  include_analysis = TRUE,
  include_models = TRUE
)
```

## Arguments

- instrument:

  An `sframe` object.

- data:

  A `tibble` or `data.frame` of responses, or NULL to generate a
  codebook-only report.

- output_file:

  Character or NULL. The output file path. When NULL, a temporary file
  is written and its path returned.

- output_path:

  Character or NULL. Alias for `output_file`. If both are supplied,
  `output_file` takes precedence.

- format:

  Character. Output format. Currently `"html"`.

- include_quality:

  Logical. Whether to include the data quality report. Requires `data`.
  Defaults to `TRUE`.

- include_reliability:

  Logical. Whether to include reliability diagnostics. Requires `data`.
  Defaults to `TRUE`.

- include_codebook:

  Logical. Whether to include the instrument codebook. Defaults to
  `TRUE`.

- include_missing:

  Logical. Whether to include the missing-data report. Requires `data`.
  Defaults to `TRUE`.

- include_descriptives:

  Logical. Whether to include descriptive statistics. Requires `data`.
  Defaults to `TRUE`.

- include_analysis:

  Logical. Whether to include analysis-plan results when `data` are
  supplied and the instrument has an `analysis_plan`.

- include_models:

  Logical. Whether to include saved model JSON and generated syntax
  blocks. Defaults to `TRUE`.

## Value

The output file path, invisibly.

## See also

[`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md),
[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md),
[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)

## Examples

``` r
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
old <- options(surveyframe.use_quarto = FALSE)
out <- tryCatch(
  render_report(
    instr,
    data = responses,
    output_file = tempfile(fileext = ".html"),
    include_reliability = FALSE,
    include_analysis = FALSE
  ),
  finally = options(old)
)
file.exists(out)
#> [1] TRUE
```
