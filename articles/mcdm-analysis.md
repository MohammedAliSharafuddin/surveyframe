# Multi-criteria decision analysis

## What this vignette covers

Multi-criteria decision analysis ranks a set of alternatives against
multiple criteria that pull in different directions. surveyframe treats
it the same way it treats any other analysis: the method, its inputs,
and the roles they play are declared in the instrument before data is
collected, and the analysis is the execution of that declaration.

The worked example is a hotel choosing between 5 suppliers on 4
criteria. It ships with the package, so every number below is
reproducible.

``` r

demo <- read_sframe(system.file("extdata", "hotel_supplier_mcdm.sframe",
                                package = "surveyframe"))
responses <- utils::read.csv(
  system.file("extdata", "hotel_supplier_mcdm_responses.csv",
              package = "surveyframe"),
  stringsAsFactors = FALSE
)

c(respondents = nrow(responses), criteria = 4, suppliers = 5)
```

## Where the numbers come from

An MCDM result needs 2 things: a performance matrix saying how each
alternative scores on each criterion, and a weight vector saying how
much each criterion matters. They can come from different places, and
being explicit about which is the difference between a defensible result
and a plausible-looking one.

This instrument declares 3 sources at once, so the example exercises all
of them.

Each result records which source it used, so a report can say where its
numbers came from, which saves a reader from assuming.

## Criterion weights from pairwise judgements

The first block asks what weight each criterion carries. Respondents
compared every pair of criteria, and AHP turns those judgements into
weights.

``` r

results <- run_analysis_plan(responses, demo, plots = has_ggplot)
ahp <- results[["RQ1"]]

kable(ahp$table, row.names = FALSE,
      caption = "Criterion weights derived from pairwise judgements.")
```

Pairwise judgements can contradict each other. If service beats price,
and price beats delivery, then service ought to beat delivery by roughly
the product of the 2. The consistency ratio measures how far the
judgements depart from that.

``` r

round(ahp$cr, 4)
```

Saaty’s convention treats a consistency ratio below 0.10 as acceptable.
This one is well inside it. A ratio above 0.10 should be reported
alongside the result, since it still yields a usable weight set.
`options$cr_filter = TRUE` will drop individual respondents above the
threshold before aggregation if a study has pre-declared that rule.

``` r

ahp$plot
```

## Ranking suppliers on audited figures

The second block ranks the suppliers using a performance matrix the
researcher supplies, combined with the weights the respondents produced.
This is the common hybrid: measured facts about the alternatives,
weighted by the people who will live with the decision.

``` r

audited <- results[["RQ2"]]

kable(audited$table, row.names = FALSE,
      caption = paste("TOPSIS ranking on audited figures, weighted by",
                      "collected judgements."))

c(weights = audited$weights_source, matrix = audited$matrix_source)
```

Note the `criteria_types` this block declares: service and location are
`benefit` criteria where more is better, while price and delivery time
are `cost` criteria where less is better. Getting that wrong silently
inverts the ranking, which is why the instrument declares it and
surveyframe reads it from there.

## Ranking suppliers on collected ratings

The third block answers a different question with the same method: which
supplier the staff rate best, where the first asked which one the
audited figures favour. The performance matrix is built from
respondents’ ratings, and the weights come from the constant-sum
question this time, where the first ranking used the pairwise one.

``` r

rated <- results[["RQ3"]]

kable(rated$table, row.names = FALSE,
      caption = paste("TOPSIS ranking on staff ratings, weighted by the",
                      "constant-sum question."))
```

The 2 rankings disagree, and that is the useful part. Comparing them is
a finding in its own right, and it belongs in the write-up.

### A trap worth naming

All 4 criteria in the rated block are declared `benefit`, including
price. That is correct here only because the question asked about
**value for money**, where a higher rating is better. Had it asked
respondents to rate price directly, a higher rating would mean more
expensive and the criterion would be a `cost`.

Nothing in the data distinguishes those 2 cases. The wording of the
question does, and the declaration has to match it. This is the single
easiest way to produce a confident, precise, and completely inverted
ranking.

## How much do the weights matter?

A ranking produced from collected weights inherits their uncertainty.
Before reporting a winner, it is worth asking how much of that result
survives a small change in the weights.

``` r

sens <- sframe_sensitivity_analysis(
  x = matrix(c(4.1, 3.0, 210, 36,
               3.6, 4.5, 180, 48,
               4.8, 2.5, 260, 24,
               3.9, 4.0, 150, 72,
               4.4, 3.8, 230, 30),
             nrow = 5, byrow = TRUE),
  weights        = audited$weights,
  criteria_types = c("benefit", "benefit", "cost", "cost"),
  method         = "topsis",
  alternatives   = c("Alpha", "Basilica", "Coral", "Dhoni", "Equator"),
  criteria       = c("service", "location", "price", "delivery")
)

sens
```

