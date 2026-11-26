# Keyword-in-context concordance for open-ended text

Finds every case-insensitive, whole-word match of `term` in `text` and
returns the words immediately before and after each match, so a reader
can judge how a term is used in context. Matching is on whole words
only, so searching for "room" does not match "roomy". `text` is expected
to already have been run through
[`sframe_clean_text()`](https://surveyframe.org/reference/sframe_clean_text.md)
(its `respondent` attribute is used to cite the original row index for
each match, and when absent, positions `seq_along(text)` are used
instead). Tokenisation here is a plain whitespace split that keeps stop
words, because they are part of a match's context.

## Usage

``` r
sframe_term_context(text, term, window = 6L, max_matches = 20L)
```

## Arguments

- text:

  Character vector of responses, ideally already cleaned by
  [`sframe_clean_text()`](https://surveyframe.org/reference/sframe_clean_text.md).

- term:

  Character. A single keyword to search for.

- window:

  Integer. Maximum number of words of context to keep before and after
  each match. Defaults to 6.

- max_matches:

  Integer. Maximum number of matches to return, counted across all
  responses. Defaults to 20.

## Value

A data.frame with columns `respondent`, `before`, `match` and `after`.

## See also

Other Text analysis functions:
[`sframe_clean_text()`](https://surveyframe.org/reference/sframe_clean_text.md),
[`sframe_extract_quotes()`](https://surveyframe.org/reference/sframe_extract_quotes.md),
[`sframe_ngram_frequency()`](https://surveyframe.org/reference/sframe_ngram_frequency.md),
[`sframe_term_frequency()`](https://surveyframe.org/reference/sframe_term_frequency.md)

## Examples

``` r
demo <- sframe_demo("open_text")
cleaned <- sframe_clean_text(demo$responses, "what_worked")
sframe_term_context(cleaned, "speakers", window = 4)
```
