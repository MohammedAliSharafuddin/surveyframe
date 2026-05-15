# Flag univariate and multivariate outliers

Uses transparent screening rules for numeric survey response variables.
The report supports data review before modelling, not automatic
deletion.

## Usage

``` r
outlier_report(
  data,
  variables = NULL,
  method = c("zscore", "iqr", "mahalanobis"),
  z_cut = 3,
  iqr_multiplier = 1.5,
  p_cut = 0.975
)
```

## Arguments

- data:

  A data.frame.

- variables:

  Character vector of numeric variables to screen. When `NULL`, all
  numeric columns are used.

- method:

  Outlier rule. `"zscore"` flags absolute z scores above `z_cut`;
  `"iqr"` flags values outside Tukey fences; `"mahalanobis"` flags rows
  above the chi-square cutoff for the selected variables.

- z_cut:

  Numeric cutoff for `"zscore"`. Defaults to `3`.

- iqr_multiplier:

  Numeric multiplier for `"iqr"` fences. Defaults to `1.5`.

- p_cut:

  Probability cutoff for `"mahalanobis"`. Defaults to `0.975`.

## Value

An object of class `sframe_outlier_report` with the method, screened
variables, a result table, flagged row numbers, and a reporting prompt.

## Examples

``` r
demo <- sframe_demo_data()
outliers <- outlier_report(
  demo$responses,
  variables = c("dm_1", "dm_2", "sat_1"),
  method = "zscore"
)
outliers$flagged_rows
#> integer(0)
```
