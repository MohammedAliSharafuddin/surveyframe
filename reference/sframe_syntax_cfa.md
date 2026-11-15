# Generate lavaan CFA syntax from an instrument or a declared model

The general entry point for CFA syntax. It takes an instrument, and
derives the constructs from its scales, or an
[`sframe_model_spec()`](https://surveyframe.org/reference/sframe_model_spec.md)
declaring constructs that cut across them, and it accepts correlated
residuals and latent covariances.

## Usage

``` r
sframe_syntax_cfa(
  instrument = NULL,
  model = NULL,
  scales = NULL,
  ordered = FALSE,
  std_lv = TRUE,
  residual_covariances = NULL,
  latent_covariances = TRUE
)
```

## Arguments

- instrument:

  Optional `sframe` object used to derive constructs from scales when
  `model` is not supplied.

- model:

  Optional
  [`sframe_model_spec()`](https://surveyframe.org/reference/sframe_model_spec.md)
  object.

- scales:

  Optional scale IDs when deriving a model from an instrument.

- ordered:

  Logical. Whether to add an ordered-item note.

- std_lv:

  Logical. Whether to add a `std.lv = TRUE` note.

- residual_covariances:

  Optional list of
  [`sframe_covariance()`](https://surveyframe.org/reference/sframe_covariance.md)
  objects for correlated residuals.

- latent_covariances:

  Logical. Whether to include model-level latent covariances supplied in
  `model`.

## Value

A lavaan syntax string.

## Details

Each generator emits the language its engine reads, so they stay
separate: this one and
[`sframe_syntax_sem()`](https://surveyframe.org/reference/sframe_syntax_sem.md)
write lavaan,
[`sframe_syntax_pls()`](https://surveyframe.org/reference/sframe_syntax_pls.md)
writes seminr, and
[`sframe_syntax_efa()`](https://surveyframe.org/reference/sframe_syntax_efa.md)
writes an exploratory plan.

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
[`sframe_syntax_efa()`](https://surveyframe.org/reference/sframe_syntax_efa.md),
[`sframe_syntax_pls()`](https://surveyframe.org/reference/sframe_syntax_pls.md),
[`sframe_syntax_result()`](https://surveyframe.org/reference/sframe_syntax_result.md),
[`sframe_syntax_sem()`](https://surveyframe.org/reference/sframe_syntax_sem.md),
[`sframe_validate_model()`](https://surveyframe.org/reference/sframe_validate_model.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
syntax <- sframe_syntax_cfa(demo$instrument,
                             scales = c("satisfaction", "behavioural_intention"))
cat(syntax)
```
