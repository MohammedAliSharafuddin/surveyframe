# Score defined scales from survey responses

Applies scale scoring rules from the instrument to response data.
Handles reverse coding, optional weighted composite score computation,
and minimum valid item thresholds. Returns a data frame with one scored
column per scale.

## Usage

``` r
score_scales(data, instrument, keep_items = TRUE, keep_meta = TRUE)
```

## Arguments

- data:

  A `tibble` or `data.frame` of responses.

- instrument:

  An `sframe` object.

- keep_items:

  Logical. Whether to retain individual item columns in the output.
  Defaults to `TRUE`.

- keep_meta:

  Logical. Whether to retain non-item columns (metadata) in the output.
  Defaults to `TRUE`.

## Value

A `data.frame` with scored scale columns appended. Scale columns are
named using the scale `id`.

## See also

[`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md),
[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)

## Examples

``` r
cs    <- sf_choices("ag5", 1:5,
           c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree"))
i1    <- sf_item("sat_1", "Item 1", type = "likert",
                 choice_set = "ag5", scale_id = "sat")
i2    <- sf_item("sat_2", "Item 2", type = "likert",
                 choice_set = "ag5", scale_id = "sat")
i3    <- sf_item("sat_3", "Item 3 (reverse)", type = "likert",
                 choice_set = "ag5", scale_id = "sat", reverse = TRUE)
scale <- sf_scale("sat", "Satisfaction",
                  items = c("sat_1", "sat_2", "sat_3"), min_valid = 2L)
instr <- sf_instrument("Demo", components = list(cs, i1, i2, i3, scale))

responses <- data.frame(
  sat_1 = c(4, 5, 3),
  sat_2 = c(4, 4, 3),
  sat_3 = c(2, 1, 3),
  stringsAsFactors = FALSE
)

scored <- score_scales(responses, instr)
scored$sat
#> [1] 4.000000 4.666667 3.000000
```
