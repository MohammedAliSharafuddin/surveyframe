# Coerce a response-quality report to a data frame

Coerce a response-quality report to a data frame

## Usage

``` r
# S3 method for class 'sframe_quality_report'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
```

## Arguments

- x:

  A surveyframe object.

- row.names:

  Passed to
  [`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html)
  by the methods that build a frame. Ignored by the methods that return
  a stored table.

- optional:

  Passed to
  [`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

- ...:

  Ignored. Present for S3 consistency.

## Value

A one-row data frame summarising respondents, items, and quality flags.

## See also

[sframe_as_data_frame](https://surveyframe.org/reference/sframe_as_data_frame.md),
[`sframe_quality_results()`](https://surveyframe.org/reference/sframe_quality_results.md)

Other Inspect functions:
[`as.data.frame.sf_choices()`](https://surveyframe.org/reference/as.data.frame.sf_choices.md),
[`as.data.frame.sframe()`](https://surveyframe.org/reference/as.data.frame.sframe.md),
[`as.data.frame.sframe_analysis_results()`](https://surveyframe.org/reference/as.data.frame.sframe_analysis_results.md),
[`as.data.frame.sframe_assumption_report()`](https://surveyframe.org/reference/as.data.frame.sframe_assumption_report.md),
[`as.data.frame.sframe_codebook()`](https://surveyframe.org/reference/as.data.frame.sframe_codebook.md),
[`as.data.frame.sframe_descriptives_report()`](https://surveyframe.org/reference/as.data.frame.sframe_descriptives_report.md),
[`as.data.frame.sframe_efa_report()`](https://surveyframe.org/reference/as.data.frame.sframe_efa_report.md),
[`as.data.frame.sframe_efa_solution()`](https://surveyframe.org/reference/as.data.frame.sframe_efa_solution.md),
[`as.data.frame.sframe_item_report()`](https://surveyframe.org/reference/as.data.frame.sframe_item_report.md),
[`as.data.frame.sframe_missing_data_report()`](https://surveyframe.org/reference/as.data.frame.sframe_missing_data_report.md),
[`as.data.frame.sframe_reliability_report()`](https://surveyframe.org/reference/as.data.frame.sframe_reliability_report.md),
[`as.data.frame.sframe_sample_size_plan()`](https://surveyframe.org/reference/as.data.frame.sframe_sample_size_plan.md),
[`as.data.frame.sframe_sensitivity()`](https://surveyframe.org/reference/as.data.frame.sframe_sensitivity.md),
[`as.data.frame.sframe_validation()`](https://surveyframe.org/reference/as.data.frame.sframe_validation.md),
[`as.data.frame.sframe_validity_report()`](https://surveyframe.org/reference/as.data.frame.sframe_validity_report.md),
[`sf_component_list`](https://surveyframe.org/reference/sf_component_list.md),
[`sframe_accessors`](https://surveyframe.org/reference/sframe_accessors.md),
[`sframe_apa()`](https://surveyframe.org/reference/sframe_apa.md),
[`sframe_as_data_frame()`](https://surveyframe.org/reference/sframe_as_data_frame.md),
[`sframe_flagged()`](https://surveyframe.org/reference/sframe_flagged.md),
[`sframe_get_attention_checks()`](https://surveyframe.org/reference/sframe_get_attention_checks.md),
[`sframe_get_branches()`](https://surveyframe.org/reference/sframe_get_branches.md),
[`sframe_get_choice_sets()`](https://surveyframe.org/reference/sframe_get_choice_sets.md),
[`sframe_get_items()`](https://surveyframe.org/reference/sframe_get_items.md),
[`sframe_get_models()`](https://surveyframe.org/reference/sframe_get_models.md),
[`sframe_get_scales()`](https://surveyframe.org/reference/sframe_get_scales.md),
[`sframe_id()`](https://surveyframe.org/reference/sframe_id.md),
[`sframe_identity`](https://surveyframe.org/reference/sframe_identity.md),
[`sframe_is_valid()`](https://surveyframe.org/reference/sframe_is_valid.md),
[`sframe_label()`](https://surveyframe.org/reference/sframe_label.md),
[`sframe_meta()`](https://surveyframe.org/reference/sframe_meta.md),
[`sframe_missing_columns()`](https://surveyframe.org/reference/sframe_missing_columns.md),
[`sframe_notes()`](https://surveyframe.org/reference/sframe_notes.md),
[`sframe_object()`](https://surveyframe.org/reference/sframe_object.md),
[`sframe_problems()`](https://surveyframe.org/reference/sframe_problems.md),
[`sframe_report_accessors`](https://surveyframe.org/reference/sframe_report_accessors.md),
[`sframe_subset`](https://surveyframe.org/reference/sframe_subset.md),
[`sframe_validation_accessors`](https://surveyframe.org/reference/sframe_validation_accessors.md)
