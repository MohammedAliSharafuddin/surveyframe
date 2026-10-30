# tests/testthat/test-quarto-build-under-test.R
#
# Session 2, third report (2026-10-30). Quarto renders in its own R process,
# which loaded the surveyframe installed earlier rather than the source under
# test. The report now records the surveyframe version and, where the install
# carries one, its commit, and this test checks that the Quarto process
# loaded the build under test. render_report() here is the helper's, which
# renders through that build (helper-quarto-build.R).

test_that("the Quarto report was rendered by the build under test", {
  skip_on_cran()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  old <- options(surveyframe.use_quarto = TRUE)
  on.exit(options(old), add = TRUE)
  ins <- sf_instrument(title = "Build check", components = list(
    sf_item("q1", "Comment", type = "text")))
  out <- tempfile(fileext = ".html")
  render_report(ins, output_file = out, open = FALSE)
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  line <- regmatches(html, regexpr("surveyframe:</strong> .*?</p>", html, perl = TRUE))
  expect_length(line, 1)

  src <- sframe_build_source()
  if (nzchar(src)) {
    version <- read.dcf(file.path(src, "DESCRIPTION"), fields = "Version")[1, 1]
    commit <- sframe_build_commit(src)
  } else {
    version <- as.character(utils::packageVersion("surveyframe"))
    commit <- utils::packageDescription("surveyframe")$RemoteSha %||% ""
  }
  expect_true(grepl(paste0("</strong> ", version), line, fixed = TRUE))
  if (nzchar(commit)) {
    expect_true(grepl(paste0("commit <code>", substr(commit, 1, 12), "</code>"), line,
                      fixed = TRUE))
  }
})
