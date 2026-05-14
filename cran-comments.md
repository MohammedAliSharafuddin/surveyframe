# CRAN submission notes - surveyframe 0.3.0

## Test environments

- Local: Ubuntu 24.04.4 LTS, R 4.6.0 (`R CMD check --as-cran`)

## R CMD check results

Local source-tarball check:

- 0 errors
- 0 warnings
- 1 note

The note is expected for a first submission:

- New submission.

The local check was run with HTML Tidy available, and both PDF and HTML
manual checks passed. Bundled HTML files were also validated locally with
`html-validate`. The SurveyBuilder source and static survey template pass
validation with style-only rules relaxed for intentional inline preview
styling. The SurveyBuilder GUI was smoke-tested in Google Chrome.

Pending external checks before submission: win-builder R-release,
win-builder R-devel, and rhub.

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

`inst/extdata/` contains one small simulated demo instrument and one simulated
response CSV. These files support runnable examples for response loading,
quality checks, scoring, analysis-plan execution, and report rendering. They
contain no human-subject or private data.

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
