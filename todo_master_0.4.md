# todo_master_0.4.md — the canonical task list for CRAN 0.4.0, 0.4.1, and 0.4.2

Dev-only planning file, tracked on `dev` only. Add its name to `.gitignore`
on `main` and to `.Rbuildignore` (see A7 and C7 below, which cover the
whole ignore-file gap).

Written 2026-07-30. **This is the single entry point for release work from
here.** The per-release files stay in place for their detail: `todo_0.4.md`
(the 0.4.0 engineering spec, merged 2026-08-15 from the previously
separate MCDM/DEMATEL file and the small-sample file, both fully built),
`todo_0.4.1.md` (the 0.4.1 demo patch), `todo_0.3.5.md` (superseded,
absorbed), `todo_rstudio_addin.md`, and `todo_0.5.md` through
`todo_1.0.md` for later releases.

---

## Version numbering: branch labels versus CRAN versions

**Branches and worktrees keep their historical labels regardless of CRAN
version** (owner decision 2026-07-30). `todo_*.md` planning files are
different: renumbered 2026-08-15 to match CRAN version numbers directly,
closing the mismatch that caused repeated confusion through this release.
Full detail and the historical rename mapping: `CLAUDE.md`'s
version-numbering section.

| Branch/worktree label (unchanged) | CRAN version | Planning file (renamed 2026-08-15) |
|---|---|---|
| branch `v0.5-dev`, worktree `../surveyframe-v0.5-dev` | **0.4.0** | `todo_0.4.md` |
| (follows `v0.5-dev`) | **0.4.1** | `todo_0.4.1.md` |
| (follows `v0.5-dev`) | **0.4.2** onward | the RMCDA expansion, block G below |
| — | never published | `todo_0.3.5.md` |
| branch `v0.4-dev` | never published | Small-sample track, already merged into `v0.5-dev` |

Consequences. CRAN numbering runs 0.3.4 to 0.4.0 to 0.4.1 to 0.4.2. There
is no 0.3.5 and no 0.5.x on CRAN, and no 0.4 in the old sense either, since
the small-sample release merged into this one on 2026-07-25. DESCRIPTION
must read `0.4.0` at submission even though the branch is called
`v0.5-dev` (task E1). NEWS.md must state plainly that 0.3.5 and 0.5 were
planned and never released (task E2). The strict patch-scope rule that
governed 0.3.5 no longer binds, because that work now rides a minor
release.

## Baseline verified 2026-07-30

0.3.4 is live on CRAN, published 2026-07-24, all 13 check flavours Status
OK with no notes. `main` at 6556f91 matches the public repository. **That
SHA no longer exists**: the 2026-08-04 history rewrite orphaned it, and its
counterpart on the rewritten `main` is `19ada2c`, which is what the
`v0.3.4` tag points at. See `CLAUDE.md`'s history-rewrite section. The
pkgdown site shows 0.3.4 and carries no dev-only files. `mas_review_034`
is signed off. Nothing from that release is outstanding.

`v0.5-dev` is clean and 6 commits ahead of `main`, carrying the whole
small-sample track, all 10 MCDM computations with both UI registries,
`R/decision_data.R`, the 2 new item types at the R level, 7
`test-decision-*.R` files, static-survey rendering for both item types
(commit d218786), and RMCDA in Suggests as a test-time oracle.

## Open decisions, needed before the affected tasks start

1. **Does the first RMCDA batch ride 0.4.1 or wait for 0.4.2?** Putting new
   methods in 0.4.1 ends its patch scope. Recommendation: start the
   expansion at 0.4.2 and keep 0.4.1 to demo proofing. Affects G1.
2. **Resolved 2026-07-31: the MCDM paper stays separate from the
   small-sample paper.** No combined manuscript. The MCDM paper describes
   the 10 shipped methods only, with the RMCDA expansion named as roadmap
   rather than claimed as shipped, matching D2's original scope. Both
   papers' preprint DOIs were expected to gate `inst/CITATION` for 0.4.0
   independently. D3 (the combined draft) is dropped and D4 no longer needs
   an owner 1-vs-2 read, since 2 was decided directly. **Superseded in part
   on 2026-08-15**: no preprint DOI gates 0.4.0 at all. SF2 went straight to
   journal submission and is cited in `inst/CITATION` as in preparation with
   no DOI, and MX3, the small-sample paper, moved to 0.4.1 with block F on
   2026-07-31 and carries its own citation there (F6). See the journal and title
   decisions in D1/D2 below and the paper-track entry in
   `../portfolio-planner/decisions.md`.
3. **Confirm the 8-into-0.4.0 and 4-into-0.4.1 split** of the 12 open
   dogfeed items. Affects C4 and F5.

---

## Priority order

Work top down. Anything in the same tier can run in parallel.

- **P0 to P3, done 2026-08-02.** Blocks A, B, and C are closed for 0.4.0.
  A1 to A6, B1 to B16, C3 to C8, plus H1. The 2 pre-existing defects logged
  during the work (the Shiny export shape and the serialisation fixed point)
  were both fixed on owner decision the same day.
- **P4, the live tier: manuscript and release. Closed 2026-08-15 apart from
  D2a and E8.** D2 (the MCDM manuscript) was drafted, proofread, and
  submitted to *Operations Research and Decisions*. D4, D5, and D6 are all
  resolved, and D6 stopped being a blocker when `inst/CITATION` moved to an
  in-preparation citation with no DOI. E1 to E5 and E7 are done, E6 is
  submitted to win-builder with results pending, and E8 (the CRAN submission
  itself) waits on those results. D2a, the OpenAlex pass, is still open and
  gates nothing in this release, only G1's grouping decision at 0.4.2.
- **P4 human gate, blocking E8: H2. Done 2026-08-15**, owner-verified inside
  a real RStudio session. It could not be automated in any form, the add-in
  ships in this release, and Part J of `mas_review_040.qmd` carried the click
  path.
- **P5, after 0.4.0 ships:** F0, F0a, F0b, F0c, F1 to F6, then G1 to G4.
  Block F now also carries the 12 dogfeed items re-laned on 2026-08-02.
- **Parallel at any time:** H3, I4 to I9.

