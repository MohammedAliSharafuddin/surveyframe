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

- Invalid item IDs

- Duplicate choice-set IDs

- Duplicate scale IDs

- Items with missing labels

- Items referencing a missing `choice_set` in the instrument

- Items referencing a missing `scale_id` in the instrument

- Items marked `reverse = TRUE` without a `scale_id`

- Choice sets referenced by items but not present in the instrument

- Scale `items` vectors containing IDs not present in the instrument

- Branching rules referencing item IDs not present in the instrument

- Attention checks referencing item IDs not present in the instrument

- Analysis plan roles referencing missing variables or models

- Model specifications referencing missing indicators or constructs

## See also

[`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)

## Examples

``` r
# Build a minimal valid instrument and validate it
cs    <- sf_choices("ag5", 1:5,
           c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree"))
item  <- sf_item("sat_1", "The service met my expectations.",
                 type = "likert", choice_set = "ag5", scale_id = "sat")
scale <- sf_scale("sat", "Satisfaction", items = "sat_1")
instr <- sf_instrument("Demo Survey", components = list(cs, item, scale))

# Non-strict: returns a list without stopping
result <- validate_sframe(instr, strict = FALSE)
result$valid
#> [1] TRUE
result$problems
#> character(0)

# Strict: returns instrument invisibly when valid
validated <- validate_sframe(instr, strict = TRUE)
isTRUE(validated$meta$validated)
#> [1] TRUE
```
