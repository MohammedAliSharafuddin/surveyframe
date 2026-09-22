# Define a latent or composite construct

Define a latent or composite construct

## Usage

``` r
sf_construct(
  id,
  label = NULL,
  items = character(0),
  mode = c("reflective", "composite", "formative", "single_item"),
  weights = NULL
)
```

## Arguments

- id:

  Construct identifier. Must start with a letter and contain only
  letters, numbers, and `_` characters.

- label:

  Human-readable construct label.

- items:

  Character vector of indicator item IDs.

- mode:

  Measurement mode. One of `"reflective"`, `"composite"`, `"formative"`,
  or `"single_item"`.

- weights:

  Optional indicator weights for later PLS-SEM planning.

## Value

An object of class `sf_construct`.

## Examples

``` r
sq <- sf_construct("sq", "Service Quality",
                    items = c("sq_1", "sq_2", "sq_3"))
sq$mode
#> [1] "reflective"
sq$items
#> [1] "sq_1" "sq_2" "sq_3"
```
