# Warn about a data quality issue

Signals a warning of class `sframe_quality_warning` and records the
respondents it concerns.

## Usage

``` r
sframe_warn_quality(message, respondent_ids = NULL, ...)
```

## Arguments

- message:

  Character. The warning message.

- respondent_ids:

  Character vector or NULL. IDs of affected respondents.

- ...:

  Additional named fields passed to
  [`rlang::warn()`](https://rlang.r-lib.org/reference/abort.html).

## Value

`NULL`, invisibly, after signalling a warning of class
`sframe_quality_warning`.
