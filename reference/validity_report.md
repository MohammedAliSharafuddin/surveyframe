# Validity report for construct models

Validity report for construct models

## Usage

``` r
validity_report(loadings, construct_scores = NULL, items_by_construct = NULL)
```

## Arguments

- loadings:

  A data.frame with columns `construct`, `item`, and `loading`, or a
  named list of loading vectors by construct.

- construct_scores:

  Optional data.frame of construct scores for Fornell-Larcker and
  inter-construct correlations.

- items_by_construct:

  Optional named list, one element per construct, each a data.frame of
  that construct's item-level responses. When supplied, `htmt` is the
  Henseler heterotrait-monotrait ratio: the mean absolute
  heterotrait-heteromethod correlation over the geometric mean of the
  two constructs' mean absolute monotrait-heteromethod correlations.
  Constructs with a single item have no monotrait correlations, so their
  HTMT entries are `NA`. Without this argument, `htmt` falls back to the
  absolute inter-construct correlation matrix from `construct_scores`
  (the pre-0.3.4 behaviour). The `htmt_method` element records which was
  computed.

## Value

An object of class `sframe_validity_report`.

## Examples

``` r
loadings <- list(
  sq  = c(sq_1 = 0.80, sq_2 = 0.75, sq_3 = 0.78),
  sat = c(sat_1 = 0.85, sat_2 = 0.82)
)
vr <- validity_report(loadings)
vr$reliability
#>     construct composite_reliability       AVE n_items
#> sat       sat             0.8217148 0.6974500       2
#> sq         sq             0.8203234 0.6036333       3
```
