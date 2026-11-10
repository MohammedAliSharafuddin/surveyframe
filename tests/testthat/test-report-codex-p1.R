# tests/testthat/test-report-codex-p1.R
#
# Codex pass 1 at af1f806, report findings P1-01 to P1-05 (Session RF,
# owner 2026-11-10). Every check uses the two_group demo, in the built-in
# engine and, on the slow tier, the Quarto engine.

p1_demo <- function() {
  d <- sframe_demo("two_group")
  list(instrument = d$instrument, data = d$responses)
}

p1_builtin_html <- function(...) {
  d <- p1_demo()
  f <- tempfile(fileext = ".html")
  surveyframe:::.render_report_html(d$instrument, d$data, output_path = f,
                                    include_analysis = FALSE, ...)
  paste(readLines(f, warn = FALSE), collapse = "\n")
}

p1_quarto_html <- function() {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  old <- options(surveyframe.use_quarto = TRUE)
  on.exit(options(old), add = TRUE)
  d <- p1_demo()
  out <- tempfile(fileext = ".html")
  res <- suppressMessages(render_report(d$instrument, data = d$data,
                                        output_file = out,
                                        include_analysis = FALSE, open = FALSE))
  expect_identical(attr(res, "engine"), "quarto")
  paste(readLines(out, warn = FALSE), collapse = "\n")
}

# The row of the missing-data patterns table: pattern, n and percent cells.
p1_complete_row <- function(doc) {
  m <- regmatches(doc, regexpr(
    "Complete case \\(no missing items\\)\\s*</td>\\s*<td[^>]*>[^<]*</td>\\s*<td[^>]*>[^<]*</td>",
    doc, perl = TRUE))
  if (!length(m)) return(character(0))
  cells <- regmatches(m, gregexpr("<td[^>]*>[^<]*</td>", m, perl = TRUE))[[1]]
  trimws(gsub("<[^>]+>", "", cells))
}

test_that("P1-01: missing-data patterns store a percentage and a proportion", {
  d <- p1_demo()
  mr <- sframe_missing_data_results(d$data, d$instrument)
  expect_true(all(c("percent", "prop") %in% names(mr$patterns)))
  expect_equal(sum(mr$patterns$percent), 100)
  expect_equal(sum(mr$patterns$prop), 1)
  expect_equal(mr$patterns$percent, mr$patterns$prop * 100)
})

test_that("P1-01: the built-in report prints Complete case | 60 | 100", {
  expect_identical(p1_complete_row(p1_builtin_html()), c("60", "100"))
})

test_that("P1-01: the Quarto report prints Complete case | 60 | 100", {
  expect_identical(p1_complete_row(p1_quarto_html()), c("60", "100"))
})
