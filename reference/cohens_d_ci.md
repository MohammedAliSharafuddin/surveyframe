# Bootstrap confidence interval for Cohen's d

Percentile bootstrap for the standardised mean difference between two
independent groups. Each resample draws within each group, preserving
the group sizes.

## Usage

``` r
cohens_d_ci(x, y, R = 2000, conf.level = 0.95, seed = NULL)
```

## Arguments

- x, y:

  Numeric vectors, one per group.

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
a sampling distribution to read. The bounds are `NA` when either group
has fewer than 3 finite values.

## See also

[`bootstrap_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/bootstrap_ci.md)

## Examples

``` r
cohens_d_ci(mtcars$mpg[mtcars$am == 1], mtcars$mpg[mtcars$am == 0],
            seed = 42)
#>  estimate     lower     upper 
#> 1.4779471 0.7869318 2.5256596 
#> attr(,"resamples")
#> [1] 2000
#> attr(,"valid_resamples")
#> [1] 2000
```
