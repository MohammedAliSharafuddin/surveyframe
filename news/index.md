# Changelog

## surveyframe 0.4.1

### New: a demo library, and a vignette that teaches from it

Twenty-two small demos, each doing one job, in `inst/extdata/demos/`.
They serve twice over: as fixtures that point at one method when
something breaks, and as worked examples somebody can follow for their
own survey. The bundled tourism and input-types instruments are
unchanged, so nothing that reads them today is affected.

``` r

sframe_demos()                            # what each one teaches
sframe_demo("two_group")                  # load one
sframe_demo("two_group", branded = TRUE)  # with a welcome page and a logo
sframe_demo_qmd("two_group")              # a Quarto notebook to run and edit
```

Together the demos reach **all 59 analysis methods and all 15 item
types**, which the test suite asserts against the package’s own dispatch
and `formals(sf_item)$type` rather than against a hand-written list. A
method added later appears as uncovered and holds the suite red until it
has a demo.

Every demo ships 4 artefacts: the instrument, the responses, a
**codebook carrying variable and value labels**, and the results
surveyframe produced. The codebook is what makes the data usable outside
R, since a plain CSV carries codes and
[`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md)
names a choice set without giving the code-to-text mapping. The results
table is the reference to compare against when the same data goes
through `psych`, SPSS, JASP, jamovi or Stata.

[`sframe_export_labelled()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_export_labelled.md)
writes an SPSS `.sav` or Stata `.dta` with the question wording and the
response options already attached, so variables read as questions rather
than as codes. `haven` joins Suggests.

