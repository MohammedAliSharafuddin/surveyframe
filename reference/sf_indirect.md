# Define an indirect effect path

Define an indirect effect path

## Usage

``` r
sf_indirect(from, through, to, label = NULL)
```

## Arguments

- from:

  Source construct ID.

- through:

  Character vector of mediator construct IDs.

- to:

  Target construct ID.

- label:

  Optional effect label.

## Value

An object of class `sf_indirect`.

## Examples

``` r
ind <- sf_indirect("sq", through = "sat", to = "bi", label = "mediation")
ind$through
#> [1] "sat"
```
