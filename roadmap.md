# surveyframe roadmap (0.3 through 1.0)

Last updated: 2026-06-04.

This roadmap stages surveyframe from the current CRAN release to v1.0.0, the
version that anchors the launch of Ethos, Ethos Pro, and the ASRDA textbook.

Principles:

- One coherent capability theme per minor version. Each minor has a single
  headline so releases are easy to message and NEWS stays clean. No minor
  carries two unrelated headlines.
- Integrity and provenance are a single contiguous track, not a feature
  sprinkled across releases. Layer 1 (the instrument hash) shipped at v0.3. The
  rest of the chain (response hashing, versioning, review, pilot, bundle,
  verify, manifest, and the report) lands as one block at v0.7 and v0.8, the
  capstone before the v0.9 API freeze. Nothing integrity-related lands in v0.4,
  v0.5, or v0.6. See "Integrity and provenance: one track" below.
- Analytical capability ships first (v0.4 to v0.6) to drive the applied papers
  and adoption. Provenance is the capstone (v0.7 to v0.8) so the v0.9 integration
  contract can freeze a complete provenance surface.
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

### v0.3.1 — Stability and onboarding (in progress)

Patch release. No new features.

- Six fixes on the static-survey to Google Sheets to R collection loop.
- Serialisation fix for instruments built with named component lists.
- Friendly instrument type-check messages, quieter reliability output, clearer
  empty-plan message.
- Main vignette rewritten as a generic tourism-services worked example adopting
  the questionnaire from Sharafuddin, Madhavan & Wangtueai (2024).
- Brand system applied.

Open before submission: full `R CMD check --as-cran`, win-builder, second
platform, Codecov badge decision, cran-comments update.

### v0.3.2 — Maintenance (patch)

Headline: correct metadata and finish the deferred documentation pass. No new
features and no new exports.

- Fix `inst/CITATION`: title to "surveyframe: Survey Instrument Workflows" (drop
  the redundant "for R"), and read the version from `meta$Version` so it never
  goes stale again. Detail in `revision_todo_0.3.md` (v0.3.2 section). This is
  the trigger for cutting 0.3.2, because the CRAN page citation only refreshes on
  a new release.
- Apply the deferred professor-review documentation items (Prof-1 to Prof-5,
  Prof-9, Prof-10): vignette additions only, no code risk.
- Optional: guard the launcher `\donttest` examples so a check that runs
  donttest does not hang.

Exit criteria: clean `R CMD check`, the CRAN package-page citation is correct,
and the version note in the citation is self-updating.

### v0.4.0 — Small-sample inference

Headline: trustworthy analysis when n is below thirty. Ships first among the
analytical themes because it supports the small-sample methods paper and any
near-term low-n applied study, and adds no new hard dependency.

Source: the practical method-selection logic and test helpers validated in the
`small-sample-survey-framework`. The simulation engine that justifies them stays
in that repository behind its own methods paper; surveyframe ships the helpers.

Deliverables (tools confirmed from the smallsamplelab book, R/smalln_recipes.R):

- Hodges-Lehmann location-shift estimate and confidence interval added to the
  Mann-Whitney runner (from `mw_test`).
- Pseudomedian (Hodges-Lehmann) confidence interval added to the paired
  Wilcoxon runner (from `wilcoxon_paired_ci`).
- Exact path and odds-ratio confidence interval surfaced on the 2x2 Fisher
  runner (from `exact_2x2`).
- Percentile bootstrap confidence interval helper for the median, base R, no
  new hard dependency (from `boot_median_ci`).
- Firth-penalised logistic regression runner for separation and very small n,
  guarded behind logistf in Suggests (from `firth_logit_fit`).
- Effect-size confidence intervals for the standard hypothesis tests.
- A small-sample advisory in `sample_size_plan()` and in `assumption_report()`
  that flags when asymptotic methods are unsafe and points to the alternative.
- Vignette: small-sample survey analysis, mirroring the decision framework.

The simulation engine that validates these choices stays in the
small-sample-survey-framework repository, behind the small-sample methods paper.
The smallsamplelab book CLAUDE.md carries the full integration plan and the
Part C chapter mapping.

Exit criteria: a study with n < 30 can run the plan and receive method-choice
guidance plus a small-sample-appropriate result with interval coverage notes.

### v0.5.0 — Decision methods (MCDM and DEMATEL)

Headline: bring multi-criteria decision making into the survey workflow.

Source: port the registry and method implementations from the existing `mcdm`
repository (TOPSIS, VIKOR, AHP, ANP, MOORA, PROMETHEE, ELECTRE, SMART, WASPAS,
DEMATEL), adapted to the sframe analysis-plan contract.

