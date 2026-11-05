# Explore a surveyframe object

Accessors for the parts of an instrument, a codebook, or a report. They
replace reaching into the object with `$`, which ties user code to the
internal layout.

## Value

A list for
[`sframe_meta()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_meta.md)
and
[`sframe_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plan.md)
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
| [`sframe_meta()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_meta.md) | list of metadata | list of metadata |
| [`sframe_get_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_items.md) | `sf_component_list` of items | data frame of items |
| [`sframe_get_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_scales.md) | `sf_component_list` of scales | data frame of scales |
| [`sframe_get_choice_sets()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_choice_sets.md) | `sf_component_list` of choice sets | data frame of choice sets |
| [`sframe_get_branches()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_branches.md) | `sf_component_list` of branching rules | not available |
| [`sframe_get_attention_checks()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_attention_checks.md) | `sf_component_list` of checks | not available |
| [`sframe_get_models()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_models.md) | `sf_component_list` of models | data frame of models |
| [`sframe_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plan.md) | list of plan blocks | data frame of plan blocks |

[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) on an
instrument gives its items as a table, which is one part of it, and a
component list has no coercion of its own. For every table an instrument
can produce, use
[`sframe_codebook()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_codebook.md).

## See also

[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md),
[`sframe_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_problems.md),
[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)

Other Inspect functions:
[`as.data.frame.sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sf_choices.md),
[`as.data.frame.sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe.md),
[`as.data.frame.sframe_analysis_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe_analysis_results.md),
[`as.data.frame.sframe_assumption_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe_assumption_report.md),
[`as.data.frame.sframe_codebook()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe_codebook.md),
[`as.data.frame.sframe_descriptives_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe_descriptives_report.md),
[`as.data.frame.sframe_efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe_efa_report.md),
[`as.data.frame.sframe_efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe_efa_solution.md),
[`as.data.frame.sframe_item_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe_item_report.md),
[`as.data.frame.sframe_missing_data_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe_missing_data_report.md),
[`as.data.frame.sframe_quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe_quality_report.md),
[`as.data.frame.sframe_reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe_reliability_report.md),
[`as.data.frame.sframe_sample_size_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe_sample_size_plan.md),
[`as.data.frame.sframe_sensitivity()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe_sensitivity.md),
[`as.data.frame.sframe_validation()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe_validation.md),
[`as.data.frame.sframe_validity_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as.data.frame.sframe_validity_report.md),
[`sf_component_list`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_component_list.md),
[`sframe_apa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_apa.md),
[`sframe_as_data_frame()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_as_data_frame.md),
[`sframe_flagged()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_flagged.md),
[`sframe_get_attention_checks()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_attention_checks.md),
[`sframe_get_branches()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_branches.md),
[`sframe_get_choice_sets()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_choice_sets.md),
[`sframe_get_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_items.md),
[`sframe_get_models()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_models.md),
[`sframe_get_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_scales.md),
[`sframe_id()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_id.md),
[`sframe_identity`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_identity.md),
[`sframe_is_valid()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_is_valid.md),
[`sframe_label()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_label.md),
[`sframe_meta()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_meta.md),
[`sframe_missing_columns()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_missing_columns.md),
[`sframe_notes()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_notes.md),
[`sframe_object()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_object.md),
[`sframe_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_problems.md),
[`sframe_report_accessors`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_report_accessors.md),
[`sframe_subset`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_subset.md),
[`sframe_validation_accessors`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation_accessors.md)

## Examples

``` r
cs    <- sframe_choice_set("ag5", 1:5,
           c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree"))
item  <- sframe_item("sat_1", "The service met my expectations.",
                 type = "likert", choice_set = "ag5", scale_id = "sat")
scale <- sframe_scale("sat", "Satisfaction", items = "sat_1")
instr <- sframe_instrument("Demo Survey", components = list(cs, item, scale))

sframe_meta(instr)$title
#> [1] "Demo Survey"
sframe_get_items(instr)
#> <item list: 1>
#>  <sf_item: sat_1 | type: likert>
sframe_get_scales(instr)[["sat"]]
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
