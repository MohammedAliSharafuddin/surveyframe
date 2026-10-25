# Save the charts from an analysis plan as files

Writes each chart
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
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
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
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
chart write a file.

## See also

[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md),
which takes the same settings as `figures`.

## Examples

``` r
# \donttest{
if (requireNamespace("ggplot2", quietly = TRUE)) {
  d <- sframe_demo("two_group")
  res <- run_analysis_plan(d$responses, d$instrument, plots = TRUE)
  paths <- sframe_save_figures(res, file.path(tempdir(), "figures"),
                               width = 6, height = 4, dpi = 300)
  basename(paths)
}
#> [1] "RQ1.png" "RQ2.png"
# }
```
