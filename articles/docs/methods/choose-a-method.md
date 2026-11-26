# Choose a method

[Documentation](https://surveyframe.org/articles/docs.md) /
[Methods](https://surveyframe.org/articles/docs.html#methods)

Start from what the research question asks: a difference, a
relationship, a prediction or a measurement. Each chart then asks about
the kind of answer and the design, and ends at a test. Under each test
is the `method` a plan block stores, as SurveyStudio’s Plan dialog and
[`sframe_plan()`](https://surveyframe.org/reference/sframe_plan.md)
write it.

**Roughly normal, no extreme outliers?** This is the check a t test,
ANOVA or Pearson correlation relies on. The scores (for paired data, the
differences between them) should be close to a bell shape, with no
extreme values pulling the mean. With about 30 or more per group, mild
skew does no harm.
[`sframe_assumption_results()`](https://surveyframe.org/reference/sframe_assumption_results.md)
runs the check: Shapiro-Wilk, skewness and kurtosis, and Levene and
Brown-Forsythe tests for equal spread. Unequal spread alone does not
send you to a rank test, since the independent t test then uses Welch’s
version. A No, or ordinal answers such as a single Likert item, lead to
the rank tests.

## Difference between groups or occasions

From a test for 2 groups or 2 occasions, a 3rd group or occasion leads
to the test below it. See [Compare
groups](https://surveyframe.org/articles/docs/methods/group-comparisons.md),
[Compare the same people over
time](https://surveyframe.org/articles/docs/methods/repeated-measures.md)
and [Test an association between
categories](https://surveyframe.org/articles/docs/methods/associations.md).

![Flowchart: scale scores that are roughly normal go to the paired or
independent t test, then repeated-measures, one-way or two-way ANOVA or
ANCOVA; ordinal answers go to the Wilcoxon signed-rank or Mann-Whitney U
test, then Friedman or Kruskal-Wallis; categories go to McNemar or
chi-squared, then Cochran's Q or Fisher's exact
test.](../../../docs/methods/choose-difference.svg)

## Relationship between variables

Two categorical variables go to the same chi-squared test as a
difference between groups, reported with Cramer’s V or phi. See [Measure
how answers go
together](https://surveyframe.org/articles/docs/methods/correlations.md).

![Flowchart: scale scores that are linear and roughly normal go to
Pearson correlation, then partial correlation; ordinal answers go to
Spearman, then Kendall's tau; categories go to chi-squared, then
Fisher's exact test.](../../../docs/methods/choose-relationship.svg)

## Predict an outcome

The type of the outcome picks the model. A 3rd variable that changes the
strength of an effect is moderation; one that carries it is mediation.
See [Predict an
outcome](https://surveyframe.org/articles/docs/methods/regression.md).

![Flowchart: a scale outcome goes to linear regression, a yes or no
outcome to binary or Firth logistic regression, ordered categories to
ordinal logistic, unordered choices to multinomial logistic, and a 3rd
variable to moderation or
mediation.](../../../docs/methods/choose-prediction.svg)

## Measure a construct

Check readiness before an exploratory factor analysis. CFA, CB-SEM and
PLS-SEM are written as model syntax, ready to fit in lavaan or seminr.
See [Score a scale and check its
reliability](https://surveyframe.org/articles/docs/methods/scales-reliability.md)
and [Check structure and write model
syntax](https://surveyframe.org/articles/docs/methods/factor-models.md).

![Flowchart: reliability goes to Cronbach's alpha and McDonald's omega,
an unknown structure to the KMO and Bartlett readiness check then
exploratory factor analysis, and a specified structure to CFA, CB-SEM or
PLS-SEM syntax.](../../../docs/methods/choose-measurement.svg)

## Effect sizes

Each test reports its effect size, with a confidence interval where the
method gives one: Cohen’s d for t tests, r for the rank tests, eta or
omega squared for ANOVA, Cramer’s V or phi for chi-squared, and odds
ratios for logistic regression.
