# Define a covariance between constructs

Define a covariance between constructs

## Usage

``` r
sf_covariance(from, to, label = NULL)
```

## Arguments

- from:

  First construct ID.

- to:

  Second construct ID.

- label:

  Optional label.

## Value

An object of class `sf_covariance`.

## Examples

``` r
cov <- sf_covariance("sq", "sus", label = "cov1")
cov$from
#> [1] "sq"
cov$to
#> [1] "sus"
```
