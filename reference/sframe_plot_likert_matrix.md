# Grouped diverging chart for a Likert matrix question

A matrix question asks 2 or more rows against one shared response scale
(a "grid" of Likert items). Plotting each row as its own separate
`sframe_draw_likert_diverging()` chart loses the grouping the question
was designed with, so this draws every row as one diverging bar inside a
single chart, sharing one x scale and one legend, the standard way a
Likert matrix is reported (compare a typical multi-item satisfaction
grid). Same diverging-stack convention as the single-item chart: the
middle category of an odd-length scale is neutral and split evenly
across the zero line, and colour saturation increases toward each pole.

## Usage

``` r
sframe_plot_likert_matrix(item, data, choice_set, palette = c("web", "print"))
```

## Arguments

- item:

  A `"matrix"` sframe item, with `matrix_items` (the row labels) and a
  `choice_set` naming the shared response scale.

- data:

  The response data.frame, with one expanded `<item id>__<row label>`
  column per matrix row, as produced by
  [`read_responses()`](https://surveyframe.org/reference/read_responses.md).

- choice_set:

  The item's choice set object (`values`, `labels`), typically looked up
  from `instrument$choices` by `item$choice_set`.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` if no row has response data.

## See also

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
  demo <- sframe_demo("matrix_likert")
  item <- Filter(function(i) i$type == "matrix", demo$instrument$items)[[1]]
  cs   <- Filter(function(c) c$id == item$choice_set, demo$instrument$choices)[[1]]
  sframe_plot_likert_matrix(item, demo$responses, cs)
}
# }
```
