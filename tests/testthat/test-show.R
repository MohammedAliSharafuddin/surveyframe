# tests/testthat/test-show.R
#
# One rule for showing a file (REVIEW_0.4.3_FIRST_CONTACT.md section 6): the
# viewer RStudio, Positron and VS Code set in getOption("viewer"), else the
# web browser, and nothing at all in a script, a knitr or Quarto render, or
# with the caller's option off. It replaced a call to rstudioapi in
# reporting.R, which broke the rule that only the Addins use rstudioapi.

show_fixture <- function(dir = tempfile("show-")) {
  dir.create(dir, showWarnings = FALSE)
  out <- file.path(dir, "r.html")
  writeLines("<html></html>", out)
  out
}

test_that("with a viewer set, a file in the temp folder goes to it as it is", {
  viewed <- NULL
  local_mocked_bindings(sframe_is_interactive = function() TRUE)
  old <- options(viewer = function(url, ...) viewed <<- url, knitr.in.progress = NULL)
  on.exit(options(old), add = TRUE)
  out <- show_fixture()
  surveyframe:::sframe_show(out)
  expect_identical(viewed, normalizePath(out))
})

test_that("with no viewer, the file opens in the browser", {
  opened <- NULL
  local_mocked_bindings(sframe_is_interactive = function() TRUE)
  local_mocked_bindings(browseURL = function(url, ...) opened <<- url, .package = "utils")
  old <- options(viewer = NULL, knitr.in.progress = NULL)
  on.exit(options(old), add = TRUE)
  out <- show_fixture()
  expect_true(surveyframe:::sframe_show(out))
  expect_identical(opened, paste0("file://", normalizePath(out)))
})

test_that("a script, a knitr render and an option set to FALSE open nothing", {
  calls <- 0
  local_mocked_bindings(browseURL = function(url, ...) calls <<- calls + 1, .package = "utils")
  old <- options(viewer = function(url, ...) calls <<- calls + 1,
                 knitr.in.progress = NULL, surveyframe.test_show = NULL)
  on.exit(options(old), add = TRUE)
  out <- show_fixture()

  local_mocked_bindings(sframe_is_interactive = function() FALSE)
  expect_false(surveyframe:::sframe_show(out))

  local_mocked_bindings(sframe_is_interactive = function() TRUE)
  options(knitr.in.progress = TRUE)
  expect_false(surveyframe:::sframe_show(out))

  options(knitr.in.progress = NULL, surveyframe.test_show = FALSE)
  expect_false(surveyframe:::sframe_show(out, option = "surveyframe.test_show"))
  expect_equal(calls, 0)
})

test_that("a missing file is not shown", {
  local_mocked_bindings(sframe_is_interactive = function() TRUE)
  expect_false(surveyframe:::sframe_show(tempfile(fileext = ".html")))
})
