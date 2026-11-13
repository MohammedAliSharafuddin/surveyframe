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

  Optional case-weight column.

## Value

An object of class `sframe_descriptives_report`. Its `table` has 1 row
per variable and group. `valid_n` and `missing_n` count the responses as
given. A variable whose responses are not all numbers, such as a choice
item's category codes, keeps those counts and has `NA` in every numeric
column, since a mean or standard deviation does not apply.

## See also

Other Analyse functions:
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
[`sframe_assumption_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_assumption_results.md),
[`sframe_efa_readiness_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_readiness_results.md),
[`sframe_efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_solution.md),
[`sframe_item_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item_results.md),
[`sframe_posthoc_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_posthoc_results.md),
[`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md),
[`sframe_validity_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validity_results.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
dr <- sframe_descriptives_results(demo$responses, variables = c("sat_1", "sat_2"),
                           split_by = "visit_type")
dr$table
#>   variable      group  n valid_n missing_n     mean       sd median iqr min max
#> 1    sat_1 first_time 69      69         0 3.304348 1.128564      3   2   1   5
#> 2    sat_2 first_time 69      69         0 3.304348 1.115458      3   2   1   5
#> 3    sat_1     repeat 51      51         0 3.352941 1.230017      3   1   1   5
#> 4    sat_2     repeat 51      51         0 3.196078 1.095803      3   2   1   5
#>      skewness   kurtosis        se   ci_low  ci_high weighted_mean
#> 1 -0.06072425 -0.9308346 0.1358632 3.033237 3.575459            NA
#> 2  0.01883148 -1.0416986 0.1342853 3.036386 3.572310            NA
#> 3 -0.29859520 -0.8012592 0.1722368 3.006993 3.698889            NA
#> 4  0.06405216 -0.9234196 0.1534431 2.887879 3.504278            NA
```
