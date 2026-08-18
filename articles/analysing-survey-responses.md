# Analysing survey responses: running the plan

The analysis in surveyframe is driven by the plan stored in the
instrument. Once responses are imported, scored, and checked,
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
runs every research question in one pass and returns results formatted
for reporting.

The worked-study vignette uses a published study whose data is private.
This vignette uses the bundled tourism demo, a synthetic dataset shaped
around the same digital marketing and tourism constructs, so the
analysis runs end to end without internet access or private data.

## Load the demo

``` r

demo      <- sframe_demo_data()
instr     <- demo$instrument
responses <- demo$responses

dim(responses)
#> [1] 120  18
```

## Import responses

Response data uses instrument item IDs as column names. Metadata columns
are declared explicitly. Use `strict = TRUE` to keep only known columns.

``` r

responses <- read_responses(
  demo$responses_path,
  instr,
  respondent_id = "respondent_id",
  submitted_at  = "submitted_at",
  meta_cols     = "started_at",
  strict        = TRUE
)

dim(responses)
#> [1] 120  18
```

## Missing data and quality

``` r

mr <- missing_data_report(responses, instr)
kable(as.data.frame(mr), digits = 2,
      col.names = c("Variable", "Missing (n)", "Missing (%)", "Valid (n)"),
      caption = "Item-level missingness")
```

|            | Variable   | Missing (n) | Missing (%) | Valid (n) |
|:-----------|:-----------|------------:|------------:|----------:|
| visit_type | visit_type |           0 |           0 |       120 |
| dm_1       | dm_1       |           0 |           0 |       120 |
| dm_2       | dm_2       |           0 |           0 |       120 |
| dm_3       | dm_3       |           0 |           0 |       120 |
| sq_1       | sq_1       |           0 |           0 |       120 |
| sq_2       | sq_2       |           0 |           0 |       120 |
| sq_3       | sq_3       |           0 |           0 |       120 |
| sus_1      | sus_1      |           0 |           0 |       120 |
| sus_2      | sus_2      |           0 |           0 |       120 |
| sat_1      | sat_1      |           0 |           0 |       120 |
| sat_2      | sat_2      |           0 |           0 |       120 |
| bi_1       | bi_1       |           0 |           0 |       120 |
| bi_2       | bi_2       |           0 |           0 |       120 |
| attention  | attention  |           0 |           0 |       120 |
| comments   | comments   |           0 |           0 |       120 |

Item-level missingness {.table}

``` r


qr <- quality_report(
  responses, instr,
  respondent_id = "respondent_id",
  submitted_at  = "submitted_at",
  started_at    = "started_at"
)
# as.data.frame() gives the summary row.
qr_summary <- as.data.frame(qr)
quality_summary <- data.frame(
  Metric = c("Respondents", "Items", "Flagged for review", "Flag rate"),
  Value  = c(qr_summary$n_respondents, qr_summary$n_items, qr_summary$n_flagged,
             sprintf("%.1f%%", 100 * qr_summary$flag_rate)),
  stringsAsFactors = FALSE
)
kable(quality_summary, align = c("l", "r"), caption = "Quality screening summary")
```

| Metric             | Value |
|:-------------------|------:|
| Respondents        |   120 |
| Items              |    15 |
| Flagged for review |   109 |
| Flag rate          | 90.8% |

Quality screening summary {.table}

## Score scales

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
scores the scales for you, but scoring once up front lets you inspect
the construct scores and run the assumption checks below.

``` r

scored    <- score_scales(responses, instr, keep_items = TRUE, keep_meta = TRUE)
scale_ids <- vapply(instr$scales, function(x) x$id, character(1))
score_cols <- intersect(scale_ids, names(scored))

kable(head(scored[, score_cols, drop = FALSE]), digits = 2,
      caption = "Scale scores, first respondents")
```

| digital_marketing | service_quality | sustainability | satisfaction | behavioural_intention |
|---:|---:|---:|---:|---:|
| 2.67 | 3.67 | 5.0 | 3.5 | 4.5 |
| 3.00 | 2.67 | 3.0 | 1.5 | 2.5 |
| 4.67 | 3.33 | 3.5 | 4.5 | 2.5 |
| 4.33 | 4.00 | 5.0 | 4.5 | 5.0 |
| 3.00 | 3.67 | 4.0 | 3.0 | 3.5 |
| 3.67 | 3.67 | 2.5 | 3.5 | 3.0 |

Scale scores, first respondents {.table}

The scale-score distributions show the shape of each construct before
the plan runs.

``` r

op <- par(mfrow = c(1, length(score_cols)), mar = c(4, 3, 2, 1))
for (s in score_cols) {
  v <- scored[[s]]; v <- v[is.finite(v)]
  hist(v, col = "#16B3B1", border = "white", main = s,
       xlab = "Score", ylab = "")
}
```

