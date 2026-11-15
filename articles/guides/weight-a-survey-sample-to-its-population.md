# How to weight a survey sample to its population

Apply survey weights so your summaries describe the population the
sample was drawn from.

The example in this guide is *Satisfaction across regions*. A resident
satisfaction survey whose sample over-represents 1 region, weighted back
to the population’s regional shares.

## In SurveyStudio

1.  In RStudio, open the **Addins** menu, choose **surveyframe: Try a
    demo** and pick `weighted_survey`.
2.  On **Responses**, see the weight column, `survey_weight`, beside the
    answers.
3.  On **Design**, choose **Plan** and open RQ3. The weight column is
    set in its weights role. RQ1 shows the sample before weighting and
    RQ2 the population after.
4.  On **Analyse**, run the plan and report which results are weighted.

## In R

``` r

d <- sframe_demo("weighted_survey")
summary(d$responses$survey_weight)
results <- run_analysis_plan(d$responses, d$instrument)
```

## The research questions and what the report gives

| Research question | Method | What the report gives |
|----|----|----|
| How is the sample spread across regions, before weighting? | Frequencies and percentages | The APA 7 sentence and a table, with a chart where the method has one |
| How is the population spread across regions, after weighting? | Frequencies and percentages | The APA 7 sentence and a table, with a chart where the method has one |
| How satisfied are residents, weighted to the population? | Descriptive statistics | The APA 7 sentence and a table, with a chart where the method has one |
| Is region associated with recommending the service, weighted? | Cross-tabulation | The APA 7 sentence and a table, with a chart where the method has one |

Run the example in SurveyStudio or R to see the results, each marked as
demonstration data.

## Related

- [Questionnaire
  templates](https://surveyframe.org/articles/templates.md)
- [All how-to guides](https://surveyframe.org/articles/guides.md)
