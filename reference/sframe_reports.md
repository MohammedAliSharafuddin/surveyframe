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
| [`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md) | what the instrument declares, as tables |
| [`descriptives_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/descriptives_report.md) | the distribution of each variable |
| [`missing_data_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/missing_data_report.md) | what is missing, and in what pattern |
| [`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md) | which responses the declared checks flagged |
| [`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md) | alpha and omega per scale |
| [`item_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/item_report.md) | how each item behaves inside its scale |
| [`efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_report.md) | whether the data suit a factor analysis |
| [`validity_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validity_report.md) | convergent and discriminant validity |
| [`assumption_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/assumption_report.md) | whether a planned test's assumptions hold |
| [`posthoc_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/posthoc_report.md) | which pairs differ after an omnibus test |

Each returns its primary table through
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html), with the
rest reachable through the accessors in
[sf_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md).
A failure is carried in the object as an error field, so a report keeps
rendering around it.

## Object or data in, file out

|  |  |
|----|----|
| Function | Writes |
| [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md) | a whole document, computing its sections from the data |
| [`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md) | a document from analysis results you already have |

Reach for
[`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md)
where
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
has already run, and
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
to go from responses to a document in one call.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[sframe_plots](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plots.md)
