# tests/testthat/test-amend-version.R
#
# Session 8a, item (b) (owner 2026-11-01). amend_sframe() gains `version`:
# NULL keeps the instrument's version, a string sets it, and when the version
# is unchanged a message suggests the next one. A design amendment moves the
# minor number (1.0.0 to 1.1.0), a pipeline amendment the patch number
# (1.0.0 to 1.0.1). The suggestion and its reason come from 1 R function, so
# Studio's dialog and the console say the same.

ver_instr <- function(label = "How was it?", version = "1.0.0") {
  sframe_instrument("Versions", version = version, components = list(
    sframe_item("q1", label, "text")))
}

test_that("(b) sframe_suggest_version() moves minor for design, patch for pipeline", {
  d <- sframe_suggest_version("1.0.0", "design")
  expect_identical(d$version, "1.1.0")
  expect_match(d$reason, "design", fixed = TRUE)
  p <- sframe_suggest_version("1.0.0", "pipeline")
  expect_identical(p$version, "1.0.1")
  expect_match(p$reason, "pipeline", fixed = TRUE)
  expect_identical(sframe_suggest_version("2.3.4", "design")$version, "2.4.0")
  expect_identical(sframe_suggest_version("1.2", "pipeline")$version, "1.2.1")
  expect_identical(sframe_suggest_version("3", "design")$version, "3.1.0")
  expect_null(sframe_suggest_version("draft", "design")$version)
  expect_identical(sframe_suggest_version("", "pipeline")$version, "1.0.1")
})

test_that("(b) version = NULL keeps the version and suggests the next", {
  expect_message(
    am <- amend_sframe(ver_instr(), ver_instr("How was it overall?"), "other",
                       "Wording.", tier = "pipeline"),
    "1.0.1", class = "sframe_version_suggestion")
  expect_identical(am$meta$version, "1.0.0")
})

test_that("(b) a version string sets it, inside the recorded content", {
  am <- expect_no_message(
    amend_sframe(ver_instr(), ver_instr("How was it overall?"), "other",
                 "Wording.", tier = "pipeline", version = "1.0.1"),
    class = "sframe_version_suggestion")
  expect_identical(am$meta$version, "1.0.1")
  log <- sframe_get_amendments(am)
  expect_identical(log$new_hash, sframe_content_hash(am))
  expect_true("version" %in% strsplit(log$changed_fields, ", ")[[1]])
})

test_that("(b) an after state that already has a new version is kept, no message", {
  expect_no_message(
    am <- amend_sframe(ver_instr(), ver_instr("Other", version = "2.0.0"),
                       "instrument_revision", "Rewritten.",
                       deviation_report = "Wording."),
    class = "sframe_version_suggestion")
  expect_identical(am$meta$version, "2.0.0")
})

test_that("(b) version must be a single string", {
  expect_error(amend_sframe(ver_instr(), ver_instr("x"), "other", "W.",
                            tier = "pipeline", version = 2),
               "version", class = "sframe_error")
})
