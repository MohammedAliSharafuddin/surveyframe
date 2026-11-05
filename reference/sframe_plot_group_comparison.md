# Group-comparison boxplot

Boxplot with jittered points, shared across every runner whose result
carries `vars = c(group_column, outcome_column)`: `t_test_ind`,
`mann_whitney`, `kruskal_wallis`, and `anova_one`. One function instead
of four, since the underlying comparison (an outcome split by a grouping
factor) and the data shape needed to plot it are identical across all
four tests, and only the inferential statistic differs.

## Usage

``` r
sframe_plot_group_comparison(result, data, palette = c("web", "print"))
```

## Arguments

- result:

  A result list from one of the four runners above, with
  `vars = c(group_column, outcome_column)`.

- data:

  The response data frame the result was computed from.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` if the columns are missing, fewer than two
groups remain after removing missing values, or ggplot2 is unavailable.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)

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
[`sframe_plot_likert_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_likert_matrix.md),
[`sframe_plot_likert_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_likert_scale.md),
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
  demo <- sframe_demo("tourism_services")
  res <- run_analysis_plan(demo$responses, demo$instrument)
  sframe_plot_group_comparison(res$rq_visit_bi, demo$responses)
}
#> NULL
# }
```
