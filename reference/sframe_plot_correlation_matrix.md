# Correlation matrix heatmap

Computes and plots a full pairwise correlation matrix, independent of
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)'s
pairwise `correlation_pearson`/`_spearman`/ `_kendall` runners (which
plot one variable pair at a time via `sframe_plot_correlation()`).
Useful directly, and as the visual companion to
[`validity_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validity_report.md)'s
discriminant-validity checks.

## Usage

``` r
sframe_plot_correlation_matrix(
  data,
  vars,
  method = "pearson",
  palette = c("web", "print")
)
```

## Arguments

- data:

  A data frame of survey responses.

- vars:

  Character vector of column names to correlate.

- method:

  One of `"pearson"`, `"spearman"`, `"kendall"`.

- palette:

  One of `"web"` (diverging red/teal gradient) or `"print"`
  (white-to-black gradient by magnitude, signed label). See
  `sframe_brand()`.

## Value

A ggplot2 object.

## See also

[`validity_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validity_report.md)
