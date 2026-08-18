# Distribution shape by variable, standardised

One violin per variable in a
[`descriptives_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/descriptives_report.md)
table, built from the underlying response data rather than from the
summary skewness and kurtosis numbers, so the reader sees the actual
shape (asymmetry, multimodality, tails) instead of reading it off a bar
height. Each variable is standardised (z-scored) before plotting so
variables on different original scales (a 5-point Likert item next to a
0-100 slider) share one comparable y-axis. Standardising is a linear
transform and does not change skewness. Each violin's subtitle-free
panel keeps the variable's skewness value in its axis label. Grouped
[`descriptives_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/descriptives_report.md)
output (one row per variable per `split_by` group) is faceted by group.

## Usage

``` r
sframe_plot_descriptives(x, data, palette = c("web", "print"))
```

## Arguments

- x:

  An `sframe_descriptives_report` object from
  [`descriptives_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/descriptives_report.md).

- data:

  The same data.frame passed to
  [`descriptives_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/descriptives_report.md).
  Required: `x` only carries the summary table, not the raw values the
  violins need.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` if none of the report's variables have
enough data to draw.

## See also

[`descriptives_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/descriptives_report.md)
