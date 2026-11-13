# Assumption-check report

Performs common assumption checks for survey analyses using base R where
possible: Shapiro-Wilk tests, skewness/kurtosis screening, Levene and
Brown-Forsythe tests, regression residual checks, VIF, Cook's distance,
expected-count checks, and sparse-cell warnings.

## Usage

``` r
sframe_assumption_results(
  data,
  variables = NULL,
  group = NULL,
  outcome = NULL,
  predictors = NULL,
  table_vars = NULL
)
```

## Arguments

- data:

  A data.frame.

- variables:

  Numeric variables for normality screening.

- group:

  Optional grouping variable for Levene/Brown-Forsythe tests.

- outcome:

  Optional regression outcome.

- predictors:

  Optional regression predictors.

- table_vars:

  Optional two categorical variables for expected-count checks.

## Value

An object of class `sframe_assumption_report`. Its `apa` names the
checks that ran, or says that none ran and which arguments each check
needs.

## See also

Other Analyse functions:
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
[`sframe_descriptives_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_descriptives_results.md),
[`sframe_efa_readiness_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_readiness_results.md),
[`sframe_efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_solution.md),
[`sframe_item_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item_results.md),
[`sframe_posthoc_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_posthoc_results.md),
[`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md),
[`sframe_validity_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validity_results.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
ar <- sframe_assumption_results(demo$responses, variables = c("sat_1", "sat_2"),
                         group = "visit_type")
print(ar)
#> Assumption Report
#> 
#> Normality:
#>  variable   n shapiro_w    shapiro_p    skewness   kurtosis
#>     sat_1 120 0.9087471 5.651017e-07 -0.17463397 -0.8225522
#>     sat_2 120 0.9033205 2.912675e-07  0.04066335 -0.9588129
#> 
#> Homogeneity of variance:
#>  variable           test         F         p
#>     sat_1         Levene 0.2848288 0.5945575
#>     sat_1 Brown-Forsythe 0.2292714 0.6329507
#>     sat_2         Levene 0.1956862 0.6590353
#>     sat_2 Brown-Forsythe 0.1522047 0.6971406
```
