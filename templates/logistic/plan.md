# Pre-analysis plan: Will they come back?

# Pre-analysis plan: Will they come back?

Author

Demo author

Rendered

26 November 2026

**Instrument:** Will they come back?

**Authors:** Demo author

**Version:** 1.0.0

**Date:** 26 November 2026

**Instrument hash (SHA-256):**

`f8d89092bd31f0906c2272af6b8eaaed6c9942191b8c19d8ec1ae352836027c9`

The hash identifies the instrument file this plan describes. Anyone can
check that a .sframe file is the one planned by opening it at
https://surveyframe.org/verify or with read_sframe() in R.

## Study

**Purpose:** A customer return-intention study: whether more use of a
service predicts that customers return, how satisfied they are and which
offer they prefer.

**Research problem:** A provider wants to know whether customers who use
a service more are the ones who come back.

| Objective | Research questions |
|----|----|
| O1: Test whether use predicts returning. | RQ1 (Does using the service more predict returning?) |
| O2: Test whether use predicts satisfaction and the offer preferred. | RQ2 (Does attending more sessions predict a higher satisfaction rating?); RQ3 (Does attending more sessions predict which session type an attendee prefers?) |

**Table 1**  
*Objectives and the research questions that serve them* {.caption-top
.table}

**Population:** Customers who used the service in the last year

**Sampling method:** simple random

**Planned sample size:** 150

## Participant information

**Welcome title:** Will they come back?

**Introduction:** Thank you for taking part. This survey takes a few
minutes.

**Consent (required to start):** I agree to take part, and for my
answers to be used for this study.

**Thank-you message:** Thank you for completing this survey.

## The questionnaire

The questions in the order respondents see them.

1.  How many times did you use the service this year? (Number,
    required).
2.  Will you use the service again next year? (Single choice, required).
    Options: No, Yes.
3.  I was satisfied with the service. (Rating scale, required). Options:
    Strongly disagree, Disagree, Neither agree nor disagree, Agree,
    Strongly agree.
4.  Which of our offers do you value most? (Single choice, required).
    Options: Workshops, Keynotes, Panel discussions.

## Scales and scoring

The instrument declares no scales.

## Pre-declared analysis plan

### RQ1: Does using the service more predict returning?

**Null hypothesis (H0):** Use does not change the odds of returning.

**Alternative hypothesis (H1):** Use changes the odds of returning.

**Planned decision rule:** Reject H0 if p \< .05 for the use
coefficient, and report its odds ratio with a 95% confidence interval.

**Method:** Binary logistic regression

**Variables:** sessions_attended, will_return

**Significance level:** alpha = .05, the package default

**Method reference:** (Hosmer et al., 2013)

### RQ2: Does attending more sessions predict a higher satisfaction rating?

**Null hypothesis (H0):** Use does not change the odds of a higher
satisfaction rating.

**Alternative hypothesis (H1):** Use changes the odds of a higher
satisfaction rating.

**Planned decision rule:** Reject H0 if p \< .05 for the use
coefficient, and report its odds ratio with a 95% confidence interval.

**Method:** Ordinal logistic regression

**Variables:** sessions_attended, satisfaction

**Significance level:** alpha = .05, the package default

**Method reference:** (Hosmer et al., 2013)

### RQ3: Does attending more sessions predict which session type an attendee prefers?

**Null hypothesis (H0):** Use does not change which offer is preferred.

**Alternative hypothesis (H1):** Use changes which offer is preferred.

**Planned decision rule:** Reject H0 if the likelihood-ratio test of use
has p \< .05.

**Method:** Multinomial logistic regression

**Variables:** sessions_attended, preferred_session_type

**Significance level:** alpha = .05, the package default

**Method reference:** (Hosmer et al., 2013)

## Amendments

None. This is the instrument as first planned.

## References

- Hosmer, D. W., Lemeshow, S., & Sturdivant, R. X. (2013). *Applied
  logistic regression* (3rd ed.). Wiley.
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
