# Descriptive statistics report

Computes survey descriptives for numeric, Likert, and scale-score
columns, including missingness, mean, standard deviation, median, IQR,
range, skewness, kurtosis, standard error, and confidence intervals.

## Usage

``` r
descriptives_report(
  data,
  variables = NULL,
  split_by = NULL,
  conf_level = 0.95,
  weights = NULL
)
```

## Arguments

- data:

  A data.frame of responses.

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

An object of class `sframe_descriptives_report`.

## Examples

``` r
demo <- sframe_demo_data()
dr <- descriptives_report(demo$responses, variables = c("sat_1", "sat_2"),
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
