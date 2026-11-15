# Small-sample inference

## When is a sample “small”?

Survey research often works with few observations: pilot studies,
specialised populations, classroom studies, and early-stage
organisational diagnostics may land at n = 10 to 25. Adequacy depends
jointly on the design, group balance, outcome distribution, model,
effect size, and estimand, so a single word count answers little on its
own. With limited data, estimates are often imprecise and assumptions
are harder to assess, so an isolated p-value carries limited
information.

surveyframe uses n = 30 as a visible advisory heuristic that flags where
assumptions deserve a closer look. Its small-sample tools surface exact
or alternative procedures where available and pair estimates with
uncertainty. Choosing one changes the question asked: a rank-based test
may target a different quantity from a test about means, and
“distribution-free” carries its own assumptions. Choose the method from
the study design and estimand, and report the limited precision.

## Planning a small-sample study

[`sframe_sample_size_plan()`](https://surveyframe.org/reference/sframe_sample_size_plan.md)
estimates a required sample size for a design and attaches the same
small-sample advisory used elsewhere in the package when the estimate
itself falls below 30.

``` r

sframe_sample_size_plan(type = "t_test", groups = 2)
```

A worked instrument in this vignette targets n = 20 complete responses,
well below that planning estimate. The instrument below has a 2-level
grouping question, a numeric outcome, and a binary outcome for the
logistic example later in this vignette.

``` r

group_cs     <- sframe_choice_set(id = "grp_cs", values = c("control", "treatment"),
                            labels = c("Control", "Treatment"))
converted_cs <- sframe_choice_set(id = "conv_cs", values = c("no", "yes"),
                            labels = c("No", "Yes"))

items <- list(
  sframe_item(id = "group", label = "Study arm", type = "single_choice", choice_set = "grp_cs"),
  sframe_item(id = "outcome", label = "Outcome score", type = "numeric"),
  sframe_item(id = "converted", label = "Converted (yes/no)", type = "single_choice",
          choice_set = "conv_cs")
)

study <- sframe_instrument(
  title      = "Small-sample pilot",
  version    = "0.1.0",
  authors    = "surveyframe",
  components = c(list(group_cs, converted_cs), items)
)

study
```

## Reading the advisory

[`sframe_assumption_results()`](https://surveyframe.org/reference/sframe_assumption_results.md)
and
[`sframe_sample_size_plan()`](https://surveyframe.org/reference/sframe_sample_size_plan.md)
both attach an `advisory` element once a relevant n drops below 30. It
prints automatically and is also available as a field for programmatic
checks.

``` r

n20 <- data.frame(score = rnorm(20, mean = 50, sd = 10))
n50 <- data.frame(score = rnorm(50, mean = 50, sd = 10))

ar_small <- sframe_assumption_results(n20, variables = "score")
ar_small$advisory

ar_large <- sframe_assumption_results(n50, variables = "score")
is.null(ar_large$advisory)
```

## Mann-Whitney with the Hodges-Lehmann estimate

The Mann-Whitney runner now reports the Hodges-Lehmann shift estimate
alongside the rank-biserial effect size, with a confidence interval on
the shift, which a point estimate alone leaves out.

``` r

pilot <- data.frame(
  group   = rep(c("control", "treatment"), each = 10),
  outcome = c(rnorm(10, 48, 8), rnorm(10, 55, 8)),
  converted = sample(c("no", "yes"), 20, replace = TRUE, prob = c(0.6, 0.4)),
  covariate = rnorm(20, 0, 1)
)

sframe_plan(study) <- list(
  list(id = "RQ1",
       research_question = "Does the treatment arm score higher than control?",
       family = "group_comparison", method = "mann_whitney",
       roles = list(group = "group", outcome = "outcome"),
       options = list(alpha = 0.05))
)

mw_results <- run_analysis_plan(pilot, study)
results_table(mw_results)
mw_results[[1]]$hl_shift
mw_results[[1]]$hl_conf_int
```

## Paired Wilcoxon with the pseudomedian CI

The paired runner reports a Hodges-Lehmann pseudomedian for the
within-pair shift, again with an interval in place of a point value.

``` r

before <- rnorm(8, 50, 6)
after  <- before + rnorm(8, 4, 5)

sframe_plan(study) <- list(
  list(id = "RQ2",
       research_question = "Did scores change from before to after?",
       family = "group_comparison", method = "wilcoxon_pair",
       roles = list(before = "before", after = "after"),
       options = list(alpha = 0.05))
)

wp_results <- run_analysis_plan(data.frame(before = before, after = after), study)
results_table(wp_results)
wp_results[[1]]$pseudomedian
wp_results[[1]]$pseudomedian_conf_int
```

## Fisher’s exact test with the exact odds-ratio CI

For a 2x2 table, `fisher_exact` reports an exact odds-ratio confidence
interval beside the test’s p-value. With `simulate_p_value`, it reports
the simulated p-value alone, as base R’s
[`fisher.test()`](https://rdrr.io/r/stats/fisher.test.html) gives either
the simulated p-value or the interval.

``` r

sframe_plan(study) <- list(
  list(id = "RQ3",
       research_question = "Is conversion associated with study arm?",
       family = "association", method = "fisher_exact",
       roles = list(row = "group", column = "converted"),
       options = list(alpha = 0.05))
)

fe_results <- run_analysis_plan(pilot, study)
results_table(fe_results)
fe_results[[1]]$odds_ratio
fe_results[[1]]$odds_ratio_conf_int
```

## Bootstrap confidence interval on a median

[`sframe_bootstrap_ci()`](https://surveyframe.org/reference/sframe_bootstrap_ci.md)
computes a bootstrap interval for an arbitrary statistic, useful when no
exact interval exists for the estimator you need. It is already exported
and used elsewhere in the package, applied here to the median of the
pilot outcome scores.

``` r

sframe_bootstrap_ci(pilot$outcome, FUN = stats::median, R = 999)
```

## Firth logistic regression for a rare or small binary outcome

Ordinary logistic regression can fail to converge or produce severely
biased estimates with small samples or separated data. Firth’s
penalised-likelihood correction (Firth, 1993) addresses both.
surveyframe’s `firth_logistic` runner needs the optional `logistf`
package.

``` r

sframe_plan(study) <- list(
  list(id = "RQ4",
       research_question = "Does the covariate predict conversion?",
       family = "regression", method = "firth_logistic",
       roles = list(dependent = "converted", predictors = "covariate"),
       options = list(conf.level = 0.95))
)

firth_results <- run_analysis_plan(pilot, study)
results_table(firth_results)
firth_results[[1]]$coefficients
```

## Cohen’s d with a bootstrap interval

[`sframe_cohens_d_ci()`](https://surveyframe.org/reference/sframe_cohens_d_ci.md)
pairs Cohen’s d with a bootstrap interval, which is informative
precisely where it matters most: interval width grows visibly as n
falls, making the extra uncertainty at small n explicit, where a single
point estimate leaves it implicit.

``` r

sframe_cohens_d_ci(pilot$outcome[pilot$group == "treatment"],
            pilot$outcome[pilot$group == "control"], R = 999)
```

## Citation

``` r

citation("surveyframe")
```

The small-sample methods demonstrated in this vignette are described in
full, with guidance on when to prefer each one, in:

> Sharafuddin, M. A., Jaleel, A. A., and Madhavan, M. (2026).
> *Quantitative Analysis with Small Samples: A Practical Guide for
> Students and Early-Career Researchers* (Version 0.1.0) \[Book\].
> Zenodo. <https://doi.org/10.5281/zenodo.20221929>

A companion preprint validating these method choices by simulation is in
preparation and will be added here once posted.
