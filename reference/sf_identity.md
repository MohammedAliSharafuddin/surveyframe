# The ID and label of an instrument component

The ID and label of an instrument component

## Arguments

- x:

  An
  [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md),
  [`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md),
  [`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md),
  [`sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_branch.md),
  [`sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_check.md)
  or
  [`sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_model.md)
  object.

- ...:

  Passed to methods.

## Value

A single character string.
[`sf_label()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_label.md)
returns `""` when the component carries no label.

## Examples

``` r
item <- sf_item("q1", "How satisfied are you?", type = "likert",
                choice_set = "agree5")
sf_id(item)
#> [1] "q1"
sf_label(item)
#> [1] "How satisfied are you?"
```
