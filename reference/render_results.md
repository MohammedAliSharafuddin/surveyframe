# Render analysis results to a formatted HTML report

Generates a self-contained HTML report from the output of
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md).
Each section corresponds to one research question and includes the
APA-formatted statistical result, an interpretation space, and a
reference list.

## Usage

``` r
render_results(
  results = NULL,
  instrument,
  output_file = NULL,
  output_path = NULL,
  citation_format = c("apa", "ama", "vancouver"),
  title = NULL
)
```

## Arguments

- results:

  An `sframe_analysis_results` object from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md).

- instrument:

  An `sframe` object.

- output_file:

  Character or NULL. Path to the output HTML file. When NULL, a
  temporary file is written and its path returned.

- output_path:

  Character or NULL. Alias for `output_file`.

- citation_format:

  Character. Reference format. One of `"apa"`, `"ama"`, or
  `"vancouver"`. Defaults to `"apa"`.

- title:

  Character or NULL. Report title. Defaults to the instrument title with
  " – Results" appended.

## Value

The output file path, invisibly.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)

## Examples

``` r
if (FALSE) { # \dontrun{
results <- run_analysis_plan(responses, instr)
render_results(results, instr, output_file = "results.html")
} # }
```
