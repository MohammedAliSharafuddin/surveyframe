# Test whether validation passed

Reads the overall pass/fail result without inspecting validation
internals.

## Usage

``` r
sf_is_valid(x, ...)
```

## Arguments

- x:

  An
  [sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
  object.

- ...:

  Passed to methods.

## Value

A single logical value.

## See also

[sf_validation_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)

## Examples

``` r
v <- validate_sframe(sframe_demo_data()$instrument, strict = FALSE)
sf_is_valid(v)
#> [1] TRUE
```
