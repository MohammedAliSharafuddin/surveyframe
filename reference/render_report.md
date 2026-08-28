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
  format = c("html", "pdf"),
  include_quality = TRUE,
  include_reliability = TRUE,
  include_codebook = TRUE,
  include_missing = TRUE,
  include_descriptives = TRUE,
  include_analysis = TRUE,
  include_models = TRUE,
  plot_palette = c("web", "print"),
  interpretations = NULL
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

  Character. Output format: `"html"` (default) or `"pdf"`. PDF output
  renders the HTML report and prints it through
  [`pagedown::chrome_print()`](https://rdrr.io/pkg/pagedown/man/chrome_print.html),
  which requires the pagedown package (in Suggests) and a local Chrome
  or Chromium installation. The HTML path is unchanged.

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

- plot_palette:

  One of `"web"` (brand colours, for on-screen reading) or `"print"`
  (black, grey, and white, for a journal-ready or print-friendly
  report). Applied to every chart the report embeds. See
  `sframe_brand()`.

- interpretations:

  Named list or NULL. Written interpretations keyed by analysis-plan
  block id, added after the results are known. When a block has an
  entry, its report section shows the pre-declared decision rule under a
  "Planned decision rule" label followed by the written text under an
  "Interpretation" label. Blocks without an entry render exactly as they
  do when this argument is NULL. Interpretations are report content only
  and are never written into the instrument.

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
# \donttest{
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
#> Report rendered with the built-in HTML engine: /tmp/RtmpoQNXak/file281d1ed1710f.html
file.exists(out)
#> [1] TRUE
# }
```
