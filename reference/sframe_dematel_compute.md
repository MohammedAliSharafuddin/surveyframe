# The DEMATEL total-relation classification

Normalises the direct-influence matrix `X` by the larger of its greatest
row sum and its greatest column sum (the standard DEMATEL normalisation,
which keeps the Neumann series `N + N^2 + N^3 + ...` convergent), then
solves the total-relation matrix `T = N(I - N)^-1` in closed form rather
than by truncating the series. `D` is each criterion's row sum of `T`
(how much it influences the others, direct and indirect combined) and
`R` its column sum (how much it is influenced). Prominence `D + R` is
overall involvement in the system, while relation `D - R` is net
direction, positive for a net cause and negative or zero for a net
effect. The threshold is the arithmetic mean of every entry of `T`:
relations at or above it are considered significant enough to draw in an
influence diagram.

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

The series converges only when the spectral radius of `N` is below 1.
Normalisation keeps the radius at or below 1, and it equals 1 when
criteria influence each other in a closed group with equal totals. That
case returns an `error` explaining it, and no truncated series is
substituted.
