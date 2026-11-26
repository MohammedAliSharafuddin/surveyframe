# Post-hoc and pairwise comparison report

Follows a significant omnibus test with pairwise comparisons: group
pairs after ANOVA or Kruskal-Wallis, cell residuals and proportion tests
after chi-square, and McNemar tests after Cochran's Q.

## Usage

``` r
sframe_posthoc_results(
  data,
  method = c("anova", "kruskal_wallis", "chi_square", "cochran_q"),
  outcome = NULL,
  group = NULL,
  table_vars = NULL,
  measures = NULL,
  correction = c("holm", "bonferroni", "BH")
)
```

## Arguments

- data:

  A data.frame.

- method:

  Comparison family. Supports `"anova"`, `"kruskal_wallis"`,
  `"chi_square"` and `"cochran_q"`.

- outcome:

  Outcome variable for group comparisons.

- group:

  Grouping variable for group comparisons.

- table_vars:

  Two categorical variables for chi-square residuals and pairwise
  proportion tests.

- measures:

  Repeated binary measures for pairwise McNemar tests.

- correction:

  Multiple-comparison correction: `"holm"` (the default), `"bonferroni"`
  or `"BH"`.

## Value

An object of class `sframe_posthoc_report`.

## See also

Other Analyse functions:
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md),
[`score_scales()`](https://surveyframe.org/reference/score_scales.md),
[`sframe_assumption_results()`](https://surveyframe.org/reference/sframe_assumption_results.md),
[`sframe_descriptives_results()`](https://surveyframe.org/reference/sframe_descriptives_results.md),
[`sframe_efa_readiness_results()`](https://surveyframe.org/reference/sframe_efa_readiness_results.md),
[`sframe_efa_solution()`](https://surveyframe.org/reference/sframe_efa_solution.md),
[`sframe_item_results()`](https://surveyframe.org/reference/sframe_item_results.md),
[`sframe_reliability_results()`](https://surveyframe.org/reference/sframe_reliability_results.md),
[`sframe_validity_results()`](https://surveyframe.org/reference/sframe_validity_results.md)

## Examples

``` r
demo <- sframe_demo("multi_group")
pr <- sframe_posthoc_results(demo$responses, method = "kruskal_wallis",
                      outcome = "sessions_attended", group = "attendee_role")
pr$tables$pairwise_wilcox
```
