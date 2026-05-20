# CRAN submission notes - surveyframe 0.3.0 (resubmission)

## Resubmission notes

This is a resubmission addressing reviewer feedback from 2026-05-16:

1. **Title**: Removed "for R" from the end of the title.

2. **DESCRIPTION formatting**: Removed single quotes around `sframe` (it is
   an S3 class name, not a package name). Added single quotes around 'Shiny'
   as required for software names.

3. **`\dontrun{}` → `\donttest{}`**: Replaced `\dontrun{}` with `\donttest{}`
   in all examples where the function can be executed by the user. One
   remaining `\dontrun{}` in `read_sheet_responses()` is justified: the
   function requires live Google Sheets API authentication (an API key the
   user must supply). All other interactive examples (Shiny launchers, browser
   openers) now use `\donttest{}`. The `cfa_syntax()` lavaan fitting example
   retains `\dontrun{}` because `lavaan` is not a declared dependency and
   constitutes "missing additional software" per CRAN policy.

## Test environments

- Local: Ubuntu 24.04 x86_64, R 4.5.0
- Local: Windows 11 x64, R 4.5.2 ucrt
- win-builder: r-devel-windows-x86_64 (R Under development, 2026-05-14 r90050)

## R CMD check results

`R CMD check --as-cran` on the built source tarball:

- Ubuntu 24.04 x86_64, R 4.5.0 — 0 ERRORs, 0 WARNINGs, 0 NOTEs
- Windows 11 x64, R 4.5.2 ucrt  — 0 ERRORs, 0 WARNINGs, 0 NOTEs

Expected server-side NOTE only:

1. CRAN incoming feasibility NOTE: "New submission." (server-side only,
   not reproduced locally)

Package build, installation, examples, tests, vignettes, namespace checks,
Rd checks, HTML manual checks, PDF manual generation, and R code diagnostics
passed on both platforms.

## Package scope

surveyframe provides survey research workflows centred on a single typed
instrument object (the sframe). The package combines instrument design,
deployment, quality checking, scale scoring, psychometric diagnostics,
analysis-plan execution, model syntax planning, and reproducible reporting.

## Dependency strategy

Hard imports are limited to three packages:

- `jsonlite` (>= 1.8.0): '.sframe' JSON serialisation
- `rlang` (>= 1.1.0): typed conditions and argument matching
- `openssl` (>= 2.1.0): SHA-256 integrity hashing

Optional features are guarded at call time with `rlang::check_installed()`:

- `shiny` (>= 1.7.0): `render_survey()`, `launch_studio()`, dashboard
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
These files contain no human-subject or private data.

## `\dontrun{}` usage

The only remaining `\dontrun{}` occurrences require genuinely missing
infrastructure that the user must supply:

- `read_sheet_responses()`: requires live Google Sheets API authentication.
- `cfa_syntax()` lavaan fitting block: requires `lavaan`, which is not a
  declared package dependency.

## Reverse dependencies

None (first submission).
