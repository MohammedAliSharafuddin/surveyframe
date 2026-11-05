# Summarise an sframe instrument object

Prints a structured summary of an `sframe` object including metadata,
item type counts, scale definitions, branching rules, and check
specifications.

## Usage

``` r
# S3 method for class 'sframe'
summary(object, ...)
```

## Arguments

- object:

  An object of class `sframe`.

- ...:

  Ignored. Present for S3 consistency.

## Value

`object`, invisibly.

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
[`print.sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/print.sframe.md),
[`summary.sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_branch.md),
[`summary.sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_check.md),
[`summary.sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_choices.md),
[`summary.sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_item.md),
[`summary.sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_model.md),
[`summary.sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/summary.sf_scale.md)

## Examples

``` r
item <- sframe_item("q1", "How satisfied are you?", type = "likert",
                choice_set = "agree5")
instr <- sframe_instrument("My Survey", components = list(item))
summary(instr)
#> Survey Instrument: My Survey
#> Version:           0.1.0
#> Languages:         en
#> 
#> Items:
#>   likert               1
#>   TOTAL                1
#> 
#> Scales:    0
#> Branches:  0
#> Checks:    0
#> 
#> Analysis plan: 0 block(s)
#> 
#> Status:    not validated
```
