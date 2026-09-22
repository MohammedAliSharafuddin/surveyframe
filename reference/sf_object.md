# Recover the validated object

Returns the original object carried by a validation result, whether or
not validation passed.

## Usage

``` r
sf_object(x, ...)
```

## Arguments

- x:

  An
  [sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
  object.

- ...:

  Passed to methods.

## Value

The object held by a validation result.

## See also

[sf_validation_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md),
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md)

## Examples

``` r
v <- validate_sframe(sframe_demo_data()$instrument, strict = FALSE)
sf_object(v)
#> <sframe>
#>   Title:      Tourism Services Experience Demo
#>   Version:    0.3.0
#>   Items:      15
#>   Scales:     5
#>   Analysis:   34 block(s)
#>   Status:     valid
```
