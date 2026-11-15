# Missing-data report

Reports item-wise missingness, respondent-wise missingness, missing-data
patterns, listwise and pairwise deletion counts, and scale scoring
missing rules. No imputation is performed.

## Usage

``` r
sframe_missing_data_results(data, instrument = NULL, variables = NULL)
```

## Arguments

- data:

  A data.frame of responses. A blank answer (an empty string, or only
  spaces) counts as missing, and a factor's unused levels are dropped.

- instrument:

  Optional `sframe` object.

- variables:

  Optional response columns. Defaults to instrument item IDs when an
  instrument is supplied, otherwise all columns.

## Value

An object of class `sframe_missing_data_report`. Its `item_missing` and
`respondent_missing` tables give `missing_prop`, a proportion between 0
and 1. Their `missing_pct` column, the name before 0.4.3 kept for 1
release, is the same proportion, not a percentage. The `patterns` table
gives each pattern's `n`, its `percent` from 0 to 100 and its `prop`
between 0 and 1.

## See also

Other Responses functions:
[`export_responses()`](https://surveyframe.org/reference/export_responses.md),
[`read_responses()`](https://surveyframe.org/reference/read_responses.md),
[`read_sheet_responses()`](https://surveyframe.org/reference/read_sheet_responses.md),
[`sframe_outlier_results()`](https://surveyframe.org/reference/sframe_outlier_results.md),
[`sframe_quality_results()`](https://surveyframe.org/reference/sframe_quality_results.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
mr <- sframe_missing_data_results(demo$responses, demo$instrument)
mr$item_missing
```
