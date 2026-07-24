# todo_0.4.md — surveyframe v0.4: Small-Sample Inference + RStudio Add-in

Dev-only planning file. Not tracked on `main`; add its name to `.gitignore`
there alongside `revision_todo_0.3.md` and the other dev-only files before
this is ever merged to `main`. Companion to `CLAUDE.md` and to
`../portfolio-planner/development_instructions/05_v04_implementation.md`
(the original implementation guide) and `19_v034_v035_implementation.md`
(the CI-helper scope reconciliation).

Last updated: 2026-07-24. Target CRAN submission: 2026-11-20
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

| Item | Where it will live | Status |
|---|---|---|
| Hodges-Lehmann estimate on Mann-Whitney | `R/analysis_plan.R`, `sframe_run_mann_whitney()` (line ~270) | not started |
| Pseudomedian CI on paired Wilcoxon | `R/analysis_plan.R`, `sframe_run_wilcoxon_pair()` (line ~486) | not started |
| Exact odds-ratio CI on Fisher | `R/statistics_reports.R`, `sframe_run_fisher()` (line ~779) | not started |
| Firth-penalised logistic regression | new, `R/regression.R` or similar | not started |
| Small-sample advisory | `assumption_report()` and `sample_size_plan()`, both in `R/statistics_reports.R` (lines ~495, ~1453) | not started |
| RStudio add-in | new `inst/rstudio/addins.dcf`, new `R/rstudio_addins.R` | not started |
| `vignettes/small-sample.Rmd` | new | not started |
| CITATION: smallsamplelab + preprint DOIs | `inst/CITATION` | not started, blocked on DOIs |
| Ethos R bridge repoint (asrda-r → surveyframe) | Ethos repo, not this one | not confirmed |

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

**Registration in `run_analysis_plan()`:** find the method registry (search
`R/analysis_plan.R` for the existing family-keyed list structure used by
`mann_whitney`, `fisher_exact`, etc. — match that exact structure, not the
guide's `list(id=, fn=, required_n=, small_sample=)` sketch, unless that is
in fact the real structure; verify before writing).

**Error class:** use the package's existing typed-condition pattern from
`R/conditions.R` (`sframe_check_instrument()` neighbours) rather than a new
ad hoc `rlang::abort()` call — check what condition classes already exist
for "missing suggested package" before inventing `sframe_missing_package`.

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

- Register `firth_logistic` (and confirm `mann_whitney`,
  `paired_wilcoxon`/`wilcoxon_pair`, `fisher_exact` already are, since
  they're extensions of existing runners, not new registrations) in
  whatever method registry `run_analysis_plan()` actually uses — verify
  its real structure before editing, per the signature note above.
- `devtools::document()` clean; `bootstrap_ci`, `cohens_d_ci`,
  `cramers_v_ci`, `eta_sq_ci` already exported (0.3.4); newly exported in
  0.4: `sframe_run_firth_logistic` (or whatever the real public/internal
  naming convention turns out to be — most `sframe_run_*` functions are
  internal, not exported; check before assuming this one should be).
- `devtools::test()` — full suite passes, plus every new test listed
  above (Mann-Whitney HL, paired Wilcoxon pseudomedian, Fisher CI, Firth
  logistic incl. missing-package path, small-sample advisory on both
  `assumption_report()` and `sample_size_plan()`).
- `R CMD check --as-cran` — 0 errors, 0 warnings, ≤1 NOTE.
- Win-builder R-release and R-devel — clean.
- `inst/rstudio/addins.dcf` present, add-ins manually verified inside a
  real RStudio session (this cannot be automated — schedule it as a
  manual step, not a test).
- `logistf` and `rstudioapi` in `Suggests`.
- `vignettes/small-sample.Rmd` knits clean, WCAG-pass CSS applied.
- CITATION: smallsamplelab DOI added (should be a copy from README, low
  risk); preprint DOI added (**blocked on the preprint being posted** —
  do not submit to CRAN without it).
- Ethos R bridge repointed from asrda-r to surveyframe — confirm in the
  Ethos repo, not here; this is listed as a hard exit-checklist item in
  the original guide even though it's not surveyframe engineering work.
- `cran-comments.md` updated with the 0.4 diff summary before submission.

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
