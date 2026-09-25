# Read a validation diagnostic

[`sf_is_valid()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_is_valid.md)
reports whether the object passed.
[`sf_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_problems.md)
returns the problem messages.
[`sf_object()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_object.md)
returns the object that was validated.

## Value

[`sf_is_valid()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_is_valid.md)
returns a single logical.
[`sf_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_problems.md)
returns a character vector, empty when the object is valid.
[`sf_object()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_object.md)
returns the validated object.

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
