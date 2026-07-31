# todo_master_0.4.md — the canonical task list for CRAN 0.4.0, 0.4.1, and 0.4.2

Dev-only planning file, tracked on `dev` only. Add its name to `.gitignore`
on `main` and to `.Rbuildignore` (see A7 and C7 below, which cover the
whole ignore-file gap).

Written 2026-07-30. **This is the single entry point for release work from
here.** The per-release files stay in place for their detail:
`todo_0.5.md` (the 0.4.0 engineering spec), `todo_0.4.md` (the
small-sample record, already built), `todo_0.5.1.md` (the 0.4.1 demo
patch), `todo_0.3.5.md` (superseded, absorbed), `todo_rstudio_addin.md`,
and `todo_0.6.md` through `todo_1.0.md` for later releases.

---

## Version numbering: local labels versus CRAN versions

**The local development labels and the CRAN version numbers deliberately
differ.** Owner decision 2026-07-30. Do not rename branches, worktrees, or
planning files to match CRAN.

| Local label (keep as is) | CRAN version | Content |
|---|---|---|
| branch `v0.5-dev`, worktree `../surveyframe-v0.5-dev`, `todo_0.5.md` | **0.4.0** | MCDM plus small-sample plus the 5 bug fixes plus absorbed field validation |
| `todo_0.5.1.md` | **0.4.1** | Faculty demo proofing plus the device-dependent field items |
| the RMCDA expansion, block G below | **0.4.2** onward | The roughly 41 extra MCDM methods |
| `todo_0.3.5.md` | never published | Absorbed into 0.4.0 and 0.4.1 |
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
OK with no notes. `main` at 6556f91 matches the public repository. The
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
   papers' preprint DOIs gate `inst/CITATION` for 0.4.0 independently;
   D3 (the combined draft) is dropped and D4 no longer needs an owner
   1-vs-2 read, since 2 was decided directly. See the journal and title
   decisions in D1/D2 below and the paper-track entry in
   `../portfolio-planner/decisions.md`.
3. **Confirm the 8-into-0.4.0 and 4-into-0.4.1 split** of the 12 open
   dogfeed items. Affects C4 and F5.

---

## Priority order

Work top down. Anything in the same tier can run in parallel.

- **P0, done 2026-07-31:** A2 to A5, all 4 validation bug fixes, on
  `v0.5-dev` at 0743e10. (B1, A1, A6, C8, I1, I2, I3, B2, B3, B12, and C7
  are also done. C7 landed on `main` at 556743d.)
- **P1, core engineering, now the live tier:** B4, B5, B6, B9, B10, B14,
  and **H1 (the RStudio add-in build, folded into 0.4.0 scope
  2026-07-31)**, worktree isolated so it cannot collide with `v0.5-dev`.
- **P2, verification and docs:** B11, B13, B15, B16, C6, and **H2 (verify
  the add-in in a real RStudio session, owner-only, cannot be
  automated)**.
- **P3, field validation (narrowed 2026-07-31):** C3 to C5 only. C1 and
  C2 moved to block F (0.4.1) and no longer gate 0.4.0.
- **P4, manuscript and release:** **D2, D2a (the MCDM paper) do not start
  until 0.4.0's engineering is submission-ready** (owner decision
  2026-07-31), since the paper describes the shipped software. Then D4,
  D5, D6, then E1 to E8. E8 cannot run before D6.
