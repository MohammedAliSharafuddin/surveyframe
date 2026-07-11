# CRAN submission notes - surveyframe 0.3.3

## Summary

This release adds an opt-in plotting layer, redesigns the exported survey for
mobile and WCAG 2.2 AA accessibility, and fixes bugs surfaced by the package's
first field deployment. ggplot2 joins Suggests as an optional dependency; hard
dependencies (jsonlite, rlang, openssl) are unchanged.

## Changes in this release

1. New `plots` argument on `run_analysis_plan()` (default `FALSE`). When
   `TRUE`, supported analysis blocks return a ggplot object in `$plot`, drawn
   with a new exported `theme_surveyframe()`. Inferential runners also gain a
   `$table` data frame ready for `knitr::kable()`.
2. `render_report()` attaches each analysis block's chart directly beneath its
   result table, and Likert items in the response-distributions section get a
   diverging stacked bar chart instead of a plain frequency bar.
3. Ranking and multiple-choice items now export one column per option (rank
   value, or 0/1 for multiple-choice) instead of a single comma-joined
   column. `read_responses()` and the Google Sheets collector script accept
   the expanded columns without warnings.
4. A full visual redesign of the exported static survey: serif question
   typography, bordered option cards, numbered Likert squares, and a slim
   progress bar, all driven from the instrument's single theme colour.
5. The exported survey and SurveyBuilder now meet WCAG 2.2 AA: accessible
   names on every control, visible keyboard focus, announced validation
   errors, keyboard-operable ranking reorder, and 44 pixel minimum touch
   targets. A matrix question reflows into stacked, labelled cards below 600
   pixels of width instead of requiring horizontal scrolling.
6. Fixed a live-deployment bug where the exported survey's response POST was
   silently dropped by some hosts because of a CORS preflight; submissions
   now use a `no-cors` request that Google Apps Script Web Apps accept
   reliably.
7. SurveyBuilder's Add-question control and Settings entry point were each
   duplicated in two places in the interface; both now have a single,
   consistent entry point.
8. Vignettes updated to describe the redesigned survey, the expanded export
   columns, and the new `plots = TRUE` argument.

## Test environments

- Local: Ubuntu, R 4.6.0 (2026-04-24), x86_64-pc-linux-gnu
- win-builder: R 4.6.1 (release, 2026-06-24 ucrt)
- win-builder: R-devel (unstable, 2026-07-10 r90234 ucrt)

## R CMD check results

`R CMD check --as-cran` returned Status: OK with 0 errors, 0 warnings, and 0
notes on every environment:

- Local (2026-07-11, clean checkout of the release commit): Status: OK.
- win-builder R-release (2026-07-11): Status: OK.
- win-builder R-devel (2026-07-11): Status: OK.

## Reverse dependencies

surveyframe has no reverse dependencies on CRAN.

## Submission outcome

Submitted 2026-07-11. Accepted the same day: CRAN's auto-check service
confirmed the package was on its way to CRAN, with Result: OK on
r-devel-linux-x86_64-debian-gcc and r-devel-windows-x86_64.
