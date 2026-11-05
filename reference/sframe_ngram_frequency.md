# N-gram frequency for open-ended text

Tokenises `text` via the same tokeniser as
[`sframe_term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_term_frequency.md)
(whitespace splitting, lower-casing, punctuation stripping, and
stop-word removal), then slides a window of `n` tokens across each
response's token vector and counts how often each resulting n-gram
occurs. `n = 2` (the default) gives bigrams, and `n = 3` gives trigrams.

## Usage

``` r
sframe_ngram_frequency(text, n = 2L, stop_words = NULL, top_n = 30L)
```

## Arguments

- text:

  Character vector of responses (raw or already cleaned by
  [`sframe_clean_text()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_clean_text.md)).

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

## See also

Other Text analysis functions:
[`sframe_clean_text()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_clean_text.md),
[`sframe_extract_quotes()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_extract_quotes.md),
[`sframe_term_context()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_term_context.md),
[`sframe_term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_term_frequency.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
cleaned <- sframe_clean_text(demo$responses, "comments")
head(sframe_ngram_frequency(cleaned, n = 2, top_n = 10))
#>                     term  n  pct
#> 1 sustainability details 35 24.1
#> 2           clear online 31 21.4
#> 3         online content 31 21.4
#> 4    service information 24 16.6
#> 5         useful service 24 16.6
```
