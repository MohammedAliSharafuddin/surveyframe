# Supplier and venue selection (decision making)

Compare candidate suppliers or venues using the criteria your committee
values. Record the criteria and the judgements, then review the rankings
your selected methods produce. surveyframe gives you the questionnaire,
the analysis plan and the report.

## Preview the questionnaire

This is the questionnaire as respondents see it. It is a preview to try,
and it stores no answers. [Open the Supplier and venue selection
(decision making) preview in a new
tab](https://surveyframe.org/templates/mcdm_choice/preview.md).

## The example analysis plan

Before any data is collected, surveyframe writes the pre-analysis plan:
the study, the questionnaire, each research question with its
hypotheses, method and decision rule, and the fields a preregistration
still asks you to complete. [Read the Supplier and venue selection
(decision making)
plan](https://surveyframe.org/templates/mcdm_choice/plan.md), or
[download the Supplier and venue selection (decision making) instrument
(.sframe)](https://surveyframe.org/templates/mcdm_choice/mcdm_choice.sframe)
to adapt it.

Methods it declares: Analytic hierarchy process (AHP), Analytic network
process (ANP), DEMATEL, TOPSIS, VIKOR, MOORA, SMART, WASPAS, PROMETHEE,
ELECTRE.

## What you get

The study in SurveyStudio, stage by stage: design, collect, check,
analyse and report.

![The Supplier and venue selection (decision making) study on the Design
screen, with its questions
listed.](../../templates/mcdm_choice/design.png)![The Supplier and venue
selection (decision making) study on the Collect screen, which exports
the survey web page.](../../templates/mcdm_choice/collect.png)![The
Supplier and venue selection (decision making) study on the Quality
screen, which checks the
responses.](../../templates/mcdm_choice/check.png)![The Supplier and
venue selection (decision making) study on the Analyse screen, with the
declared plan.](../../templates/mcdm_choice/analyse.png)![The Supplier
and venue selection (decision making) study on the Report screen, which
exports the report.](../../templates/mcdm_choice/report.png)

## Open this instrument in SurveyStudio

1.  Set up R, RStudio and surveyframe as [Get
    started](https://surveyframe.org/articles/start.md) shows.
2.  To explore the example with its demonstration responses, open
    RStudio’s **Addins** menu, choose **surveyframe: Try a demo** and
    pick `mcdm_choice`, which opens this template’s study.
3.  To make it your own study, download the instrument above, choose
    **surveyframe: Open analysis workspace** from the **Addins** menu,
    then **Open Instrument** in SurveyStudio’s left menu, and select the
    file.
4.  Adapt the questions on the **Design** screen and the research
    questions under **Plan**, press **Save to Studio**, then press
    **Download copy** on the **Report** screen to save your study.

## Questions

### Which methods rank the options?

AHP and ANP weight the criteria, DEMATEL shows which drive the others,
and TOPSIS, VIKOR, MOORA, SMART, WASPAS, PROMETHEE and ELECTRE rank the
options.

### Are the judgements consistent?

The plan accepts pairwise judgements when the consistency ratio is below
.10.

### Can a committee answer it?

Yes. Each member answers the same questionnaire, and the judgements are
combined.

## Optional R code

Open this study in R

``` r

d <- sframe_demo("mcdm_choice")
render_report(d$instrument)                 # the pre-analysis plan
results <- run_analysis_plan(d$responses, d$instrument)
```

## Related

- [All business
  templates](https://surveyframe.org/articles/templates.html#business)
- [Customer satisfaction
  survey](https://surveyframe.org/articles/templates/customer-satisfaction-survey.md)
- [Employee engagement
  survey](https://surveyframe.org/articles/templates/employee-engagement-survey.md)
- [How-to guides](https://surveyframe.org/articles/guides.md)
