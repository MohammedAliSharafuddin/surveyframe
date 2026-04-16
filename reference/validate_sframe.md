# Validate an instrument object

Checks the internal consistency of an `sframe` instrument object and
reports all detected problems. Validation is performed automatically by
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
and optionally by
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md).
It can also be run independently at any point during instrument
construction.

## Usage

``` r
validate_sframe(instrument, strict = TRUE)
```

## Arguments

- instrument:

  An `sframe` object created by
  [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md).

- strict:

  Logical. When `TRUE` (default), any detected problem raises an error
  of class `sframe_validation_error`. When `FALSE`, problems are
  returned as a character vector of messages without stopping.

## Value

When `strict = TRUE` and the instrument is valid, the instrument is
returned invisibly with `meta$validated` set to `TRUE`. When
`strict = FALSE`, a named list with elements `valid` (logical) and
`problems` (character vector) is returned.

## Details

The following checks are performed:

- Duplicate item IDs

- Items with missing labels

- Items referencing a `choice_set` that is not defined in the instrument

- Items referencing a `scale_id` that is not defined in the instrument

- Items marked `reverse = TRUE` without a `scale_id`

- Choice sets referenced by items but not present in the instrument

- Scale `items` vectors containing IDs not present in the instrument

- Branching rules referencing item IDs not present in the instrument

- Attention checks referencing item IDs not present in the instrument

## See also

[`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)

## Examples

``` r
if (FALSE) { # \dontrun{
instr <- sf_instrument("My Survey", components = list(...))
validate_sframe(instr)
} # }
```
