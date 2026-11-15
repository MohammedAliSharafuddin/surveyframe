# Open-ended feedback survey

A feedback survey of what worked and what to change, analysed as text:
frequent words and phrases, words in context, sentiment and topics.
surveyframe gives you the questionnaire, the analysis plan and the
report.

## Preview the questionnaire

This is the questionnaire as respondents see it. It is a preview to try,
and it stores no answers. [Open the Open-ended feedback survey preview
in a new tab](https://surveyframe.org/templates/open_text/preview.md).

## The example analysis plan

Before any data is collected, surveyframe writes the pre-analysis plan:
the study, the questionnaire, each research question with its
hypotheses, method and decision rule, and the fields a preregistration
still asks you to complete. [Read the Open-ended feedback survey
plan](https://surveyframe.org/templates/open_text/plan.md), or [download
the Open-ended feedback survey instrument
(.sframe)](https://surveyframe.org/templates/open_text/open_text.sframe)
to adapt it.

Methods it declares: Word frequencies, Phrase frequencies, Words in
context, Word co-occurrence, Word co-occurrence network, Sentiment
analysis, Document-feature matrix, Topic model (LDA), Structural topic
model.

## What you get

The study in SurveyStudio, stage by stage: design, collect, check,
analyse and report.

![The Open-ended feedback survey study on the Design screen, with its
questions listed.](../../templates/open_text/design.png)![The Open-ended
feedback survey study on the Collect screen, which exports the survey
web page.](../../templates/open_text/collect.png)![The Open-ended
feedback survey study on the Quality screen, which checks the
responses.](../../templates/open_text/check.png)![The Open-ended
feedback survey study on the Analyse screen, with the declared
plan.](../../templates/open_text/analyse.png)![The Open-ended feedback
survey study on the Report screen, which exports the
report.](../../templates/open_text/report.png)

## Open this instrument in SurveyStudio

1.  Set up R, RStudio and surveyframe as [Get
    started](https://surveyframe.org/articles/start.md) shows.
2.  To explore the example with its demonstration responses, open
    RStudio’s **Addins** menu, choose **surveyframe: Try a demo** and
    pick `open_text`, which opens this template’s study.
3.  To make it your own study, download the instrument above, choose
    **surveyframe: Open analysis workspace** from the **Addins** menu,
    then **Open Instrument** in SurveyStudio’s left menu, and select the
    file.
4.  Adapt the questions on the **Design** screen and the research
    questions under **Plan**, press **Save to Studio**, then press
    **Download copy** on the **Report** screen to save your study.

## Questions

### What can surveyframe do with open answers?

Explore recurring words, phrases and topics, then read the original
responses in context. The methods include word and phrase counts,
keywords in context, words that appear together, sentiment, and topic
models, which group answers by the themes they share.

### Can I compare groups?

Yes. The plan can compare what in-person and online respondents write.

### How does it help with reading the answers?

It shows where to look first, and the report keeps the quotes that
represent each topic, so you read the answers with a map.

## Optional R code

Open this study in R

``` r

d <- sframe_demo("open_text")
render_report(d$instrument)                 # the pre-analysis plan
results <- run_analysis_plan(d$responses, d$instrument)
```

## Related

- [All events and tourism
  templates](https://surveyframe.org/articles/templates.html#events-tourism)
- [How-to guides](https://surveyframe.org/articles/guides.md)
