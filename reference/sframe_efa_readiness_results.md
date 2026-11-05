# Prepare a survey instrument for exploratory factor analysis

Reports KMO sampling adequacy, Bartlett's test of sphericity, and a
parallel analysis scree plot to inform factor number selection. The
suggested number of factors from parallel analysis is returned in
`$suggested_nfactors`. The report prepares the researcher to estimate an
EFA solution with a separate package such as `psych` or `lavaan`.

## Usage

``` r
sframe_efa_readiness_results(
  data,
  instrument,
  scales = NULL,
  nfactors = NULL,
  rotation = "oblimin"
)
```

## Arguments

- data:

  A `tibble` or `data.frame` of responses.

- instrument:

  An `sframe` object.

- scales:

  Character vector or NULL. Scale IDs whose items to include. When NULL,
  all scale items are pooled.

- nfactors:

  Integer or NULL. Suggested number of factors to highlight on the scree
  plot. When NULL, the parallel analysis recommendation is used.

- rotation:

  Character. The rotation method to display in the diagnostic notes.
  Does not affect the diagnostics themselves. Defaults to `"oblimin"`.

## Value

An object of class `sframe_efa_report` with elements `kmo`, `bartlett`,
`parallel`, and `suggested_nfactors`.

## Fitting the solution

This report says whether the data suit a factor analysis and how many
factors to extract.
[`sframe_efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_solution.md)
then fits that solution and returns the loadings, so the whole route
stays in surveyframe. Take the result to another package when you want a
method surveyframe leaves out.

## See also

[`sframe_efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_solution.md),
[`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md),
[`sframe_syntax_cfa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_cfa.md)

Other Analyse functions:
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
[`sframe_assumption_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_assumption_results.md),
[`sframe_descriptives_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_descriptives_results.md),
[`sframe_efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_solution.md),
[`sframe_item_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item_results.md),
[`sframe_posthoc_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_posthoc_results.md),
[`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md),
[`sframe_validity_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validity_results.md)

## Examples

``` r
# \donttest{
if (requireNamespace("psych", quietly = TRUE)) {
  demo <- sframe_demo("tourism_services")
  er <- sframe_efa_readiness_results(demo$responses, demo$instrument)
  print(er)
}
#> EFA Readiness Diagnostics
#> 
#>   Items:          12
#>   Complete cases: 120
#>   KMO overall:    0.761
#>   Bartlett chi-sq: 665.84  df: 66  p: 0.0000
#>   Suggested factors (parallel analysis): 4
#>   Planned rotation: oblimin
#> 
#> Note: estimate the EFA solution with a dedicated modelling package.
# }
```
