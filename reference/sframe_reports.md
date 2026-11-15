# Choosing a report

The 12 report functions split into 2 shapes, and the split is what tells
them apart.

## Data in, object out

These compute and return an object you can read, coerce with
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) and often
plot.

|  |  |
|----|----|
| Function | Answers |
| [`sframe_codebook()`](https://surveyframe.org/reference/sframe_codebook.md) | what the instrument declares, as tables |
| [`sframe_descriptives_results()`](https://surveyframe.org/reference/sframe_descriptives_results.md) | the distribution of each variable |
| [`sframe_missing_data_results()`](https://surveyframe.org/reference/sframe_missing_data_results.md) | what is missing, and in what pattern |
| [`sframe_quality_results()`](https://surveyframe.org/reference/sframe_quality_results.md) | which responses the declared checks flagged |
| [`sframe_reliability_results()`](https://surveyframe.org/reference/sframe_reliability_results.md) | alpha and omega per scale |
| [`sframe_item_results()`](https://surveyframe.org/reference/sframe_item_results.md) | how each item behaves inside its scale |
| [`sframe_efa_readiness_results()`](https://surveyframe.org/reference/sframe_efa_readiness_results.md) | whether the data suit a factor analysis |
| [`sframe_validity_results()`](https://surveyframe.org/reference/sframe_validity_results.md) | convergent and discriminant validity |
| [`sframe_assumption_results()`](https://surveyframe.org/reference/sframe_assumption_results.md) | whether a planned test's assumptions hold |
| [`sframe_posthoc_results()`](https://surveyframe.org/reference/sframe_posthoc_results.md) | which pairs differ after an omnibus test |

Each returns its primary table through
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html), with the
rest reachable through the accessors in
[sframe_accessors](https://surveyframe.org/reference/sframe_accessors.md).
A failure is carried in the object as an error field, so a report keeps
rendering around it.

## Object or data in, file out

|  |  |
|----|----|
| Function | Writes |
| [`render_report()`](https://surveyframe.org/reference/render_report.md) | a whole document, computing its sections from the data |
| [`render_results()`](https://surveyframe.org/reference/render_results.md) | a document from analysis results you already have |

Reach for
[`render_results()`](https://surveyframe.org/reference/render_results.md)
where
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md)
has already run, and
[`render_report()`](https://surveyframe.org/reference/render_report.md)
to go from responses to a document in one call.

## See also

[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md),
[sframe_plots](https://surveyframe.org/reference/sframe_plots.md)

Other Report functions:
[`render_report()`](https://surveyframe.org/reference/render_report.md),
[`render_results()`](https://surveyframe.org/reference/render_results.md),
[`sframe_analysis_qmd()`](https://surveyframe.org/reference/sframe_analysis_qmd.md),
[`sframe_codebook()`](https://surveyframe.org/reference/sframe_codebook.md),
[`sframe_format_result()`](https://surveyframe.org/reference/sframe_format_result.md),
[`sframe_report_source()`](https://surveyframe.org/reference/sframe_report_source.md),
[`sframe_save_figures()`](https://surveyframe.org/reference/sframe_save_figures.md),
[`sframe_show()`](https://surveyframe.org/reference/sframe_show.md)
