# Read an instrument's amendment log

Returns the disclosed-amendment history recorded by
[`amend_sframe()`](https://surveyframe.org/reference/amend_sframe.md) as
a data frame, one row per amendment in the order they were recorded.

## Usage

``` r
sframe_get_amendments(instrument)
```

## Arguments

- instrument:

  An `sframe` object.

## Value

A data frame with columns `timestamp`, `reason_code`, `reason_text`,
`tier`, `author`, `deviation_report`, `signoff`, `previous_hash`,
`new_hash`, and `changed_fields` (a comma-joined string). Zero rows if
the instrument has no recorded amendments. Export with
[`write.csv()`](https://rdrr.io/r/utils/write.table.html) for an
external audit trail.

## See also

[`amend_sframe()`](https://surveyframe.org/reference/amend_sframe.md)

Other Amendments functions:
[`amend_sframe()`](https://surveyframe.org/reference/amend_sframe.md),
[`sframe_drop_items()`](https://surveyframe.org/reference/sframe_drop_items.md),
[`sframe_item_flags()`](https://surveyframe.org/reference/sframe_item_flags.md),
[`sframe_link_git_commit()`](https://surveyframe.org/reference/sframe_link_git_commit.md)

## Examples

``` r
item  <- sframe_item("q1", "How satisfied are you?", type = "text")
instr <- sframe_instrument("Demo", components = list(item))
sframe_get_amendments(instr)
```
