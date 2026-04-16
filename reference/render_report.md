# Render a reproducible survey report

Generates a self-contained Quarto HTML report that includes the
instrument codebook, data quality summary, and reliability diagnostics.
All outputs are derived from the instrument object and the response data
supplied, making the report fully reproducible from those two inputs.

## Usage

``` r
render_report(
  instrument,
  data = NULL,
  output_file = NULL,
  format = c("html"),
  include_quality = TRUE,
  include_reliability = TRUE,
  include_codebook = TRUE
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

- format:

  Character. Output format. Only `"html"` is supported in v0.1.

- include_quality:

  Logical. Whether to include the data quality report. Requires `data`.
  Defaults to `TRUE`.

- include_reliability:

  Logical. Whether to include reliability diagnostics. Requires `data`.
  Defaults to `TRUE`.

- include_codebook:

  Logical. Whether to include the instrument codebook. Defaults to
  `TRUE`.

## Value

The output file path, invisibly.

## Details

Requires the `quarto` package. An error is raised if it is not
installed.

## See also

[`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md),
[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md),
[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)

## Examples

``` r
if (FALSE) { # \dontrun{
render_report(instr, data = responses, output_file = "my_report.html")
} # }
```
