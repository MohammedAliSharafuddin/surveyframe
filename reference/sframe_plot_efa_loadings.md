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
  (white-to-black gradient by magnitude, with sign conveyed by the
  printed label rather than colour, so it stays legible in monochrome).
  See `sframe_brand()`.

## Value

A ggplot2 object.

## See also

[`efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_solution.md)

## Examples

``` r
# \donttest{
if (requireNamespace("ggplot2", quietly = TRUE) &&
    requireNamespace("psych", quietly = TRUE)) {
  demo <- sframe_demo_data()
  fit <- efa_solution(demo$responses, demo$instrument,
                       scales = "service_quality", nfactors = 1)
  sframe_plot_efa_loadings(fit)
}

# }
```
