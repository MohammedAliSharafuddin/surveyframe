# Term frequency for open-ended text

Tokenises `text` (splitting on whitespace, lower-casing, and stripping
punctuation), removes stop words, and counts term frequency. Ships a
small built-in English stop-word list so this works with zero optional
packages; pass `stop_words = character(0)` to disable filtering, or a
custom vector to override it.

## Usage

``` r
term_frequency(text, stop_words = NULL, top_n = 30L)
```

## Arguments

- text:

  Character vector of responses (raw or already cleaned by
  [`clean_text_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/clean_text_responses.md)).

- stop_words:

  Character vector of words to exclude, or `NULL` to use the built-in
  English list, or `character(0)` for no filtering.

- top_n:

  Integer. Maximum number of terms to return, most frequent first.
  Default `30`.

## Value

A data.frame with columns `term`, `n`, and `pct`.
