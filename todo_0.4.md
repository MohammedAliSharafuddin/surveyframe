# todo_0.4.md — surveyframe 0.4.0: MCDM, DEMATEL, and small-sample inference

> **SHIPPED. CRAN 0.4.0, released as this file's version number directly
> (owner decision 2026-08-15: local labels now match CRAN numbers, so
> there is no more 0.5-for-0.4.0 mismatch to track).** Branch `v0.5-dev`
> and worktree `../surveyframe-v0.5-dev` keep their historical names,
> since renaming a branch after the fact buys nothing; only this file's
> own name changed. The canonical task list, priority order, and model
> tiers are in `todo_master_0.4.md`.
>
> **This file merges 2 previously separate planning files, renumbered
> 2026-08-15**: the file formerly named `todo_0.5.md` (MCDM and DEMATEL,
> the larger and more current of the two, kept below as the main body)
> and the file formerly named `todo_0.4.md` (small-sample inference,
> kept below as an appendix). Both tracks merged into one release on
> 2026-07-25 and both are fully implemented, tested, and shipped in
> CRAN 0.4.0. Read this file as a historical engineering record, not a
> live task list.
>
> **Status 2026-08-15: engineering, review, and release paperwork all
> complete.** DESCRIPTION at `0.4.0`, NEWS.md complete (including the
> MCDM and small-sample sections themselves, added 2026-08-15 after
> being found missing), `R CMD check --as-cran` Status OK at 0 errors,
> 0 warnings, 0 notes, `cran-comments.md` drafted, tarball audited clean
> of dev-only files, `inst/CITATION` citing SF2 with no DOI dependency.
> A tarball passed win-builder R-release the same day. CRAN itself is
> closed for scheduled maintenance from 2026-08-05 to 2026-08-19;
> submission (E8) follows on or after 2026-08-20.

---

## Main body: MCDM and DEMATEL (formerly `todo_0.5.md`)


Dev-only planning file, tracked on `dev` only. Its name is in `.gitignore`
and `.Rbuildignore`. Companion to `CLAUDE.md`, `todo_0.4.md`, and
`../portfolio-planner/development_instructions/06_v05_v07_implementation.md`
(the original guide, v0.5 section — treat it as intent, this file as the
verified plan).

Last updated: 2026-07-26. Target CRAN submission: TBC (was 2027-01-25
pre-merge, `../portfolio-planner/master_roadmap.md`). **0.4 merged into
0.5 on 2026-07-25** (owner decision, fired early — see decisions.md);
the small-sample track from `todo_0.4.md` is already implemented and
tested on `v0.5-dev` (branched from the committed `v0.4-dev`), so this
release now carries both tracks. Superseded: the "do not start before
0.4 ships" condition and the 2026-10-15 decision gate below, both from
the pre-merge plan.

**2026-07-26 update (recorded in `../portfolio-planner/decisions.md`):
RMCDA (CRAN) discovered as much broader prior art (~51 methods vs the
10 planned here). Owner decisions**: 0.5's shipped scope stays the
original 10 methods below; the RMCDA-sourced extras ship as follow-up
patches starting at **0.5.2** (0.5.1 stays the faculty-demo patch,
`todo_0.5.1.md`); RMCDA is added as a Suggests-only, guarded, test-time
dependency to cross-check surveyframe's own computations (never a
runtime Import); and the small-sample paper is being rewritten to
include MCDM content, deliberately held back from posting its preprint
until **this file's original 10 methods** (not the 0.5.2+ expansion)
are complete — this is now what gates `inst/CITATION`'s preprint
bibentry, not a dated external checkpoint.

~~**Decision gate 2026-10-15**~~ — superseded, the merge already fired.

**2026-07-26: all 10 methods implemented and wired, committed on
`v0.5-dev`.** Phase 1 (data contract, item types at the R level,
`R/decision_data.R`, TOPSIS as the reference runner) and Phase 2 (the
remaining 9 methods — AHP, ANP, DEMATEL, VIKOR, MOORA, SMART, WASPAS,
PROMETHEE, ELECTRE — built in 4 parallel agents, each in its own file
to avoid concurrent-edit conflicts) are both done and consolidated:
every method dispatches through `sframe_run_one_block()`'s switch,
`sframe_analysis_roles()`'s fallback, and `sframe_plot_for_result()`;
both UI registries (builder `ANALYSIS_REGISTRY` + dropdown, studio
registry + requirements strings) list all 10; full test suite green
(all `test-decision-*.R` files plus the pre-existing suite);
`devtools::document()` clean; all 10 methods smoke-tested end to end
through `run_analysis_plan()` including plot attachment.
`R CMD check --as-cran` run in progress as of this update.

