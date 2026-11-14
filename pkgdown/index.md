<img src="man/figures/readme-logo.png" align="right" width="200" alt="surveyframe" />

# Plan, run and report survey research, with or without code

surveyframe takes a survey study from the questionnaire to the APA 7 report:
design the instrument and its analysis plan, collect the answers, check them,
run the planned analyses and write the report, in SurveyStudio or in R.

[![CRAN status](https://www.r-pkg.org/badges/version/surveyframe)](https://CRAN.R-project.org/package=surveyframe)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/surveyframe)](https://CRAN.R-project.org/package=surveyframe)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

APA 7 reports · Pre-analysis plans ready to preregister · Instruments sealed
with a hash anyone can [verify](https://surveyframe.org/verify/)

## Start from a template

**Psychology and measurement.**
[Likert scale questionnaire](articles/templates/likert-scale-questionnaire.html),
[Measurement model questionnaire (CFA and SEM)](articles/templates/measurement-model-questionnaire.html).

**Education.**
[Course evaluation survey](articles/templates/course-evaluation-survey.html),
[Training evaluation before and after](articles/templates/training-evaluation-before-and-after.html).

**Business.**
[Customer satisfaction survey](articles/templates/customer-satisfaction-survey.html),
[Employee engagement survey](articles/templates/employee-engagement-survey.html),
[Supplier and venue selection (decision making)](articles/templates/supplier-and-venue-selection.html).

**Events and tourism.**
[Open-ended feedback survey](articles/templates/open-ended-feedback-survey.html).

**Research methods.**
[Pilot survey with a small sample](articles/templates/pilot-survey-small-sample.html),
[Pre-registered survey sealed and amended](articles/templates/pre-registered-survey-sealed-and-amended.html).

[All questionnaire templates](articles/templates.html)

## How it works

1. **Design** the questionnaire and declare the analysis plan, with
   hypotheses and decision rules, before any data arrives.
2. **Collect** the answers with a survey file and a Google Sheet you own.
3. **Check** them for failed attention checks, speeding, straight-lining and
   missing answers.
4. **Analyse** with the plan as declared. A later change is recorded as an
   amendment.
5. **Report** in APA 7, as HTML, Word, PDF or OpenDocument.

[Two ways to run a study](articles/two-ways-to-run-a-study.html) shows each
stage in SurveyStudio and in R.

## Start in 2 steps

1. In R: `install.packages("surveyframe")`
2. In RStudio, open the **Addins** menu and choose **surveyframe: Try a demo**.

[Get started](articles/start.html)

## For R users

```r
d <- sframe_demo("first_survey")
```

Then the [Reference](reference/index.html), the
[demos](articles/learn-by-example.html) and the [changelog](news/index.html).
