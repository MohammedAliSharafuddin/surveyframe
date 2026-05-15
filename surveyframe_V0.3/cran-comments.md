# CRAN submission notes - surveyframe 0.3.0

## Test environments

- Local: Windows 11 x64, R 4.5.2 ucrt
- win-builder: R-devel, Windows
- win-builder: R-release, Windows
- R-hub: Windows
- R-hub: macOS
- R-hub: Ubuntu Linux

## R CMD check results

Local direct `R CMD check --as-cran` on the built source tarball:

- Windows 11 x64
- R 4.5.2 ucrt
- Status: 0 ERRORs, 0 WARNINGs, 2 NOTEs

The remaining NOTEs are:

1. CRAN incoming feasibility NOTE:
   - This is a new submission.
   - Maintainer details were reported.

2. Future file timestamps NOTE:
   - The local environment was unable to verify the current time.

Package build, installation, examples, tests, vignettes, namespace checks,
Rd checks, HTML manual checks, PDF manual generation, and R code diagnostics
passed locally.

No local package-code ERROR or WARNING remains.

## win-builder results

The package was checked on win-builder before submission.

- win-builder R-devel: 0 ERRORs, 0 WARNINGs, [insert number] NOTEs
- win-builder R-release: 0 ERRORs, 0 WARNINGs, [insert number] NOTEs

[If there are NOTEs, briefly list them here. If only the new-submission NOTE appears, write: The remaining NOTE is the expected new-submission NOTE.]

## R-hub results

The package was checked on R-hub before submission.

- R-hub Windows: 0 ERRORs, 0 WARNINGs, [insert number] NOTEs
- R-hub macOS: 0 ERRORs, 0 WARNINGs, [insert number] NOTEs
- R-hub Ubuntu Linux: 0 ERRORs, 0 WARNINGs, [insert number] NOTEs

[If there are NOTEs, briefly list them here. If any platform reports only minor spelling, timing, or new-submission notes, explain them clearly.]

## Resubmission notes

This is the first CRAN submission of surveyframe.

## Language and spelling

The package uses British English intentionally. The `DESCRIPTION` file therefore
uses `Language: en-GB`. Terms such as "serialisation", "behaviour", "centred",
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
- `openssl` (>= 2.1.0): SHA-256 integrity hashing

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