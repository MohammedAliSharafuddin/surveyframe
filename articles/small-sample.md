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

[`sample_size_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sample_size_plan.md)
estimates a required sample size for a design and attaches the same
small-sample advisory used elsewhere in the package when the estimate
itself falls below 30.

``` r

sample_size_plan(type = "t_test", groups = 2)
#> Sample-Size Plan
#>   Target:      t_test
#>   Estimated n: 128
#>   Method:      power
#>   Alpha:       0.050   Power: 0.80
#>   Effect size: d = 0.5
#> 
#> Warning: Assumed a medium effect, d = 0.5. Supply d for the effect you expect.
```

A worked instrument in this vignette targets n = 20 complete responses,
well below that planning estimate. The instrument below has a two-level
grouping question, a numeric outcome, and a binary outcome for the
logistic example later in this vignette.

``` r

group_cs     <- sf_choices(id = "grp_cs", values = c("control", "treatment"),
                            labels = c("Control", "Treatment"))
converted_cs <- sf_choices(id = "conv_cs", values = c("no", "yes"),
                            labels = c("No", "Yes"))

items <- list(
  sf_item(id = "group", label = "Study arm", type = "single_choice", choice_set = "grp_cs"),
  sf_item(id = "outcome", label = "Outcome score", type = "numeric"),
  sf_item(id = "converted", label = "Converted (yes/no)", type = "single_choice",
          choice_set = "conv_cs")
)

study <- sf_instrument(
  title      = "Small-sample pilot",
  version    = "0.1.0",
  authors    = "surveyframe",
  components = c(list(group_cs, converted_cs), items)
)

study
#> <sframe>
#>   Title:      Small-sample pilot
#>   Version:    0.1.0
#>   Items:      3
#>   Scales:     0
#>   Analysis:   0 block(s)
#>   Status:     not validated
```

## Reading the advisory

[`assumption_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/assumption_report.md)
and
[`sample_size_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sample_size_plan.md)
both attach an `advisory` element once a relevant n drops below 30. It
prints automatically and is also available as a field for programmatic
checks.

``` r

n20 <- data.frame(score = rnorm(20, mean = 50, sd = 10))
n50 <- data.frame(score = rnorm(50, mean = 50, sd = 10))

ar_small <- assumption_report(n20, variables = "score")
ar_small$advisory
#> [1] "Small sample detected (n = 20). For these assumption checks, consider non-parametric alternatives. Asymptotic p-values may be unreliable. Bootstrap or exact confidence intervals are provided where available."

ar_large <- assumption_report(n50, variables = "score")
is.null(ar_large$advisory)
#> [1] TRUE
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

sf_plan(study) <- list(
  list(id = "RQ1",
       research_question = "Does the treatment arm score higher than control?",
       family = "group_comparison", method = "mann_whitney",
       roles = list(group = "group", outcome = "outcome"),
       options = list(alpha = 0.05))
)

mw_results <- run_analysis_plan(pilot, study)
results_table(mw_results)
```

| RQ | Research question | Method | Result (APA) |
|:---|:---|:---|---:|
| RQ1 | Does the treatment arm score higher than control? |  | U = 34, z = -1.21, p = .226, r = 0.27, 95% CI \[0.02, 0.64\], Hodges-Lehmann shift = -3.99, 95% CI \[-13.75, 4.58\] |

``` r

mw_results[[1]]$hl_shift
#> [1] -3.987846
mw_results[[1]]$hl_conf_int
#> [1] -13.750068   4.584132
```

## Paired Wilcoxon with the pseudomedian CI

The paired runner reports a Hodges-Lehmann pseudomedian for the
within-pair shift, again with an interval in place of a point value.

``` r

before <- rnorm(8, 50, 6)
after  <- before + rnorm(8, 4, 5)

sf_plan(study) <- list(
  list(id = "RQ2",
       research_question = "Did scores change from before to after?",
       family = "group_comparison", method = "wilcoxon_pair",
       roles = list(before = "before", after = "after"),
       options = list(alpha = 0.05))
)

wp_results <- run_analysis_plan(data.frame(before = before, after = after), study)
results_table(wp_results)
```

| RQ | Research question | Method | Result (APA) |
|:---|:---|:---|---:|
| RQ2 | Did scores change from before to after? |  | V = 0, z = -2.52, p = .012, r = 0.89, 95% CI \[0.89, 0.90\], pseudomedian = -6.46, 95% CI \[-11.70, -3.63\] |

``` r

wp_results[[1]]$pseudomedian
#> [1] -6.45986
wp_results[[1]]$pseudomedian_conf_int
#> [1] -11.700678  -3.633836
```

## Fisher’s exact test with the exact odds-ratio CI

For a 2x2 table, `fisher_exact` now attaches an exact odds-ratio
confidence interval alongside the test’s p-value. The interval is only
defined for a 2x2 table, and is dropped (not approximated) when
`simulate_p_value` is requested, since base R’s
[`fisher.test()`](https://rdrr.io/r/stats/fisher.test.html) cannot
return both together.

``` r

sf_plan(study) <- list(
  list(id = "RQ3",
       research_question = "Is conversion associated with study arm?",
       family = "association", method = "fisher_exact",
       roles = list(row = "group", column = "converted"),
       options = list(alpha = 0.05))
)

fe_results <- run_analysis_plan(pilot, study)
results_table(fe_results)
```

| RQ | Research question | Method | Result (APA) |
|:---|:---|:---|---:|
| RQ3 | Is conversion associated with study arm? |  | Fisher’s exact test, p = 1.000, phi = 0.12 |

``` r

fe_results[[1]]$odds_ratio
#> [1] 0.599308
fe_results[[1]]$odds_ratio_conf_int
#> [1] 0.0390558 6.9366524
```

## Bootstrap confidence interval on a median

[`bootstrap_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/bootstrap_ci.md)
computes a bootstrap interval for an arbitrary statistic, useful when no
exact interval exists for the estimator you need. It is already exported
and used elsewhere in the package, applied here to the median of the
pilot outcome scores.

