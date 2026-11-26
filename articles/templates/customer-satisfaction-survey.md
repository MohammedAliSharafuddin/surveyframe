# Customer satisfaction survey

A customer study of return intention: whether customers who use a
service more come back, and how that use relates to their satisfaction
and the offer they prefer. surveyframe gives you the questionnaire, a
plan with logistic regressions declared in advance, and the report.

## Preview the questionnaire

This is the questionnaire as respondents see it. It is a preview to try,
and it stores no answers. [Open the Customer satisfaction survey preview
in a new tab](https://surveyframe.org/templates/logistic/preview.md).

## The example analysis plan

Before any data is collected, surveyframe writes the pre-analysis plan:
the study, the questionnaire, each research question with its
hypotheses, method and decision rule, and the fields a preregistration
still asks you to complete. [Read the Customer satisfaction survey
plan](https://surveyframe.org/templates/logistic/plan.md), or [download
the Customer satisfaction survey instrument
(.sframe)](https://surveyframe.org/templates/logistic/logistic.sframe)
to adapt it.

Methods it declares: Binary logistic regression, Ordinal logistic
regression, Multinomial logistic regression.

## What you get

The study in SurveyStudio, stage by stage: design, collect, check,
analyse and report.

![The Customer satisfaction survey study on the Design screen, with its
questions listed.](../../templates/logistic/design.png)![The Customer
satisfaction survey study on the Collect screen, which exports the
survey web page.](../../templates/logistic/collect.png)![The Customer
satisfaction survey study on the Quality screen, which checks the
responses.](../../templates/logistic/check.png)![The Customer
satisfaction survey study on the Analyse screen, with the declared
plan.](../../templates/logistic/analyse.png)![The Customer satisfaction
survey study on the Report screen, which exports the
report.](../../templates/logistic/report.png)

## Open this instrument in SurveyStudio

1.  Set up R, RStudio and surveyframe as [Get
    started](https://surveyframe.org/articles/start.md) shows.
2.  To explore the example with its demonstration responses, open
    RStudio’s **Addins** menu, choose **surveyframe: Try a demo** and
    pick `logistic`, which opens this template’s study.
3.  To make it your own study, download the instrument above, choose
    **surveyframe: Open analysis workspace** from the **Addins** menu,
    then **Open Instrument** in SurveyStudio’s left menu, and select the
    file.
4.  Adapt the questions on the **Design** screen and the research
    questions under **Plan**, press **Save to Studio**, then press
    **Download copy** on the **Report** screen to save your study.

## Questions

### Which model predicts a yes or no answer?

A binary logistic regression, with the odds ratio of each predictor and
its confidence interval.

### Can I predict a rating instead?

Yes. An ordinal logistic regression predicts an ordered rating, and a
multinomial model a choice among 3 or more options.

### Can my team use it without writing code?

Yes. SurveyStudio runs the whole study in a window started from
RStudio’s Addins menu. R and RStudio need to be installed, as Get
started shows.

## Optional R code

Open this study in R

``` r

d <- sframe_demo("logistic")
render_report(d$instrument)                 # the pre-analysis plan
results <- run_analysis_plan(d$responses, d$instrument)
```

## Related

- [All business
  templates](https://surveyframe.org/articles/templates.html#business)
- [Employee engagement
  survey](https://surveyframe.org/articles/templates/employee-engagement-survey.md)
- [Supplier and venue selection (decision
  making)](https://surveyframe.org/articles/templates/supplier-and-venue-selection.md)
- [How-to guides](https://surveyframe.org/articles/guides.md)
