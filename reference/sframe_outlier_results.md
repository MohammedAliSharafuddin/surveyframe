# Flag univariate and multivariate outliers

Uses transparent screening rules for numeric survey response variables.
The report supports data review before modelling, and what to remove
stays the researcher's decision.

## Usage

``` r
sframe_outlier_results(
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

  Outlier rule. `"zscore"` flags absolute z scores above `z_cut`,
  `"iqr"` flags values outside Tukey fences and `"mahalanobis"` flags
  rows above the chi-square cutoff for the selected variables.

- z_cut:

  Numeric cutoff for `"zscore"`. Defaults to `3`.

- iqr_multiplier:

  Numeric multiplier for `"iqr"` fences. Defaults to `1.5`.

- p_cut:

  Probability cutoff for `"mahalanobis"`. Defaults to `0.975`.

## Value

An object of class `sframe_outlier_report` with the method, screened
variables, a result table, flagged row numbers and a reporting prompt.

## See also

Other Responses functions:
[`export_responses()`](https://surveyframe.org/reference/export_responses.md),
[`read_responses()`](https://surveyframe.org/reference/read_responses.md),
[`read_sheet_responses()`](https://surveyframe.org/reference/read_sheet_responses.md),
[`sframe_missing_data_results()`](https://surveyframe.org/reference/sframe_missing_data_results.md),
[`sframe_quality_results()`](https://surveyframe.org/reference/sframe_quality_results.md)

## Examples

``` r
demo <- sframe_demo("correlation_regression")
outliers <- sframe_outlier_results(
  demo$responses,
  variables = c("sessions_attended", "networking_minutes", "overall_value"),
  method = "zscore"
)
outliers$flagged_rows
```
