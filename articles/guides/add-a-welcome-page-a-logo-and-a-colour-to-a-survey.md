# How to add a welcome page, a logo and a colour to a survey

Personalise a survey with a welcome page, your organisation’s logo and a
theme colour.

The example in this guide is *Event feedback, branded*. The event
feedback survey with the organiser’s welcome page, logo, colour and
thank-you page.

## In SurveyStudio

1.  In RStudio, open the **Addins** menu, choose **surveyframe: Try a
    demo** and pick `branded_survey`.
2.  On **Design**, choose **Title, welcome and thank-you pages** to edit
    the welcome text, the consent statement and the thank-you message.
3.  Open **Survey settings**. On **General**, set the theme colour and
    the submit label. On **Header**, add the institution name and upload
    the logo image.
4.  On **Preview**, check the survey as respondents will see it.

## In R

``` r

d <- sframe_demo("branded_survey")
d$instrument$render          # the welcome page, theme, logo and labels
export_survey(d$instrument, "survey.html")
```

## Related

- [Questionnaire
  templates](https://surveyframe.org/articles/templates.md)
- [All how-to guides](https://surveyframe.org/articles/guides.md)
