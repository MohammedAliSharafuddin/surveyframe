# Generate lavaan CB-SEM syntax

Generate lavaan CB-SEM syntax

## Usage

``` r
sframe_syntax_sem(model, instrument = NULL, standardised = TRUE)
```

## Arguments

- model:

  An
  [`sframe_model_spec()`](https://surveyframe.org/reference/sframe_model_spec.md)
  object of type `"cb_sem"`.

- instrument:

  Optional `sframe` object for indicator validation.

- standardised:

  Logical. Adds a standardised-estimates fitting note.

## Value

A lavaan syntax string.

## See also

Other Models and syntax functions:
[`sframe_add_model()`](https://surveyframe.org/reference/sframe_add_model.md),
[`sframe_construct()`](https://surveyframe.org/reference/sframe_construct.md),
[`sframe_covariance()`](https://surveyframe.org/reference/sframe_covariance.md),
[`sframe_indirect_effect()`](https://surveyframe.org/reference/sframe_indirect_effect.md),
[`sframe_model_json()`](https://surveyframe.org/reference/sframe_model_json.md),
[`sframe_model_outline()`](https://surveyframe.org/reference/sframe_model_outline.md),
[`sframe_model_spec()`](https://surveyframe.org/reference/sframe_model_spec.md),
[`sframe_path()`](https://surveyframe.org/reference/sframe_path.md),
[`sframe_syntax_cfa()`](https://surveyframe.org/reference/sframe_syntax_cfa.md),
[`sframe_syntax_efa()`](https://surveyframe.org/reference/sframe_syntax_efa.md),
[`sframe_syntax_pls()`](https://surveyframe.org/reference/sframe_syntax_pls.md),
[`sframe_syntax_result()`](https://surveyframe.org/reference/sframe_syntax_result.md),
[`sframe_validate_model()`](https://surveyframe.org/reference/sframe_validate_model.md)

## Examples

``` r
m <- sframe_model_spec(
  "cb1", type = "cb_sem",
  constructs = list(
    sframe_construct("sq", items = c("sq_1", "sq_2", "sq_3")),
    sframe_construct("sat", items = c("sat_1", "sat_2")),
    sframe_construct("bi", items = c("bi_1", "bi_2"))
  ),
  paths = list(sframe_path("sq", "sat"), sframe_path("sat", "bi")),
  indirect = list(sframe_indirect_effect("sq", through = "sat", to = "bi"))
)
cat(sframe_syntax_sem(m))
```
