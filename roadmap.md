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

## Long-term ideas (unscheduled)

- Longitudinal panel support: track the same respondent across waves.
- Adaptive testing: IRT-driven item selection in
  [`survey_module_server()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/survey_module_server.md).
- Differential privacy noise injection for anonymised response export.
- `sfDataHub`: centralised response aggregation API for multi-site
  studies.
- Translation tooling: `sf_translate()` to produce multilingual sframe
  instruments via DeepL or a human-verified translation workflow.
