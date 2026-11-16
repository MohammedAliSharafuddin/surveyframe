# Pre-analysis plan: A pilot with 18 attendees

# Pre-analysis plan: A pilot with 18 attendees

Author

Demo author

Rendered

16 November 2026

**Instrument:** A pilot with 18 attendees

**Authors:** Demo author

**Version:** 1.0.0

**Date:** 16 November 2026

**Instrument hash (SHA-256):**

`06390f6257a5349ea9dc7808f4411ab9b2f53af746ac0901f227abe428db26f6`

The hash identifies the instrument file this plan describes. Anyone can
check that a .sframe file is the one planned by opening it at
https://surveyframe.org/verify or with read_sframe() in R.

## Study

**Purpose:** A pilot study with 18 participants, answering the main
study’s questions with methods suited to a small sample.

**Research problem:** Before a full study, a pilot must show whether the
main comparisons are worth testing, with too few people for large-sample
methods.

| Objective | Research questions |
|----|----|
| O1: Compare the 2 formats on sessions attended. | RQ1 (Do the 2 formats differ, without assuming normality?) |
| O2: Test whether format and sessions attended relate to returning. | RQ2 (Is format associated with returning, on an exact test?); RQ3 (Does attending more sessions predict returning, with a small-sample correction?) |

**Table 1**  
*Objectives and the research questions that serve them* {.caption-top
.table}

**Population:** Attendees of a pilot event

**Sampling method:** convenience

**Planned sample size:** 18

## Participant information

**Welcome title:** A pilot with 18 attendees

**Introduction:** Thank you for taking part. This survey takes a few
minutes.

**Consent (required to start):** I agree to take part, and for my
answers to be used for this study.

**Thank-you message:** Thank you for completing this survey.

## The questionnaire

The questions in the order respondents see them.

1.  How did you attend? (Single choice, required). Options: In person,
    Online.
2.  How many sessions did you attend? (Number, required).
3.  Will you attend next year? (Single choice, required). Options: No,
    Yes.

## Scales and scoring

The instrument declares no scales.

## Pre-declared analysis plan

### RQ1: Do the 2 formats differ, without assuming normality?

**Null hypothesis (H0):** Sessions attended have the same distribution
in both formats.

**Alternative hypothesis (H1):** Sessions attended tend to be higher in
one format.

**Planned decision rule:** Reject H0 if p \< .05 on this rank-based
test, and report the effect size with its 95% confidence interval.

**Method:** Mann-Whitney U test

**Variables:** format, sessions_attended

**Significance level:** alpha = .05, the package default

**Method reference:** (Cohen, 1988) (Mann & Whitney, 1947)

### RQ2: Is format associated with returning, on an exact test?

**Null hypothesis (H0):** Format and returning are independent.

**Alternative hypothesis (H1):** Format and returning are associated.

**Planned decision rule:** Reject H0 if the exact p \< .05.

**Method:** Fisher’s exact test

**Variables:** format, will_return

**Significance level:** alpha = .05, the package default

**Method reference:** (Field, 2018) (Cohen, 1988)

### RQ3: Does attending more sessions predict returning, with a small-sample correction?

**Null hypothesis (H0):** Sessions attended do not change the odds of
returning.

**Alternative hypothesis (H1):** Sessions attended change the odds of
returning.

**Planned decision rule:** Reject H0 if the penalised likelihood p \<
.05, and report the odds ratio with its 95% confidence interval.

**Method:** Firth logistic regression

**Variables:** sessions_attended, will_return

**Significance level:** alpha = .05, the package default

**Method reference:** (Hosmer et al., 2013) (Firth, 1993) (Heinze &
Schemper, 2002)

## Amendments

None. This is the instrument as first planned.

## References

- Cohen, J. (1988). *Statistical power analysis for the behavioral
  sciences* (2nd ed.). Lawrence Erlbaum.
- Field, A. (2018). *Discovering statistics using IBM SPSS statistics*
  (5th ed.). SAGE.
- Firth, D. (1993). Bias reduction of maximum likelihood estimates.
  *Biometrika*, *80*(1), 27–38.
- Heinze, G., & Schemper, M. (2002). A solution to the problem of
  separation in logistic regression. *Statistics in Medicine*, *21*(16),
  2409–2419.
- Hosmer, D. W., Lemeshow, S., & Sturdivant, R. X. (2013). *Applied
  logistic regression* (3rd ed.). Wiley.
- Mann, H. B., & Whitney, D. R. (1947). On a test of whether one of two
  random variables is stochastically larger than the other. *Annals of
  Mathematical Statistics*, *18*(1), 50–60.
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
