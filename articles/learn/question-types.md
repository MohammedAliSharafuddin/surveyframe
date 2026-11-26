# Choosing questions for your survey

Choose a question type to match the information you need, from agreement
ratings and dates to written feedback and ranked options. Each type
below links to a page that shows how to add it. The `input_types` demo
holds all 13: open it from RStudio’s Addins menu with **surveyframe: Try
a demo**.

## Questions, response options and scales

A **question** asks 1 thing. Its **response options** are the labelled
choices it offers, such as Strongly disagree to Strongly agree, and
related questions can share 1 set of options. A **scored scale**
combines a group of related questions into 1 score, such as an
organisation score from 4 agreement questions, and its reliability is
checked as a whole. [Add a Likert question to a
scale](https://surveyframe.org/articles/docs/question-types/likert.md)
shows the steps.

## The 13 question types

| Type | What the respondent does | Suits |
|----|----|----|
| [Likert](https://surveyframe.org/articles/docs/question-types/likert.md) | Rates agreement on a labelled scale | Scored scales, reliability, ordinal tests |
| [Single choice](https://surveyframe.org/articles/docs/question-types/single-choice.md) | Picks 1 option | Frequencies, cross-tabulations, group comparisons |
| [Multiple choice](https://surveyframe.org/articles/docs/question-types/multiple-choice.md) | Picks any options | Frequencies, Cochran’s Q |
| [Numeric](https://surveyframe.org/articles/docs/question-types/numeric.md) | Types a number | Descriptives, t-tests, regression |
| [Short text](https://surveyframe.org/articles/docs/question-types/short-text.md) | Types a line | Text analysis |
| [Long text](https://surveyframe.org/articles/docs/question-types/long-text.md) | Types a paragraph | Text analysis, topic models |
| [Date](https://surveyframe.org/articles/docs/question-types/date.md) | Picks a date | Descriptives |
| [Grid (matrix)](https://surveyframe.org/articles/docs/question-types/grid.md) | Rates a set of rows on 1 scale | Descriptives, scored scales |
| [Slider](https://surveyframe.org/articles/docs/question-types/slider.md) | Drags to a value | Descriptives, correlation |
| [Ranking](https://surveyframe.org/articles/docs/question-types/ranking.md) | Orders options | Rank descriptives |
| [Star rating](https://surveyframe.org/articles/docs/question-types/star-rating.md) | Gives stars | Descriptives, ordinal tests |
| [Pairwise comparison](https://surveyframe.org/articles/docs/question-types/pairwise-comparison.md) | Judges which of 2 criteria matters more (Saaty), or how much 1 influences another (0 to 4) | AHP, ANP, DEMATEL |
| [Criteria weights](https://surveyframe.org/articles/docs/question-types/criteria-weights.md) | Divides 100 points across criteria | Decision methods |

The 2 layout elements are a **section break**, which starts a new page
with a heading, and a **text block**, which shows text and collects no
answer.

Any question can be **required**, shown only when an earlier answer
allows it (**branching**), or checked for attention (**attention
checks**).

## For analysis: how answers are stored

Each type stores its answer in a declared shape, so the analysis plan
matches each method to the answers it can use. Likert, single choice,
slider, star rating and numeric questions store 1 value. A multiple
choice question stores 1 column per option, a grid 1 column per row, a
pairwise comparison 1 column per pair compared, and criteria weights 1
column per criterion. Text and date questions store the text or date
given, and a ranking stores the order.
