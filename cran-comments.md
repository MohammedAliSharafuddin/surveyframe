# CRAN submission notes - surveyframe 0.3.1

## Summary

This is a patch release. No new exported functions, no new statistical methods,
and no new bundled datasets. The release fixes six defects on the static-survey
to Google Sheets to R round-trip, and rewrites the main vignette as a worked
study.

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

## Test environments

- Local: Ubuntu 24.04 x86_64, R 4.5.0
- Local: Windows 11 x64, R 4.5.2 ucrt
- win-builder: r-devel-windows-x86_64

## R CMD check results

`R CMD check --as-cran` on the built source tarball:

- Ubuntu 24.04 x86_64, R 4.5.0 -- 0 ERRORs, 0 WARNINGs, 0 NOTEs
- Windows 11 x64, R 4.5.2 ucrt  -- 0 ERRORs, 0 WARNINGs, 0 NOTEs

Expected server-side NOTE only:

1. CRAN incoming feasibility NOTE: "Possibly misspelled words in DESCRIPTION"
   for the technical terms SHA (in SHA-256), codebook, and embeddable. These
   are legitimate technical terms and were accepted at 0.3.0.

## Vignette changes

The main vignette (`surveyframe.Rmd`) has been rewritten as a four-stage
worked study following a published tourism-services survey. The vignette
builds offline: the data-collection step uses `eval = FALSE` chunks because
the study data is private, and all other steps run against the bundled
tourism demo dataset.

## Reverse dependencies

None (first CRAN submission was 0.3.0).
