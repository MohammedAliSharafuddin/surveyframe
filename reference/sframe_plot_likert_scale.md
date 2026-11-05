# Grouped diverging chart for a scale's Likert items

Several *separate* Likert items that make up one
[`sframe_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_scale.md)
(unlike a `"matrix"` item's rows, which are one question) are, by
default, each reported as their own single-item diverging chart. That
scatters a related batch of items (a satisfaction scale's 2-3 items,
say) across several charts instead of showing them the way a Likert
matrix or a typical multi-item satisfaction grid is reported: one
grouped chart, one diverging bar per item, sharing an x scale and a
legend. Applies only when every item in the scale shares the same choice
set. Scales that mix response scales fall back to one chart per item.

## Usage

``` r
sframe_plot_likert_scale(
  items,
  data,
  choice_set,
  title,
  palette = c("web", "print")
)
```

## Arguments

- items:

  A list of `"likert"` sframe items belonging to one scale, in display
  order.

- data:

  The response data.frame, with one column per item id.

- choice_set:

  The shared choice set object (`values`, `labels`).

- title:

  Chart title, typically the scale's label.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` if no item has response data.

## See also

[`sframe_plot_likert_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_likert_matrix.md),
[`sframe_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_scale.md)

Other Chart functions:
[`plot.sframe_analysis_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/plot.sframe_analysis_results.md),
[`sframe_plot_cooccurrence()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_cooccurrence.md),
[`sframe_plot_cooccurrence_network()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_cooccurrence_network.md),
[`sframe_plot_correlation_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_correlation_matrix.md),
[`sframe_plot_decision_ranking()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_decision_ranking.md),
[`sframe_plot_dematel_influence()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_dematel_influence.md),
[`sframe_plot_descriptives()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_descriptives.md),
[`sframe_plot_efa_loadings()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_efa_loadings.md),
[`sframe_plot_efa_scree()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_efa_scree.md),
[`sframe_plot_group_comparison()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_group_comparison.md),
[`sframe_plot_likert_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_likert_matrix.md),
[`sframe_plot_missingness()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_missingness.md),
[`sframe_plot_ngram_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_ngram_frequency.md),
[`sframe_plot_paired_comparison()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_paired_comparison.md),
[`sframe_plot_quality()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_quality.md),
[`sframe_plot_regression_diagnostics()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_regression_diagnostics.md),
[`sframe_plot_reliability()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_reliability.md),
[`sframe_plot_sentiment()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_sentiment.md),
[`sframe_plot_term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_term_frequency.md),
[`sframe_plot_topics()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_topics.md),
[`sframe_plot_validity()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_validity.md),
[`sframe_plot_variable_distribution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_variable_distribution.md),
[`sframe_plots`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plots.md),
[`theme_surveyframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/theme_surveyframe.md)

## Examples

``` r
# \donttest{
if (requireNamespace("ggplot2", quietly = TRUE)) {
  demo <- sframe_demo("likert_scale")
  groups <- sframe_likert_scale_groups(demo$instrument)
  g <- groups[["organisation"]]
  sframe_plot_likert_scale(g$items, demo$responses, g$choice_set, g$title)
}
#> Error in sframe_likert_scale_groups(demo$instrument): could not find function "sframe_likert_scale_groups"
# }
```
