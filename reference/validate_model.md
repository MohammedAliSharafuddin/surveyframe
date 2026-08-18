# Validate a surveyframe model specification

Checks model IDs, construct IDs, indicators, structural path endpoints,
duplicate paths, indirect paths, and engine/type compatibility.

## Usage

``` r
validate_model(model, instrument = NULL, strict = TRUE)
```

## Arguments

- model:

  An
  [`sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_model.md)
  object or compatible list.

- instrument:

  Optional `sframe` object. When supplied, model indicators must match
  instrument item IDs.

- strict:

  Logical. When `TRUE`, invalid models raise an error. When `FALSE`,
  problems are reported in the returned diagnostic without stopping.

## Value

An
[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
object. The model is carried inside it and can be recovered with
[`sf_object()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md).

## Changed in 0.4.0

Earlier versions returned the model invisibly when `strict = TRUE` and a
bare unclassed list when `strict = FALSE`. Both paths now return an
[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
object, visibly, so the diagnostic is readable at the console. Code that
read `$valid` and `$problems` keeps working.

## See also

[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md),
[`sf_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md),
[`sf_is_valid()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md)