Critical path, restated 2026-08-15. **Both things blocking submission are
now closed.** D6 no longer needs a preprint DOI: owner decision 2026-08-15
cites SF2 in `inst/CITATION` as `Unpublished`/in preparation instead,
verified to parse and render cleanly, after checking that a preprint on
Operations Research and Decisions specifically was not something to
gamble the journal relationship on without asking first (MethodsX would
have been fine; ORD's own guidelines do not say either way). SF2 itself
was submitted to ORD the same day, its own proofread pass complete
(negative-prose and antithesis rewrite, 2 missing citations added, the
roadmap-disclosure section removed on owner instruction). **H2 is done**,
owner-verified in a real RStudio session on 2026-08-15.

**Critical path, restated again later on 2026-08-15. Block E is worked
through and only E8 remains.** DESCRIPTION reads `0.4.0`, NEWS.md is
complete, `devtools::test()` gives 0 failures on 1506 tests,
`R CMD check --as-cran` returns Status OK at 0 errors, 0 warnings, 0 notes,
the tarball was audited against every dev-only file named in `CLAUDE.md`
and carries none, and `cran-comments.md` is drafted. A tarball went to
win-builder the same day and the results are pending, so E6 is submitted
rather than closed. E8, the CRAN submission itself, is the only step left.

**One real gap surfaced during that release prep.** The 2026-08-07 breaking
API change (the validation diagnostic and the accessor family) had been
built and tested on `dev` and never merged to `main`, so `main` had already
passed a full CRAN check without any of it. Cherry-picked `c67dab9` onto
`main` and re-verified from scratch. NEWS.md turned out to have the same
shape of gap: its 0.4.0 section documented the later bug-fix, accessor, and
polish work while never mentioning the MCDM extension or the small-sample
statistics track, which are this release's headline features. Both were
fixed on 2026-08-15. The lesson to carry: a commit on `dev` is no evidence
that `main` has it, and a changelog that reads complete can still be missing
the release's whole subject.

**What this round changed about the plan itself.** Three tasks turned out
not to be what they were written as. B10's exemption was already there by
construction, and the real defect was next door in missingness. B12 needed
no engineering, only documentation. C4's "8 machine-fixable items" were 7
judgement calls and one partly-machine task. Two review tasks, B11 and B13,
each found a defect that was not in the list at all. The common shape in
both was software returning something plausible rather than saying it had
no answer, which is worth carrying into the remaining review.

## Delegation and model tiering

Per the 2026-07-27 decision: Opus is the lead tier (judgement, design
decisions, shared-file wiring, review of delegated diffs), Sonnet
implements well-specified work, Haiku runs mechanical verification. Fable
is not used. Token rules from `todo_0.4.md`'s delegation section are
binding: grep then read a range, never a whole large file, one targeted
test run per change, full suite at integration only, reports under 15
lines.

---

## Block A. 0.4.0 bug fixes

A1 to A5 come from the 2026-07-26 independent validation, and 4 of those
shipped inside 0.3.4. A6 was found later, on 2026-07-30, in a live builder
session rather than by any suite. Detail and evidence:
`../surveyframe-statistical-validation` and the Claude memory
`stat-validation-bugs-found`.

- [x] **A1 [Opus]** Builder `qAdd()` fab menu and `varLevel()` switch gain
  `pairwise_comparison` and `criteria_weight`
  (`inst/builder/survey_builder.html`). **Done 2026-07-30, `v0.5-dev` at
  19083e4.** New "Decision (MCDM)" fab group with 3 entries for the 2 types
  (Saaty and influence variants of `pairwise_comparison` get one each, via a
  new optional second argument to `qAdd()`), 3 default `comparison_items`
  and `required = TRUE` so a new item validates and exports, `varLevel()`
  returning the 2 levels the decision `ANALYSIS_REGISTRY` entries already
  declare, readable id prefixes (`pair_1`, `crit_1`), and both types added
  to the inspector's Response type dropdown. Verified in headless Chrome,
  10 of 10 checks: all 10 decision methods now return a non-empty role
  dropdown, and the exported `.sframe` with ahp, dematel, and topsis blocks
  round-trips through `read_sframe()` with its hash intact. (The
  "0 validation errors" claim first recorded here was vacuous, see the lesson
  below. Re-checked properly against `$problems` on 2026-07-30: valid, 0
  problems, hash stable.) B11 and B13 are unblocked.
  **Second round, 9fdeb0e, after the first was reported as not fixed.** The
  first pass verified the JS functions in isolation, which passed, and missed
  what a researcher sees on adding the question. `renderPreviewItem()` had no
  branch for either type, so the Preview tab drew an empty question body, and
  the builder's inlined static template was stale, so exporting a survey
  emitted "Unsupported item type" for every decision question. Both fixed,
  which also closes B8. The inspector editor (B7) came forward in the same
  commit, since a question type nobody can configure is not usable. Verified
  through real clicks, 18 of 18 checks, plus a full suite at 1124 passed and
  0 failed. Screenshots of the Preview tab and the exported survey were taken
  and read, not just asserted on.
  **Third round, 266f2a1 and 83ce595, from a live builder session.** The fab
  menu's 260px cap clipped Date, Text block, and the whole new Decision group
  out of view behind a scrollbar with no visual hint, so the types looked
  absent even in the fixed file. Cap is now `min(460px,58vh)`, measured at
  458px with no scrolling at 1000px viewport height. The same session found
  A6 and C8 below.
  **Lesson for the rest of this release: a check that only calls the
  function is not a check that the feature works, and a check that cannot
  fail is not a check.** Three of my verification scripts in this task were
  themselves wrong (a wrong export placeholder, `openInsp()` where the UI
  calls `selItem()`, and reading a `$errors` field that `validate_sframe()`
  does not return, which made 2 rounds of "0 validation errors" vacuous).
  Every remaining UI task (B6, B11, B13) gets a click-path pass with a
  screenshot read back, and every new rule gets a mutation check: revert the
  guard, confirm the test fails, restore it.
- [x] **A2 [Sonnet, Opus review]** `item_report()` item-rest correlation
  (`R/psychometrics.R:179`). **Done 2026-07-31, `v0.5-dev` at 0743e10.**
  The rest score is now the sum of the other items rather than the item
  subtracted from a `rowMeans()` total. Verified against
  `psych::alpha()$item.stats$r.drop`: identical to 1e-10 across 6 items.
  The old formula returned about -0.46 per item on a simulated scale with
  alpha 0.947. New `tests/testthat/test-item-rest-correlation.R`, 9
  expectations, including one that pins the discredited formula as
  negative so it cannot creep back. Mutation-checked: reverting fails 6
  of 9.
- [x] **A3 [Sonnet, Opus review]** `sframe_run_repeated_anova()` never
  coerces `.subject` to a factor (`R/statistics_reports.R:956`).
  **Done 2026-07-31, `v0.5-dev` at 0743e10. This was 2 bugs, not 1.**
  Coercing the subject id was necessary but not sufficient: with a factor
  subject the design produces strata `.subject` and `.subject:condition`
  and **no `Error: Within` stratum at all**, so the existing fixed-name
  lookup found nothing and fell through to the branch that reports no F.
  The effect is now located by searching the strata for the `condition`
  row carrying an F. Verified against `jmv::anovaRM()`: F(2, 78) = 86.927
  against jmv's 86.92699, where the old code gave F = 1.45, p = 0.24. New
  `tests/testthat/test-repeated-anova-strata.R`, 16 expectations.
  Mutation-checked both halves: reverting the coercion fails 7 of 16,
  reverting the stratum search fails catastrophically because the named
  stratum no longer exists.
- [x] **A4 [Sonnet, Opus review]** `known_vars`
  (`R/validate_sframe.R:66`). **Done 2026-07-31, `v0.5-dev` at 0743e10.**
  Fixed at the root rather than by patching one side: `read_responses()`
  and `validate_sframe()` derived the same expansion list separately,
  which is how they drifted, so the logic now lives once in
  `sframe_item_expansion_columns()` (`R/decision_data.R`) and both call
  it. Covers all 4 expansion families (matrix sub-items, ranking and
  multiple-choice options, Saaty and influence pairs, criterion weights).
  New `tests/testthat/test-known-vars-expansion.R`, 11 expectations,
  including one asserting the 2 callers agree. Mutation-checked:
  reverting fails 4 of 11. 455 related tests green after the refactor.
- [x] **A6 [Opus]** Bug 6, found 2026-07-30 in a live builder session, not by
  the validation suite. **Fixed, `v0.5-dev` at 83ce595.** A decision plan
  could be built the wrong way round: AHP's `pairwise` role offered every
  `pairwise_comparison` item, including a DEMATEL influence item. The 2 scales
  are not interchangeable, so that returns plausible weights from meaningless
  input with no error, the same failure shape as A5's unfiltered model roles.
  Guarded on 4 surfaces: `validate_sframe()` at design time (the plan is a
  contract, so this belongs before collection), `sframe_resolve_pairwise_matrix()`
  so the AHP and ANP runners error rather than compute, the builder via a
  `pairwise_saaty`/`pairwise_influence` level split with all 10 decision roles
  retargeted, and `studio_level_meta()` in SurveyStudio, which had no branch
  for either item type at all and so showed empty MCDM role dropdowns. New
  `tests/testthat/test-decision-scale-guards.R`, 19 expectations over 8 tests,
  mutation-checked: reverting the 2 R guards fails 11 of 19.
- [x] **A5 [Sonnet, Opus review]** Model-role filtering by `model$type`.
  **Done 2026-07-31, `v0.5-dev` at 0743e10.** New
  `sframe_check_model_type()` guards all 3 generators, not the 2 the task
  named: `seminr_syntax()` (needs `pls_sem`), `sem_lavaan_syntax()` and
  `cfa_lavaan_syntax()` (need `cfa` or `cb_sem`). `cfa_lavaan_syntax()`
  checks only when a model is supplied, since `model = NULL` legitimately
  derives the measurement model from the instrument's scales. The builder
  side declares `modelTypes` per model role and `roleOptions()` filters on
  it. Verified in headless Chrome with the screenshot read back: the 3
  generators now offer `m_cfa,m_cbsem` / `m_cfa,m_cbsem` / `m_pls`, where
  before the filter every one offered all 3. New
  `tests/testthat/test-model-type-guards.R`, 21 expectations.
  Mutation-checked both surfaces: reverting the R guards fails 7 of 12
  (as it then stood), reverting the builder filter reproduces the original
  bug exactly, every generator offering all 3 models.
  **A5 immediately caught the same bug in shipped data, which is why the
  full suite went red.** Both bundled demo instruments
  (`tourism_services_demo.sframe` and `surveyframe_input_types_demo.sframe`)
  wired their `seminr_syntax` block to a `cb_sem` model, so
  `sframe_demo_data()` generated PLS-SEM syntax from a covariance-based
  model, and every vignette and example that loads it inherited the
  mismatch. Confirmed against the pre-fix code by stashing the guards:
  1232 characters of PLS-SEM syntax returned with no error. The guard was
  right and the data was wrong, so the data was fixed rather than the
  guard loosened. Each demo now carries a real `pls_sem` model with
  composite constructs, hashes regenerated through `write_sframe()`, both
  validating with 0 problems, and 2 further tests pin the wiring. A first
  attempt rewrote the role from an array to a scalar while the sibling
  CFA and SEM blocks kept arrays; tests passed either way, so that was
  caught in review rather than by the suite and redone.

## Block B. 0.4.0 MCDM and decision-family completion

Spec: `todo_0.4.md`, sections 1 to 8. Re-grep every file and line anchor
before editing.

- [x] **B1 [Owner, Opus]** Sign off the section 1 data contract (matrix
  encoding, aggregation defaults, column conventions). **Signed off
  2026-07-31.** Verified the built code on `v0.5-dev` against every
  subsection of `todo_0.4.md` section 1: the two matrix kinds (1a) stay
  separate with `weights_source`/`matrix_source` provenance,
  signed-integer column encoding (1c, `item__a__vs__b`, `item__a__to__b`,
  `item__crit`) confirmed in `R/read_responses.R` and exercised in
  `test-decision-topsis.R`, `sframe_aggregate_judgements()` (1d,
  `R/decision_data.R:258`) does geometric mean for AHP and arithmetic for
  DEMATEL with `cr_filter` defaulting `FALSE`, `sframe_decision_options()`
  (1e, `R/decision_data.R:543`) is the serialisation normaliser, and
  `sframe_rated_matrix()` (path C, `R/decision_data.R:447`) covers the
  rated-performance-matrix path with no new item type. Owner confirmed:
  no changes needed to matrix encoding, aggregation defaults, or column
  conventions. The one embedded judgement call, dropping respondents with
  any missing pairwise answer rather than Harker-completing partial
  matrices, is kept as documented in the 2026-07-25 harvest audit,
  revisit only if ICSRI or the real-survey rounds (block C) show a high
  drop rate. B14's standalone sample-sframe fixture is unaffected and
  stays open on its own line, the contract only lived inline in
  `test-decision-topsis.R` for this check.
- [x] **B2 [Haiku transcription, Opus verification]** Verify and add the
  missing citations. **Done 2026-07-31, `v0.5-dev` at c538985.** All 8
  added (ANP, DEMATEL, VIKOR, MOORA, SMART, WASPAS, PROMETHEE, ELECTRE),
  each checked against the publication record rather than transcribed
  from the harvest audit's draft strings. **That check produced a
  correction: ELECTRE is volume 2 issue 1, not the `2(8)` the audit
  recorded.** Numdam's scan of the original journal is
  `RO_1968__2_1_57_0`, and a secondary source claiming volume 8 was
  rejected in its favour. DOIs added where they exist. All entries ASCII,
  so the CRAN non-ASCII check stays clean. All 10 decision methods now
  return at least one method citation, verified by running
  `sframe_citations_for_test()` over each.
- [x] **B3 [Opus decision]** Resolve DEMATEL's citation. **Done
  2026-07-31, `v0.5-dev` at c538985. The framing needed correcting before
  the question could be answered.** It is not a choice between 2 reports.
  DEMATEL was developed as a programme at the Battelle Geneva Research
  Centre across at least 4 grey-literature reports between 1972 and 1976
  (1972 *World problems*, 1973 *Perceptions of the world problematique*,
  1974 *DEMATEL innovative methods*, 1976 *The DEMATEL observer*), and
  secondary sources disagree over which is canonical and even over the
  author order. None can be sighted, and the house rule forbids citing an
  unverified reference as though it were checked. Resolved by recording
  the 1972 originating report for provenance and pairing it with Si,
  You, Liu and Zhang (2018) in *Mathematical Problems in Engineering*,
  DOI 10.1155/2018/3696457, a peer-reviewed open-access systematic review
  a reader can actually obtain and check the implementation against.
  DEMATEL is the one method carrying 2 citations, deliberately.
- [x] **B4 [Sonnet, Opus review]** `sensitivity_analysis()` in
  `R/decision_sensitivity.R`: classed `sframe_sensitivity` object, `$table`,
  `plot()` and `print()` methods, callable from a plan block via
  `options$sensitivity = TRUE`.
  **Done 2026-08-01, `v0.5-dev` at 250c1ac.** Classed `sframe_sensitivity` with `$table`, `plot()`, `print()`, and a `$stable` verdict. Covers all 7 ranking methods through the `compute()` signature they share; AHP, ANP, and DEMATEL are refused with a typed error since they produce weights rather than consume them. Wired to plan blocks via `options$sensitivity = TRUE` through one central hook rather than 7 runner edits. **The mutation check earned its place:** 55 tests passed, then deleting the renormalisation still passed all 55, because the test only checked the weight moved in the right direction, which holds either way. Rewritten to pin the exact renormalised share (0.4231, not 0.44) and now fails 4 when reverted. Later gained a `degenerate` flag, see B11.
- [x] **B5 [Sonnet]** `sf_conjoint_design()`, a declared design generator
  and not an estimator. **Owner decision 2026-07-31: build it in 0.4.0**,
  superseding its standing as the first deferral if the window tightens.
  A new export is a permanent CRAN API commitment, so this was decided
  explicitly rather than allowed to drift.
  **Done 2026-08-01, `v0.5-dev` at c900034.** `full`, `balanced`, and `random` methods plus a `profiles` escape hatch, seed always recorded so the design regenerates from the contract, and the caller's RNG stream restored. Named `"balanced"` rather than `"fractional"` deliberately: it is a repeated-sampling search, not a catalogued orthogonal array, and the name should not imply guarantees it lacks. **Serialisation was the risk.** The hash covers the payload's key set, so `designs` is written only when a design exists. An earlier draft justified that by claiming an unconditional key would fail the integrity check on every stored file; running the mutation disproved it, because `read_sframe()` hashes the parsed payload and stays self-consistent. The real damage is identity change on rewrite (c3df10ec in, febd07c5 out). Comment and test corrected to the true failure mode.
- [x] **B6 [Sonnet]** Shiny renderer for both new item types in
  `R/render_survey.R` and `R/survey_module.R`. Neither file references
  either type today.
  **Done 2026-08-01, `v0.5-dev` at c41e370.** Saaty strips with verbal anchors on both sides, directed influence rows, constant-sum boxes, required-item logic including the total-must-be-100 rule. **The output shape was the real decision.** The existing matrix type pipe-joins its cells into one column, verified directly, which does not match the contract `read_responses()` expects. Copying that would have produced a decision survey that renders correctly and yields data the package cannot analyse, so decision items emit real expansion columns instead. The test that carries the weight runs Shiny inputs through to `sframe_assemble_pairwise()` and back. Matrix's own defect was logged rather than folded in silently, and later fixed, see the breaking-change entry below.
- [x] **B7 [Sonnet]** Builder inspector editor for `comparison_items` and
  `comparison_scale`, plus Theme B preview parity. **Done 2026-07-30,
  `v0.5-dev` at 9fdeb0e**, brought forward from its own slot because A1's
  item types are unusable without it. Items-to-compare textarea and
  comparison-scale selector wired through `FMAP` and `updF()`, carrying the
  same size limits the R side enforces (a note above 7 Saaty or 6 influence
  items, a rejection message above 10). Preview parity done in the same
  commit: `renderPreviewItem()` draws the Saaty strip, the directed DEMATEL
  rows, and the constant-sum boxes with a running total.
- [x] **B8 [Haiku]** Re-run `data-raw/inline_static_template.R` to
  regenerate the builder's inlined copy of the static template. **Done
  2026-07-30, `v0.5-dev` at 9fdeb0e.** This was not cosmetic: until it ran,
  exporting a survey from the builder emitted "Unsupported item type" for
  every decision question, because the inlined renderer predated d218786.
  The script is tracked on `dev` only, so it was copied into the worktree to
  run, and `data-raw/` stays gitignored there.
- [x] **B9 [Sonnet]** Google Sheets Apps Script generator
  (`R/google_sheets.R`) emits the 3 new column patterns, plus the round
  trip from static survey to collector CSV to `read_responses()` to
  assembled matrix.
  **Done 2026-08-01, `v0.5-dev` at 394fd91.** The Sheets header generator was the **4th** independent copy of the expansion-column derivation, after `read_responses()` and `validate_sframe()`, and those 2 had already drifted apart once, which is what made a real builder export fail validation in A4. All callers now read `sframe_item_expansion_columns()`, so the sheet cannot fall behind the reader, and the 3 decision column patterns come along without a per-type branch.
- [x] **B10 [Sonnet]** Exempt the pairwise columns from
  `quality_report()`'s straightlining and speeding checks.
  **Done 2026-08-01, `v0.5-dev` at 394fd91. The task's premise was wrong and checking first is what showed it.** Straight-lining iterates declared scales and a decision item is never in one; timing is wall-clock with no item involvement. No exemption was needed, and both facts are now pinned by tests. The same probe found the real defect next door: missingness matched on bare item ids, so every expansion column was invisible and a respondent who skipped all 3 pairwise questions was reported at **0 percent missing**. Expansion columns now count, which also brings matrix, ranking, and multi-select into the missingness figures for the first time. That moves numbers users already have, so it has its own NEWS heading.
- [x] **B11 [Opus decision, Haiku automation]** UI/UX and stress review for
  the 7 methods not yet covered (TOPSIS, VIKOR, MOORA, SMART, WASPAS,
  PROMETHEE, ELECTRE): web and mobile rendering, simulated results, 9x9
  stress test, grouped versus separate layout. Runs after A1. Already done
  for AHP, ANP, and DEMATEL.
  **Done 2026-08-02, `v0.5-dev` at 052da00. The 9x9 stress pass found a defect that was not in the task list.** 6 of the 7 ranking methods returned complete rankings under 10ms. ELECTRE I returned every score at 0 and every alternative at rank 1, which is legitimate for the method (no alternative clears concordance with 9 criteria at the default thresholds) but was reported as though it were a finding: the table listed 9 alternatives at rank 1 and the APA sentence reported a kernel containing all of them. **Worse, `sensitivity_analysis()` called that `stable = TRUE`** — the strongest robustness signal the function has, produced by the weakest result it can be handed. ELECTRE now says no outranking was established, and sensitivity gained a `degenerate` flag whose `print()` leads with "No result to test". Both regression tests skip themselves if the fixture stops being degenerate, so they cannot rot into passing for the wrong reason.
- [x] **B12 [Opus decision]** PROMETHEE's CHECK status. **Done
  2026-07-31, `v0.5-dev` at 1d8481a. The engineering half was already
  finished before this task was read**, which the task list did not
  reflect: `R/decision_preference.R` implements 3 of Brans' 6 preference
  functions (`usual`, `linear`, `level`) and already defaults to `usual`,
  the type I step function, the stronger of the 2 options offered here.
  The harvested source defaulted to `linear` **and** derived its
  thresholds from the range of the data, which makes the result depend on
  a choice the researcher never declared. Both were dropped, and a
  threshold-bearing function must now be requested explicitly.
  What was genuinely missing was any user-facing record. The reasoning
  lived in source comments and no `.Rd` mentioned it, so a researcher
  cross-checking a ranking against another implementation would find
  different numbers and no explanation. A `@section` on
  `sframe_decision_options()`, the exported entry point where a user looks
  up what a decision block accepts, now covers it.
  **The note is measured rather than asserted.** A first draft said
  cross-checked rankings "will differ", which a worked example disproved:
  net flows differed while the ranking held. Measuring properly gave rank
  reversal in 226 of 400 random 4-by-3 matrices, so the committed text
  says "will often disagree" and cites the number. It also records that
  `usual` ties ranks readily, since a step function scores every non-zero
  difference identically.
- [x] **B13 [Haiku]** Verify SurveyStudio MCDM support live against fixed
  builder output. **Partly unblocked 2026-07-30**: `studio_level_meta()` had
  no branch for either decision item type, so every MCDM role dropdown in the
  studio was empty. Fixed with the scale-aware split in 83ce595 (see A6). The
  live click-through in a running app is still open, and it is where the rest
  of the studio's decision handling gets checked.
  **Done 2026-08-02, `v0.5-dev` at d074914. The most consequential find of the batch.** All 7 ranking methods showed `performance_items` with **0 options** in SurveyStudio despite the fixture declaring 4 matrix items. The role matches on a `"matrix"` level and neither GUI gave matrix items one: the studio classified them `"identifier"`, the builder grouped them under `"expanded"`, which no role accepts. **The rated performance matrix was unwirable in both GUIs**, so path C, which RQ3 of the fixture and the vignette both teach, could only be built by writing R. Fixed in both. **The measurement needs recording as much as the fix:** the browser reader reported 0 options even after the fix was correctly in place, because selectize.js hides the real `<select>`. The defect is therefore established in R with no browser involved, 4 choices with the fix and 0 without; the live run corroborates rather than proves.
- [x] **B14 [Sonnet, Opus review]** Build the section 1g sample sframe as a
  real fixture. Release gate: builds with shipped constructors, validates,
  round-trips with a stable hash, renders on all 3 survey surfaces, exports
  the exact 42 expansion columns, and all 4 plan blocks return a table and
  a chart with no error field.
  **Done 2026-08-01, `v0.5-dev` at 4bb9203, generator at 1af4c24.** Bundled instrument plus 12 seeded respondents, 7.7 KB. All 6 gates check out: shipped constructors only, validates with 0 problems, hashes to the value it stores, renders on all 3 surfaces, declares exactly the 42 expansion columns with all 42 writable from the live page, and every block returns a table and chart. The 2 TOPSIS blocks return different rankings, which is the point of including both, and a test asserts they differ because identical scores would mean a declared path was being ignored. **Gate 3 failed at first, and not because of the fixture:** a freshly built instrument was not a serialisation fixed point. Confirmed on a plain Likert instrument, logged, and later fixed properly.
- [x] **B15 [Sonnet]** `vignettes/mcdm-analysis.Rmd` to the 0.3.4 house
  rules: offline knit, `set.seed()`, shared WCAG style block, `lang:
  en-GB`, `fig.alt` on every chart.
  **Done 2026-08-02, `v0.5-dev` at 2cbdd4e.** `vignettes/mcdm-analysis.Rmd`, offline knit, `lang: en-GB`, `set.seed()`, shared WCAG block, `fig.alt` on all 3 charts, built on B14's fixture so every number is reproducible. Names the 2 traps that make an MCDM result confidently wrong: the benefit/cost reframing (price is `benefit` only because the question asked about value for money) and the non-interchangeable comparison scales. **A first draft implied the sensitivity example was stable; checking showed it is not** (4 of 8 perturbations move the ranking while the leader holds), so the section now draws that distinction rather than the neater but false one.
- [x] **B16 [Haiku]** axe-core pass through chromote on the new vignette,
  zero violations. `_pkgdown.yml` has no vignette listing, so no pkgdown
  edit is needed.
  **Done 2026-08-02, `v0.5-dev` at 2cbdd4e.** axe-core 4.10.3 through chromote against the WCAG 2.2 AA tag set: **0 violations, 24 passing checks**, re-run after the prose edits rather than trusting the first pass. `_pkgdown.yml` gained a "Specialised analyses" section, which also fixed an unrelated gap: **`small-sample` was missing from the article index entirely**, so that vignette would never have reached the site.
## Block C. 0.4.0 field validation, absorbed from 0.3.5

Was `todo_0.3.5.md`. No 0.3.5 release ships. Dogfeed protocol applies:
while a feedback session is open, log only and edit no source file.

**C1 and C2 moved to block F (0.4.1) on 2026-07-31.** ICSRI capture and
the 3-to-5 real-survey rounds no longer gate 0.4.0. This block now
covers only the 12 dogfeed items already logged before this date; the
fresh ICSRI and real-survey feedback is captured and triaged as 0.4.1
work instead (see F0/F0a and F4 below).

- [x] **C3 [Opus]** Triage the 12 already-logged items to 0.4.0 or
  wontfix. Patch-scope constraints no longer bind. (Splitting fresh
  ICSRI/real-survey feedback no longer applies here, since that capture
  itself now happens under block F.)
  **Done 2026-08-02, `dev` at f9144c6. Re-reading the entries changed the answer.** The "8 machine-fixable items" grouping does not hold: 7 of the 8 state in their own text that they need human eyes, and D2.6 says it is bigger than a spot check. **The triage also had to correct itself** — it first named E2.6 as the one machine-fixable entry, whose own text reads "Visual judgement call", which is exactly the error the triage existed to catch. Owner decision the same day: 12 entries re-laned to 0.4.1 beside the ICSRI capture and faculty demo.
- [x] **C4 [Opus lead, Sonnet batches, Haiku verification]** Clear the 8
  machine-fixable open items already logged: B1.3 interpretation and
  decision-rule pairing, D2.5 phone-width scale-correlation heatmap, D2.6
  filter live-check and full levels and labels audit, E2.6 bounds error
  message styling, H1.4 and H1.5 vignette prose and `browseVignettes()`
  presentability, J1.5 APA interval prose, K1.7 MCAR interpretation
  wording, L1.4 to L1.7 PDF pagination, greyscale legibility, browser
  print and brand colour, N1.9 SurveyStudio Copy-result clipboard.
  **Done 2026-08-02, `v0.5-dev` at 07ed716, scope reduced by C3.** Only D2.6's machine halves were ever machine-actionable. The `levels`/`labels` audit ran across all 11 `sf_item()` types: labels reach the analysis table for every one of the 8 carrying a choice set, and text, textarea, and date correctly show raw values. Ranking and matrix analyse end to end. **The audit found one real defect:** a matrix row label containing a space produces a column containing a space, which the collectors write correctly but `read.csv()` rewrites (`check.names` defaults TRUE), so `read_responses()` rejected it as undeclared with nothing to say the header had been rewritten. The error now names the cause and the fix, and stays quiet for a genuinely stray column. **6 of the 7 attempts at this audit failed on my own harness**, not the package: a method name that does not exist, a role name from a different method, an invented `sf_branch()` argument, and `as.data.frame()` mangling column names twice.
- [x] **C5 [Opus lead, Haiku verification]** Record this block's fixes in
  `mas_review_040.md`, modelled on `mas_review_034.md`, chromote-verified
  for every UI item. Narrower in scope than before: covers only C4's 8
  items, since the ICSRI/real-survey rounds that used to feed this
  document now get recorded under F4's `mas_review_041.md` instead.
  **Done 2026-08-02.** `mas_review_040.qmd`, modelled on `mas_review_034.qmd`, renders clean with 0 errors and every chunk producing its expected value (checked by grepping the rendered HTML for the specific figures, not just for a successful build). Parts A to H cover the release; **Part J is a dedicated RStudio add-in click path and is marked a release blocker**, since H2 cannot be automated at all. Part L carries the 4 open owner decisions. Chunks resolve fixtures whether surveyframe is installed or loaded from source, and `error: true` means a failing chunk reports inline rather than halting, which matters when working through it one chunk at a time.
- [x] **C6 [Haiku]** Fix README's Roadmap section, which still promises
  small-sample inference at v0.4 and MCDM at v0.5. It is live on CRAN and
  on the pkgdown site.
  **Done 2026-08-01, `v0.5-dev` at 115350b.** The old text promised small-sample at v0.4 and MCDM at v0.5, both live on CRAN and the pkgdown site, telling readers to wait for versions that will never exist. Replaced with what 0.4.0 actually contains, a line explaining the 2 releases merged, and a pointer to NEWS rather than a restated version plan, since restating it in 2 places is what let it go stale.
- [x] **C8 [Opus]** Placeholder labels announced as placeholders. **Done
  2026-07-30, `v0.5-dev` at 83ce595**, raised in the same live session as A6.
  New decision and matrix questions ship with sample labels so they render at
  once, and nothing said so, which risks a placeholder reaching respondents.
  The inspector now shows an amber "sample" chip on the field label and the
  preview shows a matching note. Stateless: it compares the current labels
  against the exact defaults `qAdd()` writes, so nothing extra reaches the
  `.sframe` and both cues clear on the first edit. Applies to matrix rows too,
  which had the same silent defaults.
- [x] **C7 [Haiku]** Close the ignore-file gaps. **Done 2026-07-31,
  `main` at 556743d.** The gap was only ever on `main`: `dev` already
  carried all 12 newer planning files in both `.gitignore` and
  `.Rbuildignore`, so the fix was to bring `main` level, adding 13 lines
  to each. That also retires the stale `todo_0.4.1.md` pattern, which had
  matched nothing since the 2026-07-25 rename to `todo_0.4.1.md`. This
  matters beyond tidiness because `.Rbuildignore` protects only the CRAN
  tarball, while pkgdown reads the working tree directly and honours
  neither file, so a build from a branch carrying these files could
  publish them.
  Committed on `main` in an isolated worktree rather than by switching
  branches in the primary checkout. An earlier attempt at the
  stash-and-switch route popped the wrong stash entry and briefly wrote a
  regression into `dev`'s copies of both files, caught before any commit
  and reset. Worktrees for cross-branch work from here.

## Block D. 0.4.0 manuscript and the CITATION gate

**Superseded 2026-07-31: 2 separate papers, not 1 or 3 drafts then
decide.** The 2026-07-30 "write all 3, then decide" plan is dropped; D3
(the combined draft) does not get written. See
`../portfolio-planner/decisions.md` for the full reasoning, target
journals, and titles.

**D1/D1a (the small-sample paper) moved to block F (0.4.1) on
2026-07-31**, resolving the conflict flagged the same day: its
applied-validation section depends on F0a's real-survey data, which
only exists after 0.4.0 ships, so the paper cannot draft on 0.4.0's
schedule either way. Only the MCDM paper (D2/D2a) now gates 0.4.0's
`inst/CITATION`; the small-sample paper's DOI is added to `inst/CITATION`
as part of 0.4.1 instead (see F6).

- [x] **D2 [Sonnet draft, Opus review]** MCDM-only manuscript,
  **"surveyframe: A Pre-Declared, Reproducible Framework for
  Multi-Criteria Decision Analysis in Survey Research."** Target
  journal, set 2026-07-31 (supersedes the Journal of Multi-Criteria
  Decision Analysis target): *Operations Research and Decisions*
  (Wroclaw University of Science and Technology). Diamond OA, no fee,
  Scopus + Web of Science indexed, Q3 best quartile. Chosen because no
  diamond-OA MCDM journal at Q1/Q2 exists: JMCDA is Q2 but hybrid
  (~$2,630/£1,750/€2,170 APC), DMAME is Q1 but its APC is £2,500-£3,500,
  the most expensive of the 3 options considered. General OR scope, not
  MCDM-specific, but MCDM sits inside it. Covers the 10 methods that
  ship in 0.4.0 only. **Done 2026-08-15, submitted to *Operations Research
  and Decisions*.** Drafted, moved to `../research/surveyframe_manuscripts/mcdm/`
  on 2026-08-14 as SF2, typeset to the ORD LaTeX template with a real byline,
  and proofread the same day (see D4). The "Roadmap: the wider MCDA family"
  section was removed on owner instruction, since the roughly 41-method
  expansion plan, the CRAN version numbers, and the 0.4.2 timing are forward
  product detail with no place in a peer-reviewed methods paper. The RMCDA
  citation was kept on owner instruction and relocated to the Background
  section's package survey as a factual, present-tense mention. A rendered
  supplementary-material PDF was added for the submission, produced from this
  repository's `vignettes/mcdm-analysis.Rmd` as PDF output, 8 pages, running
  the hotel-supplier worked example end to end. Final state: 18 of 18
  references cited, 0 orphaned, compiles clean at 11 pages with 0 undefined
  references.
  - [ ] **D2a [Sonnet]** OpenAlex query pass over the MCDM literature:
    search works for all 10 shipped methods (AHP, ANP, DEMATEL, VIKOR,
    MOORA, SMART, WASPAS, PROMETHEE, ELECTRE, TOPSIS) plus the ~41 RMCDA
    extras, ranked by work and citation count, to (i) confirm the 10
    chosen for 0.4.0 are in fact the most widely used core rather than
    an arbitrary subset, and (ii) produce a data-driven priority order
    for the 0.4.2+ expansion batches, feeding directly into G1's open
    decision. Free API, no key, `https://api.openalex.org/works`. Script
    is `openalex_mcdm_query.R`, one source-file-name comment per house
    style. **Moved 2026-08-14** from this repo's `mcdm-paper/` to
    `../research/surveyframe_manuscripts/mcdm/`, alongside the manuscript,
    tracked as **SF2** in `../research/PORTFOLIO.md`. **Rerun status as of
    2026-08-14: still not done.** A prior session's script fabricated data
    on total API failure (fixed, see `../research/decisions.md`'s D2a
    entry). This session's rerun found and fixed a second real bug (the
    `sort=-cited_by_count` URL parameter is invalid against the current
    OpenAlex API; corrected to `sort=cited_by_count:desc`), then got 44 of
    53 queries through before hitting this sandbox's network proxy's daily
    budget cap (`$0 remaining, resets at midnight UTC`), not a real
    OpenAlex limit. No results file was written. Needs a further rerun
    with budget available. **Partly resolved 2026-08-15 by a different
    route.** A manual OpenAlex web-UI export (topic T10050,
    "Multi-Criteria Decision Making", ANDed against the 10 core method
    names) was downloaded and cleaned by
    `../research/surveyframe_manuscripts/mcdm/clean_openalex_topic_export.R`,
    giving 17,474 rows deduplicated by title and tagged per method. The
    per-method summary confirms the 10 shipped methods as the core, led by
    AHP (3,749 title mentions, 183,770 citations) and TOPSIS (3,452 /
    115,660), down to SMART (110 / 2,484). The tagging is a title-only
    proxy, since the web-UI export carries no abstract text, so the API
    rerun is still worth doing before G1's priority order is fixed.
