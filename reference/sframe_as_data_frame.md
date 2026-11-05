# Coerce a surveyframe object to a data frame

Every surveyframe class returns its primary table, and each class has
its own columns. Where an object holds more than one table, the others
are reachable through the named accessors in
[sframe_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_accessors.md),
or, for a full tabular record of an instrument, through
[`sframe_codebook()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_codebook.md).

## Value

A data frame, with the columns listed above for the class given.

## What each class gives

- `sframe`: one row per item, with `id`, `label`, `type`, `choice_set`,
  `scale_id`, `reverse` and `required`.

- `sframe_codebook`: one row per item, the codebook's item table.

- `sframe_validation`: one row per problem, with `check` and `problem`.

- `sframe_analysis_results`: one row per block, with `block`,
  `research_question`, `method` and `apa`.

- `sframe_reliability_report`: one row per scale, with `scale_id`,
  `label`, `n_items`, `n`, `alpha` and `omega`.

- `sframe_item_report`: one row per item, with `scale_id` and the item
  diagnostics.

- `sframe_quality_report`: one row per check, the flattened quality
  checks.

- `sframe_efa_report`: one row per measure, the readiness measures.

- `sframe_sensitivity`: one row per perturbation, with `criterion`,
  `direction`, `weight`, `rho`, `rank_changed` and `top_changed`.

## A summary, and where the full record is

These tables are a summary of the columns a reader scans first. The item
table leaves out help text, placeholder, matrix rows, comparison items
and scale, slider and rating settings, date bounds, section introduction
and page; the scale table leaves out `min_valid`, the reverse key and
the weights. Read the stored declaration in full through
[`sframe_get_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_items.md),
[`sframe_get_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_scales.md)
and the rest of
[sframe_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_accessors.md),
each of which returns the component objects themselves, or through
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
for the interchange record.

A class holding one table returns it directly, so it keeps that table's
own row names and `row.names` has no effect. Pass `row.names` to
[`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) on
the returned frame where you need to set them. The coercion gives one
view of an object. An instrument, for example, returns its items, and
its choice sets and scales come from
[`sframe_get_choice_sets()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_choice_sets.md),
[`sframe_get_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_scales.md)
or
[`sframe_codebook()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_codebook.md).

## See also

[sframe_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_accessors.md),
[`sframe_codebook()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_codebook.md)

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
[`sframe_accessors`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_accessors.md),
[`sframe_apa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_apa.md),
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

as.data.frame(instr)
#>      id                            label   type choice_set scale_id reverse
#> 1 sat_1 The service met my expectations. likert        ag5      sat   FALSE
#>   required
#> 1    FALSE
as.data.frame(cs)
#>   value             label
#> 1     1 Strongly disagree
#> 2     2          Disagree
#> 3     3           Neutral
#> 4     4             Agree
#> 5     5    Strongly agree
```
