# Add a model specification to an instrument

Add a model specification to an instrument

## Usage

``` r
sframe_add_model(instrument, model, validate = TRUE, replace = TRUE)
```

## Arguments

- instrument:

  An `sframe` object.

- model:

  An
  [`sframe_model_spec()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_spec.md)
  object.

- validate:

  Logical. Whether to validate the model against the instrument before
  adding it.

- replace:

  Logical. Whether to replace an existing model with the same ID.
  Defaults to `TRUE`.

## Value

The updated `sframe` object.

## See also

Other Models and syntax functions:
[`sframe_construct()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_construct.md),
[`sframe_covariance()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_covariance.md),
[`sframe_indirect_effect()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_indirect_effect.md),
[`sframe_model_json()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_json.md),
[`sframe_model_outline()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_outline.md),
[`sframe_model_spec()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_spec.md),
[`sframe_path()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_path.md),
[`sframe_syntax_cfa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_cfa.md),
[`sframe_syntax_efa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_efa.md),
[`sframe_syntax_pls()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_pls.md),
[`sframe_syntax_result()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_result.md),
[`sframe_syntax_sem()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_sem.md),
[`sframe_validate_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validate_model.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
m <- sframe_model_spec("cb1", type = "cb_sem",
              constructs = list(sframe_construct("sat", items = c("sat_1", "sat_2"))))
instr <- sframe_add_model(demo$instrument, m)
length(instr$models)
#> [1] 4
```
