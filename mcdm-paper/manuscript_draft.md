# surveyframe: A Pre-Declared, Reproducible Framework for Multi-Criteria Decision Analysis in Survey Research

Author details removed for double-blind review

## Abstract

Multi-criteria decision analysis (MCDA) is used across operations research to rank
alternatives against criteria that pull in different directions, and survey
respondents are a common source of the criterion weights and judgement matrices such
rankings depend on. Existing MCDA software accepts a matrix and a weight vector as
its starting point and says nothing about how those numbers were produced. When the
input comes from a phone-screen survey rather than a spreadsheet, the steps that
turn per-respondent answers into a square judgement matrix, an aggregated weight
vector, or a performance matrix are usually improvised by the analyst, undocumented,
and unavailable for another researcher to check. This paper presents the
multi-criteria decision analysis extension of surveyframe, an open-source R package
that represents a questionnaire as a typed, hashed instrument object. The extension
adds 2 new item types for collecting pairwise judgements and constant-sum weight
allocations, a data-assembly layer that turns per-respondent answers into aggregated
matrices with a documented aggregation rule, and 10 decision methods (AHP, ANP,
DEMATEL, VIKOR, MOORA, SMART, WASPAS, PROMETHEE, ELECTRE, TOPSIS) that consume those
matrices under a common role vocabulary. Every method call records where its matrix
and its weights came from, and a sensitivity function reports how far a ranking
moves under a declared perturbation to the weights. A worked example, a hotel
choosing between 5 suppliers on 4 criteria, is carried through the paper end to end
using the package's bundled fixture, and every number reported is the package's own
output rather than an illustration. The contribution is a reproducible link between
survey instrument, collected judgement data, and MCDA result, closing a gap between
survey methodology and decision-analysis software that neither literature currently
addresses on its own.

**Keywords:** multi-criteria decision analysis, survey research, open-source
software, R package, AHP, TOPSIS, DEMATEL, reproducibility, pre-registration.

---

## 1. Introduction

