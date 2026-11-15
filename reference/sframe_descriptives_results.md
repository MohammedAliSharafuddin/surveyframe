# Descriptive statistics report

Computes survey descriptives for numeric, Likert, and scale-score
columns, including missingness, mean, standard deviation, median, IQR,
range, skewness, kurtosis, standard error, and confidence intervals.

## Usage

``` r
sframe_descriptives_results(
  data,
  variables = NULL,
  split_by = NULL,
  conf_level = 0.95,
  weights = NULL
)
```

## Arguments

- data:

  A data.frame of responses. A blank answer (an empty string, or only
  spaces) counts as missing, and a factor's unused levels are dropped.

- variables:

  Character vector of variables. When `NULL`, numeric-like columns are
  used.

- split_by:

  Optional grouping variable.

- conf_level:

  Confidence level for the mean interval.

- weights:

  Optional case-weight column, such as a design weight the researcher
  set. A named column missing from `data` is an error.

## Value

An object of class `sframe_descriptives_report`. Its `table` has 1 row
per variable and group. `valid_n` and `missing_n` count the responses as
given. A variable whose responses are not all numbers, such as a choice
item's category codes, keeps those counts and has `NA` in every numeric
column, since a mean or standard deviation does not apply.

## See also

Other Analyse functions:
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md),
[`score_scales()`](https://surveyframe.org/reference/score_scales.md),
[`sframe_assumption_results()`](https://surveyframe.org/reference/sframe_assumption_results.md),
[`sframe_efa_readiness_results()`](https://surveyframe.org/reference/sframe_efa_readiness_results.md),
[`sframe_efa_solution()`](https://surveyframe.org/reference/sframe_efa_solution.md),
[`sframe_item_results()`](https://surveyframe.org/reference/sframe_item_results.md),
[`sframe_posthoc_results()`](https://surveyframe.org/reference/sframe_posthoc_results.md),
[`sframe_reliability_results()`](https://surveyframe.org/reference/sframe_reliability_results.md),
[`sframe_validity_results()`](https://surveyframe.org/reference/sframe_validity_results.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
dr <- sframe_descriptives_results(demo$responses, variables = c("sat_1", "sat_2"),
                           split_by = "visit_type")
dr$table
```
