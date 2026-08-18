# N-gram-frequency plot: horizontal bar

Top 20 n-grams from an `ngram_freq` result as a horizontal bar chart.
Shares its bar-building logic with
[`sframe_plot_term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_term_frequency.md)'s
bar path via the internal `.sframe_plot_term_bar()` helper; unlike that
function, there is no word-cloud mode and no group faceting for this id.

## Usage

``` r
sframe_plot_ngram_frequency(result, palette = c("web", "print"))
```

## Arguments

- result:

  An `ngram_freq` result list from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md).

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` when the result carries no table.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`ngram_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/ngram_frequency.md)
