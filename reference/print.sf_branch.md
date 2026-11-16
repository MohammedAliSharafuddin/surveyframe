# Print an sf_branch object

Print an sf_branch object

## Usage

``` r
# S3 method for class 'sf_branch'
print(x, ...)
```

## Arguments

- x:

  An object of class `sf_branch`.

- ...:

  Ignored. Present for S3 consistency.

## Value

`x`, invisibly.

## See also

Other printing formatting and summary methods:
[`format.sf_branch()`](https://surveyframe.org/reference/format.sf_branch.md),
[`format.sf_check()`](https://surveyframe.org/reference/format.sf_check.md),
[`format.sf_choices()`](https://surveyframe.org/reference/format.sf_choices.md),
[`format.sf_item()`](https://surveyframe.org/reference/format.sf_item.md),
[`format.sf_model()`](https://surveyframe.org/reference/format.sf_model.md),
[`format.sf_scale()`](https://surveyframe.org/reference/format.sf_scale.md),
[`format.sframe()`](https://surveyframe.org/reference/format.sframe.md),
[`print.sf_check()`](https://surveyframe.org/reference/print.sf_check.md),
[`print.sf_choices()`](https://surveyframe.org/reference/print.sf_choices.md),
[`print.sf_item()`](https://surveyframe.org/reference/print.sf_item.md),
[`print.sf_model()`](https://surveyframe.org/reference/print.sf_model.md),
[`print.sf_scale()`](https://surveyframe.org/reference/print.sf_scale.md),
[`print.sframe()`](https://surveyframe.org/reference/print.sframe.md),
[`summary.sf_branch()`](https://surveyframe.org/reference/summary.sf_branch.md),
[`summary.sf_check()`](https://surveyframe.org/reference/summary.sf_check.md),
[`summary.sf_choices()`](https://surveyframe.org/reference/summary.sf_choices.md),
[`summary.sf_item()`](https://surveyframe.org/reference/summary.sf_item.md),
[`summary.sf_model()`](https://surveyframe.org/reference/summary.sf_model.md),
[`summary.sf_scale()`](https://surveyframe.org/reference/summary.sf_scale.md),
[`summary.sframe()`](https://surveyframe.org/reference/summary.sframe.md)

## Examples

``` r
br <- sframe_branch("q2", depends_on = "q1", operator = "==",
                value = "yes", action = "show")
print(br)
```
