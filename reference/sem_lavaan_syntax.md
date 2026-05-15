# Generate lavaan CB-SEM syntax

Generate lavaan CB-SEM syntax

## Usage

``` r
sem_lavaan_syntax(model, instrument = NULL, standardised = TRUE)
```

## Arguments

- model:

  An
  [`sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_model.md)
  object of type `"cb_sem"`.

- instrument:

  Optional `sframe` object for indicator validation.

- standardised:

  Logical. Adds a standardised-estimates fitting note.

## Value

A lavaan syntax string.
