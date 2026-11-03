# tests/testthat/test-report-provenance.R
#
# Session 8a, item (e). The report's reproducibility block gave the
# instrument hash, the engine and the seed, and said nothing of the version
# or of the amendments the instrument went through, so a reader could not
# tell a revised instrument from the one first declared. It now gives the
# version and the amendment list, in both engines, from 1 table built in R.

amended_instr <- function() {
  path <- tempfile(fileext = ".sframe")
  write_sframe(sframe_demo("likert_scale")$instrument, path)
  before <- read_sframe(path)
  after <- before
  after$items[[1]]$label <- "A clearer label"
  a1 <- suppressMessages(amend_sframe(before, after, "other", "Clarified the wording of org_1.",
                                      tier = "pipeline", version = "1.0.1"))
  after2 <- suppressMessages(sframe_drop_items(a1, "org_4", from = "organisation"))
  suppressMessages(amend_sframe(a1, after2, "instrument_revision", "Dropped org_4.",
                                deviation_report = "org_4 loaded below .40.",
                                author = "A. Rahman", version = "1.1.0"))
}

test_that("(e) the amendment table lists every entry, oldest first", {
  tab <- sframe_report_amendments(amended_instr())
  expect_equal(nrow(tab), 2L)
  expect_identical(names(tab), c("Date", "Tier", "Reason", "What changed",
                                 "Deviation report", "Author", "Sign-off"))
  expect_identical(tab$Tier, c("pipeline", "design"))
  expect_match(tab$Reason[1], "Other: Clarified the wording of org_1.", fixed = TRUE)
  expect_match(tab$Reason[2], "Instrument revision: Dropped org_4.", fixed = TRUE)
  expect_identical(tab$`What changed`, sframe_get_amendments(amended_instr())$changed_fields)
  expect_identical(tab$`Deviation report`, c("", "org_4 loaded below .40."))
  expect_null(sframe_report_amendments(sframe_demo("likert_scale")$instrument))
})

test_that("(e) the built-in report gives the version and the amendments", {
  ins <- amended_instr()
  f <- tempfile(fileext = ".html")
  surveyframe:::.render_report_html(ins, NULL, output_path = f, include_analysis = FALSE)
  doc <- paste(readLines(f, warn = FALSE), collapse = "\n")
  expect_match(doc, "Instrument version</td>\\s*<td[^>]*>1.1.0", perl = TRUE)
  expect_match(doc, "Amendments (2)", fixed = TRUE)
  expect_match(doc, "Dropped org_4.", fixed = TRUE)
  expect_match(doc, "org_4 loaded below .40.", fixed = TRUE)

  plain <- sframe_demo("likert_scale")$instrument
  f2 <- tempfile(fileext = ".html")
  surveyframe:::.render_report_html(plain, NULL, output_path = f2, include_analysis = FALSE)
  doc2 <- paste(readLines(f2, warn = FALSE), collapse = "\n")
  expect_match(doc2, "No amendments are recorded.", fixed = TRUE)
})

test_that("(e) the Quarto template is fed the same table", {
  ins <- amended_instr()
  content <- sframe_report_content(ins)
  expect_identical(content$amendments, sframe_report_amendments(ins))
  qmd <- paste(readLines(system.file("templates", "report.qmd", package = "surveyframe")),
               collapse = "\n")
  expect_match(qmd, "content$amendments", fixed = TRUE)
  expect_match(qmd, "Instrument version", fixed = TRUE)
})

test_that("(e) the Quarto report gives the version and the amendments", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  old <- options(surveyframe.use_quarto = TRUE)
  on.exit(options(old), add = TRUE)
  out <- tempfile(fileext = ".html")
  render_report(amended_instr(), output_file = out, open = FALSE)
  doc <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(doc, "Instrument version:</strong> 1.1.0", fixed = TRUE)
  expect_match(doc, "Amendments (2)", fixed = TRUE)
  expect_match(doc, "org_4 loaded below .40.", fixed = TRUE)
})
