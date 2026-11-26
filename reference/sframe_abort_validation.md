# Abort with a validation error

Stops with an error of class `sframe_validation_error`, the class every
instrument check raises, so a caller can catch it apart from other
errors.

## Usage

``` r
sframe_abort_validation(message, instrument_title = NULL, ...)
```

## Arguments

- message:

  Character. The error message.

- instrument_title:

  Character or NULL. Title of the instrument being validated, included
  in the condition metadata when supplied.

- ...:

  Additional named fields passed to
  [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html).

## Value

This function does not return. It signals an error of class
`sframe_validation_error`.
