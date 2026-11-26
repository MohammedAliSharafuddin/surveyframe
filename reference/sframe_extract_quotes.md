# Extract representative quotes for each STM topic

Takes an `stm_topics` result from
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md)
(not a raw `stm` model object) and, for each topic, pulls the top
`n_quotes` documents by topic-document probability using
[`stm::findThoughts()`](https://rdrr.io/pkg/stm/man/findThoughts.html).
Each quote is mapped back to its original respondent row through the
mapping the result stores on `result$fit`.

## Usage

``` r
sframe_extract_quotes(model, text, n_quotes = 3L)
```

## Arguments

- model:

  An `stm_topics` result from
  [`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md),
  the whole result list, which holds the fitted model in `result$fit`.

- text:

  The response vector the topic model was fitted on: either the raw
  vector, 1 entry per original data row, or the vector
  [`sframe_clean_text()`](https://surveyframe.org/reference/sframe_clean_text.md)
  returns. The cleaned vector drops blank and missing rows, so it can be
  shorter than the data. Both forms work: when `text` carries the
  `respondent` attribute that
  [`sframe_clean_text()`](https://surveyframe.org/reference/sframe_clean_text.md)
  sets, that mapping finds each quote's row, and otherwise `text` is
  taken to be the raw vector.

- n_quotes:

  Integer. Quotes to return per topic. Defaults to 3.

## Value

A data.frame with columns `topic`, `rank`, `respondent` (the original
row index in the data the model's `text` argument came from, not a
document-matrix or corpus row index) and `quote`.

## See also

Other Text analysis functions:
[`sframe_clean_text()`](https://surveyframe.org/reference/sframe_clean_text.md),
[`sframe_ngram_frequency()`](https://surveyframe.org/reference/sframe_ngram_frequency.md),
[`sframe_term_context()`](https://surveyframe.org/reference/sframe_term_context.md),
[`sframe_term_frequency()`](https://surveyframe.org/reference/sframe_term_frequency.md)

## Examples

``` r
# \donttest{
if (requireNamespace("stm", quietly = TRUE) &&
    requireNamespace("tidytext", quietly = TRUE)) {
  demo <- sframe_demo("open_text")
  sframe_plan(demo$instrument) <- list(list(
    id = "RQ1", research_question = "What themes appear in what worked?",
    family = "text_analysis", method = "stm_topics",
    roles = list(item = "what_worked"), options = list(k = 3, seed = 42)
  ))
  res <- run_analysis_plan(demo$responses, demo$instrument)
  quotes <- sframe_extract_quotes(res$RQ1, demo$responses$what_worked, n_quotes = 2)
  quotes
}
# }
```
