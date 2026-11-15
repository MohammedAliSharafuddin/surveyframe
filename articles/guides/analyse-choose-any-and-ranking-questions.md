# How to analyse choose-any and ranking questions

Summarise questions where respondents tick any options or put options in
order.

The example in this guide is *Which sessions, and why come at all?* A
study of which sessions attendees chose and why they came, from a
choose-any item and a ranking.

## In SurveyStudio

1.  In RStudio, open the **Addins** menu, choose **surveyframe: Try a
    demo** and pick `multi_response`.
2.  On **Design**, see the choose-any question, stored as 1 column per
    option, and the ranking question, stored as the order given.
3.  On **Design**, choose **Plan**. RQ1 counts each option ticked, RQ2
    tests whether the options differ in how often they were chosen
    (Cochran’s Q), and RQ3 summarises the ranks.
4.  On **Analyse**, run the plan.

## In R

``` r

d <- sframe_demo("multi_response")
results <- run_analysis_plan(d$responses, d$instrument)
```

## The research questions and what the report gives

| Research question | Method | What the report gives |
|----|----|----|
| Which sessions were best attended? | Descriptive statistics | The APA 7 sentence and a table, with a chart where the method has one |
| Do the sessions differ in how often they were chosen? | Cochran’s Q test | The APA 7 sentence and a table, with a chart where the method has one |
| What did attendees come for? | Descriptive statistics | The APA 7 sentence and a table, with a chart where the method has one |

Run the example in SurveyStudio or R to see the results, each marked as
demonstration data.

## Related

- [Questionnaire
  templates](https://surveyframe.org/articles/templates.md)
- [All how-to guides](https://surveyframe.org/articles/guides.md)
