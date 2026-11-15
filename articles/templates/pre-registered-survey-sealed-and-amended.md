# Preparing a survey study for preregistration

A survey study whose instrument and analysis plan are saved with a hash
before data collection, with any later change recorded as a disclosed
amendment. surveyframe writes a pre-analysis plan for you to complete
and register on OSF or Zenodo, and a report that names the instrument it
analysed.

## Preview the questionnaire

This is the questionnaire as respondents see it. It is a preview to try,
and it stores no answers. [Open the Preparing a survey study for
preregistration preview in a new
tab](https://surveyframe.org/templates/verification/preview.md).

## The example analysis plan

Before any data is collected, surveyframe writes the pre-analysis plan:
the study, the questionnaire, each research question with its
hypotheses, method and decision rule, and the fields a preregistration
still asks you to complete. [Read the Preparing a survey study for
preregistration
plan](https://surveyframe.org/templates/verification/plan.md), or
[download the Preparing a survey study for preregistration instrument
(.sframe)](https://surveyframe.org/templates/verification/verification.sframe)
to adapt it.

Methods it declares: Frequencies and percentages, Descriptive
statistics, Missing-data summary, Response quality checks.

## What you get

The study in SurveyStudio, stage by stage: design, collect, check,
analyse and report.

![The Preparing a survey study for preregistration study on the Design
screen, with its questions
listed.](../../templates/verification/design.png)![The Preparing a
survey study for preregistration study on the Collect screen, which
exports the survey web
page.](../../templates/verification/collect.png)![The Preparing a survey
study for preregistration study on the Quality screen, which checks the
responses.](../../templates/verification/check.png)![The Preparing a
survey study for preregistration study on the Analyse screen, with the
declared plan.](../../templates/verification/analyse.png)![The Preparing
a survey study for preregistration study on the Report screen, which
exports the report.](../../templates/verification/report.png)

## Open this instrument in SurveyStudio

1.  Set up R, RStudio and surveyframe as [Get
    started](https://surveyframe.org/articles/start.md) shows.
2.  To explore the example with its demonstration responses, open
    RStudio’s **Addins** menu, choose **surveyframe: Try a demo** and
    pick `verification`, which opens this template’s study.
3.  To make it your own study, download the instrument above, choose
    **surveyframe: Open analysis workspace** from the **Addins** menu,
    then **Open Instrument** in SurveyStudio’s left menu, and select the
    file.
4.  Adapt the questions on the **Design** screen and the research
    questions under **Plan**, press **Save to Studio**, then press
    **Download copy** on the **Report** screen to save your study.

## Questions

### How do I preregister the plan on OSF?

Export the pre-analysis plan from SurveyStudio’s Report screen, or with
render_report() and no data. Complete the fields it lists under To
complete before submission, then upload it with the .sframe file. The
plan names the file’s hash.

### How does a reader check the questionnaire?

Anyone can check the .sframe file at surveyframe.org/verify: the page
reports whether it matches the hash recorded when it was saved, and
reads its disclosed amendments. To identify the registered version,
compare the hash with the one in the registered plan.

### What if I must change the questionnaire?

Record the change as an amendment, with its reason and a deviation
report. The amendment log stays in the file.

## Optional R code

Open this study in R

``` r

d <- sframe_demo("verification")
render_report(d$instrument)                 # the pre-analysis plan
results <- run_analysis_plan(d$responses, d$instrument)
```

## Related

- [All research methods
  templates](https://surveyframe.org/articles/templates.html#research-methods)
- [Pilot survey with a small
  sample](https://surveyframe.org/articles/templates/pilot-survey-small-sample.md)
- [How-to guides](https://surveyframe.org/articles/guides.md)
