# Criterion weights collected from respondents

Resolves a weight vector from either kind of collected weight item, so
that a ranking runner never has to know which one the researcher used. A
`"criteria_weight"` item is renormalised to sum 1 per respondent before
the arithmetic mean is taken, so a respondent who allocated 90 points in
total carries the same influence as one who allocated exactly 100. A
`"pairwise_comparison"` item is assembled, aggregated geometrically, and
reduced to its principal eigenvector.

## Usage

``` r
sframe_collected_weights(data, instrument, item_id, cr_filter = FALSE)
```

## Arguments

- data:

  A data frame of responses.

- instrument:

  An `sframe` instrument declaring `item_id`.

- item_id:

  Character. A `"criteria_weight"` or `"pairwise_comparison"` item id.

- cr_filter:

  Logical. Passed to
  [`sframe_aggregate_judgements()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_aggregate_judgements.md)
  for a pairwise item. Ignored otherwise.

## Value

A list with `weights` (a named numeric vector summing to 1), `criteria`,
`source`, `item_id`, `n_respondents`, `n_dropped`, and `consistency`
(pairwise items only).

## See also

[`sframe_assemble_pairwise()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_assemble_pairwise.md)

Other Decision analysis functions:
[`sframe_aggregate_judgements()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_aggregate_judgements.md),
[`sframe_assemble_pairwise()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_assemble_pairwise.md),
[`sframe_decision_options()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_decision_options.md),
[`sframe_dematel_compute()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_dematel_compute.md),
[`sframe_rated_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_rated_matrix.md),
[`sframe_sensitivity_analysis()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_sensitivity_analysis.md)

## Examples

``` r
study <- sframe_instrument(
  title = "Demo", components = list(
    sframe_item("pts", "Divide 100 points", type = "criteria_weight",
            comparison_items = c("price", "speed"))
  )
)
sframe_collected_weights(
  data.frame(pts__price = c(60, 40), pts__speed = c(40, 60)), study, "pts"
)$weights
#> price speed 
#>   0.5   0.5 
```