Deliverables:

- New item types for pairwise comparison and criteria-weight input, rendered by
  the builder, the Shiny renderer, and the static export.
- MCDM method runners registered in `run_analysis_plan()` under a `decision`
  family, each returning a ranking, the method's diagnostic, an APA-style
  summary, a writing prompt, and the method citation.
- AHP consistency-ratio checks and DEMATEL thresholding with a cause-effect
  classification table.
- Weight-sensitivity analysis as an optional reporting block.
- Vignette: a decision-analysis worked example.

Exit criteria: an instrument can declare an MCDM research question, collect the
matrix data, and run the plan to a ranked result with a defensible report
section. No new hard dependencies.

### v0.6.0 — Structural model execution

Headline: move from syntax generation to fitted models, and connect screening.

Deliverables:

- Optional execution backends for CFA and CB-SEM via lavaan, and PLS-SEM via
  seminr, all guarded behind Suggests. Syntax generation remains the default
  zero-dependency path.
- Measurement-invariance planning and testing across groups (configural,
  metric, scalar).
- Higher-order constructs in the model layer.
- A bridge to `semScreenR`: `run_analysis_plan()` can route CFA/SEM data through
  semScreenR screening before fitting, preserving the audit trail. semScreenR
  stays a separate package; surveyframe calls it when present.
- Common-method-variance diagnostics.
- Vignette: a full measurement-model workflow from instrument to fitted model.

Exit criteria: an sframe measurement model can be screened, fitted, and reported
end to end, with invariance results, using optional packages.

### v0.7.0 — Provenance layer, part one

Headline: give the instrument a lifecycle and a review trail.

Source: absorb the versioning, review, and pilot modules from the `asrda-r`
prototype directly into surveyframe. `asrda-r` does not ship as a dependency.

Deliverables:

- `sf_version()`: attach a content-hash version identifier and record lifecycle
  transitions (draft, reviewed, pilot, published, archived). Store the version
  chain as an attribute on the sframe.
- `sf_review()`: create and attach a peer-review artefact (reviewers, item-level
  flags, resolution notes, status).
- `sf_pilot()`: create and attach a pilot-study artefact (n, completion notes,
  per-item flags, quality and reliability summaries).
- Response-level hashing in `read_responses()`: a per-row hash computed from the
  row contents and the instrument hash, plus an aggregate response hash, so any
  row modification, addition, or deletion is detectable.
- Validation extended to check version chains and artefact integrity.
- Vignette: instrument lifecycle and review.

Delivers the integrity track: SSR 6.0 Layer 2 (pre-registration and version) and
Layer 3 (response). Source modules already exist in `asrda-r`
(`instrument_versioning.R`, `expert_review.R`, `pilot_summary.R`).

Exit criteria: an instrument can carry a versioned history with review and pilot
evidence that survives save and reload, and a response file is bound to the
instrument version by an aggregate hash.

### v0.8.0 — Provenance layer, part two, and reporting

Headline: tamper-evident bundles and a Quarto-native report.

Deliverables:

- `sf_bundle()` and `verify_bundle()`: wrap a versioned instrument, its review
  and pilot artefacts, and the response data into a single bundle with SHA-256
  verification across all components. The bundle emits a verification manifest
  that records every component hash, timestamps, and a manifest root hash.
- sfReport companion package (separate CRAN package importing surveyframe):
  `sf_report()` produces a full Quarto document with analysis results, charts,
  codebook, and bibliography, plus a defensibility appendix that reproduces the
  review and pilot evidence and the lifecycle history.
- ASRDA textbook citation linkage: `sf_report()` accepts an `asrda_chapters`
  argument that inserts formatted references to the relevant textbook chapters,
  and emits a machine-readable citation block (instrument version hash, software
  version, textbook references) in the report metadata and a BibTeX appendix.
- Vignette: defensible reporting for ethics submission and secondary analysis.

Delivers the integrity track: SSR 6.0 Layer 4 (analysis and reporting) and Layer
5 (verification manifest). The five-layer chain is complete at this point. Source
modules already exist in `asrda-r` (`response_bundle.R`, `citation_block.R`,
`report_render.R`). This is the release the SSR 6.0 paper should cite for Layers
2 to 5, not v0.4 to v0.5.

Exit criteria: a study can produce a single verifiable bundle and a Quarto
report that cites the instrument version and the textbook chapter behind each
method.

### v0.9.0 — Integration and release candidate

Headline: the surfaces Ethos and Ethos Pro depend on, hardened.

Deliverables:

