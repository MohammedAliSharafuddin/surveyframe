# Term frequency for open-ended text

Tokenises `text` (splitting on whitespace, lower-casing, and stripping
punctuation), removes stop words, and counts term frequency. Ships a
small built-in English stop-word list so this works with zero optional
packages. Pass `stop_words = character(0)` to disable filtering, or a
custom vector to override it.

## Usage

``` r
sframe_term_frequency(text, stop_words = NULL, top_n = 30L)
```

## Arguments

- text:

  Character vector of responses (raw or already cleaned by
  [`sframe_clean_text()`](https://surveyframe.org/reference/sframe_clean_text.md)).

- stop_words:

  Character vector of words to exclude, or `NULL` to use the built-in
  English list, or `character(0)` for no filtering.

- top_n:

  Integer. Maximum number of terms to return, most frequent first.
  Default `30`.

## Value

A data.frame with columns `term`, `n`, and `pct`.

## See also

Other Text analysis functions:
[`sframe_clean_text()`](https://surveyframe.org/reference/sframe_clean_text.md),
[`sframe_extract_quotes()`](https://surveyframe.org/reference/sframe_extract_quotes.md),
[`sframe_ngram_frequency()`](https://surveyframe.org/reference/sframe_ngram_frequency.md),
[`sframe_term_context()`](https://surveyframe.org/reference/sframe_term_context.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
cleaned <- sframe_clean_text(demo$responses, "comments")
head(sframe_term_frequency(cleaned, top_n = 10))
```
