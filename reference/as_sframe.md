# Coerce to an instrument

Recovers the `sframe` instrument from a validation diagnostic. This is
the migration path for code that used the `strict = TRUE` return of
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md)
as an instrument after its class has changed.

## Usage

``` r
as_sframe(x, ...)
```

## Arguments

- x:

  An
  [sframe_validation](https://surveyframe.org/reference/sframe_validation.md)
  object or an `sframe`.

- ...:

  Passed to methods.

## Value

An `sframe` object. When the validation passed, its `meta$validated` is
`TRUE`.

## See also

[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md),
[sframe_validation](https://surveyframe.org/reference/sframe_validation.md)

Other Design functions:
[`launch_builder()`](https://surveyframe.org/reference/launch_builder.md),
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md),
[`sframe_attention_check()`](https://surveyframe.org/reference/sframe_attention_check.md),
[`sframe_branch()`](https://surveyframe.org/reference/sframe_branch.md),
[`sframe_choice_set()`](https://surveyframe.org/reference/sframe_choice_set.md),
[`sframe_conjoint_design()`](https://surveyframe.org/reference/sframe_conjoint_design.md),
[`sframe_get_study()`](https://surveyframe.org/reference/sframe_get_study.md),
[`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md),
[`sframe_item()`](https://surveyframe.org/reference/sframe_item.md),
[`sframe_sampling_methods()`](https://surveyframe.org/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md),
[`sframe_validation`](https://surveyframe.org/reference/sframe_validation.md),
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md),
[`write_sframe()`](https://surveyframe.org/reference/write_sframe.md)

## Examples

``` r
item  <- sframe_item("q1", "How satisfied are you?", type = "text")
instr <- sframe_instrument("Demo", components = list(item))

validated <- as_sframe(validate_sframe(instr, strict = TRUE))
isTRUE(sframe_meta(validated)$validated)
```
