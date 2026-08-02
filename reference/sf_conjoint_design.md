# Declare a choice-experiment (conjoint) design

Generates and stores a conjoint profile set and task schedule as part of
the instrument's pre-declared contract. This is a design generator, not
an estimator: it fixes what respondents will be shown, and it does not
fit or analyse choice models.

## Usage

``` r
sf_conjoint_design(
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
  numbers, and `_` characters.

- attributes:

  Named list of character vectors, one per attribute, giving that
  attribute's levels. At least 2 attributes, each with at least 2
  levels.

- method:

  One of `"full"`, `"balanced"`, or `"random"`. Ignored when `profiles`
  is supplied.

- n_profiles:

  Number of profiles to keep. Required for `"balanced"` and `"random"`,
  ignored for `"full"`.

- n_alternatives:

  Alternatives shown per choice task, default 2.

- n_tasks:

  Choice tasks per block. Defaults to as many whole tasks as the profile
  set supports.

- blocks:

  Number of blocks the tasks are split across, default 1.

- seed:

  Integer seed. Generated and stored when not supplied.

- profiles:

  Optional data frame of pre-built profiles, one column per attribute.
  Supplying this bypasses generation and declares the design as given.

- label:

  Human-readable label.

## Value

An object of class `sf_conjoint_design` with `$profiles`, `$tasks` (long
format, one row per block, task, and alternative, ready for a choice
model), `$balance`, and the declaration that produced them.

## Details

The design is reproducible by construction. `seed` is always recorded,
and generated when not supplied, so regenerating from the stored
declaration returns the identical profiles and tasks.

## Choosing a method

`"full"` enumerates every combination, which is exact but grows fast: 4
attributes at 3 levels each is 81 profiles. `"random"` takes a seeded
random subset of that size. `"balanced"` samples repeatedly and keeps
the subset with the most even level spread and the weakest association
between attributes.

`"balanced"` is a search, not a construction. It does not produce a
catalogued orthogonal fractional factorial and does not claim the
guarantees of one. The achieved balance is reported in `$balance` so the
design can be inspected rather than trusted. A study needing a specific
D-optimal or orthogonal design should generate it elsewhere and pass it
in through `profiles`, which keeps the declaration in the contract
either way.

## See also

[`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md)

## Examples

``` r
design <- sf_conjoint_design(
  "hotel_dce",
  attributes = list(
    price    = c("50", "100", "150"),
    board    = c("room only", "breakfast"),
    distance = c("beachfront", "10 min walk")
  ),
  method = "balanced", n_profiles = 6, n_alternatives = 2, seed = 42
)
design$profiles
#>   profile_id price     board   distance
#> 1         p1    50 breakfast beachfront
#> 2         p2   100 room only beachfront
#> 3         p3   150 breakfast beachfront
#> 4         p4   150 room only beachfront
#> 5         p5    50 room only beachfront
#> 6         p6   100 breakfast beachfront
design$tasks
#>   block task alternative profile_id
#> 1     1    1           1         p2
#> 2     1    1           2         p4
#> 3     1    2           1         p3
#> 4     1    2           2         p6
#> 5     1    3           1         p5
#> 6     1    3           2         p1
```
