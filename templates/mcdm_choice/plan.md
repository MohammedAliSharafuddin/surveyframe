# Pre-analysis plan: Choosing next year’s venue

# Pre-analysis plan: Choosing next year’s venue

Author

Demo author

Rendered

16 November 2026

**Instrument:** Choosing next year’s venue

**Authors:** Demo author

**Version:** 1.0.0

**Date:** 16 November 2026

**Instrument hash (SHA-256):**

`4224221a18b60bea18c6e8984d39de1b485d2139af34e4d7ab165fb08ce02181`

The hash identifies the instrument file this plan describes. Anyone can
check that a .sframe file is the one planned by opening it at
https://surveyframe.org/verify or with read_sframe() in R.

## Study

**Purpose:** A decision study choosing next year’s venue from candidate
venues, weighting the criteria and ranking the venues by 10 methods.

**Research problem:** The organising committee must choose a venue on 4
criteria at once and needs a defensible ranking in place of a vote.

| Objective | Research questions |
|----|----|
| O1: Weight the decision criteria. | RQ1 (What weight does each criterion carry?); RQ2 (What weight does each criterion carry when network dependence is allowed?); RQ3 (Which criteria drive the others?) |
| O2: Rank the venues, and check whether the methods agree. | RQ4 (Which venue ranks best overall?); RQ5 (Which venue ranks highest by compromise ranking?); RQ6 (Which venue ranks highest by ratio analysis?); RQ7 (Which venue ranks highest by simple multi-attribute rating?); RQ8 (Which venue ranks highest by weighted aggregated sum product?); RQ9 (Which venue ranks highest by outranking flows?); RQ10 (Which venue ranks highest by outranking with thresholds?) |

**Table 1**  
*Objectives and the research questions that serve them* {.caption-top
.table}

**Population:** Members of the organising committee

**Sampling method:** purposive

**Planned sample size:** 10

## Participant information

**Welcome title:** Choosing next year’s venue

**Introduction:** Thank you for taking part. This survey takes a few
minutes.

**Consent (required to start):** I agree to take part, and for my
answers to be used for this study.

**Thank-you message:** Thank you for completing this survey.

## The questionnaire

The questions in the order respondents see them.

1.  Compare the importance of each pair of criteria (Pairwise
    comparison, required).
2.  Divide 100 points across the criteria (Criteria weights, required).
3.  How strongly does each factor influence the others? (Pairwise
    comparison, required).

## Scales and scoring

The instrument declares no scales.

## Pre-declared analysis plan

### RQ1: What weight does each criterion carry?

**Planned decision rule:** Accept the pairwise judgements when the
consistency ratio is below .10.

**Method:** Analytic hierarchy process (AHP)

**Variables:** crit_pairs

**Method reference:** (Saaty, 1980)

### RQ2: What weight does each criterion carry when network dependence is allowed?

**Method:** Analytic network process (ANP)

**Variables:** crit_pairs

**Method reference:** (Saaty, 1996)

### RQ3: Which criteria drive the others?

**Method:** DEMATEL

**Variables:** crit_influence

**Method reference:** (Gabus & Fontela, 1972) (Si et al., 2018)

### RQ4: Which venue ranks best overall?

**Method:** TOPSIS

**Variables:** crit_pairs

**Method reference:** (Hwang & Yoon, 1981)

### RQ5: Which venue ranks highest by compromise ranking?

**Method:** VIKOR

**Variables:** crit_pairs

**Method reference:** (Opricovic & Tzeng, 2004)

### RQ6: Which venue ranks highest by ratio analysis?

**Method:** MOORA

**Variables:** crit_pairs

**Method reference:** (Brauers & Zavadskas, 2006)

### RQ7: Which venue ranks highest by simple multi-attribute rating?

**Method:** SMART

**Variables:** crit_pairs

**Method reference:** (Edwards, 1977)

### RQ8: Which venue ranks highest by weighted aggregated sum product?

**Method:** WASPAS

**Variables:** crit_pairs

**Method reference:** (Zavadskas et al., 2012)

### RQ9: Which venue ranks highest by outranking flows?

**Method:** PROMETHEE

**Variables:** crit_pairs

**Method reference:** (Brans & Vincke, 1985)

### RQ10: Which venue ranks highest by outranking with thresholds?

**Method:** ELECTRE

**Variables:** crit_pairs

**Method reference:** (Roy, 1968)

## Amendments

None. This is the instrument as first planned.

## References

- Brans, J. P., & Vincke, P. (1985). A preference ranking organisation
  method: The PROMETHEE method for multiple criteria decision-making.
  *Management Science*, *31*(6), 647–656.
  https://doi.org/10.1287/mnsc.31.6.647
- Brauers, W. K. M., & Zavadskas, E. K. (2006). The MOORA method and its
  application to privatization in a transition economy. *Control and
  Cybernetics*, *35*(2), 445–469.
- Edwards, W. (1977). How to use multiattribute utility measurement for
  social decisionmaking. *IEEE Transactions on Systems, Man, and
  Cybernetics*, *7*(5), 326–340.
  https://doi.org/10.1109/TSMC.1977.4309720
- Gabus, A., & Fontela, E. (1972). *World problems, an invitation to
  further thought within the framework of DEMATEL*. Battelle Geneva
  Research Centre.
- Hwang, C.-L., & Yoon, K. (1981). *Multiple attribute decision making:
  Methods and applications*. Springer.
- Opricovic, S., & Tzeng, G.-H. (2004). Compromise solution by MCDM
  methods: A comparative analysis of VIKOR and TOPSIS. *European Journal
  of Operational Research*, *156*(2), 445–455.
  https://doi.org/10.1016/S0377-2217(03)00020-1
- R Core Team. (2026). *R: A language and environment for statistical
  computing*. R Foundation for Statistical Computing.
- Roy, B. (1968). Classement et choix en presence de points de vue
  multiples (la methode ELECTRE). *Revue Francaise d’Informatique et de
  Recherche Operationnelle*, *2*(1), 57–75.
- Saaty, T. L. (1980). *The analytic hierarchy process*. McGraw-Hill.
- Saaty, T. L. (1996). *Decision making with dependence and feedback:
  The analytic network process*. RWS Publications.
- Sharafuddin, M. A. (2026). *surveyframe: Design, Plan, Seal and Report
  Questionnaire Studies* (Version 0.4.3) \[Computer software\].
  https://github.com/MohammedAliSharafuddin/surveyframe
- Si, S.-L., You, X.-Y., Liu, H.-C., & Zhang, P. (2018). DEMATEL
  technique: A systematic review of the state-of-the-art literature on
  methodologies and applications. *Mathematical Problems in
  Engineering*, *2018*(list(list(2018))), 3696457.
  https://doi.org/10.1155/2018/3696457
- Zavadskas, E. K., Turskis, Z., Antucheviciene, J., & Zakarevicius, A.
  (2012). Optimization of weighted aggregated sum product assessment.
  *Elektronika ir Elektrotechnika*, *122*(6), 3–6.
  https://doi.org/10.5755/j01.eee.122.6.1810

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
