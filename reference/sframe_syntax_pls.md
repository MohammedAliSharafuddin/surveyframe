# Generate seminr PLS-SEM syntax

Generate seminr PLS-SEM syntax

## Usage

``` r
sframe_syntax_pls(model, data_name = "data", nboot = NULL, seed = 123)
```

## Arguments

- model:

  An
  [`sframe_model_spec()`](https://surveyframe.org/reference/sframe_model_spec.md)
  object of type `"pls_sem"`.

- data_name:

  Name of the data object in generated R code.

- nboot:

  Number of bootstrap samples.

- seed:

  Random seed for bootstrap syntax.

## Value

An R syntax string for `seminr`.

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
[`sframe_syntax_result()`](https://surveyframe.org/reference/sframe_syntax_result.md),
[`sframe_syntax_sem()`](https://surveyframe.org/reference/sframe_syntax_sem.md),
[`sframe_validate_model()`](https://surveyframe.org/reference/sframe_validate_model.md)

## Examples

``` r
m <- sframe_model_spec(
  "pls1", type = "pls_sem",
  constructs = list(
    sframe_construct("sq", items = c("sq_1", "sq_2", "sq_3")),
    sframe_construct("sat", items = c("sat_1", "sat_2"))
  ),
  paths = list(sframe_path("sq", "sat"))
)
cat(sframe_syntax_pls(m))
```
