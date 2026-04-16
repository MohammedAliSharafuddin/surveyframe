# surveyframe Roadmap

## Scope

`surveyframe` is a workflow package for academic survey research in R.
Its core contribution is the `sframe` instrument object: one structured
source of truth that carries item definitions, reusable choice sets,
scale structure, reverse-coding rules, branching logic, design-time
checks, and rendering metadata through the full research pipeline.

The package serves as a connecting layer within the research workflow.
Specialist analysis libraries and commercial survey platforms remain
separate tools. In its intended shape, `surveyframe` defines the
instrument, validates it, serialises it, deploys it, reads response data
back in, checks data quality, scores scales, prepares psychometric
diagnostics, and generates reproducible outputs. Packages such as
`psych`, `lavaan`, and future method-specific extensions consume
instrument-aware data downstream from the core package.

### In-scope for v0.1

- Typed constructors for items, choice sets, scales, branching rules,
  and design-time checks
- An `sframe` S3 object with print, format, and summary methods
- Instrument validation and custom condition classes
- `.sframe` JSON serialisation with SHA-256 integrity hashing
- Shiny-based survey rendering
- SurveyStudio, a Shiny interface for visual workflow orchestration
- Response loading with column-contract validation
- Quality reporting for attention checks, missingness, straight-lining,
  and duplicate respondent IDs
- Scale scoring, reverse coding, reliability diagnostics, item
  diagnostics, EFA readiness diagnostics, and CFA syntax generation
- Codebook generation and parameterised Quarto reporting

### Explicitly out of scope for v0.1

- A conversational builder
- Static HTML deployment
- Quarto inline survey embedding
- External platform import/export such as Qualtrics or REDCap
- Multilingual authoring workflows beyond basic language metadata
- Multi-condition branching trees
- IRT and decision-science method engines
- An AI survey design assistant

## Current Status

Current status below reflects the repository state reviewed on April 16,
2026.

### What is already present in the repo

- Package metadata, documentation, and release scaffolding are in place:
  `DESCRIPTION`, `README.md`, `NEWS.md`, `inst/CITATION`,
  `_pkgdown.yml`, the vignette, and GitHub Actions workflows for R CMD
  check, pkgdown, and Codecov.
- The public API is exported through `NAMESPACE`, including
  `sf_instrument`.
- The constructor family is implemented:
  [`sf_item()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_item.md),
  [`sf_choices()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_choices.md),
  [`sf_scale()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_scale.md),
  [`sf_branch()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_branch.md),
  [`sf_check()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_check.md),
  and
  [`sf_instrument()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_instrument.md).
- Instruments can be validated, written to `.sframe`, read back, and
  checked against their integrity hash.
- The package includes a Shiny renderer and a six-screen SurveyStudio
  app in `inst/shiny/app.R`.
- Response loading, quality reporting, scale scoring, reliability
  reporting, item diagnostics, EFA readiness diagnostics, CFA syntax
  generation, codebook generation, and Quarto report rendering are all
  implemented.
- The local test suite passes when run with the package loaded:
  `pkgload::load_all('.')` plus `testthat::test_dir('tests/testthat')`.

### What is stable enough to describe as delivered

- The package has a coherent end-to-end object model.
- The core v0.1 workflow is visible across code, tests, README,
  vignette, and pkgdown configuration.
- The scope is still disciplined. The repository stays focused on
  instrument definition and workflow.

### What still needs hardening

- The Phase 1 code gaps have been closed in the local repository.
- Remaining release verification is external to the source edits: a
  pushed branch needs fresh GitHub Actions results.

## Development Roadmap

### Phase 1: Finish and stabilize v0.1

Priority: immediate.

- Keep the package identity tight around the instrument object and the
  end-to-end survey workflow.
- Close the remaining implementation gaps between the documented API and
  the current code, especially:
  - response capture and persistence in the Shiny collection layer
  - required-field enforcement and richer item rendering behavior
  - timing checks in
    [`quality_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/quality_report.md)
  - weighted scoring support or explicit removal of the unused argument
- Expand tests across shared workflow behavior and cross-function
  interactions.
- Run full package checks regularly and keep GitHub Actions green across
  supported platforms.
- Treat CRAN readiness, documentation quality, and reproducibility as
  release requirements.

### Phase 2: Package adoption and publication

Priority: before major scope expansion.

- Make the vignette and pkgdown site clear enough that a researcher can
  start a new study from the instrument object with a clear workflow.
- Write the Journal of Statistical Software paper alongside release
  work, with the instrument object and reproducibility model as the
  central contribution.
- Frame the package as a methods contribution with a software
  implementation.
- Build citation traction around four likely methods-section
  touchpoints: survey deployment, data-quality checking, reliability
  analysis, and codebook generation.

### Phase 3: Extend the collection layer inside `surveyframe`

Priority: after v0.1 is stable and published.

These additions belong in the core package because they are collection
formats that deepen the instrument model while keeping `surveyframe`
within its workflow-focused scope.

- Pairwise comparison matrix items
- Ranking items
- Semantic differential items
- Budget allocation items
- Constant-sum or MaxDiff-style items

The goal in this phase is to make `surveyframe` a stronger survey-native
collection layer while preserving the package’s identity as a workflow
system.

### Phase 4: Companion package for decision-science workflows

Priority: separate from the core package.

Analytical methods that are tightly coupled to specialised elicitation
formats should live in a companion package such as `sfMCDM`. The core
`surveyframe` package should remain separate from that layer.

Candidate workflows for the companion package:

- AHP consistency checks, weights, and aggregation
- DEMATEL pipelines
- TOPSIS and VIKOR workflows
- Best-Worst Method support
- Fuzzy extensions where the methodological variant is explicit

This separation protects the core package from scope creep, keeps the
JSS paper focused, and creates room for a second citable output.

### Phase 5: Later extensions

Priority: only after the core and companion layers are stable.

- Static HTML deployment
- Quarto inline embedding
- External platform import/export
- Multilingual workflows
- Multi-condition branching trees
- AI-assisted survey authoring

These are meaningful directions. They should follow package stability,
documentation, release discipline, and a clear separation between
collection workflows and specialised analytical engines.

## Guardrails

- The `sframe` object remains the package’s single source of truth.
- The core package stays focused on survey workflow. General statistics
  and decision-science features remain outside the core package.
- New features must strengthen the instrument-centered workflow or stay
  out of the core package.
- Shipping a reliable, citable v0.1 matters more than chasing breadth.
