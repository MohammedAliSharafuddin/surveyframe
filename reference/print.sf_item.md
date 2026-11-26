# Print an sf_item object

Prints the item's ID, type and question label, with its choice set and
scale when it has them.

## Usage

``` r
# S3 method for class 'sf_item'
print(x, ...)
```

## Arguments

- x:

  An object of class `sf_item`.

- ...:

  Ignored. Present for S3 consistency.

## Value

`x`, invisibly.

## See also

Other Display methods:
[`format.sf_branch()`](https://surveyframe.org/reference/format.sf_branch.md),
[`format.sf_check()`](https://surveyframe.org/reference/format.sf_check.md),
[`format.sf_choices()`](https://surveyframe.org/reference/format.sf_choices.md),
[`format.sf_item()`](https://surveyframe.org/reference/format.sf_item.md),
[`format.sf_model()`](https://surveyframe.org/reference/format.sf_model.md),
[`format.sf_scale()`](https://surveyframe.org/reference/format.sf_scale.md),
[`format.sframe()`](https://surveyframe.org/reference/format.sframe.md),
[`print.sf_branch()`](https://surveyframe.org/reference/print.sf_branch.md),
[`print.sf_check()`](https://surveyframe.org/reference/print.sf_check.md),
[`print.sf_choices()`](https://surveyframe.org/reference/print.sf_choices.md),
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
it <- sframe_item("q1", "How satisfied are you?", type = "likert",
                  choice_set = "agree5")
print(it)
```
