# Add references to an instrument

Attaches
[`sframe_reference()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reference.md)
records to an instrument. A reference whose id is already present
replaces the old one when `replace = TRUE`, and is refused otherwise,
which keeps a second source from silently taking over a citation key.
`cited_by` targets of a replaced reference are merged.

## Usage

``` r
sframe_add_references(instrument, ..., replace = FALSE)
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

## See also

Other References functions:
[`read_bibtex()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_bibtex.md),
[`sframe_bibliography()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_bibliography.md),
[`sframe_get_references()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_get_references.md),
[`sframe_reference()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reference.md)

## Examples

``` r
instr <- sframe_instrument("Demo", components = list(
  sframe_item("q1", "How satisfied are you?", "likert", choice_set = "agree5"),
  sframe_choice_set("agree5", 1:5, c("SD", "D", "N", "A", "SA"))
))
instr <- sframe_add_references(instr, sframe_reference(
  "likert_1932", "A technique for the measurement of attitudes",
  author = "Likert, R.", year = 1932, container = "Archives of Psychology",
  volume = "22", issue = "140", pages = "1-55", cited_by = "item:q1"
))
length(sframe_get_references(instr))
#> [1] 1
```
