# Regression diagnostic plots for a regression_linear result

The four standard diagnostic panels (residuals vs fitted, normal Q-Q,
scale-location, residuals vs leverage), built from the plain data frame
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
attaches to a `regression_linear` result rather than the `lm` object
itself, so the result stays JSON-serialisable.

## Usage

``` r
sframe_plot_regression_diagnostics(result, palette = c("web", "print"))
```

## Arguments

- result:

  A `regression_linear` result list containing a `diagnostics` data
  frame (as produced internally by
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)).

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A named list of four ggplot2 objects (`residuals_fitted`, `qq`,
`scale_location`, `leverage`), or `NULL` if diagnostics are unavailable.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
