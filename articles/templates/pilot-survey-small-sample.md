# Pilot survey with a small sample

A pilot with 18 participants that answers the main study’s questions
with methods suited to a small sample: a rank-based comparison, an exact
test and a penalised logistic regression. surveyframe gives you the
questionnaire, the pre-analysis plan and the report.

## Preview the questionnaire

This is the questionnaire as respondents see it. It is a preview to try,
and it stores no answers. [Open the Pilot survey with a small sample
preview in a new
tab](https://surveyframe.org/templates/small_sample/preview.md).

## The example analysis plan

Before any data is collected, surveyframe writes the pre-analysis plan:
the study, the questionnaire, each research question with its
hypotheses, method and decision rule, and the fields a preregistration
still asks you to complete. [Read the Pilot survey with a small sample
plan](https://surveyframe.org/templates/small_sample/plan.md), or
[download the Pilot survey with a small sample instrument
(.sframe)](https://surveyframe.org/templates/small_sample/small_sample.sframe)
to adapt it.

Methods it declares: Mann-Whitney U test, Fisher’s exact test, Firth
logistic regression.

## What you get

The study in SurveyStudio, stage by stage: design, collect, check,
analyse and report.

![The Pilot survey with a small sample study on the Design screen, with
its questions listed.](../../templates/small_sample/design.png)![The
Pilot survey with a small sample study on the Collect screen, which
exports the survey web
page.](../../templates/small_sample/collect.png)![The Pilot survey with
a small sample study on the Quality screen, which checks the
responses.](../../templates/small_sample/check.png)![The Pilot survey
with a small sample study on the Analyse screen, with the declared
plan.](../../templates/small_sample/analyse.png)![The Pilot survey with
a small sample study on the Report screen, which exports the
report.](../../templates/small_sample/report.png)

## Open this instrument in SurveyStudio

1.  Set up R, RStudio and surveyframe as [Get
    started](https://surveyframe.org/articles/start.md) shows.
2.  To explore the example with its demonstration responses, open
    RStudio’s **Addins** menu, choose **surveyframe: Try a demo** and
    pick `small_sample`, which opens this template’s study.
3.  To make it your own study, download the instrument above, choose
    **surveyframe: Open analysis workspace** from the **Addins** menu,
    then **Open Instrument** in SurveyStudio’s left menu, and select the
    file.
4.  Adapt the questions on the **Design** screen and the research
    questions under **Plan**, press **Save to Studio**, then press
    **Download copy** on the **Report** screen to save your study.

## Questions

### Which tests suit fewer than 30 participants?

The example plan includes methods often considered for small samples:
the Mann-Whitney U test, Fisher’s exact test and Firth logistic
regression. Choose methods that fit your design, measurements and
assumptions, and the guide to small samples explains the example’s
choices.

### Should a pilot test hypotheses?

A pilot mainly checks the questionnaire and the procedure. Declaring the
tests in advance still shows which comparisons the main study should
power.

### Can I run the whole study in SurveyStudio?

Yes. The whole study opens in SurveyStudio from RStudio’s Addins menu.

## Optional R code

Open this study in R

``` r

d <- sframe_demo("small_sample")
render_report(d$instrument)                 # the pre-analysis plan
results <- run_analysis_plan(d$responses, d$instrument)
```

## Related

- [All research methods
  templates](https://surveyframe.org/articles/templates.html#research-methods)
- [Preparing a survey study for
  preregistration](https://surveyframe.org/articles/templates/pre-registered-survey-sealed-and-amended.md)
- [How-to guides](https://surveyframe.org/articles/guides.md)
