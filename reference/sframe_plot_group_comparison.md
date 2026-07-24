# Group-comparison boxplot

Boxplot with jittered points, shared across every runner whose result
carries `vars = c(group_column, outcome_column)`: `t_test_ind`,
`mann_whitney`, `kruskal_wallis`, and `anova_one`. One function instead
of four, since the underlying comparison (an outcome split by a grouping
factor) and the data shape needed to plot it are identical across all
four tests; only the inferential statistic differs.

## Usage

``` r
sframe_plot_group_comparison(result, data, palette = c("web", "print"))
```

## Arguments

- result:

  A result list from one of the four runners above, with
  `vars = c(group_column, outcome_column)`.

- data:

  The response data frame the result was computed from.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` if the columns are missing, fewer than two
groups remain after removing missing values, or ggplot2 is unavailable.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
