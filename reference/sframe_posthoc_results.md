# Post-hoc and pairwise comparison report

Post-hoc and pairwise comparison report

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
  `"chi_square"`, and `"cochran_q"`.

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

  Multiple-comparison correction.

## Value

An object of class `sframe_posthoc_report`.

## See also

Other Analyse functions:
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
[`sframe_assumption_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_assumption_results.md),
[`sframe_descriptives_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_descriptives_results.md),
[`sframe_efa_readiness_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_readiness_results.md),
[`sframe_efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_solution.md),
[`sframe_item_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item_results.md),
[`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md),
[`sframe_validity_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validity_results.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
pr <- sframe_posthoc_results(demo$responses, method = "kruskal_wallis",
                      outcome = "sat_1", group = "visit_type")
pr$tables$pairwise_wilcox
#> 
#>  Pairwise comparisons using Wilcoxon rank sum test with continuity correction 
#> 
#> data:  x[ok] and g[ok] 
#> 
#>        first_time
#> repeat 0.73      
#> 
#> P value adjustment method: holm 
```
