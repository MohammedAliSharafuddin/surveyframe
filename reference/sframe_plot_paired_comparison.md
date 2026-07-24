# Paired-comparison slope plot

One line per respondent connecting their two paired values, shared by
`t_test_pair` and `wilcoxon_pair` (both carry
`vars = c(x_column, y_column)` on the same respondents). The standard
visual for a paired design: it shows the direction and consistency of
individual change, which a plain bar-of-means would hide.

## Usage

``` r
sframe_plot_paired_comparison(result, data, palette = c("web", "print"))
```

## Arguments

- result:

  A result list from `t_test_pair`/`wilcoxon_pair`, with
  `vars = c(x_column, y_column)`.

- data:

  The response data frame the result was computed from.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` if fewer than two complete pairs remain, or
ggplot2 is unavailable.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
