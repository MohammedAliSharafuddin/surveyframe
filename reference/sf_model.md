# Create a surveyframe model specification

Create a surveyframe model specification

## Usage

``` r
sf_model(
  id,
  label = NULL,
  type = c("efa", "cfa", "cb_sem", "pls_sem"),
  engine = NULL,
  constructs = list(),
  paths = list(),
  covariances = list(),
  indirect = list(),
  options = list()
)
```

## Arguments

- id:

  Model identifier.

- label:

  Human-readable model label.

- type:

  Model type. One of `"efa"`, `"cfa"`, `"cb_sem"`, or `"pls_sem"`.

- engine:

  Optional engine name. Defaults to `"lavaan"` for CFA/CB-SEM and
  `"seminr"` for PLS-SEM.

- constructs:

  List of
  [`sf_construct()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_construct.md)
  objects.

- paths:

  List of
  [`sf_path()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_path.md)
  objects.

- covariances:

  List of
  [`sf_covariance()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_covariance.md)
  objects.

- indirect:

  List of
  [`sf_indirect()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_indirect.md)
  objects.

- options:

  List of model options, such as `estimator`, `missing`, `bootstrap`, or
  `standardised`.

## Value

An object of class `sf_model`.