- Stable, documented integration contract for Ethos and Ethos Pro to call
  surveyframe as the analysis and provenance engine. Locked argument and return
  shapes for the functions those products use.
- Complex survey-design weighting (design weights, calibration). If delivered,
  re-approach the OfficialStatistics CRAN task view with a clear use case.
- JASP and jamovi friendly exports.
- Visual branching preview, dashboard filters, interactive assumption plots.
- Full documentation pass, pkgdown hero, SurveyBuilder topbar branding.
- Release-candidate checks across Windows, macOS, and two Linux builds.

Exit criteria: Ethos and Ethos Pro can be built against a frozen surveyframe
API. No open defects on the core workflow.

### v1.0.0 — Launch

Headline: the version that the products and the textbook are built on, at
commercial-SaaS feature parity.

- Provenance layer complete and documented.
- Merkle-root extension and DOI-linked archival deposit added on top of the v0.8
  manifest. These are the v1.0 additions that bring the provenance surface to
  parity with commercial SaaS offerings, so the Ethos, Ethos Pro, and textbook
  launch is competitive.
- API declared stable; semantic-versioning guarantees begin.
- `inst/CITATION` points to the published JSS paper.
- Coincides with: Ethos public launch, Ethos Pro institutional launch, and the
  ASRDA textbook complete edition.
- A migration and stability guide for downstream users.

Exit criteria: a researcher, an institution, and a textbook reader can each rely
on surveyframe 1.0 as a stable foundation, and the provenance surface matches
the commercial SaaS bar that the products are sold against.

---

## Integrity and provenance: one track

This is the table that keeps the integrity story consistent. The five-layer
chain from the SSR 6.0 paper maps onto exactly two releases (plus the Layer 1
foundation already on CRAN). It is not spread across v0.4 to v0.6.

| SSR 6.0 layer | What ships | surveyframe version |
|---|---|---|
| 1 Instrument | SHA-256 over the `.sframe` payload; `write_sframe()`, `read_sframe()`, `validate_sframe()` | 0.3.0 (shipped) |
| 2 Pre-registration and version | `sf_version()` content-hash version chain and lifecycle states | 0.7.0 |
| 3 Response | per-row and aggregate response hash in `read_responses()` | 0.7.0 |
| 4 Analysis and reporting | analysis and report hashing, `sf_report()` provenance appendix | 0.8.0 |
| 5 Verification manifest | `sf_bundle()` and `verify_bundle()` cross-component manifest | 0.8.0 |

Implications for consistency:

- The SSR 6.0 manuscript cites v0.7 to v0.8 for Layers 2 to 5. Its submission is
  moved to after the v0.9 CRAN release (the WIN 6.0 2026 route is dropped), so at
  submission the five-layer framework is implemented and released rather than
  proposed, with the Merkle-root and DOI-archival work (v1.0) as the future
  direction. The manuscript is rewritten at submission time, not now.
- The Merkle-root extension and DOI-linked archival deposit are v1.0 features
  (SaaS parity), not v0.8.
- The portfolio `master_roadmap.md` must not tag v0.4 or v0.5 with SHA layers.
  Those releases are small-sample and MCDM respectively, with no integrity work.

## Textbook chapter to version map

The ASRDA textbook ("From Constructs to Conclusions Using R", 14 parts, 41
chapters) is released in stages pinned to the surveyframe version that makes the
tooling real. Each stage is written only once its surveyframe capability exists.

| Stage | surveyframe | Textbook chapters made real |
|---|---|---|
| 1 | 0.3 to 0.4 | Parts I to III (foundations, instrument design, sampling, data capture and quality), Part IV ch 9 (reliability), Part V (descriptives, assumptions), Part VI ch 13 to 16 (correlation, parametric and non-parametric comparisons, agreement). Part VI non-parametric and Part XIII ch 37 resampling draw on the v0.4 small-sample helpers. |
| 2 | 0.5 to 0.6 | Part XII ch 34 to 35 (MCDM, fuzzy and hybrid) on v0.5; Part IV ch 10 (validity and invariance) and Part IX ch 26 to 27 (factor, confirmatory and structural models) on v0.6. |
| 3 | 0.7 to 0.8 | Part VII ch 18 (automated reporting), Part XIV ch 39 to 40 (workflow automation and open science, data management and DOI registration). These are the provenance and defensible-reporting chapters. |
| 4 | 0.9 to 1.0 | Part XI ch 33 (survey weighting and variance estimation) on v0.9. Complete edition published at v1.0 with the JSS-paper citation. |

