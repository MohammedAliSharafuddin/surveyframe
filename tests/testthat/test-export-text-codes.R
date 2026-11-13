# P3-03 (Codex pass 3), Session CF-B: export_responses() and the reader share
# 1 test for "these codes are numbers". The export tested as.numeric() alone,
# so codes "01", "02" left as 1 and 2 in .sav and .dta, no longer matching
# the instrument.

cfb_text_code_instrument <- function() {
  sframe_instrument("P3", components = list(
    sframe_choice_set("c", c("01", "02"), c("First", "Second")),
    sframe_item("x", "Choice", "single_choice", choice_set = "c")))
}

test_that("the shared test reads 01 as text and 1 as a number", {
  expect_false(sframe_codes_are_numbers(c("01", "02")))
  expect_true(sframe_codes_are_numbers(c("1", "2")))
  expect_true(sframe_codes_are_numbers(1:3))
  expect_false(sframe_codes_are_numbers(c(" 1", "2")))
})

test_that("a .sav keeps codes 01 and 02 as labelled text that reads back as declared", {
  skip_if_not_installed("haven")
  i <- cfb_text_code_instrument()
  d <- data.frame(respondent_id = c("001", "002"), x = c("01", "02"))
  p <- tempfile(fileext = ".sav")
  export_responses(d, i, p)
  back <- haven::read_sav(p)
  expect_identical(as.character(haven::zap_labels(back$x)), c("01", "02"))
  expect_identical(unname(attr(back$x, "labels")), c("01", "02"))
  expect_identical(as.character(read_responses(back, i)$x), c("01", "02"))
})

test_that("a .dta writes codes 01 and 02 as positions 1 and 2 with their labels", {
  skip_if_not_installed("haven")
  i <- cfb_text_code_instrument()
  d <- data.frame(respondent_id = c("001", "002"), x = c("02", "01"))
  p <- tempfile(fileext = ".dta")
  export_responses(d, i, p)
  back <- haven::read_dta(p)
  expect_equal(as.numeric(haven::zap_labels(back$x)), c(2, 1))
  expect_identical(names(attr(back$x, "labels")), c("First", "Second"))
})
