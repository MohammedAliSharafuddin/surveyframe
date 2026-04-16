# Getting started with surveyframe

surveyframe treats a survey instrument as a first-class R object. One
declarative source drives validation, deployment, quality checking,
scoring, psychometric diagnostics, and report generation. This vignette
walks through the complete workflow using a five-item customer
satisfaction instrument.

------------------------------------------------------------------------

## 1. Define the instrument

Every instrument is built from typed component objects assembled by
[`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md).
Start with choice sets, then items, then scales. Branching rules and
attention checks are optional but recommended.

``` r
# A five-point agreement scale used across all Likert items
agree5 <- sf_choices(
  id     = "agree5",
  values = 1:5,
  labels = c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree")
)

# A yes/no set used for a screening item
yn <- sf_choices(
  id     = "yn",
  values = c("yes", "no"),
  labels = c("Yes", "No")
)

# Five satisfaction items, all linked to the "sat" scale
sat_1 <- sf_item(
  id         = "sat_1",
  label      = "The service was delivered on time.",
  type       = "likert",
  choice_set = "agree5",
  scale_id   = "sat",
  required   = TRUE
)

sat_2 <- sf_item(
  id         = "sat_2",
  label      = "Staff were knowledgeable and helpful.",
  type       = "likert",
  choice_set = "agree5",
  scale_id   = "sat",
  required   = TRUE
)

sat_3 <- sf_item(
  id         = "sat_3",
  label      = "The overall experience did not meet my expectations.",
  type       = "likert",
  choice_set = "agree5",
  scale_id   = "sat",
  required   = TRUE,
  reverse    = TRUE   # this item is reverse-coded
)

sat_4 <- sf_item(
  id         = "sat_4",
  label      = "I would use this service again.",
  type       = "likert",
  choice_set = "agree5",
  scale_id   = "sat",
  required   = TRUE
)

sat_5 <- sf_item(
  id         = "sat_5",
  label      = "I would recommend this service to others.",
  type       = "likert",
  choice_set = "agree5",
  scale_id   = "sat",
  required   = TRUE
)

# Demographic items
age    <- sf_item("age",    "What is your age?",   type = "numeric")
gender <- sf_item("gender", "What is your gender?",
                  type = "single_choice", choice_set = "yn")

# An attention check item
attn_item <- sf_item(
  id         = "attn_1",
  label      = "To confirm you are reading carefully, please select Agree.",
  type       = "likert",
  choice_set = "agree5"
)

# The satisfaction scale definition
sat_scale <- sf_scale(
  id            = "sat",
  label         = "Customer Satisfaction",
  items         = c("sat_1", "sat_2", "sat_3", "sat_4", "sat_5"),
  method        = "mean",
  min_valid     = 4L
)

# Attach the attention check to the attn_1 item
attn_check <- sf_check(
  id          = "chk_attn_1",
  item_id     = "attn_1",
  type        = "attention",
  pass_values = 4,
  fail_action = "flag",
  label       = "Attention check"
)

# Assemble the instrument
instr <- sf_instrument(
  title       = "Customer Satisfaction Survey",
  version     = "1.0.0",
  description = "Measures overall satisfaction with a five-item Likert scale.",
  authors     = "Mohammed Ali Sharafuddin",
  components  = list(
    agree5, yn,
    sat_1, sat_2, sat_3, sat_4, sat_5,
    age, gender, attn_item,
    sat_scale,
    attn_check
  )
)

print(instr)
#> <sframe>
#>   Title:      Customer Satisfaction Survey
#>   Version:    1.0.0
#>   Items:      8
#>   Scales:     1
#>   Status:     not validated
```

------------------------------------------------------------------------

## 2. Validate and save

[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
checks the instrument for structural problems before anything else
happens.
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
saves the validated instrument as a SHA-256 hashed JSON file. The file
is human-readable, version-control friendly, and portable across
machines and R sessions.

``` r
# Validate (raises an error with a detailed message if problems exist)
instr <- validate_sframe(instr)

# Save to a .sframe file
write_sframe(instr, "satisfaction_survey.sframe")

# Load back later in any R session
instr <- read_sframe("satisfaction_survey.sframe")
```

The `strict = FALSE` option returns a list of problems without stopping,
which is useful during instrument development:

``` r
result <- validate_sframe(instr, strict = FALSE)
cat("Valid:", result$valid, "\n")
#> Valid: TRUE
cat("Problems:", length(result$problems), "\n")
#> Problems: 0
```

------------------------------------------------------------------------

## 3. Deploy as a Shiny survey

[`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
turns the instrument into a running Shiny application. All item types,
required-field logic, and single-condition branching rules are rendered
automatically. When `save_responses = "csv"`, submitted responses are
written to a CSV file with `started_at` and `submitted_at` metadata
columns.

``` r
render_survey(
  instr,
  save_responses = "csv",
  output_path = "responses.csv"
)
```

To launch the full SurveyStudio interface, which provides a visual shell
for the complete workflow, use
[`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md):

``` r
launch_studio(instrument = instr)
```

All remaining workflow steps also work in regular R scripts. Shiny is
only needed for interactive survey deployment and the SurveyStudio
interface.

------------------------------------------------------------------------

## 4. Load responses

Once data are collected (as a CSV from the Shiny app or any external
tool), load them with
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md).
Column names must match instrument item IDs. Files written by
[`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
include `started_at` and `submitted_at` metadata columns, so load those
through `meta_cols` and `submitted_at`.

``` r
# Simulate a response dataset for this vignette
set.seed(101)
n <- 120
responses_raw <- data.frame(
  respondent_id = paste0("P", seq_len(n)),
  submitted_at  = as.character(
    as.POSIXct("2024-06-01") + sample(0:86400, n, replace = TRUE)),
  sat_1  = sample(1:5, n, replace = TRUE, prob = c(.05,.10,.15,.40,.30)),
  sat_2  = sample(1:5, n, replace = TRUE, prob = c(.05,.10,.20,.40,.25)),
  sat_3  = sample(1:5, n, replace = TRUE, prob = c(.30,.35,.20,.10,.05)),
  sat_4  = sample(1:5, n, replace = TRUE, prob = c(.05,.10,.15,.35,.35)),
  sat_5  = sample(1:5, n, replace = TRUE, prob = c(.05,.10,.20,.35,.30)),
  age    = sample(18:70, n, replace = TRUE),
  gender = sample(c("yes","no"), n, replace = TRUE),
  attn_1 = c(rep(4, round(n * 0.90)), rep(2, round(n * 0.10))),
  stringsAsFactors = FALSE
)

responses <- read_responses(
  x             = responses_raw,
  instrument    = instr,
  respondent_id = "respondent_id",
  submitted_at  = "submitted_at"
)

cat("Loaded:", nrow(responses), "responses,", ncol(responses), "columns\n")
#> Loaded: 120 responses, 10 columns
```

------------------------------------------------------------------------

## 5. Check data quality

[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)
evaluates the response data against the checks defined in the
instrument. It covers attention check performance, straight-lining
within scale blocks, item and respondent-level missingness, and
duplicate IDs.

``` r
qr <- quality_report(
  data          = responses,
  instrument    = instr,
  respondent_id = "respondent_id",
  submitted_at  = "submitted_at"
)

print(qr)
#> Survey Data Quality Report
#>   Respondents:  120
#>   Items:        8
#>   Flagged:      12 (10.0%)
#> 
#> Attention checks:
#>   chk_attn_1           pass 90%  fail 12
#> 
#> Missingness:  0.0% of respondents exceed 20% threshold
```

The quality report object is structured, so individual results are
accessible programmatically:

``` r
# Pass rate for the attention check
cat("Attention check pass rate:",
    round(qr$attention$chk_attn_1$pass_rate * 100, 1), "%\n")
#> Attention check pass rate: 90 %

# Number of respondents flagged for straight-lining
cat("Straight-line flags (sat scale):",
    length(qr$straightline$sat$flagged_rows), "\n")
#> Straight-line flags (sat scale): 0
```

------------------------------------------------------------------------

## 6. Score scales

[`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md)
applies the scale definitions from the instrument: reverse coding,
composite scoring, and minimum valid item rules. It returns a tibble
with one scored column per scale appended.

``` r
scored <- score_scales(
  data       = responses,
  instrument = instr,
  keep_items = TRUE,
  keep_meta  = TRUE
)

cat("Scale column added: 'sat'\n")
#> Scale column added: 'sat'
cat("Mean satisfaction score:", round(mean(scored$sat, na.rm = TRUE), 3), "\n")
#> Mean satisfaction score: 3.813
cat("SD:", round(sd(scored$sat, na.rm = TRUE), 3), "\n")
#> SD: 0.549
```

------------------------------------------------------------------------

## 7. Psychometric diagnostics

### Reliability

[`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)
computes Cronbach’s alpha and McDonald’s omega for each scale. Both
statistics are derived from the instrument’s scale definitions, so item
membership and reverse coding are already known.

``` r
rr <- reliability_report(responses, instr, omega = FALSE)
print(rr)
#> Reliability Report
#> 
#> Scale: sat (Customer Satisfaction)
#>   Items: 5   N: 120
#>   Alpha:   0.184
```

### Item diagnostics

[`item_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/item_report.md)
produces item-total correlations, floor and ceiling proportions, and
descriptive statistics for every item within each scale.

``` r
ir <- item_report(responses, instr)
print(ir[[1]]$diagnostics)
#> # A tibble: 5 × 7
#>   item_id  mean    sd item_rest_r floor_pct ceiling_pct n_missing
#>   <chr>   <dbl> <dbl>       <dbl>     <dbl>       <dbl>     <int>
#> 1 sat_1    3.82  1.20      -0.919    0.0583      0.358          0
#> 2 sat_2    3.85  1.00      -0.879    0.025       0.283          0
#> 3 sat_3    2.44  1.21      -0.919    0.233       0.0833         0
#> 4 sat_4    4.03  1.13      -0.907    0.0333      0.442          0
#> 5 sat_5    3.82  1.11      -0.902    0.0417      0.317          0
```

### EFA readiness

[`efa_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_report.md)
prepares a dataset for exploratory factor analysis by computing KMO
adequacy and Bartlett’s test. It does not estimate a factor solution.
That step belongs to the researcher, using
[`psych::fa()`](https://rdrr.io/pkg/psych/man/fa.html) or a similar
package.

``` r
er <- efa_report(responses, instr)
#> R was not square, finding R from data
#> Parallel analysis suggests that the number of factors =  0  and the number of components =  0
print(er)
#> EFA Readiness Diagnostics
#> 
#>   Items:          5
#>   Complete cases: 120
#>   KMO overall:    0.507
#>   Bartlett chi-sq: 9.49  df: 10  p: 0.4863
#>   Suggested factors (parallel analysis): 0
#>   Planned rotation: oblimin
#> 
#> Note: this report does not estimate an EFA solution.
```

### CFA syntax

[`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md)
generates a `lavaan` model string directly from the scale structure in
the instrument. Paste it into `lavaan::cfa()` when you are ready to fit
the confirmatory model.

``` r
syntax <- cfa_syntax(instr)
cat(syntax)
#> # lavaan CFA syntax generated by surveyframe
#> # Instrument: Customer Satisfaction Survey v1.0.0
#> # Recommended: lavaan::cfa(model, data = ..., std.lv = TRUE)
#> 
#> # Reverse-coded in 'sat': sat_3
#> sat =~ sat_1 +
#>     sat_2 +
#>     sat_3 +
#>     sat_4 +
#>     sat_5
```

To fit the model:

``` r
library(lavaan)
fit <- cfa(syntax, data = scored, std.lv = TRUE)
summary(fit, fit.measures = TRUE)
```

------------------------------------------------------------------------

## 8. Generate a codebook and report

[`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md)
produces a structured codebook from the instrument definition.
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
assembles everything into a single reproducible HTML file.

``` r
cb <- codebook_report(instr)
print(cb)
#> Codebook: Customer Satisfaction Survey v1.0.0
#>   8 items  |  2 choice sets  |  1 scales
#> 
#> Items:
#> # A tibble: 8 × 5
#>   id     label                                            type  scale_id reverse
#>   <chr>  <chr>                                            <chr> <chr>    <lgl>  
#> 1 sat_1  The service was delivered on time.               like… "sat"    FALSE  
#> 2 sat_2  Staff were knowledgeable and helpful.            like… "sat"    FALSE  
#> 3 sat_3  The overall experience did not meet my expectat… like… "sat"    TRUE   
#> 4 sat_4  I would use this service again.                  like… "sat"    FALSE  
#> 5 sat_5  I would recommend this service to others.        like… "sat"    FALSE  
#> 6 age    What is your age?                                nume… ""       FALSE  
#> 7 gender What is your gender?                             sing… ""       FALSE  
#> 8 attn_1 To confirm you are reading carefully, please se… like… ""       FALSE
```

``` r
# Requires the quarto package
render_report(
  instrument          = instr,
  data                = responses,
  output_file         = "satisfaction_survey_report.html",
  include_codebook    = TRUE,
  include_quality     = TRUE,
  include_reliability = TRUE
)
```

The report embeds the instrument hash so every output is traceable to
the exact instrument version that produced it.

------------------------------------------------------------------------

## The complete pipeline in twelve lines

``` r
library(surveyframe)

# Build once
instr     <- read_sframe("satisfaction_survey.sframe")

# Load and check
responses <- read_responses("responses.csv", instr, respondent_id = "id")
qr        <- quality_report(responses, instr, respondent_id = "id")

# Score and measure
scored    <- score_scales(responses, instr)
rr        <- reliability_report(responses, instr)
syntax    <- cfa_syntax(instr)

# Report
render_report(instr, data = responses, output_file = "report.html")
```

------------------------------------------------------------------------

## Citing surveyframe

If you use surveyframe in a publication, please cite the package and
include the instrument hash from your `.sframe` file in your
supplementary materials. This makes your measurement instrument fully
reproducible and auditable by reviewers.

``` r
citation("surveyframe")
```
