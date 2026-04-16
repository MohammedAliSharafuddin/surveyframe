# Abort with a branching error

Abort with a branching error

## Usage

``` r
sframe_abort_branching(message, item_id = NULL, ...)
```

## Arguments

- message:

  Character. The error message.

- item_id:

  Character or NULL. The item ID involved in the broken rule.

- ...:

  Additional named fields passed to
  [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html).
