# Fit an LDA topic model on open-ended text

Cleans the text item via
[`clean_text_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/clean_text_responses.md),
tokenises with the package's shared internal tokeniser (reused rather
than a second tidytext-based tokeniser, so LDA and
[`term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/term_frequency.md)
can never drift on cleaning/stop-word rules), casts the token counts to
a document-term matrix with
[`tidytext::cast_dtm()`](https://juliasilge.github.io/tidytext/reference/document_term_casters.html),
and fits
[`topicmodels::LDA()`](https://rdrr.io/pkg/topicmodels/man/lda.html).

## Usage

``` r
sframe_run_topic_model_lda(data, roles, options, instrument)
```

## Arguments

- data:

  A data.frame of responses.

- roles:

  A list with `item`, the text/textarea item id.

- options:

  A list; `k` (topic count, default `4L` – a demonstration value, not a
  recommendation; see
  [`vignette("text-analysis")`](https://mohammedalisharafuddin.github.io/surveyframe/articles/text-analysis.md)'s
  topic- modelling section for
  [`topicmodels::perplexity()`](https://rdrr.io/pkg/topicmodels/man/perplexity.html)-based
  selection), `seed` (default `42L`), `stop_words` (passed through to
  the tokeniser).

- instrument:

  Optional `sframe` instrument, passed to
  [`clean_text_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/clean_text_responses.md)
  for item-type validation.

## Value

A runner-contract result list: `test = "topic_model_lda"`, `table`
(topic/term/beta/rank, top 10 terms per topic), `fit` (a runtime-only
list holding the LDA model object and the document-row-to- respondent
mapping needed by
[`extract_quotes()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/extract_quotes.md)),
`apa`, `prompt`. On failure:
`list(test = "topic_model_lda", error = <message>)`.
