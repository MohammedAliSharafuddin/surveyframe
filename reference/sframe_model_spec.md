# Create a surveyframe model specification

Create a surveyframe model specification

## Usage

``` r
sframe_model_spec(
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
  [`sframe_construct()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_construct.md)
  objects.

- paths:

  List of
  [`sframe_path()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_path.md)
  objects.

- covariances:

  List of
  [`sframe_covariance()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_covariance.md)
  objects.

- indirect:

  List of
  [`sframe_indirect_effect()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_indirect_effect.md)
  objects.

- options:

  List of model options, such as `estimator`, `missing`, `bootstrap`, or
  `standardised`.

## Value

An object of class `sf_model`.

## See also

Other Models and syntax functions:
[`sframe_add_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_add_model.md),
[`sframe_construct()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_construct.md),
[`sframe_covariance()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_covariance.md),
[`sframe_indirect_effect()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_indirect_effect.md),
[`sframe_model_json()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_json.md),
[`sframe_model_outline()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_outline.md),
[`sframe_path()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_path.md),
[`sframe_syntax_cfa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_cfa.md),
[`sframe_syntax_efa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_efa.md),
[`sframe_syntax_pls()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_pls.md),
[`sframe_syntax_result()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_result.md),
[`sframe_syntax_sem()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_sem.md),
[`sframe_validate_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validate_model.md)

## Examples

``` r
m <- sframe_model_spec(
  "cb1", "Quality drives intention", type = "cb_sem",
  constructs = list(
    sframe_construct("sq", "Service Quality", items = c("sq_1", "sq_2", "sq_3")),
    sframe_construct("sat", "Satisfaction", items = c("sat_1", "sat_2")),
    sframe_construct("bi", "Behavioural Intention", items = c("bi_1", "bi_2"))
  ),
  paths = list(sframe_path("sq", "sat"), sframe_path("sat", "bi")),
  indirect = list(sframe_indirect_effect("sq", through = "sat", to = "bi"))
)
m$type
#> [1] "cb_sem"
m$engine
#> [1] "lavaan"
```
