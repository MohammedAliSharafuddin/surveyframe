# Choosing a plot

surveyframe draws in 3 ways, and which one fits depends on what you
already hold.

## From a report or a set of results

Every report that has a natural chart carries a
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method, so a
report draws without naming a helper:

- `plot(sframe_reliability_results(...))` draws one report.

- `plot(results)` draws each block of an analysis that has a chart.

- `plot(results, which = "RQ1")` selects one block by its ID.

This is the shortest route, and it is the one to reach for first.

## From a helper, by what it takes

The helpers exist for assembling a custom report, where you need one
chart on its own terms. They differ in what they accept and in what
comes back.

- **A report object, giving 1 plot:**

  - [`sframe_plot_reliability()`](https://surveyframe.org/reference/sframe_plot_reliability.md)

  - [`sframe_plot_validity()`](https://surveyframe.org/reference/sframe_plot_validity.md)

  - [`sframe_plot_quality()`](https://surveyframe.org/reference/sframe_plot_quality.md)

  - [`sframe_plot_missingness()`](https://surveyframe.org/reference/sframe_plot_missingness.md)

  - [`sframe_plot_efa_scree()`](https://surveyframe.org/reference/sframe_plot_efa_scree.md)

  - [`sframe_plot_efa_loadings()`](https://surveyframe.org/reference/sframe_plot_efa_loadings.md)

- **Responses with the instrument, giving 1 plot:**

  - [`sframe_plot_likert_matrix()`](https://surveyframe.org/reference/sframe_plot_likert_matrix.md)

  - [`sframe_plot_likert_scale()`](https://surveyframe.org/reference/sframe_plot_likert_scale.md)

  - [`sframe_plot_correlation_matrix()`](https://surveyframe.org/reference/sframe_plot_correlation_matrix.md)

  - [`sframe_plot_descriptives()`](https://surveyframe.org/reference/sframe_plot_descriptives.md)

- **One block's result, giving 1 plot:**

  - [`sframe_plot_group_comparison()`](https://surveyframe.org/reference/sframe_plot_group_comparison.md)

  - [`sframe_plot_paired_comparison()`](https://surveyframe.org/reference/sframe_plot_paired_comparison.md)

  - [`sframe_plot_decision_ranking()`](https://surveyframe.org/reference/sframe_plot_decision_ranking.md)

  - [`sframe_plot_dematel_influence()`](https://surveyframe.org/reference/sframe_plot_dematel_influence.md)

- **A regression result, giving 4 panels as a list:**

  - [`sframe_plot_regression_diagnostics()`](https://surveyframe.org/reference/sframe_plot_regression_diagnostics.md)

- **Responses and 1 column, giving 3 panels as a list:**

  - [`sframe_plot_variable_distribution()`](https://surveyframe.org/reference/sframe_plot_variable_distribution.md)

- **A text result, giving 1 plot:**

  - [`sframe_plot_term_frequency()`](https://surveyframe.org/reference/sframe_plot_term_frequency.md)

  - [`sframe_plot_ngram_frequency()`](https://surveyframe.org/reference/sframe_plot_ngram_frequency.md)

  - [`sframe_plot_cooccurrence()`](https://surveyframe.org/reference/sframe_plot_cooccurrence.md)

  - [`sframe_plot_cooccurrence_network()`](https://surveyframe.org/reference/sframe_plot_cooccurrence_network.md)

  - [`sframe_plot_sentiment()`](https://surveyframe.org/reference/sframe_plot_sentiment.md)

  - [`sframe_plot_topics()`](https://surveyframe.org/reference/sframe_plot_topics.md)

A helper that finds nothing to draw returns `NULL`, so guard the result
where a report has to keep rendering.

## See also

[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md),
[`render_report()`](https://surveyframe.org/reference/render_report.md)

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
[`theme_surveyframe()`](https://surveyframe.org/reference/theme_surveyframe.md)
