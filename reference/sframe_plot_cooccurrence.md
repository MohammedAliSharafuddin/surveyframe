# Term co-occurrence heatmap

Tile heatmap of pairwise within-response term co-occurrence counts for a
`co_occurrence` result. The result's edge list (`term_a`, `term_b`, `n`)
is pivoted into a full symmetric term-by-term grid before plotting, so
each pair's tile appears twice, once on either side of the diagonal, the
way the other tile heatmaps in this file
([`sframe_plot_correlation_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_correlation_matrix.md),
[`sframe_plot_efa_loadings()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_efa_loadings.md))
read as a full grid rather than a triangle.

## Usage

``` r
sframe_plot_cooccurrence(result, palette = c("web", "print"))
```

## Arguments

- result:

  A `co_occurrence` result list from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md).

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` when the result carries no table.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/term_frequency.md)
