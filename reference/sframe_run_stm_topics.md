# Fit a structural topic model (STM) on open-ended text

Cleans the text item via
[`clean_text_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/clean_text_responses.md),
tokenises with
[`tidytext::unnest_tokens()`](https://juliasilge.github.io/tidytext/reference/unnest_tokens.html)
(tidyeval column names via
[`rlang::sym()`](https://rlang.r-lib.org/reference/sym.html) and `!!`,
not bare symbols; see the source comment at the tokenising step for
why), casts to a document-term matrix, converts it to `stm`'s corpus
format with `stm::readCorpus(type = "slam")` and
[`stm::prepDocuments()`](https://rdrr.io/pkg/stm/man/prepDocuments.html),
and fits [`stm::stm()`](https://rdrr.io/pkg/stm/man/stm.html) after a
fixed [`set.seed()`](https://rdrr.io/r/base/Random.html) (stm's own fit
is not otherwise seed-stable).

## Usage

``` r
sframe_run_stm_topics(data, roles, options, instrument)
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

A runner-contract result list: `test = "stm_topics"`, `table`
(topic/proportion/term/beta/rank; proportion is the topic's mean
document weight, beta its per-term probability, both from the fitted
`stm` object), `fit` (a runtime-only list holding the `stm` model object
and the document-to-respondent mapping needed by
[`extract_quotes()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/extract_quotes.md)),
`apa`, `prompt`. On failure:
`list(test = "stm_topics", error = <message>)`.
