# Coerce an instrument to its item summary

Returns one row per item in a surveyframe instrument.

## Usage

``` r
# S3 method for class 'sframe'
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

A data frame summarising the instrument's items.

## See also

[sframe_as_data_frame](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md),
[`sf_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_items.md),
[`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md)
