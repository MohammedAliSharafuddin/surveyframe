# Raw-variable distribution panels: histogram, boxplot, and Q-Q

Unlike
[`sframe_plot_descriptives()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_descriptives.md),
which summarises skewness and kurtosis *across* the variables in a
[`descriptives_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/descriptives_report.md)
table, this operates on one variable's raw values directly (the report
table only stores summary statistics, not the underlying vector),
matching the pattern
[`sframe_plot_correlation_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_correlation_matrix.md)
already uses for report-independent, data-driven plots.

## Usage

``` r
sframe_plot_variable_distribution(data, variable, palette = c("web", "print"))
```

## Arguments

- data:

  A data frame of survey responses.

- variable:

  Character. Column name of the variable to plot.

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A named list of three ggplot2 objects (`histogram`, `boxplot`, `qq`), or
`NULL` if fewer than two complete values remain.

## See also

[`descriptives_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/descriptives_report.md),
[`sframe_plot_descriptives()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_descriptives.md)
