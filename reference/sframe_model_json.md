# Serialise a model specification to JSON

Serialise a model specification to JSON

## Usage

``` r
sframe_model_json(model, pretty = TRUE)
```

## Arguments

- model:

  An
  [`sframe_model_spec()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_spec.md)
  object.

- pretty:

  Logical. Whether to pretty-print the JSON.

## Value

A JSON string.

## See also

Other Models and syntax functions:
[`sframe_add_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_add_model.md),
[`sframe_construct()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_construct.md),
[`sframe_covariance()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_covariance.md),
[`sframe_indirect_effect()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_indirect_effect.md),
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
m <- sframe_model_spec("cb1", type = "cb_sem",
              constructs = list(sframe_construct("sq", items = c("sq_1", "sq_2"))))
cat(sframe_model_json(m))
#> {
#>   "id": "cb1",
#>   "label": "cb1",
#>   "type": "cb_sem",
#>   "engine": "lavaan",
#>   "measurement": {
#>     "constructs": [
#>       {
#>         "id": "sq",
#>         "label": "sq",
#>         "mode": "reflective",
#>         "items": ["sq_1", "sq_2"],
#>         "weights": null
#>       }
#>     ]
#>   },
#>   "structural": {
#>     "paths": [],
#>     "covariances": [],
#>     "indirect": []
#>   },
#>   "options": []
#> }
```
