# MAS Review — surveyframe 0.3.4 Pre-Submission Review

**Reviewer:** Mohammed Ali Sharafuddin
**Date created:** 2026-07-17
**Version under review:** 0.3.4 (feature work committed at main 0ca5d24,
version bumped, not yet tagged, not yet on CRAN)
**Purpose:** Human verification of everything that changed in 0.3.4 before
win-builder and CRAN submission. 0.3.4 completes the plotting and interface
arc: the editable interpretation step, the SurveyStudio result-card charts,
3 new plot() methods, the dashboard chart coverage, date-question bounds,
and the 2 WCAG 2.2 AA audits. The 0.3.3 review (mas_review_033.md) covers
the stable surfaces; this review targets the delta plus the release-safety
checks.

**Machine verification note (2026-07-17):** the automated pass is done: 649
tests, headless chromote suites for the builder (date bounds, outline
editing, WCAG), the exported survey (bounds enforcement end to end), and
SurveyStudio (Interpretations card, result cards, download round trip with a
typed interpretation landing in the report), plus axe-core WCAG 2.2 AA runs
reporting zero violations across 6 builder states and all 7 vignettes.

**Machine verification note, statistics half (2026-07-18):** the effect-size
CI layer, Henseler HTMT, Little's MCAR, omega notes, tidy EFA frames, PDF
output, report theming, and the codebook upgrades are implemented and
verified: `devtools::document()` clean, 72 new expectations across
`test-v034-effect-cis.R` and `test-v034-stats-reporting.R` (0 failed, 1
expected skip for naniar not being installed on this machine), full suite
721 passed / 0 failed / 1 skipped, all 9 CI-bearing runners spot-checked
live against the demo instrument with correct bracketed intervals, and a
fresh axe-core run against the re-themed HTML report reporting zero WCAG
2.2 AA violations. Parts J to M below are ticked on that basis.
Items marked [x] below without reviewer initials were verified that way.
Items left unticked need a human: look-and-feel judgements, the phone check,
win-builder, the fresh-eyes pass, and the decisions flagged to the owner.

**Scope note (2026-07-17):** after this file was drafted, the owner merged
the statistics and reporting scope (formerly 0.3.5) into 0.3.4. Parts J to
M below cover that work; Parts A to I stay valid for the plotting and UI
half.

Work through this document sequentially in a fresh RStudio session with a
real browser.

---

## Prerequisites

- [ ] RStudio open with a clean R session (restart R first).
- [ ] Chrome or Firefox available.
- [ ] `devtools`, `remotes`, `ggplot2`, `psych`, `lavaan`, `seminr`,
  `shiny`, and `quarto` are installed.
- [ ] Internet access (GitHub install).

---

## Part A — Installation and metadata (6 items)

### Step A1 — Install the release candidate from GitHub

```r
remotes::install_github("MohammedAliSharafuddin/surveyframe",
                        force = TRUE)
packageVersion("surveyframe")
# Expected: '0.3.4'
```

- [ ] A1.1 Installation completes with no errors or warnings.
- [ ] A1.2 `packageVersion()` reports 0.3.4.

### Step A2 — Release metadata reads correctly

```r
news(package = "surveyframe")
```

- [ ] A2.1 The 0.3.4 NEWS entry leads and reads as one release for a
  first-time reader: interpretations, charts, survey design, and
  accessibility, with no internal project names or planning content.
- [ ] A2.2 The prose contains no em-dashes, semicolons, "not X but Y"
  constructions, or banned words, and uses UK spellings.
- [x] A2.3 `citation("surveyframe")` shows version 0.3.4 (the version is
  read dynamically from DESCRIPTION).
- [ ] A2.4 The LICENSE file at the public repo root is still the two-line
  CRAN template, with the full MIT text in LICENSE.md only.

---

## Part B — Editable interpretations (12 items)

### Step B1 — The render_report() argument

```r
library(surveyframe)
instr <- read_sframe(system.file("extdata", "tourism_services_demo.sframe",
                                 package = "surveyframe"))
responses <- read_responses(
  system.file("extdata", "tourism_services_responses.csv",
              package = "surveyframe"),
  instr, respondent_id = "respondent_id", submitted_at = "submitted_at",
  meta_cols = "started_at")
out <- render_report(instr, responses, output_file = "report_interp.html",
  interpretations = list(
    rq_dm_sat = "Digital marketing engagement rose with satisfaction, in line with the preregistered rule."))
browseURL(out)
```

- [x] B1.1 The RQ section for `rq_dm_sat` shows a "Planned decision rule"
  line followed by an "Interpretation" line carrying the text above.
