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
[`export_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_responses.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md),
[`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md),
[`sframe_outlier_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_outlier_results.md),
[`sframe_quality_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_quality_results.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
mr <- sframe_missing_data_results(demo$responses, demo$instrument)
mr$item_missing
#>              variable missing_n missing_prop valid_n missing_pct
#> visit_type visit_type         0         0.00     120        0.00
#> dm_1             dm_1         0         0.00     120        0.00
#> dm_2             dm_2         0         0.00     120        0.00
#> dm_3             dm_3         0         0.00     120        0.00
#> sq_1             sq_1         0         0.00     120        0.00
#> sq_2             sq_2         0         0.00     120        0.00
#> sq_3             sq_3         0         0.00     120        0.00
#> sus_1           sus_1         0         0.00     120        0.00
#> sus_2           sus_2         0         0.00     120        0.00
#> sat_1           sat_1         0         0.00     120        0.00
#> sat_2           sat_2         0         0.00     120        0.00
#> bi_1             bi_1         0         0.00     120        0.00
#> bi_2             bi_2         0         0.00     120        0.00
#> attention   attention         0         0.00     120        0.00
#> comments     comments        30         0.25      90        0.25
```
