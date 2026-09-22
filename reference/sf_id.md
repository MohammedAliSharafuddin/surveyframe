# Get an instrument component ID

Reads the stable identifier used to refer to a component elsewhere in
the instrument.

## Usage

``` r
sf_id(x, ...)
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

A single character identifier.

## See also

[sf_identity](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_identity.md),
[`sf_label()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_label.md)

## Examples

``` r
sf_id(sf_item("q1", "Satisfaction", type = "numeric"))
#> [1] "q1"
```
