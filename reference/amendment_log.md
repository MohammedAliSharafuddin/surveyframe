# Read an instrument's amendment log

Returns the disclosed-amendment history recorded by
[`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md)
as a data frame, one row per amendment in the order they were recorded.

## Usage

``` r
amendment_log(instrument)
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

[`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md)

## Examples

``` r
item  <- sf_item("q1", "How satisfied are you?", type = "text")
instr <- sf_instrument("Demo", components = list(item))
amendment_log(instr)
#>  [1] timestamp        reason_code      reason_text      tier            
#>  [5] author           deviation_report signoff          previous_hash   
#>  [9] new_hash         changed_fields  
#> <0 rows> (or 0-length row.names)
```
