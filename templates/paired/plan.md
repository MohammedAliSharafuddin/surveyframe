# Pre-analysis plan: Before and after the workshop

# Pre-analysis plan: Before and after the workshop

Author

Demo author

Rendered

16 November 2026

**Instrument:** Before and after the workshop

**Authors:** Demo author

**Version:** 1.0.0

**Date:** 16 November 2026

**Instrument hash (SHA-256):**

`a434cf3124068b9cf27eb900f591c582c3383707ef4d47a2dd94968c87890a72`

The hash identifies the instrument file this plan describes. Anyone can
check that a .sframe file is the one planned by opening it at
https://surveyframe.org/verify or with read_sframe() in R.

## Study

**Purpose:** A pre and post training evaluation: participants rate their
confidence, and say whether they would recommend the training, before
and after it.

**Research problem:** A training unit needs evidence that a one-day
workshop changes participants’ confidence, not only that they enjoyed
it.

| Objective | Research questions |
|----|----|
| O1: Measure the change in confidence from before to after the training. | RQ1 (Did confidence change from before to after the training?); RQ2 (Did confidence change, without assuming normality?) |
| O2: Measure the change in willingness to recommend it. | RQ3 (Did willingness to recommend change?) |

**Table 1**  
*Objectives and the research questions that serve them* {.caption-top
.table}

**Population:** Staff attending the workshop

**Sampling method:** census

**Planned sample size:** 50

## Participant information

**Welcome title:** Before and after the workshop

**Introduction:** Thank you for taking part. This survey takes a few
minutes.

**Consent (required to start):** I agree to take part, and for my
answers to be used for this study.

**Thank-you message:** Thank you for completing this survey.

## The questionnaire

The questions in the order respondents see them.

1.  Before the training, how confident were you applying this skill? (0
    to 100) (Slider).
2.  After the training, how confident are you applying this skill? (0
    to 100) (Slider).
3.  Before the training, would you have recommended it to a colleague?
    (Single choice). Options: No, Yes.
4.  After the training, would you recommend it to a colleague? (Single
    choice). Options: No, Yes.

## Scales and scoring

The instrument declares no scales.

## Pre-declared analysis plan

### RQ1: Did confidence change from before to after the training?

**Null hypothesis (H0):** Mean confidence is the same before and after
the training.

**Alternative hypothesis (H1):** Mean confidence differs before and
after the training.

**Planned decision rule:** Reject H0 if p \< .05, and report the effect
size with its 95% confidence interval.

**Method:** Paired samples t-test

**Variables:** confidence_before, confidence_after

**Significance level:** alpha = .05, the package default

**Method reference:** (Field, 2018) (Cohen, 1988) (Fisher, 1925)
(Shapiro & Wilk, 1965)

### RQ2: Did confidence change, without assuming normality?

**Null hypothesis (H0):** Confidence ratings are not shifted from before
to after the training.

**Alternative hypothesis (H1):** Confidence ratings are shifted from
before to after the training.

**Planned decision rule:** Reject H0 if p \< .05 on this rank-based
test, and report the effect size with its 95% confidence interval.

**Method:** Wilcoxon signed-rank test

**Variables:** confidence_before, confidence_after

**Significance level:** alpha = .05, the package default

**Method reference:** (Cohen, 1988) (Shapiro & Wilk, 1965)

### RQ3: Did willingness to recommend change?

**Null hypothesis (H0):** The share willing to recommend is the same
before and after.

**Alternative hypothesis (H1):** The share willing to recommend differs
before and after.

**Planned decision rule:** Reject H0 if p \< .05, and report the effect
size with its 95% confidence interval.

**Method:** McNemar test

**Variables:** recommend_before, recommend_after

**Significance level:** alpha = .05, the package default

## Amendments

None. This is the instrument as first planned.

## References

- Cohen, J. (1988). *Statistical power analysis for the behavioral
  sciences* (2nd ed.). Lawrence Erlbaum.
- Field, A. (2018). *Discovering statistics using IBM SPSS statistics*
  (5th ed.). SAGE.
- Fisher, R. A. (1925). *Statistical methods for research workers*.
  Oliver & Boyd.
- R Core Team. (2026). *R: A language and environment for statistical
  computing*. R Foundation for Statistical Computing.
- Shapiro, S. S., & Wilk, M. B. (1965). An analysis of variance test for
  normality. *Biometrika*, *52*(3-4), 591–611.
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
