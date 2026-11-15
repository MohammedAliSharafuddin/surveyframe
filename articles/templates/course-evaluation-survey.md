# Course evaluation survey

A course evaluation in which students rate each part of a course on 1
grid, compared between students who took it in person and online.
surveyframe gives you the questionnaire, the analysis plan and a report
for the teaching team.

## Preview the questionnaire

This is the questionnaire as respondents see it. It is a preview to try,
and it stores no answers. [Open the Course evaluation survey preview in
a new tab](https://surveyframe.org/templates/matrix_likert/preview.md).

## The example analysis plan

Before any data is collected, surveyframe writes the pre-analysis plan:
the study, the questionnaire, each research question with its
hypotheses, method and decision rule, and the fields a preregistration
still asks you to complete. [Read the Course evaluation survey
plan](https://surveyframe.org/templates/matrix_likert/plan.md), or
[download the Course evaluation survey instrument
(.sframe)](https://surveyframe.org/templates/matrix_likert/matrix_likert.sframe)
to adapt it.

Methods it declares: Descriptive statistics, Frequencies and
percentages, Cross-tabulation.

## What you get

The study in SurveyStudio, stage by stage: design, collect, check,
analyse and report.

![The Course evaluation survey study on the Design screen, with its
questions listed.](../../templates/matrix_likert/design.png)![The Course
evaluation survey study on the Collect screen, which exports the survey
web page.](../../templates/matrix_likert/collect.png)![The Course
evaluation survey study on the Quality screen, which checks the
responses.](../../templates/matrix_likert/check.png)![The Course
evaluation survey study on the Analyse screen, with the declared
plan.](../../templates/matrix_likert/analyse.png)![The Course evaluation
survey study on the Report screen, which exports the
report.](../../templates/matrix_likert/report.png)

## Open this instrument in SurveyStudio

1.  Set up R, RStudio and surveyframe as [Get
    started](https://surveyframe.org/articles/start.md) shows.
2.  To explore the example with its demonstration responses, open
    RStudio’s **Addins** menu, choose **surveyframe: Try a demo** and
    pick `matrix_likert`, which opens this template’s study.
3.  To make it your own study, download the instrument above, choose
    **surveyframe: Open analysis workspace** from the **Addins** menu,
    then **Open Instrument** in SurveyStudio’s left menu, and select the
    file.
4.  Adapt the questions on the **Design** screen and the research
    questions under **Plan**, press **Save to Studio**, then press
    **Download copy** on the **Report** screen to save your study.

## Questions

### Can I change the parts of the course?

Yes. Edit the rows of the grid in SurveyStudio’s Design screen. Each row
becomes its own column in the data.

### Can students answer anonymously?

This example omits a name field and generates a response id. Review the
remaining questions and your collection settings when you design the
study’s privacy arrangements.

### How do I collect the answers?

Download the survey as 1 HTML file from the Collect screen and share it,
with a free Google Sheet collecting the answers.

## Optional R code

Open this study in R

``` r

d <- sframe_demo("matrix_likert")
render_report(d$instrument)                 # the pre-analysis plan
results <- run_analysis_plan(d$responses, d$instrument)
```

## Related

- [All education
  templates](https://surveyframe.org/articles/templates.html#education)
- [Training evaluation before and
  after](https://surveyframe.org/articles/templates/training-evaluation-before-and-after.md)
- [How-to guides](https://surveyframe.org/articles/guides.md)
