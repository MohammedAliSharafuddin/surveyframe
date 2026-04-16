# Abort with a validation error

Abort with a validation error

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