- [x] B1.2 Every other research question renders exactly as it did in
  0.3.3, with no new labels.
- [ ] B1.3 The pairing reads correctly to a researcher: the rule is clearly
  the prospective plan and the interpretation is clearly the written
  conclusion. Judgement call.
- [x] B1.4 Re-rendering with `interpretations = NULL` produces the 0.3.3
  output (no "Planned decision rule" label anywhere).
- [x] B1.5 `render_results()` accepts the same argument and shows the
  override in the interpretation section of its block.
- [x] B1.6 The interpretation text never appears in the .sframe file:
  `write_sframe()` then `read_sframe()` round-trips with no interpretation
  content and no hash change.

### Step B2 — SurveyStudio Interpretations card

```r
launch_studio()
# Open the demo instrument, upload the demo responses, go to Export.
```

- [x] B2.1 The Export screen has three cards: Instrument file, Report
  contents (with the Chart theme radio), Interpretations, and Generate.
- [x] B2.2 The Interpretations card lists every saved plan block with its
  id, question, planned decision rule, and live APA result.
- [ ] B2.3 Type an interpretation for two research questions, generate the
  report, and confirm both appear beside their decision rules. (The
  machine did this for one; do a second by hand.)
- [ ] B2.4 The card reads well at 34 research questions: scrolling is
  acceptable and the fields are clearly associated with their questions.
  Judgement call.

### Step B3 — Builder Report outline editing

Open `inst/builder/survey_builder.html` in a browser, add a question, add
an analysis plan, then open Analyse and the Report outline tab.

- [x] B3.1 Each research question in the outline shows an editable
  "Planned decision rule (editable)" field pre-filled from the plan.
- [x] B3.2 Editing the field updates the plan card and the RQ dialogue;
  editing in the dialogue updates the outline.
- [ ] B3.3 The inline field looks like part of the document skeleton rather
  than a form dropped into it. Judgement call.

---

## Part C — SurveyStudio result cards (6 items)

With the demo instrument and responses loaded, open Analyse and the Run
stage.

- [x] C1.1 Results render as one card per research question: number and
  block id, question, method badge, APA line, and the chart beneath.
- [x] C1.2 The regression card stacks its fit chart and 4 diagnostic
  panels.
- [x] C1.3 Syntax-only and chartless blocks render their card without a
  chart and without an empty gap.
- [ ] C1.4 Chart quality at card width: labels legible, nothing clipped,
  colours match the report. Judgement call.
- [ ] C1.5 The Run stage remains responsive with 34 blocks (the plan runs
  once and is shared with the Export screen; expect one initial wait, then
  smooth tab switches).
- [ ] C1.6 The card list reads better than the 0.3.3 flat table.
  Judgement call.

---

## Part D — New plot() methods and dashboards (10 items)

### Step D1 — plot() methods

```r
vr <- validity_report(list(SAT = c(sat_1 = .82, sat_2 = .78),
                           LOY = c(loy_1 = .69, loy_2 = .71)))
plot(vr)
results <- run_analysis_plan(responses, instr, plots = TRUE)
plot(results, which = "rq_dm_sat")
mr <- missing_data_report(responses, instr)
plot(mr)
```

- [x] D1.1 `plot(vr)` draws CR and AVE bars with the 0.70 and 0.50
  threshold lines.
- [x] D1.2 `plot(results, which = ...)` returns one chart; `plot(results)`
  prints them all; a results object built without `plots = TRUE` aborts
  with a message pointing at the argument.
- [x] D1.3 `plot(mr)` draws missing rates by item, or returns NULL when
  nothing is missing.
- [ ] D1.4 All three read correctly in the print palette
  (`palette = "print"`). Judgement call.

### Step D2 — Dashboard coverage

```r
launch_dashboard(instr, responses)
```

- [x] D2.1 The Quality tab opens with the flag-rate chart and the
  missingness chart above the attention-check table.
- [x] D2.2 The Scales tab shows the scale-score correlation heatmap below
  the distribution chart.
- [x] D2.3 The SurveyStudio Quality Dashboard screen and Dashboard tab
  mirror the same three charts.
- [ ] D2.4 Uninstall or mask ggplot2 (`callr::r()` with a stripped
  library path is the quick way) and confirm the base-graphics fallbacks
  draw instead of erroring.
- [ ] D2.5 The heatmap remains readable with the demo's 5 scales and at a
  phone-width window. Judgement call.
- [ ] D2.6 Filters still apply to the new charts (set a date filter and
  watch the missingness chart change).

---

## Part E — Date-question bounds (8 items)

