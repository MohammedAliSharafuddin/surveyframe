# Extract the item table from a codebook report

Extract the item table from a codebook report

## Usage

``` r
# S3 method for class 'sframe_codebook'
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

The codebook report's item table as a data frame.

## See also

[sframe_as_data_frame](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md),
[`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md)