Each criterion’s weight is nudged up and down by 5 percent,
renormalised, and the ranking is recomputed. `rho` is the rank
correlation with the original ranking, and `top_changed` records whether
the leading alternative changed.

``` r

kable(as.data.frame(sens), row.names = FALSE,
      caption = "Ranking stability under a 5 percent change in each weight.")
```

``` r

plot(sens)
```

This example is worth reading closely, because it is the awkward case. 4
of the 8 perturbations changed the ranking, so `stable` is `FALSE`. But
`top_changed` is `FALSE` throughout: the order shuffles among the middle
suppliers while Equator stays first under every nudge.

That distinction is the whole point of running this. “Equator ranks
first, and that holds under a 5 percent change in any single weight” is
a defensible claim. “The ranking is Equator, Coral, Basilica, Alpha,
Dhoni” is not, because positions 2 to 5 move. Reporting the full ranking
as though it were as solid as the winner would overstate what the data
supports.

A result where `top_changed` is `TRUE` anywhere deserves a stronger
caveat still, and one where `stable` is `TRUE` throughout can be
reported as robust to the weights.

## Which criteria drive the others

The criteria depend on each other. Delivery speed and price move
together, and service quality may drive both. DEMATEL asks respondents
how strongly each factor influences each other factor and separates the
causes from the effects.

``` r

dematel <- results[["RQ4"]]

kable(dematel$table, row.names = FALSE,
      caption = "DEMATEL cause and effect classification.")
```

The prominence column measures how involved a criterion is in the system
overall, and the relation column separates the drivers from the driven.
A criterion with a positive relation value influences others more than
it is influenced.

``` r

dematel$plot
```

Note that the influence question uses a different scale from the AHP
one. AHP reads reciprocal relative importance on Saaty’s 1 to 9 ratio
scale, while DEMATEL reads directed 0 to 4 influence with no
reciprocity. They are not interchangeable, and surveyframe refuses to
pair one with the other’s method at validation time, which is what stops
meaningless input returning plausible numbers.

## Reporting the whole plan

Because every block is declared in the instrument, the whole analysis is
one call and the report writes itself in the same order the plan was
declared.

## What surveyframe does not do here

The decision family ranks and weights. The choice of method stays with
the researcher, and it matters: the 10 available methods encode
different assumptions about how criteria trade off against one another.

2 limits are worth stating plainly. surveyframe does not estimate choice
models, so
[`sframe_conjoint_design()`](https://surveyframe.org/reference/sframe_conjoint_design.md)
declares a conjoint design without analysing its responses. And
PROMETHEE defaults to Brans and Vincke’s type I step function, where
some implementations default to the linear function, because the linear
function needs thresholds that are commonly derived from the data range,
which makes a result depend on a choice nobody declared. See
[`?sframe_decision_options`](https://surveyframe.org/reference/sframe_decision_options.md)
for the detail, including how far rankings move between the 2.

## How each method was checked

A ranking is only as trustworthy as the arithmetic under it, so the
evidence behind each method is recorded here in full. 2 kinds appear. An
*oracle* check computes the same method on the same matrix with RMCDA,
an independent package, and compares the numbers. A *derived* check
compares against values worked out by hand from the published formula,
or against a worked example printed in the source paper.

| Method | Evidence behind it |
|----|----|
| AHP | oracle: RMCDA weights on a consistent matrix. Derived: CR on a consistent and an inconsistent matrix |
| VIKOR | oracle: RMCDA S, R and Q. Derived: the 2 acceptance conditions |
| MOORA | oracle: RMCDA ratio-system scores on RMCDA’s own 7-alternative example. Derived: the reference-point variant and direction handling |
| WASPAS | oracle: RMCDA scores at lambda 0.5 on RMCDA’s own example. Derived: the sum and product parts separately |
| ELECTRE | oracle: RMCDA’s example, compared on the ordering of one concordance pair. Derived: 2 concordance and discordance entries, and a kernel under direct dominance |
| ANP | derived: a stored priority-vector fixture, and the limit matrix’s convergence |
| DEMATEL | derived: 2-by-2 algebra by hand, and a 4-by-4 fixture |
| SMART | derived: scores of 0.2, 0.6 and 0.7 worked out by hand, and invariance to units |
| PROMETHEE | derived: flows worked out by hand for the usual and linear preference functions |
| TOPSIS | derived: dominance endpoints, cost-direction reversal, invariance to units |

RMCDA sits in `Suggests`, so its 5 checks are skipped where it is
absent. The 5 derived-only methods differ from RMCDA’s in normalisation
or in the variant implemented, so a numeric comparison there would
compare 2 different methods. DEMATEL is the clearest case: RMCDA scales
by a different norm, and the test says so where it derives the expected
matrix instead.

Reading a citation is a separate check from reproducing a method. The
registry behind `?sframe_decision_methods` records which publications
were read directly, and names the 1 case, DEMATEL’s originating 1972
report, where a later paper’s statement of the same equations stood in
for a source that stayed out of reach.
