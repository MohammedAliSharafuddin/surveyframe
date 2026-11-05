# Create a model reporting template

Create a model reporting template

## Usage

``` r
sframe_model_outline(model, include_json = TRUE)
```

## Arguments

- model:

  An
  [`sframe_model_spec()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_spec.md)
  object.

- include_json:

  Logical. Whether to include the JSON schema block.

## Value

A character string.

## See also

Other Models and syntax functions:
[`sframe_add_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_add_model.md),
[`sframe_construct()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_construct.md),
[`sframe_covariance()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_covariance.md),
[`sframe_indirect_effect()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_indirect_effect.md),
[`sframe_model_json()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_json.md),
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
m <- sframe_model_spec("cb1", type = "cb_sem",
              constructs = list(sframe_construct("sat", items = c("sat_1", "sat_2"))))
cat(sframe_model_outline(m, include_json = FALSE))
#> # Model: cb1
#> 
#> Type: cb_sem
#> Engine: lavaan
#> 
#> ## Constructs
#> - sat (reflective): sat_1, sat_2
#> 
#> ## Structural Paths
#> No structural paths specified.
#> 
#> ## Reporting Notes
#> Report:
#> - estimator and missing-data handling
#> - chi-square, degrees of freedom and p value
#> - CFI, TLI, RMSEA with its confidence interval, and SRMR
#> - standardised loadings
#> - reliability (alpha, omega or composite reliability) and AVE
#> - discriminant validity
#> - any modifications made to the model and the reason for each
#> - structural paths with confidence intervals
#> - R squared for each endogenous construct
#> - indirect and total effects with bootstrap confidence intervals
```
