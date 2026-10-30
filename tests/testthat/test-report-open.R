# tests/testthat/test-report-open.R
#
# Found by the owner, 2026-10-27. render_report() finished with "Report
# rendered with the Quarto engine: two_group_report.html", a relative path
# that left no clue where the file was, said nothing while Quarto worked for
# a minute, and showed nothing. It now names the full path, says when Quarto
# starts, and opens the report in an interactive session.

test_that("the report's message names its full path", {
  out <- file.path(tempdir(), "open-test.html")
  writeLines("<html></html>", out)
  old <- setwd(tempdir()); on.exit(setwd(old))
  expect_message(surveyframe:::sframe_report_result("open-test.html", "html"),
                 normalizePath(out), fixed = TRUE)
})

test_that("open = TRUE shows the report, and a script leaves it alone", {
  shown <- NULL
  local_mocked_bindings(sframe_show = function(path, ...) shown <<- path)
  out <- tempfile(fileext = ".html"); writeLines("<html></html>", out)
  suppressMessages(surveyframe:::sframe_report_result(out, "html", open = TRUE))
  expect_identical(shown, out)
  shown <- NULL
  ins <- sf_instrument("Open", components = list(sf_item("q1", "Q", type = "text")))
  suppressMessages(render_report(ins, output_file = tempfile(fileext = ".html")))
  expect_null(shown)
})
