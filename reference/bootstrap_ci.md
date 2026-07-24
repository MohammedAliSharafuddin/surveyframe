# Percentile bootstrap confidence interval for a statistic

Resamples `x` with replacement `R` times, applies `FUN` to each
resample, and returns the percentile interval of the resampled
statistics together with the observed value.

## Usage

``` r
bootstrap_ci(x, FUN = stats::median, R = 2000, conf.level = 0.95, seed = NULL)
```

## Arguments

- x:

  A numeric vector.

- FUN:

  A function of one vector returning a single number. Defaults to
  [`stats::median()`](https://rdrr.io/r/stats/median.html).

- R:

  Integer. Number of bootstrap resamples. Defaults to 2000.

- conf.level:

  Confidence level. Defaults to 0.95.

- seed:

  Integer or NULL. When supplied, sets the random seed so the interval
  is reproducible.

## Value

A named numeric vector: `estimate`, `lower`, `upper`. The bounds are
`NA` when `x` has fewer than 3 finite values.

## See also

[`cohens_d_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cohens_d_ci.md),
[`cramers_v_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cramers_v_ci.md),
[`eta_sq_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/eta_sq_ci.md)

## Examples

``` r
bootstrap_ci(mtcars$mpg, seed = 42)
#> estimate    lower    upper 
#>    19.20    16.85    21.40 
bootstrap_ci(mtcars$mpg, FUN = mean, conf.level = 0.90, seed = 42)
#> estimate    lower    upper 
#> 20.09062 18.41875 21.80031 
```
