# surveyframe TODO

This checklist is derived from Phase 1 and Phase 2 of
[roadmap.md](/home/maxx/Documents/GitHub/surveyframe/roadmap.md).

## Phase 1: Finish and Stabilize v0.1

### 1. Lock the v0.1 scope

- [x] Review exported functions and confirm that every public feature belongs
      to the instrument-centered workflow.
- [x] Remove or defer any public-facing feature that pulls the package outside
      the v0.1 boundary.
- [x] Update `README.md`, `DESCRIPTION`, and `NEWS.md` so the scope statement
      matches the code exactly.

### 2. Harden the Shiny collection layer

- [x] Add a clear response persistence path for `render_survey()` so submitted
      responses are actually saved or handed off in a defined way.
- [x] Decide on the v0.1 persistence contract:
      local file, callback, returned object, or explicit "demo only" behavior.
- [x] Implement submission validation before the thank-you modal appears.
- [x] Enforce `required = TRUE` across supported item types.
- [x] Use item metadata consistently in the renderer where already supported:
      `help`, `placeholder`, and render hints.
- [x] Verify branching behavior across all supported item types.
- [x] Test the Shiny survey through server-side persistence and validation
      tests with branching and required items.

Relevant files:
- [R/render_survey.R](/home/maxx/Documents/GitHub/surveyframe/R/render_survey.R)
- [inst/shiny/app.R](/home/maxx/Documents/GitHub/surveyframe/inst/shiny/app.R)

### 3. Complete timing analysis in `quality_report()`

- [x] Define the timing input contract clearly:
      which columns are required, and how start and submit times are detected.
- [x] Implement completion-time calculation in `quality_report()`.
- [x] Flag respondents below `time_min` when timing data are available.
- [x] Return timing results in the report object instead of leaving
      `timing = list()`.
- [x] Update the print method if timing output should appear in summaries.
- [x] Add tests for:
      valid timing data, missing timing columns, malformed timestamps, and
      threshold-based flagging.

Relevant file:
- [R/quality_report.R](/home/maxx/Documents/GitHub/surveyframe/R/quality_report.R)

### 4. Resolve weighted scoring behavior

- [x] Decide whether weighted scoring ships in v0.1 or whether `weights`
      should be removed from the public API for now.
- [x] If weighted scoring stays:
      implement it in `score_scales()` for supported methods and document the
      exact behavior with missing data and `min_valid`.
- [x] Weighted scoring remains in v0.1, so the API removal path is not needed.
- [x] Add tests for the final chosen behavior.

Relevant files:
- [R/sf_scale.R](/home/maxx/Documents/GitHub/surveyframe/R/sf_scale.R)
- [R/score_scales.R](/home/maxx/Documents/GitHub/surveyframe/R/score_scales.R)

### 5. Expand test coverage across workflows

- [x] Add integration-style tests that cover the full sequence:
      instrument -> validation -> write/read -> responses -> quality ->
      scoring -> reporting.
- [x] Add regression tests for reverse coding based on choice-set ranges.
- [x] Add tests for Shiny renderer behavior where practical, or document the
      manual verification checklist if automated Shiny tests are deferred.
- [x] Add tests for edge cases in branching, missing item columns, duplicate
      IDs, and incomplete scales.
- [x] Run the full suite through the package-loading path used in CI.

Relevant files:
- [tests/testthat/test-core.R](/home/maxx/Documents/GitHub/surveyframe/tests/testthat/test-core.R)
- [tests/testthat.R](/home/maxx/Documents/GitHub/surveyframe/tests/testthat.R)

### 6. Keep package checks green

- [x] Run `devtools::document()` and confirm `NAMESPACE` and man pages stay in
      sync with the source.
- [x] Run the local test suite and a no-vignette `devtools::check()` locally.
- [x] Review GitHub Actions output for:
      R CMD check, pkgdown, and test coverage.
- [x] Fix platform-specific issues on macOS, Windows, and Linux if they
      appear in CI.
- [x] Confirm that the vignette and Quarto report template build cleanly in
      CI and locally.

Relevant files:
- [.github/workflows/R-CMD-check.yaml](/home/maxx/Documents/GitHub/surveyframe/.github/workflows/R-CMD-check.yaml)
- [.github/workflows/pkgdown.yaml](/home/maxx/Documents/GitHub/surveyframe/.github/workflows/pkgdown.yaml)
- [.github/workflows/test-coverage.yaml](/home/maxx/Documents/GitHub/surveyframe/.github/workflows/test-coverage.yaml)

