# tests/testthat/test-amend-render-wording.R
#
# Ethos request 10 (2026-10-01). The welcome, consent and thank-you wording
# sits inside the hash, so changing it needs an amendment. Ethos edited the
# JSON directly until it found that. amend_sframe()'s help now names the
# intended path, and this holds the path to working.

test_that("10: reworded consent goes through a pipeline amendment and writes", {
  ins <- sframe_demo("first_survey", branded = TRUE)$instrument
  path <- tempfile(fileext = ".sframe")
  write_sframe(ins, path, new_instrument = TRUE)
  published <- read_sframe(path)

  revised <- published
  revised$render$welcome$consent_text <- "I agree to take part."
  revised <- amend_sframe(published, revised, "other",
                          "Consent wording shortened", tier = "pipeline")
  expect_identical(revised$amendments[[length(revised$amendments)]]$changed_fields,
                   "render")
  expect_no_error(write_sframe(revised, path, overwrite = TRUE))
  expect_identical(read_sframe(path)$render$welcome$consent_text,
                   "I agree to take part.")
})

test_that("10: the same edit without an amendment is refused", {
  ins <- sframe_demo("first_survey", branded = TRUE)$instrument
  path <- tempfile(fileext = ".sframe")
  write_sframe(ins, path, new_instrument = TRUE)
  published <- read_sframe(path)
  published$render$welcome$consent_text <- "I agree to take part."
  expect_error(write_sframe(published, path, overwrite = TRUE), "amend_sframe")
})

test_that("10: amend_sframe()'s help names the path for screen wording", {
  rd <- sframe_source_text("man/amend_sframe.Rd")
  expect_match(rd, "Wording on the participant's screens", fixed = TRUE)
  expect_match(rd, "pipeline-tier amendment", fixed = TRUE)
})
