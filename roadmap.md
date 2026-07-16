# surveyframe roadmap (0.3 through 1.0)

Last updated: 2026-07-14.

This roadmap stages surveyframe from the current CRAN release to v1.0, the
version that anchors the launch of Ethos, Ethos Pro, and the ASRDA textbook.
The canonical schedule and full developer-level detail live in
`portfolio-planner/master_roadmap.md` and its `development_instructions/`
folder. When this file and the portfolio planner disagree, the portfolio planner
is authoritative. Update it first, then this file.

Principles:

- One coherent capability theme per minor version. Each minor has a single
  headline so releases are easy to message and NEWS stays clean. No minor
  carries two unrelated headlines.
- Integrity and provenance are a single contiguous track, not a feature
  sprinkled across releases. Layer 1 (the instrument hash) shipped at v0.3. The
  rest of the chain lands as one block at v0.8 and v0.9, the capstone before
  the v1.0 API freeze. Nothing integrity-related lands in v0.4 through v0.7.
  See "Integrity and provenance: one track" below.
- The 0.3.4 to 0.3.5 visualisation arc runs as two ~30-day patch releases
  between 0.3.3 and 0.4 (the foundation patch merged into 0.3.3 on 2026-07-10,
  and the five remaining patches were consolidated into two releases on
  2026-07-14). Hard Imports stay unchanged; new packages are
  Suggests-only and guarded; every new capability is opt-in; the existing test
  suite is not modified.
- Analytical capability ships first (v0.4 to v0.7) to drive the applied papers
  and adoption. Provenance is the capstone (v0.8 to v0.9) so the v1.0
  integration contract can freeze a complete provenance surface.
- There is no v0.10. The release after v0.9 is v1.0, which merges the former
  integration-and-release-candidate milestone with the AI and agentic layer and
  the launch. v1.0 spans two 45-day cycles.
- New methods land in surveyframe core, not in companion packages. The hard
  dependency footprint stays small; heavy or optional engines are guarded with
  `rlang::check_installed()` and live in Suggests.
- Every version draws on code that already exists in the wider repository set
  where possible, rather than starting cold.
- A growth and citation track runs in parallel with the version track. The two
  reinforce each other: published papers drive adoption, adoption drives
  citations, citations justify the textbook.

This file is a development working note. It is tracked in the private
surveyframe-dev repository and excluded from the public CRAN repository and the
package build.

---

## Release schedule (45-day cycles)

Minors run on a 45-day cadence. The 0.3.4 and 0.3.5 patches run on a ~30-day
cadence, consolidated on 2026-07-14 from the five remaining ~21-day patches so
the arc ends 53 days sooner and every later release pulls earlier by the same
amount. Dates are targets, not contracts. If a release slips, shift the rest by
the slip and record why in `portfolio-planner/decisions.md`.

