# Keyword-in-context concordance for open-ended text

Finds every case-insensitive, whole-word match of `term` in `text` and
returns the words immediately before and after each match, so a reader
can judge how a term is actually being used rather than reading a bare
frequency count. Matching is on whole words only, so searching for
"room" does not match "roomy". `text` is expected to already have been
run through
[`clean_text_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/clean_text_responses.md)
(its `respondent` attribute is used to cite the original row index for
each match; when absent, positions `seq_along(text)` are used instead).
Tokenisation here is a plain whitespace split, not the internal
stop-word-stripping tokeniser behind
[`term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/term_frequency.md):
stop words are part of a match's context and stripping them would
corrupt the very thing a concordance is for.

## Usage

``` r
term_context(text, term, window = 6L, max_matches = 20L)
```

## Arguments

- text:

  Character vector of responses, ideally already cleaned by
  [`clean_text_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/clean_text_responses.md).

- term:

  Character. A single keyword to search for.

- window:

  Integer. Maximum number of words of context to keep before and after
  each match. Default `6`.

- max_matches:

  Integer. Maximum number of matches to return, counted across all
  responses. Default `20`.

## Value

A data.frame with columns `respondent`, `before`, `match`, and `after`.
