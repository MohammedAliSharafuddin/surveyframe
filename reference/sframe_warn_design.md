# Warn about an instrument design issue

Advisory only. Used where a declaration is legal but likely to cost the
researcher data quality, such as a pairwise comparison item large enough
to fatigue respondents.

## Usage

``` r
sframe_warn_design(message, item_id = NULL, ...)
```

## Arguments

- message:

  Character. The warning message.

- item_id:

  Character or NULL. The item ID affected.

- ...:

  Additional named fields passed to
  [`rlang::warn()`](https://rlang.r-lib.org/reference/abort.html).
