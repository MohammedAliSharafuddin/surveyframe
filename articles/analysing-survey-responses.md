# Analysing survey responses

This vignette walks through response import, missing-data checks,
quality checks, scale scoring, descriptives, and planned analyses.

## Load the demo

``` r

demo <- sframe_demo_data()
instr <- demo$instrument
responses <- demo$responses

dim(responses)
#> [1] 120  18
```

## Expected response columns

Response data should use instrument item IDs as column names. Metadata
columns such as respondent ID, start time, and submission time should be
declared explicitly.

``` r

item_ids <- vapply(instr$items, function(x) x$id, character(1))
head(item_ids)
#> [1] "visit_type" "dm_1"       "dm_2"       "dm_3"       "sq_1"      
#> [6] "sq_2"

names(responses)[1:8]
#> [1] "respondent_id" "submitted_at"  "started_at"    "visit_type"   
#> [5] "dm_1"          "dm_2"          "dm_3"          "sq_1"
```

## Import responses

Use `strict = TRUE` when the response file should contain only known
item and metadata columns. Use `strict = FALSE` when the file may
contain additional survey platform columns that should be retained with
a warning.

``` r

strict_responses <- read_responses(
  demo$responses_path,
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  meta_cols = "started_at",
  strict = TRUE
)

relaxed_responses <- read_responses(
  demo$responses_path,
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  meta_cols = "started_at",
  strict = FALSE
)

identical(names(strict_responses), names(relaxed_responses))
#> [1] TRUE
```

## Missing data

``` r

missing <- missing_data_report(responses, instr)

missing$item_missing
#>              variable missing_n missing_pct valid_n
#> visit_type visit_type         0           0     120
#> dm_1             dm_1         0           0     120
#> dm_2             dm_2         0           0     120
#> dm_3             dm_3         0           0     120
#> sq_1             sq_1         0           0     120
#> sq_2             sq_2         0           0     120
#> sq_3             sq_3         0           0     120
#> sus_1           sus_1         0           0     120
#> sus_2           sus_2         0           0     120
#> sat_1           sat_1         0           0     120
#> sat_2           sat_2         0           0     120
#> bi_1             bi_1         0           0     120
#> bi_2             bi_2         0           0     120
#> attention   attention         0           0     120
#> comments     comments         0           0     120
head(missing$respondent_missing)
#>   row missing_n missing_pct
#> 1   1         0           0
#> 2   2         0           0
#> 3   3         0           0
#> 4   4         0           0
#> 5   5         0           0
#> 6   6         0           0
```

## Data quality

``` r

quality <- quality_report(
  responses,
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  started_at = "started_at"
)

quality
#> Survey Data Quality Report
#>   Respondents:  120
#>   Items:        15
#>   Flagged:      109 (90.8%)
#> 
#> Attention checks:
#>   attention_agree      pass 95%  fail 6
#> 
#> Timing:
#>   Median completion time: 966.0 seconds
#> 
#> Missingness:  0.0% of respondents exceed 20% threshold
```

## Score scales

[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)
uses the scale definitions in the instrument. It applies reverse coding
and minimum valid item rules.

``` r

scored <- score_scales(responses, instr, keep_items = TRUE, keep_meta = TRUE)

scale_ids <- vapply(instr$scales, function(x) x$id, character(1))
head(scored[, intersect(scale_ids, names(scored)), drop = FALSE])
#>   digital_marketing service_quality sustainability satisfaction
#> 1          2.666667        3.666667            5.0          3.5
#> 2          3.000000        2.666667            3.0          1.5
#> 3          4.666667        3.333333            3.5          4.5
#> 4          4.333333        4.000000            5.0          4.5
#> 5          3.000000        3.666667            4.0          3.0
#> 6          3.666667        3.666667            2.5          3.5
#>   behavioural_intention
#> 1                   4.5
#> 2                   2.5
#> 3                   2.5
#> 4                   5.0
#> 5                   3.5
#> 6                   3.0
```

## Descriptive statistics

``` r

descriptives_report(
  scored,
  variables = intersect(scale_ids, names(scored))
)
#> $method
#> [1] "descriptives"
#> 
#> $variables
#> [1] "digital_marketing"     "service_quality"       "sustainability"       
#> [4] "satisfaction"          "behavioural_intention"
#> 
#> $split_by
#> NULL
#> 
#> $weights
#> NULL
#> 
#> $table
#>                variable group   n valid_n missing_n     mean        sd median
#> 1     digital_marketing   All 120     120         0 3.152778 0.8576517   3.00
#> 2       service_quality   All 120     120         0 3.055556 0.8964432   3.00
#> 3        sustainability   All 120     120         0 3.187500 0.8226379   3.00
#> 4          satisfaction   All 120     120         0 3.291667 1.0443593   3.25
#> 5 behavioural_intention   All 120     120         0 3.100000 1.0504101   3.00
#>        iqr      min max    skewness   kurtosis         se   ci_low  ci_high
#> 1 1.000000 1.000000   5 -0.11828231 -0.1968503 0.07829253 2.997751 3.307805
#> 2 1.333333 1.333333   5  0.14528766 -0.5985009 0.08183369 2.893517 3.217594
#> 3 1.500000 1.500000   5  0.15770066 -0.3405926 0.07509623 3.038802 3.336198
#> 4 1.500000 1.000000   5 -0.03690984 -0.9403399 0.09533652 3.102891 3.480443
#> 5 1.125000 1.000000   5  0.02329631 -0.6542410 0.09588888 2.910130 3.289870
#>   weighted_mean
#> 1            NA
#> 2            NA
#> 3            NA
#> 4            NA
#> 5            NA
#> 
#> $apa
#> [1] "Descriptive statistics were computed for 5 variable(s)."
#> 
#> $prompt
#> [1] "Report central tendency, variability, missingness, and any skewed distributions before inferential tests."
#> 
#> attr(,"class")
#> [1] "sframe_descriptives_report"
```

## Run an analysis plan

Analysis plans are stored in the instrument. The current structure uses
method-specific roles. Earlier `variables` and `test` blocks remain
compatible.

``` r

instr$analysis_plan <- list(
  list(
    id = "RQ1",
    research_question = "Is digital marketing associated with satisfaction?",
    family = "association",
    method = "correlation_spearman",
    roles = list(x = "digital_marketing", y = "satisfaction"),
    options = list(alpha = 0.05),
    status = "valid_plan",
    requires_data = TRUE
  ),
  list(
    id = "RQ2",
    research_question = "Do visit types differ in satisfaction?",
    family = "group_comparison",
    method = "mann_whitney",
    roles = list(group = "visit_type", outcome = "satisfaction"),
    options = list(alpha = 0.05),
    status = "valid_plan",
    requires_data = TRUE
  )
)

results <- run_analysis_plan(responses, instr)
results
#> Analysis Results: 2 research question(s)
#> 
#> RQ 1: Is digital marketing associated with satisfaction?
#>   Test: correlation_spearman
#>   APA:  r_s(118) = 0.54, p < .001
#> 
#> RQ 2: Do visit types differ in satisfaction?
#>   Test: mann_whitney
#>   APA:  U = 1772, z = -0.06, p = 0.951, r = 0.01
```

## GUI workflow

SurveyStudio can preload both the instrument and responses.

``` r

launch_studio(
  instrument = instr,
  responses = responses,
  screen = "analysis",
  launch.browser = FALSE
)
```
