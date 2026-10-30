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
