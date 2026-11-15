# Pre-analysis plan: Does content quality bring people back?

# Pre-analysis plan: Does content quality bring people back?

Author

Demo author

Rendered

15 November 2026

**Instrument:** Does content quality bring people back?

**Authors:** Demo author

**Version:** 1.0.0

**Date:** 15 November 2026

**Instrument hash (SHA-256):**

`0c35b9e66a2ad4f8898892befea2eb9128a8d7fb72723468894fe6c3186e4631`

The hash identifies the instrument file this plan describes. Anyone can
check that a .sframe file is the one planned by opening it at
https://surveyframe.org/verify or with read_sframe() in R.

## Study

**Purpose:** A measurement and structural model study: whether the
quality of a programme’s content builds satisfaction, and satisfaction
the intention to return.

**Research problem:** A provider believes content quality drives return
intention through satisfaction, and needs the measurement and the
structural paths tested together.

| Objective | Research questions |
|----|----|
| O1: Specify the measurement model for the 3 constructs. | RQ1 (What lavaan syntax does this model generate?); RQ2 (And the seminr syntax for a PLS estimate?); RQ4 (What CFA syntax does the measurement model generate?) |
| O2: Estimate the paths from content quality through satisfaction to intention. | RQ3 (Does satisfaction carry content quality through to intention?); RQ5 (And what seminr code would estimate the PLS model?); RQ6 (Does content quality matter more to some attendees than others?) |

**Table 1**  
*Objectives and the research questions that serve them* {.caption-top
.table}

**Population:** Attendees of a professional programme

**Sampling method:** convenience

**Planned sample size:** 150

## Participant information

**Welcome title:** Does content quality bring people back?

**Introduction:** Thank you for taking part. This survey takes a few
minutes.

**Consent (required to start):** I agree to take part, and for my
answers to be used for this study.

**Thank-you message:** Thank you for completing this survey.

## The questionnaire

The questions in the order respondents see them.

1.  The sessions were relevant. (Rating scale). Options: Strongly
    disagree, Disagree, Neither agree nor disagree, Agree, Strongly
    agree.
2.  The material went deep enough. (Rating scale). Options: Strongly
    disagree, Disagree, Neither agree nor disagree, Agree, Strongly
    agree.
3.  The speakers knew their subject. (Rating scale). Options: Strongly
    disagree, Disagree, Neither agree nor disagree, Agree, Strongly
    agree.
4.  I was satisfied with the event. (Rating scale). Options: Strongly
    disagree, Disagree, Neither agree nor disagree, Agree, Strongly
    agree.
5.  The event met my expectations. (Rating scale). Options: Strongly
    disagree, Disagree, Neither agree nor disagree, Agree, Strongly
    agree.
6.  It was a good use of my time. (Rating scale). Options: Strongly
    disagree, Disagree, Neither agree nor disagree, Agree, Strongly
    agree.
7.  I will attend next year. (Rating scale). Options: Strongly disagree,
    Disagree, Neither agree nor disagree, Agree, Strongly agree.
8.  I would recommend it to a colleague. (Rating scale). Options:
    Strongly disagree, Disagree, Neither agree nor disagree, Agree,
    Strongly agree.
9.  I would pay to attend again. (Rating scale). Options: Strongly
    disagree, Disagree, Neither agree nor disagree, Agree, Strongly
    agree.

## Scales and scoring

| Scale | Items | Reversed | Score | Missing answers |
|----|----|----|----|----|
| Content quality (content_quality) | cq_1, cq_2, cq_3 | none | mean | all 3 items needed |
| Satisfaction (satisfaction) | sa_1, sa_2, sa_3 | none | mean | all 3 items needed |
| Intention to return (intention) | it_1, it_2, it_3 | none | mean | all 3 items needed |

**Table 2**  
*Scales and how they are scored* {.caption-top .table}

## Pre-declared analysis plan

### RQ1: What lavaan syntax does this model generate?

**Null hypothesis (H0):** The declared model reproduces the observed
covariances.

**Alternative hypothesis (H1):** The declared model does not reproduce
the observed covariances.

**Planned decision rule:** Judge the model’s fit as acceptable when CFI
is .95 or above and RMSEA is .06 or below.

**Method:** Structural equation model (lavaan syntax)

**Variables:** m1

**Significance level:** alpha = .05, the package default

### RQ2: And the seminr syntax for a PLS estimate?

**Method:** PLS structural equation model (seminr syntax)

**Variables:** m2

### RQ3: Does satisfaction carry content quality through to intention?

**Null hypothesis (H0):** Satisfaction does not carry the effect of
content quality to intention.

**Alternative hypothesis (H1):** Satisfaction carries part of the effect
of content quality to intention.

**Planned decision rule:** Treat the indirect effect as present when its
95% bootstrap confidence interval excludes 0.

**Method:** Mediation analysis

**Variables:** content_quality, satisfaction, intention

**Significance level:** alpha = .05, the package default

### RQ4: What CFA syntax does the measurement model generate?

**Method:** Confirmatory factor analysis (lavaan syntax)

**Variables:** m3

### RQ5: And what seminr code would estimate the PLS model?

**Planned decision rule:** Report a path as supported when its bootstrap
confidence interval excludes 0.

**Method:** PLS structural equation model

**Variables:** m2

### RQ6: Does content quality matter more to some attendees than others?

**Null hypothesis (H0):** The effect of content quality on intention
does not depend on the moderator.

**Alternative hypothesis (H1):** The effect of content quality on
intention depends on the moderator.

**Planned decision rule:** Reject H0 if p \< .05, and report the effect
size with its 95% confidence interval.

**Method:** Moderation analysis

**Variables:** content_quality, satisfaction, intention

**Significance level:** alpha = .05, the package default

**Method reference:** (Aiken & West, 1991)

## Models

- m1 (cb sem)
- m2 (pls sem)
- m3 (cfa)

## Amendments

None. This is the instrument as first planned.

## References

- Aiken, L. S., & West, S. G. (1991). *Multiple regression: Testing and
  interpreting interactions*. SAGE.
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
