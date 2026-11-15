# How to check whether a Likert scale holds together

Check whether the items of a Likert scale measure 1 thing well enough to
combine into a score.

The example in this guide is *Was the event well organised?* A thesis
questionnaire measuring how well organised attendees found an event, on
a 4-item Likert scale with 1 reverse-worded item.

## In SurveyStudio

1.  In RStudio, open the **Addins** menu, choose **surveyframe: Try a
    demo** and pick `likert_scale`.
2.  On **Design**, select an item and check its **Scale** and
    **Reverse-scored** settings. Every item of the scale shares 1 choice
    set.
3.  Open **Reliability** to see the scale’s reliability and how each
    item relates to the rest.
4.  On **Analyse**, read the item diagnostics before reporting the scale
    score.

![The Design screen with the Was the event well organised? study
open.](../../templates/likert_scale/design.png)

The Design screen with the Was the event well organised? study open.

## In R

``` r

d <- sframe_demo("likert_scale")
sframe_get_scales(d$instrument)            # which items form the scale
scored <- score_scales(d$responses, d$instrument)
results <- run_analysis_plan(d$responses, d$instrument)
```

## The research questions and what the report gives

| Research question | Method | What the report gives |
|----|----|----|
| How does the scale score overall? | Descriptive statistics | The APA 7 sentence and a table, with a chart where the method has one |
| Is the scale internally consistent? | Cronbach’s alpha (internal consistency) | The APA 7 sentence and a table, with a chart where the method has one |
| Same question, omega rather than alpha. | McDonald’s omega (internal consistency) | The APA 7 sentence and a table, with a chart where the method has one |
| Does any item sit poorly with the rest? | Item diagnostics | The APA 7 sentence and a table, with a chart where the method has one |

Run the example in SurveyStudio or R to see the results, each marked as
demonstration data.

## Related

- [Questionnaire
  templates](https://surveyframe.org/articles/templates.md)
- [All how-to guides](https://surveyframe.org/articles/guides.md)