- **P5, after 0.4.0 ships:** F0, F0a, F0b, F0c (the small-sample paper,
  moved here 2026-07-31 so its applied-validation section can draw on
  F0a's real-survey data), F1 to F6, then G1 to G4.
- **Parallel at any time:** H3 (Ethos repo check, no surveyframe tarball
  content, stays independent of release numbering), I4 to I9.

Critical path, restated 2026-07-31. Block A is closed and B1 signed off,
so nothing outstanding can now invalidate work already built. What
remains of block B (B4, B5, B6, B9, B10, B14) completes the engineering,
which releases the vignette and the browser passes, which release block
D, whose preprint DOI is the only hard CRAN blocker, which releases block
E. ICSRI and the real-survey rounds no longer sit on this path, since
C1/C2 moved to 0.4.1, and neither does the small-sample paper, since
D1/D1a moved with them.

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

Spec: `todo_0.5.md`, sections 1 to 8. Re-grep every file and line anchor
before editing.

- [x] **B1 [Owner, Opus]** Sign off the section 1 data contract (matrix
  encoding, aggregation defaults, column conventions). **Signed off
  2026-07-31.** Verified the built code on `v0.5-dev` against every
  subsection of `todo_0.5.md` section 1: the two matrix kinds (1a) stay
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
- [ ] **B4 [Sonnet, Opus review]** `sensitivity_analysis()` in
  `R/decision_sensitivity.R`: classed `sframe_sensitivity` object, `$table`,
  `plot()` and `print()` methods, callable from a plan block via
  `options$sensitivity = TRUE`.
- [ ] **B5 [Sonnet]** `sf_conjoint_design()`, a declared design generator
  and not an estimator. **Owner decision 2026-07-31: build it in 0.4.0**,
  superseding its standing as the first deferral if the window tightens.
  A new export is a permanent CRAN API commitment, so this was decided
  explicitly rather than allowed to drift.
- [ ] **B6 [Sonnet]** Shiny renderer for both new item types in
  `R/render_survey.R` and `R/survey_module.R`. Neither file references
  either type today.
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
- [ ] **B9 [Sonnet]** Google Sheets Apps Script generator
  (`R/google_sheets.R`) emits the 3 new column patterns, plus the round
  trip from static survey to collector CSV to `read_responses()` to
  assembled matrix.
- [ ] **B10 [Sonnet]** Exempt the pairwise columns from
  `quality_report()`'s straightlining and speeding checks.
- [ ] **B11 [Opus decision, Haiku automation]** UI/UX and stress review for
  the 7 methods not yet covered (TOPSIS, VIKOR, MOORA, SMART, WASPAS,
  PROMETHEE, ELECTRE): web and mobile rendering, simulated results, 9x9
  stress test, grouped versus separate layout. Runs after A1. Already done
  for AHP, ANP, and DEMATEL.
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
- [ ] **B13 [Haiku]** Verify SurveyStudio MCDM support live against fixed
  builder output. **Partly unblocked 2026-07-30**: `studio_level_meta()` had
  no branch for either decision item type, so every MCDM role dropdown in the
  studio was empty. Fixed with the scale-aware split in 83ce595 (see A6). The
  live click-through in a running app is still open, and it is where the rest
  of the studio's decision handling gets checked.
- [ ] **B14 [Sonnet, Opus review]** Build the section 1g sample sframe as a
  real fixture. Release gate: builds with shipped constructors, validates,
  round-trips with a stable hash, renders on all 3 survey surfaces, exports
  the exact 42 expansion columns, and all 4 plan blocks return a table and
  a chart with no error field.
- [ ] **B15 [Sonnet]** `vignettes/mcdm-analysis.Rmd` to the 0.3.4 house
  rules: offline knit, `set.seed()`, shared WCAG style block, `lang:
  en-GB`, `fig.alt` on every chart.
- [ ] **B16 [Haiku]** axe-core pass through chromote on the new vignette,
  zero violations. `_pkgdown.yml` has no vignette listing, so no pkgdown
  edit is needed.

## Block C. 0.4.0 field validation, absorbed from 0.3.5

Was `todo_0.3.5.md`. No 0.3.5 release ships. Dogfeed protocol applies:
while a feedback session is open, log only and edit no source file.

**C1 and C2 moved to block F (0.4.1) on 2026-07-31.** ICSRI capture and
the 3-to-5 real-survey rounds no longer gate 0.4.0. This block now
covers only the 12 dogfeed items already logged before this date; the
fresh ICSRI and real-survey feedback is captured and triaged as 0.4.1
work instead (see F0/F0a and F4 below).

- [ ] **C3 [Opus]** Triage the 12 already-logged items to 0.4.0 or
  wontfix. Patch-scope constraints no longer bind. (Splitting fresh
  ICSRI/real-survey feedback no longer applies here, since that capture
  itself now happens under block F.)
- [ ] **C4 [Opus lead, Sonnet batches, Haiku verification]** Clear the 8
  machine-fixable open items already logged: B1.3 interpretation and
  decision-rule pairing, D2.5 phone-width scale-correlation heatmap, D2.6
  filter live-check and full levels and labels audit, E2.6 bounds error
  message styling, H1.4 and H1.5 vignette prose and `browseVignettes()`
  presentability, J1.5 APA interval prose, K1.7 MCAR interpretation
  wording, L1.4 to L1.7 PDF pagination, greyscale legibility, browser
  print and brand colour, N1.9 SurveyStudio Copy-result clipboard.
- [ ] **C5 [Opus lead, Haiku verification]** Record this block's fixes in
  `mas_review_040.md`, modelled on `mas_review_034.md`, chromote-verified
  for every UI item. Narrower in scope than before: covers only C4's 8
  items, since the ICSRI/real-survey rounds that used to feed this
  document now get recorded under F4's `mas_review_041.md` instead.
- [ ] **C6 [Haiku]** Fix README's Roadmap section, which still promises
  small-sample inference at v0.4 and MCDM at v0.5. It is live on CRAN and
  on the pkgdown site.
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
  matched nothing since the 2026-07-25 rename to `todo_0.5.1.md`. This
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

- [ ] **D2 [Sonnet draft, Opus review]** MCDM-only manuscript,
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
  ship in 0.4.0 only, with the RMCDA expansion named as roadmap rather
  than claimed as shipped.
  - [ ] **D2a [Sonnet]** OpenAlex query pass over the MCDM literature:
    search works for all 10 shipped methods (AHP, ANP, DEMATEL, VIKOR,
    MOORA, SMART, WASPAS, PROMETHEE, ELECTRE, TOPSIS) plus the ~41 RMCDA
    extras, ranked by work and citation count, to (i) confirm the 10
    chosen for 0.4.0 are in fact the most widely used core rather than
    an arbitrary subset, and (ii) produce a data-driven priority order
    for the 0.4.2+ expansion batches, feeding directly into G1's open
    decision. Free API, no key, `https://api.openalex.org/works`. Write
    the script in R (`httr2`/`jsonlite`) in `mcdm/` or a new
    `mcdm-paper/` alongside it, one source-file-name comment per house
    style.
- [ ] **D4 [Owner]** Proofread the MCDM draft.
- [ ] **D5 [Owner]** Post the MCDM preprint, obtain its DOI.
- [ ] **D6 [Haiku]** Add the MCDM bibentry to `inst/CITATION`. **Hard
  CRAN blocker.** CRAN will not accept a placeholder DOI.

## Block E. 0.4.0 release paperwork

- [ ] **E1 [Haiku]** Set DESCRIPTION to `0.4.0`. The branch stays
  `v0.5-dev`.
- [ ] **E2 [Sonnet]** NEWS.md entry headed 0.4.0, as a clean per-release
  changelog, stating that 0.3.5 and 0.5 were planned and never released
  and what each absorbed.
- [ ] **E3 [Sonnet]** `cran-comments.md` for the merged diff, framed as
  0.3.4 to 0.4.0.
- [ ] **E4 [Haiku]** `devtools::document()` clean, full suite green.
- [ ] **E5 [Haiku]** `R CMD check --as-cran` at 0 errors, 0 warnings, at
  most 1 note, plus `urlchecker::url_check()` and
  `spelling::spell_check_package()`.
- [ ] **E6 [Haiku]** Win-builder R-release and R-devel, both Status OK.
- [ ] **E7 [Haiku]** Confirm no dev-only file reaches the tarball or
  pkgdown, and that pkgdown builds from `main` only.
- [ ] **E8 [Owner]** CRAN submission as 0.4.0, minding the release-spacing
  preference against 2026-07-24.

## Block F. CRAN 0.4.1, faculty demo proofing

Detail: `todo_0.5.1.md`. Strict patch scope, UI, UX, and documentation
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
- [ ] **G2 [Sonnet]** Write the expansion planning file on `todo_0.5.md`'s
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

- [ ] **H1 [Sonnet, worktree isolation]** Build the RStudio add-in per
  `todo_rstudio_addin.md`: `inst/rstudio/addins.dcf`,
  `R/rstudio_addins.R`, `rstudioapi` in Suggests, the 4 agreed menu items
  and nothing more. Nothing exists yet on any branch. The "do not merge
  until 0.3.4 is accepted" condition is now satisfied. Cut
  `feature/rstudio-addin` from `dev` in its own worktree; keep the diff
  to new files plus one DESCRIPTION line.
- [ ] **H2 [Owner]** Verify the add-in inside a real RStudio session.
  Cannot be automated. Must complete before E8.
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

**48 open, 17 done, 65 total. Counted from the checkboxes on
2026-07-31, not carried forward.**

The earlier figure of 66 was one too many, and 3 items (I1, I2, I3) had
been recorded as "Done 2026-07-30" in their text while their boxes stayed
unticked. Both are corrected here. The total moved to 65 when D3, the
combined manuscript, was dropped on 2026-07-31.

Done: A1, A6, B7, B8, C8, I1, I2, I3 on 2026-07-30, then B1, A2, A3, A4,
A5, B2, B3, B12, and C7 on 2026-07-31.

**9 closed on 2026-07-31**, of which 2 cost far less than the list
implied. B12 needed no engineering at all, since the step function was
already implemented and already the default, leaving only the missing
documentation. C7 was a `main`-only gap, `dev` having carried all 12
entries all along. Against that, A5 cost more than budgeted: its guard
exposed the same defect in both bundled demo instruments, so the data had
to be repaired and re-hashed as well.

Remaining split across the 48, counted from the tags: Sonnet-led 18,
Haiku-led 12, Owner or human 11, Opus-led 7.

By release: 0.4.0 carries 40 (blocks A to E, minus C1/C2 and D1/D1a,
plus H1/H2 added 2026-07-31), 0.4.1 carries 10 (F0, F0a, F0b, F0c added
2026-07-31, on top of the original 6), the expansion carries 4, and 10
sit outside a single release (H3 and block I).
