# Validity report for construct models

Validity report for construct models

## Usage

``` r
validity_report(loadings, construct_scores = NULL)
```

## Arguments

- loadings:

  A data.frame with columns `construct`, `item`, and `loading`, or a
  named list of loading vectors by construct.

- construct_scores:

  Optional data.frame of construct scores for Fornell-Larcker, HTMT, and
  inter-construct correlations.

## Value

An object of class `sframe_validity_report`.
