# Read a validation diagnostic

`sf_is_valid()` reports whether the object passed. `sf_problems()`
returns the problem messages. `sf_object()` returns the object that was
validated.

## Usage

``` r
sf_is_valid(x, ...)

sf_problems(x, ...)

sf_object(x, ...)

# S3 method for class 'sframe_validation'
sf_is_valid(x, ...)

# S3 method for class 'sframe_validation'
sf_problems(x, ...)

# S3 method for class 'sframe_validation'
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

`sf_is_valid()` returns a single logical. `sf_problems()` returns a
character vector, empty when the object is valid. `sf_object()` returns
the validated object.

## See also

[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md),
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md)

## Examples

``` r
item  <- sf_item("q1", "How satisfied are you?", type = "text")
instr <- sf_instrument("Demo", components = list(item))
v <- validate_sframe(instr, strict = FALSE)

sf_is_valid(v)
#> [1] TRUE
sf_problems(v)
#> character(0)
```
