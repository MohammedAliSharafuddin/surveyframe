# Sample-size and power planning helper

Estimates a total sample size for a planned analysis. The targets use 3
different methods, and the result says which one applied.

## Usage

``` r
sample_size_plan(
  type = c("proportion", "mean", "correlation", "t_test", "anova", "regression", "sem"),
  margin_error = NULL,
  sd = NULL,
  p = 0.5,
  r = NULL,
  alpha = 0.05,
  power = 0.8,
  groups = 2L,
  predictors = NULL,
  d = NULL,
  f = NULL,
  f2 = NULL
)
```

## Arguments

- type:

  Planning target: `"proportion"`, `"mean"`, `"correlation"`,
  `"t_test"`, `"anova"`, `"regression"`, or `"sem"`.

- margin_error:

  Margin of error for mean/proportion planning.

- sd:

  Standard deviation for mean planning.

- p:

  Expected proportion.

- r:

  Expected correlation. Defaults to 0.30 with a warning.

- alpha:

  Significance level.

- power:

  Desired power, for the power calculations.

- groups:

  Number of groups for ANOVA planning. A t test has 2.

- predictors:

  Number of predictors for regression planning.

- d:

  Expected Cohen's d for a t test. Defaults to 0.5 with a warning.

- f:

  Expected Cohen's f for ANOVA. Defaults to 0.25 with a warning.

- f2:

  Expected Cohen's f squared for regression. When `NULL`, a rule of
  thumb is returned in place of a power calculation.

## Value

An `sframe_sample_size_plan` list holding `type`, `estimated_n` (total
sample size), `method` (`"power"`, `"precision"`, `"rule_of_thumb"` or
`"none"`), `alpha`, `power`, `effect_size`, `warnings`, `advisory` and
`prompt`.

## Power calculations

`"t_test"`, `"anova"` and `"correlation"` are power calculations, so
`alpha`, `power` and the expected effect size all change the result. The
t test uses
[`stats::power.t.test()`](https://rdrr.io/r/stats/power.t.test.html) for
2 independent groups with Cohen's `d`. ANOVA uses
[`stats::power.anova.test()`](https://rdrr.io/r/stats/power.anova.test.html)
with Cohen's `f`. Correlation uses the Fisher z approximation with `r`.
`"regression"` is a power calculation when `f2` is supplied, from the
noncentral F distribution for the overall test of `predictors`
predictors.

When the effect size is left `NULL`, a conventional medium effect is
assumed (`d` 0.5, `f` 0.25, `r` 0.30) and a warning names it. An assumed
effect is a placeholder. Supply the effect you expect from prior studies
or a pilot.

## Precision targets and rules of thumb

`"proportion"` and `"mean"` size a confidence interval to a margin of
error, and use `alpha` for its confidence level. `power` has no bearing
on them. `"regression"` without `f2` returns the larger of 2 published
rules of thumb, `50 + 8k` and `104 + k`, which ignore `alpha` and
`power`. `"sem"` returns no estimate. Both say so in the returned
warnings.

## Examples

``` r
plan <- sample_size_plan("t_test", d = 0.5, power = 0.80)
plan$estimated_n
#> [1] 128
plan$method
#> [1] "power"
```
