# Term co-occurrence network plot

Plots a `co_occurrence_network` result's node table (`term`,
`frequency`, `cluster`, `x`, `y`) as a network diagram: edges (from
`result$edges`) as line segments underneath, nodes as points sized by
term frequency and coloured by Louvain cluster, with term labels on the
larger points only. Labelling every point on a dense network risks
overlap chaos, so only the top 15 nodes by frequency are labelled; the
full term list stays available in `result$table`.

## Usage

``` r
sframe_plot_cooccurrence_network(result, palette = c("web", "print"))
```

## Arguments

- result:

  A `co_occurrence_network` result list from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
  carrying `table` and `edges`.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` when the result carries no table.

## Details

Clusters beyond the first 8 (ranked largest first) are folded into a
single "Other" bucket rather than cycling or interpolating a new hue,
per the dataviz skill's categorical-colour guidance; see
`.sframe_cluster_palette()`.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