### Step E1 — R side

```r
it <- sf_item("visit", "When did you visit?", type = "date",
              date_min = "2026-01-01", date_max = "2026-12-31")
sf_item("bad", "x", type = "date", date_min = "2026-12-31",
        date_max = "2026-01-01")
# Expected: a validation error saying min must not be later than max
```

- [x] E1.1 Valid bounds are stored as "YYYY-MM-DD" strings and survive a
  write/read round trip.
- [x] E1.2 Reversed bounds and unparseable dates abort with a typed
  validation error.

### Step E2 — Builder and exported survey

- [x] E2.1 A date question's inspector shows Earliest date and Latest date
  fields; setting min after max raises an error toast.
- [x] E2.2 The exported survey's date input carries the min and max
  attributes, so the native picker greys out-of-range dates.
- [x] E2.3 A typed out-of-range date is blocked at page validation with
  "Please pick a date on or after/before ..." in both directions.
- [x] E2.4 An in-range date passes and submits.
- [ ] E2.5 On a phone, the native date wheel respects the bounds.
- [ ] E2.6 The bounds error message reads well next to the required-field
  message style. Judgement call.

---

## Part F — WCAG 2.2 AA audits (8 items)

- [x] F1.1 axe-core 4.10.2 (wcag2a, wcag2aa, wcag22aa) reports zero
  violations across 6 builder states: build with inspector, preview,
  Analyse plan tab, Report outline, settings modal, RQ modal.
- [x] F1.2 All 7 vignettes report zero violations and zero heading-order
  skips.
- [ ] F2.1 The darker muted text (`#5b6b80` replacing `#94a3b8`) still
  reads as secondary text and has not flattened the builder's visual
  hierarchy. Judgement call.
- [ ] F2.2 The darker save-status colours (amber and green) still read as
  states at a glance.
- [ ] F2.3 Vignette links in the darker teal still read as brand.
  Judgement call.
- [ ] F2.4 Wrapped code blocks in the vignettes: pick the widest chunk in
  the lead vignette and confirm the wrap reads acceptably.
- [ ] F2.5 Keyboard-only pass of the builder: tab through build, preview,
  analyse, and both modals; focus is always visible and no control is
  unreachable.
- [ ] F2.6 One screen-reader spot check (VoiceOver, NVDA, or Orca): the
  preview inputs announce their question labels.

---

## Part G — Release safety (8 items)

- [ ] G1.1 `R CMD check --as-cran` on the 0.3.4 tarball: 0 errors, 0
  warnings, at most the incoming-feasibility NOTE.
- [ ] G1.2 The tarball contains no dev-only files: no CLAUDE.md, roadmap,
  revision_todo, dogfeed, mas_review, demo directory, or
  mas_full_report.html (`untar -tf` and scan).
- [x] G1.3 649 tests pass on the working tree.
- [ ] G1.4 win-builder R-release returns Status: OK.
- [ ] G1.5 win-builder R-devel returns Status: OK.
- [x] G1.6 NAMESPACE gained only additive exports: 3 S3 plot methods,
  `sframe_plot_validity()`, `sframe_plot_missingness()`.
- [x] G1.7 Hard Imports are still exactly jsonlite, rlang, and openssl.
- [ ] G1.8 A 0.3.3 script with no new arguments produces identical output
  under 0.3.4 (spot check: render_report on the demo without
  interpretations, diff the RQ sections).

---

## Part H — Vignettes (5 items)

```r
browseVignettes("surveyframe")
```

- [ ] H1.1 All 7 vignettes build and open from the installed package.
- [ ] H1.2 The lead vignette's new fig.alt text does not show visibly
  anywhere (alt text only).
- [ ] H1.3 The two rewritten style blocks did not change table styling:
  APA-style rules above and below headers, no shading.
- [ ] H1.4 Spot-read one vignette for the style rules (UK spellings, no
  em-dashes or semicolons, no banned words).
- [ ] H1.5 The flat `browseVignettes()` output (no pkgdown wrapper) is
  presentable.

---

## Part I — Fresh-eyes UX pass (4 items)

- [ ] I1.1 Thirty minutes as a new user: build a 5-question survey with a
  bounded date question in the builder, export it, answer it, and note
  anything confusing.
- [ ] I1.2 Thirty minutes in SurveyStudio: open the demo, run the plan,
  write two interpretations, export the report in the print palette, and
  note anything confusing.
- [ ] I1.3 Read the full generated report top to bottom as if reviewing a
  student's submission.
- [ ] I1.4 Log anything found in dogfeed.todo.md rather than fixing
  inline.

---

