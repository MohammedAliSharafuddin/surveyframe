# Missing-data report plot: missingness rate by item

Missing-data report plot: missingness rate by item

## Usage

``` r
sframe_plot_missingness(x, palette = c("web", "print"))
```

## Arguments

- x:

  An `sframe_missing_data_report` object from
  [`missing_data_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/missing_data_report.md).

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object. When no item has missing values, this is a short "no
missing responses" message rather than an empty bar chart.

## See also

[`missing_data_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/missing_data_report.md)