Multi-criteria decision analysis ranks alternatives against multiple criteria at
once, and it depends on 2 kinds of input: a performance matrix describing how each
alternative scores on each criterion, and a weight vector describing how much each
criterion matters. Established R and Python packages implement the ranking
mathematics well. The `topsis` package takes a decision matrix, a weight vector, and
a vector of benefit or cost impacts and returns a score and a rank (Hwang & Yoon,
1981, and the package's own documentation). The `dematel` package takes one aggregated
square matrix and returns the cause-effect classification. Neither package, nor most
of the wider MCDA software landscape, says anything about where its input matrix
came from. That step is left to the analyst, and in applied survey research it is
often the hardest and least visible part of the study.

A weight vector derived from Saaty pairwise comparisons is not simply typed in. It
is built from a set of respondent judgements that must first be checked for
consistency, then aggregated across respondents by a defensible rule, and only then
converted to weights by an eigenvector calculation. A performance matrix built from
respondent ratings carries the same aggregation problem one level earlier: which
statistic per cell, how missing responses are handled, and whether a criterion
framed as "value for money" should be coded as a benefit or a cost. None of this is
mathematics. All of it is a set of researcher decisions that change the answer, and
none of it is currently recorded in a form another researcher can inspect.

Survey methodology software, in turn, treats scale scoring, reliability analysis,
and hypothesis testing as first-class operations but has no concept of a decision
method at all. A researcher currently runs 2 disconnected tools: one to collect and
manage the survey, and one to compute the ranking, with the aggregation step
performed by hand in between and rarely reported.

This paper presents an extension to surveyframe, an R package for survey instrument
workflows, that closes this gap. The package already represents a questionnaire as a
typed instrument object (the `.sframe` format), reads and validates response data
against that declaration, and executes a pre-declared analysis plan so that every
statistical test a study reports was specified before the data existed rather than
selected afterwards. The extension described here brings MCDA into that same
declarative model: an instrument declares which items collect pairwise judgements or
performance ratings, an analysis plan block declares which decision method consumes
them and how its inputs are sourced, and the package's own aggregation and
computation code produces the result. The scope of this paper is the 10 decision
methods shipping in surveyframe 0.4.0: the Analytic Hierarchy Process (AHP), the
Analytic Network Process (ANP), the Decision Making Trial and Evaluation Laboratory
method (DEMATEL), VIKOR, MOORA, SMART, WASPAS, PROMETHEE, ELECTRE, and TOPSIS. A
larger expansion carrying roughly 41 further methods is planned for later releases
and is described only as a roadmap in Section 6, not as delivered work.

The remainder of the paper is organised as follows. Section 2 sets the extension
against existing MCDA software and survey research practice. Section 3 describes
the data contract: the 2 kinds of matrix the package distinguishes, the 2 new item
types used to collect judgements from respondents, the column encoding used to
export them, and the aggregation rules applied before a method runs. Section 4
carries a worked example, a hotel supplier selection problem, through 4 declared
analysis blocks using the package's bundled fixture data, reporting the package's
own output at each step. Section 5 discusses what pre-declaration buys a study, the
package's sensitivity-analysis function, and a documented deviation from common
PROMETHEE defaults. Section 6 sets out the roadmap for the remaining methods.
Section 7 concludes.

## 2. Background and related work

### 2.1 MCDA computation packages

A handful of CRAN packages implement individual MCDA methods well but treat data
assembly as outside their scope. `topsis` (version 1.0) exposes one function,
`topsis(decision, weights, impacts)`, that takes an already-built numeric matrix, an
already-summed weight vector, and a character vector of `"+"`/`"-"` impacts, and
returns a data frame of scores and ranks. `dematel` (version 0.1.0) exposes stepwise
functions operating on one plain square matrix that is already aggregated across
however many experts contributed to it. Its bundled example data arrives as a
10-by-10 frame with no record of how it was produced. `ahptopsis2n` (version 0.2.0)
goes one step further and accepts a full AHP pairwise matrix with literal
reciprocal fractions (`1/3`, `1/5`) alongside the decision matrix, confirming that
the hybrid pipeline used in this paper, pairwise judgement to weights to ranking, is
an established published pattern, but again the pairwise matrix in its examples is
handed in ready-made.

`IFMCDM` (version 0.1.17) is the closest published analogue to the problem this
paper addresses. Its `IFconversion()` function takes raw per-respondent ordinal
survey data, repeated rows of one Likert column per criterion per respondent, and
aggregates it into an intuitionistic fuzzy decision matrix before `IFTOPSIS()`
ranks it. This confirms that building a decision matrix by aggregating survey
responses is a recognised path, and it uses a third weight and criterion-type
encoding again distinct from the other 2 packages. None of the 4 packages records
provenance: none of their result objects say which matrix cells came from which
respondents, using which statistic, under which framing of the question.

### 2.2 Survey research software

Survey platforms and R packages for survey analysis (scale construction,
reliability, weighted estimation) have no MCDA concept at all. A researcher running
a supplier-selection or policy-priority survey using AHP or TOPSIS today collects
data in one tool, exports it, and writes ad hoc aggregation code before handing the
result to one of the packages in Section 2.1. That aggregation code is rarely
published alongside the paper, and where it is published it typically lives as
uncommented analysis script rather than as part of a declared, reusable instrument.

### 2.3 The gap this paper addresses

The gap sits between the 2 literatures. MCDA packages assume a clean matrix exists.
Survey software has no method for producing one. surveyframe's decision-family
extension is built to close that gap directly: the instrument declares the
collection instrument for the judgement data, the analysis plan declares the method
and the exact source of each input, and the package's own code performs the
aggregation the same way for every user rather than leaving it to be reinvented per
study.

## 3. The data contract

### 3.1 Two matrix kinds, kept separate

surveyframe's decision family distinguishes 2 kinds of matrix and never conflates
them. Judgement matrices are criteria-by-criteria matrices of respondent opinion:
AHP and ANP pairwise ratios, and the DEMATEL direct-relation matrix. One judgement
matrix exists per respondent and is aggregated across respondents before use. AHP
and ANP matrices are reciprocal, with the entry for the pair (b, a) fixed as the
reciprocal of the entry for (a, b) and a diagonal of 1. DEMATEL matrices are not
reciprocal: the influence of a on b is judged independently of the influence of b on
a, and the diagonal is 0.

Performance matrices are alternatives-by-criteria matrices, the decision matrix that
TOPSIS, VIKOR, MOORA, PROMETHEE, ELECTRE, SMART, and WASPAS rank from. These are
measurements or expert scores of the actual alternatives under study and are not
typically collected from a general respondent pool.

A realistic study frequently combines both: weights are collected from respondents,
either by pairwise comparison or by a constant-sum allocation question, while the
performance matrix is supplied by the researcher from audited figures or collected
separately as respondent ratings. Every ranking method in the package therefore
resolves its 2 inputs independently, matrix and weights, and records where each one
came from (`matrix_source`, `weights_source`) so that a results table or a report
can state the provenance of every number rather than leaving a reader to assume it.

### 3.2 Collecting judgements from respondents

2 new item types collect judgement data directly inside the survey instrument.

`pairwise_comparison`, used with `comparison_scale = "saaty"`, collects the
unordered pairs needed for AHP or ANP. For n criteria this is n(n-1)/2 rows, each a
bipolar 17-point Saaty strip running from "extremely more important" on one side
through "equal" to "extremely more important" on the other. An n-by-n grid is never
rendered, since a grid of that kind is unusable on a phone screen and invites
inconsistent answers. The package warns above 7 items being compared, since
respondent burden and the reliability of the eigenvector solution both degrade past
that point, and refuses more than 10.

`pairwise_comparison`, used with `comparison_scale = "influence"`, collects the
ordered pairs DEMATEL needs: for n criteria, n(n-1) rows, each a 5-point unipolar
strip from 0 (no influence) to 4 (very high influence), since "how strongly does A
influence B" is a separate question from "how strongly does B influence A". The
package warns above 6 items being compared, since that already produces 30 rows.

`criteria_weight` collects a constant-sum allocation: one numeric field per
criterion, a running total shown to the respondent, and the page will not advance
until the total is exactly 100. This is the second and simpler route to a weight
vector, used where a full pairwise comparison is judged too demanding for the
respondent group.

All 3 input structures render identically, item for item, on every survey surface
the package supports: the static HTML survey, the embeddable Shiny module, and the
visual builder's preview. A respondent completing the same instrument on any surface
sees the same question.

### 3.3 Column encoding

Collected judgements are exported as one column per pair or per criterion, following
the package's existing expansion-column convention. An AHP pairwise item produces
one column per unordered pair, named `item__a__vs__b`, holding a signed integer in
{-9 to -2, 1, 2 to 9}: a positive value means the alphabetically first side of the
pair was preferred by that Saaty degree, a negative value means the second side was
preferred, and 1 means the pair was judged equal. Storing a signed integer rather
than a decimal keeps the exported CSV and the linked Google Sheet free of recurring
fractions. The reciprocal used inside the matrix is reconstructed at assembly time
and never stored. A DEMATEL item produces one column per ordered pair,
`item__a__to__b`, an integer from 0 to 4. A `criteria_weight` item produces one
column per criterion, `item__crit`, an integer from 0 to 100 that sums to 100 across
each respondent's row.

### 3.4 Assembly and aggregation

A dedicated module (`R/decision_data.R`) sits between the response data frame and
the decision methods, and is tested on its own rather than only as a side effect of
testing the methods. `sframe_assemble_pairwise()` builds one n-by-n matrix per
respondent from the pair columns, filling reciprocal cells for AHP and directed
cells for DEMATEL, and validates that every pair was answered and every value falls
in range. A respondent who left any pair unanswered is dropped from that block and
counted rather than having their partial matrix completed by estimation. This is a
documented decision rather than a silent one, adopted because the method used to
complete a partial matrix (Harker completion) is itself a researcher choice that the
package does not make on a user's behalf.

`sframe_aggregate_judgements()` aggregates the per-respondent matrices into one.
AHP and ANP use the element-wise geometric mean, the standard aggregation of
individual judgements, chosen because it is the aggregation rule that preserves
reciprocity: an arithmetic mean of reciprocal judgements does not itself stay
reciprocal. DEMATEL uses the arithmetic mean, since its matrix carries no
reciprocity constraint to preserve. The aggregated result carries the number of
respondents used and the number dropped for missing data.

AHP judgements are also screened for consistency. The package computes each
respondent's consistency ratio (CR) from the principal eigenvector solution and
Saaty's random-index table, reports the distribution of CR across respondents
(minimum, median, maximum, and the share above 0.10) whether or not it is used to
filter, and only drops individual respondents above the conventional CR threshold
of 0.10 when a study has declared `cr_filter = TRUE` in advance. The threshold is
never applied silently.

Where the performance matrix is itself built from ratings rather than supplied,
`sframe_rated_matrix()` builds it from one ordinary `matrix` item per criterion,
with respondents as the rows of each matrix item and alternatives as its columns,
taking the per-cell mean (or another declared statistic) across respondents and
carrying the per-cell sample size and standard deviation forward for reporting.

Every one of the 10 runners resolves its inputs in the same order: a
researcher-supplied matrix or weight vector in the analysis plan block takes
precedence, a role pointing at a collected item is used if no override is supplied,
and a typed error naming exactly what is missing is raised if neither is available.
This uniform resolution order, rather than a per-method convention, is what allows
the worked example in Section 4 to mix a supplied matrix with collected weights in
one block and 2 fully collected sources in another, using the same method both
times.

### 3.5 The 10 methods

The computation layer (`R/decision_methods.R`) implements each method as a pure,
internally tested function taking a matrix, a weight vector, and a vector of
criterion types, and returning the method's raw output. A shared validator checks
every input once: a numeric matrix with no missing values, weights that sum to 1
within a small tolerance (renormalised with a note rather than rejected), a weight
vector matching the matrix's column count, and criterion types restricted to
`"benefit"` or `"cost"`.

AHP and ANP return weights from the pairwise judgement matrix, using the principal
eigenvector and Saaty's consistency ratio. ANP extends this to a supermatrix solved
by power iteration with a bounded iteration count. DEMATEL returns a cause-effect
classification from the total-relation matrix, separating each criterion's overall
involvement (prominence, D+R) from its net direction of influence (relation, D-R).
The remaining 7 methods rank alternatives against a performance matrix and a weight
vector. TOPSIS ranks by distance from an ideal and an anti-ideal solution. VIKOR
ranks by a compromise measure with a group-utility parameter defaulting to 0.5.
MOORA offers a ratio system and a reference-point variant. SMART ranks by a
normalised weighted value. WASPAS blends a weighted sum and a weighted product,
also defaulting to 0.5. ELECTRE I ranks by outranking under concordance and
discordance thresholds. PROMETHEE II ranks by net preference flows under a chosen
preference function, discussed further in Section 5.2.

Every method carries at least one verified literature citation attached to the
`use` field of the package's citation library, checked against the publication
record rather than transcribed from a secondary source. DEMATEL carries 2, since no
single publication is agreed as canonical for a method developed across 4
grey-literature reports at the Battelle Geneva Research Centre between 1972 and
1976. Where sources disagreed, as they did for ELECTRE's original journal volume,
the primary source was checked directly rather than the more commonly repeated
figure being carried forward.

## 4. Worked example: hotel supplier selection

The worked example ships with the package as a bundled fixture, `.sframe`
instrument plus 12 seeded respondents, so every table in this section is the
package's own output rather than an illustration built separately for the paper. A
hotel is choosing between 5 suppliers, Alpha, Basilica, Coral, Dhoni, and Equator,
on 4 criteria: service quality, location, price, and delivery time. Service quality
and location are framed as benefit criteria, where a higher figure is better.
Price and delivery time are framed as cost criteria, where a lower figure is
better. The
instrument declares 4 analysis blocks that between them exercise every collection
path described in Section 3.

### 4.1 Criterion weights from pairwise judgements (AHP)

The first block asks what weight each criterion carries, using the 6 pairwise
comparisons the 4 criteria require. Table 1 reports the weights the package
computed from the 12 respondents' aggregated judgements.

**Table 1.** Criterion weights derived from pairwise judgements (AHP).

| Criterion | Weight | Rank |
|---|---|---|
| service  | 0.3970 | 1 |
| location | 0.2462 | 2 |
| price    | 0.1916 | 3 |
| delivery | 0.1652 | 4 |

The consistency ratio for the aggregated matrix is 0.0197, comfortably inside
Saaty's conventional threshold of 0.10. A ratio above that threshold would not
invalidate the data, but the package reports it in every case rather than only
when it is a problem, and `cr_filter = TRUE` is available to drop individual
respondents above the threshold before aggregation where a study has pre-declared
that rule.

### 4.2 Ranking on audited figures, weighted by collected judgements

The second block ranks the 5 suppliers on a performance matrix the researcher
supplies directly, weighted by the AHP judgements from Section 4.1. This is the
hybrid pipeline described in Section 3.1: measured facts about the alternatives,
weighted by the people who will act on the decision. Table 2 reports the TOPSIS
result.

**Table 2.** TOPSIS ranking on audited figures, weighted by collected judgements.

| Alternative | Score | Rank |
|---|---|---|
| Equator  | 0.6657 | 1 |
| Coral    | 0.5530 | 2 |
| Basilica | 0.5478 | 3 |
| Alpha    | 0.5180 | 4 |
| Dhoni    | 0.4245 | 5 |

The block's result records `weights_source = "collected"` and
`matrix_source = "supplied"`, so a reader of the results table, not only a reader of
the method section, can see which half of the calculation came from respondents and
which was entered by the researcher.

### 4.3 Ranking on collected ratings, weighted by a constant-sum question

The third block answers a related but different question with the same method: not
which supplier the audited figures favour, but which supplier respondents rate
best overall. The performance matrix here is built entirely from respondent
ratings across 4 matrix items, one per criterion, and the weights come from the
constant-sum question rather than the pairwise one. Table 3 reports the result.

**Table 3.** TOPSIS ranking on staff ratings, weighted by the constant-sum question.

| Alternative | Score | Rank |
|---|---|---|
| Equator  | 0.6125 | 1 |
| Dhoni    | 0.5706 | 2 |
| Basilica | 0.5688 | 3 |
| Alpha    | 0.4580 | 4 |
| Coral    | 0.4458 | 5 |

The 2 rankings do not agree beyond the top position: Coral falls from second to
last, and Dhoni rises from last to second. This is not a defect in either
calculation. It is the same method answering 2 different, equally legitimate
questions, and the value of running both inside one declared plan is that the
disagreement is visible rather than hidden behind whichever single ranking a study
happened to report.

All 4 criteria in this block are declared `benefit`, including price, and this is
correct only because the underlying question asked respondents to rate value for
money, where a higher rating is better. Nothing in the collected data distinguishes
that framing from the alternative, a question asking respondents to rate price
directly, where a higher rating would mean more expensive and the criterion would
need to be declared a cost. The declaration has to match the wording of the
question, not the name of the criterion, and this is among the easiest ways to
produce a confident, precise, and completely inverted ranking if it is missed.

### 4.4 How much do the weights matter

A ranking built from collected weights inherits their uncertainty, and the package
provides `sensitivity_analysis()` to report how much of a result survives a small,
declared change in those weights. Applied to the audited-figures ranking from
Section 4.2, each criterion's weight is nudged up and down by 5 percent, renormalised,
and the ranking recomputed. Table 4 reports the result.

**Table 4.** Ranking stability under a 5 percent change in each criterion weight.

| Criterion | Direction | Weight | rho | Rank changed | Top changed |
|---|---|---|---|---|---|
| service  | up   | 0.4087 | 1.0 | FALSE | FALSE |
| service  | down | 0.3848 | 0.9 | TRUE  | FALSE |
| location | up   | 0.2554 | 0.9 | TRUE  | FALSE |
| location | down | 0.2368 | 1.0 | FALSE | FALSE |
| price    | up   | 0.1992 | 0.9 | TRUE  | FALSE |
| price    | down | 0.1838 | 1.0 | FALSE | FALSE |
| delivery | up   | 0.1721 | 1.0 | FALSE | FALSE |
| delivery | down | 0.1583 | 0.9 | TRUE  | FALSE |

`rho` is the rank correlation with the original ranking, and `top_changed` records
whether the leading alternative changed. This result is worth reading in full
rather than summarised as pass or fail. 4 of the 8 perturbations change the
ranking, so the package's overall `stable` verdict is `FALSE`. `top_changed` is
`FALSE` throughout, however: the middle of the ranking reorders under a 5 percent
nudge to any single weight, while Equator stays first every time. "Equator ranks
first, and that holds under a 5 percent change in any single weight" is a claim the
data supports. "The ranking is Equator, Coral, Basilica, Alpha, Dhoni" is not,
because positions 2 to 5 move under exactly the perturbation just tested. Reporting
the full ranking with the same confidence as the winner would overstate what the
sensitivity check actually shows.

### 4.5 Which criteria drive the others (DEMATEL)

The 4 criteria are unlikely to be independent of one another: delivery speed and
price may move together, and service quality may drive both. The fourth block asks
respondents how strongly each criterion influences each other criterion and
separates causes from effects. Table 5 reports the result.

**Table 5.** DEMATEL cause and effect classification.

| Criterion | D | R | Prominence (D+R) | Relation (D-R) | Role |
|---|---|---|---|---|---|
| service  | 2.3375 | 1.0457 | 3.3833 |  1.2918 | cause  |
| delivery | 1.4008 | 1.9769 | 3.3776 | -0.5761 | effect |
| price    | 1.2126 | 1.9481 | 3.1607 | -0.7355 | effect |
| location | 1.4315 | 1.4117 | 2.8432 |  0.0198 | cause  |

Prominence measures how involved a criterion is in the system as a whole. Relation
separates drivers from driven, with a positive value meaning a criterion influences
the others more than it is influenced by them. Service quality is the strongest
driver in this sample and also the most prominent criterion overall, while price
and delivery time are net effects rather than causes, consistent with the intuition
that respondents see cost and speed as consequences of service quality rather than
independent levers.

The influence question behind this table uses a different response scale from the
pairwise question behind Section 4.1: AHP reads reciprocal relative importance on
Saaty's 1-to-9 ratio scale, while DEMATEL reads directed influence on a 0-to-4 scale
with no reciprocity. The 2 are not interchangeable, and the package refuses to pair
data collected under one scale with the method built for the other at validation
time, rather than silently returning a plausible-looking number from meaningless
input.

## 5. Discussion

### 5.1 What pre-declaration buys the study

Every number reported in Section 4 traces to a specific instrument item, a
specific aggregation rule, and a specific declared role, because the analysis plan
that produced them was written before the fixture's 12 respondents answered
anything. This matters for MCDA specifically because the method has 4
researcher degrees of freedom that do not exist in a simple hypothesis test: which
matrix a ranking used, which statistic aggregated respondent judgements, whether a
criterion was framed as a benefit or a cost, and which preference function a method
such as PROMETHEE applied. Each of these choices changes the answer, and each is
recorded in the instrument and the result object rather than left to be
reconstructed from a script after the fact. A reviewer or a replicating researcher
can read the `weights_source` and `matrix_source` fields on any result and know
exactly where its inputs came from without re-reading the analysis code.

### 5.2 A documented departure from common defaults

PROMETHEE requires a preference function, and other MCDA implementations commonly
default to the linear (V-shape) function with its 2 thresholds derived automatically
from the range of the supplied data. surveyframe defaults instead to Brans and
Vincke's original type I step function, `"usual"`, which needs no thresholds and so
adds no researcher degree of freedom the study has not declared. Deriving thresholds
from the data range makes the result depend on a choice nobody actually made, which
is the exact class of hidden researcher degree of freedom this package exists to
close off. The choice is not cosmetic: across 400 randomly drawn 4-alternative,
3-criterion matrices, the ranking itself changed in 226 of them between the 2
preference functions. A ranking produced by surveyframe and cross-checked against an
implementation defaulting to the linear function will often disagree unless the
threshold-bearing function is requested explicitly and the same thresholds are
supplied on both sides. The preference function actually used is always named in
the block's reported result, and the step function ties ranks more readily than the
linear one, since it scores every non-zero difference identically.

### 5.3 Limitations

The package does not complete partial pairwise matrices. A respondent who skips any
pairwise question is dropped from that block's aggregation rather than having their
matrix estimated. This is a defensible default but not a costless one, and it should
be revisited if field studies show a high rate of partial completion. The package
does not estimate choice models: `sf_conjoint_design()` declares a conjoint design
for data collection but does not analyse the responses it produces, and no method in
this paper's scope addresses discrete choice estimation. The worked example in
Section 4 uses a fixture of 12 seeded respondents chosen to exercise every
collection path rather than to represent a fielded study, and the consistency and
sensitivity figures reported are properties of that fixture, not general claims
about AHP or TOPSIS.

## 6. Roadmap: the wider MCDA family

The 10 methods in this paper's scope are the set shipping in surveyframe 0.4.0. A
further set of roughly 41 methods, drawn from the same computational family and
already implemented in a companion R package the authors maintain (RMCDA, CRAN
0.3.1), is planned for incremental release across later versions, beginning at
0.4.2. Each addition will follow the same integration pattern used for the 10
methods in this paper: a computation function, a runner wired into the existing
analysis-plan engine, a verified citation, a results table and plot, and coverage in
both the builder and the Shiny studio interfaces the package already provides. The
existing RMCDA package is retained as a guarded, test-time cross-check oracle for
every ported method rather than discarded once its methods are absorbed. This
practice already caught one implementation error during the 0.4.0 build, a WASPAS
runner that had inherited SMART's normalisation step by mistake. No claim is made in
this paper about the content, ranking, or timing of that expansion beyond what is
stated here: it is a stated intention, not delivered software, and readers should
treat the 10 methods in Sections 3 and 4 as the entire tested scope of the current
release.

## 7. Conclusion

MCDA computation software and survey research software currently meet only through
unpublished analyst code. This paper has described an extension to surveyframe that
closes that gap directly: 2 new item types collect pairwise judgements and
constant-sum weight allocations inside a declared survey instrument, a documented
aggregation layer turns per-respondent answers into the matrices 10 decision methods
consume, and every result records the provenance of its inputs. A worked hotel
supplier-selection example, run end to end on the package's own bundled data, shows
the same method producing 2 legitimate but different rankings depending on
declared input source, and shows a sensitivity check separating a robust top result
from a fragile full ranking. The methods covered here are 10 of a larger family. The
remainder is named as a roadmap rather than claimed as delivered work.

## References

Brans, J. P., & Vincke, P. (1985). A preference ranking organisation method: The
PROMETHEE method for multiple criteria decision-making. *Management Science*,
*31*(6), 647-656. https://doi.org/10.1287/mnsc.31.6.647

Brauers, W. K. M., & Zavadskas, E. K. (2006). The MOORA method and its application
to privatization in a transition economy. *Control and Cybernetics*, *35*(2),
445-469.

Edwards, W. (1977). How to use multiattribute utility measurement for social
decisionmaking. *IEEE Transactions on Systems, Man, and Cybernetics*, *7*(5),
326-340. https://doi.org/10.1109/TSMC.1977.4309720

Gabus, A., & Fontela, E. (1972). *World problems, an invitation to further thought
within the framework of DEMATEL*. Battelle Geneva Research Centre.

Hwang, C.-L., & Yoon, K. (1981). *Multiple attribute decision making: Methods and
applications*. Springer.

Opricovic, S., & Tzeng, G.-H. (2004). Compromise solution by MCDM methods: A
comparative analysis of VIKOR and TOPSIS. *European Journal of Operational
Research*, *156*(2), 445-455. https://doi.org/10.1016/S0377-2217(03)00020-1

R Core Team. (2026). *R: A language and environment for statistical computing*. R
Foundation for Statistical Computing.

Roy, B. (1968). Classement et choix en presence de points de vue multiples (la
methode ELECTRE). *Revue Francaise d'Informatique et de Recherche Operationnelle*,
*2*(1), 57-75.

Saaty, T. L. (1980). *The analytic hierarchy process*. McGraw-Hill.

Saaty, T. L. (1996). *Decision making with dependence and feedback: The analytic
network process*. RWS Publications.

Sharafuddin, M. A. (2026). *surveyframe: Survey Instrument Workflows* (Version
0.4.0) [Computer software]. https://github.com/MohammedAliSharafuddin/surveyframe

Si, S.-L., You, X.-Y., Liu, H.-C., & Zhang, P. (2018). DEMATEL technique: A
systematic review of the state-of-the-art literature on methodologies and
applications. *Mathematical Problems in Engineering*, *2018*, 3696457.
https://doi.org/10.1155/2018/3696457

Zavadskas, E. K., Turskis, Z., Antucheviciene, J., & Zakarevicius, A. (2012).
Optimization of weighted aggregated sum product assessment. *Elektronika ir
Elektrotechnika*, *122*(6), 3-6. https://doi.org/10.5755/j01.eee.122.6.1810
