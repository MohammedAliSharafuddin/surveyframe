# Get an instrument component label

Reads the respondent- or analyst-facing label attached to a component.

## Usage

``` r
sf_label(x, ...)
```

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

A single character label, or `""` when none is declared.

## See also

[sf_identity](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_identity.md),
[`sf_id()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_id.md)

## Examples

``` r
sf_label(sf_item("q1", "Satisfaction", type = "numeric"))
#> [1] "Satisfaction"
```
