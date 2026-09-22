# Bootstrap confidence interval for Cramer's V

Percentile bootstrap for the association strength in a contingency
table. The table is expanded back to individual observations, which are
resampled jointly. For a 2 by 2 table the statistic equals phi.

## Usage

``` r
cramers_v_ci(tab, R = 2000, conf.level = 0.95, seed = NULL)
```

## Arguments

- tab:

  A contingency table (from
  [`table()`](https://rdrr.io/r/base/table.html)) or a matrix of counts.

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
a sampling distribution to read. The bounds are `NA` when the table
holds fewer than 3 observations.

## See also

[`bootstrap_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/bootstrap_ci.md)

## Examples

``` r
cramers_v_ci(table(mtcars$am, mtcars$cyl), seed = 42)
#>  estimate     lower     upper 
#> 0.5226355 0.2581670 0.8157627 
#> attr(,"resamples")
#> [1] 2000
#> attr(,"valid_resamples")
#> [1] 1998
```
