# Topic-model top-terms plot: faceted bars, one facet per topic

Serves both
[`sframe_run_topic_model_lda()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_run_topic_model_lda.md)
and
[`sframe_run_stm_topics()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_run_stm_topics.md)
results with no dispatch on `result$test`: both runners emit a `$table`
with the same `topic`/`term`/`beta` columns (LDA's beta from
[`tidytext::tidy()`](https://generics.r-lib.org/reference/tidy.html),
STM's from its fitted word-topic distribution), so this function reads
that shared shape directly.

## Usage

``` r
sframe_plot_topics(result, palette = c("web", "print"))
```

## Arguments

- result:

  A `topic_model_lda` or `stm_topics` result list from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md).

- palette:

  One of `"web"` or `"print"`. See `sframe_brand()`.

## Value

A ggplot2 object, or `NULL` when the result carries no usable table.

## See also

[`sframe_run_topic_model_lda()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_run_topic_model_lda.md),
[`sframe_run_stm_topics()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_run_stm_topics.md)
