# Coerce a surveyframe object to a data frame

Every surveyframe class returns its primary table, and each class has
its own columns. Where an object holds more than one table, the others
are reachable through the named accessors in
[sf_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
or, for a full tabular record of an instrument, through
[`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md).

## Arguments

- x:

  A surveyframe object.

- row.names:

  Passed to
  [`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html)
  by the methods that build a frame. Ignored by the methods that return
  a stored table.

- optional:

  Passed to
  [`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

- ...:

  Ignored. Present for S3 consistency.

## Value

A data frame, with the columns listed above for the class given.

## What each class gives

|  |  |  |
|----|----|----|
| Class | One row per | Columns |
| `sframe` | item | `id`, `label`, `type`, `choice_set`, `scale_id`, `reverse`, `required` |
| `sframe_codebook` | item | the codebook's item table |
| `sframe_validation` | problem | `check`, `problem` |
| `sframe_analysis_results` | block | `block`, `research_question`, `method`, `apa` |
| `sframe_reliability_report` | scale | `scale_id`, `label`, `n_items`, `n`, `alpha`, `omega` |
| `sframe_item_report` | item | `scale_id` and the item diagnostics |
| `sframe_quality_report` | check | the flattened quality checks |
| `sframe_efa_report` | measure | the readiness measures |
| `sframe_sensitivity` | perturbation | `criterion`, `direction`, `weight`, `rho`, `rank_changed`, `top_changed` |

## A summary, and where the full record is

These tables are a summary of the columns a reader scans first. The item
table leaves out help text, placeholder, matrix rows, comparison items
and scale, slider and rating settings, date bounds, section introduction
and page; the scale table leaves out `min_valid`, the reverse key and
the weights. Read the stored declaration in full through
[`sf_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_items.md),
[`sf_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scales.md)
and the rest of
[sf_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
each of which returns the component objects themselves, or through
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
for the interchange record.

A class holding one table returns it directly, so it keeps that table's
own row names and `row.names` has no effect. Pass `row.names` to
[`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) on
the returned frame where you need to set them. The coercion gives one
view of an object. An instrument, for example, returns its items, and
its choice sets and scales come from
[`sf_choice_sets()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choice_sets.md),
[`sf_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scales.md)
or
[`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md).

## See also

[sf_accessors](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
[`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md)

## Examples

``` r
cs    <- sf_choices("ag5", 1:5,
           c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree"))
item  <- sf_item("sat_1", "The service met my expectations.",
                 type = "likert", choice_set = "ag5", scale_id = "sat")
scale <- sf_scale("sat", "Satisfaction", items = "sat_1")
instr <- sf_instrument("Demo Survey", components = list(cs, item, scale))

as.data.frame(instr)
#>      id                            label   type choice_set scale_id reverse
#> 1 sat_1 The service met my expectations. likert        ag5      sat   FALSE
#>   required
#> 1    FALSE
as.data.frame(cs)
#>   value             label
#> 1     1 Strongly disagree
#> 2     2          Disagree
#> 3     3           Neutral
#> 4     4             Agree
#> 5     5    Strongly agree
```
