# Print an sf_check object

Print an sf_check object

## Usage

``` r
# S3 method for class 'sf_check'
print(x, ...)
```

## Arguments

- x:

  An object of class `sf_check`.

- ...:

  Ignored. Present for S3 consistency.

## Value

`x`, invisibly.

## See also

Other print, format and summary methods:
[`format.sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sf_branch.md),
[`format.sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sf_check.md),
[`format.sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sf_choices.md),
[`format.sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sf_item.md),
[`format.sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sf_model.md),
[`format.sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sf_scale.md),
[`format.sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/format.sframe.md),
[`print.sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_branch.md),
[`print.sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_choices.md),
[`print.sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_item.md),
[`print.sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_model.md),
[`print.sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_scale.md),
[`print.sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sframe.md),
[`summary.sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_branch.md),
[`summary.sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_check.md),
[`summary.sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_choices.md),
[`summary.sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_item.md),
[`summary.sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_model.md),
[`summary.sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_scale.md),
[`summary.sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sframe.md)

## Examples

``` r
ck <- sframe_attention_check("attn1", item_id = "q5", type = "attention",
               pass_values = 3)
print(ck)
#> <sf_check: attn1 | type: attention>
#>   Item: q5
#>   Pass values: 3
```
