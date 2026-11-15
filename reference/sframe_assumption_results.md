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

  Optional 2 categorical variables for expected-count checks.

## Value

An object of class `sframe_assumption_report`. Its `apa` names the
checks that ran, or says that none ran and which arguments each check
needs.

## See also

Other Analyse functions:
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md),
[`score_scales()`](https://surveyframe.org/reference/score_scales.md),
[`sframe_descriptives_results()`](https://surveyframe.org/reference/sframe_descriptives_results.md),
[`sframe_efa_readiness_results()`](https://surveyframe.org/reference/sframe_efa_readiness_results.md),
[`sframe_efa_solution()`](https://surveyframe.org/reference/sframe_efa_solution.md),
[`sframe_item_results()`](https://surveyframe.org/reference/sframe_item_results.md),
[`sframe_posthoc_results()`](https://surveyframe.org/reference/sframe_posthoc_results.md),
[`sframe_reliability_results()`](https://surveyframe.org/reference/sframe_reliability_results.md),
[`sframe_validity_results()`](https://surveyframe.org/reference/sframe_validity_results.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
ar <- sframe_assumption_results(demo$responses, variables = c("sat_1", "sat_2"),
                         group = "visit_type")
print(ar)
```
