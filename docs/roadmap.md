# surveyframe development roadmap

Last updated: May 2026 - v0.3.0 pre-submission candidate

------------------------------------------------------------------------

## v0.4 future directions: PLANNED

MCDM and DEMATEL fall outside v0.3 scope. Planned v0.4 work includes
MCDM input fields, AHP pairwise-comparison matrices, DEMATEL
direct-influence matrices, TOPSIS, VIKOR, PROMETHEE and ELECTRE planning
support, MCDM data validation, DEMATEL thresholding and causal diagram
export, advanced SEM and PLS-SEM execution, higher-order constructs,
MICOM/invariance testing, multi-group SEM planning, a diagram-based
model builder, complex survey-design weighting, JASP/jamovi-friendly
exports, and later ASRDA/report writer integration once the data and
model schema has stabilised.

Additional v0.4 candidates from the pre-submission review:

- Visual branching preview with a flowchart view before deployment.
- Dashboard filters for categorical subsets and submitted-date ranges.
- Power-analysis extensions for
  [`sample_size_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sample_size_plan.md)
  using optional packages where available.
- Interactive assumption plots, including Q-Q plots and residual plots.
- Effect-size confidence intervals for common hypothesis tests.
- Measurement-invariance planning for configural, metric, and scalar CFA
  workflows.
- Exact, permutation, and bootstrap test helpers for small samples.

------------------------------------------------------------------------

## Phase 0: CRAN hardening - IN FINAL REVIEW

Local `R CMD check --as-cran` on source tarball with 0 errors and 0
warnings

Confirm win-builder and rhub results for the final v0.3.0 tarball

`studio_builder.R` internal state and validation helpers implemented

[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md)
fixed to open HTML, not Shiny

SHA-256 fallback in SurveyBuilder HTML

`rqSuggest` box made functional

Undo/redo button state corrected

Runnable examples for constructors and
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md)

`cran-comments.md` written

Security hardening pass: strict Studio upload validation, JSON schema
checks on `.sframe` import, safe Apps Script string generation, escaped
analysis/report HTML, and Quarto temp-file cleanup

------------------------------------------------------------------------

## Phase 1: First CRAN submission - PENDING

Submit surveyframe 0.3.0 to CRAN

Respond to CRAN reviewer comments, if any

Tag the accepted CRAN release

------------------------------------------------------------------------

## Phase 2: Adoption surface: IN PROGRESS

pkgdown site with gallery of worked example instruments

RStudio add-in: one-click
[`launch_builder()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder.md)
from the Addins menu

Zenodo DOI for the instrument schema

JSS methods paper draft

Workshop materials (3-hour short course, CC BY)

[`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md)
gallery vignette with five example domains (marketing, health,
education, HR, social science)

------------------------------------------------------------------------

## Phase 3: Workflow completion - COMPLETE in v0.3.0

Static HTML survey export:
[`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md)
All 13 item types, branching, validation, CSV download, POST endpoint.
No server or internet connection required.

Shiny survey module:
[`survey_module_ui()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_ui.md)
/
[`survey_module_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_server.md)
Embeds a survey inside a larger Shiny application. Returns a reactive
holding the response list when submitted.

Interactive response dashboard:
[`launch_dashboard()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard.md)
Overview, per-item charts, scale distributions, quality flags, raw data
table with download.

Extended analysis tests in
[`run_analysis_plan()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/run_analysis_plan.md):
`anova_one` (with Tukey HSD), `t_test_pair`, `wilcoxon_pair`,
`regression_logistic_binary`.

End-to-end browser test suite using shinytest2 (deferred to v0.3.1:
requires CI setup)

Google Sheets direct submission from
[`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md)
(Apps Script generator exists; direct R-side writer deferred)

Align SurveyBuilder preview exactly with
[`render_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_survey.md)
output (minor rendering differences remain in matrix and ranking items)

------------------------------------------------------------------------

## Phase 4: Companion packages: PLANNED

Each companion is a separate CRAN package that imports surveyframe as a
hard dependency and extends one slice of the pipeline.

