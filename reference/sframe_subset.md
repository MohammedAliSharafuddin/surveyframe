# Subset a surveyframe report

Keeps the report class, so a subset still prints as a report and still
answers [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

## Usage

``` r
# S3 method for class 'sframe_analysis_results'
x[i, ...]

# S3 method for class 'sframe_reliability_report'
x[i, ...]

# S3 method for class 'sframe_item_report'
x[i, ...]
```

## Arguments

- x:

  An `sframe_analysis_results`, `sframe_reliability_report`, or
  `sframe_item_report` object.

- i:

  Index, name, or logical vector.

- ...:

  Ignored. Present for S3 consistency.

## Value

An object of the same class as `x`.
