# Generate EFA planning syntax

Generate EFA planning syntax

## Usage

``` r
efa_syntax(
  items,
  nfactors = 1L,
  extraction = c("minres", "pa", "ml"),
  rotation = c("oblimin", "promax", "varimax"),
  data_name = "data"
)
```

## Arguments

- items:

  Character vector of item IDs.

- nfactors:

  Number of factors.

- extraction:

  Extraction method.

- rotation:

  Rotation method.

- data_name:

  Name of the data object in generated R code.

## Value

A character string with R syntax.
