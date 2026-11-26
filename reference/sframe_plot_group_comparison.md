# Group-comparison boxplot

Boxplot with jittered points for a `t_test_ind`, `mann_whitney`,
`kruskal_wallis` or `anova_one` block, whose result carries
`vars = c(group_column, outcome_column)`. The 4 tests compare the same
thing, an outcome split by a grouping factor, so 1 chart serves them
all.

## Usage

``` r
sframe_plot_group_comparison(result, data, palette = c("web", "print"))
```

## Arguments

- result:

  A result list from one of the 4 methods above, with
  `vars = c(group_column, outcome_column)`.

- data:

  The response data frame the result was computed from.

- palette:

  One of `"web"` (brand colours) or `"print"` (black, grey and white).
  See
  [`theme_surveyframe()`](https://surveyframe.org/reference/theme_surveyframe.md).

## Value

A ggplot2 object, or `NULL` if the columns are missing, fewer than 2
groups remain after removing missing values, or ggplot2 is unavailable.

## See also

[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md)

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
  demo <- sframe_demo("two_group")
  res <- run_analysis_plan(demo$responses, demo$instrument)
  sframe_plot_group_comparison(res$RQ1, demo$responses)
}
# }
```
