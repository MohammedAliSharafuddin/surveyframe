# Pre-analysis plan: What worked, and what to change

# Pre-analysis plan: What worked, and what to change

Author

Demo author

Rendered

15 November 2026

**Instrument:** What worked, and what to change

**Authors:** Demo author

**Version:** 1.0.0

**Date:** 15 November 2026

**Instrument hash (SHA-256):**

`8b7793fd1757b614c2d6fdc9706e0766fd6feb9dc9692cf5c3c1da8e8605bb70`

The hash identifies the instrument file this plan describes. Anyone can
check that a .sframe file is the one planned by opening it at
https://surveyframe.org/verify or with read_sframe() in R.

## Study

**Purpose:** An open-ended feedback study: what attendees say worked and
what to change, analysed as text.

**Research problem:** Rating questions tell organisers how much
attendees liked the event, not why. The open answers hold the reasons.

| Objective | Research questions |
|----|----|
| O1: Describe the words and topics in what worked and what to change. | RQ1 (Which words come up most often?); RQ2 (And which pairs of words?); RQ3 (How is a key word actually used?); RQ4 (Which words appear together?); RQ6 (Which words cluster together?); RQ7 (Is the tone positive or negative?); RQ8 (What does a document-feature matrix show?); RQ9 (What topics are people writing about?); RQ10 (The same question with a structural topic model.) |
| O2: Compare what in-person and online attendees write. | RQ5 (Do in-person and online attendees say different things?) |

**Table 1**  
*Objectives and the research questions that serve them* {.caption-top
.table}

**Population:** Attendees of a hybrid conference

**Sampling method:** convenience

**Planned sample size:** 80

## Participant information

**Welcome title:** What worked, and what to change

**Introduction:** Thank you for taking part. This survey takes a few
minutes.

**Consent (required to start):** I agree to take part, and for my
answers to be used for this study.

**Thank-you message:** Thank you for completing this survey.

## The questionnaire

The questions in the order respondents see them.

1.  How did you attend? (Single choice, required). Options: In person,
    Online.
2.  What worked well? (Long text).
3.  What should we change? (Long text).

## Scales and scoring

The instrument declares no scales.

## Pre-declared analysis plan

### RQ1: Which words come up most often?

**Method:** Word frequencies

**Variables:** what_worked

### RQ2: And which pairs of words?

**Method:** Phrase frequencies

**Variables:** what_worked

### RQ3: How is a key word actually used?

**Method:** Words in context

**Variables:** what_worked

### RQ4: Which words appear together?

**Method:** Word co-occurrence

**Variables:** what_worked

### RQ5: Do in-person and online attendees say different things?

**Method:** Word frequencies

**Variables:** what_to_improve, format

### RQ6: Which words cluster together?

**Method:** Word co-occurrence network

**Variables:** what_worked

**Method reference:** (Blondel et al., 2008) (Fruchterman & Reingold,
1991)

### RQ7: Is the tone positive or negative?

**Method:** Sentiment analysis

**Variables:** what_to_improve

### RQ8: What does a document-feature matrix show?

**Method:** Document-feature matrix

**Variables:** what_worked

### RQ9: What topics are people writing about?

**Method:** Topic model (LDA)

**Variables:** what_to_improve

### RQ10: The same question with a structural topic model.

**Method:** Structural topic model

**Variables:** what_to_improve

## Amendments

None. This is the instrument as first planned.

## References

- Blondel, V. D., Guillaume, J.-L., Lambiotte, R., & Lefebvre, E.
  (2008). Fast unfolding of communities in large networks. *Journal of
  Statistical Mechanics: Theory and Experiment*, *2008*(10), P10008.
  https://doi.org/10.1088/1742-5468/2008/10/P10008
- Fruchterman, T. M. J., & Reingold, E. M. (1991). Graph drawing by
  force-directed placement. *Software: Practice and Experience*,
  *21*(11), 1129–1164. https://doi.org/10.1002/spe.4380211102
- R Core Team. (2026). *R: A language and environment for statistical
  computing*. R Foundation for Statistical Computing.
- Sharafuddin, M. A. (2026). *surveyframe: Survey Instrument Workflows*
  (Version 0.4.3) \[Computer software\].
  https://github.com/MohammedAliSharafuddin/surveyframe

## To complete before submission

A preregistration also asks for these. Write each answer on its line
before you submit the plan, or add it to the instrument’s study.

**Exclusion rules:** which responses will be excluded, and why.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

**Stopping rule:** when data collection ends: a date, a sample size or
another rule.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

**Primary outcomes:** the outcomes that answer the main question.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

**Secondary outcomes:** the secondary outcomes.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

**Multiplicity:** how the tests are corrected for being run together, if
at all.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

**Contingency decisions:** what you will do if an assumption fails or
the planned sample is not reached.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

**Significance level:** the alpha each test is judged against.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_
