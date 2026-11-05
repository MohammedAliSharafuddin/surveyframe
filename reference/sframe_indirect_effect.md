# Define an indirect effect path

Define an indirect effect path

## Usage

``` r
sframe_indirect_effect(from, through, to, label = NULL)
```

## Arguments

- from:

  Source construct ID.

- through:

  Character vector of mediator construct IDs.

- to:

  Target construct ID.

- label:

  Optional effect label.

## Value

An object of class `sf_indirect`.

## See also

Other Models and syntax functions:
[`sframe_add_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_add_model.md),
[`sframe_construct()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_construct.md),
[`sframe_covariance()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_covariance.md),
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
ind <- sframe_indirect_effect("sq", through = "sat", to = "bi", label = "mediation")
ind$through
#> [1] "sat"
```
