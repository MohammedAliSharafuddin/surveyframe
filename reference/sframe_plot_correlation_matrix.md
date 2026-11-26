# Correlation matrix heatmap

Computes and plots a full pairwise correlation matrix of the chosen
columns. A correlation block of
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md)
charts 1 pair of variables, and this chart shows every pair at once. It
is also the visual companion to the discriminant-validity checks of
[`sframe_validity_results()`](https://surveyframe.org/reference/sframe_validity_results.md).

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

  One of `"pearson"` (the default), `"spearman"` or `"kendall"`.

- palette:

  One of `"web"` (diverging red/teal gradient) or `"print"`
  (white-to-black gradient by magnitude, signed label). See
  [`theme_surveyframe()`](https://surveyframe.org/reference/theme_surveyframe.md).

## Value

A ggplot2 object.

## See also

[`sframe_validity_results()`](https://surveyframe.org/reference/sframe_validity_results.md)

Other Chart functions:
[`plot.sframe_analysis_results()`](https://surveyframe.org/reference/plot.sframe_analysis_results.md),
[`sframe_plot_cooccurrence()`](https://surveyframe.org/reference/sframe_plot_cooccurrence.md),
[`sframe_plot_cooccurrence_network()`](https://surveyframe.org/reference/sframe_plot_cooccurrence_network.md),
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
if (requireNamespace("ggplot2", quietly = TRUE)) {
  demo <- sframe_demo("correlation_regression")
  sframe_plot_correlation_matrix(demo$responses,
                                 c("sessions_attended", "networking_minutes",
                                   "overall_value", "age"))
}
# }
```
