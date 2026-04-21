# surveyframe Roadmap

## Scope

surveyframe is an end-to-end survey research workflow package for R. Its core
object is the `sframe`, a typed survey instrument that carries item
definitions, choice sets, scales, reverse-coding rules, branching logic,
quality checks, analysis-plan metadata, and rendering settings through the
entire workflow.

The package is intended to cover:

- instrument design
- validation and serialisation
- deployment and collection
- response loading
- data quality checks
- scale scoring
- psychometric diagnostics
- planned analyses
- reproducible reporting

The package is not intended to become a general statistics environment or a
replacement for specialist modelling tools.

## Current status

Status below reflects the repository working tree after the current CRAN
hardening pass.

### Integrated v0.2 capabilities

- typed constructors for instruments and all core components
- `.sframe` JSON serialisation with SHA-256 integrity hashing
- browser-based SurveyBuilder
- Shiny survey generator through `render_survey()`
- SurveyStudio as the workflow shell
- CSV/data-frame response loading and Google Sheets import helper
- quality reporting, scale scoring, reliability diagnostics, item diagnostics,
  EFA readiness, and CFA syntax generation
- analysis-plan execution and HTML result rendering
- HTML report rendering with Quarto when available and an internal fallback
  when it is not

### Dependency posture

Hard imports are now intentionally minimal:

- `jsonlite`
- `rlang`
- `openssl`

Optional features are loaded at call time:

- `shiny` for deployment and studio features
- `psych` for reliability and EFA readiness
- `googlesheets4` for Google Sheets input
- Quarto CLI for richer report rendering

### Verification snapshot

- local targeted test run: `test-core.R` `PASS=135`, `FAIL=0`
- local targeted test run: `test-v02.R` `PASS=100`, `FAIL=0`
- local source build plus `R CMD check --no-vignettes --no-manual`: `Status: OK`

### What still blocks a clean CRAN submission

- full `R CMD check --as-cran` needs to be run and reviewed across platforms
- runnable examples need to replace broad `\\dontrun{}` usage on constructor
  functions
- the bundled builder asset needs a reviewer-facing note explaining that it is
  authored package code, not third-party minified JavaScript
- the submission pack still needs `cran-comments.md`, win-builder results, and
  rhub results

## Development roadmap

### Phase 0: CRAN hardening

Priority: immediate.

- keep the hard dependency set minimal and stable
- finish guard-at-call-time behaviour for optional packages
- run `R CMD check --as-cran` locally and fix every actionable note or warning
- verify Windows and cross-platform behaviour through win-builder and rhub
- tighten examples and submission documentation for CRAN review

### Phase 1: First CRAN submission

Priority: after Phase 0 is clean.

- prepare a clear `cran-comments.md`
- document optional dependency behaviour explicitly
- submit once with a reviewed, tested, cross-platform package
- avoid feature churn during review

### Phase 2: Adoption surface

Priority: after CRAN acceptance.

- add an RStudio add-in for `launch_builder()`
- ship a stronger pkgdown site with a gallery of complete example instruments
- register Zenodo for release DOIs
- prepare workshop materials for survey-methods and R audiences
- draft and submit the Journal of Statistical Software paper

### Phase 3: Workflow completion inside v0.2/v0.3

Priority: after the package is easier to install and cite.

- align SurveyBuilder preview and `render_survey()` behaviour
- decide the long-term relationship between SurveyBuilder and SurveyStudio
- decide whether direct Google Sheets submission belongs in core v0.2 or later
- add browser-level UI automation for the builder and rendered survey
- decide whether static HTML survey deployment remains in scope
- expose the survey renderer as a reusable Shiny module

### Phase 4: Companion packages

Priority: only after the core package is stable on CRAN.

- `sfMCDM` for multi-criteria decision methods
- `sfSEM` for SEM-oriented extensions around generated syntax
- `sfIRT` for item response theory workflows
- `sfReport` for additional journal-style report templates

## Guardrails

- The `sframe` object remains the single source of truth.
- CRAN acceptance is more important than adding one more feature to v0.2.
- Optional dependencies stay optional unless a hard import is unavoidable.
- External services remain downstream integrations rather than core
  requirements.
- New features should not blur the package identity.
