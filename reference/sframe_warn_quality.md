# Warn about a data quality issue

Warn about a data quality issue

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
