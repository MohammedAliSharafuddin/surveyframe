# FR-32 (Fable sitting 2), Session CF-B: APA 7 number formatting.

f <- function(n) get(n, asNamespace("surveyframe"))

test_that("p above .999 is > .999, in a sentence and a cell", {
  expect_identical(f("sframe_p_string")(0.9996), "> .999")
  expect_identical(f("sframe_p_cell")(0.9996), ">.999")
})

test_that("a p value just below .05 is not rounded up to .050", {
  expect_identical(f("sframe_p_string")(0.04996), "= .04996")
  expect_identical(f("sframe_p_cell")(0.04996), ".04996")
  expect_identical(f("sframe_p_string")(0.0512), "= .051")
  expect_identical(f("sframe_p_string")(0.0349), "= .035")
})

test_that("Cramer's V drops its leading zero, the Wilcoxon V keeps its value", {
  expect_identical(sframe_apa_text("V = 0.23, 95% CI [0.07, 0.45]"), "V = .23, 95% CI [.07, .45]")
  expect_identical(sframe_apa_text("V = 45, z = 0.32"), "V = 45, z = 0.32")
})

test_that("a value that rounds to 0 is never -0.00", {
  expect_identical(sframe_apa_text("d = -0.00, b = -0.001"), "d = 0.00, b = -0.001")
  expect_identical(f("sframe_apa_number")(c(-0.001, 1.5)), c("0.00", "1.50"))
})

test_that("a small slope keeps 3 decimals, and whole F values keep 2", {
  set.seed(4); x <- rnorm(200, sd = 100); y <- 0.004 * x + rnorm(200, sd = 0.1)
  r <- cfb_block(data.frame(x = x, y = y), "regression_linear", list(predictors = "x", dependent = "y"),
                 cfb_num("x"), cfb_num("y"))
  expect_identical(r$table$Estimate[r$table$Term == "x"],
                   formatC(r$coefficients["x", 1], digits = 3, format = "f"))
  cells <- sframe_apa_cells(data.frame(F = c(4, 9), n = c(10L, 12L), df = c(2, 3)))
  expect_identical(cells$F, c("4.00", "9.00"))
  expect_identical(cells$n, c("10", "12"))
  expect_identical(cells$df, c("2", "3"))
})
