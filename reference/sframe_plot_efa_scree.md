# Scree plot from an EFA readiness report

Plots the parallel-analysis eigenvalues from
[`efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_report.md)
(both the observed factor-analysis eigenvalues and the simulated
comparison line), with the suggested factor count marked.

## Usage

``` r
sframe_plot_efa_scree(x, palette = c("web", "print"))
```

## Arguments

- x:

  An `sframe_efa_report` object from
  [`efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_report.md).

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object.

## See also

[`efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_report.md)