- [x] **D4 [Owner]** Proofread the MCDM draft. **Done 2026-08-15.** The 7
  uncited references were fixed earlier; a final pass the same day
  rewrote every negative-prose and antithesis construction to direct
  affirmative statements (41 instances of "not" down to 1 idiomatic
  case), added 2 more missing citations (R itself, surveyframe itself),
  and removed the "Roadmap: the wider MCDA family" section on owner
  instruction (forward business/product detail with no place in a
  peer-reviewed paper), keeping the RMCDA citation itself relocated to
  the Background section as a factual, present-tense mention.
- [x] **D5 [Owner]** Superseded 2026-08-15: no preprint. SF2 submitted
  directly to Operations Research and Decisions, real byline already in
  place in the LaTeX version (the double-blind placeholder only ever
  lived in the older markdown draft).
- [x] **D6 [Haiku]** Add the MCDM bibentry to `inst/CITATION`. **Done
  2026-08-15**, without a DOI: cited as `Unpublished`/in preparation,
  verified to parse and render cleanly via
  `utils:::readCitationFile()`. No longer a CRAN blocker.

## Block E. 0.4.0 release paperwork

**Worked through on 2026-08-15.** E1 to E5 and E7 are done, E6 is
submitted with results pending, and E8 is the only step left.

