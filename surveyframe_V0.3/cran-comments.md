# CRAN submission notes - surveyframe 0.3.0

## Test environments

- Local: Ubuntu 24.04.4 LTS, R 4.6.0 (`R CMD check --as-cran`)
- win-builder: R-devel, R-release
- rhub: `ubuntu-latest` (R release), `windows-latest` (R release), `macos-latest` (R release)

## R CMD check results

Local source-tarball check currently has 0 errors and 0 warnings.

The local Linux check reports one expected note:

- New submission.

HTML manual validation was run with HTML Tidy and passed. The bundled
SurveyBuilder HTML and a generated static survey HTML export were also
validated with HTML Tidy.

win-builder and rhub checks are pending for the final v0.3.0 tarball.

## Resubmission notes

This is the first CRAN submission of surveyframe.

## Package scope

surveyframe provides an end-to-end survey research workflow centred on a
single typed object (the `sframe`). The package combines instrument design,
deployment, quality checking, scale scoring, psychometric diagnostics,
analysis-plan execution, and reproducible reporting in one unified pipeline.

## Dependency strategy

Hard imports are limited to three packages that cover file-format
serialisation and condition signalling:

- `jsonlite` (>= 1.8.0): `.sframe` JSON serialisation
- `rlang` (>= 1.1.0): typed conditions and argument matching
- `openssl` (>= 2.1.0): SHA-256 integrity hashing

Optional features are guarded at call time with `rlang::check_installed()`:

- `shiny` (>= 1.7.0): `render_survey()` and `launch_studio()`
- `psych` (>= 2.3.0): `reliability_report()` and `efa_report()`
- `googlesheets4` (>= 1.1.0): `read_sheet_responses()`
- `digest` (>= 0.6.0): response IDs in `survey_module_server()`
- Quarto CLI: `render_report()` (falls back to an internal HTML renderer)

## Bundled asset

`inst/builder/survey_builder.html` is a self-contained browser application
authored entirely for this package. It contains no third-party minified
JavaScript. All CSS and JS is original package code written in-line to
eliminate external network dependencies. The file is opened with
`utils::browseURL()` by `launch_builder(open = TRUE)`.

## `\dontrun{}` usage

All examples wrapped in `\dontrun{}` require one of:

- an interactive browser session (`launch_builder()`, `launch_studio()`),
- a running Shiny process (`render_survey()`),
- file I/O to a temporary path (`write_sframe()`, `read_sframe()`), or
- optional packages that may not be installed (`reliability_report()`,
  `efa_report()`, `render_report()` with Quarto).

Constructor functions (`sf_instrument()`, `sf_item()`, `sf_choices()`,
`sf_scale()`, `sf_branch()`, `sf_check()`) have fully runnable examples.
`launch_builder(open = FALSE)` also has a runnable example that returns
the bundled file path without opening a browser.

## Reverse dependencies

None (first submission).
