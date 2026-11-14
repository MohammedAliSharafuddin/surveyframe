# study$preregistration (owner 2026-11-14): 6 optional texts a
# preregistration asks for beyond the plan blocks, sealed in the hash.

prereg_instrument <- function(pre = list(stopping_rule = "At 120 responses or on 30 June.",
                                         exclusion_rules = "Responses failing the attention check.")) {
  ins <- sframe_demo("two_group", preview = FALSE)$instrument
  # The demo's own study, with the preregistration added.
  ins$study$preregistration <- pre
  ins$meta$version <- "2.0.0"
  ins
}

test_that("a preregistration round-trips through write and read", {
  ins <- prereg_instrument()
  path <- tempfile(fileext = ".sframe")
  write_sframe(ins, path, new_instrument = TRUE)
  back <- read_sframe(path)
  expect_identical(sframe_get_study(back)$preregistration, ins$study$preregistration)
  expect_true(validate_sframe(back)$valid)
})

test_that("an empty, blank, unknown or non-text field is refused", {
  bad <- list(list(), list(stopping_rule = " "), list(foo = "x"),
              list(stopping_rule = c("a", "b")), "text")
  for (pre in bad) {
    v <- validate_sframe(prereg_instrument(pre), strict = FALSE)
    expect_false(v$valid, info = deparse(pre))
    expect_true(any(grepl("study$preregistration", v$problems, fixed = TRUE)), info = deparse(pre))
  }
})

test_that("editing 1 preregistration field changes the hash and needs an amendment", {
  path <- tempfile(fileext = ".sframe")
  write_sframe(prereg_instrument(), path, new_instrument = TRUE)
  read <- read_sframe(path)
  edited <- read
  edited$study$preregistration$stopping_rule <- "At 150 responses."
  expect_false(identical(surveyframe:::sframe_hash_value(edited), surveyframe:::sframe_hash_value(read)))
  expect_error(write_sframe(edited, tempfile(fileext = ".sframe")), "amend_sframe")
  amended <- suppressMessages(amend_sframe(read, edited, "other", "Raised the stopping rule.", tier = "design",
                                           deviation_report = "The stopping rule moved from 120 to 150 responses."))
  out <- tempfile(fileext = ".sframe")
  expect_no_error(write_sframe(amended, out))
  expect_identical(read_sframe(out)$study$preregistration$stopping_rule, "At 150 responses.")
})

test_that("sframe_get_study() returns the preregistration, NULL when absent", {
  expect_null(sframe_get_study(sframe_demo("two_group", preview = FALSE)$instrument)$preregistration)
  expect_identical(sframe_get_study(prereg_instrument())$preregistration$stopping_rule,
                   "At 120 responses or on 30 June.")
})

test_that("an instrument with no preregistration hashes as before", {
  ins <- sframe_demo("two_group", preview = FALSE)$instrument
  expect_identical(surveyframe:::sframe_hash_value(ins),
                   jsonlite::fromJSON(sframe_demo("two_group", preview = FALSE)$instrument_path)$hash$value)
})
