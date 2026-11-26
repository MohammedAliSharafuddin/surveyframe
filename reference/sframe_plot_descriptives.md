# Distribution shape by variable, standardised

One violin per variable in an
[`sframe_descriptives_results()`](https://surveyframe.org/reference/sframe_descriptives_results.md)
table, built from the underlying response data, so the reader sees the
shape that the skewness and kurtosis numbers summarise: asymmetry,
multimodality and tails. Each variable is standardised (z-scored) before
plotting so variables on different original scales (a 5-point Likert
item next to a 0-100 slider) share one comparable y-axis. Standardising
is a linear transform and does not change skewness. Each variable's axis
label gives its skewness. Grouped
[`sframe_descriptives_results()`](https://surveyframe.org/reference/sframe_descriptives_results.md)
output (one row per variable per `split_by` group) is faceted by group.

## Usage

``` r
sframe_plot_descriptives(x, data, palette = c("web", "print"))
```

## Arguments

- x:

  An `sframe_descriptives_report` object from
  [`sframe_descriptives_results()`](https://surveyframe.org/reference/sframe_descriptives_results.md).

- data:

  The same data.frame passed to
  [`sframe_descriptives_results()`](https://surveyframe.org/reference/sframe_descriptives_results.md).
  Required, because the violins need the raw values and `x` carries the
  summary table.

- palette:

  One of `"web"` (brand colours) or `"print"` (black, grey and white).
  See
  [`theme_surveyframe()`](https://surveyframe.org/reference/theme_surveyframe.md).

## Value

A ggplot2 object, or `NULL` if none of the report's variables have
enough data to draw.

## See also

[`sframe_descriptives_results()`](https://surveyframe.org/reference/sframe_descriptives_results.md)

Other Chart functions:
[`plot.sframe_analysis_results()`](https://surveyframe.org/reference/plot.sframe_analysis_results.md),
[`sframe_plot_cooccurrence()`](https://surveyframe.org/reference/sframe_plot_cooccurrence.md),
[`sframe_plot_cooccurrence_network()`](https://surveyframe.org/reference/sframe_plot_cooccurrence_network.md),
[`sframe_plot_correlation_matrix()`](https://surveyframe.org/reference/sframe_plot_correlation_matrix.md),
[`sframe_plot_decision_ranking()`](https://surveyframe.org/reference/sframe_plot_decision_ranking.md),
[`sframe_plot_dematel_influence()`](https://surveyframe.org/reference/sframe_plot_dematel_influence.md),
[`sframe_plot_efa_loadings()`](https://surveyframe.org/reference/sframe_plot_efa_loadings.md),
[`sframe_plot_efa_scree()`](https://surveyframe.org/reference/sframe_plot_efa_scree.md),
[`sframe_plot_group_comparison()`](https://surveyframe.org/reference/sframe_plot_group_comparison.md),
[`sframe_plot_likert_matrix()`](https://surveyframe.org/reference/sframe_plot_likert_matrix.md),
[`sframe_plot_likert_scale()`](https://surveyframe.org/reference/sframe_plot_likert_scale.md),
[`sframe_plot_missingness()`](https://surveyframe.org/reference/sframe_plot_missingness.md),
[`sframe_plot_ngram_frequency()`](https://surveyframe.org/reference/sframe_plot_ngram_frequency.md),
[`sframe_plot_paired_comparison()`](https://surveyframe.org/reference/sframe_plot_paired_comparison.md),
[`sframe_plot_quality()`](https://surveyframe.org/reference/sframe_plot_quality.md),
[`sframe_plot_regression_diagnostics()`](https://surveyframe.org/reference/sframe_plot_regression_diagnostics.md),
[`sframe_plot_reliability()`](https://surveyframe.org/reference/sframe_plot_reliability.md),
[`sframe_plot_sentiment()`](https://surveyframe.org/reference/sframe_plot_sentiment.md),
[`sframe_plot_term_frequency()`](https://surveyframe.org/reference/sframe_plot_term_frequency.md),
[`sframe_plot_topics()`](https://surveyframe.org/reference/sframe_plot_topics.md),
[`sframe_plot_validity()`](https://surveyframe.org/reference/sframe_plot_validity.md),
[`sframe_plot_variable_distribution()`](https://surveyframe.org/reference/sframe_plot_variable_distribution.md),
[`sframe_plots`](https://surveyframe.org/reference/sframe_plots.md),
[`theme_surveyframe()`](https://surveyframe.org/reference/theme_surveyframe.md)

## Examples

``` r
# \donttest{
if (requireNamespace("ggplot2", quietly = TRUE)) {
  demo <- sframe_demo("likert_scale")
  dr <- sframe_descriptives_results(demo$responses,
                                    variables = c("org_1", "org_2", "org_3", "org_4"))
  sframe_plot_descriptives(dr, demo$responses)
}
# }
```
