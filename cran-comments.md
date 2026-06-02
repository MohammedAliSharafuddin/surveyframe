# CRAN submission notes - surveyframe 0.3.1

## Summary

This is a patch release. No new exported functions, no new statistical methods,
and no new bundled datasets. The release fixes six defects on the static-survey
to Google Sheets to R round-trip, repairs a serialisation hash mismatch for
instruments built with named component lists, improves the first-time error
messages, and rewrites the main vignette as a worked study.

## Bug fixes in this release

1. `export_static_survey()` now renders the header logo and institution name
   so exported surveys match the Shiny renderer and the builder preview.
2. `export_static_survey()` now falls back to the instrument's stored
   `render$google_sheets_endpoint` when `endpoint_url` is not supplied.
3. The static survey now posts the respondent identifier as `respondent_id`,
   matching the Apps Script collector and `read_responses()`.
4. `export_google_sheet()` now includes matrix sub-item columns in the Apps
   Script header row so matrix answers are stored in the Sheet.
5. `read_sheet_responses()` now declares `started_at` as a meta column and no
   longer warns on every read.
6. Survey logos now keep their original MIME type so JPEG and GIF logos
   display correctly in the builder, the Shiny renderer, and the static export.

A serialisation defect is also fixed: `write_sframe()` now unnames the component
lists before serialisation, so instruments built with named lists round-trip
without an integrity-check hash mismatch on `read_sframe()`.

## Test environments

- Local: Ubuntu 24.04 x86_64, R 4.6.0
- win-builder: R-release (R 4.6.0, x86_64-w64-mingw32)
- win-builder: R-devel (x86_64-w64-mingw32)

The macOS builder at mac.r-project.org was unavailable at submission time. R-hub
on GitHub Actions was used for the macOS check.

## R CMD check results

`R CMD check --as-cran` on the built source tarball returned 0 ERRORs, 0
WARNINGs, and 1 NOTE on every platform.

The single NOTE is the CRAN incoming feasibility note reporting a short interval
since the previous release. Version 0.3.0 was published on 2026-05-21, and
version 0.3.1 is a bug-fix release submitted a few days later. The short interval
reflects the importance of the fixes rather than feature churn, see the
justification below.

## Justification for the update interval

surveyframe 0.3.1 repairs defects that break core functionality: the
static-survey to Google Sheets to R data-collection round-trip, and a
serialisation hash mismatch that raised an integrity error when reading back
instruments built with named component lists. These affect users following the
package's main workflow, so the fix follows 0.3.0 closely.

## Vignette changes

The main vignette (`surveyframe.Rmd`) has been rewritten as a worked study
following a published tourism-services survey. The vignette builds offline: the
data-collection step uses `eval = FALSE` chunks because the study data is
private, and all other steps run against the bundled tourism demo dataset.

## Reverse dependencies

None (first CRAN submission was 0.3.0).