RMCDA (CRAN, ~51 methods) added as a Suggests-only, guarded, test-time
dependency and used as a cross-check oracle in the new test files —
this caught one real bug (WASPAS's normalisation was wrong, borrowed
from SMART instead of using its own ratio-to-best convention; fixed
and verified against RMCDA's published worked example).

**Still open, not done in this pass**: citations for 8 of the 10
methods (only AHP's Saaty 1980 is added to `.sframe_citations`; the
other 8 are recorded in the harvest audit below but flagged as
needing page/volume/journal-name verification before they can be
added, or — for DEMATEL — genuinely unresolved between two candidate
sources); `sensitivity_analysis()` (section 5); `sf_conjoint_design()`
(section 6); the vignette (section 7); the three rendering surfaces
for `pairwise_comparison`/`criteria_weight` on the static template and
Shiny renderer (the builder inspector editor status needs checking —
not confirmed done or not in this pass); win-builder; `cran-comments.md`.

All file/line anchors below were verified against `main` on 2026-07-25
(0.3.4 feature-complete). Line numbers will drift: **re-grep every anchor
before editing**, the function names are the stable reference.

---

## Architecture ground truth (verified, corrects the 06 guide)

The guide assumes a method registry table with
`list(id=, fn=, required_n=, small_sample=)` entries. **No such registry
exists in R.** The real architecture:

- Dispatch is a plain `switch(test, ...)` inside
  `sframe_run_one_block()` at `R/analysis_plan.R:1101`. `family` is
  descriptive metadata on the block (`block$family`), never dispatched on.
- Runners are `sframe_run_<id>(data, vars)` or
  `sframe_run_<id>(data, roles, options)` returning a flat named list:
  `test` (the method id), `apa` string, `prompt` string, effect-size
  fields where they exist, and `error` string on any failure (never
  `stop()` — the switch is wrapped in `tryCatch()` but runners handle
  their own expected failures).
- Tables are humanised centrally: `sframe_run_one_block()` passes every
  `$table` through `sframe_humanize_table(sframe_label_lookup(instrument))`
  (`R/analysis_plan.R:1180`). Runners emit raw ids and coded values.
- Missing `$table` is backfilled by `sframe_result_table()`
  (`R/analysis_plan.R:845`, a switch on test id).
- Plots attach centrally via `sframe_plot_for_result()`
  (`R/plots.R:636`, a switch on test id mapping to `sframe_plot_*()`
  helpers built on `theme_surveyframe()` with `palette = c("web","print")`).
- Citations come from `.sframe_citations` (`R/analysis_plan.R:9`), a list
  whose entries carry a `use` vector of method ids;
  `sframe_citations_for_test()` (`R/analysis_plan.R:92`) filters on it.
- **Two JS/Shiny registries mirror the method list and must be updated in
  lockstep:** the builder's `ANALYSIS_REGISTRY`
  (`inst/builder/survey_builder.html` ~line 2690) plus its method
  `<optgroup>` dropdown (~line 969), and the studio's registry in
  `inst/shiny/app.R` (~line 324, built with a local `role()` helper) plus
  its requirements strings (~line 722).
- Plan blocks round-trip through `sframe_restore_analysis_block()`
  (`R/read_write_sframe.R:254`). **Any new block field not restored there
  silently drops on write_sframe()/read_sframe().**
- Missing optional packages use `sframe_require_<pkg>()` helpers in
  `R/conditions.R` wrapping `rlang::check_installed()` (pattern:
  `sframe_require_psych`, `R/conditions.R:26`).

## Harvest audit (completed 2026-07-25)

Source: `../mcdm` (cloned 2026-07-25). Every method lives in
`R/methods/<id>.R` and registers itself with `register_method(name,
description, func, category, requires_pairwise)` from `R/registry.R`
into an environment-backed `MCDM_REGISTRY`. Each computation function
has the fixed signature `<id>_method(X, w, cb)` where `X` is a numeric
matrix, `w` a numeric weight vector, and `cb` a **logical** vector
(TRUE = benefit). surveyframe uses `criteria_types = c("benefit",
"cost")`, so every port converts once at the boundary.

**All 10 are pure R with zero Shiny entanglement.** A grep for
`shiny|reactive|req(|input$|output$|showNotification` across
`R/methods/`, `R/utils_normalise.R`, `R/utils_weights.R` and
`R/utils_validate.R` returns nothing. The Shiny layer sits entirely
above the registry. The only non-pure behaviour inside the method files
is two `cat()` calls (ahp.R:39, dematel.R:28) printing to the console
from inside a computation, which must not survive the port.

**No citations exist anywhere in the mcdm repo.** No `references`
field, no DOI, no author-year string, in any of the 10 method files or
the registry. The "citation keys used" column below is therefore
*not* harvested from the source — it is the standard originating
reference for each method, supplied here from general knowledge and
marked with a confidence flag. **Nothing in the flagged rows may be
added to `.sframe_citations` until it is checked against the actual
publication.** Only the rows marked `verified` are cleared for use.

| Method | Source file | Computation fn | Pure R | Rework | Originating reference (confidence) |
|---|---|---|---|---|---|
| TOPSIS | `R/methods/topsis.R` (81) | `topsis_method(X, w, cb)` | yes | trivial | Hwang, C.-L., & Yoon, K. (1981). *Multiple attribute decision making: Methods and applications*. Springer. — **verified**, standard |
| AHP | `R/methods/ahp.R` (84) | `ahp_method(X, w = NULL, cb = NULL)` | yes (one `cat()`) | moderate | Saaty, T. L. (1980). *The analytic hierarchy process*. McGraw-Hill. — **verified**, standard. AIJ geometric-mean aggregation: Aczél & Saaty (1983), *Journal of Mathematical Psychology*, 27(1), 93-102 — *flagged, check volume/pages*. Forman & Peniwati (1998), *EJOR*, 108(1), 165-169 — *flagged* |
| ANP | `R/methods/anp.R` (72) | `anp_method(X, w = NULL, cb = NULL)` | yes | significant | Saaty, T. L. (1996). *Decision making with dependence and feedback: The analytic network process*. RWS Publications. — *flagged, check edition/year* |
| DEMATEL | `R/methods/dematel.R` (113) | `dematel_method(X, w = NULL, cb = NULL)` | yes (one `cat()`) | moderate | Gabus, A., & Fontela, E. (1972). *World problems, an invitation to further thought within the framework of DEMATEL*. Battelle Geneva Research Centre. — **corrected**: the brief's "Fontela & Gabus 1976" is a different report (*The DEMATEL observer*, 1976). Web-checked 2026-07-25; both are grey-literature Battelle reports, so *flagged* until a copy is sighted |
| ELECTRE | `R/methods/electre.R` (154) | `electre_method(X, w, cb, thresholds = NULL)` | yes | significant | Roy, B. (1968). Classement et choix en présence de points de vue multiples (la méthode ELECTRE). *RIRO*, 2(8), 57-75. — *flagged, check journal name and pages* |
| MOORA | `R/methods/moora.R` (88) | `moora_method(X, w, cb)` | yes | trivial | Brauers, W. K. M., & Zavadskas, E. K. (2006). The MOORA method and its application to privatization in a transition economy. *Control and Cybernetics*, 35(2), 445-469. — *flagged, check pages* |
| PROMETHEE | `R/methods/promethee.R` (119) | `promethee_method(X, w, cb, preference_function = "linear", thresholds = NULL)` | yes | moderate | Brans, J. P., & Vincke, P. (1985). A preference ranking organisation method. *Management Science*, 31(6), 647-656. — *flagged, check pages* |
| SMART | `R/methods/smart.R` (49) | `smart_method(X, w, cb)` | yes | trivial | Edwards, W. (1977). How to use multiattribute utility measurement for social decisionmaking. *IEEE Transactions on Systems, Man, and Cybernetics*, 7(5), 326-340. — *flagged, check pages* |
| VIKOR | `R/methods/vikor.R` (90) | `vikor_method(X, w, cb, v = 0.5)` | yes | moderate | Opricovic, S., & Tzeng, G.-H. (2004). Compromise solution by MCDM methods: A comparative analysis of VIKOR and TOPSIS. *European Journal of Operational Research*, 156(2), 445-455. — *flagged, check pages*. The true origin is Opricovic's 1998 Belgrade thesis, in Serbian, which we cannot sight |
| WASPAS | `R/methods/waspas.R` (64) | `waspas_method(X, w, cb, lambda = 0.5)` | yes | trivial | Zavadskas, E. K., Turskis, Z., Antucheviciene, J., & Zakarevicius, A. (2012). Optimization of weighted aggregated sum product assessment. *Elektronika ir Elektrotechnika*, 122(6), 3-6. — *flagged, check issue/pages* |

Shared helpers worth porting or deliberately not porting:

- `R/utils_normalise.R` (132): `normalise_vector`, `normalise_minmax`,
  `normalise_vector_norm`, `normalise_sum`, `normalise_max`,
  `normalise_matrix(method=)`. All pure, all trivial to port. Each
  method needs only one of them, so port per method rather than
  wholesale.
- `R/utils_weights.R` (287): entropy, standard-deviation, variance and
  CRITIC objective weighting. **Out of 0.5 scope** — surveyframe's
  weights come from respondents (section 1d) or the researcher. Note
  as a candidate for a later release, do not port now.
- `R/utils_validate.R` (298): `validate_mcdm_inputs`,
  `validate_method_requirements`, `clean_and_validate`,
  `check_data_quality`, `validate_decision_matrix`. Superseded by
  `sframe_check_decision_input()` (section 3) plus
  `sframe_decision_options()` (1e). Do not port; read for edge cases
  only.
- `R/utils_plots.R` (692) and `R/registry.R` (112): not ported. The
  plot layer is `theme_surveyframe()`-based here, and there is no R
  registry in surveyframe (see Architecture ground truth).

Defects in the source that must **not** be carried across (found while
auditing, each one is a correctness issue, not a style preference):

1. **TOPSIS double-inverts cost criteria.**
   `normalise_vector_norm()` (utils_normalise.R:55-58) takes the
   complement `1 - x/||x||` for cost columns, and then
   `topsis_method()` (topsis.R:22-30) *also* swaps the ideal and
   anti-ideal for cost columns. The two inversions cancel, so a cost
   criterion is scored as a benefit. Standard TOPSIS applies vector
   normalisation with no complement and handles direction once, at the
   ideal/anti-ideal step. The port does it once.
2. **AHP and DEMATEL silently fabricate their input matrix.** Both
   detect a non-square `X` and invent a square one — AHP from ratios of
   column means (ahp.R:16-40), DEMATEL from the criteria correlation
   matrix scaled to 0-4 (dematel.R:12-29), each announcing itself with
   `cat()`. Drop both branches. In surveyframe the square matrix comes
   from `sframe_assemble_pairwise()` or `options$matrix`, and a
   non-square input is a typed error.
3. **AHP clamps RI beyond n = 10** (`else 1.49`, ahp.R:62) rather than
   refusing. Section 3 requires an `error` beyond n = 10.
4. **VIKOR omits both acceptance conditions.** vikor.R computes S, R, Q
   and stops. Acceptable advantage and acceptable stability must be
   evaluated (section 3). Also note `scores <- 1 - Q` (vikor.R:67) is
   a display convention invented for the app's shared score column;
   report Q itself and rank ascending.
5. **ELECTRE's veto check is a no-op loop.** electre.R:111-116 loops
   over `j` while testing a `j`-independent condition, so the loop body
   either breaks on the first iteration or never fires. The file is
   also labelled "ELECTRE III" while section 3 specifies ELECTRE I.
   Treat as a rewrite against the published definition, not a port.
6. **PROMETHEE defaults to the linear (V-shape) preference function
   with thresholds derived from the data range** (promethee.R:12,
   19-25). Section 3 specifies the usual criterion (type 1) as the
   default. Data-derived thresholds are a hidden researcher degree of
   freedom and must be explicit in `options` if offered at all.
7. **DEMATEL's threshold is `mean(T) + sd(T)`** (dematel.R:102).
   Section 3 specifies the arithmetic mean of T. Keep the mean; the
   mean+sd variant may be offered through `options$threshold_rule`.
8. **ANP is not ANP.** anp.R is a column-normalised power iteration
   over whatever square matrix it is handed, capped at 100 iterations,
   with no cluster/supermatrix construction and no unweighted-to-
   weighted supermatrix step. Section 3's 1000-iteration convergence
   guard is a floor, not the whole gap. Budget ANP as the largest
   single computation task in phase 2.

## Integration checklist for every new method (all 10 MCDM runners)

1. Runner `sframe_run_<id>(data, roles, options)` in `R/decision_methods.R`.
2. `switch()` case in `sframe_run_one_block()` (`R/analysis_plan.R:1101`).
3. Roles: decision methods are roles-based (a matrix item id plus
   options), so no `sframe_vars_for_method()` entry is needed unless a
   method takes plain variables. Add a default-roles fallback in
   `sframe_analysis_roles()` (`R/statistics_reports.R:57`) mapping
   `variables[1]` to the matrix-item role for blocks declared without
   roles.
4. Citation entries in `.sframe_citations` with the method id in `use`.
   Harvest the reference list from the mcdm repo and verify each one
   before adding (standing no-unverified-references rule).
5. `$table` returned by the runner (the ranking or cause-effect frame).
6. Plot case in `sframe_plot_for_result()` plus the helper in `R/plots.R`.
7. Builder: `<optgroup label="Decision">` in the method dropdown plus an
   `ANALYSIS_REGISTRY` entry per method (copy the `mann_whitney` entry
   shape: family, label, roles with min/max/levels, showAlpha,
   showHypotheses, showEffectSize, assumptions, output, refs).
8. Studio: registry entry (~app.R:324 shape) and requirements string.
9. Matrix, weights, labels, and `criteria_types` all live inside
   `options` (see the 1g sample), which
   `sframe_restore_analysis_block()` already round-trips generically —
   no restore work needed, only `sframe_decision_options()` validation
   (1e). Do not add top-level block fields.
10. testthat file per method group; `render_results()`
    (`R/analysis_plan.R:1348`) renders each result without error.

---

## 0. Pre-work (lead, before any agent is spawned)

1. [x] **Clone the source repo — it is not local as of 2026-07-25:**
   `gh repo clone MohammedAliSharafuddin/mcdm ../mcdm` — done, cloned to
   `/home/maxx/Documents/GitHub/mcdm`.
2. [x] Harvest audit — see "Harvest audit" section above.
3. [ ] Decide the two design questions in section 1 and 2 with the
   owner before implementation starts — **not done**. Phase 1 below
   proceeded directly against this file's already-detailed spec, on
   owner instruction to start building rather than pause for review.
   Flagged as a standing gap: if the owner wants to revisit the data
   contract's design (matrix encoding, aggregation defaults, column
   conventions), everything built in Phase 1 that depends on it may
   need rework.

