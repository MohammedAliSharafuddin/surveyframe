# Prominence-relation scatter for a DEMATEL result

The dedicated DEMATEL chart: one point per criterion, prominence (D + R)
on x and relation (D - R) on y, with a horizontal quadrant line at
relation = 0 separating causes (above) from effects (below). This is
deliberately a different shape from
[`sframe_plot_decision_ranking()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_decision_ranking.md):
DEMATEL classifies criteria on two axes rather than producing a single
ranked score, so a ranking bar chart would misrepresent it.

## Usage

``` r
sframe_plot_dematel_influence(result, palette = c("web", "print"))
```

## Arguments

- result:

  A `dematel`-family result list from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
  or `sframe_run_dematel()`, carrying `prominence`, `relation`, and
  `criteria`.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` when the result carries no DEMATEL fields to
plot.

## See also

[`sframe_plot_decision_ranking()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_decision_ranking.md)
