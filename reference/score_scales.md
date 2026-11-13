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

## Sum scores with unanswered items

With `method = "sum"` and a `min_valid` below the number of items, a
respondent who answered at least `min_valid` items gets a prorated sum:
the mean of the answered items times the number of items (with weights,
the weighted mean times the sum of the weights). 5 and 5 on 2 of 4 items
on a 1 to 5 scale scores 20. Before 0.4.3 an unanswered item counted as
0, so the same respondent scored 10.

## Codes that are not scores

An item's scores are the longest run of its choice set's numeric codes
at 1 even step: 1 to 5, or 0 to 100 in steps of 25. A code outside that
run, such as 99 for "do not know" after 1 to 5, is read as missing, with
a message naming it and how many answers held it, and a reversed item is
reversed on the run's ends (1 + 5 - x). A set with 2 equally long runs,
such as 1, 2, 4, 5, has no clear run, and its scale is refused with an
error.
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
notes such a choice set. Before 0.4.3 every numeric code was a score, so
the reversal point moved to 1 + 99 and a 99 entered the mean.

## See also

[`sframe_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_scale.md),
[`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md)

Other Analyse functions:
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`sframe_assumption_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_assumption_results.md),
[`sframe_descriptives_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_descriptives_results.md),
[`sframe_efa_readiness_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_readiness_results.md),
[`sframe_efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_efa_solution.md),
[`sframe_item_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_item_results.md),
[`sframe_posthoc_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_posthoc_results.md),
[`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md),
[`sframe_validity_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_validity_results.md)

## Examples

``` r
cs    <- sframe_choice_set("ag5", 1:5,
           c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree"))
i1    <- sframe_item("sat_1", "Item 1", type = "likert",
                 choice_set = "ag5", scale_id = "sat")
i2    <- sframe_item("sat_2", "Item 2", type = "likert",
                 choice_set = "ag5", scale_id = "sat")
i3    <- sframe_item("sat_3", "Item 3 (reverse)", type = "likert",
                 choice_set = "ag5", scale_id = "sat", reverse = TRUE)
scale <- sframe_scale("sat", "Satisfaction",
                  items = c("sat_1", "sat_2", "sat_3"), min_valid = 2L)
instr <- sframe_instrument("Demo", components = list(cs, i1, i2, i3, scale))

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