## Part J — Effect-size confidence intervals (7 items)

```r
bootstrap_ci(mtcars$mpg, seed = 42)
cohens_d_ci(mtcars$mpg[mtcars$am == 1], mtcars$mpg[mtcars$am == 0], seed = 42)
results <- run_analysis_plan(responses, instr, plots = TRUE)
results[["rq_ttest_ind"]]$apa
```

- [x] J1.1 The four helpers are exported, reproducible with a seed, and
  return `estimate`, `lower`, `upper` with NA bounds on tiny samples.
- [x] J1.2 The 9 affected runners attach their CI key (`d_ci`, `r_ci`,
  `eta_ci`, `ci`, `v_ci`) and the APA string carries the interval.
- [x] J1.3 The Pearson interval is the analytic Fisher z, matching
  `sframe_fisher_z_ci()` exactly.
- [x] J1.4 Degenerate data keeps the pre-0.3.4 APA string with no bracket.
- [ ] J1.5 Read 3 APA strings in a rendered report: the intervals read
  naturally in context and match the reported effect. Judgement call.
- [ ] J1.6 The intervals are statistically sensible on the demo data
  (bracket the estimate, wider at 99 percent than at 95). Spot check one
  by hand.
- [ ] J1.7 Timing: the full demo plan with 34 blocks still runs in
  acceptable time in the studio's Run tab (the bootstraps add work).

## Part K — Psychometric depth (7 items)

- [x] K1.1 `validity_report(items_by_construct = ...)` returns Henseler
  HTMT (symmetric, unit diagonal, NA rows for single-item constructs) and
  `htmt_method = "henseler"`.
- [x] K1.2 Without item data the correlation fallback applies unchanged
  and is labelled `correlation_fallback`.
- [x] K1.3 With naniar installed, `missing_data_report()` returns Little's
  MCAR statistic, df, p value, and a plain interpretation; without
  missingness (or without naniar) the pre-0.3.4 result returns verbatim.
- [x] K1.4 `reliability_report()` sets `omega_note` when omega cannot be
  computed and the reliability chart names those scales in its subtitle.
- [x] K1.5 `efa_solution()` carries `loadings_long`,
  `communalities_table`, and `variance_table`, and the loadings heatmap
  consumes the tidy frame.
- [ ] K1.6 Run `validity_report()` on real scored demo data with
  `items_by_construct` and sanity-check 2 HTMT values against hand
  computation.
- [ ] K1.7 The MCAR interpretation wording reads correctly to a
  methodologist. Judgement call.

## Part L — PDF output and report theming (8 items)

```r
render_report(instr, responses, output_file = "report.pdf", format = "pdf")
```

- [x] L1.1 `format = "pdf"` produces a real PDF through pagedown when
  Chrome is available, and aborts with a typed, actionable error without
  pagedown.
- [x] L1.2 `format = "html"` remains the default and its output is
  unchanged apart from the deliberate theming work below.
- [x] L1.3 The HTML fallback styles sit behind `--sf-*` CSS variables with
  a print stylesheet, tables carry captions and `scope="col"`, and every
  embedded chart has descriptive alt text naming its research question.
- [ ] L1.4 Open the PDF: pagination is clean (no result card or table
  split mid-block, headers repeat on continued tables).
- [ ] L1.5 The PDF is readable in print greyscale when generated with
  `plot_palette = "print"`.
- [ ] L1.6 Print the HTML report from a browser (Ctrl+P): the print
  stylesheet applies (no panel tints, no clipped tables).
- [ ] L1.7 The accessible teal (`--sf-accent`) still reads as brand in the
  HTML report. Judgement call.
- [ ] L1.8 File size of a full demo PDF is reasonable to email (check it
  is under about 10 MB).

## Part M — Codebook upgrades (4 items)

- [x] M1.1 `codebook_report()` returns `plan_table` (id, question, method,
  variables, decision rule) and `models_table` (id, label, type, engine,
  constructs, paths).
- [x] M1.2 Both render in the report codebook section on the Quarto path
  and the HTML fallback.
- [ ] M1.3 Read the codebook of the demo instrument end to end: it now
  fully documents the study (items, choices, scales, plan, models) without
  needing the rest of the report. Judgement call.
- [ ] M1.4 A codebook-only report (`include_analysis = FALSE`, no data)
  still renders the plan summary, since the plan is pre-declared design,
  independent of results.

---

## Sign-off

- [ ] All parts above are complete or their exceptions are recorded.
- [ ] Decision recorded: submit 0.3.4 to CRAN or hold for fixes.

**Reviewer signature:** ______________________ **Date:** ____________
