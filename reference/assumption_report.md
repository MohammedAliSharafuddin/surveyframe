# Assumption-check report

Performs common assumption checks for survey analyses using base R where
possible: Shapiro-Wilk tests, skewness/kurtosis screening, Levene and
Brown-Forsythe tests, regression residual checks, VIF, Cook's distance,
expected-count checks, and sparse-cell warnings.

## Usage

``` r
assumption_report(
  data,
  variables = NULL,
  group = NULL,
  outcome = NULL,
  predictors = NULL,
  table_vars = NULL
)
```

## Arguments

- data:

  A data.frame.

- variables:

  Numeric variables for normality screening.

- group:

  Optional grouping variable for Levene/Brown-Forsythe tests.

- outcome:

  Optional regression outcome.

- predictors:

  Optional regression predictors.

- table_vars:

  Optional two categorical variables for expected-count checks.

## Value

An object of class `sframe_assumption_report`.

## Examples

``` r
demo <- sframe_demo_data()
ar <- assumption_report(demo$responses, variables = c("sat_1", "sat_2"),
                         group = "visit_type")
print(ar)
#> Assumption Report
#> 
#> Normality:
#>  variable   n shapiro_w    shapiro_p    skewness   kurtosis
#>     sat_1 120 0.9087471 5.651017e-07 -0.17463397 -0.8225522
#>     sat_2 120 0.9033205 2.912675e-07  0.04066335 -0.9588129
#> 
#> Homogeneity of variance:
#>  variable           test         F         p
#>     sat_1         Levene 0.2848288 0.5945575
#>     sat_1 Brown-Forsythe 0.2292714 0.6329507
#>     sat_2         Levene 0.1956862 0.6590353
#>     sat_2 Brown-Forsythe 0.1522047 0.6971406
```
