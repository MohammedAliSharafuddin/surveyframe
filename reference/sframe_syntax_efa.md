# Generate EFA planning syntax

Generate EFA planning syntax

## Usage

``` r
sframe_syntax_efa(
  items,
  nfactors = 1L,
  extraction = c("minres", "pa", "ml"),
  rotation = c("oblimin", "promax", "varimax"),
  data_name = "data"
)
```

## Arguments

- items:

  Character vector of item IDs.

- nfactors:

  Number of factors.

- extraction:

  Extraction method.

- rotation:

  Rotation method.

- data_name:

  Name of the data object in generated R code.

## Value

A character string with R syntax.

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
[`sframe_syntax_pls()`](https://surveyframe.org/reference/sframe_syntax_pls.md),
[`sframe_syntax_result()`](https://surveyframe.org/reference/sframe_syntax_result.md),
[`sframe_syntax_sem()`](https://surveyframe.org/reference/sframe_syntax_sem.md),
[`sframe_validate_model()`](https://surveyframe.org/reference/sframe_validate_model.md)

## Examples

``` r
syntax <- sframe_syntax_efa(c("sq_1", "sq_2", "sq_3"), nfactors = 1)
cat(syntax)
```
