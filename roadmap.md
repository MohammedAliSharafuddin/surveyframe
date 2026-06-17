# surveyframe roadmap (0.3 through 1.0)

Last updated: 2026-06-13.

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
- The 0.3.4 to 0.3.9 visualisation arc runs on a strict ~21-day patch cadence
  between 0.3.3 and 0.4. Hard Imports stay unchanged; new packages are
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

Minors run on a 45-day cadence. The 0.3.3 to 0.3.9 patches run on a ~21-day
cadence. Dates are targets, not contracts, anchored to the 0.3.2 ship date
(2026-07-04). If a release slips, shift the rest by the slip and record why in
`portfolio-planner/decisions.md`.

| Version | Theme | Target |
|---|---|---|
| 0.3.0 | Foundation on CRAN | done 2026-05-21 |
| 0.3.1 | Stability and onboarding | done 2026-06-02 |
| 0.3.2 | Maintenance: CITATION fix, JSS-required package changes, doc pass | 2026-07-04 |
| 0.3.3 | Real-world embedding and conference feedback (AIC-RSAM, ICSRI 2026) | 2026-07-25 |
| 0.3.4 | Visualisation foundation: ggplot2 in Suggests, brand theme, `plots = TRUE`, first family plots, `$table` on inferential runners | 2026-08-15 |
| 0.3.5 | Visualisation breadth: regression, EFA, reliability, categorical, correlation-matrix plots; `plot()` S3 on report objects | 2026-09-05 |
| 0.3.6 | Plots into the surfaces: `render_report()`, dashboard charts, studio plot area | 2026-09-26 |
| 0.3.7 | Effect-size confidence intervals: base-R bootstrap (`bootstrap_ci`, `cohens_d_ci`, `cramers_v_ci`, `eta_sq_ci`) | 2026-10-17 |
| 0.3.8 | Psychometric depth: Henseler HTMT, real Little's MCAR via naniar, omega and EFA polish | 2026-11-07 |
| 0.3.9 | Report polish and PDF: `render_report(format = "pdf")` via pagedown, theming, accessibility, codebook upgrades | 2026-11-28 |
| 0.4 | Small-sample inference plus the RStudio add-in | 2027-01-12 |
| 0.4.1 | Faculty demo proofing: demo session to college faculty, then UI/UX and doc fixes | 2027-02-02 |
| 0.5 | MCDM and DEMATEL | 2027-03-19 |
| 0.6 | SEM and PLS execution, invariance | 2027-05-03 |
| 0.7 | Text and open-ended response analysis | 2027-06-17 |
| 0.8 | Provenance part 1: `sf_version`, `sf_review`, `sf_pilot`, response hashing (SHA Layers 2-3) | 2027-08-01 |
| 0.9 | Provenance part 2: `sf_bundle`, `verify_bundle`, manifest, sfReport (SHA Layers 4-5) | 2027-09-15 |
| 1.0 | Integration contract, AI and agentic layer, JASP/jamovi export, API freeze, Merkle root and DOI archival, launch at SaaS parity | 2027-12-14 |

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

### v0.3.4 — Visualisation foundation (target 2026-08-15)

Headline: the first plotting layer — opt-in, brand-styled, ggplot2-based.

Patch scope rules apply. Hard Imports unchanged. ggplot2 in Suggests, guarded.

Deliverables:
- Brand theme (`theme_surveyframe()`) built on ggplot2.
- `plots = TRUE` argument on the main analysis runners.
- First family of plots: bar charts for categorical runners, scatter/regression
  overlays for correlation and regression runners.
- `$table` slot added to inferential runners (returns a formatted data frame
  suitable for `knitr::kable()`).

### v0.3.5 — Visualisation breadth (target 2026-09-05)

Headline: coverage across all analysis families and S3 `plot()` on report objects.

Deliverables:
- Regression diagnostic plots (residuals, Q-Q, scale-location, leverage).
- EFA scree plot and loadings heatmap.
- Reliability plot (alpha and omega by scale).
- Categorical plots: grouped bar, mosaic.
- Correlation matrix heatmap.
- `plot.quality_report()`, `plot.reliability_report()`, `plot.efa_report()` S3
  methods that dispatch to the family-specific plots.