### sfReport (v1.0 target: Q3 2026)

- Quarto-native report renderer: `sf_report()` produces a full `.qmd`
  document with analysis results, charts, codebook, and bibliography.
- CFA path diagram via `semPlot` or `DiagrammeR`.
- APA 7 reference list auto-populated from the citation store.

### sfSEM (v1.0 target: Q4 2026)

- Structural equation modelling helpers layered on `lavaan`.
- `sf_sem_model()`: declare structural paths between sframe scales.
- Common-method variance diagnostics (CMV Suite, replacing `cmvtest`).
- Indirect effects via `semTools::monteCarloCI()`.
- Measurement invariance testing across groups.

### sfIRT (v1.0 target: Q1 2027)

- Item Response Theory layer using `mirt`.
- `sf_irt_model()`: fit 1PL / 2PL / GRM from sframe scale definitions.
- Item information curves and test information functions.
- Differential item functioning (DIF) across demographic groups.

### sfMCDM (v1.0 target: Q2 2027)

- Multi-criteria decision making: AHP, TOPSIS, VIKOR from sframe data.
- `sf_ahp()`, `sf_topsis()`, `sf_vikor()` with HTML result tables.
- Sensitivity analysis across criteria weights.

------------------------------------------------------------------------

## asrda-r adoption analysis: v1.0 provenance layer

*Written May 2026. This section records what can be absorbed from the
`asrda-r` prototype into surveyframe and its companion packages before
v1.0. `asrda-r` itself will not ship as a CRAN dependency; its
contributions are absorbed directly.*

### Background

`asrda-r` is a prototype R package built alongside Ethos to give the
instrument-build workflow an auditable provenance trail. It wraps nine
modules (3021 lines) covering instrument versioning, expert review,
pilot study records, tamper-evident response bundles, defensibility
report appendices, machine-readable citation blocks, and a starter
analysis scaffold. Surveyframe already handles everything below the
instrument object (quality reporting, scale scoring, reliability, EFA,
CFA/SEM syntax, full analysis plan), but it currently has no concept
of instrument lifecycle, review artefacts, or traceable provenance.

The ASRDA textbook is the complete methodological companion planned for
publication when surveyframe reaches v1.0. The textbook defines the
full research design vocabulary (screening, reliability, validity,
structural modelling, small-sample paths), and the citation linkage
in sfReport should reference its chapters, not just the package
version. Absorbing the provenance layer from `asrda-r` is the concrete
engineering counterpart to publishing that textbook.

### What asrda-r contributes that surveyframe does not have

**Instrument lifecycle and content-hash versioning
(`instrument_versioning.R`)**  
Assigns content-hash version IDs in the form
`instrument_id.v{n}.{hash7}` so that every saved state of an
instrument is uniquely addressable. Tracks parent version, lifecycle
status (`draft` → `reviewed` → `pilot` → `published` → `archived`),
and version number increments. Surveyframe has no equivalent; an
sframe object is always the current, unnamed state.

**Expert review artefact (`expert_review.R`)**  
A structured record attached to a specific instrument version: list of
reviewers, item-level flags, resolution notes, overall status
(`completed` / `skipped` / `not_applicable`), and review date.
Surveyframe has no peer-review object.

**Pilot study artefact (`pilot_summary.R`)**  
A structured summary attached to a specific instrument version: n,
completion notes, per-item flags from respondents, a quality summary,
and a reliability summary. Surveyframe has no pilot record object.

**Tamper-evident response bundle (`response_bundle.R`)**  
Combines instrument version snapshot + review artefact + pilot
artefact + response data into a single bundle with SHA-256 verification
across all components. Provides audit-trail integrity for ethics
submission and secondary analysis. Surveyframe has no bundle primitive.

**Defensibility report appendix (`report_render.R`)**  
A narrative appendix section added to any report that reproduces the
review and pilot evidence, summarises the instrument lifecycle, and
explains methodological choices in plain text. Distinct from the
analysis output sections. Not in sfReport yet.

