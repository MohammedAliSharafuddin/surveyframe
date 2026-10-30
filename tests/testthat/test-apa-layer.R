# tests/testthat/test-apa-layer.R
# The one APA layer (CX-15, CX-22, CX-24, D9): result text, table cells and
# headings, and numbered tables and figures, formatted in one place for
# every renderer.

test_that("a statistic bounded by 1 loses its leading zero, others keep it", {
  expect_identical(
    sframe_apa_text("r(58) = 0.53, 95% CI [0.33, 0.69], p < .001"),
    "r(58) = .53, 95% CI [.33, .69], p < .001")
  expect_identical(sframe_apa_text("tau = -0.39, 95% CI [-0.60, -0.10], p = .004, N = 60"),
                   "tau = -.39, 95% CI [-.60, -.10], p = .004, N = 60")
  expect_identical(sframe_apa_text("r_s(28) = 0.55"), "r_s(28) = .55")
  expect_identical(sframe_apa_text("R\u00b2 = 0.362, F(2, 57) = 16.20, p < .001"),
                   "R\u00b2 = .362, F(2, 57) = 16.20, p < .001")
  expect_identical(
    sframe_apa_text("\u03c7\u00b2(1, N = 60) = 1.20, p = .273, Cramer's V = 0.24"),
    "\u03c7\u00b2(1, N = 60) = 1.20, p = .273, Cramer's V = .24")
  expect_identical(sframe_apa_text("F(2, 57) = 3.10, p = .052, \u03b7\u00b2 = 0.098"),
                   "F(2, 57) = 3.10, p = .052, \u03b7\u00b2 = .098")
  expect_identical(sframe_apa_text("phi = 0.15"), "phi = .15")
  # d, t, z, means and other unbounded values keep the zero.
  unbounded <- "t(57.30) = 0.45, p = .652, d = 0.12, 95% CI [-0.40, 0.63], z = 0.80, M = 0.50"
  expect_identical(sframe_apa_text(unbounded), unbounded)
  expect_identical(sframe_apa_text("net causal role (D - R = 0.893)"),
                   "net causal role (D - R = 0.893)")
  expect_identical(sframe_apa_text(c("r = 1.00", NA)), c("r = 1.00", NA))
})

test_that("a run block's result text and prompt carry no leading zero on r", {
  set.seed(2)
  d <- data.frame(a = 1:40, b = 1:40 + stats::rnorm(40, sd = 15))
  instr <- sf_instrument("APA", components = list(
    sf_item("a", "A", type = "numeric"), sf_item("b", "B", type = "numeric")))
  sf_plan(instr) <- list(list(id = "RQ1", research_question = "Is a related to b?",
    family = "relationship", method = "correlation_pearson",
    roles = list(x = "a", y = "b")))
  res <- run_analysis_plan(d, instr)
  expect_match(res$RQ1$apa, "^r\\(38\\) = -?\\.[0-9]{2}, 95% CI \\[-?\\.[0-9]+, -?\\.[0-9]+\\]")
  expect_match(res$RQ1$prompt, "r\\(38\\) = -?\\.[0-9]{2}")
})