- [x] **E1 [Haiku]** Set DESCRIPTION to `0.4.0`. The branch stays
  `v0.5-dev`. **Done 2026-08-15**, from the `0.3.4.9000` development
  marker.
- [x] **E2 [Sonnet]** NEWS.md entry headed 0.4.0, as a clean per-release
  changelog, stating that 0.3.5 and 0.5 were planned and never released
  and what each absorbed. **Done 2026-08-15**, in 2 passes. The first
  dropped "(in development)" from the header and added the
  never-released statement. The second added the MCDM and small-sample
  sections, which the section had omitted entirely while documenting the
  later bug-fix, accessor, and polish work, so the changelog was missing
  the release's own headline features.
- [x] **E3 [Sonnet]** `cran-comments.md` for the merged diff, framed as
  0.3.4 to 0.4.0. **Done 2026-08-15.** Written from `CLAUDE.md`'s feature
  description in place of NEWS.md, since NEWS.md's gap was found first.
  9 numbered changes, the 2 breaking ones flagged, test environments
  recording win-builder as submitted with results pending.
- [x] **E4 [Haiku]** `devtools::document()` clean, full suite green.
  **Done 2026-08-15.** NAMESPACE regenerated (cosmetic import-block
  reformatting from roxygen2 8.1.0, no functional change, verified by
  diff). Suite: 0 failures, 1506 passes, 36 warnings (the pre-existing
  `geom_errorbarh` deprecation), 1 skip.
