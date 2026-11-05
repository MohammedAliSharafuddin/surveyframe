# Validity report for construct models

Validity report for construct models

## Usage

``` r
sframe_validity_results(
  loadings,
  construct_scores = NULL,
  items_by_construct = NULL
)
```

## Arguments

- loadings:

  A data.frame with columns `construct`, `item`, and `loading`, or a
  named list of loading vectors by construct.

- construct_scores:

  Optional data.frame of construct scores for Fornell-Larcker and
  inter-construct correlations.

- items_by_construct:

  Optional named list, one element per construct, each a data.frame of
  that construct's item-level responses. When supplied, `htmt` is the
  Henseler heterotrait-monotrait ratio: the mean absolute
  heterotrait-heteromethod correlation over the geometric mean of the
  two constructs' mean absolute monotrait-heteromethod correlations.
  Constructs with a single item have no monotrait correlations, so their
  HTMT entries are `NA`. Without this argument, `htmt` falls back to the
  absolute inter-construct correlation matrix from `construct_scores`
  (the pre-0.3.4 behaviour). The `htmt_method` element records which was
  computed.

## Value

An object of class `sframe_validity_report`.

## See also

Other Analyse functions:
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
[`sframe_assumption_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_assumption_results.md),
[`sframe_descriptives_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_descriptives_results.md),
[`sframe_efa_readiness_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_readiness_results.md),
[`sframe_efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_solution.md),
[`sframe_item_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item_results.md),
[`sframe_posthoc_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_posthoc_results.md),
[`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md)

## Examples

``` r
loadings <- list(
  sq  = c(sq_1 = 0.80, sq_2 = 0.75, sq_3 = 0.78),
  sat = c(sat_1 = 0.85, sat_2 = 0.82)
)
vr <- sframe_validity_results(loadings)
vr$reliability
#>     construct composite_reliability       AVE n_items
#> sat       sat             0.8217148 0.6974500       2
#> sq         sq             0.8203234 0.6036333       3
```
