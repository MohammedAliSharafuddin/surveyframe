# Write responses to SPSS or Stata with the labels attached

Writes response data to an SPSS `.sav` or Stata `.dta` file, with
variable and value labels taken from the instrument. A plain CSV carries
codes: `dm_1` arrives in SPSS as a column of integers with empty
variable and value labels, and the reader has to reconstruct all of it
from the questionnaire. This attaches both from the instrument: the
variable label is the item's `label`, and the value labels come from the
item's choice set, which stores its `values` and `labels` side by side.

## Usage

``` r
export_responses(data, instrument, path)
```

## Arguments

- data:

  A response data frame, as returned by
  [`read_responses()`](https://surveyframe.org/reference/read_responses.md).

- instrument:

  The `sframe` the responses were collected with.

- path:

  Output file. An `.sav` is written for SPSS, a `.dta` for Stata, chosen
  from the extension.

## Value

The path, invisibly. When any name or label was changed, the path
carries an attribute `"renamed"`, a data frame with the columns `kind`
(`"name"`, `"variable label"` or `"value label"`), `column`, `old` and
`new`. An unchanged file returns silently with an empty attribute.

## Text codes in Stata

Stata attaches value labels to numbers alone. In a `.dta`, a choice set
coded with text, such as `"a"` and `"b"`, is written as 1, 2, 3 in the
set's declared order, each carrying its label, so the file reads back in
Stata with the labels intact. A `.sav` keeps the text codes, which SPSS
labels directly. Codes such as `"01"` and `"02"` are text, as
[`read_responses()`](https://surveyframe.org/reference/read_responses.md)
reads them, since as numbers they would lose their leading zero and
differ from the instrument.

## How names and labels are adapted for each format

SPSS and Stata use column names that start with a letter and stay within
their format limits of 64 bytes for SPSS and 32 characters for Stata.
Matrix row columns such as `session__Reading materials` are renamed to
valid names, with illegal characters turned into `_`, a leading `v`
where the first character is other than a letter, and a number added
where 2 names would otherwise match. Variable labels are cut at 256
bytes for SPSS and 80 characters for Stata, and value labels at 120
bytes for SPSS and 80 characters for Stata. Everything else keeps its
full label. One message lists each change as old -\> new.

## See also

[`sframe_demo()`](https://surveyframe.org/reference/sframe_demo.md),
[`read_responses()`](https://surveyframe.org/reference/read_responses.md)

Other Responses functions:
[`read_responses()`](https://surveyframe.org/reference/read_responses.md),
[`read_sheet_responses()`](https://surveyframe.org/reference/read_sheet_responses.md),
[`sframe_missing_data_results()`](https://surveyframe.org/reference/sframe_missing_data_results.md),
[`sframe_outlier_results()`](https://surveyframe.org/reference/sframe_outlier_results.md),
[`sframe_quality_results()`](https://surveyframe.org/reference/sframe_quality_results.md)

## Examples

``` r
# \donttest{
demo <- sframe_demo("two_group")
out <- file.path(tempdir(), "two_group.sav")
if (requireNamespace("haven", quietly = TRUE)) {
  export_responses(demo$responses, demo$instrument, out)
  sframe_show(out)
}
# }
```
