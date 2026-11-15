# Define a covariance between constructs

Define a covariance between constructs

## Usage

``` r
sframe_covariance(from, to, label = NULL)
```

## Arguments

- from:

  First construct ID.

- to:

  Second construct ID.

- label:

  Optional label.

## Value

An object of class `sf_covariance`.

## See also

Other Models and syntax functions:
[`sframe_add_model()`](https://surveyframe.org/reference/sframe_add_model.md),
[`sframe_construct()`](https://surveyframe.org/reference/sframe_construct.md),
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
cov <- sframe_covariance("sq", "sus", label = "cov1")
cov$from
cov$to
```
