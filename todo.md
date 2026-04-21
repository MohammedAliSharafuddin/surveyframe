# surveyframe TODO

This checklist reflects the current CRAN-hardening and release plan.
Checkpoint as of 2026-04-21: dependency reduction is complete, optional-package
guards are in place, documentation was regenerated, and the standard clean
source build plus `R CMD check` are passing.

## Phase 0: CRAN hardening

- [x] Reduce hard imports to the core file-format and condition stack
- [x] Move `shiny` behind runtime guards
- [x] Move `psych` behind runtime guards
- [x] Remove `dplyr` from the package dependency surface
- [x] Replace `readr` usage with base R CSV loading
- [x] Replace `tibble` output paths with base `data.frame` output
- [x] Remove the Quarto hard dependency and keep Quarto optional
- [x] Add a non-Quarto HTML fallback in `render_report()`
- [x] Add explicit `utils::type.convert()` calls in the bundled studio app
- [x] Remove top-level `library()` calls from the bundled studio app
- [x] Regenerate documentation and verify the dependency changes in `NAMESPACE`
- [x] Run a clean source build and standard `R CMD check`
- [ ] Run full local `R CMD check --as-cran`
- [ ] Review every note, warning, and skip from the `--as-cran` run
- [ ] Run win-builder before submission
- [ ] Run rhub before submission
- [ ] Replace broad `\\dontrun{}` constructor examples with runnable examples
- [ ] Add `@details` text where exported functions intentionally raise custom
      `sframe_*` conditions
- [ ] Add a short reviewer note to the builder HTML explaining that the script
      is authored package code, not bundled third-party minified code

## Phase 1: submission pack

- [ ] Write `cran-comments.md`
- [ ] Describe the package purpose and lack of a direct CRAN equivalent
- [ ] Explain the optional dependency strategy for `shiny`, `psych`,
      `googlesheets4`, and Quarto
- [ ] List every remaining `\\dontrun{}` example and justify it
- [ ] Summarise the builder asset and why it is included in `inst/`
- [ ] Freeze feature work while CRAN review is active

## Phase 2: documentation and adoption

- [ ] Publish a stronger pkgdown site with a gallery of example instruments
- [ ] Add an RStudio add-in for `launch_builder()`
- [ ] Document the optional-package model clearly in the main vignette
- [ ] Prepare workshop material for a full surveyframe workflow demo
- [ ] Enable Zenodo DOI generation for tagged releases
- [ ] Draft the Journal of Statistical Software paper

## Phase 3: workflow completion

- [ ] Align SurveyBuilder preview and `render_survey()` behaviour
- [ ] Add browser-level UI automation for the builder
- [ ] Add at least one end-to-end browser test for survey completion
- [ ] Decide whether SurveyStudio remains separate or hosts the builder
- [ ] Decide whether direct Google Sheets submission belongs in core
- [ ] Decide whether static HTML survey deployment remains in scope
- [ ] Expose the survey renderer as a reusable Shiny module

## Phase 4: companion packages

- [ ] Plan `sfMCDM`
- [ ] Plan `sfSEM`
- [ ] Plan `sfIRT`
- [ ] Plan `sfReport`
