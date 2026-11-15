# Validate an instrument object

Checks the internal consistency of an `sframe` instrument object and
returns a diagnostic result. Validation is performed automatically by
[`write_sframe()`](https://surveyframe.org/reference/write_sframe.md)
and optionally by
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md). It
can also be run independently at any point during instrument
construction.

## Usage

``` r
validate_sframe(instrument, strict = TRUE)
```

## Arguments

- instrument:

  An `sframe` object created by
  [`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md).

- strict:

  Logical. When `TRUE` (default), any detected problem raises an error
  of class `sframe_validation_error`. When `FALSE`, problems are
  reported in the returned diagnostic without stopping.

## Value

An
[sframe_validation](https://surveyframe.org/reference/sframe_validation.md)
object. When the instrument is valid, the instrument carried inside it
has `meta$validated` set to `TRUE` and can be recovered with
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md).

## Details

The following checks are performed:

- Duplicate item IDs

- Invalid item IDs

- Duplicate choice-set IDs

- Duplicate scale IDs

- Item IDs, scale IDs and response columns that share a name, or take a
  reserved metadata name such as `submitted_at`. A scale's score is
  stored in a column named by its ID, so a shared name would overwrite
  data

- Items with missing labels

- Items referencing a missing `choice_set` in the instrument

- Items referencing a missing `scale_id` in the instrument

- Items marked `reverse = TRUE` without a `scale_id`

- Choice sets referenced by items but not present in the instrument

- Scale `items` vectors containing IDs not present in the instrument

- Scale scoring parameters: repeated items, a `min_valid` outside 1 to
  the number of items, and weights that are not positive finite numbers

- Reverse coding declared for an item outside the scale that declares it

- Branching rules referencing item IDs not present in the instrument

- `%in%` branching rules whose `value` no evaluator can consume

- Attention checks referencing item IDs not present in the instrument

- A choice code with white space at the start or end, such as `" 1"`

- A scale `method` other than `"mean"` or `"sum"`, a choice set whose
  `values` and `labels` differ in length, a branching rule whose
  operator is unknown or missing or that depends on its own item, and a
  plan block whose `alpha` or `options$alpha` is not a number between 0
  and 1

These are reported as notes, which
[`sframe_notes()`](https://surveyframe.org/reference/sframe_notes.md)
returns and which leave the instrument valid, since SurveyBuilder saved
them before 0.4.3: branching rules that depend on each other in a cycle,
a check whose pass values are not codes of its item's choice set, an
item whose `scale_id` names a scale that does not list it, and a scale
item's choice set with numeric codes outside 1 evenly spaced run (1 to 5
and 99 for "do not know"), which
[`score_scales()`](https://surveyframe.org/reference/score_scales.md)
reads as missing.

- Analysis plan roles referencing missing variables or models

- Model specifications referencing missing indicators or constructs

## Changed in 0.4.0

Earlier versions returned 2 different things depending on `strict`: the
instrument itself, invisibly, when `strict = TRUE`, and a bare unclassed
list when `strict = FALSE`. A validator should report a diagnostic, so
both paths now return an
[sframe_validation](https://surveyframe.org/reference/sframe_validation.md)
object, and they return it visibly, so `validate_sframe(instrument)`
typed at the console shows the result. Code that read `$valid` and
`$problems` keeps working. Code that used the `strict = TRUE` return as
an instrument should now wrap the call in
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md).

## See also

[sframe_validation](https://surveyframe.org/reference/sframe_validation.md),
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md),
[`sframe_problems()`](https://surveyframe.org/reference/sframe_problems.md),
[`sframe_is_valid()`](https://surveyframe.org/reference/sframe_is_valid.md),
[`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md),
[`write_sframe()`](https://surveyframe.org/reference/write_sframe.md)

Other Design functions:
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md),
[`launch_builder()`](https://surveyframe.org/reference/launch_builder.md),
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md),
[`sframe_attention_check()`](https://surveyframe.org/reference/sframe_attention_check.md),
[`sframe_branch()`](https://surveyframe.org/reference/sframe_branch.md),
[`sframe_choice_set()`](https://surveyframe.org/reference/sframe_choice_set.md),
[`sframe_conjoint_design()`](https://surveyframe.org/reference/sframe_conjoint_design.md),
[`sframe_get_study()`](https://surveyframe.org/reference/sframe_get_study.md),
[`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md),
[`sframe_item()`](https://surveyframe.org/reference/sframe_item.md),
[`sframe_sampling_methods()`](https://surveyframe.org/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md),
[`sframe_validation`](https://surveyframe.org/reference/sframe_validation.md),
[`write_sframe()`](https://surveyframe.org/reference/write_sframe.md)

## Examples

``` r
# Build a minimal valid instrument and validate it
cs    <- sframe_choice_set("ag5", 1:5,
           c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree"))
item  <- sframe_item("sat_1", "The service met my expectations.",
                 type = "likert", choice_set = "ag5", scale_id = "sat")
scale <- sframe_scale("sat", "Satisfaction", items = "sat_1")
instr <- sframe_instrument("Demo Survey", components = list(cs, item, scale))

# The result prints its own diagnostic
validate_sframe(instr, strict = FALSE)

# Explore it with dedicated methods rather than reaching in with `$`
v <- validate_sframe(instr, strict = FALSE)
sframe_is_valid(v)
sframe_problems(v)
summary(v)

# Recover the validated instrument
validated <- as_sframe(validate_sframe(instr, strict = TRUE))
isTRUE(sframe_meta(validated)$validated)
```
