# Choosing a plot

surveyframe draws in 3 ways, and which one fits depends on what you
already hold.

## From a report or a set of results

Every report that has a natural chart carries a
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method, so a
report draws without naming a helper:

- `plot(reliability_report(...))` draws one report.

- `plot(results)` draws each block of an analysis that has a chart.

- `plot(results, which = "RQ1")` selects one block by its ID.

This is the shortest route, and it is the one to reach for first.

## From a helper, by what it takes

The helpers exist for assembling a custom report, where you need one
chart on its own terms. They differ in what they accept and in what
comes back.

- **A report object, giving 1 plot:**

  - [`sframe_plot_reliability()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_reliability.md)

  - [`sframe_plot_validity()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_validity.md)

  - [`sframe_plot_quality()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_quality.md)

  - [`sframe_plot_missingness()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_missingness.md)

  - [`sframe_plot_efa_scree()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_efa_scree.md)

  - [`sframe_plot_efa_loadings()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_efa_loadings.md)

- **Responses with the instrument, giving 1 plot:**

  - [`sframe_plot_item_chart()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_item_chart.md)

  - [`sframe_plot_scale_chart()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_scale_chart.md)

  - [`sframe_plot_likert_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_likert_matrix.md)

  - [`sframe_plot_likert_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_likert_scale.md)

  - [`sframe_plot_correlation_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_correlation_matrix.md)

  - [`sframe_plot_descriptives()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_descriptives.md)

- **One block's result, giving 1 plot:**

  - [`sframe_plot_group_comparison()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_group_comparison.md)

  - [`sframe_plot_paired_comparison()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_paired_comparison.md)

  - [`sframe_plot_decision_ranking()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_decision_ranking.md)

  - [`sframe_plot_dematel_influence()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_dematel_influence.md)

- **A regression result, giving 4 panels as a list:**

  - [`sframe_plot_regression_diagnostics()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_regression_diagnostics.md)

- **Responses and 1 column, giving 3 panels as a list:**

  - [`sframe_plot_variable_distribution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_variable_distribution.md)

- **A text result, giving 1 plot:**

  - [`sframe_plot_term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_term_frequency.md)

  - [`sframe_plot_ngram_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_ngram_frequency.md)

  - [`sframe_plot_cooccurrence()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_cooccurrence.md)

  - [`sframe_plot_cooccurrence_network()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_cooccurrence_network.md)

  - [`sframe_plot_sentiment()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_sentiment.md)

  - [`sframe_plot_topics()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_topics.md)

A helper that finds nothing to draw returns `NULL`, so guard the result
where a report has to keep rendering.

## Integration helpers

[`sframe_draw_mosaic()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_draw_mosaic.md)
and
[`sframe_draw_likert_diverging()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_draw_likert_diverging.md)
draw into an open device for the generated reports, and stay exported so
those reports keep working.
[`sframe_likert_scale_groups()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_likert_scale_groups.md)
finds the scales whose items share a choice set, which is how a report
groups them. Take the results they draw from
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md).

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
