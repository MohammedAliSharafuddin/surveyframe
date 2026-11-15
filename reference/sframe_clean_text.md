# Clean open-ended text responses for analysis

Extracts one text/textarea item's responses from a response data frame
and applies light, configurable cleaning: lower-casing, punctuation
removal, and optional number stripping. Blank and missing responses are
dropped rather than kept as empty strings, since they carry no
term-frequency signal and would otherwise inflate downstream response
counts.

## Usage

``` r
sframe_clean_text(
  data,
  item_id,
  lowercase = TRUE,
  remove_punct = TRUE,
  strip_numbers = FALSE,
  instrument = NULL
)
```

## Arguments

- data:

  A data.frame of responses.

- item_id:

  Character. The text/textarea item's column name.

- lowercase:

  Logical. Lower-case the text. Default `TRUE`.

- remove_punct:

  Logical. Strip punctuation. Default `TRUE`.

- strip_numbers:

  Logical. Strip digits. Default `FALSE`.

- instrument:

  Optional `sframe` instrument. When supplied, `item_id` is validated as
  a `"text"` or `"textarea"` item before cleaning.

## Value

A character vector of cleaned responses, with an integer `"respondent"`
attribute giving each entry's original row index in `data`, so quotes
extracted later can cite a respondent.

## See also

Other Text analysis functions:
[`sframe_extract_quotes()`](https://surveyframe.org/reference/sframe_extract_quotes.md),
[`sframe_ngram_frequency()`](https://surveyframe.org/reference/sframe_ngram_frequency.md),
[`sframe_term_context()`](https://surveyframe.org/reference/sframe_term_context.md),
[`sframe_term_frequency()`](https://surveyframe.org/reference/sframe_term_frequency.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
cleaned <- sframe_clean_text(demo$responses, "comments")
head(cleaned)
attr(cleaned, "respondent")[1:5]
```
