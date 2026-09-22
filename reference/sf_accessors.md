# Explore a surveyframe object

Accessors for the parts of an instrument, a codebook, or a report. They
replace reaching into the object with `$`, which ties user code to the
internal layout.

## Arguments

- x:

  A surveyframe object.

- ...:

  Passed to methods.

## Value

A list for
[`sf_meta()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_meta.md)
and
[`sf_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_plan.md)
on an instrument, an
[sf_component_list](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_component_list.md)
for the component accessors on an instrument, and a data frame for any
of them on a codebook. See the table above.

## Details

What each one gives back depends on what it is asked. Given an
instrument, the component accessors return the component objects as an
[sf_component_list](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_component_list.md),
which prints as a list and is subset with `[` and `[[`. Given a
codebook, the same verbs return the table the codebook already holds, a
plain data frame with one row per item, scale, choice set, model or plan
block.

|  |  |  |
|----|----|----|
| Accessor | On an `sframe` | On an `sframe_codebook` |
| [`sf_meta()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_meta.md) | list of metadata | list of metadata |
| [`sf_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_items.md) | `sf_component_list` of items | data frame of items |
| [`sf_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scales.md) | `sf_component_list` of scales | data frame of scales |
| [`sf_choice_sets()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choice_sets.md) | `sf_component_list` of choice sets | data frame of choice sets |
| [`sf_branches()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_branches.md) | `sf_component_list` of branching rules | not available |
| [`sf_checks()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_checks.md) | `sf_component_list` of checks | not available |
| [`sf_models()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_models.md) | `sf_component_list` of models | data frame of models |
| [`sf_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_plan.md) | list of plan blocks | data frame of plan blocks |

[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) on an
instrument gives its items as a table, which is one part of it, and a
component list has no coercion of its own. For every table an instrument
can produce, use
[`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md).

## See also

[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md),
[`sf_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_problems.md),
[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)

## Examples

``` r
cs    <- sf_choices("ag5", 1:5,
           c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree"))
item  <- sf_item("sat_1", "The service met my expectations.",
                 type = "likert", choice_set = "ag5", scale_id = "sat")
scale <- sf_scale("sat", "Satisfaction", items = "sat_1")
instr <- sf_instrument("Demo Survey", components = list(cs, item, scale))

sf_meta(instr)$title
#> [1] "Demo Survey"
sf_items(instr)
#> <item list: 1>
#>  <sf_item: sat_1 | type: likert>
sf_scales(instr)[["sat"]]
#> <sf_scale: sat | 1 item(s)>
#>   Label: Satisfaction
#>   Items: sat_1
#>   Scoring: mean
as.data.frame(instr)
#>      id                            label   type choice_set scale_id reverse
#> 1 sat_1 The service met my expectations. likert        ag5      sat   FALSE
#>   required
#> 1    FALSE
```
