# Prepare a survey instrument for exploratory factor analysis

Reports KMO sampling adequacy, Bartlett's test of sphericity, and a
parallel analysis scree plot to inform factor number selection. The
suggested number of factors from parallel analysis is returned in
`$suggested_nfactors`. The report prepares the researcher to estimate an
EFA solution with a separate package such as `psych` or `lavaan`.

## Usage

``` r
efa_report(
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

## See also

[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md),
[`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md)

## Examples

``` r
# \donttest{
if (requireNamespace("psych", quietly = TRUE)) {
  demo <- sframe_demo_data()
  er <- efa_report(demo$responses, demo$instrument)
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
