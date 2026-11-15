# How to predict a yes or no, an ordered rating or a choice

Choose and run a model for an outcome that is a yes or no, an ordered
rating or a choice between categories.

The example in this guide is *Will they come back?* A customer
return-intention study: whether more use of a service predicts that
customers return, how satisfied they are and which offer they prefer.

## In SurveyStudio

1.  In RStudio, open the **Addins** menu, choose **surveyframe: Try a
    demo** and pick `logistic`.
2.  On **Design**, choose **Plan**. RQ1 predicts returning, a yes or no
    (binary logistic). RQ2 predicts satisfaction, an ordered rating
    (ordinal logistic). RQ3 predicts the preferred session type, a
    choice (multinomial logistic).
3.  On **Analyse**, run the plan and report the odds ratios with their
    intervals.

![The Design screen with the Will they come back? study
open.](../../templates/logistic/design.png)

The Design screen with the Will they come back? study open.

## In R

``` r

d <- sframe_demo("logistic")
results <- run_analysis_plan(d$responses, d$instrument)
```

## The research questions and what the report gives

| Research question | Method | What the report gives |
|----|----|----|
| Does using the service more predict returning? | Binary logistic regression | The APA 7 sentence and a table, with a chart where the method has one |
| And does it predict how satisfied they were? | Ordinal logistic regression | The APA 7 sentence and a table, with a chart where the method has one |
| And which session type they prefer? | Multinomial logistic regression | The APA 7 sentence and a table, with a chart where the method has one |

Run the example in SurveyStudio or R to see the results, each marked as
demonstration data.

## Related

- [Questionnaire
  templates](https://surveyframe.org/articles/templates.md)
- [All how-to guides](https://surveyframe.org/articles/guides.md)
