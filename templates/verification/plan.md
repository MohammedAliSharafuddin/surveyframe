# Pre-analysis plan: Event feedback

# Pre-analysis plan: Event feedback

Author

Demo author

Rendered

26 November 2026

**Instrument:** Event feedback

**Authors:** Demo author

**Version:** 1.0.0

**Date:** 26 November 2026

**Instrument hash (SHA-256):**

`3db2149ca3c347d2f503c525ee9704fcb302fcf5887585e6cd211c9a0b8c9a12`

The hash identifies the instrument file this plan describes. Anyone can
check that a .sframe file is the one planned by opening it at
https://surveyframe.org/verify or with read_sframe() in R.

## Study

**Purpose:** A short feedback survey for a one-day professional event,
run to describe who attended and to check the quality of the answers
before the programme is planned again.

**Research problem:** The organisers plan next year’s programme without
knowing who attends or whether feedback forms are completed with care.

| Objective | Research questions |
|----|----|
| O1: Describe who attended and how old they are. | RQ1 (Who came to the event?); RQ2 (How old are attendees?) |
| O2: Check how complete and attentive the responses are. | RQ3 (How complete is the data?); RQ4 (Are there inattentive responses?) |

**Table 1**  
*Objectives and the research questions that serve them* {.caption-top
.table}

**Population:** Registered attendees of the 2025 event

**Sampling method:** census

**Planned sample size:** 50

## Participant information

**Welcome title:** Event feedback

**Introduction:** Thank you for taking part. This survey takes a few
minutes.

**Consent (required to start):** I agree to take part, and for my
answers to be used for this study.

**Thank-you message:** Thank you for completing this survey.

## The questionnaire

The questions in the order respondents see them.

1.  Have you attended this event before? (Single choice, required).
    Options: This is my first time, I have attended before.
2.  How old are you? (Number).
3.  Which day did you attend? (Date).

### A few optional questions

These help us plan next year. Skip any you prefer to.

We ask so we can improve the programme.

4.  What should we do differently next year? (Short text).

## Scales and scoring

The instrument declares no scales.

## Pre-declared analysis plan

### RQ1: Who came to the event?

**Method:** Frequencies and percentages

**Variables:** attendee_type

### RQ2: How old are attendees?

**Method:** Descriptive statistics

**Variables:** age

### RQ3: How complete is the data?

**Planned decision rule:** Treat a question with more than 10% missing
answers as a problem to report.

**Method:** Missing-data summary

**Variables:** age, suggestion

### RQ4: Are there inattentive responses?

**Planned decision rule:** Flag a response as inattentive when it fails
the quality checks, and report the count.

**Method:** Response quality checks

## Amendments

None. This is the instrument as first planned.

## References

- R Core Team. (2026). *R: A language and environment for statistical
  computing*. R Foundation for Statistical Computing.
- Sharafuddin, M. A. (2026). *surveyframe: Design, Plan, Seal and Report
  Questionnaire Studies* (Version 0.4.3) \[Computer software\].
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
