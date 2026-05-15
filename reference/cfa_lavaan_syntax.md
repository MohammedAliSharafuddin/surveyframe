# Generate lavaan CFA syntax

Generate lavaan CFA syntax

## Usage

``` r
cfa_lavaan_syntax(
  instrument = NULL,
  model = NULL,
  scales = NULL,
  ordered = FALSE,
  std_lv = TRUE,
  residual_covariances = NULL,
  latent_covariances = TRUE
)
```

## Arguments

- instrument:

  Optional `sframe` object used to derive constructs from scales when
  `model` is not supplied.

- model:

  Optional
  [`sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_model.md)
  object.

- scales:

  Optional scale IDs when deriving a model from an instrument.

- ordered:

  Logical. Whether to add an ordered-item note.

- std_lv:

  Logical. Whether to add a `std.lv = TRUE` note.

- residual_covariances:

  Optional list of
  [`sf_covariance()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_covariance.md)
  objects for correlated residuals.

- latent_covariances:

  Logical. Whether to include model-level latent covariances supplied in
  `model`.

## Value

A lavaan syntax string.
