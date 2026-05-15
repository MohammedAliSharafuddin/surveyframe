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
