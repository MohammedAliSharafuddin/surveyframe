# Serialise a model specification to JSON

Serialise a model specification to JSON

## Usage

``` r
model_json(model, pretty = TRUE)
```

## Arguments

- model:

  An
  [`sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_model.md)
  object.

- pretty:

  Logical. Whether to pretty-print the JSON.

## Value

A JSON string.

## Examples

``` r
m <- sf_model("cb1", type = "cb_sem",
              constructs = list(sf_construct("sq", items = c("sq_1", "sq_2"))))
cat(model_json(m))
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
