# tests/testthat/test-report-citation-sites.R
#
# Session 8b-R, item 5. A report shows each citation where it is used, as
# well as in the References list: the instrument's sources under its title,
# a scale's under its reliability table, an item's and a scale's in the
# codebook, a plan block's in its section, and the hypotheses' beside the
# hypotheses. In both engines.

cite_instrument <- function() {
  ins <- sframe_demo("likert_scale")$instrument
  rq2 <- which(vapply(ins$analysis_plan, function(b) identical(b$id, "RQ2"), logical(1)))
  ins$analysis_plan[[rq2]]$hypotheses <- list(alternative = "The scale is reliable.")
  sframe_add_references(
    ins,
    sframe_reference("whole_2001", "A source for the whole study", author = "Whole, A.", year = 2001),
    sframe_reference("scale_2002", "A source for the scale", author = "Scaler, B.", year = 2002,
                     cited_by = "scale:organisation"),
    sframe_reference("item_2003", "A source for an item", author = "Itemer, C.", year = 2003,
                     cited_by = "item:org_1"),
    sframe_reference("plan_2004", "A source for a plan block", author = "Planner, D.", year = 2004,
                     cited_by = "plan:RQ2"),
    sframe_reference("hyp_2005", "A source for a hypothesis", author = "Hypo, E.", year = 2005,
                     cited_by = "hypothesis:RQ2")
  )
}

# The text between a heading and the next heading of the same level.
section_of <- function(doc, heading, level = "h2") {
  start <- regexpr(heading, doc, fixed = TRUE)
  if (start < 0) return("")
  rest <- substring(doc, start + nchar(heading))
  end <- regexpr(paste0("<", level, "[ >]"), rest)
  if (end < 0) rest else substr(rest, 1, end)
}

check_sites <- function(doc) {
  expect_match(section_of(doc, "Reliability</h2>"), "Scaler, 2002", fixed = TRUE)
  expect_match(section_of(doc, "Codebook</h2>"), "Itemer, 2003", fixed = TRUE)
  expect_match(section_of(doc, "Codebook</h2>"), "Scaler, 2002", fixed = TRUE)
  # Inside the Analysis Plan section, past the table of contents.
  rq2 <- section_of(section_of(doc, "Analysis Plan</h2>"), "RQ 2:", "h3")
  expect_match(rq2, "Planner, 2004", fixed = TRUE)
  expect_match(rq2, "Hypo, 2005", fixed = TRUE)
  # Beside the hypotheses: after the H1 line and before the result.
  expect_lt(regexpr("Alternative hypothesis (H1)", rq2, fixed = TRUE),
            regexpr("Hypo, 2005", rq2, fixed = TRUE))
  refs <- section_of(doc, "References</h2>")
  for (who in c("Whole, A.", "Scaler, B.", "Itemer, C.", "Planner, D.", "Hypo, E.")) {
    expect_match(refs, who, fixed = TRUE)
  }
}

test_that("the keys a target cites follow the template's rule", {
  ins <- cite_instrument()
  f <- surveyframe:::sframe_cited_keys
  expect_identical(f(ins, "instrument"), "whole_2001")
  expect_identical(f(ins, "scale:organisation"), "scale_2002")
  expect_identical(f(ins, "hypothesis:RQ2"), "hyp_2005")
  expect_identical(f(ins, "plan:RQ9"), character(0))
})

test_that("the built-in report cites each source where it is used", {
  d <- sframe_demo("likert_scale")
  f <- tempfile(fileext = ".html")
  surveyframe:::.render_report_html(cite_instrument(), d$responses, output_path = f, show_code = FALSE)
  doc <- paste(readLines(f, warn = FALSE), collapse = "\n")
  expect_match(doc, "Draws on:</strong> (Whole, 2001)", fixed = TRUE)
  check_sites(doc)
})

test_that("the Quarto report cites each source where it is used", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  old <- options(surveyframe.use_quarto = TRUE)
  on.exit(options(old), add = TRUE)
  d <- sframe_demo("likert_scale")
  out <- tempfile(fileext = ".html")
  res <- suppressMessages(render_report(cite_instrument(), data = d$responses,
                                        output_file = out, show_code = FALSE, open = FALSE))
  expect_identical(attr(res, "engine"), "quarto")
  doc <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(doc, "Whole, 2001", fixed = TRUE)
  check_sites(doc)
})
