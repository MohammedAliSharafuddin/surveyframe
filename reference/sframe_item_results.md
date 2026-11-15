# Generate item-level diagnostics

Produces, for each item within each scale, the item-rest correlation,
floor and ceiling proportions, and the item mean and standard deviation.

## Usage

``` r
sframe_item_results(data, instrument, scales = NULL)
```

## Arguments

- data:

  A `tibble` or `data.frame` of responses.

- instrument:

  An `sframe` object.

- scales:

  Character vector or NULL. A subset of scale IDs to analyse. When NULL
  (default), all scales are included.

## Value

An object of class `sframe_item_report`: a named list with one element
per scale, each a list holding `scale_id`, `label` and `diagnostics`, a
data frame with one row per item and columns `item_id`, `mean`, `sd`,
`item_rest_r`, `floor_prop`, `ceiling_prop` and `n_missing`. The floor
and ceiling shares are proportions. `floor_pct` and `ceiling_pct`, their
names before 0.4.3, are kept as copies for 1 release.
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) stacks
every scale's diagnostics into one table.

## Details

Diagnostics use the scale's scoring orientation, so an item the scale
reverse-codes is reversed first, as in
[`score_scales()`](https://surveyframe.org/reference/score_scales.md)
and
[`sframe_reliability_results()`](https://surveyframe.org/reference/sframe_reliability_results.md).
The item-rest correlation is the correlation between an item and the sum
of the scale's other items. It is computed on respondents who answered
every item in the scale, the same rows
[`sframe_reliability_results()`](https://surveyframe.org/reference/sframe_reliability_results.md)
uses, and `n_missing` counts the item's own missing values in `data`.

Floor and ceiling are the proportions at the item's declared lowest and
highest response, taken from its choice set, slider limits or rating
maximum. They are `NA` for an item that declares no bounds, since the
sample's own extremes say nothing about a floor or ceiling effect.

## See also

[`sframe_reliability_results()`](https://surveyframe.org/reference/sframe_reliability_results.md),
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md)

Other Analyse functions:
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md),
[`score_scales()`](https://surveyframe.org/reference/score_scales.md),
[`sframe_assumption_results()`](https://surveyframe.org/reference/sframe_assumption_results.md),
[`sframe_descriptives_results()`](https://surveyframe.org/reference/sframe_descriptives_results.md),
[`sframe_efa_readiness_results()`](https://surveyframe.org/reference/sframe_efa_readiness_results.md),
[`sframe_efa_solution()`](https://surveyframe.org/reference/sframe_efa_solution.md),
[`sframe_posthoc_results()`](https://surveyframe.org/reference/sframe_posthoc_results.md),
[`sframe_reliability_results()`](https://surveyframe.org/reference/sframe_reliability_results.md),
[`sframe_validity_results()`](https://surveyframe.org/reference/sframe_validity_results.md)

## Examples

``` r
# \donttest{
demo <- sframe_demo("likert_scale")
ir <- sframe_item_results(demo$responses, demo$instrument)
print(ir)
# one scale's diagnostics
ir[[1]]$diagnostics
# every scale in one table
as.data.frame(ir)
# }
```
