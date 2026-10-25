# Write responses to SPSS or Stata with the labels attached

A plain CSV carries codes. `dm_1` arrives in SPSS as a column of
integers with no variable label and no value labels, and the reader has
to reconstruct all of it from the questionnaire. This attaches both from
the instrument: the variable label is the item's `label`, and the value
labels come from the item's choice set, which stores its `values` and
`labels` side by side.

## Usage

``` r
sframe_export_labelled(data, instrument, path)
```

## Arguments

- data:

  A response data frame, as returned by
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md).

- instrument:

  The `sframe` the responses were collected with.

- path:

  Output file. An `.sav` is written for SPSS, a `.dta` for Stata, chosen
  from the extension.

## Value

The path, invisibly.

## Text codes in Stata

Stata attaches value labels to numbers alone. In a `.dta`, a choice set
coded with text, such as `"a"` and `"b"`, is written as 1, 2, 3 in the
set's declared order, each carrying its label, so the file reads back in
Stata with the labels intact. A `.sav` keeps the text codes, which SPSS
labels directly.

## See also

[`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)

## Examples

``` r
# \donttest{
demo <- sframe_demo("two_group")
out <- file.path(tempdir(), "two_group.sav")
if (requireNamespace("haven", quietly = TRUE)) {
  sframe_export_labelled(demo$responses, demo$instrument, out)
}
# }
```
