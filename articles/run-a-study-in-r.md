# Run a study in R

A study in surveyframe passes through 5 stages: design the questionnaire
and its analysis plan, collect the answers, check them, run the planned
analyses, and write the report. This page runs each stage in R. The
`.sframe` file it writes opens in SurveyStudio too, so a study can move
between the 2.

The examples use the `paired` demo, a training evaluation measured
before and after. Its data is demonstration data, not collected from
participants, and every output made from it says so.

## Open a study

``` r

library(surveyframe)
d <- sframe_demo("paired")
d
```

To open a study of your own, read its file:

``` r

ins <- read_sframe("my_study.sframe")
```

## 1. Design

The parts are built with
[`sframe_item()`](https://surveyframe.org/reference/sframe_item.md),
[`sframe_choice_set()`](https://surveyframe.org/reference/sframe_choice_set.md),
[`sframe_scale()`](https://surveyframe.org/reference/sframe_scale.md)
and
[`sframe_instrument()`](https://surveyframe.org/reference/sframe_instrument.md).
The plan is a list of blocks in `sframe_instrument(analysis_plan = )`.
[`write_sframe()`](https://surveyframe.org/reference/write_sframe.md)
saves the file with its integrity hash.

``` r

write_sframe(d$instrument, "paired.sframe")
```

Before collecting, write the plan down.
[`render_report()`](https://surveyframe.org/reference/render_report.md)
given the instrument alone writes the pre-analysis plan, a document to
submit to OSF, Zenodo or an ethics committee.

``` r

render_report(d$instrument, output_file = "paired-plan.pdf", format = "pdf")
```

## 2. Collect

``` r

export_survey(d$instrument, "paired-survey.html",
              endpoint_url = "https://script.google.com/macros/s/.../exec")
export_google_sheet(d$instrument, sheet_url = "https://docs.google.com/spreadsheets/d/...")
```

## 3. Check

``` r

responses <- read_responses("paired-responses.csv", d$instrument,
                            respondent_id = "respondent_id")
sframe_quality_results(responses, d$instrument)
```

## 4. Analyse

[`run_analysis_plan()`](https://surveyframe.org/reference/run_analysis_plan.md)
runs the declared plan, as declared.

``` r

results <- run_analysis_plan(d$responses, d$instrument)
results
```

## 5. Report

``` r

render_report(d$instrument, d$responses, output_file = "paired-report.docx",
              format = "docx")
```

The report names the instrument’s hash, so a reader can check that the
questionnaire analysed is the one planned.

## Prefer to point and click?

The same 5 stages run in SurveyStudio. See [Run a study in
SurveyStudio](https://surveyframe.org/articles/run-a-study-in-surveystudio.md).
