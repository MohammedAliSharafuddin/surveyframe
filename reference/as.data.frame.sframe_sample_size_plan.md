# Coerce a sample-size plan to a data frame

Coerce a sample-size plan to a data frame

## Usage

``` r
# S3 method for class 'sframe_sample_size_plan'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
```

## Arguments

- x:

  A surveyframe object.

- row.names:

  Passed to
  [`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html)
  by the methods that build a frame. Ignored by the methods that return
  a stored table.

- optional:

  Passed to
  [`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

- ...:

  Ignored. Present for S3 consistency.

## Value

A one-row data frame containing the analysis type, estimated sample
size, alpha, and power.

## See also

[sframe_as_data_frame](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md),
[`sample_size_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sample_size_plan.md)
