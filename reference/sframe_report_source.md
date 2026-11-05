# Recompute and check a report source folder

The first chunk of the `report.qmd` that `render_report(format = "qmd")`
writes calls this function. It reads the folder's `.sframe` and
responses, recomputes the analysis plan, and compares what it finds with
the folder's `manifest.json`. The report's Provenance section then
states the instrument hash and whether
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
verified it, the amendments, whether the responses file is the one
exported, whether the numbers match the recorded results ("Numbers match
the recorded results", or "Numbers differ from the recorded results"
with both hashes), whether `report.qmd` was edited after surveyframe
wrote it, and which declared plan blocks the report includes.

## Usage

``` r
sframe_report_source(dir = ".", include_analysis = TRUE, plot_palette = "web")
```

## Arguments

- dir:

  The report source folder. Defaults to the working directory, which is
  the folder itself when Quarto renders its `report.qmd`.

- include_analysis:

  Logical. Whether the report includes the analysis plan results.

- plot_palette:

  `"web"` or `"print"`, as in
  [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md).

## Value

A list the template reads: paths to the inputs it renders from, the
instrument hash, the analysis seed, and `check`, a list of the verdicts
(`numbers_match`, `source_edited`, `responses_match`, with the recorded
and recomputed hashes).

## Details

Editing the `.qmd` stays allowed and is disclosed, as an amendment is.
Someone can delete the provenance chunk, as they can edit any document.
The tamper evidence a reviewer can check lives in the `.sframe`, the
responses hash and the results record, all checkable without the report.

## See also

[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)

Other Report functions:
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md),
[`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md),
[`sframe_analysis_qmd()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_analysis_qmd.md),
[`sframe_codebook()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_codebook.md),
[`sframe_format_result()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_format_result.md),
[`sframe_reports`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reports.md),
[`sframe_save_figures()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_save_figures.md)

## Examples

``` r
# \donttest{
d <- sframe_demo("likert_scale")
dir <- file.path(tempdir(), "report-source-example")
render_report(d$instrument, d$responses, output_file = dir, format = "qmd",
              open = FALSE)
#> Report source written to /tmp/RtmppB03Io/report-source-example. Open report.qmd in RStudio or Positron and render it.
src <- sframe_report_source(dir)
src$check$numbers_match
#> [1] TRUE
src$check$source_edited
#> [1] FALSE
unlink(dir, recursive = TRUE)
# }
```
