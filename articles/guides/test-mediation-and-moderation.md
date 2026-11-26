# How to test mediation and moderation

Test whether a variable carries an effect (mediation) or changes its
strength (moderation).

The example in this guide is *Workload, stress and wellbeing*. An
employee wellbeing study of whether stress carries the effect of
workload to wellbeing, and whether a manager’s support weakens the link
from workload to stress.

## In SurveyStudio

1.  In RStudio, open the **Addins** menu, choose **surveyframe: Try a
    demo** and pick `mediation_moderation`.
2.  On **Design**, choose **Plan**. RQ1 sets workload as the predictor,
    stress as the mediator and wellbeing as the outcome. RQ2 sets
    manager support as the moderator of workload on stress.
3.  On **Analyse**, run the plan and read the indirect effect with its
    bootstrap confidence interval.

## In R

``` r

d <- sframe_demo("mediation_moderation")
results <- run_analysis_plan(d$responses, d$instrument)
```

## The research questions and what the report gives

| Research question | Method | What the report gives |
|----|----|----|
| Does stress carry the effect of workload to wellbeing? | Mediation analysis | The APA 7 sentence and a table, with a chart where the method has one |
| Does manager support weaken the link from workload to stress? | Moderation analysis | The APA 7 sentence and a table, with a chart where the method has one |

Run the example in SurveyStudio or R to see the results, each marked as
demonstration data.

## Related

- [Questionnaire
  templates](https://surveyframe.org/articles/templates.md)
- [All how-to guides](https://surveyframe.org/articles/guides.md)
