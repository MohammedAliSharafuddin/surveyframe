# tests/testthat/test-report-title-authors.R
#
# Ethos request 23 (2026-10-03). The Quarto report was titled "Survey Research
# Report" and carried a "Published" line, whatever the study was called and
# whoever wrote it, and render_report() took no title or author.

titled_instrument <- function() {
  ins <- sframe_demo("two_group")$instrument
  ins$meta$title <- "Session format and satisfaction"
  ins$meta$authors <- c("Rahman, A.", "Lee, K.")
  ins
}

test_that("23: the built-in engine uses the instrument's title and authors", {
  path <- tempfile(fileext = ".html")
  surveyframe:::.render_report_html(titled_instrument(), output_path = path,
                                    include_analysis = FALSE, title = "Session format and satisfaction",
                                    authors = c("Rahman, A.", "Lee, K."))
  html <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_match(html, "<h1>Session format and satisfaction</h1>", fixed = TRUE)
  expect_match(html, "Rahman, A., Lee, K.", fixed = TRUE)
})

test_that("23: the Quarto report takes title and authors, and says Rendered", {
  skip_on_cran()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto not installed")
  d <- sframe_demo("two_group")
  ins <- titled_instrument()
  out <- tempfile(fileext = ".html")
  res <- suppressMessages(render_report(ins, d$responses, output_file = out,
                                        include_analysis = FALSE))
  skip_if(!identical(attr(res, "engine"), "quarto"), "report fell back to the built-in engine")
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(html, "Session format and satisfaction", fixed = TRUE)
  expect_match(html, "Rahman, A.", fixed = TRUE)
  expect_no_match(html, "Survey Research Report", fixed = TRUE)
  expect_no_match(html, ">Published<", fixed = TRUE)
  expect_match(html, "Rendered", fixed = TRUE)

  out2 <- tempfile(fileext = ".html")
  suppressMessages(render_report(ins, d$responses, output_file = out2,
                                 include_analysis = FALSE, title = "A chosen title",
                                 authors = "Someone, B."))
  html2 <- paste(readLines(out2, warn = FALSE), collapse = "\n")
  expect_match(html2, "A chosen title", fixed = TRUE)
  expect_match(html2, "Someone, B.", fixed = TRUE)
})
