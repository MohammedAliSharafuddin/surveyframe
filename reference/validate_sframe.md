# Validate an instrument object

Checks the internal consistency of an `sframe` instrument object and
returns a diagnostic result. Validation is performed automatically by
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
  reported in the returned diagnostic without stopping.

## Value

An
[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
object. When the instrument is valid, the instrument carried inside it
has `meta$validated` set to `TRUE` and can be recovered with
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md).

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

- `%in%` branching rules whose `value` no evaluator can consume

- Attention checks referencing item IDs not present in the instrument

- Analysis plan roles referencing missing variables or models

- Model specifications referencing missing indicators or constructs

## Changed in 0.4.0

Earlier versions returned two different things depending on `strict`:
the instrument itself, invisibly, when `strict = TRUE`, and a bare
unclassed list when `strict = FALSE`. A validator should report a
diagnostic, so both paths now return an
[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md)
object, and they return it visibly, so `validate_sframe(instrument)`
typed at the console shows the result. Code that read `$valid` and
`$problems` keeps working. Code that used the `strict = TRUE` return as
an instrument should now wrap the call in
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md).

## See also

[sframe_validation](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validation.md),
[`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md),
[`sf_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md),
[`sf_is_valid()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md),
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

# The result prints its own diagnostic
validate_sframe(instr, strict = FALSE)
#> <sframe validation>
#>   Instrument:  Demo Survey (0.1.0)
#>   Status:      valid
#>   Checks:      19 run, 0 with problems

# Explore it with dedicated methods rather than reaching in with `$`
v <- validate_sframe(instr, strict = FALSE)
sf_is_valid(v)
#> [1] TRUE
sf_problems(v)
#> character(0)
summary(v)
#>                           check status n_problems
#> 1            duplicate_item_ids     ok          0
#> 2                item_id_format     ok          0
#> 3          duplicate_choice_ids     ok          0
#> 4           duplicate_scale_ids     ok          0
#> 5                   item_labels     ok          0
#> 6          item_choice_set_refs     ok          0
#> 7               item_scale_refs     ok          0
#> 8         reverse_without_scale     ok          0
#> 9           decision_item_shape     ok          0
#> 10             comparison_scale     ok          0
#> 11             scale_membership     ok          0
#> 12               branching_refs     ok          0
#> 13             branching_values     ok          0
#> 14                   check_refs     ok          0
#> 15         analysis_plan_models     ok          0
#> 16      analysis_plan_variables     ok          0
#> 17 decision_scale_compatibility     ok          0
#> 18                    model_ids     ok          0
#> 19                  model_specs     ok          0

# Recover the validated instrument
validated <- as_sframe(validate_sframe(instr, strict = TRUE))
isTRUE(sf_meta(validated)$validated)
#> [1] TRUE
```
