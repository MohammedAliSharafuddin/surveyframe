# tests/testthat/test-read-responses-leading-zero.R
#
# rr-11. Choice items whose declared codes are text such as "01" were read as
# numbers, so the leading zero was lost and the frequency table showed the
# declared options with a count of 0 and unlabelled rows 1 and 2.

leading_zero_instrument <- function(type = "single_choice") {
  sf_instrument(
    "Leading zeros",
    components = list(
      sf_choices("codes", c("01", "02"), c("First", "Second")),
      sf_item("q", "Choice", type = type, choice_set = "codes")
    ),
    analysis_plan = list(
      list(id = "F", method = "frequency", roles = list(variable = "q"))
    )
  )
}

test_that("text codes with leading zeros stay character", {
  i <- leading_zero_instrument()
  d <- read_responses(data.frame(q = c("01", "02", "01")), i)
  expect_type(d$q, "character")
  expect_equal(d$q, c("01", "02", "01"))
  path <- tempfile(fileext = ".csv")
  writeLines(c("q", "01", "02", "01"), path)
  expect_equal(read_responses(path, i)$q, c("01", "02", "01"))
})

test_that("the frequency table shows the declared labels with real counts", {
  i <- leading_zero_instrument()
  d <- read_responses(data.frame(q = c("01", "02", "01")), i)
  tab <- run_analysis_plan(d, i)[[1]]$table
  expect_equal(nrow(tab), 2L)
  expect_equal(tab$Value, c("First", "Second"))
  expect_equal(tab$Frequency, c(2, 1))
})

test_that("numeric-looking codes still read as numbers", {
  i <- sf_instrument("Plain", components = list(
    sf_choices("codes", 1:2, c("First", "Second")),
    sf_item("q", "Choice", type = "single_choice", choice_set = "codes")
  ))
  d <- read_responses(data.frame(q = c("1", "2", "1")), i)
  expect_type(d$q, "double")
  # as.character(1e5) is "1e+05", which must not count as a changed code.
  big <- sf_instrument("Big", components = list(
    sf_choices("codes", c(100000, 200000), c("First", "Second")),
    sf_item("q", "Choice", type = "single_choice", choice_set = "codes")
  ))
  expect_type(read_responses(data.frame(q = c("100000", "200000")), big)$q,
              "double")
  mixed <- sf_instrument("Mixed", components = list(
    sf_choices("codes", c("1", "2.5"), c("First", "Second")),
    sf_item("q", "Choice", type = "single_choice", choice_set = "codes")
  ))
  expect_type(read_responses(data.frame(q = c("1", "2.5")), mixed)$q,
              "double")
})
