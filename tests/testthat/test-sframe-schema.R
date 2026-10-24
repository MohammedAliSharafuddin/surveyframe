# tests/testthat/test-sframe-schema.R
# inst/schema/sframe_schema.json documents the .sframe format so a reviewer
# or a second tool can validate a file without installing surveyframe. No
# JSON Schema validation package is added as a dependency for this (none was
# already present) -- these checks confirm the schema's own required-key
# list stays in sync with what write_sframe() actually produces, by hand,
# which is what a schema is for either way.

schema_path <- function() {
  system.file("schema", "sframe_schema.json", package = "surveyframe")
}

test_that("the schema file is installed and parses as JSON", {
  path <- schema_path()
  skip_if(!nzchar(path), "schema not found via system.file(); run devtools::load_all() first")
  schema <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  expect_equal(schema$type, "object")
  # The bundled schema is sframe-schema's instrument profile, which describes
  # what write_sframe() writes, sframe_format included. read_sframe() also
  # reads older files without it. version, choices and scales are optional.
  expect_setequal(unlist(schema$required), c("sframe_format", "hash", "meta", "items"))
  expect_true(all(c("version", "choices", "scales") %in% names(schema$properties)))
})

test_that("a freshly written .sframe file's top-level keys match the schema's properties", {
  path <- schema_path()
  skip_if(!nzchar(path), "schema not found via system.file(); run devtools::load_all() first")
  schema <- jsonlite::fromJSON(path, simplifyVector = FALSE)

  item <- sf_item("q1", "How satisfied are you?", type = "text")
  instr <- sf_instrument("Demo", components = list(item))
  out <- tempfile(fileext = ".sframe")
  write_sframe(instr, out, overwrite = TRUE)
  written <- jsonlite::fromJSON(out, simplifyVector = FALSE)

  extra_keys <- setdiff(names(written), names(schema$properties))
  expect_equal(extra_keys, character(0))
  expect_true(all(schema$required %in% names(written)))
})

test_that("a .sframe file with an amendment round-trips its amendments key against the schema", {
  path <- schema_path()
  skip_if(!nzchar(path), "schema not found via system.file(); run devtools::load_all() first")
  schema <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  expect_true("amendments" %in% names(schema$properties))

  item <- sf_item("q1", "How satisfied are you?", type = "text")
  instr <- sf_instrument("Demo", components = list(item))
  item2 <- sf_item("q1", "How satisfied are you overall?", type = "text")
  revised <- sf_instrument("Demo", components = list(item2))
  amended <- amend_sframe(
    instr, revised,
    reason_code = "instrument_revision",
    reason_text = "wording",
    deviation_report = "wording only"
  )
  out <- tempfile(fileext = ".sframe")
  write_sframe(amended, out, overwrite = TRUE)
  written <- jsonlite::fromJSON(out, simplifyVector = FALSE)

  expect_true("amendments" %in% names(written))
  entry <- written$amendments[[1]]
  required_entry_keys <- schema$properties$amendments$items$required
  expect_true(all(required_entry_keys %in% names(entry)))
})

# Ethos request 29 (2026-10-06). The bundled copy did not require
# sframe_format and lacked references, while sframe-schema's instrument
# profile required the first and documented the second, so a file could be
# valid by one and invalid by the other. The bundled copy is now the profile,
# copied by data-raw/sync_sframe_schema.R.
test_that("29: the bundled schema is sframe-schema's instrument profile", {
  bundled <- schema_path()
  skip_if(!nzchar(bundled), "schema not found via system.file()")
  profile <- test_path("..", "..", "..", "sframe-schema", "schema",
                       "sframe-instrument.schema.json")
  skip_if(!file.exists(profile), "sframe-schema repository not beside this one")
  expect_identical(readLines(bundled, warn = FALSE), readLines(profile, warn = FALSE))
})

test_that("29: the bundled schema documents every field write_sframe() can write", {
  schema <- jsonlite::fromJSON(schema_path(), simplifyVector = FALSE)
  expect_true(all(c("sframe_format", "references", "designs", "amendments") %in%
                    names(schema$properties)))
  expect_identical(schema$properties$sframe_format$type, "string")
})
