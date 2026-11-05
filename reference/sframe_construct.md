# Define a latent or composite construct

Define a latent or composite construct

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
  letters, numbers, and `_` characters.

- label:

  Human-readable construct label.

- items:

  Character vector of indicator item IDs.

- mode:

  Measurement mode. One of `"reflective"`, `"composite"`, `"formative"`,
  or `"single_item"`.

- weights:

  Optional indicator weights for later PLS-SEM planning.

## Value

An object of class `sf_construct`.

## See also

Other Models and syntax functions:
[`sframe_add_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_add_model.md),
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
sq <- sframe_construct("sq", "Service Quality",
                    items = c("sq_1", "sq_2", "sq_3"))
sq$mode
#> [1] "reflective"
sq$items
#> [1] "sq_1" "sq_2" "sq_3"
```
