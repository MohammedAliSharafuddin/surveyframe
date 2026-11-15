# Estimate scale reliability from item responses

Produces Cronbach's alpha and McDonald's omega for each scale defined in
the instrument, along with the number of items and sample size.

## Usage

``` r
sframe_reliability_results(
  data,
  instrument,
  scales = NULL,
  alpha = TRUE,
  omega = TRUE
)
```

## Arguments

- data:

  A `tibble` or `data.frame` of responses. Item columns must be present.

- instrument:

  An `sframe` object.

- scales:

  Character vector or NULL. A subset of scale IDs to analyse. When NULL
  (default), all scales in the instrument are included.

- alpha:

  Logical. Whether to compute Cronbach's alpha. Defaults to `TRUE`.

- omega:

  Logical. Whether to compute McDonald's omega. Defaults to `TRUE`.

## Value

An object of class `sframe_reliability_report`, a list with one element
per scale. Each element is a list of statistics and a summary tibble.

## See also

[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md),
[`sframe_item_results()`](https://surveyframe.org/reference/sframe_item_results.md)

Other Analyse functions:
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md),
[`score_scales()`](https://surveyframe.org/reference/score_scales.md),
[`sframe_assumption_results()`](https://surveyframe.org/reference/sframe_assumption_results.md),
[`sframe_descriptives_results()`](https://surveyframe.org/reference/sframe_descriptives_results.md),
[`sframe_efa_readiness_results()`](https://surveyframe.org/reference/sframe_efa_readiness_results.md),
[`sframe_efa_solution()`](https://surveyframe.org/reference/sframe_efa_solution.md),
[`sframe_item_results()`](https://surveyframe.org/reference/sframe_item_results.md),
[`sframe_posthoc_results()`](https://surveyframe.org/reference/sframe_posthoc_results.md),
[`sframe_validity_results()`](https://surveyframe.org/reference/sframe_validity_results.md)

## Examples

``` r
# \donttest{
if (requireNamespace("psych", quietly = TRUE)) {
  demo <- sframe_demo("tourism_services")
  rr <- sframe_reliability_results(demo$responses, demo$instrument, omega = FALSE)
  print(rr)
}
# }
```
