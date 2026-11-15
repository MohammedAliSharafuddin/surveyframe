# Training evaluation before and after

Compare the same participants’ confidence, and their willingness to
recommend a workshop, before and after the training. Plan the paired
comparisons before collecting responses. surveyframe gives you the
questionnaire, the plan and the report.

## Preview the questionnaire

This is the questionnaire as respondents see it. It is a preview to try,
and it stores no answers. [Open the Training evaluation before and after
preview in a new
tab](https://surveyframe.org/templates/paired/preview.md).

## The example analysis plan

Before any data is collected, surveyframe writes the pre-analysis plan:
the study, the questionnaire, each research question with its
hypotheses, method and decision rule, and the fields a preregistration
still asks you to complete. [Read the Training evaluation before and
after plan](https://surveyframe.org/templates/paired/plan.md), or
[download the Training evaluation before and after instrument
(.sframe)](https://surveyframe.org/templates/paired/paired.sframe) to
adapt it.

Methods it declares: Paired samples t-test, Wilcoxon signed-rank test,
McNemar test.

## What you get

The study in SurveyStudio, stage by stage: design, collect, check,
analyse and report.

![The Training evaluation before and after study on the Design screen,
with its questions listed.](../../templates/paired/design.png)![The
Training evaluation before and after study on the Collect screen, which
exports the survey web page.](../../templates/paired/collect.png)![The
Training evaluation before and after study on the Quality screen, which
checks the responses.](../../templates/paired/check.png)![The Training
evaluation before and after study on the Analyse screen, with the
declared plan.](../../templates/paired/analyse.png)![The Training
evaluation before and after study on the Report screen, which exports
the report.](../../templates/paired/report.png)

## Open this instrument in SurveyStudio

1.  Set up R, RStudio and surveyframe as [Get
    started](https://surveyframe.org/articles/start.md) shows.
2.  To explore the example with its demonstration responses, open
    RStudio’s **Addins** menu, choose **surveyframe: Try a demo** and
    pick `paired`, which opens this template’s study.
3.  To make it your own study, download the instrument above, choose
    **surveyframe: Open analysis workspace** from the **Addins** menu,
    then **Open Instrument** in SurveyStudio’s left menu, and select the
    file.
4.  Adapt the questions on the **Design** screen and the research
    questions under **Plan**, press **Save to Studio**, then press
    **Download copy** on the **Report** screen to save your study.

## Questions

### Why paired tests?

The same people answer before and after, so their answers are compared
with themselves: the paired t-test, the Wilcoxon signed-rank test and
McNemar’s test.

### Can I add a third time point?

Yes. With 3 or more measurements the plan uses a repeated measures ANOVA
or the Friedman test.

### Can I run the whole study in SurveyStudio?

Yes. The whole study opens in SurveyStudio from RStudio’s Addins menu.

## Optional R code

Open this study in R

``` r

d <- sframe_demo("paired")
render_report(d$instrument)                 # the pre-analysis plan
results <- run_analysis_plan(d$responses, d$instrument)
```

## Related

- [All education
  templates](https://surveyframe.org/articles/templates.html#education)
- [Course evaluation
  survey](https://surveyframe.org/articles/templates/course-evaluation-survey.md)
- [How-to guides](https://surveyframe.org/articles/guides.md)
