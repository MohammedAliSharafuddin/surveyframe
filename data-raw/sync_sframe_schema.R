# data-raw/sync_sframe_schema.R
#
# Copies sframe-schema's instrument profile into the package as
# inst/schema/sframe_schema.json, byte for byte. The 2 copies had drifted:
# the bundled one did not require sframe_format and lacked references, so a
# file could be valid by the package's copy and invalid by the published
# schema (Ethos request 29). The published profile is the source, and
# test-sframe-schema.R fails when the copies differ and the sframe-schema
# repository sits beside this one.
#
# Run from the package root, with sframe-schema cloned beside it:
#   Rscript data-raw/sync_sframe_schema.R

source_path <- file.path("..", "sframe-schema", "schema", "sframe-instrument.schema.json")
target_path <- file.path("inst", "schema", "sframe_schema.json")

if (!file.exists(source_path)) {
  stop("sframe-schema's instrument profile was not found at ", source_path,
       ". Clone sframe-schema beside this repository.")
}
invisible(jsonlite::fromJSON(source_path, simplifyVector = FALSE))  # it parses
ok <- file.copy(source_path, target_path, overwrite = TRUE)
if (!ok) stop("Copying to ", target_path, " failed.")
cat("Copied ", source_path, " to ", target_path, "\n", sep = "")