**Machine-readable citation block (`citation_block.R`)**  
Links the report to the specific instrument version, the surveyframe
package version, and the ASRDA textbook. Fields: instrument ID and
version hash, software version, textbook chapter reference, report
date, and analysis type. Produces both plain-text and BibTeX output.
sfReport currently auto-populates a package citation but has no
instrument-version or textbook linkage.

**Starter analysis scaffold (`analysis.R`)**  
Six high-level analysis types (`screening`, `reliability`,
`validity_starter`, `efa_starter`, `cfa_sem_starter`,
`regression_starter`) each carrying a `methods_text`, `results_text`,
and `citations` field. These are narrative wrappers above surveyframe's
`run_analysis_plan()` output. Some of this overlaps with what
sfReport's Quarto renderer will generate; the non-overlapping value is
the pre-written methods-text templates tied to named analysis types.

### Adoption plan

#### Core surveyframe (v1.0, parallel with sfReport delivery)

These additions belong in the surveyframe package itself because they
extend the instrument object — sfReport and Ethos both depend on them:

- `sf_version()`: attach a content-hash version identifier to an
  sframe instrument and record lifecycle status transitions. Store
  version chain as an attribute on the sframe object.
- `sf_review()`: create and attach a peer-review artefact to a
  versioned sframe instrument.
- `sf_pilot()`: create and attach a pilot-study artefact.
- `sf_bundle()`: wrap a versioned instrument + review + pilot +
  response data frame into a tamper-evident bundle with SHA-256
  verification across components. Pairs with a `verify_bundle()`
  helper.

None of these touch the analysis chain or the Plumber adapter; they
are purely data-structure additions to the instrument layer.

#### sfReport (Phase 4, Q3 2026 target)

- Defensibility appendix section: reproduce review artefact, pilot
  summary, and lifecycle history in a dedicated appendix block.
- ASRDA textbook citation linkage: `sf_report()` accepts an optional
  `asrda_chapters` argument that inserts formatted references to the
  relevant ASRDA chapters (e.g. "Chapter 4: Scale Reliability" for a
  reliability-focused report). This ties the rendered report back to
  the textbook that describes the methodology.
- Machine-readable citation block: embed instrument version hash,
  software version, and textbook references in the report metadata and
  BibTeX appendix.
- Methods-text templates from the `asrda-r` analysis scaffold: adapt
  the pre-written narrative paragraphs for each analysis type into
  Quarto chunk templates that sfReport populates from
  `run_analysis_plan()` output.

#### Not adopted

- The full `asrda-r` package as a CRAN dependency: absorbed directly,
  not re-exported.
- `asrda-r`'s own report renderer: replaced by sfReport's Quarto-native
  approach, which is more flexible and produces a proper `.qmd`
  document.
- The linear 12-step workflow assumed in the current Ethos UI: the
  Ethos front end presents a sequential chain for simplicity in the
  alpha. True research-design branching — different analytical paths
  based on the user's design decisions after consulting ASRDA — is a
  future Ethos UX concern. Surveyframe itself is not sequential;
  functions can be called in any order that makes sense for the study
  design.

### Connection to the ASRDA textbook

The ASRDA textbook will be the complete methodological companion for
surveyframe v1.0, covering the full research design space including
paths that surveyframe v0.3 does not yet implement (PLS-SEM, CB-SEM,
small-sample alternatives, MCDM). The citation-block work in sfReport
is the engineering contract that makes the textbook citable from within
a generated report. The textbook publication and v1.0 release are
planned to coincide so that every sfReport output can point to the
corresponding chapter that justifies its methodological choices.

------------------------------------------------------------------------

## Long-term ideas (unscheduled)

- Longitudinal panel support: track the same respondent across waves.
- Adaptive testing: IRT-driven item selection in
  [`survey_module_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_server.md).
- Differential privacy noise injection for anonymised response export.
- `sfDataHub`: centralised response aggregation API for multi-site
  studies.
- Translation tooling: `sf_translate()` to produce multilingual sframe
  instruments via DeepL or a human-verified translation workflow.
