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
environment loading after CRAN submission. Confirmed: the
`sys.source`/`app_env` pattern is correct and no change needed.

Rebuild pkgdown docs after CRAN-facing files settle.

Run win-builder release and devel checks.

Run rhub checks.

Run URL and spelling checks when those packages are installed.

## Fixed in latest session

1.  [`launch_builder_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_builder_demo.md)
    rewritten: injects demo instrument JSON directly into a temporary
    copy of `survey_builder.html`. Demo questions, scales, and analysis
    plan are visible immediately — no manual Load .sframe step needed.
2.  [`launch_studio_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_studio_demo.md)
    and
    [`launch_dashboard_demo()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/launch_dashboard_demo.md):
    `launch.browser = TRUE` so the browser always opens automatically.
3.  `inst/shiny/dashboard/app.R`: replaced
    [`library(shiny)`](https://shiny.posit.co/) with a
    `requireNamespace` check and explicit `shiny::` prefixes for CRAN
    policy compliance.
4.  `db_quality_ui()`: `class = flag_class` added to `tags$tr()` so rows
    are colour-coded by flag status.
5.  `db_data_ui()`: download-button background colour now uses
    `sprintf("...%s...", THEME)` instead of
    `background:var(--cp,#2563eb)`.
6.  `db_overview_ui()`: date parsing delegated to
    `dashboard_parse_date()` for robust, error-free date display.
7.  [`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
    and
    [`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md):
    HTML report tables now use APA formatting — horizontal rules only,
    no vertical borders, no row shading. Significance footnote appended
    when p-value column detected.
8.  `demo/survey.R`: complete UX rewrite — section headers, contextual
    pause prompts, “In the browser: -\>” guidance, `ask_yn()` yes/no
    prompts, conversational mode for static survey export. Fully
    ASCII-safe.
9.  `dashboard_parse_date()` completely rewritten: tries six explicit
    format templates in priority order with `tryCatch` on each, plus a
    wrapped fallback. Non-matching strings return `NA` instead of
    throwing an error.
10. Dashboard Items and Scales tabs:
    `outputOptions(..., suspendWhenHidden = FALSE)` added for
    `item_chart` and `scale_chart`. Charts now render on first tab visit
    instead of appearing blank.
