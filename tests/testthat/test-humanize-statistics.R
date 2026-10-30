# tests/testthat/test-humanize-statistics.R
# CX-21. The label lookup swaps a choice code for its label in a result
# table. It used to do so in every character cell, so a statistic that
# happened to equal a code ("Suggested factors" 2) printed as "Disagree".

humanize_instr <- function() {
  sf_instrument(
    "Humanize statistics",
    components = list(
      sf_choices("ag5", values = 1:5,
                 labels = c("Strongly disagree", "Disagree", "Neutral",
                            "Agree", "Strongly agree")),
      sf_item("q1", "Service quality", type = "likert", choice_set = "ag5")
    )
  )
}

test_that("the factor_structure demo keeps its suggested factor count", {
  dir <- system.file("extdata", "demos", package = "surveyframe")
  ins <- read_sframe(file.path(dir, "factor_structure.sframe"))
  d <- utils::read.csv(file.path(dir, "factor_structure_responses.csv"))
  res <- run_analysis_plan(d, ins)
  readiness <- Filter(function(r) identical(r$test, "efa_readiness"), res)[[1]]
  tbl <- readiness$table
  value <- tbl$Value[tbl$Statistic == "Suggested factors"]
  expect_match(value, "^[0-9]+$")
  expect_false(any(tbl$Value %in% c("Strongly disagree", "Disagree", "Neutral",
                                    "Agree", "Strongly agree")))
})

test_that("a statistics table keeps its numbers even when all equal codes", {
  lookup <- sframe_label_lookup(humanize_instr())
  tbl <- data.frame(Statistic = c("Bartlett df", "Suggested factors"),
                    Value = c("3", "2"), stringsAsFactors = FALSE)
  out <- sframe_humanize_table(tbl, lookup)
  expect_equal(out$Value, c("3", "2"))
})

test_that("a column mixing statistics and code-like numbers is left alone", {
  lookup <- sframe_label_lookup(humanize_instr())
  tbl <- data.frame(Term = c("a", "b"), Estimate = c("0.81", "2"),
                    stringsAsFactors = FALSE)
  out <- sframe_humanize_table(tbl, lookup)
  expect_equal(out$Estimate, c("0.81", "2"))
})

test_that("a column of response codes still reads as labels beside statistics", {
  lookup <- sframe_label_lookup(humanize_instr())
  tbl <- data.frame(Group = c("1", "2", "Total"), n = c(10L, 12L, 22L),
                    Mean = c("3.20", "2.00", "2.55"),
                    stringsAsFactors = FALSE)
  out <- sframe_humanize_table(tbl, lookup)
  expect_equal(out$Group, c("Strongly disagree", "Disagree", "Total"))
  expect_equal(out$n, c(10L, 12L, 22L))
  expect_equal(out$Mean, c("3.20", "2.00", "2.55"))
})

test_that("item ids still read as labels in cells and headers", {
  lookup <- sframe_label_lookup(humanize_instr())
  tbl <- data.frame(Variable = "q1", Mean = "2.00", stringsAsFactors = FALSE)
  out <- sframe_humanize_table(tbl, lookup)
  expect_equal(out$Variable, "Service quality")
  tbl2 <- data.frame(q1 = "4", stringsAsFactors = FALSE)
  out2 <- sframe_humanize_table(tbl2, lookup)
  expect_equal(names(out2), "Service quality")
  expect_equal(out2[[1]], "Agree")
})
