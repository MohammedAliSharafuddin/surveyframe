# Abort with an import error

Stops with an error of class `sframe_import_error` when a file cannot be
read as an instrument, and records the file's path.

## Usage

``` r
sframe_abort_import(message, path = NULL, ...)
```

## Arguments

- message:

  Character. The error message.

- path:

  Character or NULL. The file path that failed to import.

- ...:

  Additional named fields passed to
  [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html).

## Value

This function does not return. It signals an error of class
`sframe_import_error`.
