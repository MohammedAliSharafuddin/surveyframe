# Generate seminr PLS-SEM syntax

Generate seminr PLS-SEM syntax

## Usage

``` r
seminr_syntax(model, data_name = "data", nboot = NULL, seed = 123)
```

## Arguments

- model:

  An
  [`sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_model.md)
  object of type `"pls_sem"`.

- data_name:

  Name of the data object in generated R code.

- nboot:

  Number of bootstrap samples.

- seed:

  Random seed for bootstrap syntax.

## Value

An R syntax string for `seminr`.