- [x] **E5 [Haiku]** `R CMD check --as-cran` at 0 errors, 0 warnings, at
  most 1 note, plus `urlchecker::url_check()` and
  `spelling::spell_check_package()`. **Done 2026-08-15**: Status OK on
  the built tarball at 0 errors, 0 warnings, 0 notes.
- [ ] **E6 [Haiku]** Win-builder R-release and R-devel, both Status OK.
  **Submitted 2026-08-15, results pending.** Leave open until both
  flavours report back.
- [x] **E7 [Haiku]** Confirm no dev-only file reaches the tarball or
  pkgdown, and that pkgdown builds from `main` only. **Done 2026-08-15**:
  the built tarball's full file listing was audited against every
  dev-only file named in `CLAUDE.md` and none is present.
- [ ] **E8 [Owner]** CRAN submission as 0.4.0, minding the release-spacing
  preference against 2026-07-24. Waits on E6.

## Block F. CRAN 0.4.1, faculty demo proofing

Detail: `todo_0.4.1.md`. Strict patch scope, UI, UX, and documentation
only, no new exports, unless decision 1 puts the first RMCDA batch here.

- [ ] **F0 [Owner]** Moved from block C on 2026-07-31. Capture ICSRI 2026
  audience feedback, Villa College, 8 to 9 August 2026, into
  `dogfeed.todo.md`, one entry each, status open. The conference date
  itself does not move; only the release this feedback's fixes land in
  does — 0.4.1, not 0.4.0.
