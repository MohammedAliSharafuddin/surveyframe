# surveyframe and Google Forms

Google Forms is Google’s form builder. Its responses can be viewed in
the form or stored in a linked Google Sheet, and downloaded as a CSV
file.

surveyframe is a free R package (MIT, on CRAN) for the whole research
workflow around a survey: the questionnaire and its analysis plan, the
collection, the checks, the planned analyses and the APA 7 report.

## What the surveyframe workflow provides

- An analysis plan written before the data, with hypotheses and decision
  rules, saved in the questionnaire file.
- A pre-analysis plan to submit to OSF, Zenodo or an ethics committee.
- A hash anyone can check at
  [surveyframe.org/verify](https://surveyframe.org/verify/), and
  amendments recorded with their reasons.
- Quality checks, scale reliability, the planned analyses and a report
  in APA 7, in SurveyStudio or in R.

## Using Google Forms with surveyframe

You can collect responses with Google Forms and analyse them with
surveyframe. Describe the questionnaire as a surveyframe instrument,
then prepare the export so that
[`read_responses()`](https://surveyframe.org/reference/read_responses.md)
can check it against the instrument:

1.  Download the responses as a CSV file from the form’s Responses view.
2.  Name each column by the matching item id. The export heads each
    column with the question’s text.
3.  Where the instrument stores choice codes, change each answer’s text
    to its code.
4.  Declare any column outside the instrument, such as the time of
    submission, in `meta_cols`.

``` r

raw <- read.csv("answers.csv", check.names = FALSE)
names(raw) <- c("submitted", "visit_type", "satisfaction")  # each column named by its item id, in order
raw$visit_type <- c("First visit" = "first", "Returning" = "returning")[raw$visit_type]  # answer text to choice codes, where needed
responses <- read_responses(raw, instrument, meta_cols = "submitted")
results <- run_analysis_plan(responses, instrument)
```

The planned analyses and the report then run on these responses.

## Sources

Checked on 15 November 2026 against Google Forms’s own documentation:

- [Choose where to save form
  responses](https://support.google.com/docs/answer/2917686)
- [View and manage form
  responses](https://support.google.com/docs/answer/139706)

## Related

- [Choosing a survey tool for
  research](https://surveyframe.org/articles/learn/choosing-a-survey-tool.md)
- [Get started](https://surveyframe.org/articles/start.md)
