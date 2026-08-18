# Sentiment plot: diverging bar, or a positive/negative comparison cloud

A ggplot2 diverging bar for a `tidy_sentiment` result by default:
positive counts extend one direction, negative counts the other, so bar
position (not colour alone) carries the primary polarity signal, the
same convention
[`sframe_draw_likert_diverging()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_draw_likert_diverging.md)
uses for Likert agreement (dark ramp toward the pole) rebuilt here in
ggplot2 rather than called directly, since that helper is base-graphics
and Likert-scale-specific. Facets by group when `result$table` carries a
`group` column, mirroring
[`sframe_plot_term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_term_frequency.md)'s
grouped branch.

## Usage

``` r
sframe_plot_sentiment(result, palette = c("web", "print"))
```

## Arguments

- result:

  A `tidy_sentiment` result list from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md).

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` when the result carries no table.

## Details

When `result$options$wordcloud` is `TRUE` (opt-in, default `FALSE`,
matching
[`sframe_plot_term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_term_frequency.md)'s
own word-cloud toggle), draws a comparison cloud instead:
negative-sentiment words above the centre line, positive-sentiment words
below it, each word sized by how often it occurred, using the internal
`tidy_sentiment` runner's `$word_sentiment` word-by-sentiment counts.
Answers a different question from the diverging bar: not "how many
responses leaned positive," but "which *words* drove that."

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`sframe_draw_likert_diverging()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_draw_likert_diverging.md)
