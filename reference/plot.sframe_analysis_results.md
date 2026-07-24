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
