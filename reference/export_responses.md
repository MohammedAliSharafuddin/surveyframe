# Write responses to SPSS or Stata with the labels attached

A plain CSV carries codes. `dm_1` arrives in SPSS as a column of
integers with no variable label and no value labels, and the reader has
to reconstruct all of it from the questionnaire. This attaches both from
the instrument: the variable label is the item's `label`, and the value
labels come from the item's choice set, which stores its `values` and
`labels` side by side.

## Usage

``` r
export_responses(data, instrument, path)
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

The path, invisibly. When any name or label was changed, the path
carries an attribute `"renamed"`, a data frame with the columns `kind`
(`"name"`, `"variable label"` or `"value label"`), `column`, `old` and
`new`. With no changes there is no message and no attribute.

## Text codes in Stata

Stata attaches value labels to numbers alone. In a `.dta`, a choice set
coded with text, such as `"a"` and `"b"`, is written as 1, 2, 3 in the
set's declared order, each carrying its label, so the file reads back in
Stata with the labels intact. A `.sav` keeps the text codes, which SPSS
labels directly. Codes such as `"01"` and `"02"` are text, as
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
reads them, since as numbers they would lose their leading zero and no
longer match the instrument.

## Names and labels that do not fit the format

SPSS and Stata refuse column names with spaces or punctuation, names
that do not start with a letter, and names over the format's length
limit (64 bytes for SPSS, 32 characters for Stata). Matrix row columns
such as `session__Opening keynote` are renamed to valid names, with
illegal characters turned into `_`, a leading `v` where the first
character is not a letter, and a number added where two names would
otherwise match. Variable labels are cut at 256 bytes for SPSS and 80
characters for Stata, and value labels at 120 bytes for SPSS and 80
characters for Stata. Everything else keeps its full label. One message
lists each change as old -\> new.

## See also

[`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md),
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)

Other Responses functions:
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md),
[`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md),
[`sframe_missing_data_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_missing_data_results.md),
[`sframe_outlier_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_outlier_results.md),
[`sframe_quality_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_quality_results.md)

## Examples

``` r
# \donttest{
demo <- sframe_demo("two_group")
out <- file.path(tempdir(), "two_group.sav")
if (requireNamespace("haven", quietly = TRUE)) {
  export_responses(demo$responses, demo$instrument, out)
}
# }
```
