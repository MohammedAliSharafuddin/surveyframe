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
2. **Which manuscript's DOI gates `inst/CITATION` for 0.4.0**, and does the
   MCDM paper describe the 10 shipped methods or the expanded set? If the
   expanded set, 0.4.0 ships on the small-sample DOI alone and the MCDM
   citation lands in 0.4.1 or 0.4.2. Affects D2, D5, D6.
3. **Confirm the 8-into-0.4.0 and 4-into-0.4.1 split** of the 12 open
   dogfeed items. Affects C4 and F5.

---

## Priority order

Work top down. Anything in the same tier can run in parallel.

- **P0, start now:** A1, B1, D1, D2, D3, I1, I2, I3.
- **P1, core engineering:** A2 to A5, B2 to B10, B12, B14.
- **P2, verification and docs:** B11, B13, B15, B16, C6, C7.
- **P3, calendar-bound field validation:** C1 to C5. ICSRI is 8 to 9 August
  2026, which now sits on the release's critical path.
- **P4, release:** D4, D5, D6, then E1 to E8. E8 cannot run before D6.
- **P5, after 0.4.0 ships:** F1 to F6, then G1 to G4.
- **Parallel at any time:** H1 to H3, I4 to I9.

Critical path: A1 unblocks B11 and B13. Block B completes the engineering,
which releases block D, whose DOI is the only hard CRAN blocker, which
releases block E. Block C is on the path too, because the release cannot
be submitted before ICSRI feedback is captured and triaged. B1 is the one
item that can invalidate work already built, so clear it early.

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

All 5 come from the 2026-07-26 independent validation. 4 of them shipped
inside 0.3.4. Detail and evidence: `../surveyframe-statistical-validation`
and the Claude memory `stat-validation-bugs-found`.

- [ ] **A1 [Opus]** Builder `qAdd()` fab menu and `varLevel()` switch gain
  `pairwise_comparison` and `criteria_weight`
  (`inst/builder/survey_builder.html`). Until this lands, `roleOptions()`
  returns nothing and all 10 MCDM methods are unbuildable in the GUI, even
  from an imported instrument. Shared file, lead only. **Do first.**
- [ ] **A2 [Sonnet, Opus review]** `item_report()` item-rest correlation
  (`R/psychometrics.R:179`). `cor(vals, total_score - vals)` uses
  `rowMeans()` where the standard needs the sum of the other items. Verify
  against `psych::alpha()$item.stats$r.drop`.
- [ ] **A3 [Sonnet, Opus review]** `sframe_run_repeated_anova()` never
  coerces `.subject` to a factor (`R/statistics_reports.R:956`), so `aov()`
  uses the wrong error stratum. Verify against `jmv::anovaRM()`.
- [ ] **A4 [Sonnet, Opus review]** `known_vars`
  (`R/validate_sframe.R:66`) needs the `item__sub` and `item__option`
  expansion the builder and `read_responses()` already use.
- [ ] **A5 [Sonnet, Opus review]** Model-role filtering by `model$type` in
  builder `roleOptions()` and in `seminr_syntax()` and
  `sem_lavaan_syntax()` (`R/model_layer.R`).

## Block B. 0.4.0 MCDM and decision-family completion

Spec: `todo_0.5.md`, sections 1 to 8. Re-grep every file and line anchor
before editing.

- [ ] **B1 [Owner, Opus]** Sign off the section 1 data contract (matrix
  encoding, aggregation defaults, column conventions). Never taken. Highest
  rework risk in the release, so clear it early.
- [ ] **B2 [Haiku transcription, Opus verification]** Verify page, volume,
  and journal for the 7 flagged citations and add all 8 missing entries to
  `.sframe_citations`. Only TOPSIS and AHP are in.
- [ ] **B3 [Opus decision]** Resolve DEMATEL's citation, unresolved between
  Gabus and Fontela 1972 and the 1976 observer report.
- [ ] **B4 [Sonnet, Opus review]** `sensitivity_analysis()` in
  `R/decision_sensitivity.R`: classed `sframe_sensitivity` object, `$table`,
  `plot()` and `print()` methods, callable from a plan block via
  `options$sensitivity = TRUE`.
- [ ] **B5 [Sonnet, or Opus decision to defer]** `sf_conjoint_design()`, a
  declared design generator and not an estimator. Named as the first
  deferral if the window tightens.
- [ ] **B6 [Sonnet]** Shiny renderer for both new item types in
  `R/render_survey.R` and `R/survey_module.R`. Neither file references
  either type today.
- [ ] **B7 [Sonnet]** Builder inspector editor for `comparison_items` and
  `comparison_scale`, plus Theme B preview parity.
- [ ] **B8 [Haiku]** Re-run `data-raw/inline_static_template.R` to
  regenerate the builder's inlined copy of the static template. The script
  is tracked on `dev` only, so copy it into the worktree first. The
  inlined copy currently has none of the pairwise rendering.
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
- [ ] **B12 [Opus decision]** PROMETHEE's CHECK status: accept RMCDA's
  linear preference function as a documented difference, or implement the
  standard step function.