### 7. Finish CRAN-readiness work

- [x] Review `DESCRIPTION` for final dependency hygiene and metadata quality.
- [x] Confirm `LICENSE`, `inst/CITATION`, and author metadata are final.
- [x] Check examples, vignette, and documentation for CRAN-safe behavior.
- [x] Make sure the package can be used without launching Shiny when the user
      only wants the non-interactive workflow.
- [x] Prepare a CRAN submission checklist with final blockers and decisions.

Current blockers outside the local source tree:

- [x] Push the current branch and review fresh GitHub Actions runs.
- [x] Re-run the full local vignette build on a machine with Pandoc installed.

Latest verification:

- [x] Commit `2f94b5e` passed `pkgdown`, `R CMD check`, and `test-coverage`
      on GitHub Actions on April 16, 2026 UTC.

Definition of done for Phase 1:

- [x] The public API matches the documented v0.1 scope.
- [x] The remaining implementation gaps named in `roadmap.md` are closed.
- [x] Local checks pass.
- [x] GitHub Actions are green.
- [x] The package is ready for a serious CRAN submission pass.

## Phase 2: Package Adoption and Publication

### 1. Strengthen the getting-started path

- [ ] Review the vignette from the perspective of a first-time researcher.
- [ ] Make the vignette start with the instrument object and walk cleanly
      through the full workflow.
- [ ] Add a clear "new study from scratch" path to the README.
- [ ] Add a clear "script-only workflow" path to the README or vignette.
- [ ] Make sure SurveyStudio is presented as one workflow entry point, not the
      only useful way to use the package.

Relevant files:
- [README.md](/home/maxx/Documents/GitHub/surveyframe/README.md)
- [vignettes/surveyframe.Rmd](/home/maxx/Documents/GitHub/surveyframe/vignettes/surveyframe.Rmd)
- [_pkgdown.yml](/home/maxx/Documents/GitHub/surveyframe/_pkgdown.yml)

### 2. Improve the pkgdown site

- [ ] Audit the navigation for the order a new researcher actually needs.
- [ ] Make sure the home page and reference index emphasize the instrument
      object and end-to-end workflow.
- [ ] Add links between the vignette, reference topics, and reporting tools.
- [ ] Confirm that badges, install instructions, and citation information are
      correct and current.
- [ ] Build the site locally and review it page by page.

### 3. Prepare the JSS paper

- [ ] Write a paper outline centered on the `sframe` object as the primary
      contribution.
- [ ] Draft the core argument for the paper:
      one instrument object drives the full research lifecycle.
- [ ] Document the reproducibility case around `.sframe` files and SHA-256
      hashing.
- [ ] Build one complete worked example that can anchor both the paper and the
      package documentation.
- [ ] Decide which package features are core to the paper and which should
      stay as supporting details.
- [ ] Start a references list for competing or adjacent packages and explain
      the distinction clearly.

### 4. Turn the package into a citable methods contribution

- [ ] Write method-section wording for the four intended citation points:
      deployment, data quality, reliability, and codebook generation.
- [ ] Make sure the citation metadata and package citation are publication
      ready.
- [ ] Add a short "How to cite surveyframe in a paper" section to the README
      or vignette if needed.
- [ ] Identify one or two example studies or demos that show the full workflow
      clearly enough to support citation adoption.

Relevant file:
- [inst/CITATION](/home/maxx/Documents/GitHub/surveyframe/inst/CITATION)

### 5. Publication support work

- [ ] Create a release checklist for the first public package release.
- [ ] Prepare a short release summary for GitHub and pkgdown.
- [ ] Prepare issue templates or contribution guidance for incoming user
      feedback once adoption starts.
- [ ] Decide how to track post-release bugs and documentation requests.

Relevant file:
- [CONTRIBUTING.md](/home/maxx/Documents/GitHub/surveyframe/CONTRIBUTING.md)

Definition of done for Phase 2:

- [ ] A new researcher can follow the docs and complete a full workflow.
- [ ] The pkgdown site clearly explains the package’s contribution.
- [ ] The JSS paper draft is underway with the instrument object as the center.
- [ ] Citation guidance is ready for real-world use.
