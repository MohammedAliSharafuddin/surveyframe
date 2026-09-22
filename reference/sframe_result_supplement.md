# The second table a result carries, if it has one

Some results hold a table beside their main one that a reader needs: a
quanteda result's leading features, or a moderation's conditional slopes
at the moderator's own values. Both report engines render whatever this
returns, under its own caption, so the 2 cannot drift on what a result
shows.

## Usage

``` r
sframe_result_supplement(result)
```

## Arguments

- result:

  One analysis block's result from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md).

## Value

A list with `table` and `caption`, or `NULL` where the result has no
second table.

## Details

This is exported because the Quarto report template runs in a separate R
session against the installed package, so everything it calls has to be
part of the public surface. A template calling an internal through `:::`
fails there and the renderer falls back to the built-in HTML engine
without saying why.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md),
[`analysis_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/analysis_syntax.md)

## Examples

``` r
instr <- sf_instrument("Moderation demo", components = list(
  sf_item("y", "Outcome", type = "numeric"),
  sf_item("x", "Predictor", type = "numeric"),
  sf_item("w", "Moderator", type = "numeric")
))
sf_plan(instr) <- list(list(
  id = "RQ1", research_question = "Does w moderate x?",
  family = "inferential", method = "moderation",
  roles = list(outcome = "y", predictor = "x", moderator = "w")
))

set.seed(1)
n <- 80
responses <- data.frame(x = rnorm(n), w = rnorm(n))
responses$y <- 0.4 * responses$x + 0.3 * responses$w +
  0.35 * responses$x * responses$w + rnorm(n, sd = 0.6)
results <- run_analysis_plan(responses, instr)

# the conditional slopes, at the moderator's own values
sframe_result_supplement(results$RQ1)
#> $table
#>   Level w value Slope of x
#> 1     1  -1.021      0.193
#> 2     2  -0.097      0.481
#> 3     3   0.827      0.769
#> 
#> $caption
#> [1] "Conditional effect of x at values of w"
#> 
```
