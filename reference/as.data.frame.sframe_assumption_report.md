# Coerce an assumption report to a data frame

Combines the available normality, homogeneity, and regression checks
into a long-form summary.

## Usage

``` r
# S3 method for class 'sframe_assumption_report'
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

A data frame naming each assumption family, variable, and statistic.

## See also

[sframe_as_data_frame](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md),
[`assumption_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/assumption_report.md)
