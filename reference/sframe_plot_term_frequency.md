# Term-frequency plot: horizontal bar or word cloud

Top terms from a `term_freq` result as a horizontal bar chart, or a word
cloud when `result$options$wordcloud` is `TRUE` (opt-in, default
`FALSE`). Facets by group when the result carries a `group` role
(todo_text_analysis.md section 1a).

## Usage

``` r
sframe_plot_term_frequency(result, palette = c("web", "print"))
```

## Arguments

- result:

  A `term_freq` result list from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md).

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` when the result carries no table.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/term_frequency.md)

## Examples

``` r
# \donttest{
if (requireNamespace("ggplot2", quietly = TRUE)) {
  demo <- sframe_demo("open_text")
  res <- run_analysis_plan(demo$responses, demo$instrument)
  sframe_plot_term_frequency(res$RQ1)
}
#> Warning: K=2 is equivalent to a unidimensional scaling model which you may prefer.

# }
```
