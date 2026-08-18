# Extract representative quotes for each STM topic

Takes the result of
[`sframe_run_stm_topics()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_run_stm_topics.md)
(not a raw `stm` model object) and, for each topic, pulls the top
`n_quotes` documents by topic-document probability using
[`stm::findThoughts()`](https://rdrr.io/pkg/stm/man/findThoughts.html),
then maps each one back to its original respondent row via the mapping
[`sframe_run_stm_topics()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_run_stm_topics.md)
stored on `result$fit`.

## Usage

``` r
extract_quotes(model, text, n_quotes = 3L)
```

## Arguments

- model:

  A `stm_topics` result list from
  [`sframe_run_stm_topics()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_run_stm_topics.md)
  (i.e. `result`, not `result$fit` and not the raw `stm` object).

- text:

  The response vector the topic model was fit on: either the raw vector
  (one entry per original data row, indexed 1:1 by row number) or the
  [`clean_text_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/clean_text_responses.md)-cleaned
  vector, which drops blank/missing rows and is therefore *shorter*, its
  positions no longer equal original row numbers once any earlier row
  was dropped. Both forms work correctly: when `text` carries the
  `respondent` attribute
  [`clean_text_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/clean_text_responses.md)
  sets, that mapping is used to find each quote's real position;
  otherwise `text` is assumed to be the raw, 1:1-indexed vector.

- n_quotes:

  Integer. Quotes to return per topic. Default `3L`.

## Value

A data.frame with columns `topic`, `rank`, `respondent` (the original
row index in the data the model's `text` argument came from, not a
document-matrix or corpus row index), and `quote`.
