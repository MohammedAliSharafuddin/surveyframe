# Pre-analysis plan: Employee engagement at work

# Pre-analysis plan: Employee engagement at work

Author

Demo author

Rendered

26 November 2026

**Instrument:** Employee engagement at work

**Authors:** Demo author

**Version:** 1.0.0

**Date:** 26 November 2026

**Instrument hash (SHA-256):**

`4b6fcc73ca2bd9a0762fa4eab731c8c318b94ee0831e1b3a7a1262aa77ce8dff`

The hash identifies the instrument file this plan describes. Anyone can
check that a .sframe file is the one planned by opening it at
https://surveyframe.org/verify or with read_sframe() in R.

## Study

**Purpose:** An employee engagement survey of 8 items, written to
measure 2 things employees judge: how their work is organised, and the
content of their work.

**Research problem:** An organisation’s engagement survey assumes 2
dimensions, and it needs to check that its employees’ answers support
that before reporting 2 scores.

| Objective | Research questions |
|----|----|
| O1: Check that the data are suitable for factor analysis. | RQ1 (Is this data suitable for factor analysis?) |
| O2: Find how many factors the items form, and which items load where. | RQ2 (How many factors, and which items load where?) |

**Table 1**  
*Objectives and the research questions that serve them* {.caption-top
.table}

**Population:** Employees of one organisation

**Sampling method:** census

**Planned sample size:** 200

## Participant information

**Welcome title:** Employee engagement at work

**Introduction:** Thank you for taking part. This survey takes a few
minutes.

**Consent (required to start):** I agree to take part, and for my
answers to be used for this study.

**Thank-you message:** Thank you for completing this survey.

## The questionnaire

The questions in the order respondents see them.

1.  My work is planned well in advance. (Rating scale). Options:
    Strongly disagree, Disagree, Neither agree nor disagree, Agree,
    Strongly agree.
2.  I know where to find what I need to do my job. (Rating scale).
    Options: Strongly disagree, Disagree, Neither agree nor disagree,
    Agree, Strongly agree.
3.  My manager helps when I have a question. (Rating scale). Options:
    Strongly disagree, Disagree, Neither agree nor disagree, Agree,
    Strongly agree.
4.  My workplace suits the work I do. (Rating scale). Options: Strongly
    disagree, Disagree, Neither agree nor disagree, Agree, Strongly
    agree.
5.  My work is relevant to my goals. (Rating scale). Options: Strongly
    disagree, Disagree, Neither agree nor disagree, Agree, Strongly
    agree.
6.  My work challenges me enough. (Rating scale). Options: Strongly
    disagree, Disagree, Neither agree nor disagree, Agree, Strongly
    agree.
7.  The people I work with know their subject. (Rating scale). Options:
    Strongly disagree, Disagree, Neither agree nor disagree, Agree,
    Strongly agree.
8.  The tools I am given are useful. (Rating scale). Options: Strongly
    disagree, Disagree, Neither agree nor disagree, Agree, Strongly
    agree.

## Scales and scoring

| Scale | Items | Reversed | Score | Missing answers |
|----|----|----|----|----|
| How my work is organised (organisation) | org_1, org_2, org_3, org_4 | none | mean | all 4 items needed |
| The content of my work (content) | con_1, con_2, con_3, con_4 | none | mean | all 4 items needed |

**Table 2**  
*Scales and how they are scored* {.caption-top .table}

## Pre-declared analysis plan

### RQ1: Is this data suitable for factor analysis?

**Planned decision rule:** Proceed when KMO is .60 or above and
Bartlett’s test has p \< .05.

**Method:** Factorability checks (KMO and Bartlett’s test)

**Variables:** org_1, org_2, org_3, org_4, con_1, con_2, con_3, con_4

### RQ2: How many factors, and which items load where?

**Planned decision rule:** Retain the factors parallel analysis
supports, and read loadings of .40 or above.

**Method:** Exploratory factor analysis

**Variables:** org_1, org_2, org_3, org_4, con_1, con_2, con_3, con_4

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
