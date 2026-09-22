# Create a model reporting template

Create a model reporting template

## Usage

``` r
model_report_template(model, include_json = TRUE)
```

## Arguments

- model:

  An
  [`sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_model.md)
  object.

- include_json:

  Logical. Whether to include the JSON schema block.

## Value

A character string.

## Examples

``` r
m <- sf_model("cb1", type = "cb_sem",
              constructs = list(sf_construct("sat", items = c("sat_1", "sat_2"))))
cat(model_report_template(m, include_json = FALSE))
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
#> Report estimator, missing-data handling, fit indices, standardised path estimates, indirect effects, reliability, validity, and any item-retention decisions.
```
