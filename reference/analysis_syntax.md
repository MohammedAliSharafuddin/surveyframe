# The R code behind an analysis result

Returns the statistical call that produced a result, as R code a reader
can copy and run. This is what lets a report show
[`t.test()`](https://rdrr.io/r/stats/t.test.html) or
[`cor.test()`](https://rdrr.io/r/stats/cor.test.html) with the variables
and options resolved, rather than only the
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
call that dispatched it.

## Usage

``` r
analysis_syntax(x, which = NULL, data_expr = "scored", header = FALSE)
```

## Arguments

- x:

  An `sframe_analysis_results` object from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
  or one block's result from it.

- which:

  Character or NULL. One block id, when `x` holds several.

- data_expr:

  Character. The expression the code should read its data from. Defaults
  to `"scored"`, the scored frame the header sets up.

- header:

  Logical. Whether to include the lines that load the instrument, read
  the responses and score the scales. `TRUE` gives a script that runs on
  its own.

## Value

A character vector of R code lines, or `NULL` for a method this does not
cover. For several blocks, a named list of such vectors.

## Details

The code is built from the same resolved specification the runner
executed: the variables in the order it resolved them, and the options
after defaults were applied. Running it reproduces the statistic,
degrees of freedom and p value the package reports, which the package's
own tests check by running the generated code and comparing.

## What it covers

The 2-group, paired, k-group, correlation, regression and categorical
families, and descriptives. `sframe_syntax_methods` lists them. A method
outside that list returns `NULL`: the model families carry their own
syntax already, through
[`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md)
and its neighbours, and for the rest the computation has no single
base-R equivalent to show honestly.

## See also

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md),
[`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md),
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)

## Examples

``` r
instr <- sf_instrument("Syntax demo", components = list(
  sf_item("score", "Score", type = "numeric"),
  sf_item("arm", "Arm", type = "text")
))
sf_plan(instr) <- list(list(
  id = "RQ1", research_question = "Do the arms differ?",
  family = "inferential", method = "t_test_ind",
  roles = list(group = "arm", outcome = "score")
))

set.seed(1)
responses <- data.frame(
  arm   = rep(c("control", "treatment"), each = 15),
  score = c(rnorm(15, 10), rnorm(15, 12))
)
results <- run_analysis_plan(responses, instr)

# the call behind the number, with the variables and options resolved
cat(analysis_syntax(results, which = "RQ1"), sep = "\n")
#> # Do the arms differ?
#> # method: t_test_ind | n = 15 + 15
#> group   <- as.character(scored[["arm"]])
#> outcome <- as.numeric(as.character(scored[["score"]]))
#> levels_seen <- unique(group[!is.na(group)])
#> g1 <- outcome[group == levels_seen[1]]; g1 <- g1[!is.na(g1)]
#> g2 <- outcome[group == levels_seen[2]]; g2 <- g2[!is.na(g2)]
#> t.test(g1, g2, var.equal = FALSE)
```
