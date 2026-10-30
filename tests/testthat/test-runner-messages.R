# tests/testthat/test-runner-messages.R
#
# CX-13. A runner that failed said "McNemar test failed." or "ANCOVA failed."
# and lost the condition R raised. Each message now names the block and the
# method, says what is wrong with the data, gives a remedy and keeps R's own
# message.

run_block <- function(method, roles, data, family = "inferential", options = list()) {
  items <- lapply(names(data), function(n) sf_item(n, n, type = "text"))
  inst <- sf_instrument(
    title = "Runner messages", version = "1.0.0", components = items,
    analysis_plan = list(list(
      id = "RQ3", research_question = "Why?", family = family,
      method = method, roles = roles, options = options))
  )
  suppressWarnings(run_analysis_plan(data, inst))[[1]]
}

expect_full_message <- function(msg, label) {
  expect_match(msg, "RQ3", fixed = TRUE)
  expect_match(msg, label, fixed = TRUE)
  expect_match(msg, "R said:", fixed = TRUE)
}

test_that("McNemar names the block, the data problem, the remedy and R's message", {
  d <- data.frame(a = c("yes", "yes", "yes", "yes"), b = c("yes", "no", "yes", "no"))
  res <- run_block("mcnemar", list(before = "a", after = "b"), d)
  expect_false(is.null(res$error))
  expect_false(identical(res$error, "McNemar test failed."))
  expect_full_message(res$error, "McNemar")
  expect_match(res$error, "paired", fixed = TRUE)
})

test_that("Friedman names the block, the data problem, the remedy and R's message", {
  d <- data.frame(a = c(NA, NA, NA), b = c(NA, NA, NA), c = c(1, 2, 3))
  res <- run_block("friedman", list(measures = c("a", "b", "c")), d)
  expect_false(is.null(res$error))
  expect_false(identical(res$error, "Friedman test failed."))
  expect_full_message(res$error, "Friedman")
})

test_that("a t-test with an infinite outcome says so", {
  d <- data.frame(g = rep(c("x", "y"), each = 5),
                  y = c(1, 2, 3, Inf, 5, 2, 3, 4, 5, 6))
  res <- run_block("t_test_ind", list(group = "g", outcome = "y"), d)
  expect_false(is.null(res$error))
  expect_match(res$error, "infinite", ignore.case = TRUE)
  expect_match(res$error, "'y'", fixed = TRUE)
  expect_match(res$error, "RQ3", fixed = TRUE)
})

test_that("ANCOVA names the block, the data problem, the remedy and R's message", {
  d <- data.frame(g = rep("a", 6), y = c(1, 2, 3, 4, 5, 6), z = c(2, 1, 4, 3, 6, 5))
  res <- run_block("ancova", list(group = "g", outcome = "y", covariates = "z"), d)
  expect_false(is.null(res$error))
  expect_false(identical(res$error, "ANCOVA failed."))
  expect_full_message(res$error, "ANCOVA")
})

test_that("EFA readiness with no usable rows says what is missing", {
  d <- data.frame(a = c(NA_real_, NA, NA), b = c(NA_real_, NA, NA), c = c(NA_real_, NA, NA))
  items <- lapply(names(d), function(n) sf_item(n, n, type = "likert"))
  inst <- sf_instrument(
    title = "EFA", version = "1.0.0",
    components = c(items, list(sf_scale("S", "S", items = c("a", "b", "c")))),
    analysis_plan = list(list(id = "RQ3", research_question = "Why?",
      family = "psychometric", method = "efa_readiness", roles = list(scales = "S")))
  )
  res <- suppressWarnings(run_analysis_plan(d, inst))[[1]]
  expect_false(is.null(res))
  expect_false(grepl("is empty", res$error, fixed = TRUE))
  expect_match(res$error, "RQ3 (EFA readiness)", fixed = TRUE)
  expect_match(res$error, "complete row", fixed = TRUE)
  expect_match(res$error, "Check that", fixed = TRUE)
})

test_that("no runner keeps a bare 'X failed.' message", {
  src <- strsplit(sframe_source_text("R", "statistics_reports.R"), "\n",
                  fixed = TRUE)[[1]]
  expect_false(any(grepl("error = \"[A-Za-z' -]+ failed\\.\"", src)))
})

test_that("lm's 0 (non-NA) cases error is explained as no usable responses", {
  msg <- sframe_condition_error(simpleError("0 (non-NA) cases"),
                                data.frame(y = 1), list(), "y")
  expect_match(msg, "^No usable responses reach this block")
  expect_match(msg, "R said: 0 (non-NA) cases", fixed = TRUE)
})
