# Serialise a model specification to JSON

Serialise a model specification to JSON

## Usage

``` r
sframe_model_json(model, pretty = TRUE)
```

## Arguments

- model:

  An
  [`sframe_model_spec()`](https://surveyframe.org/reference/sframe_model_spec.md)
  object.

- pretty:

  Logical. Whether to pretty-print the JSON.

## Value

A JSON string.

## See also

Other Models and syntax functions:
[`sframe_add_model()`](https://surveyframe.org/reference/sframe_add_model.md),
[`sframe_construct()`](https://surveyframe.org/reference/sframe_construct.md),
[`sframe_covariance()`](https://surveyframe.org/reference/sframe_covariance.md),
[`sframe_indirect_effect()`](https://surveyframe.org/reference/sframe_indirect_effect.md),
[`sframe_model_outline()`](https://surveyframe.org/reference/sframe_model_outline.md),
[`sframe_model_spec()`](https://surveyframe.org/reference/sframe_model_spec.md),
[`sframe_path()`](https://surveyframe.org/reference/sframe_path.md),
[`sframe_syntax_cfa()`](https://surveyframe.org/reference/sframe_syntax_cfa.md),
[`sframe_syntax_efa()`](https://surveyframe.org/reference/sframe_syntax_efa.md),
[`sframe_syntax_pls()`](https://surveyframe.org/reference/sframe_syntax_pls.md),
[`sframe_syntax_result()`](https://surveyframe.org/reference/sframe_syntax_result.md),
[`sframe_syntax_sem()`](https://surveyframe.org/reference/sframe_syntax_sem.md),
[`sframe_validate_model()`](https://surveyframe.org/reference/sframe_validate_model.md)

## Examples

``` r
m <- sframe_model_spec("cb1", type = "cb_sem",
              constructs = list(sframe_construct("sq", items = c("sq_1", "sq_2"))))
cat(sframe_model_json(m))
```
