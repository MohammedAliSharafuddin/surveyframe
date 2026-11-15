# How to test whether 2 categorical answers are associated

Test whether 2 categorical answers are associated.

The example in this guide is *What do attendees prefer?* A study of
whether attendance format is associated with the session type attendees
value most.

## In SurveyStudio

1.  In RStudio, open the **Addins** menu, choose **surveyframe: Try a
    demo** and pick `categorical`.
2.  On **Design**, choose **Plan**. RQ1 cross-tabulates format and
    preference, RQ2 tests the association with chi-square, and RQ3 uses
    Fisher’s exact test for small cell counts.
3.  On **Analyse**, run the plan and read the assumption notes before
    choosing the test to report.

## In R

``` r

d <- sframe_demo("categorical")
results <- run_analysis_plan(d$responses, d$instrument)
```

## The research questions and what the report gives

| Research question | Method | What the report gives |
|----|----|----|
| How do format and preference cross-tabulate? | Cross-tabulation | The APA 7 sentence and a table, with a chart where the method has one |
| Are format and preference associated? | Cross-tabulation | The APA 7 sentence and a table, with a chart where the method has one |
| Are format and preference associated, on an exact test for the small cell? | Fisher’s exact test | The APA 7 sentence and a table, with a chart where the method has one |

Run the example in SurveyStudio or R to see the results, each marked as
demonstration data.

## Related

- [Questionnaire
  templates](https://surveyframe.org/articles/templates.md)
- [All how-to guides](https://surveyframe.org/articles/guides.md)
