# Extract a sensitivity-analysis results table

Extract a sensitivity-analysis results table

## Usage

``` r
# S3 method for class 'sframe_sensitivity'
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

The primary results table from a sensitivity analysis.

## See also

[sframe_as_data_frame](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md)
