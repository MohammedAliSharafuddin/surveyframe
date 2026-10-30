# tests/testthat/test-kendall-report.R
# D9 (CX-17). Kendall's tau reports tau, interval, p and N with no df.
# Pearson and Spearman keep r(df) and r_s(df).

kendall_data <- function() {
  set.seed(1)
  x <- 1:30
  data.frame(a = x, b = x + stats::rnorm(30, sd = 6))
}

test_that("Kendall reports N and no df", {
  r <- suppressWarnings(sframe_run_correlation(kendall_data(), c("a", "b"), "kendall"))
  expect_match(r$apa, "^tau = -?[0-9.]+, 95% CI \\[.*\\], p .*, N = 30$")
  expect_no_match(r$apa, "tau\\(")
  expect_match(r$prompt, "tau = ")
  expect_no_match(r$prompt, "tau\\(")
  expect_null(r$df)
  tab <- sframe_result_table(r)
  expect_false("df" %in% names(tab))
  expect_equal(tab$n, 30)
})

test_that("Pearson and Spearman keep their degrees of freedom", {
  p <- sframe_run_correlation(kendall_data(), c("a", "b"), "pearson")
  s <- suppressWarnings(sframe_run_correlation(kendall_data(), c("a", "b"), "spearman"))
  expect_match(p$apa, "^r\\(28\\) = ")
  expect_match(s$apa, "^r_s\\(28\\) = ")
  expect_equal(p$df, 28)
  expect_true("df" %in% names(sframe_result_table(p)))
})
