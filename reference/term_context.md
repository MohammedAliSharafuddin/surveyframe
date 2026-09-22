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

## Examples

``` r
demo <- sframe_demo_data()
cleaned <- clean_text_responses(demo$responses, "comments")
term_context(cleaned, "service", window = 4)
#>    respondent before   match       after
#> 1           2 useful service information
#> 2           3 useful service information
#> 3           7 useful service information
#> 4          15 useful service information
#> 5          20 useful service information
#> 6          36 useful service information
#> 7          38 useful service information
#> 8          42 useful service information
#> 9          45 useful service information
#> 10         50 useful service information
#> 11         59 useful service information
#> 12         65 useful service information
#> 13         75 useful service information
#> 14         78 useful service information
#> 15         84 useful service information
#> 16         85 useful service information
#> 17         90 useful service information
#> 18         93 useful service information
#> 19         95 useful service information
#> 20        101 useful service information
```