**Phase 1 status (2026-07-25, committed to `v0.5-dev` at 77070b6, which
itself sits on top of the committed 0.4 work — 0.4 and 0.5 are now one
branch/release per owner decision, invoking the 2026-10-15 gate's merge
consequence early):**

- [x] Item types (#2): `pairwise_comparison` and `criteria_weight` added
  to `sf_item()`, `read_write_sframe.R`, `validate_sframe.R`, and the
  `read_responses.R` expansion whitelist (the three column patterns
  from 1c). Size-limit advisories (warn > 7 saaty / > 6 influence,
  error > 10) implemented via a new `sframe_warn_design()` in
  `R/conditions.R`. Round-trip and export-column tests pass
  (`tests/testthat/test-decision-item-types.R`).
  **Not done: all three rendering surfaces** (static template, Shiny
  renderer, builder inspector) — the R-level plumbing only. An
  instrument with either new item type will validate, round-trip, and
  export correctly, but will not yet render a usable question on any
  survey surface.
- [x] `R/decision_data.R` (#1d/#1e): `sframe_assemble_pairwise()`,
  `sframe_aggregate_judgements()`, `sframe_collected_weights()`,
  `sframe_rated_matrix()`, `sframe_decision_options()`, AHP consistency
  screening. Full test file, 93 assertions, 0 failures
  (`tests/testthat/test-decision-data.R`).
- [x] TOPSIS end to end (#3/#4, the reference diff): `R/decision_methods.R`
  with `sframe_run_topsis()`, wired into `sframe_run_one_block()`,
  `sframe_analysis_roles()`, `.sframe_citations` (Hwang & Yoon 1981,
  verified), `sframe_result_table()`, and a new generic
  `sframe_plot_decision_ranking()` in `R/plots.R` meant for reuse by
  the other 6 ranking methods. 62 assertions, 0 failures
  (`tests/testthat/test-decision-topsis.R`).
  **Not done: the two JS UI registries.** Exact spots for the next
  pass: `inst/builder/survey_builder.html:969` (method dropdown
  `<optgroup>`), `:2690` (`ANALYSIS_REGISTRY`); `inst/shiny/app.R:324`
  (studio registry), `:733` (requirements string) — copy the
  `mann_whitney` entry shape at each.
- [ ] **Not started: the remaining 9 computations** (AHP, ANP, DEMATEL,
  ELECTRE, MOORA, PROMETHEE, SMART, VIKOR, WASPAS) — sections 3/4 for
  each, per the Phase 2 agent assignments below. AHP and DEMATEL are
  the two named in the section 1g sample sframe and should come next.
- [ ] Not started: `sensitivity_analysis()` (#5), `sf_conjoint_design()`
  (#6), the vignette (#7), the section 1g sample sframe as an actual
  built/tested fixture, the full exit checklist (#8).

`devtools::document()` clean (after a second pass — first pass showed
`@seealso` resolution warnings between the new decision_data.R
functions, a normal same-batch roxygen2 ordering artifact, not a real
problem). Full `devtools::test()` on the merged branch: 0 failures, 1
expected skip (logistf), only pre-existing ggplot2 deprecation warnings
unrelated to this work.

## 1. The MCDM data contract: input structure, storage, assembly

This is the hard half of the release. The computation layer (#3) is
textbook maths; getting judgement data from a phone screen into a
square reciprocal matrix is where MCDM implementations fail. Settle
this section with the owner before any runner is written.

### 1a. Two matrix kinds — never conflated

- **Judgement matrices** (criteria x criteria): AHP/ANP pairwise ratios
  and the DEMATEL direct-relation matrix. These are respondent
  opinions, one matrix per respondent, and are the survey-collectable
  kind. AHP matrices are reciprocal (m[b,a] = 1/m[a,b], diagonal 1);
  DEMATEL matrices are **not** reciprocal (influence of a on b is
  independent of b on a) and have a 0 diagonal.
- **Performance matrices** (alternatives x criteria): the decision
  matrix TOPSIS, VIKOR, MOORA, PROMETHEE, ELECTRE, SMART, and WASPAS
  rank from. These are measurements or expert scores of real
  alternatives (price, capacity, rating), not typically collected from
  survey respondents. They are researcher-supplied in the plan block.
- **The realistic pipeline combines both:** weights are collected
  (pairwise AHP or a `criteria_weight` item, aggregated across
  respondents), the performance matrix is supplied, and a ranking
  method consumes supplied matrix + collected weights. Every ranking
  runner therefore resolves its two inputs independently:
  matrix from `options$matrix`, weights from `options$weights` OR from
  a `weights_item` role pointing at a collected item. Record the
  provenance of each in the result (`weights_source`,
  `matrix_source`) so the report can say where numbers came from.

### 1b. Respondent input structure (per item type, per surface)

**`pairwise_comparison` (AHP/ANP variant).** Never render an n x n
grid — it is unusable below tablet width and invites inconsistency.
Render the n(n-1)/2 unordered pairs as one comparison row each: left
label, a bipolar 17-point Saaty strip (9 8 7 6 5 4 3 2 | 1 | 2 3 4 5 6
7 8 9), right label. Desktop: a radio strip (the matrix-table radio
styling at `inst/static_survey/template.html` ~lines 159-170 is the
precedent). Mobile (< 600px): reuse the matrix reflow pattern
(template.html ~lines 213-229, one stacked card per pair) with a
`<select>` listing the 17 verbal anchors ("A extremely more important"
... "Equal" ... "B extremely more important"). 4 criteria = 6 rows,
7 criteria = 21 rows; `validate_sframe()` warns above 7
`comparison_items` (respondent burden and the RI table both degrade)
and errors above 10.

**`pairwise_comparison` (DEMATEL variant, `comparison_scale =
"influence"`).** Ordered pairs, so n(n-1) rows ("How strongly does A
influence B?", then B on A separately), each a 5-point unipolar strip
(0 none - 4 very high). Same reflow. Warn above 6 comparison items
(30 rows).

**`criteria_weight`.** Constant-sum allocation: one numeric input per
criterion, a live running total, and page advance blocked until the
total is exactly 100 (extend `validatePage()` in the static template —
the date-bounds check added 2026-07-17 is the precedent for
per-type validation there). The builder inspector gets the same
criteria-list editor the matrix type already has for rows.

All three surfaces must agree: static template, Shiny renderer
(`R/render_survey.R` + `R/survey_module.R`), and the builder preview.
After editing the static template, re-run `inline_static_template.R`
(0.3.4 established this step). The WCAG bar from 0.3.4 applies: the
strips are radio groups with accessible names per pair, 44px targets,
keyboard operable.

### 1c. Column encoding (export contract)

Follows the `item__sub` expansion convention already accepted by
`read_responses()` (`R/read_responses.R:97-105` builds the expansion
whitelist per item type — extend that switch for the two new types):

- AHP pairwise: one column per unordered pair, `item__a__vs__b`
  (ids joined with the existing double-underscore convention), value a
  **signed integer** in {-9..-2, 1, 2..9}: positive means the first
  (alphabetically first declared) side is preferred by that Saaty
  degree, negative means the second side, 1 means equal. Signed
  integers keep the CSV and Google Sheet free of fractions (never
  store 1/7 as 0.142857...); reciprocals are reconstructed at
  assembly, not stored.
- DEMATEL: one column per ordered pair, `item__a__to__b`, integer 0-4.
- `criteria_weight`: one column per criterion, `item__crit`, integer
  0-100, row-sum 100.
- The static template's submit serialiser and the Google Sheets Apps
  Script generator (`R/google_sheets.R`) must both emit these columns —
  the multi-select one-column-per-option export from 0.3.3 is the
  precedent to copy. Round-trip test: static survey fixture -> collector
  CSV -> `read_responses()` -> assembled matrix.

### 1d. Assembly and aggregation — new file R/decision_data.R

The data layer between response frames and the computation layer, unit
tested on its own:

- `sframe_assemble_pairwise(data, instrument, item_id)`: per
  respondent, build the n x n matrix from the pair columns (fill
  reciprocals for AHP: +5 in `a__vs__b` gives m[a,b] = 5,
  m[b,a] = 1/5; DEMATEL fills directed cells, diagonal 0). Validation
  per respondent: all pairs answered, values in range. Respondents
  with any missing pair are dropped and counted (Harker-style
  completion of partial matrices is out of scope — a documented
  decision, revisit only if field data demands it).
- `sframe_aggregate_judgements(matrices, method = c("geometric",
  "arithmetic"))`: element-wise geometric mean for AHP (the standard
  AIJ aggregation — it is the one that preserves reciprocity;
  arithmetic means do not), arithmetic mean for DEMATEL. Result
  carries `n_respondents`, `n_dropped`.
- AHP consistency screening across respondents:
  `options$cr_filter = TRUE` drops individual matrices with CR >= 0.10
  before aggregation; default FALSE, but the per-respondent CR
  distribution (min/median/max, share above 0.10) is always computed
  and reported — reviewers ask for it.
- `sframe_collected_weights(data, instrument, item_id)`: for
  `criteria_weight` items, per-respondent renormalisation to sum 1,
  then the arithmetic mean vector; for pairwise items, the aggregated
  matrix's principal-eigenvector weights. Both return the same shape
  so runners are source-agnostic.
- Runner resolution order, uniform across all 10:
  `options$matrix`/`options$weights` first (researcher-supplied),
  collected item roles second, typed error naming what is missing
  third.

### 1e. Serialisation of matrix-valued options

`options` already round-trips through
`sframe_restore_analysis_block()` (`R/read_write_sframe.R:254`) as a
generic list, but jsonlite turns a numeric matrix into a list of rows
and drops dimnames. Contract: `options$matrix` is stored as a list of
numeric row vectors plus `options$alternatives` and
`options$criteria` character vectors; a new
`sframe_decision_options()` normaliser (called by the runners and by
`validate_sframe()` for decision blocks) rebuilds the matrix, checks
`length(alternatives) == nrow`, `length(criteria) == ncol ==
length(weights) == length(criteria_types)`, and errors with the exact
mismatch. Round-trip test: block with a 5x4 matrix survives
write_sframe/read_sframe with values, dims, and labels intact and the
instrument hash stable.

### 1f. CRAN prior art (read 2026-07-25, reference manuals verified)

What the existing packages expect as input, and what surveyframe must
therefore be able to produce from a survey:

| Package | Entry point and input structure | Lesson for surveyframe |
|---|---|---|
| topsis 1.0 | `topsis(decision, weights, impacts)`: numeric matrix m alternatives x n criteria, numeric weight vector, character vector of `"+"`/`"-"`. Returns data frame `alt.row`, `score`, `rank` | The minimal runner contract. Our `criteria_types = c("benefit","cost")` maps 1:1 to `impacts`; our `$table` (Alternative, Score, Rank) matches its return shape |
| dematel 0.1.0 | `execute_dematel(x)` and stepwise functions (`normalize_data`, `total_relationship_matrix`, `threshold_value`, `compare_criteria`): one plain numeric square matrix, already aggregated across experts (its bundled `hospitaldata`/`nurseselection` are 10x10 frames with named criteria K1..K5...). Returns a list of matrices, the threshold, and the over-threshold relation pairs | Expert aggregation happens **before** the package is called and is undocumented there — exactly the gap `sframe_assemble_pairwise()` + `sframe_aggregate_judgements()` (1d) close. Criteria names travel as dimnames, so ours must too |
| ahptopsis2n 0.2.0 | `ahptopsis2n(decision, criteria, minmax)`: the decision matrix, a **full n x n AHP pairwise matrix with literal reciprocals** (`1/3`, `1/5` in the example), and `c("max","min")` per criterion. Returns CR plus ranked frames | Confirms the hybrid pipeline in 1a (pairwise -> weights -> ranking) as an established published pattern, and confirms reciprocal fractions appear the moment users hand-build matrices — our signed-integer column encoding (1c) exists precisely so collected data never carries fractions |
| IFMCDM 0.1.17 | `IFconversion(primary)` takes **raw per-respondent ordinal survey data** (first column = object name, repeated rows per respondent, one Likert column per criterion; example: 26 objects x 13 respondents x 8 criteria) and aggregates to an intuitionistic fuzzy decision matrix (m x n*3: mu, nu, pi per criterion); `IFSM()`/`IFTOPSIS()` then rank with crisp `w` and `z = "b"/"c"` | The closest published analogue to our whole problem: the decision matrix is **built from survey responses by aggregation**. This validates collection path C below and shows a third weight/type encoding (`"b"/"c"`) — ours stays `benefit`/`cost`, translated per engine |

Direct consequence missed by the earlier draft: alongside the two
collection paths in 1a there is a **path C, the rated performance
matrix** (the IFMCDM pattern) — respondents rate each alternative on
each criterion with ordinary Likert/rating items, and the decision
matrix is the per-cell aggregate (mean, or IF conversion later). This
needs no new item type: one existing `matrix` item per criterion
(rows = alternatives) already collects it. Add to `R/decision_data.R`:
`sframe_rated_matrix(data, instrument, items, statistic = "mean")`
building the m x n matrix from the `item__alternative` expansion
columns of n matrix items, with per-cell n and SD kept for the report.

### 1g. Sample sframe (the design target — this must build, validate, round-trip, and run)

The worked example for the whole release: hotel supplier selection, 5
vendors, 4 criteria (service quality and location = benefit, price =
cost, delivery time = cost). It exercises every data path: pairwise
weights (A), constant-sum weights, rated performance matrix (C),
researcher-supplied matrix, and DEMATEL. Uses only the real 0.3.x API
plus the additions this file specifies.

```r
crits   <- c("service", "location", "price", "delivery")
vendors <- c("Alpha", "Basilica", "Coral", "Dhoni", "Equator")

components <- list(
  # Path A: criteria pairwise comparison (6 pair rows rendered, 1b)
  sf_item("crit_pairs", "Compare the importance of each pair of criteria",
          type = "pairwise_comparison",
          comparison_items = crits,
          comparison_scale = "saaty",
          required = TRUE),

  # Constant-sum weights (alternative weight source, 1b)
  sf_item("crit_points", "Divide 100 points across the criteria",
          type = "criteria_weight",
          comparison_items = crits,
          required = TRUE),

  # Path C: rated performance matrix - one matrix item per criterion,
  # rows = vendors (IFMCDM pattern, no new item type needed)
  sf_choices("q5", values = 1:5,
             labels = c("Very poor", "Poor", "Fair", "Good", "Excellent")),
  sf_item("rate_service",  "Rate each supplier: service quality",
          type = "matrix", matrix_items = vendors, choice_set = "q5"),
  sf_item("rate_location", "Rate each supplier: location",
          type = "matrix", matrix_items = vendors, choice_set = "q5"),
  sf_item("rate_price",    "Rate each supplier: value for money",
          type = "matrix", matrix_items = vendors, choice_set = "q5"),
  sf_item("rate_delivery", "Rate each supplier: delivery speed",
          type = "matrix", matrix_items = vendors, choice_set = "q5"),

  # DEMATEL: directed influence among criteria (12 ordered pairs, 1b)
  sf_item("crit_influence", "How strongly does each factor influence the others?",
          type = "pairwise_comparison",
          comparison_items = crits,
          comparison_scale = "influence")
)

study <- sf_instrument(
  title      = "Hotel supplier selection",
  version    = "1.0.0",
  components = components,
  analysis_plan = list(
    list(id = "RQ1",
         research_question = "What weight does each criterion carry?",
         family  = "decision", method = "ahp",
         roles   = list(pairwise = "crit_pairs"),
         options = list(cr_filter = FALSE)),
    list(id = "RQ2",
         research_question = "Which supplier ranks best on the audited figures?",
         family  = "decision", method = "topsis",
         roles   = list(weights_item = "crit_pairs"),
         options = list(
           # researcher-supplied performance matrix (audited data),
           # stored per 1e: list of rows + label vectors
           matrix = list(c(4.1, 3.0, 210, 36),
                         c(3.6, 4.5, 180, 48),
                         c(4.8, 2.5, 260, 24),
                         c(3.9, 4.0, 150, 72),
                         c(4.4, 3.8, 230, 30)),
           alternatives   = vendors,
           criteria       = crits,
           criteria_types = c("benefit", "benefit", "cost", "cost"))),
    list(id = "RQ3",
         research_question = "Which supplier do staff rate best overall?",
         family  = "decision", method = "topsis",
         roles   = list(performance_items = c("rate_service", "rate_location",
                                              "rate_price", "rate_delivery"),
                        weights_item = "crit_points"),
         options = list(criteria_types = c("benefit", "benefit",
                                           "benefit", "benefit"))),
    list(id = "RQ4",
         research_question = "Which criteria drive the others?",
         family  = "decision", method = "dematel",
         roles   = list(pairwise = "crit_influence"))
  )
)
```

What this sample pins down, and what each runner receives:

- **Role vocabulary for the decision family** (this is the spec):
  `pairwise` (a pairwise_comparison item id), `weights_item` (a
  pairwise_comparison OR criteria_weight item — both resolve through
  `sframe_collected_weights()`, 1d), `performance_items` (ordered
  vector of matrix items, one per criterion, path C). Register these
  in `sframe_analysis_roles()` and the two UI registries with exactly
  these names.
- **RQ1 (ahp)** receives the aggregated reciprocal 4x4 from
  `sframe_assemble_pairwise()` + AIJ; returns weights, CR, the
  consistency warning path, weights bar chart.
- **RQ2 (topsis, hybrid)** receives the supplied 5x4 matrix rebuilt by
  `sframe_decision_options()` and weights from the collected
  `crit_pairs` — the ahptopsis2n pipeline, split across declared
  sources with provenance recorded. Note `criteria_types` mixes
  benefit and cost here because the audited figures are raw magnitudes.
- **RQ3 (topsis, fully collected)** builds the 5x4 from
  `sframe_rated_matrix()` over the 4 matrix items' `item__vendor`
  columns; all 4 criteria are `benefit` because the price question was
  asked as value-for-money (higher = better) — the vignette must spell
  out this reframing trap (a raw "price" rating collected as
  higher = more expensive would be a `cost`).
- **RQ4 (dematel)** receives the arithmetic-mean 4x4 directed matrix
  (0 diagonal, no reciprocity) and returns the cause-effect table plus
  influence map.
- **Respondent export columns** this instrument produces (the 1c
  contract made concrete): 6 `crit_pairs__a__vs__b` signed columns, 4
  `crit_points__crit` 0-100 columns, 20 `rate_*__vendor` columns, 12
  `crit_influence__a__to__b` columns.
- **Interplay with the existing engine**: no scales are declared, so
  `run_analysis_plan(scored = TRUE)` must pass through unchanged;
  `quality_report()`'s straightlining and speeding checks must not
  treat the pairwise columns as a Likert battery (check and, if
  needed, exempt the new types there); `missing_data_report()` sees
  the expansion columns like any matrix item's.
- The sample (with seeded simulated responses for ~12 respondents)
  becomes `tests/testthat/` fixtures and the spine of the vignette
  (#7). Exit criterion: every block above returns a table and a chart
  with no error field, and the whole instrument round-trips with a
  stable hash.

## 2. New item types: pairwise_comparison and criteria_weight

There is no `R/item_types.R`. The enum lives inline in the `sf_item()`
signature at `R/sf_item.R:53-56`, validated by `rlang::arg_match()` at
line 74. Touch points:

- `R/sf_item.R`: add `"pairwise_comparison"`, `"criteria_weight"` to the
  `type` default vector; new params `comparison_items` (character vector
  of things being compared, reusing the `matrix_items` pattern at line
  63) and `comparison_scale = c("saaty", "influence")` selecting the
  AHP bipolar 1-9 or DEMATEL unipolar 0-4 input from section 1b.
  Validate like `sframe_check_date_bound()` does for dates, including
  the 1b size limits (warn > 7 saaty / > 6 influence items, error > 10).
- `R/read_write_sframe.R`: restore the new fields in
  `sframe_restore_item()` (line 168), same `sframe_as_vector()` idiom as
  `matrix_items`.
- `R/validate_sframe.R`: `pairwise_comparison` requires `comparison_items`
  length >= 2 and `choice_set` NULL. Use `sframe_abort_validation()`
  (`R/conditions.R:45`).
- `R/read_responses.R`: extend the expansion-whitelist switch (lines
  97-105) with the three column patterns from section 1c
  (`item__a__vs__b`, `item__a__to__b`, `item__crit`).
- Round-trip test: sf_item with both types survives
  write_sframe()/read_sframe() with fields intact (hash equality).
- Rendering surfaces: implement the section 1b input structures in all
  three places — the static template (+ `validatePage()` checks: all
  pairs answered when the item is required, constant-sum total = 100;
  then re-run `inline_static_template.R`), the Shiny renderer
  (`R/render_survey.R` + `R/survey_module.R`), and the builder
  (inspector editor for `comparison_items`/`comparison_scale`, Theme B
  preview parity). An instrument carrying either type must never
  render a broken or blank question on any surface.

## 3. Computation layer: R/decision_methods.R

One new file, header comment `# R/decision_methods.R` per house style.
Pure base-R computation helpers, one per method, taking
`(matrix, weights, criteria_types)` and returning the method's raw
outputs. These are internal (not exported), unit-tested directly against
known-value fixtures.

- Shared validator `sframe_check_decision_input()`: numeric matrix, no
  NA, weights sum to 1 within 1e-6 (renormalise with a note, do not
  error), `length(weights) == ncol(matrix)`, `criteria_types` all in
  c("benefit", "cost"). Tested once, called by every runner.
- `.ahp_cr()` as in the 06 guide (principal eigenvector, CR = CI/RI,
  Saaty RI vector). RI covers n <= 10 only: return `error` beyond that.
  CR >= 0.10 sets a `consistency_warning` field. Advise, never abort.
- `.dematel_classify()` as in the guide: total-relation matrix
  T = N(I-N)^-1 from the normalised direct matrix, D+R prominence,
  D-R relation, arithmetic-mean threshold, cause/effect role column.
- TOPSIS: vector normalisation, weighted ideal/anti-ideal separation,
  closeness coefficient. VIKOR: S, R, Q with v = 0.5 default and the
  two acceptance conditions evaluated. MOORA: ratio system plus
  reference-point. PROMETHEE II: usual preference function (type 1) by
  default, net flow. ELECTRE I: concordance/discordance matrices with
  standard thresholds in options. SMART: normalised weighted value.
  WASPAS: lambda = 0.5 WSM/WPM blend. ANP: supermatrix limit by power
  iteration with a convergence guard (max 1000 iterations, else error).
- Every numeric fixture in tests carries expected values computed
  by hand or reproduced from the mcdm app, stored as literals with a
  comment naming the source.

## 4. Runners and wiring

Method ids: `topsis`, `vikor`, `ahp`, `dematel`, `moora`, `promethee`,
`electre`, `smart`, `waspas`, `anp`. Family string: `"decision"`
(metadata only). Each runner:

- resolves its inputs through the section 1d order (researcher-supplied
  options first, collected roles via `sframe_assemble_pairwise()` /
  `sframe_collected_weights()` second, typed error third; provenance
  fields recorded), builds `$table` (ranking frame: Alternative, Score,
  Rank — or the DEMATEL cause-effect frame), `apa` (one sentence with
  the top alternative and the key statistic), `prompt` (interpretation
  guidance), and the method-specific raw fields (weights, CR, flows,
  Q values, and the rest).
- AHP additionally returns `cr` and `consistency_warning`; the report
  path renders the warning prominently (check how `error` renders in
  `.render_report_analysis_section()`, `R/reporting.R:752`, and give
  the warning similar visibility).
- Plots: one shared `sframe_plot_decision_ranking()` (horizontal bar of
  scores) for the 7 ranking methods, `sframe_plot_dematel_influence()`
  (prominence vs relation scatter with quadrant lines) for DEMATEL, and
  the ranking bar reused for AHP global weights. Register all in
  `sframe_plot_for_result()`.

## 5. sensitivity_analysis()

New exported function in `R/decision_sensitivity.R` per the 06 guide's
grid logic (perturb each weight by delta = 0.05, renormalise, rerun,
Spearman correlation between base and perturbed rankings). Changes to
the guide: return a classed object `sframe_sensitivity` with `$table`
(criterion, direction, rho, rank_changed) and a `plot()` S3 method
(follow the `plot.sframe_validity_report()` pattern, `R/plots.R:1059`),
plus a print method. Use `rlang`'s `%||%` (already imported). It is also
callable from a plan block via `options$sensitivity = TRUE` on any
ranking method, attaching `$sensitivity` to that result.

## 6. sf_conjoint_design()

Carried in from the mas_review_033.md sf_choices assessment (good fit,
scheduled v0.5). Re-read that assessment first. Scope: a declared
choice-experiment design generator (attributes, levels, fractional
factorial or random subset, declared block count) stored on the
instrument, not an estimator. Analysis of conjoint responses is out of
scope for 0.5 (no runner). If the 45-day window tightens, this is the
first deferral, recorded in `../portfolio-planner/decisions.md`.

## 7. Vignette: vignettes/mcdm-analysis.Rmd

Worked example: 5 hotel vendors, 4 criteria. Researcher-supplied matrix
path plus one collected-weights AHP block assembled from simulated
pairwise columns (so the vignette exercises both halves of the section
1 pipeline). TOPSIS and AHP blocks, sensitivity on
the TOPSIS weights, DEMATEL cause-effect table and influence map in the
rendered report. House rules from 0.3.4: shared WCAG style block,
`lang: en-GB`, `fig.alt` on every chart, offline knit, `set.seed()`.
Check `_pkgdown.yml` for an explicit vignette listing and add it.
axe-core pass through chromote at zero violations (same harness as the
0.3.4 vignette pass).

## 8. Exit checklist

- 10 runners + wiring per the integration checklist, every box, every
  method. The two JS registries updated in lockstep and verified by
  loading the builder and studio and creating one block per method.
- **The section 1g sample sframe is the release gate:** it builds with
  the shipped constructors, validates, round-trips with a stable hash,
  renders on all three survey surfaces, its simulated responses export
  the exact 42 expansion columns listed there, and all 4 plan blocks
  (ahp, hybrid topsis, fully-collected topsis via
  `sframe_rated_matrix()`, dematel) return a table and chart with no
  error field. It ships as the test fixture and the vignette spine.
- Known-value unit tests for all 10 computations; AHP CR both branches;
  DEMATEL threshold and role assignment; input-validator edge cases.
- Data contract (section 1) verified end to end: pairwise and
  constant-sum inputs render on all three surfaces (desktop strip,
  mobile reflow, WCAG-checked), export the section 1c columns from the
  static template and the Sheets collector, read back through
  `read_responses()`, assemble into correct matrices (reciprocal fill
  for AHP, directed cells for DEMATEL), and aggregate (geometric AIJ /
  arithmetic) with drop counts and the per-respondent CR distribution
  reported. Constant-sum totals enforced at entry; incomplete pairwise
  respondents dropped and counted.
- Round-trip: an instrument with both new item types, a decision block
  carrying a 5x4 `options$matrix` with labels, weights, and
  criteria_types, write/read, hash intact, dims and block fields intact
  (`sframe_decision_options()` tests).
- `sensitivity_analysis()` exported, documented, plotted, tested.
- `sf_conjoint_design()` shipped or formally deferred.
- Vignette knits clean offline, axe-core zero violations.
- No new hard Imports. No new Suggests either (all computation base R).
- `devtools::document()` clean; full suite green locally;
  `R CMD check --as-cran` 0/0/<=1 NOTE; win-builder release and devel
  clean; `cran-comments.md` updated; NEWS.md entry written as a clean
  changelog.
- Owner reminders (not engineering): MCDM methodology paper kickoff;
  ASRDA Part XII ch 34-35 revision once the API is final; Ethos
  surfaces MCDM in the following cycle.

---

## Delegation, model tiering, and token budget

Binding policy, same as `todo_0.4.md`. The computation layer is the most
parallelisable work in the roadmap; the wiring is not (single switch,
single plot dispatcher, two JS registries — merge conflicts live there).

### Build order and agent assignment

Phase 1 (lead, Fable/Opus): clone + harvest audit, owner sign-off on
the section 1 data contract (input structures, column encoding,
aggregation defaults), then implement TOPSIS end to end (computation,
runner, wiring, builder/studio entries, tests) as the reference diff
every agent copies, and `R/decision_data.R` (assembly, aggregation,
collected weights) with its full test file — the data layer is the
correctness core of the release and is never delegated.

Phase 2 (parallel, after the reference diff lands):
- **Agent 1 (Sonnet):** AHP + ANP computations and runners (shared
  eigen/supermatrix machinery) + tests.
- **Agent 2 (Sonnet):** DEMATEL computation, runner, influence-map plot
  helper + tests.
- **Agent 3 (Sonnet):** VIKOR, MOORA, SMART, WASPAS + tests (4 similar
  ranking methods, one brief).
- **Agent 4 (Sonnet):** PROMETHEE + ELECTRE + tests (highest-rework per
  the audit; brief includes their audit rows).
- **Agents write computation + runner + tests only.** They do not touch
  `sframe_run_one_block()`, `sframe_plot_for_result()`, or the two JS
  registries — the lead applies all shared-file wiring in one pass after
  the agent diffs land, precisely to avoid 4-way conflicts on the same
  switch statements.
- **Agent 5 (Sonnet):** item types (#2) including the three rendering
  surfaces and their `validatePage()` checks — independent of the
  runners, briefed with section 1b/1c verbatim.
- **Agent 6 (Haiku):** after integration, verification sweeps: run each
  new test file, `devtools::document()`, knit check, NAMESPACE diff.

Phase 3 (lead + one Sonnet agent): sensitivity (#5), conjoint (#6),
vignette (#7), exit checklist. Vignette drafting is delegable; the exit
checklist is not.

### Model tiering

- **Haiku:** test execution, document runs, knit checks, mechanical
  verification, audit-table transcription.
- **Sonnet:** all pattern-following computations/runners/tests, the
  vignette draft, the item-type edits (fully specified above).
- **Opus/Fable:** harvest audit judgement, design decisions, the
  reference implementation, all shared-file wiring, review of every
  delegated diff before merge.

### Token-saving rules (binding)

- Grep for the target function, read only its range. Never read
  `analysis_plan.R` (1500+ lines) or `survey_builder.html` (3000+
  lines) end to end.
- The mcdm repo is read once (audit). The audit table is the sole
  downstream source.
- Agent reports: what changed, file:line, test summary line, surprises.
  Under 15 lines unless something failed.
- No re-reads of unchanged files; batch independent tool calls; Explore
  agents for any search wider than 5 files.
- One `testthat::test_file()` per change; `devtools::test()` full suite
  only at integration and before the tarball build.

---
---

## Appendix: small-sample inference track (formerly `todo_0.4.md`)

This section is the original small-sample engineering spec, folded in
here 2026-08-15. All items in it are implemented and shipped; it is kept
verbatim below as the detailed record of what was built and why, since
that detail (exact runner signatures, line numbers, test fixtures) is
worth preserving rather than summarising away.


> **ALREADY BUILT, SHIPS INSIDE CRAN 0.4.0 (status 2026-07-30).** Every
> engineering item in this file is implemented, tested, and committed on
> `v0.5-dev`. Confusing history worth stating once: this file was written
> for a standalone 0.4 release that merged into 0.5 on 2026-07-25, and the
> merged release is now numbered **0.4.0** on CRAN, so the version number
> came back round while the branch kept the 0.5 label. Canonical task
> list: `todo_master_0.4.md`.

Dev-only planning file. Not tracked on `main`; add its name to `.gitignore`
there alongside `revision_todo_0.3.md` and the other dev-only files before
this is ever merged to `main`. Companion to `CLAUDE.md` and to
`../portfolio-planner/development_instructions/05_v04_implementation.md`
(the original implementation guide) and `19_v034_v035_implementation.md`
(the CI-helper scope reconciliation).

**Decision gate 2026-10-15 (recorded 2026-07-25 in
`../portfolio-planner/decisions.md`):** whether this ships as 0.4 on
2026-11-20 depends on the small-sample preprint DOI being live by
2026-10-15. DOI live: ship as planned. DOI not live: this release
merges into 0.5 (2027-01-25) as its small-sample track, this file folds
into `todo_0.5.md`, and 0.4.1 renumbers to 0.5.1 — see the decisions.md
entry for the full consequence list. Until the gate fires, work from
this file as written; the engineering content is identical either way.

Last updated: 2026-07-25. Target CRAN submission: 2026-11-20
(`../portfolio-planner/master_roadmap.md`). Current package version: 0.3.4
(0.3.5 is a field-validation patch with no planned code changes, per the
2026-07-17 decision — see CLAUDE.md and
`../portfolio-planner/decisions.md`, entry "0.3.5 statistics scope merged
into 0.3.4").

---

## What's already done (do not re-implement)

The 05_v04_implementation.md guide was written before the 2026-07-14
consolidation moved the CI infrastructure and stats/reporting work earlier,
into 0.3.4. All of the following shipped already and v0.4 simply reuses them:

- `bootstrap_ci()`, `cohens_d_ci()`, `cramers_v_ci()`, `eta_sq_ci()` —
  `R/bootstrap_ci.R`, all exported, all seed-safe (the 2026-07-18 RNG-leak
  fix restores `.Random.seed` on exit).
- `$table` on inferential runners, effect-size CIs threaded through the
  runner `apa` strings.
- Henseler HTMT, Little's MCAR via naniar, omega/EFA polish.
- `render_report(format = "pdf")` via pagedown, `--sf-*` CSS theming,
  chart alt text.
- The full `plots = TRUE` visualisation layer and both WCAG 2.2 AA passes.

**Confirmed against current source (2026-07-24) — none of the following
exist yet, so this is the real v0.4 scope:**

**Status update 2026-07-25: items 1-3, 5, 6, 7, and the smallsamplelab
half of 8 are implemented and verified on branch `v0.4-dev`
(worktree `../surveyframe-v0.4-dev`, based on main post-0.3.4), not yet
committed. Full `devtools::test()` green (0 failures, 1 expected skip
for `logistf` being installed locally), `devtools::document()` clean,
`R CMD check --as-cran` 0 errors / 0 real warnings (the 3 WARNINGs
shown in that run are checkpoint-run artifacts: unbumped version and a
`--no-build-vignettes` build flag, not real problems — R CMD check's
own vignette-rebuild step confirms all 8 vignettes including the new
one build clean). See the merge note below: this branch is now folding
into `v0.5-dev` per the 2026-10-15 decision gate, invoked early by
owner decision on 2026-07-25.**

| Item | Where it will live | Status |
|---|---|---|
| Hodges-Lehmann estimate on Mann-Whitney | `R/analysis_plan.R`, `sframe_run_mann_whitney()` (line ~270) | **done** — `hl_shift`, `hl_conf_int` added, tested |
| Pseudomedian CI on paired Wilcoxon | `R/analysis_plan.R`, `sframe_run_wilcoxon_pair()` (line ~486) | **done** — `pseudomedian`, `pseudomedian_conf_int` added, tested |
| Exact odds-ratio CI on Fisher | `R/statistics_reports.R`, `sframe_run_fisher()` (line ~779) | **done** — `odds_ratio_conf_int`, guarded against `simulate_p_value`, tested |
| Firth-penalised logistic regression | `R/statistics_reports.R`, `sframe_run_firth_logistic()` | **done** — full registration (switch, roles, citations `.sframe_citations`, table, plot, builder + studio registries), `logistf` in Suggests, `sframe_require_logistf()` added, tested incl. missing-package skip path |
| Small-sample advisory | `assumption_report()` and `sample_size_plan()`, both in `R/statistics_reports.R` (lines ~495, ~1453) | **done** — `sframe_small_sample_advisory()`, wired into both return objects and their S3 print methods, tested at n=15/n=50 |
| RStudio add-in | new `inst/rstudio/addins.dcf`, new `R/rstudio_addins.R` | not started — stays off `v0.4-dev`/`v0.5-dev` regardless, per standing instruction; build separately per `todo_rstudio_addin.md` |
| `vignettes/small-sample.Rmd` | new | **done** — renders clean to HTML, WCAG house style, all 8 sections plus citation block |
| CITATION: smallsamplelab + preprint DOIs | `inst/CITATION` | **partial** — smallsamplelab Zenodo DOI bibentry added and verified parseable; preprint DOI still blocked, see hard-blockers list |
| Ethos R bridge repoint (asrda-r → surveyframe) | Ethos repo, not this one | not confirmed — separate repo, not checked this session |

---

## Signature note — use the real runner form, not the guide's sketch

`05_v04_implementation.md` sketches `.run_mann_whitney(x, y, ...)` style
helpers. **Do not use that signature.** The actual runners in this codebase
take `sframe_run_*(data, vars)` or `sframe_run_*(data, roles, options)` and
return a flat named list consumed by `run_analysis_plan()` — see
`sframe_run_mann_whitney()`, `sframe_run_wilcoxon_pair()`, and
`sframe_run_fisher()` for the exact pattern (variable extraction from
`data`/`vars`, `tryCatch()` around the underlying `stats::` call, an
`error` field on failure, an `apa` string, and usually a `prompt` string for
AI-assisted interpretation). Every new/extended runner below must follow
that existing pattern, not the guide's `.run_*(x, y)` sketch.

---

## 1. Hodges-Lehmann estimate — Mann-Whitney runner

**File:** `R/analysis_plan.R`, inside `sframe_run_mann_whitney()`.

Current call is `stats::wilcox.test(g1, g2, exact = FALSE)`. Add
`conf.int = TRUE` (keep `exact = FALSE`, consistent with the existing
rank-biserial CI already computed via `sframe_rank_r_ci()`):

```r
wt <- tryCatch(
  stats::wilcox.test(g1, g2, exact = FALSE, conf.int = TRUE),
  error = function(e) NULL
)
```

Add to the returned list: `hl_shift = unname(wt$estimate)`,
`hl_conf_int = as.numeric(wt$conf.int)`. Extend the `apa` string with the
HL shift and its interval, matching the existing `sframe_ci_string()`
helper used elsewhere in this function for `r_ci`.

**Test:** add to whichever test file covers `sframe_run_mann_whitney()`
(`grep -rl sframe_run_mann_whitney tests/testthat/` to confirm the file).
Assert `hl_shift` is numeric and `hl_conf_int` has length 2, on a small
fixture (n = 5 per group is fine — this is exactly the small-sample case).

---

## 2. Pseudomedian CI — paired Wilcoxon runner

**File:** `R/analysis_plan.R`, inside `sframe_run_wilcoxon_pair()`.

Same pattern: add `conf.int = TRUE` to the existing
`stats::wilcox.test(x, y, paired = TRUE, exact = FALSE)` call. Add
`pseudomedian = unname(wt$estimate)` and
`pseudomedian_conf_int = as.numeric(wt$conf.int)` to the return list, and
extend `apa`.

**Test:** small paired fixture (n = 8), assert the new fields exist and
`pseudomedian_conf_int` has length 2.

---

## 3. Exact odds-ratio CI — Fisher runner

**File:** `R/statistics_reports.R`, inside `sframe_run_fisher()`.

Current call is
`stats::fisher.test(tbl, simulate.p.value = isTRUE(options$simulate_p_value))`.
`conf.int` is not compatible with `simulate.p.value = TRUE` in base R
(fisher.test errors if both are requested) — guard for that: only request
`conf.int = TRUE` when `simulate.p.value` is not requested, and note this
clearly in the docs since the function silently drops the CI otherwise.

```r
want_ci <- !isTRUE(options$simulate_p_value)
ft <- tryCatch(
  stats::fisher.test(tbl, simulate.p.value = isTRUE(options$simulate_p_value),
                      conf.int = want_ci),
  error = function(e) NULL
)
```

`odds_ratio` is already returned (`ft$estimate`); it's currently just not
paired with a CI. Add `odds_ratio_conf_int = if (want_ci) as.numeric(ft$conf.int) else NULL`.
Fisher's exact CI is only defined for 2x2 tables — `ft$conf.int` is `NULL`
for larger tables regardless, so this degrades gracefully.

**Test:** 2x2 table fixture, assert `odds_ratio_conf_int` has length 2 when
`simulate_p_value` is not set; assert it's `NULL` when it is set.

---

## 4. Bootstrap CI for arbitrary statistics — already shipped

`bootstrap_ci()` already exists and is exported (`R/bootstrap_ci.R`). No
work needed here beyond referencing it from the new vignette (section 7
below) and, optionally, exposing it as a small-sample option for the
median in `sframe_run_*` runners that don't already have an exact CI —
skip this unless a runner surfaces the need; don't add unused surface
area.

---

## 5. Firth-penalised logistic regression

**DESCRIPTION:** add `logistf (>= 1.24.0)` to `Suggests`.

**New file:** `R/regression.R` (confirm this doesn't collide with an
existing file of that name — `ls R/ | grep -i regress` first; if
regression runners already live in `analysis_plan.R` or
`statistics_reports.R`, put it there instead for consistency).

```r
# R/regression.R
# Path: R/regression.R

sframe_run_firth_logistic <- function(data, vars, options = list()) {
  outcome <- vars[1]
  predictors <- vars[-1]
  if (!requireNamespace("logistf", quietly = TRUE)) {
    return(list(test = "firth_logistic",
                error = "Package 'logistf' needed. Install with: install.packages('logistf')"))
  }
  form <- stats::as.formula(
    paste(outcome, "~", paste(predictors, collapse = " + "))
  )
  fit <- tryCatch(
    logistf::logistf(form, data = data,
                      alpha = 1 - (options$conf.level %||% 0.95)),
    error = function(e) NULL
  )
  if (is.null(fit)) return(list(test = "firth_logistic", error = "Firth regression failed."))
  list(
    test = "firth_logistic",
    vars = vars,
    coefficients = stats::coef(fit),
    conf_int = cbind(lower = fit$ci.lower, upper = fit$ci.upper),
    p_values = fit$prob,
    likelihood_ratio = fit$loglik,
    apa = sprintf("Firth logistic regression (n = %d), likelihood ratio = %.2f",
                  nrow(data), fit$loglik[2] - fit$loglik[1])
  )
}
```

Follow whatever `%||%` / null-coalescing helper already exists in the
package (`rlang::%||%` is already an import; use that rather than defining
a new one).

**Registration in `run_analysis_plan()` (verified 2026-07-25):** there is
no registry table. Dispatch is a plain `switch(test, ...)` inside
`sframe_run_one_block()` at `R/analysis_plan.R:1101`. A new method id
(`firth_logistic`) needs: a `switch()` case there; a role-extraction entry
in `sframe_vars_for_method()` (`R/analysis_plan.R:770`, copy the
`regression_logistic_binary` line); a default-roles fallback in
`sframe_analysis_roles()` (`R/statistics_reports.R:57`); citation entries
in `.sframe_citations` (`R/analysis_plan.R:9`, `use` vector keyed by
method id); a `$table` (return it from the runner, or a case in
`sframe_result_table()`, `R/analysis_plan.R:845`); a plot case in
`sframe_plot_for_result()` (`R/plots.R:636`, the logistic-coefficients
helper already exists); entries in the builder `ANALYSIS_REGISTRY`
(`inst/builder/survey_builder.html` ~line 2690) and method dropdown
(~line 969), and in the studio registry (`inst/shiny/app.R` ~line 324)
with its requirements string (~line 722). Line numbers drift — re-grep
before editing. The full checklist lives in `todo_0.5.md` ("Integration
checklist"); it applies to this item too.

**Error class (verified):** the house pattern for a missing suggested
package is a `sframe_require_<pkg>()` helper in `R/conditions.R` wrapping
`rlang::check_installed()` (see `sframe_require_psych`, R/conditions.R:26).
Add `sframe_require_logistf()` there; do not invent
`sframe_missing_package` or guard inline.

**Test:** fixture with a binary outcome, n < 30, at least one covariate.
Also test the missing-package path with `skip_if(requireNamespace("logistf", quietly = TRUE))`.

---

## 6. Small-sample advisory

**Files:** `assumption_report()` (R/statistics_reports.R, ~line 495) and
`sample_size_plan()` (R/statistics_reports.R, ~line 1453).

Read both functions in full before editing — confirm their current return
shape (list vs data frame) so the `advisory` element is added consistently
with what callers already expect.

```r
sframe_small_sample_advisory <- function(n, test) {
  if (n < 30) {
    sprintf(
      paste0(
        "Small sample detected (n = %d). For %s, consider non-parametric ",
        "alternatives. Asymptotic p-values may be unreliable. ",
        "Bootstrap or exact confidence intervals are provided where available."
      ),
      n, test
    )
  } else {
    NULL
  }
}
```

Attach as `advisory` on the return list of both functions when applicable.
**Do not `warning()`** — render inline via whatever print method already
exists for these objects (`print.sframe_assumption_report()` /
equivalent — grep for it first). If no such S3 print method exists yet,
that's a separate small scope item: add one that prints the advisory with
a visible prefix (e.g. a leading "⚠" or "Note:" — match the house style
used elsewhere in console output, if any exists).

**Test:** call both functions with n = 15 and n = 50 fixtures; assert
`advisory` is a non-empty string in the first case and `NULL` in the
second.

---

## 7. New vignette: `vignettes/small-sample.Rmd`

Must knit offline, no data beyond base R/package bundled data, `set.seed()`
before every simulated example. Follow the existing vignette house style
(check `vignettes/surveyframe.Rmd` for the YAML header, WCAG-pass CSS
block, and `lang: en-GB` — all vignettes got a WCAG 2.2 AA pass in 0.3.4,
so this new one must match that from the start rather than needing a
follow-up pass).

Sections:

1. When is a sample "small" for survey research, and why it matters.
2. Constructing a small-sample instrument (`sf_instrument()` with a
   `sample_size_plan` block, `n = 20`).
3. `assumption_report()` and reading the advisory.
4. Mann-Whitney with the Hodges-Lehmann estimate.
5. Paired Wilcoxon with the pseudomedian CI.
6. Fisher's exact test with the exact odds-ratio CI.
7. `bootstrap_ci()` on the median of a scale score (already-shipped
   helper — this section is pure documentation, no new code).
8. Firth logistic regression for a binary outcome, n < 30.
9. Cohen's d with bootstrap CI (also already-shipped — `cohens_d_ci()`),
   focused on interpreting interval width at small n.
10. Citation block: `citation("surveyframe")` plus the smallsamplelab
    Zenodo DOI and the small-sample preprint DOI (blocked — see next
    section).

Add to `_pkgdown.yml` navigation alongside the other vignettes if that
file lists them explicitly (`grep -n "vignette" _pkgdown.yml` first).

---

## 8. CITATION wiring

**File:** `inst/CITATION`.

Two new `bibentry()` blocks, appended after the existing primary
bibentry (added 0.3.2):

- smallsamplelab book (Zenodo DOI) — **check whether this DOI is already
  live**; CLAUDE.md's 0.3.3 section says the small-sample textbook
  reference in the README already got "a full citation... with its
  Zenodo DOI" during the SEO/GEO pass, so the DOI may already exist and
  just needs copying from `README.md` rather than re-sourcing.
- the small-sample paper preprint DOI — **not yet registered** per
  `master_roadmap.md` ("0.4 | small-sample survey inference paper
  (smallsamplelab), draft"). This is a hard blocker: **the preprint must
  be posted before this bibentry can be filled in, and before 0.4 can go
  to CRAN** (CRAN will not accept a placeholder DOI). Track this as an
  external dependency, not an engineering task — flag it back to the
  owner rather than guessing a DOI.

---

## 9. RStudio add-in — moved to its own file

**Superseded by `todo_rstudio_addin.md`** (created 2026-07-24). That file
has the corrected scope (the guide's `addin_insert_skeleton()` snippet
uses a stale `sf_instrument()`/`sf_item()` API and needed fixing) plus
explicit isolation instructions: it's built on a separate branch/worktree
and does not merge to `dev` until 0.3.4 is submitted to and accepted by
CRAN, so it stays completely out of the way of the in-flight release.

This item has no dependency on the statistical work in this file and can
be built independently, any time — see `todo_rstudio_addin.md` directly
rather than duplicating its plan here.

---

## 10. Registration and exit checklist

- [x] Wire `firth_logistic` through every integration point listed in
  section 5 (switch case, vars_for_method, analysis_roles fallback,
  citations, table, plot, builder ANALYSIS_REGISTRY + dropdown, studio
  registry + requirements string). `mann_whitney`, `wilcoxon_pair`, and
  `fisher_exact` are extensions of existing wired runners and need no
  new registration, only their new fields.
- [x] `devtools::document()` clean; `bootstrap_ci`, `cohens_d_ci`,
  `cramers_v_ci`, `eta_sq_ci` already exported (0.3.4); newly exported in
  0.4: `sframe_run_firth_logistic` stayed internal (not exported), matching
  the house convention that `sframe_run_*` runners are internal.
- [x] `devtools::test()` — full suite passes (0 failures, 1 expected
  skip for the logistf-missing-package path since logistf is installed
  locally), plus every new test listed above (Mann-Whitney HL, paired
  Wilcoxon pseudomedian, Fisher CI, Firth logistic incl. missing-package
  path, small-sample advisory on both `assumption_report()` and
  `sample_size_plan()`).
- [x] `R CMD check --as-cran` — 0 errors, 0 real warnings (checkpoint
  run showed 3 WARNINGs, all artifacts of the checkpoint build itself —
  unbumped version, `--no-build-vignettes` flag — not real problems;
  needs a clean re-run with a bumped version and full vignette build
  before actual submission).
- [ ] Win-builder R-release and R-devel — not run this session.
- [ ] `inst/rstudio/addins.dcf` present, add-ins manually verified inside a
  real RStudio session (this cannot be automated — schedule it as a
  manual step, not a test). Deferred: RStudio add-in stays off
  `v0.4-dev`/`v0.5-dev` per standing instruction, built separately.
- [x] `logistf` in `Suggests`. `rstudioapi` deferred with the add-in.
- [x] `vignettes/small-sample.Rmd` knits clean, WCAG-pass CSS applied.
- [ ] CITATION: smallsamplelab DOI added (done, copied from README);
  preprint DOI **blocked on the preprint being posted** — do not submit
  to CRAN without it. See hard-blockers list, 2026-07-25 status update.
- [ ] Ethos R bridge repointed from asrda-r to surveyframe — confirm in the
  Ethos repo, not here; this is listed as a hard exit-checklist item in
  the original guide even though it's not surveyframe engineering work.
- [ ] `cran-comments.md` updated with the 0.4 diff summary before submission.

**2026-07-25: this file's remaining scope folds into `todo_0.5.md` by
owner decision, invoking the 2026-10-15 decision-gate consequence early
rather than waiting for the gate date.** `v0.4-dev` is being merged into
`v0.5-dev`; 0.4.1 renumbers to 0.5.1 per the gate's consequence list.
The unchecked items above (win-builder, RStudio add-in verification,
CITATION preprint DOI, Ethos bridge, cran-comments.md) carry forward as
open items on the combined release rather than being re-litigated here.

---

## Out of scope for this file

- **0.4.1 faculty demo proofing** is a separate patch after 0.4.0 ships
  (target per `master_roadmap.md`: 2026-12-11). No analytical features,
  UI/UX and doc fixes only, triggered by an actual faculty demo session
  that hasn't happened yet. Don't pull any of that work forward into this
  todo — it depends on live feedback this file's scope doesn't produce.
- **MCDM/DEMATEL** is v0.5, not v0.4 (reordered 2026-06-05 so small-sample
  ships first). Do not scope-creep MCDM work into this release.
- Anything in `R/plots.R`, the builder, SurveyStudio, or the dashboard —
  all of that is 0.3.4/0.3.5 scope and is done or in field-validation,
  not touched here.

---

## Delegation, model tiering, and token budget

This release is built with multiple agents in parallel where the work
allows it, and with the cheapest model that can do each job reliably.
The same policy applies to `todo_0.5.md` and `todo_0.6.md`.

### Model tiering (pick the cheapest tier that fits)

- **Haiku** (mechanical, zero-judgement work): grep sweeps to confirm
  line numbers and registry structure, running `devtools::test()` and
  reporting output, `devtools::document()` runs, checking that a
  vignette knits, verifying exports in NAMESPACE, formatting fixes.
- **Sonnet** (well-specified implementation): items #1, #2, and #3 in
  this file. Each is a 2-line change to an existing runner plus a small
  test, with the exact code given above. Also the vignette draft (#7),
  since the section list and house style are fully specified.
- **Opus or Fable** (judgement needed): item #5 (Firth logistic, which
  needs the registry lookup and condition-class decisions done
  correctly), item #6 (advisory, which touches two functions whose
  return shapes must be read and respected), the final review of all
  delegated work, and anything that changes `run_analysis_plan()`
  dispatch.

### Agent assignment for this release

Spawn agents only when a track is genuinely independent, and give each
one a narrow brief with the relevant section of this file pasted in, so
it does not re-derive context.

- **Agent 1 (Sonnet):** items #1, #2, #3 in sequence. Same editing
  pattern three times. Deliverable: the three runner edits plus their
  tests, with `testthat::test_file()` passing on each affected file.
- **Agent 2 (Opus):** items #5 and #6. Starts with the registry and
  condition-class reads listed in those sections.
- **Agent 3 (Sonnet, worktree isolation):** the RStudio add-in from
  `todo_rstudio_addin.md`. Fully independent, own branch, never merges
  until 0.3.4 is accepted by CRAN.
- **Lead (this session):** integration, the vignette review, CITATION,
  and the exit checklist. Do not delegate the exit checklist.

Agents must not run the full test suite repeatedly. Each agent runs
only the test file it touched via `testthat::test_file()`. The lead
runs `devtools::test()` once at integration and once before the
tarball build.

### Token-saving rules (binding for every agent on this release)

- Grep for the target function first, then read only that function's
  range with an offset and limit. Never read a 1500-line file end to
  end to edit 10 lines of it.
- Never re-read a file already read in the same session unless it was
  edited by someone else.
- Do not paste whole files or whole test outputs back in reports. A
  report is: what changed, file and line, test result line, anything
  surprising. Under 15 lines unless something failed.
- Batch independent tool calls in one message.
- Use an Explore agent for any search expected to touch more than 5
  files, so the file contents stay out of the lead's context.
- Verification is one targeted test run per change, then one full
  suite at the end. Not a full suite per edit.

---

## Suggested build order (for delegation — see the handover prompt)

Two independent tracks. Either can go first; both must land before the
exit checklist is run.

**Track A — statistical inference (needs care, do not delegate the
whole thing blindly):**
1. Mann-Whitney HL estimate (#1) — smallest, safest first move, confirms
   the runner-editing pattern.
2. Paired Wilcoxon pseudomedian (#2) — same pattern, low risk.
3. Fisher exact CI (#3) — slightly more care needed for the
   `simulate.p.value` interaction.
4. Small-sample advisory (#6) — touches two existing functions, read both
   fully first.
5. Firth logistic (#5) — new file, new Suggests dependency, needs the
   registry lookup done carefully. Highest-risk item in this track.

**Track B — RStudio add-in (#9):** fully independent, can run in parallel
with Track A at any time. Two new small files plus one DESCRIPTION line,
content already specified verbatim in the implementation guide.

**Then, after both tracks:** vignette (#7, depends on all of Track A being
done since it demonstrates each new feature), CITATION (#8, partially
blocked externally), exit checklist (#10).
