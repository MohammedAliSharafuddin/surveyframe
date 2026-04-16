# Define a reusable choice set

Creates a named set of response options that can be referenced by one or
more items. Defining choices once and referencing them by `id` keeps the
instrument consistent and reduces the risk of label mismatches across
items that share the same response format.

## Usage

``` r
sf_choices(id, values, labels, allow_other = FALSE, randomise = FALSE)
```

## Arguments

- id:

  Character. A unique identifier for this choice set. Referenced in the
  `choice_set` argument of
  [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md).

- values:

  Character or numeric vector. The stored values corresponding to each
  response option. Must have the same length as `labels`.

- labels:

  Character vector. The display labels shown to respondents. Must have
  the same length as `values`.

- allow_other:

  Logical. Whether to append an open-text "Other" option at the end of
  the choice list. Defaults to `FALSE`.

- randomise:

  Logical. Whether to randomise the display order of options at render
  time. Defaults to `FALSE`.

## Value

An object of class `sf_choices` (a named list).

## See also

[`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md),
[`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md)

## Examples

``` r
# A five-point agreement scale
agree5 <- sf_choices(
  id     = "agree5",
  values = 1:5,
  labels = c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree")
)

# A yes/no set
yn <- sf_choices(
  id     = "yn",
  values = c("yes", "no"),
  labels = c("Yes", "No")
)
```
