# Extract APA-formatted result summaries

Returns the report-ready sentence attached to each analysis result.

## Usage

``` r
sframe_apa(x, ...)
```

## Arguments

- x:

  An `sframe_analysis_results`, `sframe_descriptives_report`,
  `sframe_missing_data_report`, `sframe_validity_report`, or
  `sframe_assumption_report` object.

- ...:

  Passed to methods.

## Value

A character vector containing one APA-formatted summary per result.

## See also

[sframe_report_accessors](https://surveyframe.org/reference/sframe_report_accessors.md),
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md)

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
[`as.data.frame.sframe_quality_report()`](https://surveyframe.org/reference/as.data.frame.sframe_quality_report.md),
[`as.data.frame.sframe_reliability_report()`](https://surveyframe.org/reference/as.data.frame.sframe_reliability_report.md),
[`as.data.frame.sframe_sample_size_plan()`](https://surveyframe.org/reference/as.data.frame.sframe_sample_size_plan.md),
[`as.data.frame.sframe_sensitivity()`](https://surveyframe.org/reference/as.data.frame.sframe_sensitivity.md),
[`as.data.frame.sframe_validation()`](https://surveyframe.org/reference/as.data.frame.sframe_validation.md),
[`as.data.frame.sframe_validity_report()`](https://surveyframe.org/reference/as.data.frame.sframe_validity_report.md),
[`sf_component_list`](https://surveyframe.org/reference/sf_component_list.md),
[`sframe_accessors`](https://surveyframe.org/reference/sframe_accessors.md),
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

## Examples

``` r
results <- structure(
  list(RQ1 = list(apa = "Mean satisfaction was 4.20.")),
  class = c("sframe_analysis_results", "list")
)
sframe_apa(results)
```
