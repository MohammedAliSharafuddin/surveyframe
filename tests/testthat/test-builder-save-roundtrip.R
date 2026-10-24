# tests/testthat/test-builder-save-roundtrip.R
#
# A file saved from SurveyBuilder, judged by the R reader. The builder runs
# under V8 (helper-v8-builder.R), opens what write_sframe() wrote, and saves.
#
# Ethos request 28 (2026-10-06): the builder never wrote `sframe_format`, so
# every file saved from it failed sframe-schema's instrument profile, which
# requires the field. Of 30 real files Ethos validated, only the builder save
# failed, on that field alone.

test_that("28: a builder save carries sframe_format", {
  ctx <- builder_context()
  builder_open(ctx, sframe_demo("first_survey")$instrument)
  saved <- jsonlite::fromJSON(builder_save(ctx), simplifyVector = FALSE)
  expect_identical(saved$sframe_format, SFRAME_FORMAT_VERSION)
})

test_that("28: a file from before sframe_format gains it on a builder save", {
  ctx <- builder_context()
  path <- tempfile(fileext = ".sframe")
  write_sframe(sframe_demo("first_survey")$instrument, path)
  old <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  old$sframe_format <- NULL
  ctx$call("openSframeText", jsonlite::toJSON(old, auto_unbox = TRUE, null = "null"))
  saved <- jsonlite::fromJSON(builder_save(ctx), simplifyVector = FALSE)
  expect_identical(saved$sframe_format, SFRAME_FORMAT_VERSION)
})

test_that("a builder save reads back in R with its hash verified and its content unchanged", {
  ins <- sframe_demo("first_survey")$instrument
  ctx <- builder_context()
  builder_open(ctx, ins)
  back <- read_sframe(builder_save(ctx))
  expect_s3_class(back, "sframe")
  expect_identical(sframe_content_hash(back), sframe_content_hash(ins))
})

test_that("an amended instrument keeps its amendment log through a builder save", {
  ins <- sframe_demo("first_survey")$instrument
  revised <- ins
  revised$meta$description <- "Revised wording."
  revised <- amend_sframe(ins, revised, "other", "Wording", tier = "pipeline")
  ctx <- builder_context()
  builder_open(ctx, revised)
  back <- read_sframe(builder_save(ctx))
  expect_length(back$amendments, 1L)
  # And the reader's file can take a further write, which a lost or
  # inconsistent log would refuse.
  expect_no_error(write_sframe(back, tempfile(fileext = ".sframe")))
})
