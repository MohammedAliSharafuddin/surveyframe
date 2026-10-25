# Add references to an instrument

Attaches
[`sf_reference()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_reference.md)
records to an instrument. A reference whose id is already present
replaces the old one when `replace = TRUE`, and is refused otherwise,
which keeps a second source from silently taking over a citation key.
`cited_by` targets of a replaced reference are merged.

## Usage

``` r
add_references(instrument, ..., replace = FALSE)
```

## Arguments

- instrument:

  An `sframe` object.

- ...:

  `sf_reference` objects, or lists of them such as
  [`read_bibtex()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_bibtex.md)
  returns.

- replace:

  Logical. Replace a reference with the same id.

## Value

The instrument, with the references added.

## Details

Adding references changes the file hash, as any edit does, and leaves
the content hash that
[`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md)
records unchanged: citing a source is disclosure, outside the design.

## Examples

``` r
instr <- sf_instrument("Demo", components = list(
  sf_item("q1", "How satisfied are you?", "likert", choice_set = "agree5"),
  sf_choices("agree5", 1:5, c("SD", "D", "N", "A", "SA"))
))
instr <- add_references(instr, sf_reference(
  "likert_1932", "A technique for the measurement of attitudes",
  author = "Likert, R.", year = 1932, container = "Archives of Psychology",
  volume = "22", issue = "140", pages = "1-55", cited_by = "item:q1"
))
length(sframe_references(instr))
#> [1] 1
```
