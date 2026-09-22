# Add a model specification to an instrument

Add a model specification to an instrument

## Usage

``` r
add_model(instrument, model, validate = TRUE, replace = TRUE)
```

## Arguments

- instrument:

  An `sframe` object.

- model:

  An
  [`sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_model.md)
  object.

- validate:

  Logical. Whether to validate the model against the instrument before
  adding it.

- replace:

  Logical. Whether to replace an existing model with the same ID.
  Defaults to `TRUE`.

## Value

The updated `sframe` object.

## Examples

``` r
demo <- sframe_demo_data()
m <- sf_model("cb1", type = "cb_sem",
              constructs = list(sf_construct("sat", items = c("sat_1", "sat_2"))))
instr <- add_model(demo$instrument, m)
length(instr$models)
#> [1] 4
```