- [ ] **F0a [Owner]** Moved from block C on 2026-07-31. Run 3 to 5 short
  real surveys end to end with recruited testers, covering the surfaces
  that changed most: the builder rework, the Interpretations canvas, PDF
  report output, and the date-bounds path. Feeds F0b's applied-validation
  section directly.
- [ ] **F0b [Sonnet draft, Opus review]** Moved from block D (was D1) on
  2026-07-31, resolving the conflict flagged the same day: this paper's
  applied-validation section needs F0a's real data, which does not exist
  before 0.4.0 ships, so the paper cannot draft on 0.4.0's schedule.
  Small-sample-only manuscript, **"Small-Sample Inference for Survey
  Research: A Reproducible Workflow in R with surveyframe."** Target
  journal, set 2026-07-31 against 4 criteria (Scopus quartile, diamond
  OA, review speed, OA-conference fallback): primary *Survey Research
  Methods* (ESRA) — Scopus Q2, SSCI+DOAJ, diamond, reviewers given 4
  weeks; fallback *Survey Methodology* (Statistics Canada) — Scopus Q3,
  diamond, if SRM rejects.
  - [ ] **F0c [Sonnet]** Moved from block D (was D1a). OpenAlex query
    pass over the survey-methodology literature: search works for the 4
    shipped small-sample corrections (Hodges-Lehmann, paired-Wilcoxon
    pseudomedian, exact Fisher odds-ratio CI, Firth logistic regression)
    plus the bootstrap CI helper, by year and by field, to (i) quantify
    how common small-n survey studies actually are (the paper's
    motivating claim, currently asserted rather than counted) and (ii)
    confirm these 4 corrections are the most-used ones in practice
    rather than a convenience selection. Free API, no key,
    `https://api.openalex.org/works`. Write the script in R
    (`httr2`/`jsonlite`) in `small-sample-survey-framework/`, one
    source-file-name comment per house style.
