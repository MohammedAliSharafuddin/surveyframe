# Estimate an exploratory factor solution

Runs [`psych::fa()`](https://rdrr.io/pkg/psych/man/fa.html) on selected
item columns and returns loadings, communalities, uniqueness, variance
summaries, and simple item retention flags. The `psych` package is
optional and is only required when this function is called.

## Usage

``` r
efa_solution(
  data,
  instrument,
  items = NULL,
  scales = NULL,
  nfactors = 1L,
  extraction = c("minres", "pa", "ml"),
  rotation = c("oblimin", "promax", "varimax"),
  min_loading = 0.3,
  cross_loading = 0.3
)
```

## Arguments

- data:

  A data.frame of responses.

- instrument:

  An `sframe` object.

- items:

  Character vector of item IDs. When `NULL`, scale items are used.

- scales:

  Optional scale IDs used to select item columns.

- nfactors:

  Number of factors.

- extraction:

  Extraction method passed to
  [`psych::fa()`](https://rdrr.io/pkg/psych/man/fa.html).

- rotation:

  Rotation method passed to
  [`psych::fa()`](https://rdrr.io/pkg/psych/man/fa.html).

- min_loading:

  Minimum salient loading.

- cross_loading:

  Maximum secondary loading before a warning is raised.

## Value

An object of class `sframe_efa_solution`.
