# How to show a survey 1 question at a time

Present your survey 1 question at a time, with a progress bar.

The example in this guide is *Event feedback, one question at a time*.
The event feedback survey shown one question at a time, for respondents
on a phone.

## In SurveyStudio

1.  In RStudio, open the **Addins** menu, choose **surveyframe: Try a
    demo** and pick `conversational_survey`.
2.  Open **Survey settings**. On **General**, set **Presentation mode**
    to Conversational: one question at a time.
3.  On **Preview**, step through the questions with the Next button.

## In R

``` r

d <- sframe_demo("conversational_survey")
d$instrument$render$mode     # "conversational"
export_survey(d$instrument, "survey.html")
```

## Related

- [Questionnaire
  templates](https://surveyframe.org/articles/templates.md)
- [All how-to guides](https://surveyframe.org/articles/guides.md)
