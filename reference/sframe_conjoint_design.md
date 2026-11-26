# Declare a choice-experiment (conjoint) design

Generates and stores a conjoint profile set and task schedule as part of
the instrument's pre-declared contract. It fixes what respondents will
be shown. Fit and analyse the resulting choice responses with a
choice-model estimator.

## Usage

``` r
sframe_conjoint_design(
  id,
  attributes,
  method = c("full", "balanced", "random"),
  n_profiles = NULL,
  n_alternatives = 2L,
  n_tasks = NULL,
  blocks = 1L,
  seed = NULL,
  profiles = NULL,
  label = NULL
)
```

## Arguments

- id:

  Design identifier. Must start with a letter and contain only letters,
  numbers and `_` characters.

- attributes:

  Named list of character vectors, one per attribute, giving that
  attribute's levels. At least 2 attributes, each with at least 2
  levels.

- method:

  One of `"full"`, `"balanced"` or `"random"`. Ignored when `profiles`
  is supplied.

- n_profiles:

  Number of profiles to keep. Required for `"balanced"` and `"random"`,
  ignored for `"full"`.

- n_alternatives:

  Integer. Alternatives shown per choice task. Defaults to 2.

- n_tasks:

  Choice tasks per block. Defaults to as many whole tasks as the profile
  set supports.

- blocks:

  Integer. Number of blocks the tasks are split across. Defaults to 1.

- seed:

  Integer seed. Generated and stored when omitted.

- profiles:

  Optional data frame of pre-built profiles, one column per attribute.
  Supplying this bypasses generation and declares the design as given.

- label:

  Human-readable label.

## Value

An object of class `sf_conjoint_design` with `$profiles`, `$tasks` (long
format, one row per block, task and alternative, ready for a choice
model), `$balance` and the declaration that produced them.

## Details

The design is reproducible by construction. `seed` is always recorded,
and generated when omitted, so regenerating from the stored declaration
returns the identical profiles and tasks.

## Choosing a method

`"full"` enumerates every combination, which is exact but grows fast: 4
attributes at 3 levels each is 81 profiles. `"random"` takes a seeded
random subset of `n_profiles` of them. `"balanced"` samples repeatedly
and keeps the subset with the most even level spread and the weakest
association between attributes.

`"balanced"` uses a search. A catalogued orthogonal fractional factorial
provides different guarantees. The achieved balance is reported in
`$balance` for inspection. A study needing a specific D-optimal or
orthogonal design should generate it elsewhere and pass it in through
`profiles`, which keeps the declaration in the contract either way.

## See also

[`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md)

Other Design functions:
[`as_sframe()`](https://surveyframe.org/reference/as_sframe.md),
[`launch_builder()`](https://surveyframe.org/reference/launch_builder.md),
[`read_sframe()`](https://surveyframe.org/reference/read_sframe.md),
[`sframe_attention_check()`](https://surveyframe.org/reference/sframe_attention_check.md),
[`sframe_branch()`](https://surveyframe.org/reference/sframe_branch.md),
[`sframe_choice_set()`](https://surveyframe.org/reference/sframe_choice_set.md),
[`sframe_get_study()`](https://surveyframe.org/reference/sframe_get_study.md),
[`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md),
[`sframe_item()`](https://surveyframe.org/reference/sframe_item.md),
[`sframe_sampling_methods()`](https://surveyframe.org/reference/sframe_sampling_methods.md),
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md),
[`sframe_validation`](https://surveyframe.org/reference/sframe_validation.md),
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md),
[`write_sframe()`](https://surveyframe.org/reference/write_sframe.md)

## Examples

``` r
design <- sframe_conjoint_design(
  "hotel_dce",
  attributes = list(
    price    = c("50", "100", "150"),
    board    = c("room only", "breakfast"),
    distance = c("beachfront", "10 min walk")
  ),
  method = "balanced", n_profiles = 6, n_alternatives = 2, seed = 42
)
design$profiles
design$tasks
```
