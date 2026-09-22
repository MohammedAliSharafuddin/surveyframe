# Bootstrap confidence interval for eta squared

Percentile bootstrap for the proportion of variance in `outcome`
explained by `group`, resampling observations jointly so the group
structure travels with each resample.

## Usage

``` r
eta_sq_ci(outcome, group, R = 2000, conf.level = 0.95, seed = NULL)
```

## Arguments

- outcome:

  A numeric vector.

- group:

  A grouping vector of the same length.

- R:

  Integer. Number of bootstrap resamples. Defaults to 2000.

- conf.level:

  Confidence level. Defaults to 0.95.

- seed:

  Integer or NULL. When supplied, sets the random seed.

## Value

A named numeric vector: `estimate`, `lower`, `upper`, with attributes
`resamples`, `valid_resamples` and, when the interval is withheld,
`reason`. The bounds are `NA` when fewer than 90% of resamples give a
value, or when every resample gives the same value, since neither leaves
a sampling distribution to read. The bounds are `NA` with fewer than 3
complete observations or fewer than 2 groups.

## See also

[`bootstrap_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/bootstrap_ci.md)

## Examples

``` r
eta_sq_ci(mtcars$mpg, mtcars$cyl, seed = 42)
#>  estimate     lower     upper 
#> 0.7324601 0.6316254 0.8460837 
#> attr(,"resamples")
#> [1] 2000
#> attr(,"valid_resamples")
#> [1] 2000
```
