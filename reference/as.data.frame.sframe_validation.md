# Coerce validation problems to a data frame

Coerce validation problems to a data frame

## Usage

``` r
# S3 method for class 'sframe_validation'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
```

## Arguments

- x:

  An
  [sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
  object.

- row.names:

  Passed to
  [`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

- optional:

  Passed to
  [`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

- ...:

  Ignored. Present for S3 consistency.

## Value

A data frame with one row per validation problem and columns `check` and
`problem`.

## See also

[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md),
[`sf_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_problems.md)
