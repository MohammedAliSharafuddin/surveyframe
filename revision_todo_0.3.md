# surveyframe 0.3 Revision Todo

This file consolidates the two reviewer-style reports plus the local CRAN
review performed on the current source package.

## Required Before CRAN Submission

- [x] Review the `setNames` namespace concern. Verified on R 4.6.0 that
      `setNames` is provided by `stats`, not `base`, and changed calls to use
      `stats::setNames()` explicitly.
- [x] Remove the local `%||%` definition and rely on the `rlang` import.
- [x] Remove `:::` calls from the installed Shiny studio app by exporting the
      builder helper functions it uses.
- [x] Change `export_static_survey()` so the default output path is in
      `tempdir()` rather than the working directory.
- [x] Remove the dead `chartr("", "", ...)` hash code.
- [x] Canonicalise `.sframe` hash payloads in R to match the JavaScript key
      sorting algorithm.
- [x] Assign the validated object in `write_sframe()` before serialisation.
- [x] Enforce documented item ID rules in `validate_sframe()`.
- [x] Check duplicate choice-set IDs and duplicate scale IDs in
      `validate_sframe()`.
- [x] Replace `app$serverFuncSource()` tests with public `shiny::testServer()`
      usage.

## Recommended Before Submission

- [x] Generate the R Core Team citation year at call time.
- [x] Change `Language` in `DESCRIPTION` to `en-GB` for spelling consistency.
- [x] Move generic helpers out of `conditions.R`.
- [x] Test the `render_report()` fallback renderer without requiring Quarto.
- [x] Add direct tests for `export_static_survey()`.
- [x] Make the `export_google_sheet()` test run without a `googlesheets4`
      skip.
- [x] Use or remove the `sheet_url` argument in `export_google_sheet()`.
- [x] Correct crosstab effect-size wording: phi for 2 by 2 tables and
      Cramer's V otherwise.
- [x] Guard vignette chunks that require optional packages.
- [x] Update `cran-comments.md` so it reports only completed checks after the
      final local check finishes.

## Cleanup / Maintainer Quality

- [x] Run local source tests with `testthat::test_local()`.
- [x] Build `surveyframe_0.3.0.tar.gz` from the revised source tree.
- [x] Run local `R CMD check --as-cran` including PDF and HTML manual checks.
- [x] Validate bundled HTML files with HTML Tidy and `html-validate`.
- [ ] Add short return-shape comments for internal analysis runners.
- [ ] Review Wilcoxon and Mann-Whitney APA wording so approximate z values are
      either computed explicitly or omitted.
- [x] Review `launch_dashboard()` environment loading after CRAN submission.
      Confirmed: the `sys.source`/`app_env` pattern is correct and no change needed.
- [ ] Rebuild pkgdown docs after CRAN-facing files settle.
- [ ] Run win-builder release and devel checks.
- [ ] Run rhub checks.
- [ ] Run URL and spelling checks when those packages are installed.

## Fixed in latest session

1. `launch_builder_demo()` rewritten: injects demo instrument JSON directly
   into a temporary copy of `survey_builder.html`. Demo questions, scales, and
   analysis plan are visible immediately — no manual Load .sframe step needed.
2. `launch_studio_demo()` and `launch_dashboard_demo()`: `launch.browser = TRUE`
   so the browser always opens automatically.
3. `inst/shiny/dashboard/app.R`: replaced `library(shiny)` with a
   `requireNamespace` check and explicit `shiny::` prefixes for CRAN policy
   compliance.
4. `db_quality_ui()`: `class = flag_class` added to `tags$tr()` so rows are
   colour-coded by flag status.
5. `db_data_ui()`: download-button background colour now uses
   `sprintf("...%s...", THEME)` instead of `background:var(--cp,#2563eb)`.
6. `db_overview_ui()`: date parsing delegated to `dashboard_parse_date()` for
   robust, error-free date display.
7. `render_report()` and `render_results()`: HTML report tables now use APA
   formatting — horizontal rules only, no vertical borders, no row shading.
   Significance footnote appended when p-value column detected.
8. `demo/survey.R`: complete UX rewrite — section headers, contextual pause
   prompts, "In the browser: ->" guidance, `ask_yn()` yes/no prompts,
   conversational mode for static survey export. Fully ASCII-safe.
9. `dashboard_parse_date()` completely rewritten: tries six explicit format
   templates in priority order with `tryCatch` on each, plus a wrapped
   fallback. Non-matching strings return `NA` instead of throwing an error.
10. Dashboard Items and Scales tabs: `outputOptions(..., suspendWhenHidden = FALSE)`
    added for `item_chart` and `scale_chart`. Charts now render on first tab
    visit instead of appearing blank.
