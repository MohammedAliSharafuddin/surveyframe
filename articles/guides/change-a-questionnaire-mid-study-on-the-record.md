# How to change a questionnaire mid-study, on the record

Change a questionnaire during a study and record the change with its
reason.

The example in this guide is *Event feedback*. A short feedback survey
for a one-day professional event, run to describe who attended and to
check the quality of the answers before the programme is planned again.

## In SurveyStudio

1.  In RStudio, open the **Addins** menu, choose **surveyframe: Try a
    demo** and pick `instrument_revision`.
2.  Open **Amendments** to see the amendment log: every disclosed
    change, oldest first, with its reason.
3.  To change your own questionnaire, choose **Edit in Design** on
    **Amendments**, make the change, and give the amendment details
    SurveyStudio asks for. A revised file made outside SurveyStudio
    comes in through **Import an externally revised version**.
4.  The report lists every recorded amendment under Reproducibility.

## In R

``` r

d <- sframe_demo("instrument_revision")
sframe_get_amendments(d$instrument)
# Your own change: amend_sframe(previous, revised, reason_code, reason_text)
```

## Related

- [Questionnaire
  templates](https://surveyframe.org/articles/templates.md)
- [All how-to guides](https://surveyframe.org/articles/guides.md)
