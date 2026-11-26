# Warn about missing data

Signals a warning of class `sframe_missing_data_warning` and records the
item and its missing rate.

## Usage

``` r
sframe_warn_missing(message, item_id = NULL, rate = NULL, ...)
```

## Arguments

- message:

  Character. The warning message.

- item_id:

  Character or NULL. The item ID with missing data.

- rate:

  Numeric or NULL. The observed missing rate.

- ...:

  Additional named fields passed to
  [`rlang::warn()`](https://rlang.r-lib.org/reference/abort.html).

## Value

`NULL`, invisibly, after signalling a warning of class
`sframe_missing_data_warning`.
