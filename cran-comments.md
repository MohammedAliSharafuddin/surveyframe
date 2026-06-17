# CRAN submission notes - surveyframe 0.3.2

## Summary

This release corrects the package citation, completes the S3 method surface for
the component classes, and improves the graphical tools and the HTML report. It
adds no new exported functions, no new statistical methods, no new bundled
datasets, and no new hard or suggested dependencies.

## Changes in this release

1. `inst/CITATION` reports the correct package title and reads the version
   dynamically from the package metadata.
2. Added `print()`, `format()`, and `summary()` methods for the component
   classes `sf_choices`, `sf_item`, `sf_scale`, `sf_branch`, `sf_check`, and
   `sf_model`.
3. SurveyBuilder gained in-browser export of a deployable survey and of the
   Google Sheets Apps Script collector, distinct Plan, Run preview, and Report
   outline stages, and plan reordering.
4. The exported survey gained a branding footer, consistent logo sizing, a page
   progress indicator for multi-page surveys, and a mobile layout.
5. SurveyStudio opens an instrument, previews the exact deployable survey, and
   analyses responses, with the response dashboard built in. Its Export buttons
   stay disabled until a valid instrument is loaded, and the Upload screen can
   read responses from a deployed Google Sheets collector.
6. `render_report()` and `render_results()` share one branded template, render
   reliably through Quarto when it is installed, include response-distribution
   plots, format tables, and round numeric values to two decimal places. Quarto
   remains optional, with a built-in HTML fallback.
7. Added the "Deploying a survey and collecting responses on free hosting"
   vignette, and the analysis, reliability, and validity vignettes now present
   their output as formatted tables and plots.

## Test environments

- Local: Ubuntu, R 4.6.0 (2026-04-24), x86_64-pc-linux-gnu
- win-builder: R-release and R-devel (pending at the time of writing)

## R CMD check results

`R CMD check --as-cran` was run on the local environment on 2026-06-17 against a
clean checkout of the release commit. It returned:

    Status: OK
    0 errors | 0 warnings | 0 notes

win-builder results will be added before submission.

## Reverse dependencies

surveyframe has no reverse dependencies on CRAN.
