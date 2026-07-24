# todo_0.6.md — surveyframe v0.6: Structural model execution and semScreenR bridge

Dev-only planning file, tracked on `dev` only. Its name is in `.gitignore`
and `.Rbuildignore`. Companion to `CLAUDE.md`, `todo_0.5.md` (whose
"Architecture ground truth" and integration checklist apply verbatim
here), and
`../portfolio-planner/development_instructions/06_v05_v07_implementation.md`
(v0.6 section — intent only, this file is the verified plan).

Last updated: 2026-07-25. Target CRAN submission: 2027-03-11. Theme:
fitted measurement and structural models. Syntax generation stays the
default zero-dependency path.

Anchors verified against `main` 2026-07-25; re-grep before editing.

---

## Hard blockers (start tracking during the 0.5 cycle)

1. **semScreenR is not on CRAN and not cloned locally as of 2026-07-25.**
   Its `triage_apply` defect (returns neither the screened model nor the
   pruned data) is fixed in the semScreenR repo, as a separate
   engagement scheduled during the 0.5 cycle, and the package submitted
   to CRAN in time for this release. Only the bridge (#5) is gated on
   it: everything else ships regardless, with the bridge deferred and
   the guard message carrying the release if semScreenR slips.
2. Verify the real post-fix `triage_apply()` signature and return shape
   before writing the bridge. Never code against the defective API.
3. lavaan already in Suggests (0.3.2). seminr joins in this release.
   MASS already in Suggests (used by existing runners and test fixtures).

## Model-layer ground truth (verified)

All in `R/model_layer.R` unless noted:

- Constructors: `sf_construct()` (line 129: id, label, indicators,
  type), `sf_path()` (160), `sf_covariance()` (177), `sf_indirect()`
  (195), `sf_model()` (223). `validate_model()` (275),
  `add_model()` (447), `model_json()` (430).
- Syntax generators: `efa_syntax()` (646), `cfa_lavaan_syntax()` (681,
  signature `(instrument, model, ordered)`), `sem_lavaan_syntax()` (757,
  `(model, instrument, standardised)`), `seminr_syntax()` (845,
  `(model, data_name, nboot, seed)` — generates code text, does not fit).
  Plus a separate scale-based `cfa_syntax()` in `R/psychometrics.R:364`.
- Model round-trip: `sframe_restore_model()`
  (`R/read_write_sframe.R:288`) normalises legacy `type = "sem"` to
  `"cb_sem"`. Valid model types today: `"cfa"`, `"cb_sem"`, `"pls_sem"`
  (confirm in `validate_model()` before relying on this list).
- Existing plan method ids (already in the `sframe_run_one_block()`
  switch, `R/analysis_plan.R:1112-1132`): `cfa_lavaan_syntax`,
  `sem_lavaan_syntax`, and `pls_sem`/`seminr_syntax` (aliased cases).
  They resolve the model via `sframe_model_by_id(instrument, model_id)`
  from a `model` role and return `syntax` + `apa` + `prompt`.
- Henseler HTMT already shipped in 0.3.4 inside `validity_report()`
  (`R/statistics_reports.R:1295`) — do not re-implement discriminant
  validity here.
- `model_report_template()` (920) is the current model reporting hook.

## Design decision (owner, at release start): fitted-model method ids

New switch cases `cfa_fit`, `sem_fit`, `pls_sem_fit` alongside the
existing `*_syntax` ids, rather than an `options$fit = TRUE` flag on the
syntax methods. Rationale: the builder and studio registries are keyed
by method id, a separate id gives the fit path its own roles, hints,
assumptions text, and citation set, and old instruments keep meaning
exactly what they said. Confirm with the owner, then hold it.

---

## 0. The fitting data contract: from response frame to estimator

The hard half of this release. lavaan and seminr assume a clean numeric
indicator frame; a surveyframe response frame is not that. One shared
resolver, `sframe_model_data(instrument, data, model, missing, ordered)`
in `R/model_layer.R`, feeds every fit in this release, is unit tested on
its own, and settles the following before any estimator runs:

### 0a. Raw indicators, never scale scores

Fits consume the item columns, not the scored scale columns.
`run_analysis_plan(scored = TRUE)` calls
`score_scales(keep_items = TRUE, keep_meta = TRUE)`
(`R/analysis_plan.R:1262-1264`), so both column sets coexist in plan
runs — the resolver selects only the indicator columns the model names.
A construct whose `items` entry names a scale id instead of item ids is
a validation error with a message explaining the distinction.

### 0b. Indicator-to-column resolution

Construct `items` reference item ids, but a matrix item's data arrives
as `item__sub` expansion columns (`R/read_responses.R:97-105`), never
as its base id. The resolver maps each declared indicator to its real
column: plain id when the column exists, the expansion columns when the
id names a matrix item (each `item__sub` becomes its own indicator,
labelled), and a typed error naming the indicator and the available
columns when neither resolves. `validate_model(strict = TRUE)` gains
the same awareness so a model referencing a matrix parent validates
against what the data will actually contain. Ranking and
multiple-choice expansions are rejected as indicators (they are not
interval-scaled), with a clear message.

### 0c. Value coercion and reverse coding

Response columns can hold character choice codes; choice-set values
map them to numerics. Do not write new coercion: reuse
`sframe_numeric_scale_data(data, item_ids, reverse_context)` and
`sframe_reverse_context(instrument)` (`R/score_scales.R:46` and `:3`) —
the exact machinery scoring already uses, so fitted loadings and scale
scores can never disagree about coding direction. Consequence to
document and test: `cfa_lavaan_syntax()` only emits a comment naming
reverse-coded indicators (verified, `R/model_layer.R` ~710-735), so a
user fitting the generated syntax on raw data sees negative loadings
where `run_cfa()` shows positive ones. The `run_cfa()` docs and the
vignette state this explicitly; a test asserts the reversed item's
loading is positive through the resolver path.

### 0d. Ordinal versus continuous indicators

`ordered = FALSE` default: Likert indicators treated as continuous
with `estimator = "MLR"` (robust ML), the convention for >= 5-point
scales; state it in the docs and vignette. `ordered = TRUE`: the
resolver returns the indicator columns as ordered factors, the fit
passes `ordered = <indicators>` to lavaan (which switches to WLSMV),
and combining `ordered = TRUE` with an explicitly ML-family
`estimator` argument is a typed error, not a silent override. seminr
has no ordinal path: `run_plssem(ordered = TRUE)` errors with a
message saying PLS treats indicators as metric.

### 0e. Missing data

`missing = c("listwise", "fiml")` on `run_cfa()`/`run_sem()`.
Listwise is the default (lavaan's own default, no surprises); `fiml`
passes `missing = "ml"` and is a typed error when combined with
`ordered = TRUE` (DWLS has no FIML). Every fit result records
`n_total`, `n_used`, and the per-indicator missingness share; when
more than 10% of rows drop under listwise, the result carries a note
pointing at `missing_data_report()`. seminr: mean replacement is its
default; record that in the result so the report never implies
listwise.

### 0f. Identification and sample-size guards

Before fitting, the resolver checks and the runner reports:
- any construct with 1 indicator: allowed only when its mode is
  `single_item` (fixed loading and zero residual, the standard
  treatment); otherwise a typed error naming the construct.
- 2-indicator constructs: allowed in multi-construct models, flagged
  in a `notes` field (locally just-identified).
- n < number of free parameters: typed error (unfittable).
- n per free parameter < 5: warning note in the result (small-sample
  SEM advisory, consistent with the 0.4 advisory language).
- invariance: per-group versions of the same checks, plus the
  existing n < 100 per-group warning from #3.

### 0g. PLS measurement modes (verified: the model layer already has them)

`sf_construct()` carries `mode = c("reflective", "composite",
"formative", "single_item")` and a `weights` field
(`R/model_layer.R:129-149`). The seminr translation maps: reflective ->
`seminr::reflective()`; composite -> `seminr::composite()` mode A;
formative -> `seminr::composite(weights = seminr::mode_B)`;
single_item -> `seminr::single_item()`. CB-SEM fits reject formative
and composite constructs with a typed error explaining that formative
measurement needs the PLS path (or explicit MIMIC modelling, out of
scope). A translation test covers all 4 modes against a hand-built
seminr model.

## 1. run_cfa() and run_sem() — lavaan execution

**File:** `R/model_layer.R`, after the syntax generators.

- Exported `run_cfa(instrument, data, model_id, estimator = "MLR",
  missing = "listwise", ordered = FALSE, ...)` and `run_sem(...)`:
  resolve the model (`sframe_model_by_id`), resolve the data through
  `sframe_model_data()` (section 0 — indicators, coercion, reverse
  coding, guards all happen there, not in the fit functions), build
  syntax with the existing generators (match their real signatures
  above, the 06 guide's `cfa_syntax(sf, model_id)` sketch is wrong),
  guard with a new `sframe_require_lavaan()` in `R/conditions.R`
  (pattern: `sframe_require_psych`, line 26), fit inside `tryCatch()`,
  tag `attr(fit, "sframe_hash") <- instrument$meta$instrument_hash`.
- Companion result builder shared by the plan runners: a fit-summary
  list with `$table` (chi-square, df, p, CFI, TLI, RMSEA + 90% CI,
  SRMR, one row per index) and a standardised-loadings table
  (`lavaan::standardizedSolution()`), plus `apa` and `prompt`. The
  lavaan fit object itself is kept under `$fit`, and **must be stripped
  before any JSON serialisation of results** (relevant to the 0.9
  bundle work — leave a comment).
- Plan runners `sframe_run_cfa_fit()`, `sframe_run_sem_fit()` in
  `R/model_layer.R` following the runner contract, registered per the
  todo_0.5 integration checklist (switch, citations, plot, builder,
  studio, restore). Non-convergence and lavaan warnings surface as an
  `error`/`warning` field, never a crash.
- Plot: `sframe_plot_cfa_loadings()` (loading dot plot per construct,
  ggplot2-guarded) registered in `sframe_plot_for_result()`.

## 2. run_plssem() — seminr execution

**Files:** DESCRIPTION (`seminr (>= 2.3.0)` to Suggests),
`R/model_layer.R`.

- `seminr_syntax()` already builds the full seminr call as text (845).
  The execution path does not eval that text: private
  `.sframe_seminr_mm(model)` and `.sframe_seminr_sm(model)` build the
  `seminr::constructs()`/`relationships()` objects directly from
  `sframe_model_constructs()`/`sframe_model_paths()` (lines 67-85),
  applying the section 0g mode mapping, so the two paths cannot drift
  apart silently — add a test asserting the generated-syntax path and
  the direct path name identical constructs and modes.
- Data enters through the same `sframe_model_data()` resolver
  (`ordered = TRUE` rejected per 0d; seminr's mean-replacement
  missing-data behaviour recorded in the result per 0e).
- `run_plssem(instrument, data, model_id, inner_weights =
  "path_weighting", nboot = NULL)` exported; bootstrap only when
  `nboot` is set. Result contract mirrors #1: `$table` with path
  coefficients (plus t and CI when bootstrapped), R squared per
  endogenous construct, loadings table, `apa`, `prompt`, `$fit`
  stripped before serialisation.
- Plan runner `pls_sem_fit`, wired per the checklist.

## 3. test_invariance()

**New file:** `R/invariance.R` (header comment per house style).

Per the 06 guide (configural, metric, scalar via
`group.equal = character(0)` / `"loadings"` / `c("loadings",
"intercepts")`, `lavTestLRT()` differences) with these additions:

- Returns a classed `sframe_invariance` object with `$table`: one row
  per level (chi-square, df, CFI, RMSEA, SRMR) plus the two difference
  rows (delta chi-square, delta df, p, delta CFI), and a `decision`
  field applying the delta-CFI <= .01 convention with the convention
  named in the output.
- `print()` and `plot()` S3 methods (fit-index trajectory across
  levels; follow `plot.sframe_validity_report()`, `R/plots.R:1059`).
- Guards: grouping variable exists, >= 2 non-empty groups, warn (typed,
  `sframe_warn_*` pattern in `R/conditions.R`) when any group n < 100.
- Optional plan method id `invariance` wired per the checklist, roles:
  model + group.

## 4. cmv_diagnostics()

**File:** `R/psychometrics.R` (exists; reliability/item/EFA reports live
there, so this belongs beside them).

Per the guide (Harman first-factor percentage via `stats::prcomp`,
VIF loop) with: `stats::` prefixes, a classed return with `$table`
(diagnostic, value, threshold, flag), print method matching the house
console style, and thresholds documented (Harman > 50%, VIF > 10).
Base R only, no guard needed.

## 5. screen_for_sem() — the semScreenR bridge

**New file:** `R/sem_screen_bridge.R`. Gated on blockers #1-#2.

- `screen_for_sem(instrument, data, model_id)`: when semScreenR is
  absent, message "semScreenR not installed; screening skipped." and
  return `list(screening_report = NULL, ready_data = data)`. When
  present, call the verified post-fix API on the model's indicator
  columns (collect them via `sframe_model_constructs()` indicators).
- Wire into the `cfa_fit`/`sem_fit`/`pls_sem_fit` runners (not into
  `run_analysis_plan()` generally): screening runs first, its report
  attaches as `$screening` on the result, and the screened data feeds
  the fit when the researcher set `options$screen = TRUE` (opt-in,
  consistent with the strict-scope principle that every new capability
  is opt-in).
- semScreenR goes in Suggests only after it is on CRAN (CRAN policy:
  Suggests must be available); until then the bridge code merges but
  the DESCRIPTION entry and the present-path test wait. If CRAN
  acceptance has not happened by feature freeze, defer the bridge
  entirely and record it in decisions.md.

## 6. Higher-order constructs

Roadmap deliverable absent from the 06 guide. Scope at release start:

- Minimum viable: `sf_construct()` accepts constructs as indicators
  (an `indicator_type = c("items", "constructs")` field),
  `validate_model()` checks the referenced constructs exist and no
  cycles, `cfa_lavaan_syntax()` emits second-order syntax, `run_cfa()`
  fits it, `sframe_restore_model()` round-trips the new field.
- If this cannot be expressed without breaking the serialised model
  shape (check `sframe_restore_model()` and the hash canonicalisation
  in `R/read_write_sframe.R:33` first), write a design note and defer
  to a named release. No improvised structure changes mid-cycle.

## 7. Vignette: vignettes/sem-workflow.Rmd

The guide's 8-step outline (build 3 reflective constructs x 3 items,
score, screen, run_cfa, invariance across 2 groups, CMV, optional
PLS block, rendered report). Data via `MASS::mvrnorm()` with
`set.seed()`. Every fit chunk guarded so the vignette knits with no
Suggests installed (lavaan chunks `eval = requireNamespace(...)` or
precomputed). 0.3.4 house rules: WCAG style block, `lang: en-GB`,
`fig.alt`, offline knit, axe-core zero violations.

## 8. Exit checklist

- `run_cfa()`, `run_sem()`, `run_plssem()`, `test_invariance()`,
  `cmv_diagnostics()`, `screen_for_sem()` exported, documented, tested,
  with `$table`, print/plot methods where specified, graceful failure
  everywhere.
- Data contract (section 0) verified end to end: matrix-item
  indicators resolve to their expansion columns; ranking/multi-choice
  indicators rejected; character choice codes coerce; a reverse-coded
  item loads positively through the resolver (and the docs state the
  generated-syntax divergence); `ordered = TRUE` + ML estimator and
  `fiml` + `ordered` both raise typed errors; n_total/n_used and the
  listwise-drop note reported; single/2-indicator and
  n-vs-parameters guards fire; all 4 measurement modes translate to
  seminr correctly and formative/composite constructs are rejected by
  the CB-SEM path.
- Plan ids `cfa_fit`, `sem_fit`, `pls_sem_fit` (and `invariance` if
  confirmed) wired through every point of the todo_0.5 integration
  checklist including both JS registries and
  `sframe_restore_analysis_block()`.
- seminr syntax-path/direct-path consistency test passes.
- Higher-order constructs shipped or design-note-deferred.
- semScreenR bridge verified against its CRAN release, or formally
  deferred in decisions.md.
- Fit objects never enter JSON serialisation paths (grep the 0.9-bound
  comment in place).
- Vignette knits with and without Suggests, axe-core clean.
- `devtools::document()` clean; full suite; `R CMD check --as-cran`
  0/0/<=1 NOTE with no Suggests installed as well as with; win-builder
  both flavours; `cran-comments.md`; NEWS.md.
- Owner reminders: Ethos surfaces SEM next cycle; the semScreenR
  methodology paper is written fresh (AI draft rejected); ASRDA Part IV
  ch 10 and Part IX ch 26-27 become real with this release.

---

## Delegation, model tiering, and token budget

Binding policy per `todo_0.4.md`. This release parallelises less than
0.5: #1, #2, #6 all extend `R/model_layer.R`. Sequence, don't fan out.

### Build order and agent assignment

- **Lead (Fable/Opus) first:** read `R/model_layer.R` once, write a
  half-page structure summary (model list shape, constructor fields,
  syntax entry points, restore path) into every agent brief; settle the
  method-id design decision and the higher-order scope (#6) with the
  owner; then implement `sframe_model_data()` (section 0) with its full
  test file, and `run_cfa()` on top of it, as the reference diff. The
  data contract is the release's correctness core — never delegated,
  and no fit code merges before it is green.
- **Agent 1 (Sonnet):** `run_sem()` + the `sem_fit` runner + tests,
  from the reference diff.
- **Agent 2 (Sonnet):** #2 seminr (after the reference lands, so the
  result contract is fixed).
- **Agent 3 (Sonnet):** #3 invariance + #4 CMV + tests (disjoint files,
  one brief).
- **Lead:** #5 bridge (blocker-sensitive), #6 higher-order, all
  shared-file wiring (switch, plot dispatcher, JS registries) in one
  pass, per the conflict rule from todo_0.5.
- **Agent 4 (Sonnet):** #7 vignette after #1-#4 land.
- **Agent 5 (Haiku):** verification sweeps throughout; plus the
  double `R CMD check` run (with and without optional packages).
- The semScreenR `triage_apply` fix is a separate engagement in its own
  repo during the 0.5 cycle. Never fold it into this release's pool.

### Model tiering

- **Haiku:** test sweeps, document runs, knit checks, the no-Suggests
  check environment run.
- **Sonnet:** #1-mirror (run_sem), #2, #3, #4, #7 as briefed.
- **Opus/Fable:** the model-layer read and summary, the reference
  implementation, #5, #6, shared-file wiring, review of every
  delegated diff (the seminr translation is the highest
  silent-failure risk in the release — review it against a hand-built
  seminr model, not just tests).

### Token-saving rules (binding)

Same 6 rules as todo_0.4/todo_0.5, plus: the lead's model-layer
structure summary is the only way agents learn `model_layer.R` — agents
do not read the file beyond the specific function ranges they edit.
