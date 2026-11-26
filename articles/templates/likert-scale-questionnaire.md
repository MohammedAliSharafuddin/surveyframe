# Likert scale questionnaire

A short questionnaire that measures 1 idea with a 4-item Likert scale,
including a reverse-worded item, and checks that the scale holds
together before its score is used. surveyframe gives you the
questionnaire, a pre-analysis plan to submit with your proposal, and an
APA 7 report.

## Preview the questionnaire

This is the questionnaire as respondents see it. It is a preview to try,
and it stores no answers. [Open the Likert scale questionnaire preview
in a new
tab](https://surveyframe.org/templates/likert_scale/preview.md).

## The example analysis plan

Before any data is collected, surveyframe writes the pre-analysis plan:
the study, the questionnaire, each research question with its
hypotheses, method and decision rule, and the fields a preregistration
still asks you to complete. [Read the Likert scale questionnaire
plan](https://surveyframe.org/templates/likert_scale/plan.md), or
[download the Likert scale questionnaire instrument
(.sframe)](https://surveyframe.org/templates/likert_scale/likert_scale.sframe)
to adapt it.

Methods it declares: Scale score descriptive statistics, Cronbach’s
alpha (internal consistency), McDonald’s omega (internal consistency),
Item diagnostics.

## What you get

The study in SurveyStudio, stage by stage: design, collect, check,
analyse and report.

![The Likert scale questionnaire study on the Design screen, with its
questions listed.](../../templates/likert_scale/design.png)![The Likert
scale questionnaire study on the Collect screen, which exports the
survey web page.](../../templates/likert_scale/collect.png)![The Likert
scale questionnaire study on the Quality screen, which checks the
responses.](../../templates/likert_scale/check.png)![The Likert scale
questionnaire study on the Analyse screen, with the declared
plan.](../../templates/likert_scale/analyse.png)![The Likert scale
questionnaire study on the Report screen, which exports the
report.](../../templates/likert_scale/report.png)

## Open this instrument in SurveyStudio

1.  Set up R, RStudio and surveyframe as [Get
    started](https://surveyframe.org/articles/start.md) shows.
2.  To explore the example with its demonstration responses, open
    RStudio’s **Addins** menu, choose **surveyframe: Try a demo** and
    pick `likert_scale`, which opens this template’s study.
3.  To make it your own study, download the instrument above, choose
    **surveyframe: Open analysis workspace** from the **Addins** menu,
    then **Open Instrument** in SurveyStudio’s left menu, and select the
    file.
4.  Adapt the questions on the **Design** screen and the research
    questions under **Plan**, press **Save to Studio**, then press
    **Download copy** on the **Report** screen to save your study.

## Questions

### Can I use this for my thesis?

Yes. Adapt the questions and review the analysis plan with your
supervisor before collecting answers. If you change the items, update
the scale and the plan to match.

### How do I check that my scale is reliable?

The plan declares Cronbach’s alpha and McDonald’s omega with a decision
rule, .70 or above, and item diagnostics that flag an item that sits
poorly with the rest.

### Can I run the whole study in SurveyStudio?

Yes. Install surveyframe, then choose Try a demo from RStudio’s Addins
menu, and the whole study opens in SurveyStudio.

## Optional R code

Open this study in R

``` r

d <- sframe_demo("likert_scale")
render_report(d$instrument)                 # the pre-analysis plan
results <- run_analysis_plan(d$responses, d$instrument)
```

## Related

- [All psychology and measurement
  templates](https://surveyframe.org/articles/templates.html#psychology)
- [Measurement model questionnaire (CFA and
  SEM)](https://surveyframe.org/articles/templates/measurement-model-questionnaire.md)
- [How-to guides](https://surveyframe.org/articles/guides.md)
