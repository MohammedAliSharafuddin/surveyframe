# Validate a surveyframe model specification

Checks model IDs, construct IDs, indicators, structural path endpoints,
duplicate paths, indirect paths, and engine/type compatibility.

## Usage

``` r
sframe_validate_model(model, instrument = NULL, strict = TRUE)
```

## Arguments

- model:

  An
  [`sframe_model_spec()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_spec.md)
  object or compatible list.

- instrument:

  Optional `sframe` object. When supplied, model indicators must match
  instrument item IDs.

- strict:

  Logical. When `TRUE`, invalid models raise an error. When `FALSE`,
  problems are reported in the returned diagnostic without stopping.

## Value

An
[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
object. The model is carried inside it and can be recovered with
[`sframe_object()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_object.md).

## Changed in 0.4.0

Earlier versions returned the model invisibly when `strict = TRUE` and a
bare unclassed list when `strict = FALSE`. Both paths now return an
[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
object, visibly, so the diagnostic is readable at the console. Code that
read `$valid` and `$problems` keeps working.

## See also

[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md),
[`sframe_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_problems.md),
[`sframe_is_valid()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_is_valid.md)

Other Models and syntax functions:
[`sframe_add_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_add_model.md),
[`sframe_construct()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_construct.md),
[`sframe_covariance()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_covariance.md),
[`sframe_indirect_effect()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_indirect_effect.md),
[`sframe_model_json()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_json.md),
[`sframe_model_outline()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_outline.md),
[`sframe_model_spec()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_model_spec.md),
[`sframe_path()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_path.md),
[`sframe_syntax_cfa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_cfa.md),
[`sframe_syntax_efa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_efa.md),
[`sframe_syntax_pls()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_pls.md),
[`sframe_syntax_result()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_result.md),
[`sframe_syntax_sem()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_sem.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
m <- sframe_model_spec(
  "cb1", type = "cb_sem",
  constructs = list(
    sframe_construct("sq", items = c("sq_1", "sq_2", "sq_3")),
    sframe_construct("sat", items = c("sat_1", "sat_2"))
  ),
  paths = list(sframe_path("sq", "sat"))
)
diag <- sframe_validate_model(m, instrument = demo$instrument)
diag
#> <sframe validation>
#>   Model:       cb1 (cb_sem)
#>   Status:      valid
#>   Checks:      10 run, 0 with problems
```
