# Define a latent or composite construct

Names a construct and the items that measure it, with its measurement
mode. A construct is the building block of
[`sframe_model_spec()`](https://surveyframe.org/reference/sframe_model_spec.md).

## Usage

``` r
sframe_construct(
  id,
  label = NULL,
  items = character(0),
  mode = c("reflective", "composite", "formative", "single_item"),
  weights = NULL
)
```

## Arguments

- id:

  Construct identifier. Must start with a letter and contain only
  letters, numbers and `_` characters.

- label:

  Human-readable construct label.

- items:

  Character vector of indicator item IDs.

- mode:

  Measurement mode. One of `"reflective"`, `"composite"`, `"formative"`
  or `"single_item"`.

- weights:

  Optional indicator weights for later PLS-SEM planning.

## Value

An object of class `sf_construct`.

## See also

Other Models and syntax functions:
[`sframe_add_model()`](https://surveyframe.org/reference/sframe_add_model.md),
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
sq <- sframe_construct("sq", "Service Quality",
                       items = c("sq_1", "sq_2", "sq_3"))
sq$mode
sq$items
```
