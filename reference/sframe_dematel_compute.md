# The DEMATEL total-relation classification

Normalises the direct-influence matrix `X` by the larger of its greatest
row sum and its greatest column sum (the standard DEMATEL normalisation,
which keeps the Neumann series `N + N^2 + N^3 + ...` convergent), then
solves the total-relation matrix `T = N(I - N)^-1` in closed form rather
than by truncating the series. `D` is each criterion's row sum of `T`
(how much it influences the others, direct and indirect combined) and
`R` its column sum (how much it is influenced). Prominence `D + R` is
overall involvement in the system; relation `D - R` is net direction,
positive for a net cause and negative or zero for a net effect. The
threshold is the arithmetic mean of every entry of `T`: relations at or
above it are considered significant enough to draw in an influence
diagram.

## Usage

``` r
sframe_dematel_compute(x)
```

## Arguments

- x:

  A square numeric matrix of direct influence, zero diagonal.

## Value

A list with `normalised` (N), `total_relation` (T), `D`, `R`,
`prominence` (D + R), `relation` (D - R), `threshold` (mean of T), and
`role` (a character vector, `"cause"` where relation \> 0, else
`"effect"`).

## Details

[`solve()`](https://rdrr.io/r/base/solve.html) fails outright if `I - N`
is exactly singular, which does not arise for a matrix normalised this
way in ordinary use; no fallback series truncation is implemented,
unlike the harvested source, because a singular `I - N` here would
signal a malformed matrix rather than a case to work around silently.
