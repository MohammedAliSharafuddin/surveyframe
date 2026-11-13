# Confidence interval for Cramer's V

The noncentrality interval for the association strength in a contingency
table, as
`effectsize::cramers_v(adjust = FALSE, alternative = "two.sided")`
computes it: the 2-sided interval for the noncentrality of the
chi-square statistic, each bound turned into V as \\\sqrt{\lambda / (n
(k - 1))}\\, where k is the smaller of the number of rows and columns.
For a 2 by 2 table V equals phi. The interval reaches 0 when the test is
far from significant. Until 0.4.3 this was a percentile bootstrap, whose
resampled V is 0 or above, so an exactly independent table had the
interval \[0.05, 0.50\] beside V = 0 (FR-24).

## Usage

``` r
sframe_cramers_v_ci(tab, R = 2000, conf.level = 0.95, seed = NULL)
```

## Arguments

- tab:

  A contingency table (from
  [`table()`](https://rdrr.io/r/base/table.html)) or a matrix of counts.

- R:

  Kept so existing calls still run. Unused since 0.4.3.

- conf.level:

  Confidence level. Defaults to 0.95.

- seed:

  Kept so existing calls still run. Unused since 0.4.3, as the interval
  uses no resampling.

## Value

A named numeric vector: `estimate`, `lower`, `upper`, with the
attributes `level` and `method` (`"noncentral chi-square"`). The bounds
are `NA` when the table holds fewer than 3 observations or has fewer
than 2 rows or columns.

## See also

[`sframe_eta_sq_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_eta_sq_ci.md),
[`sframe_bootstrap_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_bootstrap_ci.md)

Other Confidence interval functions:
[`sframe_bootstrap_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_bootstrap_ci.md),
[`sframe_cohens_d_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_cohens_d_ci.md),
[`sframe_eta_sq_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_eta_sq_ci.md)

## Examples

``` r
sframe_cramers_v_ci(table(mtcars$am, mtcars$cyl))
#>  estimate     lower     upper 
#> 0.5226355 0.1118233 0.8455313 
#> attr(,"level")
#> [1] 0.95
#> attr(,"method")
#> [1] "noncentral chi-square"
```