- [ ] **F1 [Sonnet]** Script the demo flow on released 0.4.0 as a
  repeatable `demo/` script or a documented click path, including the MCDM
  material.
- [ ] **F2 [Owner]** Fresh-install test on a machine that has never had
  surveyframe: `install.packages("surveyframe")`, README quick start, lead
  vignette.
- [ ] **F3 [Owner]** Run the faculty demo session, capturing every
  observation live into `dogfeed.todo.md`, including verbatim confusion
  moments.
- [ ] **F4 [Opus lead, Sonnet batches]** Triage and fix in
  `mas_review_041.md` rounds, chromote-verified for UI items.
- [ ] **F5 [Owner, then Sonnet fixes]** Clear the 4 device-dependent
  carried items: E2.5 phone native date-wheel bounds, F2.6 screen-reader
  spot check (VoiceOver, NVDA, Orca), I1.1 to I1.4 the 30-minute
  fresh-eyes UX pass, J1.7 perceived Run-tab timing.
- [ ] **F6 [Haiku, Owner submits]** Release process and submission,
  including posting F0b's preprint, obtaining its DOI, and adding its
  bibentry to `inst/CITATION` as part of the 0.4.1 release (moved from
  the 0.4.0 CITATION gate, block D, on 2026-07-31).

## Block G. CRAN 0.4.2 onward, the RMCDA expansion

RMCDA (CRAN 0.3.1) carries roughly 51 methods against the 10 shipping in
0.4.0. The extras ship incrementally.

- [ ] **G1 [Opus, Owner]** Decide the method-per-patch grouping across the
  roughly 41 extras, and whether the first batch rides 0.4.1 or waits for
  0.4.2 (open decision 1).
- [ ] **G2 [Sonnet]** Write the expansion planning file on `todo_0.4.md`'s
  pattern: harvest audit per method, integration checklist, delegation
  rules.
- [ ] **G3 [Sonnet per batch, Opus for shared-file wiring]** Port each
  batch: computation, runner, `switch()` case, roles fallback, citation,
  table, plot, both UI registries, tests.
