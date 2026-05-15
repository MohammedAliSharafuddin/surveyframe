# Descriptive statistics report

Computes survey descriptives for numeric, Likert, and scale-score
columns, including missingness, mean, standard deviation, median, IQR,
range, skewness, kurtosis, standard error, and confidence intervals.

## Usage

``` r
descriptives_report(
  data,
  variables = NULL,
  split_by = NULL,
  conf_level = 0.95,
  weights = NULL
)
```

## Arguments

- data:

  A data.frame of responses.

- variables:

  Character vector of variables. When `NULL`, numeric-like columns are
  used.

- split_by:

  Optional grouping variable.

- conf_level:

  Confidence level for the mean interval.

- weights:

  Optional case-weight column.

## Value

An object of class `sframe_descriptives_report`.
