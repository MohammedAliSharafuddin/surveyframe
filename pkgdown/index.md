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

## Start from a study

**Students and thesis supervisors.**
[Thesis questionnaire with a Likert scale](articles/studies/thesis-questionnaire-likert-scale.html),
[Pilot study with a small sample](articles/studies/pilot-study-small-sample.html).

**University and teaching evaluation.**
[Course evaluation survey](articles/studies/course-evaluation-survey.html),
[Pre and post training evaluation](articles/studies/pre-post-training-evaluation.html).

**Organisations.**
[Customer satisfaction and return intention](articles/studies/customer-satisfaction-return-intention.html),
[Employee engagement survey](articles/studies/employee-engagement-survey.html),
[Choosing between options](articles/studies/choosing-between-options.html),
[Open-ended feedback](articles/studies/open-ended-feedback.html).

**Research labs.**
[Pre-registered survey study](articles/studies/preregistered-survey-study.html),
[Measurement and structural model study](articles/studies/measurement-structural-model.html).

[All studies](articles/studies.html)

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
