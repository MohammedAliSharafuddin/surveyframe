# Generate lavaan CFA syntax from an instrument object

Produces a character string of `lavaan` model syntax derived from the
scale structure in the instrument. The syntax can be passed directly to
`lavaan::cfa()`. Reverse-coded items are noted in a comment but are not
transformed in the syntax; recoding should be applied to the data before
fitting the model.

## Usage

``` r
cfa_syntax(instrument, scales = NULL, std_lv = TRUE)
```

## Arguments

- instrument:

  An `sframe` object.

- scales:

  Character vector or NULL. A subset of scale IDs to include. When NULL,
  all scales are included.

- std_lv:

  Logical. Whether to include the `std.lv = TRUE` argument note in the
  output comment header. Defaults to `TRUE`.

## Value

A character string of `lavaan` CFA model syntax.

## See also

[`efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_report.md),
[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)

## Examples

``` r
if (FALSE) { # \dontrun{
syntax <- cfa_syntax(instr)
cat(syntax)
fit <- lavaan::cfa(syntax, data = scored_data, std.lv = TRUE)
} # }
```
