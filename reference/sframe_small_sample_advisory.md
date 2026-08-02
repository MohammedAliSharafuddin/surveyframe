# Small-sample advisory text

Builds a short advisory note when a sample falls below the conventional
n = 30 threshold at which asymptotic approximations become unreliable.

## Usage

``` r
sframe_small_sample_advisory(n, test)
```

## Arguments

- n:

  Integer. The sample size.

- test:

  Character. A short description of the analysis the advisory applies
  to, inserted into the message.

## Value

A single character string, or NULL when `n` is 30 or more.