[`vignette("learn-by-example")`](https://mohammedalisharafuddin.github.io/surveyframe/articles/learn-by-example.md)
works from the survey you are trying to run rather than from the
function list, with a table that picks the demo from the data you hold,
screenshots of the real exported survey, and sections on branding,
display mode, the 3 collection routes, disclosed amendments and file
verification.

Every demo belongs to one study of an event, its attendees and its
sessions, which reads as a conference, a training day, a health
promotion event, a product launch or a community meeting, so the designs
transfer to any field.

### Bug fix: reading a CSV whose matrix rows contain spaces

A matrix item expands into one column per row, so a row labelled
“Opening keynote” produces `session__Opening keynote`.
[`utils::read.csv()`](https://rdrr.io/r/utils/read.table.html) rewrites
that as `session__Opening.keynote` under its default
`check.names = TRUE`, and the column no longer matches the contract the
instrument declares.
[`sframe_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo.md)
reads with `check.names = FALSE`, and
[`vignette("learn-by-example")`](https://mohammedalisharafuddin.github.io/surveyframe/articles/learn-by-example.md)
names the trap for anyone reading a surveyframe CSV by hand.

### Reports are now reproducible, and say how they were made

**Breaking in the sense that numbers move once.**
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
gains a `seed` argument, defaulting to a fixed value. Every bootstrap
confidence interval in an analysis plan, and the parallel analysis
behind the EFA family, previously drew from the global random stream
unseeded, so the same instrument and the same data gave different
intervals on every run. Two runs on the bundled demo differed in 32 of
1768 values, and the difference reached the text a researcher would
quote:

    run 1:  U = 1576, z = -0.98, p = 0.327, r = 0.09 [0.01, 0.27]
    run 2:  U = 1576, z = -0.98, p = 0.327, r = 0.09 [0.00, 0.27]

The test statistic and the p value were stable throughout, because they
are computed analytically. Only the interval moved, which is why nothing
ever looked wrong. **Confidence intervals produced by earlier releases
are not wrong, but they are not reproducible, and re-running an analysis
under 0.4.1 will give a slightly different interval.** Pass
`seed = NULL` for the old behaviour.

Seeding also pins `mc.cores` to 1 for the duration of the run.
[`psych::fa.parallel()`](https://rdrr.io/pkg/psych/man/fa.parallel.html)
splits its simulation across forked workers whose own random streams
[`set.seed()`](https://rdrr.io/r/base/Random.html) cannot reach, and
splits the work by core count, so the result otherwise depended on the
machine it ran on. The caller’s random stream and `mc.cores` option are
both restored afterwards.

[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
now says which of its 2 engines produced the file. It prefers Quarto and
falls back to a built-in HTML writer when Quarto is absent or its render
fails, and the 2 produce materially different documents, roughly 5.8 MB
against 1.9 MB on the bundled demo. Until now both paths returned a file
path and nothing else, so a caller could not tell which they had. The
engine is now announced 3 ways: a message on the console, an `engine`
attribute on the returned path so a script can assert on it, and a line
in the report itself alongside the instrument hash. The analysis seed is
printed there too, so the artefact states what reproducing it would
take.

### Bug fix: a missing straight-lining chart now says why

[`sframe_plot_quality()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_plot_quality.md)
returned `NULL` whenever no scale had a straight-lining flag rate, and
the chart simply disappeared from the report. After this release’s
`straightline_min_items` change that became the normal case for short
scales: the bundled demo’s 5 scales are all 2 or 3 items, so every one
is recorded as unchecked and the chart vanished with nothing said. An
absent chart read as “nothing was flagged” while meaning “nothing was
long enough to check”, which are opposite conclusions.

`sframe_quality_plot_note()` returns the reason there is no chart, and
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
prints it in place of the missing figure.

### Bug fix: a mediation model’s generated lavaan syntax can now be fitted

[`sem_lavaan_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sem_lavaan_syntax.md)
wrote an indirect effect as `indirect_A_B_C := A__B*B__C` while emitting
the structural paths unlabelled, so the labels the definition multiplied
were never defined. lavaan accepted the syntax and then refused the
model at fit time with “unknown label(s) in variable definition(s)”.
This is a hard error in the single case a `cb_sem` model is most often
declared for, mediation.

A path an indirect effect walks now carries its derived label in the
structural block, so the label written on the path and the label
multiplied in the `:=` line cannot diverge. A path the author labelled
by hand keeps that label, and a model with no indirect effects generates
exactly what it did before. The total-effect line is emitted whenever
the direct path is labelled in the output, rather than only when it was
labelled by hand.

The defect was logged on 2026-08-04 and survived because the syntax
generators were tested by matching substrings. It parses. Only fitting
it reveals the problem, so the new tests fit the generated syntax to
simulated data with a known mediation structure, and check `seminr`
output by running it, rather than reading either.

### Bug fix: the Apps Script collector no longer corrupts data after an instrument change

The generated Google Apps Script collector wrote the sheet’s header row
once, when it first created the sheet, and then built every response row
positionally from `EXPECTED_COLUMNS`. Add an item to the instrument
mid-collection, regenerate the collector, redeploy it onto the same
sheet, and the header stayed as first deployed while rows arrived in the
new order. Every column from the insertion point onward was off by one.

Nothing errored. The sheet stayed well-formed,
[`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
read it without complaint, and the values were simply under the wrong
headings, so a researcher had no reason to suspect anything until an
analysis made no sense. Adding an item mid-collection is what a pilot
study does after a face-validity pass, so this is not an exotic case.

The collector is now header-driven. It reads the sheet’s live header,
appends only columns the instrument has genuinely gained, at the
right-hand end, and maps every value by name. An existing column never
moves, so rows already collected stay valid, and **a redeploy after an
instrument change is safe**.

Regression-tested by running the generated `doPost()` against a mock of
the Sheets API it calls, since the collector is JavaScript the R package
never executes and a test that only read the template would pass even if
the logic were wrong. `V8` joins Suggests as the test-time engine.

### Bug fix: multi-value `%in%` branching rules now work in exported surveys

A branching rule using `%in%` with more than 1 value never fired in an
exported survey. The gated item stayed hidden whatever the respondent
answered, with no error shown to the respondent or the researcher.
Present since 0.3.0, so every release up to 0.4.0 shipped it.

[`sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_branch.md)
documents a vector for `%in%`, and a vector serialises to a JSON array.
All 3 evaluators then disagreed about what they had been handed. The
static survey template’s JavaScript called `value.split(',')`, which an
array does not have, so the rule threw and the item stayed hidden.
`sframe_module_eval_op()` read only the array’s first element, so a rule
matched its first value and silently rejected the rest.
`.evaluate_branch()` handled arrays correctly but never split the
comma-separated string an older builder or a hand-written file carries.
Only 1 of the 6 combinations of evaluator and value shape was right.

All 3 now share `sframe_branch_in_values()` and accept both shapes, so
an instrument written before this release starts working without being
re-exported, and the 3 code paths can no longer drift apart. Verified
end to end in headless Chrome against a real exported survey: before the
fix the gated item stayed hidden for every answer, after it the item
appears for each value in the rule and stays hidden for a value outside
it.

[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
gains a `branching_values` check that flags a `%in%` rule whose value no
evaluator can consume, since the reason this survived 3 releases is that
nothing ever said a word about it.

### Bug fix: straight-lining check no longer flags short scales by default

[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)’s
straight-lining check applied to any scale with 2 or more items. On a
2-item scale, giving the same response to both items is what a genuinely
consistent respondent does, not evidence of inattention, so the check
produced a large share of false positives on short scales. Found while
proofreading the R Journal package paper against the bundled
demonstration instrument, whose 5 scales are all 2 or 3 items: the check
flagged 109 of 120 respondents (91 percent), driven almost entirely by
the three 2-item scales, each independently flagging 44 to 53 percent of
respondents.

[`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)
gains a `straightline_min_items` argument, defaulting to 4. A scale
shorter than the threshold is recorded as `checked = FALSE` with an
empty flag list, not silently skipped and not reported as a clean 0
percent pass, so a caller can tell “too short to check” apart from
“checked and nobody straight-lined it”. `print.sframe_quality_report()`
and the
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
quality table both surface the distinction. Pass
`straightline_min_items = 2` to restore the previous, more permissive
behaviour.

On the bundled demonstration instrument this drops the flag rate from 91
percent to 5 percent, all 6 remaining flags from the genuine attention
check.

## surveyframe 0.4.0

CRAN release: 2026-08-20

A major release. It adds multi-criteria decision analysis (10 methods),
small-sample statistics, text and open-ended response analysis (9
methods), and a disclosed-amendment and Git-linked provenance trail for
`.sframe` files, alongside 4 corrected results and 2 breaking changes.
See below for full detail on each.

### New: multi-criteria decision analysis (MCDA)

surveyframe’s decision-family extension links survey collection directly
to 10 MCDA methods, closing the gap between MCDA computation packages,
which assume a clean matrix already exists, and survey software, which
has no concept of a decision method at all.

- 10 decision methods: the Analytic Hierarchy Process (AHP), the
  Analytic Network Process (ANP), the Decision Making Trial and
  Evaluation Laboratory method (DEMATEL), VIKOR, MOORA, SMART, WASPAS,
  PROMETHEE, ELECTRE, and TOPSIS. Every method carries a verified
  literature citation.
- 2 new item types collect judgement data directly inside the survey
  instrument: `pairwise_comparison` (Saaty’s 1-to-9 ratio scale for AHP
  and ANP, or a 0-to-4 directed influence scale for DEMATEL) and
  `criteria_weight` (a constant-sum allocation across criteria).
- A documented aggregation layer (`R/decision_data.R`) turns
  per-respondent answers into the matrices the methods consume:
  [`sframe_assemble_pairwise()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_assemble_pairwise.md)
  builds one matrix per respondent and validates every pair was
  answered,
  [`sframe_aggregate_judgements()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_aggregate_judgements.md)
  combines them (geometric mean for AHP/ANP, which preserves
  reciprocity, or arithmetic mean for DEMATEL), and
  [`sframe_rated_matrix()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_rated_matrix.md)
  builds a performance matrix from ordinary matrix items. AHP judgements
  are additionally screened for consistency against Saaty’s random-index
  table, with the CR distribution reported whether or not a study has
  pre-declared a filtering threshold.
- Every ranking method resolves its matrix and weight inputs in the same
  order (a researcher-supplied override, then a collected item, then a
  typed error naming what is missing) and records where each input came
  from, so a results table states the provenance of every number.
- [`sensitivity_analysis()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sensitivity_analysis.md)
  reports how far a ranking moves under a declared perturbation of the
  weights, and carries a `degenerate` flag so a ranking that never
  separated its alternatives cannot report false stability (see
  “Decision analysis: non-results now say so” below).
- Both the visual builder and SurveyStudio support the 2 new item types,
  and the static HTML survey, the Shiny module, and the builder preview
  render all 3 judgement-collection structures identically.
- RMCDA joins Suggests as a test-time cross-check oracle: an independent
  computation of the same method on the same matrix is required to agree
  with the package’s own result before a method’s implementation is
  accepted. This practice caught a real defect during development, a
  WASPAS runner that had inherited SMART’s normalisation step by
  mistake.

### New: small-sample statistics

A track of corrections for comparisons run on small samples, where the
ordinary versions of these tests can flip significance on repeated draws
from data whose true difference never changed.

- The Hodges-Lehmann shift estimator as an alternative to the
  independent two-group Mann-Whitney comparison.
- The paired Wilcoxon pseudomedian confidence interval as an alternative
  to the paired t-test.
- The exact odds-ratio confidence interval on Fisher’s test for small
  2x2 tables, avoiding the ad hoc continuity correction a conventional
  Wald interval needs when a cell is zero.
- Firth’s bias-reduced logistic regression (`logistf` in Suggests) for
  regression prone to separation at small n.
- A small-sample advisory surfaced on
  [`assumption_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/assumption_report.md)
  and
  [`sample_size_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sample_size_plan.md),
  flagging when a study’s sample size falls in the range where these
  corrections are worth considering.
- `vignettes/small-sample.Rmd` walks through when to prefer each
  correction over its conventional counterpart.

### New: text and open-ended response analysis

A 9-method text-analysis family for open-ended survey items, from term
frequency through topic modelling, sharing the same analysis-plan,
role-resolution, and reporting pipeline every other method family uses.

- `term_freq`: top terms by frequency, optionally split by a group
  variable, rendered as a bar chart or a word cloud.
- `ngram_freq`: top bigrams or trigrams by frequency.
- `term_context`: a keyword-in-context concordance table (before/match/
  after) for a chosen keyword.
- `co_occurrence`: pairwise within-response co-occurrence counts on the
  top terms, rendered as a heatmap.
- `co_occurrence_network`: a Louvain-clustered (Blondel et al. 2008),
  force-directed (Fruchterman & Reingold 1991) term co-occurrence
  network; requires the optional igraph package.
- `tidy_sentiment`: positive/negative sentiment counts and proportion
  positive using the bing lexicon, optionally split by a group variable,
  rendered as a diverging bar chart or a positive/negative comparison
  word cloud; requires the optional tidytext package.
- `quanteda_dfm`: a document-feature matrix summary (feature count,
  sparsity, top features); requires the optional quanteda package.
- `topic_model_lda`: Latent Dirichlet Allocation topic modelling, top
  terms per topic as a ranked table and a faceted bar chart; requires
  the optional tidytext and topicmodels packages.
- `stm_topics`: structural topic modelling, the same top-terms-per-topic
  output; requires the optional stm and tidytext packages.
- A shared cleaning step
  ([`clean_text_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/clean_text_responses.md))
  and a 174-word Snowball-based English stopword list, both exported so
  a study can reuse or override them outside a runner.
- Both the visual builder and SurveyStudio support all 9 methods,
  including the word-cloud, top-N, seed, and topic-count (`k`) options
  that steer their plots and models.
- `vignettes/text-analysis.Rmd` walks through cleaning, each method, and
  what the family deliberately does not attempt (stemming/lemmatisation,
  tf-idf, and keyness comparison are not yet implemented).

### New: disclosed amendments and a Git-linked provenance trail

[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)’s
SHA-256 hash proves a `.sframe` file is unchanged since it was written,
but gives no way to distinguish a legitimate revision (a data-entry
correction, bot-response removal, a documented model respecification)
from an undisclosed edit – both break the hash identically. This release
adds a disclosed-revision path alongside the existing hash check,
without weakening it.

- [`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md)
  compares an instrument before and after a change and appends a
  structured, timestamped entry to an ordered amendment log – never
  overwrites – recording the reason (a controlled vocabulary:
  `data_correction`, `bot_removal`, `model_respecification`,
  `instrument_revision`, `other`), a free-text explanation, and which
  top-level fields changed.
- Two tiers, by default inferred from the reason: `"pipeline"`
  amendments (data corrections, bot removal) need only a reason.
  `"design"` amendments (anything touching the analysis plan or a model)
  require a `deviation_report` describing what changed in the research
  question, method, or model and why, matching how a formal
  preregistration deviation is normally handled. `signoff` is never left
  blank – it records a reviewer’s name or the literal `"none"`, so an
  unreviewed design change stays visible to an auditor.
- [`amendment_log()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amendment_log.md)
  returns the full history as a data frame, one row per disclosed
  amendment, exportable with
  [`write.csv()`](https://rdrr.io/r/utils/write.table.html).
- An edit made directly to a `.sframe` file, bypassing
  [`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md),
  still fails
  [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)’s
  integrity check exactly as before. The amendment log adds a disclosed
  path alongside the existing hash check.
- [`link_git_commit()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/link_git_commit.md)
  records the current Git commit SHA and subject line alongside an
  instrument. This ties the SHA-256 hash to a specific,
  already-explained commit. It returns an informative message when Git
  isn’t installed or the path isn’t a repository. Git is optional.
- `inst/schema/sframe_schema.json` documents the `.sframe` format (every
  top-level field, including the new `amendments` log) as a standalone
  JSON Schema, so a reviewer or a second tool can read and validate a
  `.sframe` file without installing the package. `.sframe` was already
  plain, git-diffable JSON before this release; the schema makes that
  format explicit and independently checkable.
- `vignettes/surveyframe.Rmd` gains a “What the SHA-256 hash proves, and
  what it does not” section, stating plainly that the hash proves file
  identity, not methodological validity, and pointing to the design-time
  `analysis_plan` binding and
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)’s
  single-pass execution as the package’s separate, complementary defence
  against HARKing and p-hacking.

### Corrected results (read before comparing against earlier output)

Four defects found by independent cross-validation are fixed. Each
produced normal-looking numbers with no error or warning, so re-run any
results computed with an earlier version.

- [`item_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/item_report.md)
  returned the wrong item-rest correlation. It subtracted each item from
  a [`rowMeans()`](https://rdrr.io/r/base/colSums.html) total, which
  leaves roughly noise carrying the item negatively, so a highly
  reliable scale reported strong negative values. On simulated data with
  alpha 0.947 every item came back at about -0.46. The statistic is now
  the item against the sum of the other items in its scale, and matches
  [`psych::alpha()`](https://rdrr.io/pkg/psych/man/alpha.html)’s
  `item.stats$r.drop` to 1e-10.
- Repeated-measures ANOVA tested the condition effect against the wrong
  error term, because the subject identifier was left as an integer and
  [`aov()`](https://rdrr.io/r/stats/aov.html) treated it as a continuous
  covariate. On a fixture where
  [`jmv::anovaRM()`](https://rdrr.io/pkg/jmv/man/anovaRM.html) gives
  F(2, 78) = 86.93, surveyframe reported F = 1.45, p = 0.24. Correcting
  the identifier alone was not sufficient: the corrected design produces
  no `Error: Within` stratum, so the effect is now located by searching
  the strata directly.
- [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
  rejected valid instruments. Its known-variable list held only base
  item and scale ids, so an analysis plan naming an expansion column
  (`item__sub`, `item__option`, `item__a__vs__b`, `item__crit`) failed
  validation for variables that do exist, including real exports from
  the visual builder.
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  already accepted those columns. Both now derive the list from one
  shared helper.
- The SEM syntax generators ignored the model type.
  [`seminr_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/seminr_syntax.md),
  [`sem_lavaan_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sem_lavaan_syntax.md),
  and
  [`cfa_lavaan_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_lavaan_syntax.md)
  never checked `model$type`, and the builder offered every saved model
  to all 3 generators, so a covariance-based model produced PLS-SEM
  syntax with no complaint. That is a runnable script estimating a model
  the researcher never declared. All 3 now refuse a mismatched
  estimation family, and the builder filters each model role to the
  types its generator can produce.

### Breaking: `validate_sframe()` and `validate_model()` return a diagnostic

Both validators previously returned two different things depending on
`strict`: the object itself, invisibly, when `strict = TRUE`, and a bare
unclassed list when `strict = FALSE`. Neither was a diagnostic, the
success path printed nothing at all, and the `strict = FALSE` return had
no methods. Both now return an `sframe_validation` object, and they
return it visibly, so `validate_sframe(instrument)` typed at the console
shows the user what it found.

- The object records `valid`, every `problems` message, and a `checks`
  table listing all 18 instrument checks (10 for a model) whether or not
  each found anything. A diagnostic that lists only failures cannot tell
  a user that a check passed from one that was never reached.
- Read it with [`print()`](https://rdrr.io/r/base/print.html),
  [`summary()`](https://rdrr.io/r/base/summary.html) for the check
  roster, [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html)
  for one row per problem,
  [`sf_is_valid()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md),
  and
  [`sf_problems()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_validation_accessors.md).
- `strict = TRUE` still aborts with `sframe_validation_error` when
  anything is wrong. That has not changed.
- **`$valid` and `$problems` keep working**, so the common reading
  pattern needs no migration.
- **What breaks**: code using the `strict = TRUE` return as an
  instrument, as in `instrument <- validate_sframe(instrument)`. Wrap it
  in
  [`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md).
  Passing a validation result where an instrument is expected now raises
  a directed error naming
  [`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md)
  immediately.

Raised by a Journal of Statistical Software editor reviewing the code:
“we would at least expect that the object is not silently returned and
that the print method is adapted to allow the user to read directly the
diagnostic”.

### New: accessor and exploration methods for every class

The same review found that the classes carried `print`, `summary` and
`format` only, so user code had no route to their contents except `$` on
the underlying list, which makes the internal layout part of the public
contract. Two facts made that concrete:
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) failed on
all 14 result classes with “cannot coerce class … to a data.frame”, and
`[` dropped the class on the list-backed reports, so `results[1:2]`
silently degraded to a bare list and lost its print method.

- [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) now
  works on the instrument and on every report class, returning that
  object’s primary table.
- `[` keeps the class on `sframe_analysis_results`,
  `sframe_reliability_report` and `sframe_item_report`.
- Instrument accessors:
  [`sf_meta()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
  [`sf_items()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
  [`sf_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
  [`sf_choice_sets()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
  [`sf_branches()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
  [`sf_checks()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
  [`sf_models()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md)
  and
  [`sf_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_accessors.md),
  with `sf_plan<-` for declaring the plan. The component accessors
  return an `sf_component_list` named by ID, so
  `sf_items(instrument)[["sat_1"]]` reaches one item.
- Component accessors:
  [`sf_id()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_identity.md)
  and
  [`sf_label()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_identity.md).
- Report accessors:
  [`sf_apa()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_report_accessors.md)
  and
  [`sf_flagged()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_report_accessors.md).
- Coercion:
  [`as_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/as_sframe.md).

The vignettes and the examples are rewritten to use these accessors. The
registered S3 method count goes from 41 to 103.

### Breaking: the Shiny collector now emits expansion columns

- [`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
  pipe-joined a matrix item’s cells into a single column, so a matrix
  question answered in the Shiny survey arrived as `mx = "4|5"` where
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  and the whole analysis layer expect `mx__r1` and `mx__r2`. Data
  collected that way could not be read back by the package at all, and
  nothing said so at collection time. Ranking and multiple-choice items
  had the same shape problem.
- All 3 now emit the expansion columns that the static template and the
  Google Sheets collector already emitted: one column per matrix
  sub-item carrying its value, one per ranking option carrying its rank
  position, and one per multi-select option carrying 0 or 1.
- **This changes the output shape of the Shiny collector.** A study
  mid-collection through
  [`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
  will see its matrix, ranking, and multi-select columns change name and
  layout between versions. Responses already gathered under the old
  shape need re-shaping before they can be read, and the decision item
  types are unaffected because they emitted the correct columns from the
  start.

### The rated performance matrix can now be wired in both GUIs

- SurveyStudio and the visual builder both offered an empty “Performance
  matrix items” dropdown for all 7 ranking methods (TOPSIS, VIKOR,
  MOORA, SMART, WASPAS, PROMETHEE, ELECTRE). That role matches on a
  `"matrix"` level, and neither surface gave matrix items one: the
  studio classified them as `"identifier"` and the builder grouped them
  under `"expanded"`, which no role accepts. The effect was that the
  rated-matrix path, where respondents rate every alternative on every
  criterion, could only be built by writing R directly, even though it
  is one of the 3 declared ways to supply a decision matrix. Matrix
  items now carry their own `"matrix"` level in both surfaces.

### Decision analysis: non-results now say so

- ELECTRE I reports when it establishes no outranking relation at all.
  On a 9-criterion problem at the default 0.70 and 0.30 thresholds no
  alternative clears concordance against any other, so every score is 0
  and every alternative ranks 1. That is legitimate behaviour for the
  method, but the results table read as “all 9 alternatives are jointly
  best” and the APA sentence reported a kernel containing every
  alternative. A note now explains the equal ranks as an absence of
  evidence.
- [`sensitivity_analysis()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sensitivity_analysis.md)
  gains a `degenerate` flag for the same reason. A ranking that never
  separated the alternatives cannot be changed by perturbing a weight,
  so every check passed and `stable` came back `TRUE`: the strongest
  robustness signal the function can give, produced by the weakest
  result it can be handed.
  [`print()`](https://rdrr.io/r/base/print.html) now leads with “No
  result to test” instead of “Stable” in that case.

### Data quality

- [`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)
  counted only columns matching a bare item id, and multi-column items
  never post under those, so every expansion column was invisible to the
  missingness check. A respondent who skipped an entire pairwise battery
  was reported at 0 percent missing. Expansion columns now count as item
  data, which brings matrix, ranking, multi-select, and the 2 decision
  item types into the missingness figures for the first time. **Reported
  missingness rates will change for any instrument using those item
  types**, because columns that were silently excluded are now counted.
  Straight-lining and timing are unaffected: straight-lining runs over
  declared scales, and timing is measured on the clock.

### Bundled demo data

- Both bundled demo instruments wired their seminr block to a `cb_sem`
  model, so
  [`sframe_demo_data()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo_data.md)
  generated PLS-SEM syntax from a covariance-based model, and every
  vignette and example loading it inherited the same mismatch. Each demo
  now carries a real `pls_sem` model with composite constructs. The
  instrument hashes changed with it.

### Decision analysis

- All 10 MCDM methods now return a citation. Previously only TOPSIS and
  AHP had one. Every reference was checked against the publication
  record.
- [`sframe_decision_options()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_decision_options.md)
  documents PROMETHEE’s preference functions and records why the default
  is `"usual"`, Brans and Vincke’s type I step function, chosen over the
  linear function several other implementations default to. Net flows
  differ between the 2 functions, and the ranking changed in 226 of 400
  randomly drawn 4-alternative by 3-criterion matrices.

## surveyframe 0.3.4

CRAN release: 2026-07-24

This release completes the plotting, interface, statistics, and
reporting work started in 0.3.3. Every analysis family now has a chart,
every effect size ships with a confidence interval, reports accept
written interpretations and print to PDF, both dashboards gain quality
and correlation panels, date questions gain bounds, and the builder and
vignettes pass a WCAG 2.2 AA accessibility audit. Hard dependencies are
unchanged. naniar and pagedown join Suggests.

### Effect sizes and intervals

- Four new exported helpers, all base R:
  [`bootstrap_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/bootstrap_ci.md)
  (percentile bootstrap for any statistic),
  [`cohens_d_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cohens_d_ci.md),
  [`cramers_v_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cramers_v_ci.md),
  and
  [`eta_sq_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/eta_sq_ci.md).
- Analysis-plan runners attach a confidence interval to their effect
  size as a new result key: `d_ci` on the t-tests, `r_ci` on
  Mann-Whitney and Wilcoxon, `eta_ci` on ANOVA and Kruskal-Wallis, `ci`
  on the correlations (analytic Fisher z for Pearson, bootstrap for the
  rank methods), and `v_ci` on chi-square and cross-tabulation.
- APA strings and writing prompts now carry the interval, for example
  `d = 0.62 [0.18, 1.05]`. Data too small for an interval keeps the
  previous string.

### Psychometrics

- [`validity_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validity_report.md)
  computes the Henseler heterotrait-monotrait ratio when item-level data
  is supplied through the new `items_by_construct` argument. Without it,
  the previous correlation-based fallback applies and the `htmt_method`
  element records which was used.
- [`missing_data_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/missing_data_report.md)
  runs Little’s MCAR test when naniar is installed. Without naniar the
  result is unchanged.
- [`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)
  records why omega is unavailable for a scale in an `omega_note`, and
  the reliability chart names those scales in its subtitle.
- [`efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_solution.md)
  adds three tidy data frames ready for plotting and reporting:
  `loadings_long`, `communalities_table`, and `variance_table`.

### Reports and codebook

- `render_report(format = "pdf")` prints the HTML report to PDF through
  pagedown, which requires a local Chrome or Chromium. HTML output is
  unchanged and remains the default.
- The report’s built-in styling now uses a small set of CSS variables,
  so a re-theme is a one-line change, and a print stylesheet paginates
  the report cleanly. Tables carry captions and header scopes, and every
  embedded chart has descriptive alternative text.
- The codebook now includes the pre-declared analysis plan and the saved
  measurement and structural models, so one document fully records the
  instrument a study used.
- The codebook’s items table shows each item’s actual response options
  and scale label directly, instead of an id that needed a separate
  choice-sets table to decode.
- Analysis-result tables (frequency, cross-tabulation, group
  comparisons, regression coefficients, and the rest) show item, scale,
  and response-option labels instead of the underlying ids and coded
  values.
- Report tables render as properly split HTML tables in both the Quarto
  and internal HTML report paths.

### Written interpretations in reports

- New `interpretations` argument on
  [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
  and
  [`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md).
  Pass a named list keyed by analysis-plan block id to add a written
  interpretation to each research question after the results are known.
  The report shows it beside the pre-declared decision rule, so the
  prospective plan stays visible next to the post-hoc narrative.
  Interpretations are report content only and are never written into the
  instrument file.
- SurveyStudio’s Export screen gains an Interpretations card: one block
  per research question, in reading order (result table, chart, planned
  decision rule, then the interpretation), shown with the live result
  once responses are loaded. The generated report includes whatever you
  write there.
- A “Copy result” button on each Interpretations block copies the whole
  result, table, chart, and the interpretation as written, as one block,
  for pasting into a document.
- The SurveyBuilder Report outline now edits the planned decision rule
  inline, in sync with the research-question dialogue.

### Charts

- `run_analysis_plan(plots = TRUE)` now attaches a chart to every
  supported family: regression diagnostics (4 panels), EFA scree and
  loadings heatmap, reliability bars, mosaic and crosstab, correlation
  heatmap, quality flag rates, group-comparison boxplots, paired slope
  charts, raw-variable distributions, repeated-measures profiles, a
  partial-correlation residual scatter, logistic-regression odds-ratio
  forest plots, a moderation interaction plot, and a mediation effect
  chart. Every analysis-plan block now returns a table, a chart, or
  generated syntax.
- Distribution shape by variable draws as a violin per variable, instead
  of a bar chart of the skewness and kurtosis summary statistics.
- A scale’s separate Likert items, and a matrix question’s rows, draw as
  one grouped diverging chart, instead of one chart per item.
- New [`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods
  for descriptives, EFA, quality, reliability, validity, missing-data,
  and analysis-results objects. `plot(results)` draws every attached
  chart, and `plot(results, which = "rq_id")` returns one.
- New `plot_palette` argument on
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
  and
  [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md):
  `"web"` for brand colour on screen, `"print"` for black and white
  suitable for print and journal submission. SurveyStudio exposes the
  choice as a Chart theme option on the Export screen.
- SurveyStudio’s Analyse screen shows one result card per research
  question with its chart beneath the statistic.
- Both dashboards (the standalone response dashboard and the
  SurveyStudio Dashboard tab) gain a straight-lining flag-rate chart, a
  missing-data chart, and a scale-score correlation heatmap. All
  dashboard charts keep a base-graphics fallback, so ggplot2 remains
  optional.

### Survey design

- Date questions accept `date_min` and `date_max` bounds in
  [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md),
  the SurveyBuilder, and the exported survey. The date picker enforces
  the bounds and typed dates outside them show a clear message.
- The SurveyBuilder ships a library of 14 preset choice sets,
  regenerates item ids safely when the response type changes, and
  expands matrix, ranking, and multiple-choice items into the same
  per-option variables that
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  produces.
- The survey thank-you page no longer forces a CSV download. It offers a
  “Download my response” button and honours a configured redirect.

### Accessibility

- The SurveyBuilder interface passes an instrumented WCAG 2.2 AA audit
  with zero findings across its build, preview, and analyse screens and
  dialogues.
- All 7 vignettes pass the same audit: language metadata, AA contrast
  for links and code highlighting, wrapped code blocks,
  keyboard-reachable content, and alternative text on every chart.

### Bug fixes

- [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md)’s
  `date_min` and `date_max` accept only `"YYYY-MM-DD"` or a `Date`
  object now (an ambiguous string such as `"01/02/2024"` used to parse
  silently into a specific date depending on locale). Anything else
  raises a validation error.
- [`bootstrap_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/bootstrap_ci.md),
  [`cohens_d_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cohens_d_ci.md),
  [`cramers_v_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cramers_v_ci.md),
  and
  [`eta_sq_ci()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/eta_sq_ci.md)
  no longer alter the random-number seed for code that runs after a
  reproducible, seeded call.

## surveyframe 0.3.3

CRAN release: 2026-07-11

This release adds an opt-in plotting layer, fixes bugs surfaced by the
package’s first field deployment, and redesigns the survey-taking
experience. ggplot2 joins Suggests; hard dependencies are unchanged.

### Analysis and plotting

- New `plots` argument on
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
  (default `FALSE`). When `TRUE`, supported analysis blocks return a
  ggplot object in `$plot`: bar charts for frequency and chi-square
  blocks, and scatter plots with a regression overlay for correlation
  and regression blocks.
- New exported
  [`theme_surveyframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/theme_surveyframe.md),
  a publication-oriented ggplot2 theme with an accessible fixed-order
  series palette. All plots use it.
- Inferential runners return a `$table` data frame ready for
  [`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html); the HTML
  report shows these tables automatically.
- Frequency and cross-tab runners treat empty strings as missing values,
  so partially completed responses no longer form a blank category.
- Ranking items now export one column per option holding its rank
  (`item__option = 1` for the top choice), so ranks are directly
  analysable. Multiple-choice items likewise export one 0/1 column per
  option instead of a single comma-joined column.
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  accepts the expanded columns for ranking, matrix, and multiple-choice
  items without warnings.
- [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
  now attaches each analysis block’s chart directly under its result
  table, in both the Quarto and internal HTML report paths, instead of
  tables and plots appearing in separate places.
- Likert items in the report’s response-distributions section get a
  diverging stacked bar chart (darkest at each pole, lightest next to
  neutral) instead of a plain frequency bar, so the direction and
  strength of opinion is visible at a glance.

### Survey experience

- A full redesign of the exported survey: larger serif question
  typography, bordered option cards with selection ticks, numbered
  Likert squares, restyled matrix, slider, and ranking blocks, and a
  slim top progress bar. Every colour derives from the instrument’s
  single theme colour, so one colour choice re-skins the whole survey.
  Touch targets meet a 44 pixel minimum on phones.
- Branching rules on one question now combine with AND, and hiding a
  controlling question also hides everything that depends on it, so
  screening logic behaves as declared even when answers change.
- Single-page surveys show answered-questions progress (for example “12
  of 44 answered”); numeric questions respect declared minimum and
  maximum bounds.
- Branching rules can now show and hide section breaks and text blocks,
  so a branched text block works as a screen-out message (“Sorry, you
  are not eligible”) and section headings disappear with their
  questions.
- A matrix question reflows into stacked, labelled row-cards below 600
  pixels instead of a table that needs horizontal scrolling to complete.
- The exported survey meets WCAG 2.2 AA on an instrumented audit: every
  input carries an accessible name, keyboard focus is visible on option
  cards, errors are announced to assistive technology, required
  questions are marked beyond colour, ranking items gain keyboard
  reorder buttons, headings are real headings, and all touch targets and
  text contrast meet the standard.

### Data collection

- Fixed a bug that silently blocked submissions from hosted surveys: the
  Google Apps Script POST now avoids the CORS preflight that Apps Script
  never answers. Collectors no longer emit columns for section breaks or
  text blocks.
- [`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md)
  gains a `meta_cols` argument for extra sheet columns a host
  application appends, and SurveyStudio’s dashboard now computes
  completion times from imported sheet responses.

### Model syntax

- [`sem_lavaan_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sem_lavaan_syntax.md)
  turns free-text path labels into valid lavaan parameter names (a label
  starting “H1:” becomes the parameter `H1`).
- [`seminr_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/seminr_syntax.md)
  output loads seminr and uses
  [`summary()`](https://rdrr.io/r/base/summary.html) accessors, so the
  generated code runs as pasted.
- [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
  accepts `pls_sem` as an alias for `seminr_syntax`.

### SurveyBuilder and report

- Opening a `.sframe` verifies and reports its SHA-256 integrity status.
- New choice questions start with a fresh option set, and editing shared
  options forks the set first, so options never leak between questions.
- The analysis-plan modal blocks using one variable in two roles, and
  the test suggester handles Likert items and multi-group comparisons
  sensibly.
- Reports print generated model syntax in code blocks and show
  reliability results as a table.
- “+ Add question” now opens the question-type picker instead of
  silently adding a Likert item, and the redundant icon-only button next
  to it is gone. Survey settings live only in the sidebar; the top bar
  no longer duplicates that entry point.

## surveyframe 0.3.2

CRAN release: 2026-06-17

This release corrects the package citation, completes the S3 method
surface for the component classes, and improves the graphical tools and
the HTML report. It adds no new exported functions, no new statistical
methods, and no new bundled datasets.

### Citation and methods

- `inst/CITATION` now reports the correct package title and reads the
  version dynamically from the package metadata, so the citation no
  longer pins an old version or an outdated title.
- Added [`print()`](https://rdrr.io/r/base/print.html),
  [`format()`](https://rdrr.io/r/base/format.html), and
  [`summary()`](https://rdrr.io/r/base/summary.html) methods for the
  component classes `sf_choices`, `sf_item`, `sf_scale`, `sf_branch`,
  `sf_check`, and `sf_model`, so each class now has a visible,
  documented S3 surface.
- `lavaan` is declared in `Suggests`. It is used only to fit the syntax
  produced by
  [`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md).
  The package itself generates syntax and never requires `lavaan` to be
  installed.

### Graphical tools

- SurveyBuilder exports a deployable survey in the browser through a new
  Export survey button, and generates the Google Sheets Apps Script
  collector through a Generate collector button. Both reuse the same
  templates the R functions use, so the output matches
  [`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md)
  and
  [`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md).
- The builder Analyse tab shows three distinct stages: Plan, Run preview
  (the methods that need response data), and Report outline (analyses
  plus measurement models). Analysis plans can be reordered by dragging.
- The exported survey carries a “Built with surveyframe” footer, sizes a
  header logo consistently across aspect ratios, shows a page progress
  indicator only on multi-page surveys, and gains a mobile layout.
- SurveyStudio opens an instrument designed in the builder, previews the
  exact deployable survey in a frame, and analyses uploaded responses.
  The response dashboard, with an overview, item and scale
  distributions, and a raw-data table, is now built into the studio. A
  button loads the bundled sample survey and 120 responses. Survey
  design moved entirely to the builder.

### HTML report

- [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
  renders reliably through Quarto when it is installed. A path defect
  that made the Quarto render fail and fall back to the plain internal
  output is fixed.
- Reports include a response distributions section, with one chart per
  item and one per scale, in both the Quarto output and the built-in
  HTML fallback.
- Tables are formatted, wide tables scroll within the page, the table of
  contents sits on the left, and numeric values are rounded to two
  decimal places.

### Documentation

- Added the “Deploying a survey and collecting responses on free
  hosting” vignette, covering the Apps Script collector, GitHub Pages
  and Blogger hosting, and reading the responses back into R.

## surveyframe 0.3.1

CRAN release: 2026-06-02

This is a patch release. It fixes the static-survey to Google Sheets to
R collection loop, repairs a serialisation defect, and improves the
first-time user experience. There are no new exported functions, no new
statistical methods, and no new bundled datasets.

### Bug fixes

#### Data collection round-trip

- [`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md)
  now renders the header logo and institution name from `render$header`,
  so exported surveys match the Shiny renderer and the builder preview.
- [`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md)
  now falls back to the instrument’s `render$google_sheets_endpoint`
  when `endpoint_url` is not supplied, so a Google Sheets endpoint set
  in the builder is honoured on export.
- The static survey now posts the respondent identifier under the column
  name `respondent_id`, matching the Google Apps Script collector and
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md).
  The collection round-trip now preserves the identifier.
- [`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md)
  now includes matrix sub-item columns (`item_id__sub`) in the Apps
  Script header row, so matrix answers are stored in the Sheet.
- [`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md)
  now declares `started_at` as a meta column and no longer raises a
  warning on every read.
- Survey logos now keep their original MIME type (`image/png`,
  `image/jpeg`, `image/gif`), so JPEG and GIF logos display correctly in
  the builder, the Shiny renderer, and the static export.

#### Serialisation

- [`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
  now strips list-level names from the item, choice, scale, branching,
  check, and model collections before serialisation. Instruments built
  with [`Map()`](https://rdrr.io/r/base/funprog.html) or other helpers
  that attach element names (for example, using item IDs as names)
  previously serialised those collections as keyed JSON objects,
  producing a hash mismatch and an integrity error on
  [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md).
  Saved instruments now round-trip correctly regardless of how the
  component lists were constructed.

### User experience

- Every exported function that takes an instrument now reports a clear,
  actionable message when passed something that is not an `sframe`
  object. The message points the user to
  [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md)
  and
  [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
  instead of showing a raw
  [`inherits()`](https://rdrr.io/r/base/class.html) assertion failure.
- [`reliability_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/reliability_report.md)
  no longer prints `psych` internal warnings to the console. McDonald’s
  omega is skipped silently for scales with fewer than three items,
  where the statistic is not meaningful.
- The error message from
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
  when no analysis plan is present now describes both the programmatic
  route (`instrument$analysis_plan`) and the visual SurveyBuilder route.

### Documentation

- Rewrote the main vignette (`surveyframe.Rmd`) as an end-to-end worked
  example: design the questionnaire, export it as a hosted survey with a
  Google Sheets backend, collect responses, score them, run the analysis
  plan, and render a report. The results section uses simulated
  responses so the vignette builds offline; a single
  [`read_sheet_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sheet_responses.md)
  call connects the same workflow to live responses. The questionnaire
  and concept are adopted from Sharafuddin, Madhavan, and Wangtueai
  (2024, *Administrative Sciences*, 14(11), 273,
  <doi:10.3390/admsci14110273>), with generic destination wording so the
  example transfers to any tourism services context.
- Updated the supporting vignettes to reflect the research-design-first
  workflow where the instrument holds the questions, the analysis plan,
  and the measurement model.
- [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md)
  examples now include a complete `analysis_plan` block.
- The README now leads with `install.packages("surveyframe")`, adds a
  short path for users who already have a response CSV, and points to
  `browseVignettes("surveyframe")`.

## surveyframe 0.3.0

CRAN release: 2026-05-27

The first CRAN release of the full workflow: a typed instrument object
carrying the questions, the analysis plan, and the measurement model,
with deployment, collection, analysis, and reporting built around it.

### New features

#### Analysis planning, survey statistics, and model syntax

- Added a role-based analysis-plan structure while preserving old
  `variables`/`test` analysis blocks. New plans can store `family`,
  `method`, `roles`, `options`, `hypotheses`, `decision_rule`,
  `reporting_references`, `status`, and `requires_data`.
- Added common survey analysis helpers:
  [`descriptives_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/descriptives_report.md),
  [`missing_data_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/missing_data_report.md),
  [`assumption_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/assumption_report.md),
  [`posthoc_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/posthoc_report.md),
  [`validity_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validity_report.md),
  and
  [`sample_size_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sample_size_plan.md).
- Expanded
  [`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
  to dispatch the v0.3 method registry, including descriptives, missing
  data, sparse-table tests, related-sample tests, Kendall and partial
  correlations, two-way ANOVA, ANCOVA, repeated ANOVA, ordinal and
  multinomial logistic regression, mediation, moderation, and
  model-syntax output.
- Added a model specification layer:
  [`sf_construct()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_construct.md),
  [`sf_path()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_path.md),
  [`sf_covariance()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_covariance.md),
  [`sf_indirect()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_indirect.md),
  [`sf_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_model.md),
  [`validate_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_model.md),
  [`model_json()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/model_json.md),
  [`add_model()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/add_model.md),
  [`efa_solution()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_solution.md),
  [`efa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/efa_syntax.md),
  [`cfa_lavaan_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_lavaan_syntax.md),
  [`sem_lavaan_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sem_lavaan_syntax.md),
  [`seminr_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/seminr_syntax.md),
  and
  [`model_report_template()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/model_report_template.md).
  Syntax generation does not require `lavaan` or `seminr`.
- [`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md)
  remains available as a backward-compatible wrapper around
  [`cfa_lavaan_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_lavaan_syntax.md).
- SurveyBuilder Analyse mode now uses a three-panel Plan/Run/Report
  workspace with variable metadata badges, role-based variable
  assignment, method options, output preview, reporting references, and
  a table-based model builder. Significance level is shown only for
  inferential methods.

#### Static HTML survey export

- Added
  [`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md).
  This produces a single, self-contained HTML file that runs the survey
  in any modern browser without a Shiny server or an internet
  connection. All thirteen item types are fully rendered (Likert, single
  choice, multiple choice, matrix, numeric, text, long text, date,
  slider, rating, ranking, section break, text block). Branching logic,
  required-field validation, a progress bar, welcome and thank-you pages
  are all handled in client-side JavaScript. On submission the browser
  downloads a per-respondent CSV file. An optional `endpoint_url`
  argument adds a parallel JSON POST to any serverless endpoint (Google
  Apps Script, Netlify function, etc.).

  The exported file is suitable for hosting on GitHub Pages, Netlify, or
  any static file server, and can also be shared directly as an e-mail
  attachment and opened from disk.

  The SHA-256 hash written into `.sframe` files by
  [`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
  and by the SurveyBuilder HTML is computed using the same
  canonicalisation algorithm, so instruments round-trip correctly
  between the browser and R.

#### Interactive response dashboard

- Added
  [`launch_dashboard()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard.md).
  Opens a five-panel Shiny dashboard for exploring collected response
  data alongside the instrument definition, without modifying either.
  The panels are: Overview (response count, date range, instrument
  metadata), Items (per-item bar charts, histograms, and frequency
  tables), Scales (scale score distributions with mean overlay), Quality
  (attention-check pass rates), and Raw data (a scrollable response
  table with CSV download).

  When called without arguments the dashboard loads the bundled tourism
  services demo. When called with a user-supplied instrument and no
  `responses` argument, it opens in metadata-only mode showing
  instrument structure.

- Added
  [`sframe_demo_data()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_demo_data.md),
  [`sframe_input_types_demo_data()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_input_types_demo_data.md),
  [`launch_builder_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder_demo.md),
  [`launch_studio_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio_demo.md),
  and
  [`launch_dashboard_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard_demo.md)
  for CRAN-safe examples, training, and local GUI testing.

- Added a bundled input-types demo instrument and simulated response
  dataset for testing SurveyBuilder, SurveyStudio, the dashboard, and
  all supported item controls.

- [`launch_studio()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio.md)
  now accepts preloaded instruments, response data frames, CSV response
  paths, initial screen selection, host, port, and browser control.
  SurveyStudio reads these preloaded values during startup.

#### Shiny survey module

- Added
  [`survey_module_ui()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_ui.md)
  and
  [`survey_module_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_server.md).
  These allow a survey to be embedded inside a larger Shiny application
  as a first-class module.
  [`survey_module_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_server.md)
  returns a `reactive` that holds `NULL` until the form is submitted,
  then returns the response as a named list keyed by item ID.

  ``` r

  ui <- fluidPage(survey_module_ui("s1"))
  server <- function(input, output, session) {
    resp <- survey_module_server("s1", instrument = instr)
    observeEvent(resp(), { saveRDS(resp(), "response.rds") })
  }
  ```

  An optional `on_submit` callback fires immediately on submission,
  before any
  [`observeEvent()`](https://rdrr.io/pkg/shiny/man/observeEvent.html)
  elsewhere in the app.

#### Extended analysis plan tests

[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md)
now implements four additional tests used by the SurveyBuilder’s test
dropdown:

- `anova_one`: One-way ANOVA with eta-squared effect size. When the
  result is significant and there are more than two groups, Tukey HSD
  post-hoc output is included in the result object.
- `t_test_pair`: Paired-samples t-test with Cohen’s d_z.
- `wilcoxon_pair`: Wilcoxon signed-rank test with r effect size.
- `regression_logistic_binary`: Binary logistic regression with McFadden
  R-squared and an overall model chi-square test. The full coefficient
  table is returned for interpretation.

All four runners produce an APA-formatted summary string and an
interpretation `prompt` field to guide write-up.

### Bug fixes

- [`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
  validates the instrument and writes the validated object, preserving
  `meta$validated = TRUE` in the saved `.sframe` file.

- `.sframe` serialisation now includes a `models` field and continues to
  read older `.sframe` files where `models` is absent.

- [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md)
  no longer requires display-only items such as `section_break` and
  `text_block` to appear as response columns.

- [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)
  now checks model references, analysis-plan roles, invalid model IDs,
  duplicate model IDs, and model indicator/path integrity.

- `launch_builder(open = TRUE)` opens the SurveyBuilder HTML in the
  system’s default browser via
  [`utils::browseURL()`](https://rdrr.io/r/utils/browseURL.html).

- `R/studio_builder.R` contains three fully implemented internal
  functions (`sframe_builder_empty_state`,
  `sframe_builder_state_from_instrument`,
  `sframe_builder_validate_draft`) used by SurveyStudio startup and
  draft validation.

- SHA-256 hashing in the SurveyBuilder HTML includes a pure-JavaScript
  fallback for environments where `crypto.subtle` is unavailable on
  `file://` origins, including common Firefox `file://` configurations.
  Saving a `.sframe` file from the builder now always succeeds.

- The SurveyBuilder’s `rqSuggest` box now appears with an icon and a
  plain-language recommendation when two or more variables are selected
  in the RQ modal.

- The undo and redo buttons in the SurveyBuilder topbar are now
  correctly disabled when their respective history stacks are empty.

### Security hardening

- [`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md)
  now writes Google Apps Script using JSON-encoded JavaScript literals
  instead of interpolating instrument metadata directly into executable
  code. The generated endpoint also rejects missing, over-large, and
  non-object JSON POST bodies.
- SurveyStudio upload handlers now validate uploaded `.sframe` and
  `.csv` files by extension, size, and text-content checks before
  passing them to import functions.
- [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
  now validates the top-level `.sframe` payload structure before hash
  verification and object reconstruction.
- Internal HTML report generation now applies escaping consistently to
  report titles, instrument metadata, citations, and effect labels.
- Quarto report rendering now cleans temporary render directories and
  RDS files with [`on.exit()`](https://rdrr.io/r/base/on.exit.html) even
  when rendering fails.

### Documentation

- [`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md),
  [`score_scales()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/score_scales.md),
  [`codebook_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/codebook_report.md),
  [`cfa_syntax()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/cfa_syntax.md),
  and `launch_builder(open = FALSE)` have fully runnable examples.
- Reworked the vignette set into a coherent workflow covering instrument
  building, response analysis, reliability and validity, EFA/CFA/SEM/PLS
  syntax generation, and GUI usage.
- The demo launchers
  ([`launch_builder_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder_demo.md),
  [`launch_studio_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio_demo.md),
  and
  [`launch_dashboard_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard_demo.md))
  open in the browser with the demo instrument, scales, and analysis
  plan preloaded, so no manual file loading is needed.
- The interactive package demo (`demo("survey")`) walks through the
  whole workflow with step-by-step prompts.

### Dashboard and report polish

- The dashboard parses response dates in the common formats (ISO 8601,
  date-only, UK and US day orders) instead of erroring on non-standard
  strings, colour-codes quality rows by flag status, matches the
  download button to the active theme, and draws the Items and Scales
  charts as soon as their tabs open.
- HTML report tables use APA formatting, with horizontal rules only and
  a significance footnote added automatically when a p-value column is
  present.

## surveyframe 0.1.0

- Initial release.
- Core S3 object system:
  [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md),
  [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md),
  [`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md),
  [`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md).
- Serialisation:
  [`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md),
  [`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
  with SHA-256 integrity checking.
- Shiny survey renderer:
  [`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md).
- Static SurveyBuilder HTML:
  [`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md).
- Response reader:
  [`read_responses()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_responses.md).
