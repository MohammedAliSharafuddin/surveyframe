# Prepare a survey instrument for exploratory factor analysis

Reports KMO sampling adequacy, Bartlett's test of sphericity, and a
parallel analysis scree plot to inform factor number selection. This
function does not estimate or return an EFA solution; it prepares the
researcher to run one using a separate package such as `psych` or
`lavaan`.

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
if (FALSE) { # \dontrun{
er <- efa_report(responses, instr)
print(er)
} # }
```
