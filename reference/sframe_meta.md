# Get survey metadata

Reads the title, version, description, language, validation state, and
other metadata without depending on the object's internal list layout.

## Usage

``` r
sframe_meta(x, ...)
```

## Arguments

- x:

  A surveyframe object.

- ...:

  Passed to methods.

## Value

A list of instrument or codebook metadata.

## See also

[sframe_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_accessors.md)

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
[`sframe_missing_columns()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_missing_columns.md),
[`sframe_notes()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_notes.md),
[`sframe_object()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_object.md),
[`sframe_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_problems.md),
[`sframe_report_accessors`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_report_accessors.md),
[`sframe_subset`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_subset.md),
[`sframe_validation_accessors`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation_accessors.md)

## Examples

``` r
sframe_meta(sframe_demo("tourism_services")$instrument)
#> $title
#> [1] "Tourism Services Experience Demo"
#> 
#> $version
#> [1] "0.3.0"
#> 
#> $description
#> [1] "Simulated demo questionnaire inspired by tourism-services research on digital marketing, service quality, sustainability, satisfaction, and behavioural intention."
#> 
#> $authors
#> [1] "Mohammed Ali Sharafuddin"
#> 
#> $languages
#> [1] "en"
#> 
#> $validated
#> [1] TRUE
#> 
#> $created_at
#> [1] "2026-05-13T18:16:19Z"
#> 
```
