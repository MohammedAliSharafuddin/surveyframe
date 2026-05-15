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

  Logical. When `TRUE`, invalid models raise an error. When `FALSE`, a
  list with `valid` and `problems` is returned.

## Value

The model invisibly when valid and `strict = TRUE`, otherwise a
validation result list.
