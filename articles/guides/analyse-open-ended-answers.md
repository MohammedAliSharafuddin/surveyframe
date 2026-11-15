# How to analyse open-ended answers

Explore what respondents wrote in open-ended answers: the frequent
words, how a word is used, the topics and the tone.

The example in this guide is *What worked, and what to change*. An
open-ended feedback study: what attendees say worked and what to change,
analysed as text.

## In SurveyStudio

1.  In RStudio, open the **Addins** menu, choose **surveyframe: Try a
    demo** and pick `open_text`.
2.  On **Design**, choose **Plan** and pick a text question for each
    research question: word and word pair counts, a key word in context,
    words that appear together, sentiment and topics.
3.  On **Analyse**, run the plan and read each term in context before
    interpreting it.

![The Design screen with the What worked, and what to change study
open.](../../templates/open_text/design.png)

The Design screen with the What worked, and what to change study open.

## In R

``` r

d <- sframe_demo("open_text")
results <- run_analysis_plan(d$responses, d$instrument)
sframe_term_context(d$responses$what_worked, "session")
```

## The research questions and what the report gives

| Research question | Method | What the report gives |
|----|----|----|
| Which words come up most often? | Word frequencies | The APA 7 sentence and a table, with a chart where the method has one |
| And which pairs of words? | Phrase frequencies | The APA 7 sentence and a table, with a chart where the method has one |
| How is a key word actually used? | Words in context | The APA 7 sentence and a table, with a chart where the method has one |
| Which words appear together? | Word co-occurrence | The APA 7 sentence and a table, with a chart where the method has one |
| Do in-person and online attendees say different things? | Word frequencies | The APA 7 sentence and a table, with a chart where the method has one |
| Which words cluster together? | Word co-occurrence network | The APA 7 sentence and a table, with a chart where the method has one |
| Is the tone positive or negative? | Sentiment analysis | The APA 7 sentence and a table, with a chart where the method has one |
| What does a document-feature matrix show? | Document-feature matrix | The APA 7 sentence and a table, with a chart where the method has one |
| What topics are people writing about? | Topic model (LDA) | The APA 7 sentence and a table, with a chart where the method has one |
| The same question with a structural topic model. | Structural topic model | The APA 7 sentence and a table, with a chart where the method has one |

Run the example in SurveyStudio or R to see the results, each marked as
demonstration data.

## Related

- [Questionnaire
  templates](https://surveyframe.org/articles/templates.md)
- [All how-to guides](https://surveyframe.org/articles/guides.md)
