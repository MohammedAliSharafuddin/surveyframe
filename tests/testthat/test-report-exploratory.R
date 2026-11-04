# tests/testthat/test-report-exploratory.R
#
# Session 8b-R, item 9 (owner 2026-11-04). A block whose result carries a
# significance test (a p value) and that declared no H0 and no H1 prints
# "Exploratory: no hypothesis declared before the data" before its result,
# in both engines, and the results record carries the same flag. The 2
# placeholder sentences count as not declared. Descriptive blocks print
# nothing extra, and a missing hypothesis stays valid.

label <- "Exploratory: no hypothesis declared before the data"

expl_instrument <- function(hypotheses = NULL) {
  ttest <- list(id = "RQ1", research_question = "Do the groups differ?",
                family = "group_comparison", method = "t_test_ind",
                roles = list(outcome = "score", group = "grp"))
  ttest$hypotheses <- hypotheses
  freq <- list(id = "RQ2", research_question = "How are the groups split?",
               family = "descriptive", method = "frequency", variables = "grp")
  sframe_instrument(title = "Exploratory", components = list(
    sframe_choice_set("ab", values = c("a", "b"), labels = c("A", "B")),
    sframe_item("score", "Score", type = "numeric"),
    sframe_item("grp", "Group", type = "single_choice", choice_set = "ab")),
    analysis_plan = list(ttest, freq))
}

expl_data <- data.frame(score = c(3, 4, 5, 6, 2, 3, 4, 7, 8, 6),
                        grp = rep(c("a", "b"), each = 5))

builtin_doc <- function(ins) {
  f <- tempfile(fileext = ".html")
  surveyframe:::.render_report_html(ins, expl_data, output_path = f, show_code = FALSE)
  paste(readLines(f, warn = FALSE), collapse = "\n")
}

block_text <- function(doc, rq) {
  start <- regexpr(paste0("RQ ", rq, ":"), substring(doc, regexpr("Analysis Plan</h2>", doc, fixed = TRUE)),
                   fixed = TRUE)
  plan <- substring(doc, regexpr("Analysis Plan</h2>", doc, fixed = TRUE))
  rest <- substring(plan, start)
  end <- regexpr("RQ [0-9]+:", substring(rest, 6))
  if (end < 0) rest else substr(rest, 1, end + 5)
}

test_that("the flag is set for a tested block with no hypothesis, and only then", {
  f <- surveyframe:::sframe_result_exploratory
  r <- run_analysis_plan(expl_data, expl_instrument())
  expect_true(f(r[[1]]))
  expect_false(f(r[[2]]))
  r2 <- run_analysis_plan(expl_data, expl_instrument(list(alternative = "The groups differ.")))
  expect_false(f(r2[[1]]))
  r3 <- run_analysis_plan(expl_data, expl_instrument(
    list(null = "No effect or association is present.",
         alternative = "An effect or association is present.")))
  expect_true(f(r3[[1]]))
  expect_true(validate_sframe(expl_instrument(), strict = FALSE)$valid)
})

test_that("the results record carries the flag", {
  r <- run_analysis_plan(expl_data, expl_instrument())
  rec <- jsonlite::fromJSON(surveyframe:::sframe_results_record_json(r, expl_instrument(), "s"),
                            simplifyVector = FALSE)
  expect_identical(vapply(rec$results, function(b) b$exploratory, logical(1)), c(TRUE, FALSE))
})

test_that("the built-in report prints the label before the result, only where it applies", {
  doc <- builtin_doc(expl_instrument())
  b1 <- block_text(doc, 1)
  expect_match(b1, label, fixed = TRUE)
  expect_lt(regexpr(label, b1, fixed = TRUE), regexpr("Result:", b1, fixed = TRUE))
  expect_false(grepl(label, block_text(doc, 2), fixed = TRUE))
  doc2 <- builtin_doc(expl_instrument(list(null = "The means are equal.")))
  expect_false(grepl(label, doc2, fixed = TRUE))
})

test_that("the Quarto report prints the label before the result, only where it applies", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  old <- options(surveyframe.use_quarto = TRUE)
  on.exit(options(old), add = TRUE)
  render <- function(ins) {
    out <- tempfile(fileext = ".html")
    res <- suppressMessages(render_report(ins, data = expl_data, output_file = out,
                                          show_code = FALSE, open = FALSE))
    expect_identical(attr(res, "engine"), "quarto")
    paste(readLines(out, warn = FALSE), collapse = "\n")
  }
  doc <- render(expl_instrument())
  b1 <- block_text(doc, 1)
  expect_match(b1, label, fixed = TRUE)
  expect_lt(regexpr(label, b1, fixed = TRUE), regexpr("Result:", b1, fixed = TRUE))
  expect_false(grepl(label, block_text(doc, 2), fixed = TRUE))
  expect_false(grepl(label, render(expl_instrument(list(alternative = "The groups differ."))),
                     fixed = TRUE))
})