- [ ] **B13 [Haiku]** Verify SurveyStudio MCDM support live against fixed
  builder output.
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

- [ ] **C1 [Owner]** Capture ICSRI 2026 audience feedback, Villa College,
  8 to 9 August 2026, into `dogfeed.todo.md`, one entry each, status open.
- [ ] **C2 [Owner]** Run 3 to 5 short real surveys end to end with
  recruited testers, covering the surfaces that changed most: the builder
  rework, the Interpretations canvas, PDF report output, and the
  date-bounds path.
- [ ] **C3 [Opus]** Triage every item to 0.4.0, 0.4.1, or wontfix.
  Patch-scope constraints no longer bind.
- [ ] **C4 [Opus lead, Sonnet batches, Haiku verification]** Clear the 8
  machine-fixable open items already logged: B1.3 interpretation and
  decision-rule pairing, D2.5 phone-width scale-correlation heatmap, D2.6
  filter live-check and full levels and labels audit, E2.6 bounds error
  message styling, H1.4 and H1.5 vignette prose and `browseVignettes()`
  presentability, J1.5 APA interval prose, K1.7 MCAR interpretation
  wording, L1.4 to L1.7 PDF pagination, greyscale legibility, browser
  print and brand colour, N1.9 SurveyStudio Copy-result clipboard.
- [ ] **C5 [Opus lead, Haiku verification]** Record the rounds in
  `mas_review_040.md`, modelled on `mas_review_034.md`, chromote-verified
  for every UI item.
- [ ] **C6 [Haiku]** Fix README's Roadmap section, which still promises
  small-sample inference at v0.4 and MCDM at v0.5. It is live on CRAN and
  on the pkgdown site.
- [ ] **C7 [Haiku]** Close the ignore-file gaps. `.Rbuildignore` still
  names `todo_0.4.1.md` (renamed to `todo_0.5.1.md` on 2026-07-25) and
  omits `todo_0.5.1.md`, `kimi_review_034.md`, `qwen_review_034.md`, and
  `todo_master_0.4.md`. `main`'s `.gitignore` names only the original 6
  dev-only files, so the 12 newer planning files are not excluded there.

## Block D. 0.4.0 manuscripts and the CITATION gate

Owner decision 2026-07-30: write all 3 drafts, then decide 1 paper or 2.
RMCDA's breadth expanded what 0.4.1 and 0.4.2 will carry, which changes
what an MCDM paper should claim.

- [ ] **D1 [Sonnet draft, Opus review]** Small-sample-only manuscript.
- [ ] **D2 [Sonnet draft, Opus review]** MCDM-only manuscript, covering the
  10 methods that ship in 0.4.0, with the RMCDA expansion named as
  roadmap rather than claimed as shipped.
- [ ] **D3 [Sonnet draft, Opus review]** Combined small-sample plus MCDM
  manuscript.
- [ ] **D4 [Owner]** Proofread all 3 and decide 1 combined paper or 2
  separate papers.
- [ ] **D5 [Owner]** Post the chosen preprint or preprints, obtain the DOI
  or DOIs.
- [ ] **D6 [Haiku]** Add the resulting bibentry or bibentries to
  `inst/CITATION`. **Hard CRAN blocker.** CRAN will not accept a
  placeholder DOI.

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
- [ ] **F6 [Haiku, Owner submits]** Release process and submission.

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

## Block H. Independent of release numbering

- [ ] **H1 [Sonnet, worktree isolation]** Build the RStudio add-in per
  `todo_rstudio_addin.md`: `inst/rstudio/addins.dcf`,
  `R/rstudio_addins.R`, `rstudioapi` in Suggests, the 4 agreed menu items
  and nothing more. Nothing exists yet on any branch. The "do not merge
  until 0.3.4 is accepted" condition is now satisfied.
- [ ] **H2 [Owner]** Verify the add-in inside a real RStudio session.
  Cannot be automated.
- [ ] **H3 [Haiku]** Confirm the Ethos R bridge is repointed from asrda-r
  to surveyframe. Check in the Ethos repo, not this one.

## Block I. Planning, ecosystem, and the numbering note

- [ ] **I1 [Opus]** Add the version-numbering note to CLAUDE.md and to
  memory, and correct the release order recorded there. Done 2026-07-30.
- [ ] **I2 [Sonnet]** Log the renumbering in
  `../portfolio-planner/decisions.md`, superseding the 2026-07-25 and
  2026-07-26 entries on release numbers. Done 2026-07-30.
- [ ] **I3 [Sonnet]** Update `master_roadmap.md` and `roadmap.md`. Both
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

64 tasks. Sonnet 26, Haiku 15, Owner or human 12, Opus lead 11.

By release: 0.4.0 carries 42 (blocks A to E), 0.4.1 carries 6, the
expansion carries 4, and 12 sit outside a single release (blocks H and I).
