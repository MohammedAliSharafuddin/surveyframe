# Run a pre-planned analysis from an instrument's analysis plan

Executes every analysis block defined in the instrument's
`analysis_plan` slot against the supplied response data. Each block
corresponds to one research question defined during instrument design in
the SurveyBuilder. Results include APA-formatted statistics, effect
sizes, interpretation prompts, and reporting references.

## Usage

``` r
run_analysis_plan(
  data,
  instrument,
  scored = TRUE,
  plots = FALSE,
  plot_palette = c("web", "print"),
  seed = 20260828L,
  strict = FALSE
)
```

## Arguments

- data:

  A `tibble` or `data.frame` of responses, typically produced by
  [`read_responses()`](https://surveyframe.org/reference/read_responses.md)
  or
  [`read_sheet_responses()`](https://surveyframe.org/reference/read_sheet_responses.md).

- instrument:

  An `sframe` object containing an `analysis_plan`.

- scored:

  Logical. Whether to automatically score scales before running the
  analysis. Defaults to `TRUE`.

- plots:

  Logical. When `TRUE` and ggplot2 is installed, supported blocks gain a
  `$plot` element holding a brand-styled ggplot object: bar charts for
  frequency and chi-square blocks, scatter plots with a regression
  overlay for correlation and linear-regression blocks. Defaults to
  `FALSE`.

- plot_palette:

  One of `"web"` (brand colours, for on-screen use) or `"print"` (black,
  grey, and white, for journal-ready print figures). Applied to every
  plot attached when `plots = TRUE`. See `sframe_brand()`.

- seed:

  Integer or `NULL`. The random seed the analysis runs under. Defaults
  to a fixed value so the same instrument and the same data give the
  same answer every time, which is what makes a rendered report usable
  as an audit artefact. Every bootstrap confidence interval in the plan,
  and the parallel analysis behind the EFA family, depend on it. Pass
  `NULL` for the unseeded behaviour of releases before 0.4.1. Each
  block's stream starts from this seed and the block's id, so a block
  gives the same interval whatever blocks come before it. The caller's
  own random stream is restored afterwards, so seeding here does not
  affect anything that runs later.

- strict:

  Logical. When `TRUE`, an error is raised if any block fails or scale
  scoring fails, listing each failure. When `FALSE`, the default,
  failures are kept in the results and counted in their `status`.

## Value

An object of class `sframe_analysis_results`, a list with one element
per analysis block, named by block id. Its `status` attribute holds
`blocks`, `succeeded`, `failed`, `failed_blocks` and `scoring`, the
outcome of scoring scales before analysis. A normal return can hold
failed blocks, so check `attr(results, "status")$failed` or use
`strict = TRUE`. Each element contains the test result, APA string,
interpretation prompt, and reporting-reference metadata. Inferential
blocks also carry a `$table` data frame suitable for
[`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html). Pass to
[`render_results()`](https://surveyframe.org/reference/render_results.md)
to generate a formatted report.

## Cross-tabulations

A `crosstab` or `chi_square` block's result carries `$totals`, the
counts with a Total row and column. Set
`options = list(percent = "row")`, `"column"` or `"total"` for
`$percent_table`, the percentages over that denominator. The Total row
of row percentages is the column distribution, and the Total column of
column percentages is the row distribution. The report then shows each
count with its percentage beside it, and the chart draws the
percentages.

## Weights

A frequency, descriptives, cross-tabulation or chi-square block may name
a case-weight column in its `weights` role. A design weight is set by
the researcher, not asked of respondents, so it may be a column that is
not an item:
[`validate_sframe()`](https://surveyframe.org/reference/validate_sframe.md)
notes it, and it must then be in the responses, read with
`read_responses(meta_cols = )`. A block whose weight column is missing,
or holds a negative, non-finite or non-numeric value, fails with a
message saying so.

## How answers are coded

Categories follow 1 order in every locale: the codes of the item's
choice set as the instrument declares them, then factor levels, then any
other value, numbers by value and other text in code point order. A
category nobody chose is dropped before a model is fitted.

- McNemar's test lays both items out on that order, so each category is
  paired with itself. 2 items with different choice sets are refused.

- An ordinal logistic outcome is ordered as its choice set declares. The
  result's `$outcome_levels` and its sentence give the order.

- In every model (linear, binary, ordinal, multinomial and Firth
  logistic regression, and the ANCOVA covariates) a `single_choice` or
  `multiple_choice` item enters as a category, with 1 indicator term per
  category after the first, whatever its codes look like. The first
  category with answers is the reference. The result's
  `$predictor_coding` lists each categorical predictor's levels, and the
  sentence names each reference category.

- A binary or Firth logistic model gives the odds of its event, the last
  category of its outcome in that order (1 of 0 and 1, the last declared
  code of a choice set). `options = list(event = "yes")` names another.
  The result's `$event` and `$reference_level`, and its sentence, name
  both. A multinomial model's reference is the first category.

## See also

[`render_results()`](https://surveyframe.org/reference/render_results.md),
[`read_sheet_responses()`](https://surveyframe.org/reference/read_sheet_responses.md)

Other Analyse functions:
[`score_scales()`](https://surveyframe.org/reference/score_scales.md),
[`sframe_assumption_results()`](https://surveyframe.org/reference/sframe_assumption_results.md),
[`sframe_descriptives_results()`](https://surveyframe.org/reference/sframe_descriptives_results.md),
[`sframe_efa_readiness_results()`](https://surveyframe.org/reference/sframe_efa_readiness_results.md),
[`sframe_efa_solution()`](https://surveyframe.org/reference/sframe_efa_solution.md),
[`sframe_item_results()`](https://surveyframe.org/reference/sframe_item_results.md),
[`sframe_posthoc_results()`](https://surveyframe.org/reference/sframe_posthoc_results.md),
[`sframe_reliability_results()`](https://surveyframe.org/reference/sframe_reliability_results.md),
[`sframe_validity_results()`](https://surveyframe.org/reference/sframe_validity_results.md)

## Examples

``` r
instr <- read_sframe(
  system.file("extdata", "demos", "two_group.sframe",
              package = "surveyframe")
)
responses <- read_responses(
  system.file("extdata", "demos", "two_group_responses.csv",
              package = "surveyframe"),
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  meta_cols = "started_at"
)
# \donttest{
results <- run_analysis_plan(responses, instr)
print(results)
# }
```
