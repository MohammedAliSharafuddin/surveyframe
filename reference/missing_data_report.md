# Missing-data report

Reports item-wise missingness, respondent-wise missingness, missing-data
patterns, listwise and pairwise deletion counts, and scale scoring
missing rules. No imputation is performed.

## Usage

``` r
missing_data_report(data, instrument = NULL, variables = NULL)
```

## Arguments

- data:

  A data.frame of responses.

- instrument:

  Optional `sframe` object.

- variables:

  Optional response columns. Defaults to instrument item IDs when an
  instrument is supplied, otherwise all columns.

## Value

An object of class `sframe_missing_data_report`.

## Examples

``` r
demo <- sframe_demo_data()
mr <- missing_data_report(demo$responses, demo$instrument)
mr$item_missing
#>              variable missing_n missing_pct valid_n
#> visit_type visit_type         0        0.00     120
#> dm_1             dm_1         0        0.00     120
#> dm_2             dm_2         0        0.00     120
#> dm_3             dm_3         0        0.00     120
#> sq_1             sq_1         0        0.00     120
#> sq_2             sq_2         0        0.00     120
#> sq_3             sq_3         0        0.00     120
#> sus_1           sus_1         0        0.00     120
#> sus_2           sus_2         0        0.00     120
#> sat_1           sat_1         0        0.00     120
#> sat_2           sat_2         0        0.00     120
#> bi_1             bi_1         0        0.00     120
#> bi_2             bi_2         0        0.00     120
#> attention   attention         0        0.00     120
#> comments     comments        30        0.25      90
```