``` r

bootstrap_ci(pilot$outcome, FUN = stats::median, R = 999)
#> estimate    lower    upper 
#> 52.82878 47.33676 56.66709 
#> attr(,"resamples")
#> [1] 999
#> attr(,"valid_resamples")
#> [1] 999
```

## Firth logistic regression for a rare or small binary outcome

Ordinary logistic regression can fail to converge or produce severely
biased estimates with small samples or separated data. Firth’s
penalised-likelihood correction (Firth, 1993) addresses both.
surveyframe’s `firth_logistic` runner needs the optional `logistf`
package.

``` r

sf_plan(study) <- list(
  list(id = "RQ4",
       research_question = "Does the covariate predict conversion?",
       family = "regression", method = "firth_logistic",
       roles = list(dependent = "converted", predictors = "covariate"),
       options = list(conf.level = 0.95))
)

firth_results <- run_analysis_plan(pilot, study)
results_table(firth_results)
```

| RQ | Research question | Method | Result (APA) |
|:---|:---|:---|---:|
| RQ4 | Does the covariate predict conversion? |  | Firth logistic regression (n = 20), likelihood ratio = 0.10 |

``` r

firth_results[[1]]$coefficients
#>               Estimate     ci_low     ci_high         p odds_ratio or_ci_low
#> (Intercept) -0.9722906 -1.9991045 -0.07984311 0.0321831  0.3782157 0.1354565
#> covariate    0.1336834 -0.7614982  0.99469674 0.7555259  1.1430308 0.4669663
#>             or_ci_high
#> (Intercept)  0.9232612
#> covariate    2.7039042
```

## Cohen’s d with a bootstrap interval

[`cohens_d_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cohens_d_ci.md)
pairs Cohen’s d with a bootstrap interval, which is informative
precisely where it matters most: interval width grows visibly as n
falls, making the extra uncertainty at small n explicit, where a single
point estimate leaves it implicit.

``` r

cohens_d_ci(pilot$outcome[pilot$group == "treatment"],
            pilot$outcome[pilot$group == "control"], R = 999)
#>   estimate      lower      upper 
#> 0.54201883 0.02928852 1.54044282 
#> attr(,"resamples")
#> [1] 999
#> attr(,"valid_resamples")
#> [1] 999
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
