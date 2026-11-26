# Estimate an exploratory factor solution

Runs [`psych::fa()`](https://rdrr.io/pkg/psych/man/fa.html) on selected
item columns and returns loadings, communalities, uniqueness, variance
summaries and simple item retention flags. The `psych` package is
optional and is only required when this function is called.

## Usage

``` r
sframe_efa_solution(
  data,
  instrument,
  items = NULL,
  scales = NULL,
  nfactors = 1L,
  extraction = c("minres", "pa", "ml"),
  rotation = c("oblimin", "promax", "varimax"),
  min_loading = 0.3,
  cross_loading = 0.3
)
```

## Arguments

- data:

  A data.frame of responses.

- instrument:

  An `sframe` object.

- items:

  Character vector of item IDs. When `NULL`, scale items are used.

- scales:

  Optional scale IDs used to select item columns.

- nfactors:

  Integer. Number of factors. Defaults to 1.

- extraction:

  Extraction method passed to
  [`psych::fa()`](https://rdrr.io/pkg/psych/man/fa.html): `"minres"`
  (the default), `"pa"` or `"ml"`.

- rotation:

  Rotation method passed to
  [`psych::fa()`](https://rdrr.io/pkg/psych/man/fa.html): `"oblimin"`
  (the default), `"promax"` or `"varimax"`.

- min_loading:

  Minimum salient loading. Defaults to 0.3.

- cross_loading:

  Maximum secondary loading before a warning is raised. Defaults to 0.3.

## Value

An object of class `sframe_efa_solution`. Alongside the psych objects it
carries 3 tidy data frames ready for plotting and reporting:
`loadings_long` (item_id, factor, loading), `communalities_table`
(item_id, communality, uniqueness) and `variance_table` (factor,
ss_loadings, proportion_var, cumulative_var).

## See also

Other Analyse functions:
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md),
[`score_scales()`](https://surveyframe.org/reference/score_scales.md),
[`sframe_assumption_results()`](https://surveyframe.org/reference/sframe_assumption_results.md),
[`sframe_descriptives_results()`](https://surveyframe.org/reference/sframe_descriptives_results.md),
[`sframe_efa_readiness_results()`](https://surveyframe.org/reference/sframe_efa_readiness_results.md),
[`sframe_item_results()`](https://surveyframe.org/reference/sframe_item_results.md),
[`sframe_posthoc_results()`](https://surveyframe.org/reference/sframe_posthoc_results.md),
[`sframe_reliability_results()`](https://surveyframe.org/reference/sframe_reliability_results.md),
[`sframe_validity_results()`](https://surveyframe.org/reference/sframe_validity_results.md)

## Examples

``` r
# \donttest{
if (requireNamespace("psych", quietly = TRUE)) {
  demo <- sframe_demo("factor_structure")
  fit <- sframe_efa_solution(demo$responses, demo$instrument,
                       scales = c("organisation", "content"), nfactors = 2)
  fit$loadings
}
# }
```
