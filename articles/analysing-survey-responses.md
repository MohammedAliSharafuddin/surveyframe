# Analysing survey responses: running the plan

The analysis in surveyframe is driven by the plan stored in the
instrument. Once responses are imported, scored, and checked,
[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md)
runs every research question in one pass and returns results formatted
for reporting.

The worked-study vignette uses a published study whose data is private.
This vignette uses the bundled tourism demo, a synthetic dataset shaped
around the same digital marketing and tourism constructs, so the
analysis runs end to end without internet access or private data.

## Load the demo

``` r

demo      <- sframe_demo("tourism_services")
instr     <- demo$instrument
responses <- demo$responses

dim(responses)
```

## Import responses

Response data uses instrument item IDs as column names. Metadata columns
are declared explicitly. With `strict = TRUE`, an undeclared column is
an error. With `strict = FALSE`, it is retained with a warning. Strict
mode therefore catches an unexpected export instead of silently
discarding columns.

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
```

## Missing data and quality

``` r

mr <- sframe_missing_data_results(responses, instr)
mr_items <- as.data.frame(mr)[, c("variable", "missing_n", "missing_prop", "valid_n")]
mr_items$missing_prop <- 100 * mr_items$missing_prop
kable(mr_items, digits = 1, row.names = FALSE,
      col.names = c("Variable", "Missing (n)", "Missing (%)", "Valid (n)"),
      caption = "Item-level missingness")

qr <- sframe_quality_results(
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

## Score scales

[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md)
scores the scales for you, but scoring once up front lets you inspect
the construct scores and run the assumption checks below.

``` r

scored    <- score_scales(responses, instr, keep_items = TRUE, keep_meta = TRUE)
scale_ids <- vapply(instr$scales, function(x) x$id, character(1))
score_cols <- intersect(scale_ids, names(scored))

kable(head(scored[, score_cols, drop = FALSE]), digits = 2,
      caption = "Scale scores, first respondents")
```

The scale-score distributions show the shape of each construct before
the plan runs.

``` r

op <- par(mfrow = c(1, length(score_cols)), mar = c(4, 3, 2, 1))
for (s in score_cols) {
  v <- scored[[s]]; v <- v[is.finite(v)]
  hist(v, col = "#16B3B1", border = "white", main = s,
       xlab = "Score", ylab = "")
}
par(op)
```

## Check assumptions before the plan

[`sframe_assumption_results()`](https://surveyframe.org/reference/sframe_assumption_results.md)
reports the checks a technique relies on, such as residual normality,
variance inflation, and influence for a regression.

``` r

sframe_assumption_results(
  scored,
  predictors = c("digital_marketing", "service_quality", "sustainability"),
  outcome    = "satisfaction"
)
```

## Define the plan

Each block binds a research question to a technique and to the variables
that fill each role. A correlation expects `x` and `y`. A regression
expects `predictors` and a `dependent` variable. A group comparison
expects a `group` and an `outcome`.

``` r

sframe_plan(instr) <- list(
  list(id = "RQ1",
       research_question = "Is digital marketing perception associated with satisfaction?",
       family = "association", method = "correlation_pearson",
       roles = list(x = "digital_marketing", y = "satisfaction"),
       options = list(alpha = 0.05)),
  list(id = "RQ2",
       research_question = "Do the 3 perception scales predict satisfaction?",
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

Pass `plots = TRUE` to attach a brand-styled `ggplot2` chart to each
result that supports one (descriptive, correlation, chi-square, and
regression blocks). The chart sits in `$plot` alongside the existing
`$table` and `$apa` elements.

``` r

results_plots <- run_analysis_plan(responses, instr, plots = TRUE)
results_plots[[1]]$plot
```

## Read a single result

Each result holds more than the printed line. It carries the APA
statistic, the effect-size label where the technique reports one, a
writing prompt, and the references that support the technique.

``` r

rq1 <- results[[1]]

rq1$apa
rq1$effect_label
rq1$prompt
unlist(rq1$citations)
```

## Render the results report

[`render_results()`](https://surveyframe.org/reference/render_results.md)
writes a self-contained HTML report with one section per research
question, each holding the APA result, the writing prompt, a space for
the interpretation, and a reference list compiled from the techniques
used.

``` r

render_results(results, instr, output_file = "results.html", citation_format = "apa")
```

## In SurveyStudio

SurveyStudio runs the same plan. Open it on the analysis screen, upload
the responses, and the Analyse screen runs the saved plan and shows a
table of each question with its method and APA result. The full report
is produced on the Report screen.

``` r

launch_studio(
  instrument     = instr,
  responses      = responses,
  screen         = "analysis",
  launch.browser = FALSE
)
```

## Next step

You now have imported, screened, scored, and analysed responses.
Continue with the scale reliability and validity vignette for
measurement evidence, or copy an editable worked notebook with
`sframe_demo_qmd("two_group")`.
