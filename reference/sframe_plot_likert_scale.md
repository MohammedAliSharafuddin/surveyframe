# Grouped diverging chart for a scale's Likert items

*Separate* Likert items that make up one
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md)
(unlike a `"matrix"` item's rows, which are one question) are, by
default, each reported as their own single-item diverging chart. That
scatters a related batch of items (a satisfaction scale's 2-3 items,
say) across separate charts instead of showing them the way a Likert
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

[`sframe_plot_likert_matrix()`](https://surveyframe.org/reference/sframe_plot_likert_matrix.md),
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md)

Other Chart functions:
[`plot.sframe_analysis_results()`](https://surveyframe.org/reference/plot.sframe_analysis_results.md),
[`sframe_plot_cooccurrence()`](https://surveyframe.org/reference/sframe_plot_cooccurrence.md),
[`sframe_plot_cooccurrence_network()`](https://surveyframe.org/reference/sframe_plot_cooccurrence_network.md),
[`sframe_plot_correlation_matrix()`](https://surveyframe.org/reference/sframe_plot_correlation_matrix.md),
[`sframe_plot_decision_ranking()`](https://surveyframe.org/reference/sframe_plot_decision_ranking.md),
[`sframe_plot_dematel_influence()`](https://surveyframe.org/reference/sframe_plot_dematel_influence.md),
[`sframe_plot_descriptives()`](https://surveyframe.org/reference/sframe_plot_descriptives.md),
[`sframe_plot_efa_loadings()`](https://surveyframe.org/reference/sframe_plot_efa_loadings.md),
[`sframe_plot_efa_scree()`](https://surveyframe.org/reference/sframe_plot_efa_scree.md),
[`sframe_plot_group_comparison()`](https://surveyframe.org/reference/sframe_plot_group_comparison.md),
[`sframe_plot_likert_matrix()`](https://surveyframe.org/reference/sframe_plot_likert_matrix.md),
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
  scale <- sframe_get_scales(demo$instrument)[["organisation"]]
  items <- sframe_get_items(demo$instrument)[scale$items]
  agree <- sframe_get_choice_sets(demo$instrument)[["agree5"]]
  sframe_plot_likert_scale(items, demo$responses, agree, scale$label)
}
# }
```
