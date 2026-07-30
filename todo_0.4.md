# todo_0.4.md — surveyframe v0.4: Small-Sample Inference + RStudio Add-in

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
