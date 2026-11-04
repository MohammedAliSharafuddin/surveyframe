# tests/testthat/test-report-quarto-engine.R
#
# Session 8b-R, item 1 (owner 2026-10-31). Quarto is the report engine.
# Without it the built-in engine writes a short plain results page under a
# banner that says how to get the full report. The sections only the
# built-in engine had (the Quality summary table and Respondent-wise
# missingness) are in the Quarto template, and the Quarto report names the
# copy of Quarto that rendered it.

demo_with_data <- function() {
  d <- sframe_demo("likert_scale")
  list(instrument = d$instrument, data = d$responses)
}

test_that("the built-in report carries the Install Quarto banner", {
  d <- demo_with_data()
  f <- tempfile(fileext = ".html")
  surveyframe:::.render_report_html(d$instrument, d$data, output_path = f,
                                    include_analysis = FALSE)
  doc <- paste(readLines(f, warn = FALSE), collapse = "\n")
  expect_match(doc, "Install Quarto for the full formatted report", fixed = TRUE)
  expect_match(doc, "href=\"https://quarto.org/docs/get-started/\"", fixed = TRUE)
  # The banner comes before the first section.
  expect_lt(regexpr("sf-banner", doc, fixed = TRUE), regexpr("<section>", doc, fixed = TRUE))
})

test_that("the Quarto template carries the sections only the built-in engine had", {
  qmd <- paste(readLines(system.file("templates", "report.qmd", package = "surveyframe")),
               collapse = "\n")
  expect_match(qmd, "caption = \"Quality summary\"", fixed = TRUE)
  expect_match(qmd, "caption = \"Respondent-wise missingness\"", fixed = TRUE)
  expect_match(qmd, "content$quality_note", fixed = TRUE)
  expect_match(qmd, "params$quarto_found", fixed = TRUE)
})

test_that("the Quarto report has the quality table, respondent missingness and its Quarto", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  old <- options(surveyframe.use_quarto = TRUE)
  on.exit(options(old), add = TRUE)
  d <- demo_with_data()
  out <- tempfile(fileext = ".html")
  res <- suppressMessages(render_report(d$instrument, data = d$data, output_file = out,
                                        include_analysis = FALSE, open = FALSE))
  expect_identical(attr(res, "engine"), "quarto")
  found <- surveyframe:::sframe_quarto_find()
  expect_identical(attr(res, "quarto"), found$path)
  doc <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(doc, "Quality summary", fixed = TRUE)
  expect_match(doc, "Respondent-wise missingness", fixed = TRUE)
  expect_match(doc, paste0("Quarto:</strong> ", found$version), fixed = TRUE)
  expect_false(grepl("Install Quarto for the full formatted report", doc, fixed = TRUE))
})
