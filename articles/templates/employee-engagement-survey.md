# Employee engagement survey

An engagement survey of 8 items written to measure 2 dimensions, how
work is organised and the content of the work, with a check that
employees’ answers support 2 scores. surveyframe gives you the
questionnaire, the analysis plan and the report.

## Preview the questionnaire

This is the questionnaire as respondents see it. It is a preview to try,
and it stores no answers. [Open the Employee engagement survey preview
in a new
tab](https://surveyframe.org/templates/factor_structure/preview.md).

## The example analysis plan

Before any data is collected, surveyframe writes the pre-analysis plan:
the study, the questionnaire, each research question with its
hypotheses, method and decision rule, and the fields a preregistration
still asks you to complete. [Read the Employee engagement survey
plan](https://surveyframe.org/templates/factor_structure/plan.md), or
[download the Employee engagement survey instrument
(.sframe)](https://surveyframe.org/templates/factor_structure/factor_structure.sframe)
to adapt it.

Methods it declares: Factorability checks (KMO and Bartlett’s test),
Exploratory factor analysis.

## What you get

The study in SurveyStudio, stage by stage: design, collect, check,
analyse and report.

![The Employee engagement survey study on the Design screen, with its
questions listed.](../../templates/factor_structure/design.png)![The
Employee engagement survey study on the Collect screen, which exports
the survey web page.](../../templates/factor_structure/collect.png)![The
Employee engagement survey study on the Quality screen, which checks the
responses.](../../templates/factor_structure/check.png)![The Employee
engagement survey study on the Analyse screen, with the declared
plan.](../../templates/factor_structure/analyse.png)![The Employee
engagement survey study on the Report screen, which exports the
report.](../../templates/factor_structure/report.png)

## Open this instrument in SurveyStudio

1.  Set up R, RStudio and surveyframe as [Get
    started](https://surveyframe.org/articles/start.md) shows.
2.  To explore the example with its demonstration responses, open
    RStudio’s **Addins** menu, choose **surveyframe: Try a demo** and
    pick `factor_structure`, which opens this template’s study.
3.  To make it your own study, download the instrument above, choose
    **surveyframe: Open analysis workspace** from the **Addins** menu,
    then **Open Instrument** in SurveyStudio’s left menu, and select the
    file.
4.  Adapt the questions on the **Design** screen and the research
    questions under **Plan**, press **Save to Studio**, then press
    **Download copy** on the **Report** screen to save your study.

## Questions

### How do I know the survey measures 2 things?

The plan checks that the data suit factor analysis, then runs an
exploratory factor analysis that shows which items load on which factor.

### Can I report 2 scores?

Yes, once the factor analysis supports them. Each scale’s score and
reliability are reported.

### Can answers stay anonymous?

The example omits a name field, and its report summarises the group.
Review the identifying information you collect and who can access the
responses in your own study.

## Optional R code

Open this study in R

``` r

d <- sframe_demo("factor_structure")
render_report(d$instrument)                 # the pre-analysis plan
results <- run_analysis_plan(d$responses, d$instrument)
```

## Related

- [All business
  templates](https://surveyframe.org/articles/templates.html#business)
- [Customer satisfaction
  survey](https://surveyframe.org/articles/templates/customer-satisfaction-survey.md)
- [Supplier and venue selection (decision
  making)](https://surveyframe.org/articles/templates/supplier-and-venue-selection.md)
- [How-to guides](https://surveyframe.org/articles/guides.md)
