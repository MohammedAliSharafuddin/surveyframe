# Get validation problems

Returns every actionable validation message in check order.

## Usage

``` r
sf_problems(x, ...)
```

## Arguments

- x:

  An
  [sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
  object.

- ...:

  Passed to methods.

## Value

A character vector, empty when validation passed.

## See also

[sf_validation_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md),
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)

## Examples

``` r
v <- validate_sframe(sframe_demo_data()$instrument, strict = FALSE)
sf_problems(v)
#> character(0)
```
