# Read the reportable parts of an analysis or quality result

[`sframe_apa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_apa.md)
returns the APA-formatted sentence a result carries.
[`sframe_flagged()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_flagged.md)
returns the rows a quality report flagged.

## Value

[`sframe_apa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_apa.md)
returns a character vector: one element per block, named by block, for
analysis results, and one element for a single report.
[`sframe_flagged()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_flagged.md)
returns an integer vector of row positions, sorted, each row once.

## Details

Given analysis results,
[`sframe_apa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_apa.md)
answers for every block at once, as a character vector named by block.
Given one of the standalone reports that carry a sentence of their own,
an assumption report, a descriptives report, a missing-data report or a
validity report, it returns that single sentence. A result with no
sentence gives an empty string, so the shape of the answer follows the
number of blocks asked about.

The sentence is plain text. APA 7 asks for italic Latin statistical
symbols, so a manuscript needs `t`, `F`, `p`, `r`, `d` and the rest
italicised after pasting: a character vector cannot carry that styling.
Numbers are already APA-formatted, including no leading zero on `p` and
a labelled confidence interval.

[`sframe_flagged()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_flagged.md)
returns row positions in the response data, as one sorted vector with
each row once, pooling every check the quality report ran: failed
attention checks, straight-lining, excess missingness, timing and
duplicates. Read the report itself for which check flagged a row.

## See also

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
[`sframe_meta()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_meta.md),
[`sframe_missing_columns()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_missing_columns.md),
[`sframe_notes()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_notes.md),
[`sframe_object()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_object.md),
[`sframe_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_problems.md),
[`sframe_subset`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_subset.md),
[`sframe_validation_accessors`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation_accessors.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
qr <- sframe_quality_results(demo$responses, demo$instrument)
head(sframe_flagged(qr))
#> [1]  37  48  61  73 107 108
```
