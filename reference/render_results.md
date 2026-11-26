# Render analysis results to a formatted HTML report

Generates a self-contained HTML report from the output of
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md).
Each section corresponds to one research question and includes the
APA-formatted statistical result, an interpretation space and a
reference list.

## Usage

``` r
render_results(
  results = NULL,
  instrument,
  output_file = NULL,
  output_path = NULL,
  citation_format = "apa",
  title = NULL,
  interpretations = NULL
)
```

## Arguments

- results:

  An `sframe_analysis_results` object from
  [`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md).

- instrument:

  An `sframe` object.

- output_file:

  Character or NULL. Path to the output HTML file. When NULL, a
  temporary file is written and its path returned.

- output_path:

  Character or NULL. Alias for `output_file`.

- citation_format:

  Character. The reference format, `"apa"` (APA 7), the only one the
  report writes. `"ama"` and `"vancouver"` were accepted before 0.4.3
  and never applied, so they are refused with a message.

- title:

  Character or NULL. Report title. Defaults to the instrument title with
  `" -- Results"` appended.

- interpretations:

  Named list or NULL. Written interpretations keyed by analysis-plan
  block id, added after the results are known. A block with an entry
  shows that text in its Interpretation section, labelled as written
  after the results. The hypotheses and planned decision rule a block
  declared print before its result, with or without an entry.
  Interpretations are report content only and are never written into the
  instrument.

## Value

The output file path, invisibly.

## See also

[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md),
[`render_report()`](https://surveyframe.org/reference/render_report.md)

Other Report functions:
[`render_report()`](https://surveyframe.org/reference/render_report.md),
[`sframe_analysis_qmd()`](https://surveyframe.org/reference/sframe_analysis_qmd.md),
[`sframe_codebook()`](https://surveyframe.org/reference/sframe_codebook.md),
[`sframe_format_result()`](https://surveyframe.org/reference/sframe_format_result.md),
[`sframe_report_source()`](https://surveyframe.org/reference/sframe_report_source.md),
[`sframe_reports`](https://surveyframe.org/reference/sframe_reports.md),
[`sframe_save_figures()`](https://surveyframe.org/reference/sframe_save_figures.md),
[`sframe_show()`](https://surveyframe.org/reference/sframe_show.md)

## Examples

``` r
instr <- read_sframe(
  system.file("extdata", "demos", "two_group.sframe",
              package = "surveyframe")
)
responses <- read_responses(
  system.file("extdata", "demos", "two_group_responses.csv",
              package = "surveyframe"),
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  meta_cols = "started_at"
)
# \donttest{
results <- run_analysis_plan(responses, instr)
out <- render_results(results, instr,
                      output_file = tempfile(fileext = ".html"))
sframe_show(out)
# }
```