![Histograms of the scored scale distributions, one panel per
scale](analysing-survey-responses_files/figure-html/score-distributions-1.png)

``` r

par(op)
```

## Check assumptions before the plan

[`assumption_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/assumption_report.md)
reports the checks a technique relies on, such as residual normality,
variance inflation, and influence for a regression.

``` r

assumption_report(
  scored,
  predictors = c("digital_marketing", "service_quality", "sustainability"),
  outcome    = "satisfaction"
)
#> Assumption Report
#> 
#> Regression residuals: n = 120, Shapiro-Wilk p = 0.898
```

## Define the plan

Each block binds a research question to a technique and to the variables
that fill each role. A correlation expects `x` and `y`. A regression
expects `predictors` and a `dependent` variable. A group comparison
expects a `group` and an `outcome`.

``` r

sf_plan(instr) <- list(
  list(id = "RQ1",
       research_question = "Is digital marketing perception associated with satisfaction?",
       family = "association", method = "correlation_pearson",
       roles = list(x = "digital_marketing", y = "satisfaction"),
       options = list(alpha = 0.05)),
  list(id = "RQ2",
       research_question = "Do the three perception scales predict satisfaction?",
       family = "regression", method = "regression_linear",
       roles = list(predictors = c("digital_marketing", "service_quality", "sustainability"),
                    dependent = "satisfaction"),
       options = list(alpha = 0.05)),
  list(id = "RQ3",
       research_question = "Do first-time and repeat visitors differ in behavioural intention?",
       family = "group_comparison", method = "mann_whitney",
       roles = list(group = "visit_type", outcome = "behavioural_intention"),
       options = list(alpha = 0.05))
)
```

## Run the plan

``` r

results <- run_analysis_plan(responses, instr)
results_table(results)
```

| RQ | Research question | Method | Result (APA) | Effect |
|:---|:---|:---|---:|:---|
| RQ1 | Is digital marketing perception associated with satisfaction? | pearson | r(118) = 0.54 \[0.40, 0.65\], p \< .001 | large |
| RQ2 | Do the three perception scales predict satisfaction? |  | R² = 0.383, F(3, 116) = 23.95, p \< .001 |  |
| RQ3 | Do first-time and repeat visitors differ in behavioural intention? |  | U = 1576, z = -0.98, p = 0.327, r = 0.09 \[0.01, 0.27\], Hodges-Lehmann shift = -0.00 \[-0.50, 0.00\] | negligible |

Pass `plots = TRUE` to attach a brand-styled `ggplot2` chart to each
result that supports one (descriptive, correlation, chi-square, and
regression blocks). The chart sits in `$plot` alongside the existing
`$table` and `$apa` elements.

``` r

results_plots <- run_analysis_plan(responses, instr, plots = TRUE)
results_plots[[1]]$plot
```

![Chart attached to the first analysis-plan result by run_analysis_plan
with plots
enabled](analysing-survey-responses_files/figure-html/run-plots-1.png)

## Read a single result

Each result holds more than the printed line. It carries the APA
statistic, the effect-size label where the technique reports one, a
writing prompt, and the references that support the technique.

``` r

rq1 <- results[[1]]

rq1$apa
#> [1] "r(118) = 0.54 [0.40, 0.65], p < .001"
rq1$effect_label
#> [1] "large"
rq1$prompt
#> [1] "There was a positive, large significant correlation between digital_marketing and satisfaction, r(118) = 0.54 [0.40, 0.65], p < .001. Explain what this means for your research question."
unlist(rq1$citations)
#>                                                                                                                                                         field_2018 
#>                                                                            "Field, A. (2018). *Discovering statistics using IBM SPSS statistics* (5th ed.). SAGE." 
#>                                                                                                                                                         cohen_1988 
#>                                                          "Cohen, J. (1988). *Statistical power analysis for the behavioral sciences* (2nd ed.). Lawrence Erlbaum." 
#>                                                                                                                                                             r_core 
#>                                          "R Core Team. (2026). *R: A language and environment for statistical computing*. R Foundation for Statistical Computing." 
#>                                                                                                                                                        surveyframe 
#> "Sharafuddin, M. A. (2026). *surveyframe: Survey Instrument Workflows* (Version 0.4.0) [Computer software]. https://github.com/MohammedAliSharafuddin/surveyframe"
```

## Render the results report

[`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md)
writes a self-contained HTML report with one section per research
question, each holding the APA result, the writing prompt, a space for
the interpretation, and a reference list compiled from the techniques
used.

``` r

render_results(results, instr, output_file = "results.html", citation_format = "apa")
```

## In SurveyStudio

SurveyStudio runs the same plan. Open it on the analysis screen, upload
the responses, and the Analysis Plan screen runs the saved plan and
shows a table of each question with its method and APA result. The full
report is produced on the Export screen.

``` r

launch_studio(
  instrument     = instr,
  responses      = responses,
  screen         = "analysis",
  launch.browser = FALSE
)
```
