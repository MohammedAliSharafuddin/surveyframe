# surveyframe 0.3 Revision Todo

This file consolidates the two reviewer-style reports plus the local
CRAN review performed on the current source package.

## Required Before CRAN Submission

Review the `setNames` namespace concern. Verified on R 4.6.0 that
`setNames` is provided by `stats`, not `base`, and changed calls to use
[`stats::setNames()`](https://rdrr.io/r/stats/setNames.html) explicitly.

Remove the local `%||%` definition and rely on the `rlang` import.

Remove `:::` calls from the installed Shiny studio app by exporting the
builder helper functions it uses.

Change
[`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md)
so the default output path is in
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) rather than the
working directory.

Remove the dead `chartr("", "", ...)` hash code.

Canonicalise `.sframe` hash payloads in R to match the JavaScript key
sorting algorithm.

Assign the validated object in
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
before serialisation.

Enforce documented item ID rules in
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md).

Check duplicate choice-set IDs and duplicate scale IDs in
[`validate_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/validate_sframe.md).

Replace `app$serverFuncSource()` tests with public
[`shiny::testServer()`](https://rdrr.io/pkg/shiny/man/testServer.html)
usage.

## Recommended Before Submission

Generate the R Core Team citation year at call time.

Change `Language` in `DESCRIPTION` to `en-GB` for spelling consistency.

Move generic helpers out of `conditions.R`.

Test the
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
fallback renderer without requiring Quarto.

Add direct tests for
[`export_static_survey()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_static_survey.md).

Make the
[`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md)
test run without a `googlesheets4` skip.

Use or remove the `sheet_url` argument in
[`export_google_sheet()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/export_google_sheet.md).

Correct crosstab effect-size wording: phi for 2 by 2 tables and Cramer’s
V otherwise.

Guard vignette chunks that require optional packages.

Update `cran-comments.md` so it reports only completed checks after the
final local check finishes.

## Cleanup / Maintainer Quality

Run local source tests with
[`testthat::test_local()`](https://testthat.r-lib.org/reference/test_package.html).

Build `surveyframe_0.3.0.tar.gz` from the revised source tree.

Run local `R CMD check --as-cran` including PDF and HTML manual checks.

Validate bundled HTML files with HTML Tidy and `html-validate`.

Add short return-shape comments for internal analysis runners.

Review Wilcoxon and Mann-Whitney APA wording so approximate z values are
either computed explicitly or omitted.

Review
[`launch_dashboard()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard.md)
environment loading after CRAN submission.

Rebuild pkgdown docs after CRAN-facing files settle.

Run win-builder release and devel checks.

Run rhub checks.

Run URL and spelling checks when those packages are installed.
