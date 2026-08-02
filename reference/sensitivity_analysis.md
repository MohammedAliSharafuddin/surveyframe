# Test how far a decision ranking moves when the weights are perturbed

Perturbs each criterion weight up and down by `delta`, renormalises the
weight vector to sum to 1, reruns the same ranking method, and compares
the perturbed ranking against the base ranking. A ranking that survives
this unchanged is one a reviewer can be told is robust to the weights. A
ranking whose leader changes under a 5 percent nudge is not.

## Usage

``` r
sensitivity_analysis(
  x,
  weights,
  criteria_types,
  method = "topsis",
  delta = 0.05,
  alternatives = NULL,
  criteria = NULL,
  ...
)
```

## Arguments

- x:

  Numeric performance matrix, alternatives in rows and criteria in
  columns.

- weights:

  Numeric weight vector, one per criterion. Renormalised to sum to 1
  before use.

- criteria_types:

  Character vector of `"benefit"` or `"cost"`, one per criterion.

- method:

  Ranking method. One of `"topsis"`, `"vikor"`, `"moora"`, `"smart"`,
  `"waspas"`, `"promethee"`, or `"electre"`.

- delta:

  Perturbation size as a proportion of the weight, default `0.05`. A
  weight of 0.40 with `delta = 0.05` is tested at 0.42 and 0.38 before
  renormalisation.

- alternatives:

  Optional labels for the rows of `x`.

- criteria:

  Optional labels for the columns of `x`.

- ...:

  Passed to the underlying method, for example `v` for VIKOR or `lambda`
  for WASPAS.

## Value

An object of class `sframe_sensitivity`, a list with `$table` (one row
per criterion and direction, carrying `criterion`, `direction`, `rho`,
`rank_changed`, and `top_changed`), `$base_ranks`, `$method`, `$delta`,
and `$stable`, a single logical that is `TRUE` when no perturbation
changed the ranking.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`sframe_decision_options()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_decision_options.md)

## Examples

``` r
x <- matrix(c(4.1, 3.0, 210, 3.6, 4.5, 180, 4.8, 2.5, 260),
            nrow = 3, byrow = TRUE)
sa <- sensitivity_analysis(
  x,
  weights        = c(0.4, 0.3, 0.3),
  criteria_types = c("benefit", "benefit", "cost"),
  method         = "topsis",
  alternatives   = c("Alpha", "Basilica", "Coral"),
  criteria       = c("service", "location", "price")
)
sa$stable
#> [1] TRUE
sa$table
#>   criterion direction weight rho rank_changed top_changed
#> 1   service        up 0.4118   1        FALSE       FALSE
#> 2   service      down 0.3878   1        FALSE       FALSE
#> 3  location        up 0.3103   1        FALSE       FALSE
#> 4  location      down 0.2893   1        FALSE       FALSE
#> 5     price        up 0.3103   1        FALSE       FALSE
#> 6     price      down 0.2893   1        FALSE       FALSE
```
