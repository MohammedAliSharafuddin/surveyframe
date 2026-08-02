# Normalise the decision options of an analysis-plan block

A researcher-supplied performance matrix round-trips through JSON as a
list of numeric row vectors with its dimnames dropped, so it is stored
as `options$matrix` plus the `options$alternatives` and
`options$criteria` label vectors and rebuilt here. Every length
agreement between the matrix, its labels, the weights, and the criterion
types is checked once, in one place, with the exact mismatch named.

## Usage

``` r
sframe_decision_options(options)
```

## Arguments

- options:

  The `options` list of a decision analysis block.

## Value

The same list with `matrix` rebuilt as a numeric matrix carrying
dimnames, and `weights` and `criteria_types` coerced and checked.

## PROMETHEE preference functions

A PROMETHEE block takes `options$preference_function`, one of `"usual"`,
`"linear"`, or `"level"`, and `options$thresholds` for the 2 that need
them. The default is `"usual"`, Brans and Vincke's type I step function,
which needs no thresholds and so adds no researcher degrees of freedom.

This default differs from several other MCDM implementations, which
default to the linear (V-shape) function and derive its thresholds from
the range of the supplied data. Deriving thresholds that way makes the
result depend on choices the researcher never declared, which is what
this package exists to prevent, so surveyframe requires a
threshold-bearing preference function to be asked for explicitly.

The choice changes the answer. Net flows always differ between the 2
functions, and the ranking itself changed in 226 of 400 randomly drawn
4-alternative by 3-criterion matrices. So a ranking cross-checked
against an implementation that defaults to `"linear"` will often
disagree unless `preference_function = "linear"` is set here and the
same thresholds are supplied on both sides. The preference function
actually used is always named in the block's APA sentence. Note also
that `"usual"` produces tied ranks readily, because a step function
scores every non-zero difference identically.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)

## Examples

``` r
sframe_decision_options(list(
  matrix = list(c(4, 210), c(3, 180)),
  alternatives = c("Alpha", "Basilica"),
  criteria = c("service", "price"),
  criteria_types = c("benefit", "cost")
))$matrix
#>          service price
#> Alpha          4   210
#> Basilica       3   180
```
