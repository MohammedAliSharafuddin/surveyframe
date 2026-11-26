# Warn about a scoring issue

Signals a warning of class `sframe_scoring_warning` and records the
scale it concerns.

## Usage

``` r
sframe_warn_scoring(message, scale_id = NULL, ...)
```

## Arguments

- message:

  Character. The warning message.

- scale_id:

  Character or NULL. The scale ID affected.

- ...:

  Additional named fields passed to
  [`rlang::warn()`](https://rlang.r-lib.org/reference/abort.html).

## Value

`NULL`, invisibly, after signalling a warning of class
`sframe_scoring_warning`.
