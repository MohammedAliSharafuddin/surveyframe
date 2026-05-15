# CRAN submission notes - surveyframe 0.3.0

## Test environments

- Local: Ubuntu 24.04.4 LTS, R 4.6.0, x86_64-pc-linux-gnu
- win-builder: Windows Server 2022 x64, R Under development, 2026-05-14 r90050 ucrt
- win-builder: Windows Server 2022 x64, R 4.6.0, 2026-04-24 ucrt
- R-hub / GitHub Actions: Ubuntu latest, R-release
- R-hub / GitHub Actions: Ubuntu latest, R-devel
- R-hub / GitHub Actions: Windows latest, R-release
- R-hub / GitHub Actions: macOS latest, R-release

## R CMD check results

Local direct `R CMD check --as-cran` on the built source tarball:

- Ubuntu 24.04.4 LTS
- R 4.6.0
- Status: 0 ERRORs, 0 WARNINGs, 1 NOTE

The remaining NOTE is:

1. CRAN incoming feasibility NOTE:
   - This is a new submission.
   - Maintainer details were reported.

Package build, installation, examples, tests, vignettes, namespace checks,
Rd checks, HTML manual checks, PDF manual generation, and R code diagnostics
passed locally.

No local package-code ERROR or WARNING remains.

## win-builder results

The package was checked on win-builder before submission.

- win-builder R-devel: 0 ERRORs, 0 WARNINGs, 1 NOTE
  - Platform: Windows Server 2022 x64, R Under development, 2026-05-14 r90050 ucrt
  - Compiler: GCC 14.3.0
  - Installation time: 12 seconds
  - Check time: 144 seconds
  - Temporary log URL: https://win-builder.r-project.org/8IxRH1jvDytF

- win-builder R-release: 0 ERRORs, 0 WARNINGs, 1 NOTE
  - Platform: Windows Server 2022 x64, R 4.6.0, 2026-04-24 ucrt
  - Compiler: GCC 14.3.0
  - Installation time: 12 seconds
  - Check time: 147 seconds
  - Temporary log URL: https://win-builder.r-project.org/A8V8WNxkzdxU

The remaining NOTE is the expected CRAN incoming feasibility NOTE for a new
submission. The win-builder log also reported possible spelling items in
`DESCRIPTION`: `SHA`, `codebook`, and `embeddable`. These have been reviewed:
`SHA` refers to cryptographic hashing, `codebook` refers to survey codebook
documentation, and `embeddable` describes browser-based survey deployment.

## R-hub / GitHub Actions results

The package was checked using the R-hub GitHub Actions workflow before
submission.

- Ubuntu latest, R-release: 0 ERRORs, 0 WARNINGs
- Ubuntu latest, R-devel: 0 ERRORs, 0 WARNINGs
- Windows latest, R-release: 0 ERRORs, 0 WARNINGs
- macOS latest, R-release: 0 ERRORs, 0 WARNINGs

The GitHub Actions annotations about Node.js deprecation and Windows runner
redirection are workflow-environment notices, not package check failures.

## Final submission notes

This is the first CRAN submission of surveyframe.

## Language and spelling

The package uses British English intentionally. The `DESCRIPTION` file uses
`Language: en-GB`. Terms such as "serialisation", "behaviour", "centred",
and related spellings follow British English. Package-specific terms and names
such as `sframe`, `Quarto`, `jsonlite`, `lavaan`, and `seminr` are intentional.

## Internal helper testing

Some tests use `surveyframe:::` to call internal helper functions, including
branching, response-row construction, required-item checks, and CSV persistence
helpers. These functions are intentionally internal because they support
implementation details of survey rendering and response persistence. They are
tested directly to protect user-facing functions such as `render_survey()`.

The functions are not exported because they are not part of the public API.

## Package scope

surveyframe supports survey research workflows centred on a single typed
object, the `sframe`. The package combines instrument design, deployment,
quality checking, scale scoring, psychometric diagnostics, analysis-plan
execution, model syntax planning, and reproducible reporting.

## Dependency strategy

Hard imports are limited to packages that cover file-format serialisation,
condition signalling, and integrity hashing:

- `jsonlite` (>= 1.8.0): `.sframe` JSON serialisation
- `rlang` (>= 1.1.0): typed conditions and argument matching
- `openssl` (>= 2.1.0): integrity hashing

Optional features are guarded at call time:

- `shiny` (>= 1.7.0): `render_survey()`, `launch_studio()`, and dashboard tools
- `psych` (>= 2.3.0): `reliability_report()`, `item_report()`, and `efa_report()`
- `MASS`: optional ordinal logistic regression with `MASS::polr()`
- `nnet`: optional multinomial logistic regression with `nnet::multinom()`
- `googlesheets4` (>= 1.1.0): `read_sheet_responses()`
- `digest` (>= 0.6.0): response IDs in `survey_module_server()`
- Quarto CLI: `render_report()` with fallback to an internal HTML renderer

Tests that use optional packages include `skip_if_not_installed()` guards.

## Bundled asset

`inst/builder/survey_builder.html` is a self-contained browser application
authored for this package. It contains no third-party minified JavaScript. All
CSS and JavaScript are package code written in-line to avoid external network
dependencies. The file is opened with `utils::browseURL()` by
`launch_builder(open = TRUE)`.

`inst/extdata/` contains small simulated demo instruments and response CSVs.
The tourism-services demo supports runnable examples for response loading,
quality checks, scoring, analysis-plan execution, reporting, and syntax
generation. The input-types demo supports GUI, builder, studio, dashboard, and
item-control coverage. These files contain no human-subject or private data.

## `\dontrun{}` usage

All examples wrapped in `\dontrun{}` require one of:

- an interactive browser session (`launch_builder()`, `launch_studio()`),
- a running Shiny process (`render_survey()`),
- file I/O to a temporary path (`write_sframe()`, `read_sframe()`),
- optional packages that may not be installed (`reliability_report()`,
  `item_report()`, `efa_report()`), or
- optional Quarto CLI rendering.

Constructor functions (`sf_instrument()`, `sf_item()`, `sf_choices()`,
`sf_scale()`, `sf_branch()`, `sf_check()`) have fully runnable examples.
`launch_builder(open = FALSE)` also has a runnable example that returns the
bundled file path without opening a browser.

## Reverse dependencies

None. This is a first submission.