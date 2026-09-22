# N-gram frequency for open-ended text

Tokenises `text` via the same tokeniser as
[`term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/term_frequency.md)
(whitespace splitting, lower-casing, punctuation stripping, and
stop-word removal), then slides a window of `n` tokens across each
response's token vector and counts how often each resulting n-gram
occurs. `n = 2` (the default) gives bigrams, and `n = 3` gives trigrams.

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

## Details

An n-gram never straddles a removed stop word. Where "but" and "not" are
filtered, "clean but not comfortable" yields no bigram at all, because
"clean" and "comfortable" were never next to each other. This is what
makes the output phrases respondents actually wrote.

## Examples

``` r
demo <- sframe_demo_data()
cleaned <- clean_text_responses(demo$responses, "comments")
head(ngram_frequency(cleaned, n = 2, top_n = 10))
#>                     term  n  pct
#> 1 sustainability details 35 24.1
#> 2           clear online 31 21.4
#> 3         online content 31 21.4
#> 4    service information 24 16.6
#> 5         useful service 24 16.6
```
