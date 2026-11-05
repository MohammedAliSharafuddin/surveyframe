# Plot analysis-plan results

Draws the charts that
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
attaches when called with `plots = TRUE`. With `which` supplied, returns
that single chart. With `which` omitted, prints every attached chart in
queue order and returns the list invisibly. Regression diagnostic panels
stay on the result's `diagnostic_plots` element and are not drawn here.

## Usage

``` r
# S3 method for class 'sframe_analysis_results'
plot(x, ..., which = NULL)
```

## Arguments

- x:

  An `sframe_analysis_results` object from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md).

- ...:

  Ignored.

- which:

  A research-question number or a plan block id selecting one chart, or
  NULL for all.

## Value

A ggplot2 object when `which` is supplied, otherwise an invisible named
list of ggplot2 objects keyed by plan block id.

## See also

Other Chart functions:
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
