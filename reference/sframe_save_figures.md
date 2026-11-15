# Save the charts from an analysis plan as files

Writes each chart
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md)
drew with `plots = TRUE` to its own file, at the size, resolution and
format a journal asks for. The charts the exported `sframe_plot_*()`
functions return are `ggplot` objects, so any one of them can also be
saved at any size with
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html).

## Usage

``` r
sframe_save_figures(
  results,
  dir,
  width = 7,
  height = 4.5,
  dpi = 300,
  format = c("png", "tiff", "jpeg", "pdf", "svg")
)
```

## Arguments

- results:

  The list
  [`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md)
  returns, run with `plots = TRUE`.

- dir:

  Directory to write into. Created when absent.

- width, height:

  Size in inches. Default 7 by 4.5.

- dpi:

  Resolution in dots per inch, for the raster formats. Default 300.

- format:

  One of `"png"` (default), `"tiff"`, `"jpeg"`, `"pdf"` or `"svg"`.

## Value

The paths written, named by block id, invisibly. Only blocks that drew a
chart write a file. A block with a second chart, a linear regression's
standardised coefficients or a mediation's path diagram, writes it as
`<id>_2`.

## See also

[`render_report()`](https://surveyframe.org/reference/render_report.md),
which takes the same settings as `figures`.

Other Report functions:
[`render_report()`](https://surveyframe.org/reference/render_report.md),
[`render_results()`](https://surveyframe.org/reference/render_results.md),
[`sframe_analysis_qmd()`](https://surveyframe.org/reference/sframe_analysis_qmd.md),
[`sframe_codebook()`](https://surveyframe.org/reference/sframe_codebook.md),
[`sframe_format_result()`](https://surveyframe.org/reference/sframe_format_result.md),
[`sframe_report_source()`](https://surveyframe.org/reference/sframe_report_source.md),
[`sframe_reports`](https://surveyframe.org/reference/sframe_reports.md),
[`sframe_show()`](https://surveyframe.org/reference/sframe_show.md)

## Examples

``` r
# \donttest{
if (requireNamespace("ggplot2", quietly = TRUE)) {
  d <- sframe_demo("two_group")
  res <- run_analysis_plan(d$responses, d$instrument, plots = TRUE)
  paths <- sframe_save_figures(res, file.path(tempdir(), "figures"),
                               width = 6, height = 4, dpi = 300)
  basename(paths)
  sframe_show(paths[1])
}
# }
```