Parked beyond v1.0 (the book has chapters but surveyframe will not cover them by
1.0; they use base R or other packages, or become post-1.0 companions): Part VIII
ch 21 to 25 (multilevel, causal and longitudinal, survival, time series), Part X
(spatial, network, conjoint and choice), Part XI ch 32 (machine learning), Part
XIII ch 36 (IRT) and ch 38 (meta-analysis). Part III ch 8 (text and open-ended
responses) is not in the surveyframe roadmap; treat a light text-quality helper
as a v1.x candidate, not a v1.0 commitment.

---

## Growth and citation track (parallel)

The credibility engine. Sequenced to compound: each output makes the next one
land harder.

### 1. JSS paper — surveyframe (highest priority)

- Journal of Statistical Software. Manuscript at `jss-paper/surveyframe.Rnw`.
- Positions surveyframe as a proactive workflow: the instrument is a
  methodological contract declared before data collection, so analysis is the
  execution of a pre-declared plan rather than a post-hoc search. No existing
  tool offers this architecture.
- Open task: fill the institutional address, final proofread, submit. After
  acceptance, add `inst/CITATION` and convert the manuscript into a vignette.
- This is the anchor citation for the whole ecosystem.

### 2. Methodological paper based on v0.3

- One focused methods paper built on the v0.3 feature set, distinct from the
  JSS software paper. Subject: the analysis-plan-in-the-instrument design as
  software-enforced pre-registration for survey research, with the worked
  tourism-services example as the demonstration.
- Target a quantitative-methods or research-methods outlet.
- Gives a second citable artefact and a methods-section reference that applied
  papers can cite when they use surveyframe.

### 3. semScreenR — CRAN release and methods paper

- Ship `semScreenR` to CRAN. It is the natural pipeline partner: surveyframe
  `cfa_syntax()` output feeds semScreenR screening before a lavaan fit.
- A methods paper on rule-based, cross-validated SEM data screening with audit
  trails and preregistered caps. Target a methods journal.
- Cross-reference surveyframe and semScreenR in each other's documentation so
  the two packages form a visible toolchain.

### 4. Small-sample methods paper

- Based on the `small-sample-survey-framework` simulation study (n < 30,
  parametric vs nonparametric vs bootstrap vs Bayesian across a factorial
  design). Manuscript-focused already.
- The published decision framework justifies the helpers shipped in surveyframe
  v0.5, so the paper and the release reinforce each other.

### 5. ASRDA textbook — staged with surveyframe progress

- "From Constructs to Conclusions Using R." Quarto book.
- Released in stages that track surveyframe capability rather than as a single
  v1.0 drop: design and reliability chapters with v0.3 to v0.4, structural
  modelling with v0.5 to v0.6, provenance and defensible reporting with v0.7 to
  v0.8, complete edition at v1.0.
- Each chapter cites the surveyframe functions and the JSS paper. The sfReport
  citation linkage at v0.8 makes the textbook citable from inside generated
  reports.
- The textbook is the long-term reputation asset. It must be written to a high
  standard and is gated on the JSS paper being accepted first so it can cite a
  peer-reviewed reference.

### Adoption surface (continuous)

- Applied papers that use surveyframe become citation drivers: the maritime
  research set (`JMR`), the Maldives cross-border e-commerce PLS-SEM study
  (`cbec-maldives-smes`), and the logistics-trade island-economies study
  (`ILPTFIE`). Each should cite surveyframe and, once published, the JSS paper.
- pkgdown gallery of worked instruments across domains (marketing, health,
  education, HR, social science).
- CRAN task views: listed in Psychometrics. Re-approach OfficialStatistics if
  v0.9 ships complex-survey weighting.
- Short course and workshop materials under CC BY.

---

## Product launch dependency (why 1.0 is the gate)

- **Ethos** (research workflow product) and **Ethos Pro** (institutional
  governance) both treat surveyframe as the source-of-truth engine. They need
  the frozen integration contract from v0.9 and the provenance layer from v0.7
  to v0.8. They launch on v1.0.
- **ASRDA textbook** is the methodological companion. Its complete edition
  matches v1.0 capability and cites the JSS paper.
- The provenance work (v0.7 to v0.8) is the concrete engineering that makes the
  textbook citable from reports and gives institutions the audit trail Ethos Pro
  sells.

---

## Out of scope through v1.0 (parked)

Recorded so they are not mistaken for planned work before 1.0.

- Longitudinal panel support across waves.
- Adaptive testing with IRT-driven item selection.
- Differential-privacy noise injection for anonymised export.
- A centralised multi-site response aggregation service.
- Automated translation tooling for multilingual instruments.
- An Item Response Theory layer (candidate for a post-1.0 companion).
