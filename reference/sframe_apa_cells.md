# Format a result table's cells as an APA 7 report prints them

The cells of a table from
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
as both report engines and
[`sframe_format_result()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_format_result.md)
print them, so a table shows the same numbers wherever it appears. A p
value column shows 3 decimals with no leading zero, or `<.001`. A column
that cannot exceed 1, such as `r`, `tau` or `alpha`, drops its leading
zero. Other numbers show 2 decimals, whole numbers none. A missing value
is a blank cell.

## Usage

``` r
sframe_apa_cells(x, digits = 2)

sframe_apa_col_labels(names, format = c("html", "markdown"), conf_level = 0.95)
```

## Arguments

- x:

  A data frame, such as a result's `table`.

- digits:

  Decimals for numbers other than p values.

- names:

  Column names.

- format:

  `"html"` for HTML headings, `"markdown"` for the pipe tables of Word,
  OpenDocument and PDF reports.

- conf_level:

  The confidence level a `ci_low` or `ci_high` heading states.

## Value

A data frame of character columns with the same names.

## Details

This is exported because the Quarto report template runs in a separate R
session against the installed package.

`sframe_apa_col_labels()` gives the headings both report engines print
for a table's columns: words for a column such as `valid_n` ("Valid
*n*"), statistic symbols in italics (*M*, *SD*, *Mdn*, *SE*) and the
confidence level in an interval heading ("95% CI lower").

## See also

[`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md),
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)

## Examples

``` r
sframe_apa_cells(data.frame(t = 2.345, p = 0.004, r = 0.53, n = 40L))
#>      t    p   r  n
#> 1 2.35 .004 .53 40
```
