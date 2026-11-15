# Pre-analysis plan: Rate each session

# Pre-analysis plan: Rate each session

Author

Demo author

Rendered

15 November 2026

**Instrument:** Rate each session

**Authors:** Demo author

**Version:** 1.0.0

**Date:** 15 November 2026

**Instrument hash (SHA-256):**

`a734607031472c4c69ef59d847796ce3bc89cf9f06bd73acbff447ff6ab16f77`

The hash identifies the instrument file this plan describes. Anyone can
check that a .sframe file is the one planned by opening it at
https://surveyframe.org/verify or with read_sframe() in R.

## Study

**Purpose:** A course evaluation in which students rate each part of a
course on one grid, compared across students who attended in person and
online.

**Research problem:** A teaching team wants each part of a course rated,
and to know whether students who took it online judged it differently.

| Objective | Research questions |
|----|----|
| O1: Describe how each part of the course was rated. | RQ1 (How was each part of the course rated?); RQ2 (How were ratings of the lectures distributed?) |
| O2: Compare ratings between in-person and online students. | RQ3 (Did in-person and online students rate the lectures differently?) |

**Table 1**  
*Objectives and the research questions that serve them* {.caption-top
.table}

**Population:** Students enrolled on the course this term

**Sampling method:** census

**Planned sample size:** 60

## Participant information

**Welcome title:** Rate each session

**Introduction:** Thank you for taking part. This survey takes a few
minutes.

**Consent (required to start):** I agree to take part, and for my
answers to be used for this study.

**Thank-you message:** Thank you for completing this survey.

## The questionnaire

The questions in the order respondents see them.

1.  How would you rate each part of the course? (Grid of rating scales,
    required). Options: Poor, Fair, Good, Very good, Excellent.
2.  How did you take the course? (Single choice). Options: In person,
    Online.

## Scales and scoring

The instrument declares no scales.

## Pre-declared analysis plan

### RQ1: How was each part of the course rated?

**Method:** Descriptive statistics

**Variables:** session\_\_Lectures, session\_\_Seminars,
session\_\_Assessment, session\_\_Reading materials

### RQ2: How were ratings of the lectures distributed?

**Method:** Frequencies and percentages

**Variables:** session\_\_Lectures

### RQ3: Did in-person and online students rate the lectures differently?

**Null hypothesis (H0):** The rating of the lectures does not depend on
how the course was taken.

**Alternative hypothesis (H1):** The rating of the lectures depends on
how the course was taken.

**Planned decision rule:** Reject H0 if p \< .05, and report the effect
size with its 95% confidence interval.

**Method:** Cross-tabulation

**Variables:** format, session\_\_Lectures

## Amendments

None. This is the instrument as first planned.

## References

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
