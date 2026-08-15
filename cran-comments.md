# CRAN submission notes - surveyframe 0.4.0

## Summary

This release adds a multi-criteria decision analysis (MCDA) extension and a
small-sample statistics track, corrects 4 pre-existing defects found by
independent cross-validation, and fixes 2 S3 design defects raised by a
Journal of Statistical Software editor: `validate_sframe()` and
`validate_model()` now return a visible `sframe_validation` diagnostic
object instead of silently returning the instrument or an unclassed list,
and every result class gained accessor and coercion methods
(`as.data.frame()`, class-preserving `[`, `sf_meta()`, `sf_items()`,
`as_sframe()`, and others). Hard dependencies (jsonlite, rlang, openssl) are
unchanged. RMCDA and rstudioapi join Suggests, both optional and guarded
with `requireNamespace()`/`rlang::check_installed()`.

This is 0.4.0, not 0.3.5: 0.3.5 was planned as a field-validation round and
0.5.0 was, at one stage, this release's own working label. Neither number
was released; both are absorbed into 0.4.0 and the following 0.4.1.

## Changes in this release

1. MCDA extension: 10 decision methods (AHP, ANP, DEMATEL, VIKOR, MOORA,
   SMART, WASPAS, PROMETHEE, ELECTRE, TOPSIS), 2 new item types
   (`pairwise_comparison`, `criteria_weight`) for collecting judgement data
   directly inside a survey instrument, a documented aggregation layer
   (`sframe_assemble_pairwise()`, `sframe_aggregate_judgements()`,
   `sframe_rated_matrix()`), and `sensitivity_analysis()` for perturbation
   checks on a ranking. Every method carries a verified literature citation.
   RMCDA is used in Suggests as a test-time cross-check oracle.
2. Small-sample statistics track: the Hodges-Lehmann shift estimator on
   Mann-Whitney, the paired Wilcoxon pseudomedian confidence interval, the
   exact odds-ratio confidence interval on Fisher's test, and Firth's
   bias-reduced logistic regression (logistf in Suggests), plus a
   small-sample advisory surfaced on `assumption_report()` and
   `sample_size_plan()`.
3. `sf_conjoint_design()` declares a conjoint design for data collection.
4. An RStudio add-in (4 menu items) ships in `inst/rstudio/addins.dcf`,
   owner-verified in a real RStudio session.
5. **Breaking**: `validate_sframe()` and `validate_model()` return an
   `sframe_validation` object visibly from both `strict` branches, rather
   than the previous behaviour (the instrument returned invisibly when
   `strict = TRUE`, a bare unclassed list when `strict = FALSE`). `$valid`
   and `$problems` keep working. Code using the `strict = TRUE` return as
   an instrument needs `as_sframe()`; a directed error names it if missed.
6. **New**: `as.data.frame()` now works on the instrument and all 14 result
   classes. `[` preserves class on 3 list-backed report types. New
   accessors: `sf_meta()`, `sf_items()`, `sf_scales()`, `sf_choice_sets()`,
   `sf_branches()`, `sf_checks()`, `sf_models()`, `sf_plan()`/`sf_plan<-`,
   `sf_id()`, `sf_label()`, `sf_apa()`, `sf_flagged()`, `sf_is_valid()`,
   `sf_problems()`, `sf_object()`, `as_sframe()`.
7. **Breaking**: the Shiny collector (`render_survey()`) now emits
   expansion columns for matrix, ranking, and multi-select items, matching
   the static template and Google Sheets collector. Responses collected
   under the old joined-column shape need re-shaping before they can be
   read; the new decision item types were unaffected, since they already
   emitted the correct columns.
8. 4 corrected results, none previously erroring or warning:
   `item_report()`'s item-rest correlation, repeated-measures ANOVA's error
   stratum, `validate_sframe()`'s expansion-column rejection, and the SEM
   syntax generators ignoring `model$type`.
9. `quality_report()` now counts expansion columns in its missingness
   figures; reported missingness rates will change for instruments using
   matrix, ranking, multi-select, or the 2 new decision item types.

## Test environments

- Local: Ubuntu, R 4.6.0, x86_64-pc-linux-gnu
- win-builder: R 4.6.1 (release, 2026-06-24 ucrt), checked 2026-08-15

## R CMD check results

`R CMD check --as-cran` returned Status: OK with 0 errors, 0 warnings, and
0 notes on every environment:

- Local (2026-08-15, release-candidate tarball): Status: OK.
- win-builder R-release (2026-08-15): Status: OK. Install 12 seconds,
  check 424 seconds.

## Reverse dependencies

surveyframe has no reverse dependencies on CRAN.

## Submission outcome

Not yet submitted to CRAN.
