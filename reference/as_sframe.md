# Coerce to an instrument

Recovers the `sframe` instrument from a validation diagnostic. This is
the migration path for code that used the `strict = TRUE` return of
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
as an instrument, which it no longer is.

## Usage

``` r
as_sframe(x, ...)

# S3 method for class 'sframe'
as_sframe(x, ...)

# S3 method for class 'sframe_validation'
as_sframe(x, ...)
```

## Arguments

- x:

  An
  [sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
  object or an `sframe`.

- ...:

  Passed to methods.

## Value

An `sframe` object. When the validation passed, its `meta$validated` is
`TRUE`.

## See also

[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)

## Examples

``` r
item  <- sf_item("q1", "How satisfied are you?", type = "text")
instr <- sf_instrument("Demo", components = list(item))

validated <- as_sframe(validate_sframe(instr, strict = TRUE))
isTRUE(sf_meta(validated)$validated)
#> [1] TRUE
```
