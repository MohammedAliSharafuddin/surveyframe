# CRAN submission notes - surveyframe 0.3.0

## Test environments

- Local: Windows 11 x64, R 4.5.2 ucrt
- Local: Ubuntu 24.04 x86_64, R 4.5.0

## R CMD check results

Local direct `R CMD check --as-cran` on the built source tarball:

- Windows 11 x64, R 4.5.2 ucrt
- Status: 0 ERRORs, 0 WARNINGs, 0 NOTEs (local check)

- Ubuntu 24.04 x86_64, R 4.5.0
- Status: 0 ERRORs, 0 WARNINGs, 0 NOTEs

The following NOTEs are expected on CRAN servers only (not reproduced in
local checks):

1. CRAN incoming feasibility NOTE (server-side only):
   - This is a new submission.
   - Maintainer details were reported.

2. Future file timestamps NOTE (server-side only):
   - The CRAN server environment was unable to verify the current time.

Package build, installation, examples, tests, vignettes, namespace checks,
Rd checks, HTML manual checks, PDF manual generation, and R code diagnostics
passed locally on both platforms.

No local package-code ERROR or WARNING remains.

## Resubmission notes

This is the first CRAN submission of surveyframe.

## Package scope

surveyframe provides survey research workflows centred on a single typed
object (the `sframe`). The package combines instrument design, deployment,
quality checking, scale scoring, psychometric diagnostics, analysis-plan
execution, model syntax planning, and reproducible reporting.

## Dependency strategy

Hard imports are limited to three packages that cover file-format
serialisation and condition signalling:

- `jsonlite` (>= 1.8.0): `.sframe` JSON serialisation
- `rlang` (>= 1.1.0): typed conditions and argument matching
- `openssl` (>= 2.1.0): SHA-256 integrity hashing

Optional features are guarded at call time with `rlang::check_installed()`:

- `shiny` (>= 1.7.0): `render_survey()` and `launch_studio()`
- `psych` (>= 2.3.0): `reliability_report()` and `efa_report()`
- `MASS`: optional ordinal logistic regression with `MASS::polr()`
- `nnet`: optional multinomial logistic regression with `nnet::multinom()`
- `googlesheets4` (>= 1.1.0): `read_sheet_responses()`
- `digest` (>= 0.6.0): response IDs in `survey_module_server()`
- Quarto CLI: `render_report()` (falls back to an internal HTML renderer)

## Bundled asset

`inst/builder/survey_builder.html` is a self-contained browser application
authored entirely for this package. It contains no third-party minified
JavaScript. All CSS and JS is original package code written in-line to
eliminate external network dependencies. The file is opened with
`utils::browseURL()` by `launch_builder(open = TRUE)`.

`inst/extdata/` contains small simulated demo instruments and response CSVs.
The tourism-services demo supports runnable examples for response loading,
quality checks, scoring, analysis-plan execution, reporting, and syntax
generation. The input-types demo supports GUI, builder, studio, dashboard, and
item-control coverage. These files contain no human-subject or private data.

## `\dontrun{}` usage

All examples wrapped in `\dontrun{}` require one of:

- an interactive browser session (`launch_builder()`, `launch_studio()`),
- a running Shiny process (`render_survey()`),
- file I/O to a temporary path (`write_sframe()`, `read_sframe()`), or
- optional packages that may not be installed (`reliability_report()`,
  `efa_report()`), or optional Quarto CLI rendering.

Constructor functions (`sf_instrument()`, `sf_item()`, `sf_choices()`,
`sf_scale()`, `sf_branch()`, `sf_check()`) have fully runnable examples.
`launch_builder(open = FALSE)` also has a runnable example that returns
the bundled file path without opening a browser.

## Reverse dependencies

None (first submission).
