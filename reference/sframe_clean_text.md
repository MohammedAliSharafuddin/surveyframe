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
[`sframe_extract_quotes()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_extract_quotes.md),
[`sframe_ngram_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_ngram_frequency.md),
[`sframe_term_context()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_term_context.md),
[`sframe_term_frequency()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_term_frequency.md)

## Examples

``` r
demo <- sframe_demo("tourism_services")
cleaned <- sframe_clean_text(demo$responses, "comments")
head(cleaned)
#> [1] "useful service information"            
#> [2] "useful service information"            
#> [3] "would like more sustainability details"
#> [4] "useful service information"            
#> [5] "would like more sustainability details"
#> [6] "clear online content"                  
attr(cleaned, "respondent")[1:5]
#> [1] 2 3 5 7 8
```