- [ ] **G4 [Sonnet]** Keep RMCDA as the Suggests-only, guarded, test-time
  cross-check oracle for every ported method. It already caught one real
  bug, WASPAS using SMART's normalisation.

## Block H. RStudio add-in (H1/H2 folded into 0.4.0 scope 2026-07-31), plus one independent item

**H1 and H2 now target the 0.4.0 release**, not "whenever" — the add-in
ships as part of whatever tarball contains `inst/rstudio/addins.dcf` and
`R/rstudio_addins.R`, so it needs to land before E4 (`devtools::document()`
clean, full suite green) and be verified before E8 (submission). H3 stays
independent of release numbering, since it is an Ethos-repo check with no
surveyframe tarball content.

- [x] **H1 [Sonnet, worktree isolation]** Build the RStudio add-in per
  `todo_rstudio_addin.md`: `inst/rstudio/addins.dcf`,
  `R/rstudio_addins.R`, `rstudioapi` in Suggests, the 4 agreed menu items
  and nothing more. Nothing exists yet on any branch. The "do not merge
  until 0.3.4 is accepted" condition is now satisfied. Cut
  `feature/rstudio-addin` from `dev` in its own worktree; keep the diff
  to new files plus one DESCRIPTION line.
  **Done 2026-08-02, `feature/rstudio-addin` at 0194ffb.** 3 launchers and one skeleton insert, the agreed 4 and nothing more. All 3 constraints tested rather than asserted: `rstudioapi` in Suggests only, no file outside `R/rstudio_addins.R` calls `rstudioapi::`, and every binding fails soft. **The skeleton needed rewriting from source** — the guide's version passed `id =` to `sf_instrument()`, named the component list `items =`, and gave `sf_item()` an inline `choices =`, none of which exist. Since a bad skeleton teaches the wrong shape to whoever reaches for it first, the test parses it, evaluates it, validates the instrument, and round-trips it. 26 tests. Branched from `v0.5-dev` rather than `dev`, because it now ships in 0.4.0 and cutting from `dev` would have forced a merge.
- [x] **H2 [Owner]** Verify the add-in inside a real RStudio session.
  Cannot be automated. Must complete before E8.
  **Done 2026-08-15, owner-verified in a real RStudio session, not automated.**
  All 4 bindings confirmed present in the Addins menu (Open SurveyBuilder,
  Open SurveyStudio, Open Dashboard, Insert sframe skeleton) and all 4 run.
  **One real environment finding along the way, worth keeping rather than
  just noting as resolved:** `devtools::load_all()` left the Package column
  blank for all 4 bindings in the Addins list and every click produced
  `Error: unexpected ':::' in ':::'`, because RStudio builds the call as
  `<package>:::<binding>()` and couldn't resolve a package name for a
  dev-loaded (not installed) package. `devtools::install()` plus a full
  RStudio restart (not just Session > Restart R, which does not force a
  re-scan of installed packages' `addins.dcf` files) fixed it: Package
  column populated, all 4 entries run. `addin_launch_dashboard()` correctly
  errors with no instrument supplied ("needs an instrument to display,"
  telling the user to use `launch_dashboard_demo()` or `launch_studio()`
  instead), which is the designed fail-soft-with-a-real-message behaviour,
  not a defect. `review_040/19_rstudio_addin.qmd`'s own branch-location
  section is now stale (it still describes checking out
  `feature/rstudio-addin` in a worktree, from before the 2026-08-03 merge
  to `main`); not fixed this session, worth a pass before the review suite
  is next opened cold.
  **Also fixed in this pass, found by a live methodology question rather
  than the checklist:** the inserted skeleton (`addin_insert_skeleton`)
  built a 2-item scale and ran `reliability_alpha` on it. Alpha on exactly
  2 items reduces to a single pairwise correlation rather than measuring
  internal consistency, and a 2-indicator factor is not identifiable if
  the instrument is later carried into a measurement model, so the
  skeleton is now 3 items (`q1`, `q2`, `q3`, all labelled). Verified by
  running the skeleton (`valid`, 0 problems) and the full
  `test-rstudio-addins.R` suite, 26 passed, 0 failed. All changes staged,
  not committed.
- [ ] **H3 [Haiku]** Confirm the Ethos R bridge is repointed from asrda-r
  to surveyframe. Check in the Ethos repo, not this one. Independent of
  0.4.0's release numbering and its tarball.

## Block I. Planning, ecosystem, and the numbering note

- [x] **I1 [Opus]** Add the version-numbering note to CLAUDE.md and to
  memory, and correct the release order recorded there. Done 2026-07-30.
- [x] **I2 [Sonnet]** Log the renumbering in
  `../portfolio-planner/decisions.md`, superseding the 2026-07-25 and
  2026-07-26 entries on release numbers. Done 2026-07-30.
- [x] **I3 [Sonnet]** Update `master_roadmap.md` and `roadmap.md`. Both
  showed 0.3.4 as unshipped with a 2026-08-15 target, a live 0.3.5, and a
  0.5 slot. Done 2026-07-30.
- [ ] **I4 [Sonnet]** Update
  `development_instructions/12_publications_citations.md` for the 3-draft
  approach and whichever paper structure D4 picks.
- [ ] **I5 [Haiku]** Re-key the Ethos R-bridge milestone in
  `master_roadmap.md`'s ecosystem table to 0.4.0.
- [ ] **I6 [Sonnet]** Reconcile `master_todo.md`, stale since 2026-07-09.
- [ ] **I7 [Owner]** Owner reminders: ASRDA Part XII chapters 34 and 35
  revision once the MCDM API is final, Ethos surfacing MCDM in the
  following cycle, MCDM methodology paper kickoff (now block D).
- [ ] **I8 [Owner]** smallsamplelab book proofread and alignment, re-keyed
  off the old 0.4 date.
- [ ] **I9 [Opus decisions, Sonnet fixes]** Smaller carried items: the
  `.bib` reference carry-in decision (leaning defer), the Codecov badge in
  README, guarding the Shiny launcher `\donttest` examples so a full check
  cannot hang, the keep-versus-deprecate call on the standalone dashboard
  (`inst/shiny/dashboard/app.R`), and an interactive pass over
  `R/survey_module.R`.

---

## Totals

**33 open, 32 done, 65 total. Counted from the checkboxes on 2026-08-02.**

Done on 2026-08-02, on top of the 17 recorded on 2026-07-31: B4, B5, B6,
B9, B10, B11, B13, B14, B15, B16, C3, C4, C5, C6, and H1. That is 15
tasks, and 2 unplanned fixes alongside them.

**The 2 unplanned fixes were both pre-existing and both owner-decided.**
The Shiny collector emitted joined columns for matrix, ranking, and
multi-select, so that data could not be read back by the package at all;
fixed and recorded as breaking. A freshly built instrument was not a
serialisation fixed point, so identical content could carry 2 different
hashes depending on whether it had been through a read; fixed, with a test
asserting the 3 bundled instruments still hash to what they store, because
if that ever fails every `.sframe` in the wild moved with it.

Remaining split across the 33, counted from the tags: Sonnet-led 12,
Haiku-led 9, Owner or human 9, Opus-led 3.

By release: 0.4.0 carries 13 (blocks D and E, plus H2), 0.4.1 carries 10
in block F plus the 12 re-laned dogfeed entries, the expansion carries 4,
and 6 sit outside a single release (H3 and block I).
