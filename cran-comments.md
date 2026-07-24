# CRAN submission notes - surveyframe 0.3.4

## Summary

This release completes the plotting, interface, statistics, and reporting
work started in 0.3.3. Every analysis family gains a chart, every effect
size ships with a confidence interval, reports accept written
interpretations and can print to PDF, both dashboards gain quality and
correlation panels, date questions gain bounds, and the builder and
vignettes pass a WCAG 2.2 AA accessibility audit. Hard dependencies
(jsonlite, rlang, openssl) are unchanged. naniar and pagedown join Suggests,
both optional and guarded with `requireNamespace()`.

## Changes in this release

1. Four new exported base-R helpers for confidence intervals:
   `bootstrap_ci()`, `cohens_d_ci()`, `cramers_v_ci()`, `eta_sq_ci()`.
   Nine analysis-plan runners attach an interval to their effect size, and
   the APA strings carry it.
2. `validity_report()` computes the Henseler heterotrait-monotrait ratio
   from item-level data; `missing_data_report()` runs Little's MCAR test
   when naniar is installed; `reliability_report()` and `efa_solution()`
   gain additional diagnostics and tidy output frames.
3. `render_report(format = "pdf")` prints the HTML report to PDF through
   pagedown when a local Chrome or Chromium is available, and aborts with
   an actionable, typed error otherwise. HTML remains the default and is
   unchanged apart from the theming below.
4. A new `interpretations` argument on `render_report()` and
   `render_results()` lets a written interpretation be added to each
   research question after results are known, shown beside the
   pre-declared decision rule. Interpretations are report content only and
   are never written into the instrument file.
5. `run_analysis_plan(plots = TRUE)` now attaches a ggplot2 chart (with a
   base-graphics fallback when ggplot2 is unavailable) to every supported
   analysis family, and every analysis-plan block returns a table, a
   chart, or generated syntax.
6. New `date_min`/`date_max` bounds on `sf_item(type = "date")`, enforced
   in the builder inspector, the exported survey's native date picker, and
   page-level validation.
7. The exported survey, SurveyBuilder, and all seven vignettes pass a
   WCAG 2.2 AA audit (axe-core, zero violations).

## Test environments

- Local: Ubuntu, R 4.6.0 (2026-04-24), x86_64-pc-linux-gnu
- win-builder: R (release)
- win-builder: R-devel

## R CMD check results

`R CMD check --as-cran` returned Status: OK with 0 errors, 0 warnings, and
0 notes on every environment:

- Local (2026-07-25, release-candidate tarball): Status: OK.
- win-builder R-release: Status: OK.
- win-builder R-devel: Status: OK.

## Reverse dependencies

surveyframe has no reverse dependencies on CRAN.
