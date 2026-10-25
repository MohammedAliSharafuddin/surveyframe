# Render one analysis result as the report does

Takes one result from
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
and returns what the report shows for it: the formatted table with its
caption and note, any second table
[`sframe_result_supplement()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_result_supplement.md)
gives, the APA line, and the chart the report picks for that method,
with the instrument's labels. The table, the chart and their choice per
method come from the code
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
uses, so a host rendering results one at a time and the report agree.

## Usage

``` r
render_result(
  result,
  data,
  instrument = NULL,
  palette = c("web", "print"),
  format = c("html", "png", "svg"),
  width = 7,
  height = 4.5,
  dpi = 150
)
```

## Arguments

- result:

  One element of the list
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
  returns.

- data:

  The response data the result was computed from. The chart is drawn
  from it, with the scales scored first as
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
  scores them when `instrument` is given.

- instrument:

  The `sframe` the plan belongs to, or `NULL`. Gives the chart the item
  and choice labels the tables use.

- palette:

  `"web"` (default) or `"print"`, the report's 2 palettes.

- format:

  `"html"` (default) returns an HTML fragment with the chart embedded.
  `"png"` and `"svg"` write the chart to a file as well, and return its
  path in `chart_file`.

- width, height, dpi:

  The chart's size in inches and its resolution, for the embedded or
  written chart. Defaults 7 by 4.5 at 150 dpi.

## Value

A list with `block_id`, `test`, `caption`, `apa`, `table` (a data
frame), `note`, `supplement` (a list with `table` and `caption`, or
`NULL`), `chart` (a `ggplot`, or `NULL` where the method has none or
ggplot2 is absent), `html` (the fragment, for `format = "html"`), and
`chart_file` (for `"png"` and `"svg"`). A result that failed carries its
`error`, and `html` shows it.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md),
[`sframe_save_figures()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_save_figures.md)

## Examples

``` r
# \donttest{
d <- sframe_demo("two_group")
res <- run_analysis_plan(d$responses, d$instrument)
out <- render_result(res[[1]], d$responses, d$instrument)
out$caption
#> [1] "RQ1: Do in-person and online attendees reach a different number of sessions?"
out$table
#>       Group  n Mean   SD
#> 1 In person 30 6.80 2.14
#> 2    Online 30 4.90 2.23
# }
```
