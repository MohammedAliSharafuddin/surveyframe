# Term co-occurrence network plot

Plots a `co_occurrence_network` result's node table (`term`,
`frequency`, `cluster`, `x`, `y`) as a network diagram: edges (from
`result$edges`) as line segments underneath, nodes as points sized by
term frequency and coloured by Louvain cluster, with term labels on the
larger points only. Labelling every point on a dense network risks
overlap chaos, so only the top 15 nodes by frequency are labelled, and
the full term list stays available in `result$table`.

## Usage

``` r
sframe_plot_cooccurrence_network(result, palette = c("web", "print"))
```

## Arguments

- result:

  A `co_occurrence_network` result list from
  [`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md),
  carrying `table` and `edges`.

- palette:

  One of `"web"` (brand colours) or `"print"` (black, grey and white).
  See
  [`theme_surveyframe()`](https://surveyframe.org/reference/theme_surveyframe.md).

## Value

A ggplot2 object, or `NULL` when the result carries no table.

## Details

Clusters beyond the first 8 (ranked largest first) are folded into a
single "Other" group with 1 colour, so every colour on the chart stays
distinct.

## See also

[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md)

Other Chart functions:
[`plot.sframe_analysis_results()`](https://surveyframe.org/reference/plot.sframe_analysis_results.md),
[`sframe_plot_cooccurrence()`](https://surveyframe.org/reference/sframe_plot_cooccurrence.md),
[`sframe_plot_correlation_matrix()`](https://surveyframe.org/reference/sframe_plot_correlation_matrix.md),
[`sframe_plot_decision_ranking()`](https://surveyframe.org/reference/sframe_plot_decision_ranking.md),
[`sframe_plot_dematel_influence()`](https://surveyframe.org/reference/sframe_plot_dematel_influence.md),
[`sframe_plot_descriptives()`](https://surveyframe.org/reference/sframe_plot_descriptives.md),
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
if (requireNamespace("ggplot2", quietly = TRUE) &&
    requireNamespace("igraph", quietly = TRUE)) {
  demo <- sframe_demo("open_text")
  res <- run_analysis_plan(demo$responses, demo$instrument)
  sframe_plot_cooccurrence_network(res$RQ6)
}
# }
```
