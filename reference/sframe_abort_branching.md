# Abort with a branching error

Stops with an error of class `sframe_branching_error` when a skip rule
is broken, and records the item it belongs to.

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

## Value

This function does not return. It signals an error of class
`sframe_branching_error`.
