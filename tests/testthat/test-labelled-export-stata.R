# tests/testthat/test-labelled-export-stata.R
#
# Ethos request 15 (2026-10-02). write_dta() received character value labels
# from sframe_export_labelled(), so a choice set coded a and b with labels A
# and B read back in Stata as A = 0 and B = 0. SPSS was correct.

text_coded <- function() {
  sf_instrument("Text codes", components = list(
    sf_item("fmt", "Preferred format", type = "single_choice", choice_set = "f"),
    sf_choices("f", values = c("online", "in_person", "hybrid"),
               labels = c("Online", "In person", "Hybrid"))))
}
answers <- data.frame(fmt = c("in_person", "online", NA, "hybrid", "online"))

test_that("15: text codes reach Stata as 1, 2, 3 in the set's order, with labels", {
  skip_if_not_installed("haven")
  path <- tempfile(fileext = ".dta")
  sframe_export_labelled(answers, text_coded(), path)
  back <- haven::read_dta(path)
  expect_identical(as.numeric(back$fmt), c(2, 1, NA, 3, 1))
  expect_identical(attr(back$fmt, "labels"),
                   c(Online = 1, `In person` = 2, Hybrid = 3))
  expect_identical(as.character(haven::as_factor(back$fmt)),
                   c("In person", "Online", NA, "Hybrid", "Online"))
})

test_that("15: SPSS keeps the text codes with their labels", {
  skip_if_not_installed("haven")
  path <- tempfile(fileext = ".sav")
  sframe_export_labelled(answers, text_coded(), path)
  back <- haven::read_sav(path)
  expect_identical(as.character(haven::zap_labels(back$fmt)),
                   c("in_person", "online", "", "hybrid", "online"))
  expect_identical(unname(attr(back$fmt, "labels")), c("online", "in_person", "hybrid"))
})

test_that("15: a code the set lacks leaves the Stata column as text", {
  skip_if_not_installed("haven")
  path <- tempfile(fileext = ".dta")
  odd <- data.frame(fmt = c("online", "elsewhere"))
  sframe_export_labelled(odd, text_coded(), path)
  back <- haven::read_dta(path)
  expect_type(back$fmt, "character")
  expect_identical(as.character(haven::zap_formats(haven::zap_label(back$fmt))),
                   c("online", "elsewhere"))
  expect_null(attr(back$fmt, "labels"))
})