| Version | Theme | Target |
|---|---|---|
| 0.3.0 | Foundation on CRAN | done 2026-05-21 |
| 0.3.1 | Stability and onboarding | done 2026-06-02 |
| 0.3.2 | Maintenance: CITATION fix, JSS-required package changes, doc pass | 2026-07-04 |
| 0.3.3 | Real-world embedding and conference feedback (AIC-RSAM, ICSRI 2026) plus the visualisation foundation (ggplot2 in Suggests, brand theme, `plots = TRUE`, first family plots, `$table` on inferential runners) and the Theme B survey redesign. Merged from the planned 0.3.3 and 0.3.4 on 2026-07-10 | implemented 2026-07-09, release pending |
| 0.3.4 | All plotting, UI, statistics, and reporting work. The plotting and UI half (visualisation breadth, `plot()` S3 methods, plots into every surface, the builder rework, date bounds, the 2 WCAG 2.2 AA passes) is implemented and committed. The statistics and reporting half joins it by owner decision on 2026-07-17, since 0.3.4 had not been submitted: effect-size confidence intervals (base-R bootstrap `bootstrap_ci`, `cohens_d_ci`, `cramers_v_ci`, `eta_sq_ci`), psychometric depth (Henseler HTMT, real Little's MCAR via naniar, omega and EFA polish), report polish and PDF (`render_report(format = "pdf")` via pagedown, theming, accessibility, codebook upgrades) | 2026-08-15 |
| 0.3.5 | Field validation: ICSRI 2026 audience feedback (conference 8-9 August 2026), additional rounds of human testing with several short real surveys, and the fixes both surface. Strict patch scope, no planned new features. Redefined 2026-07-17 when the former statistics scope moved into 0.3.4 | 2026-09-15 |
| 0.4 | Small-sample inference plus the RStudio add-in | 2026-11-20 |
| 0.4.1 | Faculty demo proofing: demo session to college faculty, then UI/UX and doc fixes | 2026-12-11 |
| 0.5 | MCDM and DEMATEL | 2027-01-25 |
| 0.6 | SEM and PLS execution, invariance | 2027-03-11 |
| 0.7 | Text and open-ended response analysis | 2027-04-25 |
| 0.8 | Provenance part 1: `sf_version`, `sf_review`, `sf_pilot`, response hashing (SHA Layers 2-3) | 2027-06-09 |
| 0.9 | Provenance part 2: `sf_bundle`, `verify_bundle`, manifest, sfReport (SHA Layers 4-5) | 2027-07-24 |
| 1.0 | Integration contract, AI and agentic layer, JASP/jamovi export, API freeze, Merkle root and DOI archival, launch at SaaS parity | 2027-10-22 |

---

## Version track

### v0.3.0 — Foundation (published on CRAN, accepted 2026-05-21)

The typed instrument object and the full design-to-report workflow.

- `sframe` instrument: items, choice sets, scales, branching, attention checks,
  analysis plan, and a model layer.
- Serialisation with SHA-256 integrity checking.
- Deployment: Shiny renderer, embeddable module, static HTML export, builder.
- Collection: CSV import, Google Sheets script generator and reader.
- Analysis: scoring, quality, missingness, descriptives, assumptions, post-hoc,
  reliability, item diagnostics, EFA readiness, validity, sample-size planning,
  and the role-based analysis-plan executor.
- Model syntax planning for EFA, CFA, CB-SEM, and PLS-SEM (syntax only).
- Reporting: codebook, results report, full study report. Response dashboard.

Status: complete and stable.

### v0.3.1 — Stability and onboarding (done 2026-06-02)

Patch release. No new features.

- Six fixes on the static-survey to Google Sheets to R collection loop.
- Serialisation fix for instruments built with named component lists.
- Friendly instrument type-check messages, quieter reliability output, clearer
  empty-plan message.
- Main vignette rewritten as a generic tourism-services worked example.
- Brand system applied.

Status: complete and stable. On CRAN.

### v0.3.2 — Maintenance (target 2026-07-04)

Headline: correct metadata, add JSS-required package changes, and finish the
deferred documentation pass. No new features and no new exports.

- Fix `inst/CITATION`: title to "surveyframe: Survey Instrument Workflows" (drop
  the redundant "for R"), and read the version from `meta$Version` so it never
  goes stale again.
- Add S3 methods (`print`, `format`, `summary`) for all sub-classes: `sf_choices`,
  `sf_item`, `sf_scale`, `sf_branch`, `sf_check`, `sf_model`.
- Move `lavaan` from Imports to Suggests and guard all lavaan-dependent code with
  `requireNamespace("lavaan", quietly = TRUE)`.
- Fix `replicate.R`: add `export_static_survey()` and `render_results()` calls
  wrapped in `if (interactive()) { }`; remove `str()` calls.
- Fix attention check item rendering in the static HTML export.
- Apply the deferred professor-review documentation items (Prof-1 to Prof-5,
  Prof-9, Prof-10): vignette additions only, no code risk.

Status: fully implemented locally (all 7 changes done, 368/368 tests pass).
Awaiting MAS co-review, then R CMD check and CRAN submission.

### v0.3.3 — Real-world embedding and conference feedback (target 2026-07-25)

Headline: harden the package against its first real deployment and conference
presentation feedback.

Evidence sources: the AIC-RSAM room-service AI prototype (a QR-accessed mobile
static HTML survey with eligibility skip logic and a six-construct, nine-path
model) and the ICSRI 2026 presentation at Villa College, 8-9 August 2026. This
prototype is also the dogfooding source for 0.3.3: the real embedding and the
conference feedback drive the fixes. Strict patch scope: no new analytical
features.

Deliverables:
- Mobile static survey hardening: layout, touch targets, progress bar on narrow
  screens.
- Branching and skip-logic fixes surfaced by the room-service embedding.
- Six-construct model syntax correctness checks.
- Report legibility fixes surfaced by the conference presentation.
- UI/UX fixes from the ICSRI presentation audience.
- Google Sheets collection verified end to end. The 0.3.2 SurveyStudio added a
  Google Sheet response-import card and `read_sheet_responses()`, but the live
  round trip (deploy the Apps Script collector, submit responses, read them back
  in the studio and in R) has never been exercised. Deploy the AIC-RSAM survey
  with the collector and confirm it, fixing anything in the Google Sheets path.

Exit criteria: the room-service instrument deploys and collects responses on a
phone without layout or logic errors, including the Google Sheets collector read
back through SurveyStudio and `read_sheet_responses()`. The rendered report is
readable at conference presentation size.

Status: implemented 2026-07-09, tag and release pending. All exit criteria
verified against the live AIC-RSAM deployment (8 real responses read back
through both paths, phone-viewport hardening confirmed by screenshot,
report reviewed at 1280 by 720). The ICSRI audience-feedback deliverable is
excluded from this release by explicit decision (conference is 8-9 August
2026); it lands as a follow-up patch once real feedback exists. On
2026-07-10 the planned 0.3.4 visualisation foundation (see the subsection
below) and the Theme B survey redesign were merged into this release, so
0.3.3 ships all three bodies of work as one version. Full detail in
dogfeed.todo.md. 519/519 tests pass, R CMD check --as-cran clean.

#### Visualisation foundation (merged into v0.3.3 on 2026-07-10, originally the 0.3.4 patch)

Headline: the first plotting layer — opt-in, brand-styled, ggplot2-based.

Patch scope rules apply. Hard Imports unchanged. ggplot2 in Suggests, guarded.

Deliverables:
- Brand theme (`theme_surveyframe()`) built on ggplot2.
- `plots = TRUE` argument on the main analysis runners.
- First family of plots: bar charts for categorical runners, scatter/regression
  overlays for correlation and regression runners.
- `$table` slot added to inferential runners (returns a formatted data frame
  suitable for `knitr::kable()`).

Status: implemented 2026-07-09 and merged into v0.3.3 on 2026-07-10. All four
deliverables done: ggplot2 (>= 3.4.0) in Suggests, `theme_surveyframe()`
exported with a validated fixed-order series palette, `plots = TRUE` on
`run_analysis_plan()`, the first plot family (frequency and chi-square
bars, correlation and regression scatters), and `$table` on the
correlation, regression, t-test, Mann-Whitney, ANOVA, and Kruskal-Wallis
runners. Plots verified visually against the AIC-RSAM simulated data.
519/519 tests pass.

### v0.3.4 — All plotting, UI, statistics, and reporting work (target 2026-08-15)

Consolidated 2026-07-14: this release merges the former 0.3.4 (visualisation
breadth and the builder rework) with the former 0.3.5 (plots into the
surfaces), so all remaining plotting and UI work ships as one ~30-day patch.

**Consolidated again 2026-07-17 (owner decision):** the statistics and
reporting scope below, previously the whole of 0.3.5, moves into this
release, since the plotting and UI half was feature-complete and committed
(main 0ca5d24) with the 0.3.4 CRAN submission not yet made. The tarball
built on 2026-07-17 is superseded and will be rebuilt when the statistics
half lands. 0.3.5 is redefined as the field-validation release. The
plotting and UI deliverables below are all DONE; the statistics and
reporting deliverables (moved in from the old 0.3.5 section) are the
remaining work.

Second track added 2026-07-10 from the 0.3.3 MAS review (owner decision:
quick wins shipped in 0.3.3, the rework lands here): a complete
launch_builder() UI and UX pass benchmarked against LimeSurvey and
Formbricks. Scope: split the Add Question control into four (question-type
dropdown, branching, section break, configuration), restyle the Preview tab
to the Theme B renderer so it matches the exported survey, a WCAG 2.2 pass
across the builder chrome, date-question minimum and maximum bounds, and
the Design improvement arc items already logged in dogfeed.todo.md
(settings entry-point consolidation, Analyse sub-tab rework, header nav
balance).

**2026-07-12**: a WCAG 2.2 AA pass on the vignettes themselves, not just
the exported survey and the builder chrome. The default knitr HTML
vignette output (no pkgdown wrapper) reads as visually flat: a single
black-on-white type scale, no colour or spacing to guide scanning, and
default table/code-block contrast that has not been checked against AA
thresholds. **Partially addressed same day**: the pkgdown site went live
(https://mohammedalisharafuddin.github.io/surveyframe/), so anyone reading
vignettes through the site already gets the branded bslib theme instead of
flat Pandoc output. That build also surfaced and fixed two real bugs (not
cosmetic): building pkgdown from `dev` renders dev-only planning files into
public HTML (pkgdown ignores `.Rbuildignore`; must always build from
`main`), and the deploy workflow's `clean: false` had let
`revision_todo_0.3.md`/`.html`, `roadmap.md`/`.html`, and `todo.md` sit
live on the public `gh-pages` branch since an earlier deploy, surviving
every rebuild since; both fixed. Still open for 0.3.4, scoped as before: a
shared vignette CSS pass checking AA contrast on code blocks, tables, and
body text (not just "on brand"), and heading-structure verification, since
the pkgdown theme fixes the look but was never checked against AA
thresholds specifically. Also raw, non-pkgdown vignette viewing (e.g.
`browseVignettes()` from a local install) still gets the flat default, so
this is not fully closed by the site alone.

Settings-entry-point direction confirmed 2026-07-11: the sidebar's
existing title button, the Welcome/Logo/Thank You setup strip, and any
other survey-settings entry points become ONE obviously-primary sidebar
location. The top bar carries no settings entry points; it is reserved
for future enterprise/academic administrative controls (a separate,
not-yet-scoped feature area). The 0.3.3 quick win already removed the
top-bar Settings button that duplicated the sidebar's; this task is the
full consolidation, not just deduplication.

Headline: coverage across all analysis families, S3 `plot()` on report
objects, plots in every rendering surface, and the builder rework.

Deliverables (visualisation breadth):
- Regression diagnostic plots (residuals, Q-Q, scale-location, leverage).
- EFA scree plot and loadings heatmap.
- Reliability plot (alpha and omega by scale).
- Categorical plots: grouped bar, mosaic.
- Correlation matrix heatmap.
- `plot.quality_report()`, `plot.reliability_report()`, `plot.efa_report()` S3
  methods that dispatch to the family-specific plots.

Deliverables (plots into the surfaces):
- `render_report()` embeds family plots for each section when ggplot2 is present.
- Dashboard chart panels replaced with ggplot2 equivalents.
- SurveyStudio plot area wired to the new S3 methods.

Deliverables (statistics and reporting, moved in from the old 0.3.5 on
2026-07-17; originally the former 0.3.6 to 0.3.8, consolidated 2026-07-14):

Headline: every effect-size statistic ships with an interval, the known
psychometric gaps close, and the report surface is complete with PDF output.

Deliverables (effect-size confidence intervals, base R only):
- `bootstrap_ci()`: percentile bootstrap CI for the median, no new hard dependency.
- `cohens_d_ci()`: Cohen's d interval from the noncentral t distribution.
- `cramers_v_ci()`: Cramer's V interval via bootstrap.
- `eta_sq_ci()`: eta-squared interval from the noncentral F distribution.
- Each inferential runner that returns an effect size now populates a `$ci`
  slot in its result.

Deliverables (psychometric depth):
- Henseler HTMT discriminant validity index added to `validity_report()`.
- Real Little's MCAR test via naniar (in Suggests, guarded).
- Omega polish: `reliability_report(omega = TRUE)` is more robust and prints
  a clearer comparison of alpha and omega.
- EFA polish: parallel analysis displayed alongside VSS in `efa_report()`.

Deliverables (report polish and PDF):
- `render_report(format = "pdf")` via pagedown (in Suggests, guarded).
- APA table theming: consistent horizontal rules, caption placement, and font
  sizing across all report sections.
- Accessibility: colour-blind-safe palette for all ggplot2 outputs.
- Codebook upgrades: item-level descriptives and choice-set frequency tables
  in the codebook section.

### v0.3.5 — Field validation (target 2026-09-15)

Redefined 2026-07-17 (owner decision) when the statistics and reporting
scope moved into 0.3.4. This release validates the merged 0.3.4 against
real use. Strict patch scope, no planned new features: fixes and polish
only, driven by what the field surfaces.

Deliverables:
- ICSRI 2026 audience feedback (conference 8-9 August 2026): triage every
  item, fix what is in patch scope, log the rest against roadmap versions.
- Additional rounds of human testing: design, deploy, answer, and analyse
  several short real surveys end to end (owner plus recruited testers),
  logging findings in dogfeed.todo.md as they come in.
- Fixes for everything the two feedback streams surface that fits patch
  scope.

Four sf_choices proposals, assessed against the pre-declared-contract core
idea (full assessment in mas_review_033.md):

- `missing_codes` on `sf_choices()` (declare 99 = prefer not to say so
  scoring and reliability skip it): strongest fit, lands in v0.4.
- `sf_conjoint_design()` for discrete choice experiments: good fit, lands
  in v0.5 with the decision methods.
- Cascading/hierarchical choice sets: admissible if declared statically;
  needs a design document first, v0.6 or later.
- Runtime label piping (glue-style tokens): in tension with the immutable
  hashed-instrument guarantee; recorded as a research question only.

### v0.4 — Small-sample inference plus the RStudio add-in (target 2026-11-20)

Headline: trustworthy analysis when n is below thirty, plus an IDE surface.

Source: the practical method-selection logic and test helpers validated in the
`small-sample-survey-framework`. The simulation engine stays in that repository
behind its own methods paper; surveyframe ships the helpers.

Deliverables (analysis):
- Hodges-Lehmann location-shift estimate and CI on the Mann-Whitney runner.
- Pseudomedian CI on the paired Wilcoxon runner.
- Exact path and odds-ratio CI on the 2x2 Fisher runner.
- Firth-penalised logistic regression runner (logistf in Suggests, guarded).
- A small-sample advisory in `sample_size_plan()` and `assumption_report()`.
- Vignette: small-sample survey analysis.

Deliverables (RStudio add-in):
- Thin wrapper over the launchers plus an insert-sframe-skeleton helper.
- `rstudioapi` in Suggests (already guarded in code, exempt from the
  one-theme-per-minor rule and off the critical path).
- Released to GitHub from the dev branch immediately; released to CRAN with 0.4.
- `inst/rstudio/addins.dcf` and a small R file.

Exit criteria: a study with n < 30 can run the plan and receive method-choice
guidance plus a small-sample-appropriate result with interval coverage notes.
The RStudio add-in installs and registers correctly on CRAN.

### v0.4.1 — Faculty demo proofing (target 2026-12-11)

Headline: a live demo session to college faculty, then UI/UX and documentation
fixes based on that session's feedback.

This patch applies real-world adoption feedback from faculty who are not
package authors. Strict patch scope: no new analytical features or exports.
The faculty demo is the proofing mechanism, not a deliverable.

### v0.5 — MCDM and DEMATEL (target 2027-01-25)

Headline: bring multi-criteria decision making into the survey workflow.

Source: port the registry and method implementations from the `mcdm` repository
(TOPSIS, VIKOR, AHP, ANP, MOORA, PROMETHEE, ELECTRE, SMART, WASPAS, DEMATEL),
adapted to the sframe analysis-plan contract.

Deliverables:
- New item types for pairwise comparison and criteria-weight input.
- MCDM method runners registered in `run_analysis_plan()` under a `decision`
  family, each returning a ranking, a diagnostic, an APA-style summary, a
  writing prompt, and the method citation.
- AHP consistency-ratio checks and DEMATEL thresholding with cause-effect
  classification.
- Weight-sensitivity analysis as an optional reporting block.
- Vignette: a decision-analysis worked example.

Exit criteria: an instrument can declare an MCDM research question, collect the
matrix data, and run the plan to a ranked result with a defensible report
section. No new hard dependencies.

### v0.6 — Structural model execution (target 2027-03-11)

Headline: move from syntax generation to fitted models, and connect screening.

Deliverables:
- Optional execution backends for CFA and CB-SEM via lavaan, and PLS-SEM via
  seminr, all guarded behind Suggests. Syntax generation remains the default
  zero-dependency path.
- Measurement-invariance planning and testing across groups.
- Higher-order constructs in the model layer.
- A bridge to `semScreenR`: `run_analysis_plan()` routes CFA/SEM data through
  semScreenR screening before fitting. semScreenR stays a separate package.
- Common-method-variance diagnostics.
- Vignette: a full measurement-model workflow from instrument to fitted model.

Exit criteria: an sframe measurement model can be screened, fitted, and reported
end to end, with invariance results, using optional packages.

### v0.7 — Text and open-ended response analysis (target 2027-04-25)

Headline: structured analysis of open-ended and free-text survey responses.

Source: the thematic-analysis approach from the Omani gateways manuscript
(tidytext, quanteda, stm). The `text` and `textarea` item types ship from v0.3;
this version adds the analysis side.

Deliverables:
- Text cleaning and normalisation for open-ended responses.
- A `text` family in `run_analysis_plan()`: term frequency, co-occurrence, and
  optional dictionary-based sentiment.
- Thematic and topic support: term-frequency themes and optional structural topic
  models, with representative quote extraction.
- Optional tidytext, quanteda, and stm backends (Suggests, guarded).
- Vignette: analysing open-ended responses end to end.

Exit criteria: an instrument with open-ended items can declare a text research
question, run the plan, and receive term frequencies, themes, representative
quotes, and a defensible report section. No new hard dependency.

### v0.8 — Provenance layer, part one (target 2027-06-09)

Headline: give the instrument a lifecycle and a review trail.

Source: absorb the versioning, review, and pilot modules from the `asrda-r`
prototype. `asrda-r` does not ship as a dependency.

Delivers SHA integrity Layers 2 and 3 (see table below).

Deliverables:
- `sf_version()`: content-hash version identifier and lifecycle transitions
  (draft, reviewed, pilot, published, archived).
- `sf_review()`: peer-review artefact (reviewers, item-level flags, resolution
  notes, status).
- `sf_pilot()`: pilot-study artefact (n, completion notes, per-item flags,
  quality and reliability summaries).
- Response-level hashing in `read_responses()`: per-row and aggregate hash.
- Vignette: instrument lifecycle and review.

Exit criteria: an instrument can carry a versioned history with review and pilot
evidence that survives save and reload, and a response file is bound to the
instrument version by an aggregate hash.

### v0.9 — Provenance layer, part two, and reporting (target 2027-07-24)

Headline: tamper-evident bundles and a Quarto-native report.

Delivers SHA integrity Layers 4 and 5. The five-layer chain is complete.

Deliverables:
- `sf_bundle()` and `verify_bundle()`: wrap a versioned instrument, its review
  and pilot artefacts, and the response data into a single bundle with SHA-256
  verification across all components.
- sfReport companion package: `sf_report()` produces a full Quarto document with
  results, charts, codebook, bibliography, and a defensibility appendix.
- ASRDA textbook citation linkage: `sf_report()` accepts an `asrda_chapters`
  argument and emits a machine-readable citation block.
- Vignette: defensible reporting for ethics submission and secondary analysis.

Exit criteria: a study can produce a single verifiable bundle and a Quarto
report that cites the instrument version and the textbook chapter behind each
method.

### v1.0 — Integration, AI layer, and launch (target 2027-10-22)

Headline: the version that the products and textbook are built on, at
commercial-SaaS feature parity. This release merges the former
integration-and-release-candidate milestone with the AI and agentic layer and
the launch. It spans two 45-day cycles.

Deliverables (integration and surfaces):
- Stable, documented integration contract for Ethos and Ethos Pro.
- Complex survey-design weighting (design weights, calibration).
- JASP and jamovi friendly exports.
- Visual branching preview, dashboard filters, interactive assumption plots.
- Full documentation pass, pkgdown hero, SurveyBuilder topbar branding.
- Release-candidate checks across Windows, macOS, and two Linux builds.

Deliverables (AI and agentic layer):
- sframe JSON Schema and a surveyframe MCP server exposing the safe verbs
  (`create_instrument`, `validate_sframe`, `score_scales`, `run_analysis_plan`,
  `render_report`, `verify_bundle`).
- AI-assisted instrument authoring: an agent drafts constructs, items, scales,
  and an analysis plan that surveyframe validates against the schema before a
  human approves.
- AI narrative generation: writes interpretation only for the tests the
  pre-declared plan contains (no p-hacking by design).
- AI-disclosure provenance ledger inside `sf_bundle`: records what was
  AI-generated versus human-authored, the model and version, and a prompt hash.
- A governed agentic execution loop through the Ethos approval gates.
- Model layer standardises on Claude through tool use and MCP.

Deliverables (provenance parity):
- Merkle-root extension on top of the v0.9 manifest.
- DOI-linked archival deposit.
- API declared stable; semantic-versioning guarantees begin.
- `inst/CITATION` updated to point to the published JSS paper.

Coincides with: Ethos public launch, Ethos Pro institutional launch, and the
ASRDA textbook complete edition.

Exit criteria: a researcher, an institution, and a textbook reader can each rely
on surveyframe 1.0 as a stable foundation, and the provenance surface matches
the commercial SaaS bar that the products are sold against.

---

## Integrity and provenance: one track

No integrity work ships in v0.3.4 through v0.7. Layers 2 to 5 land together at
v0.8 and v0.9. The SSR 6.0 paper is submitted after the v0.9 CRAN release
(now 2027-07-24, so around 2027 Q3) so it describes a shipped five-layer
framework rather than a proposal.

| SSR 6.0 layer | What ships | surveyframe version |
|---|---|---|
| 1 Instrument | SHA-256 over the `.sframe` payload; `write_sframe()`, `read_sframe()`, `validate_sframe()` | 0.3.0 (shipped) |
| 2 Pre-registration and version | `sf_version()` content-hash version chain and lifecycle states | 0.8 |
| 3 Response | per-row and aggregate response hash in `read_responses()` | 0.8 |
| 4 Analysis and reporting | analysis and report hashing, `sf_report()` provenance appendix | 0.9 |
| 5 Verification manifest | `sf_bundle()` and `verify_bundle()` chained cross-component manifest (Merkle-style, not sorted-then-concatenated as of 2026-07-14; see portfolio-planner `07_v08_v09_implementation.md`) | 0.9 |

---

## Textbook chapter to version map

The ASRDA textbook is released in stages pinned to the surveyframe version that
makes the tooling real.

| Stage | surveyframe | Textbook chapters made real |
|---|---|---|
| 1 | 0.3 to 0.4 | Parts I to III (foundations, instrument design, sampling, data capture and quality), Part IV ch 9 (reliability), Part V (descriptives, assumptions), Part VI ch 13 to 16 (correlation, parametric and non-parametric comparisons, agreement). Part VI non-parametric and Part XIII ch 37 resampling draw on the v0.4 small-sample helpers. |
| 2 | 0.5 to 0.7 | Part XII ch 34 to 35 (MCDM, fuzzy and hybrid) on v0.5; Part IV ch 10 (validity and invariance) and Part IX ch 26 to 27 (factor, confirmatory and structural models) on v0.6; Part III ch 8 (text data processing and open-ended responses) and Part VII ch 17 (text visualisation) on v0.7. |
| 3 | 0.8 to 0.9 | Part VII ch 18 (automated reporting), Part XIV ch 39 to 40 (workflow automation and open science, data management and DOI registration). |
| 4 | 1.0 | Part XI ch 33 (survey weighting and variance estimation). Complete edition published at v1.0 with the JSS-paper citation. |

Note: Part III ch 8 (text) sits early in the book but its surveyframe tooling
lands at v0.7, so the chapter is written in Stage 2 even though its part is in
the Stage 1 range.

Parked beyond v1.0: Part VIII ch 21 to 25 (multilevel, causal and longitudinal,
survival, time series), Part X (spatial, network, conjoint and choice), Part XI
ch 32 (machine learning), Part XIII ch 36 (IRT) and ch 38 (meta-analysis).

---

## Methodology paper per release

| surveyframe | Methodology paper |
|---|---|
| 0.3 | JSS software paper (OJS 6454, submitted 2026-06-02; returned without full review 2026-06; revise and resubmit). Plus the v0.3 design paper (not yet started). |
| 0.3.4 to 0.3.5 | No separate paper. The visualisation arc is patch work. Plots feed figures in every later methodology paper and in ASRDA ch 17. |
| 0.4 | Small-sample survey inference paper (smallsamplelab), draft exists. |
| 0.5 | MCDM and DEMATEL methodology paper, not started. |
| 0.6 | semScreenR package and SEM-screening methodology paper, not started. |
| 0.7 | Text and open-ended analysis methodology paper, not started. |
| 0.8 and 0.9 | Covered by three papers, in submission order: SSR 6.0 (proof-of-integrity, submitted post-0.9, unchanged as of the 2026-07-14 scope decision), then MethodsX (sframe-schema standard, standalone repo `sframe-schema`), then JOI (informetrics framing of the Derivative Citation Model). MethodsX and JOI added 2026-07-14; both cite SSR 6.0 rather than duplicating it. |
| 1.0 | AI and agentic layer methodology paper, not started. |

---

## Growth and citation track (parallel)

### 1. JSS paper — surveyframe (highest priority)

- Journal of Statistical Software. Manuscript at `jss-paper/surveyframe.Rnw`.
- Positions surveyframe as a proactive workflow: the instrument is a
  methodological contract declared before data collection, so analysis is the
  execution of a pre-declared plan rather than a post-hoc search.
- Submitted 2026-06-02 (OJS 6454). Returned without full review 2026-06;
  invited to revise and resubmit.
- Package changes required by the editor ship with 0.3.2. Manuscript revision
  (stronger JSS venue-fit argument, sframe design and extensibility section,
  functionality table, worked example opening, shorter code chunks) follows.
- After acceptance: add `inst/CITATION` pointing to the JSS DOI.
- This is the anchor citation for the whole ecosystem.

### 2. Methodological paper based on v0.3

- Subject: the analysis-plan-in-the-instrument design as software-enforced
  pre-registration for survey research.
- Target: a quantitative-methods or research-methods outlet.
- Draft and preprint by 0.4.

### 3. semScreenR — CRAN release and methods paper

- Ship `semScreenR` to CRAN close to the 0.6 release. Fix the `triage_apply`
  defect first (returns neither the screened model nor pruned data).
- A methods paper on rule-based, cross-validated SEM data screening.

### 4. Small-sample methods paper

- Based on the `small-sample-survey-framework` simulation study.
- The published paper justifies the helpers shipped in v0.4.
- Proofread, post a preprint DOI, then submit. Preprint DOI must land by 0.4.

### 5. ASRDA textbook — staged with surveyframe progress

- "From Constructs to Conclusions Using R." Quarto book.
- Released in stages that track surveyframe capability.
- Gated on the JSS paper being accepted so it can cite a peer-reviewed reference.
- At v1.0 the textbook is retitled to reflect SSR 6.0, agentic AI, and the
  surveyframe unique selling point.

### Adoption surface (continuous)

- Applied papers: maritime research set (JMR), Maldives cross-border e-commerce
  PLS-SEM (cbec-maldives-smes), and the logistics-trade island-economies study
  (ILPTFIE). Each cites surveyframe and, once published, the JSS paper.
- pkgdown gallery of worked instruments across domains.
- CRAN task views: listed in Psychometrics. Re-approach OfficialStatistics if
  v0.9 ships complex-survey weighting.
- Short course and workshop materials under CC BY.

---

## Product launch dependency (why 1.0 is the gate)

- **Ethos** and **Ethos Pro** treat surveyframe as the source-of-truth engine.
  They need the frozen integration contract and the provenance layer. They launch
  at surveyframe 1.0 (2027-10-22).
- **ASRDA textbook** complete edition matches v1.0 capability and cites the JSS
  paper.
- The Ethos build train runs one cycle behind surveyframe. Each Ethos milestone
  depends on the matching surveyframe release landing first.

---

## Out of scope through v1.0 (parked)

- Longitudinal panel support across waves.
- Adaptive testing with IRT-driven item selection.
- Differential-privacy noise injection for anonymised export.
- A centralised multi-site response aggregation service.
- Automated translation tooling for multilingual instruments.
- An Item Response Theory layer (candidate for a post-1.0 companion).
