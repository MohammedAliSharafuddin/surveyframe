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
