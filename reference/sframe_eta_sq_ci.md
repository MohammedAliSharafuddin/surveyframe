# Confidence interval for eta squared

The noncentrality interval for the proportion of variance in `outcome`
explained by `group`, as
`effectsize::eta_squared(partial = FALSE, alternative = "two.sided")`
computes it for a one-way ANOVA: the 2-sided interval for the
noncentrality \\\lambda\\ of the F statistic, each bound turned into
\\\lambda / (\lambda + df\_{error})\\. The interval reaches 0 when the
test is far from significant. Until 0.4.3 this was a percentile
bootstrap, whose resampled eta squared is 0 or above, so 40 samples with
equal group means all had an interval above 0 (FR-24).

## Usage

``` r
sframe_eta_sq_ci(outcome, group, R = 2000, conf.level = 0.95, seed = NULL)
```

## Arguments

- outcome:

  A numeric vector.

- group:

  A grouping vector of the same length.

- R:

  Kept so existing calls still run. Unused since 0.4.3.

- conf.level:

  Confidence level. Defaults to 0.95.

- seed:

  Kept so existing calls still run. Unused since 0.4.3, as the interval
  uses no resampling.

## Value

A named numeric vector: `estimate`, `lower`, `upper`, with the
attributes `level` and `method` (`"noncentral F"`). The bounds are `NA`
with fewer than 3 complete observations, fewer than 2 groups, or no
variation within the groups.

## See also

[`sframe_cramers_v_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_cramers_v_ci.md),
[`sframe_bootstrap_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_bootstrap_ci.md)

Other Confidence interval functions:
[`sframe_bootstrap_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_bootstrap_ci.md),
[`sframe_cohens_d_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_cohens_d_ci.md),
[`sframe_cramers_v_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_cramers_v_ci.md)

## Examples

``` r
sframe_eta_sq_ci(mtcars$mpg, mtcars$cyl)
#>  estimate     lower     upper 
#> 0.7324601 0.5362175 0.8285950 
#> attr(,"level")
#> [1] 0.95
#> attr(,"method")
#> [1] "noncentral F"
```
