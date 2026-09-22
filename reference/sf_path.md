# Define a structural path between constructs

Define a structural path between constructs

## Usage

``` r
sf_path(from, to, label = NULL)
```

## Arguments

- from:

  Source construct ID.

- to:

  Target construct ID.

- label:

  Optional lavaan label for the path.

## Value

An object of class `sf_path`.

## Examples

``` r
p <- sf_path("sq", "sat", label = "H1")
p$from
#> [1] "sq"
p$to
#> [1] "sat"
```
