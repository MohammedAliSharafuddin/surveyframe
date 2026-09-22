# Quality report plot: straight-lining flag rate by scale

Quality report plot: straight-lining flag rate by scale

## Usage

``` r
sframe_plot_quality(x, palette = c("web", "print"))
```

## Arguments

- x:

  An `sframe_quality_report` object from
  [`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md).

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object.

## See also

[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)

## Examples

``` r
# \donttest{
if (requireNamespace("ggplot2", quietly = TRUE)) {
  demo <- sframe_demo("likert_scale")
  qr <- quality_report(demo$responses, demo$instrument)
  sframe_plot_quality(qr)
}

# }
```
