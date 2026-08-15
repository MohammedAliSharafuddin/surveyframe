# CRAN submission notes - surveyframe 0.4.0

## Summary

Adds a multi-criteria decision analysis extension (10 methods, 2 new item
types) and a small-sample statistics track (Hodges-Lehmann, paired Wilcoxon
pseudomedian, exact Fisher odds-ratio CI, Firth logistic regression).
Fixes 4 pre-existing defects found by independent cross-validation and 2
S3 design defects raised by a Journal of Statistical Software editor:
`validate_sframe()`/`validate_model()` now return a visible diagnostic
object, and every result class gained accessor methods
(`as.data.frame()`, `sf_meta()`, `as_sframe()`, and others). Full detail
in NEWS.md. Hard dependencies (jsonlite, rlang, openssl) unchanged. RMCDA
and rstudioapi join Suggests, both guarded with `requireNamespace()`/
`rlang::check_installed()`.

2 breaking changes, both documented in NEWS.md: the validator return type
above, and the Shiny collector now emitting expansion columns for matrix,
ranking, and multi-select items rather than pipe-joined values.

## Test environments

- Local: Ubuntu, R 4.6.0, x86_64-pc-linux-gnu
- win-builder: R 4.6.1 (release, 2026-06-24 ucrt), checked 2026-08-15

## R CMD check results

Status: OK, 0 errors, 0 warnings, 0 notes, on both environments.

## Reverse dependencies

None on CRAN.

## Submission status

CRAN submissions are closed for scheduled maintenance from 2026-08-05 to
2026-08-19. Submitting on or after 2026-08-20.
