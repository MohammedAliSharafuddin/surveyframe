# N-gram frequency for open-ended text

Tokenises `text` via the same tokeniser as
[`term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/term_frequency.md)
(whitespace splitting, lower-casing, punctuation stripping, and
stop-word removal), then slides a window of `n` tokens across each
response's token vector and counts how often each resulting n-gram
occurs. `n = 2` (the default) gives bigrams; `n = 3` gives trigrams.
Because stop words are already removed by the shared tokeniser, an
n-gram never straddles a dropped word; it is built only from tokens that
survive filtering, in their original order within each response.

## Usage

``` r
ngram_frequency(text, n = 2L, stop_words = NULL, top_n = 30L)
```

## Arguments

- text:

  Character vector of responses (raw or already cleaned by
  [`clean_text_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/clean_text_responses.md)).

- n:

  Integer. N-gram size. Default `2` (bigrams).

- stop_words:

  Character vector of words to exclude, or `NULL` to use the built-in
  English list, or `character(0)` for no filtering.

- top_n:

  Integer. Maximum number of n-grams to return, most frequent first.
  Default `30`.

## Value

A data.frame with columns `term` (the space-joined n-gram), `n`, and
`pct`.
