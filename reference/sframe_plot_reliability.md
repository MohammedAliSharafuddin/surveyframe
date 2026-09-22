# Reliability plot: alpha and omega by scale

Reliability plot: alpha and omega by scale

## Usage

``` r
sframe_plot_reliability(x, palette = c("web", "print"))
```

## Arguments

- x:

  An `sframe_reliability_report` object from
  [`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md).

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object.

## See also

[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)

## Examples

``` r
# \donttest{
if (requireNamespace("ggplot2", quietly = TRUE) &&
    requireNamespace("psych", quietly = TRUE)) {
  demo <- sframe_demo_data()
  rr <- reliability_report(demo$responses, demo$instrument, omega = FALSE)
  sframe_plot_reliability(rr)
}

# }
```
