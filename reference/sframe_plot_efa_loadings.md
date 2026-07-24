# Loadings heatmap from a fitted EFA solution

Loadings heatmap from a fitted EFA solution

## Usage

``` r
sframe_plot_efa_loadings(x, palette = c("web", "print"))
```

## Arguments

- x:

  An `sframe_efa_solution` object from
  [`efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_solution.md).

- palette:

  One of `"web"` (diverging red/teal gradient) or `"print"`
  (white-to-black gradient by magnitude; sign is conveyed by the printed
  label, not colour, so it stays legible in monochrome). See
  `sframe_brand()`.

## Value

A ggplot2 object.

## See also

[`efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_solution.md)
