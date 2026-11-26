# Add a model specification to an instrument

Stores a model in the instrument's `models` list, after checking that
every item it names is in the instrument.

## Usage

``` r
sframe_add_model(instrument, model, validate = TRUE, replace = TRUE)
```

## Arguments

- instrument:

  An `sframe` object.

- model:

  An
  [`sframe_model_spec()`](https://surveyframe.org/reference/sframe_model_spec.md)
  object.

- validate:

  Logical. Whether to validate the model against the instrument before
  adding it. Defaults to `TRUE`.

- replace:

  Logical. Whether to replace an existing model with the same ID.
  Defaults to `TRUE`.

## Value

The updated `sframe` object.

## See also

Other Models and syntax functions:
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
[`sframe_syntax_sem()`](https://surveyframe.org/reference/sframe_syntax_sem.md),
[`sframe_validate_model()`](https://surveyframe.org/reference/sframe_validate_model.md)

## Examples

``` r
demo <- sframe_demo("factor_structure")
m <- sframe_model_spec("cfa1", type = "cfa",
              constructs = list(sframe_construct("org", items = c("org_1", "org_2", "org_3"))))
instr <- sframe_add_model(demo$instrument, m)
length(instr$models)
```
