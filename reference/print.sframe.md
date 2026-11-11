# Print an sframe instrument object

Displays a compact summary of an `sframe` instrument object, showing the
title, version, item count, scale count, and validation status. The
status comes from
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
run on `x`, not from a stored flag.

## Usage

``` r
# S3 method for class 'sframe'
print(x, ...)
```

## Arguments

- x:

  An object of class `sframe`.

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
[`print.sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_check.md),
[`print.sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_choices.md),
[`print.sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_item.md),
[`print.sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_model.md),
[`print.sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sf_scale.md),
[`summary.sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_branch.md),
[`summary.sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_check.md),
[`summary.sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_choices.md),
[`summary.sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_item.md),
[`summary.sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_model.md),
[`summary.sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_scale.md),
[`summary.sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sframe.md)

## Examples

``` r
item <- sframe_item("q1", "How satisfied are you?", type = "likert",
                choice_set = "agree5")
instr <- sframe_instrument("My Survey", components = list(item))
print(instr)
#> <sframe>
#>   Title:      My Survey
#>   Version:    0.1.0
#>   Items:      1
#>   Scales:     0
#>   Analysis:   0 blocks
#>   Status:     invalid, 1 problem. validate_sframe(x, strict = FALSE) lists them
```
