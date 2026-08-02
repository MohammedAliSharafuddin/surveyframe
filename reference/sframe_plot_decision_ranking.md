# Ranked-score bar chart for a decision-family result

The shared chart for every MCDM ranking method: one horizontal bar per
alternative, ordered best first, with the leading alternative picked
out. It is generic over the method rather than tied to one, so AHP
criterion weights and any ranking method's scores all draw through it.
The score column is whatever the method reports as its headline quantity
(a closeness coefficient, a net flow, a priority weight), so the axis is
labelled from the result rather than hard-coded.

## Usage

``` r
sframe_plot_decision_ranking(result, palette = c("web", "print"))
```

## Arguments

- result:

  A decision-family result list from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
  carrying either `scores` and `alternatives` or a ranking `table`.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` when the result carries no ranking.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
