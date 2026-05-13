# surveyframe development roadmap

Last updated: May 2026 - v0.3.0 pre-submission candidate

---

## Phase 0: CRAN hardening - IN FINAL REVIEW

- [x] Local `R CMD check --as-cran` on source tarball with 0 errors and 0 warnings
- [ ] Confirm win-builder and rhub results for the final v0.3.0 tarball
- [x] `studio_builder.R` internal state and validation helpers implemented
- [x] `launch_builder()` fixed to open HTML, not Shiny
- [x] SHA-256 fallback in SurveyBuilder HTML
- [x] `rqSuggest` box made functional
- [x] Undo/redo button state corrected
- [x] Runnable examples for constructors and `validate_sframe()`
- [x] `cran-comments.md` written
- [x] Security hardening pass:
      strict Studio upload validation, JSON schema checks on `.sframe` import,
      safe Apps Script string generation, escaped analysis/report HTML, and
      Quarto temp-file cleanup

---

## Phase 1: First CRAN submission - PENDING

- [ ] Submit surveyframe 0.3.0 to CRAN
- [ ] Respond to CRAN reviewer comments, if any
- [ ] Tag the accepted CRAN release

---

## Phase 2: Adoption surface: IN PROGRESS

- [ ] pkgdown site with gallery of complete example instruments
- [ ] RStudio add-in: one-click `launch_builder()` from the Addins menu
- [ ] Zenodo DOI for the instrument schema
- [ ] JSS methods paper draft
- [ ] Workshop materials (3-hour short course, CC BY)
- [ ] `sf_instrument()` gallery vignette with five example domains
      (marketing, health, education, HR, social science)

---

## Phase 3: Workflow completion - COMPLETE in v0.3.0

- [x] Static HTML survey export: `export_static_survey()`
      All 13 item types, branching, validation, CSV download, POST endpoint.
      No server or internet connection required.

- [x] Shiny survey module: `survey_module_ui()` / `survey_module_server()`
      Embeds a survey inside a larger Shiny application. Returns a reactive
      holding the response list when submitted.

- [x] Interactive response dashboard: `launch_dashboard()`
      Overview, per-item charts, scale distributions, quality flags,
      raw data table with download.

- [x] Extended analysis tests in `run_analysis_plan()`:
      `anova_one` (with Tukey HSD), `t_test_pair`, `wilcoxon_pair`,
      `regression_logistic_binary`.

- [ ] End-to-end browser test suite using shinytest2
      (deferred to v0.3.1: requires CI setup)

- [ ] Google Sheets direct submission from `export_static_survey()`
      (Apps Script generator exists; direct R-side writer deferred)

- [ ] Align SurveyBuilder preview exactly with `render_survey()` output
      (minor rendering differences remain in matrix and ranking items)

---

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

---

## Long-term ideas (unscheduled)

- Longitudinal panel support: track the same respondent across waves.
- Adaptive testing: IRT-driven item selection in `survey_module_server()`.
- Differential privacy noise injection for anonymised response export.
- `sfDataHub`: centralised response aggregation API for multi-site studies.
- Translation tooling: `sf_translate()` to produce multilingual sframe
  instruments via DeepL or a human-verified translation workflow.