### v0.3.6 — Plots into the surfaces (target 2026-09-26)

Headline: plots appear automatically in all rendering surfaces.

Deliverables:
- `render_report()` embeds family plots for each section when ggplot2 is present.
- Dashboard chart panels replaced with ggplot2 equivalents.
- SurveyStudio plot area wired to the new S3 methods.

### v0.3.7 — Effect-size confidence intervals (target 2026-10-17)

Headline: every effect-size statistic ships with an interval, base R only.

Deliverables:
- `bootstrap_ci()`: percentile bootstrap CI for the median, no new hard dependency.
- `cohens_d_ci()`: Cohen's d interval from the noncentral t distribution.
- `cramers_v_ci()`: Cramer's V interval via bootstrap.
- `eta_sq_ci()`: eta-squared interval from the noncentral F distribution.
- Each inferential runner that returns an effect size now populates a `$ci`
  slot in its result.

### v0.3.8 — Psychometric depth (target 2026-11-07)

Headline: HTMT, real MCAR testing, and omega polish.

Deliverables:
- Henseler HTMT discriminant validity index added to `validity_report()`.
- Real Little's MCAR test via naniar (in Suggests, guarded).
- Omega polish: `reliability_report(omega = TRUE)` is more robust and prints
  a clearer comparison of alpha and omega.
- EFA polish: parallel analysis displayed alongside VSS in `efa_report()`.

### v0.3.9 — Report polish and PDF (target 2026-11-28)

Headline: the last patch before the analytical themes. The report surface is
complete and PDF output is available.

Deliverables:
- `render_report(format = "pdf")` via pagedown (in Suggests, guarded).
- APA table theming: consistent horizontal rules, caption placement, and font
  sizing across all report sections.
- Accessibility: colour-blind-safe palette for all ggplot2 outputs.
- Codebook upgrades: item-level descriptives and choice-set frequency tables
  in the codebook section.

### v0.4 — Small-sample inference plus the RStudio add-in (target 2027-01-12)

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

### v0.4.1 — Faculty demo proofing (target 2027-02-02)

Headline: a live demo session to college faculty, then UI/UX and documentation
fixes based on that session's feedback.

This patch applies real-world adoption feedback from faculty who are not
package authors. Strict patch scope: no new analytical features or exports.
The faculty demo is the proofing mechanism, not a deliverable.

### v0.5 — MCDM and DEMATEL (target 2027-03-19)

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

### v0.6 — Structural model execution (target 2027-05-03)

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

### v0.7 — Text and open-ended response analysis (target 2027-06-17)

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

### v0.8 — Provenance layer, part one (target 2027-08-01)

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

### v0.9 — Provenance layer, part two, and reporting (target 2027-09-15)

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

### v1.0 — Integration, AI layer, and launch (target 2027-12-14)

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
(around 2027 Q1 to Q2) so it describes a shipped five-layer framework rather
than a proposal.

| SSR 6.0 layer | What ships | surveyframe version |
|---|---|---|
| 1 Instrument | SHA-256 over the `.sframe` payload; `write_sframe()`, `read_sframe()`, `validate_sframe()` | 0.3.0 (shipped) |
| 2 Pre-registration and version | `sf_version()` content-hash version chain and lifecycle states | 0.8 |
| 3 Response | per-row and aggregate response hash in `read_responses()` | 0.8 |
| 4 Analysis and reporting | analysis and report hashing, `sf_report()` provenance appendix | 0.9 |
| 5 Verification manifest | `sf_bundle()` and `verify_bundle()` cross-component manifest | 0.9 |

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
| 0.3.4 to 0.3.9 | No separate paper. The visualisation arc is patch work. Plots feed figures in every later methodology paper and in ASRDA ch 17. |
| 0.4 | Small-sample survey inference paper (smallsamplelab), draft exists. |
| 0.5 | MCDM and DEMATEL methodology paper, not started. |
| 0.6 | semScreenR package and SEM-screening methodology paper, not started. |
| 0.7 | Text and open-ended analysis methodology paper, not started. |
| 0.8 and 0.9 | Covered by the SSR 6.0 proof-of-integrity paper (submitted post-0.9). |
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
  at surveyframe 1.0 (2027-12-14).
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
