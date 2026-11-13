# FR-19 (Fable sitting 2), Session CF-B: an ordinal outcome is ordered as its
# choice set declares, not alphabetically. ordered() of low, medium, high gave
# high < low < medium and reversed the slope's sign.

test_that("a text-coded ordinal outcome follows its declared order", {
  skip_if_not_installed("MASS")
  set.seed(202); n <- 90; x <- round(rnorm(n), 2)
  d <- data.frame(x = x, ord = as.character(cut(0.9 * x + rlogis(n), c(-Inf, -0.7, 0.7, Inf),
                                                labels = c("low", "medium", "high"))))
  r <- cfb_block(d, "regression_logistic_ordinal", list(predictors = "x", dependent = "ord"),
                 sframe_choice_set("lmh", c("low", "medium", "high"), c("Low", "Medium", "High")),
                 cfb_num("x"),
                 sframe_item("ord", "Rating", type = "single_choice", choice_set = "lmh"))
  expect_null(r$error)
  ref <- MASS::polr(factor(ord, c("low", "medium", "high"), ordered = TRUE) ~ x, d, Hess = TRUE)
  expect_equal(r$coefficients["x", 1], unname(coef(ref)["x"]), tolerance = 1e-6)
  expect_gt(r$coefficients["x", 1], 0)
  expect_identical(r$outcome_levels, c("low", "medium", "high"))
  expect_true(all(c("low|medium", "medium|high") %in% rownames(r$coefficients)))
  expect_match(r$apa, "ordered Low < Medium < High", fixed = TRUE)
})

test_that("an outcome with no choice set is ordered by number, not by text", {
  skip_if_not_installed("MASS")
  set.seed(7); n <- 120; x <- rnorm(n)
  y <- as.character(cut(x + rlogis(n), c(-Inf, -1, 1, Inf), labels = c("2", "9", "10")))
  d <- data.frame(x = x, y = y)
  r <- cfb_block(d, "regression_logistic_ordinal", list(predictors = "x", dependent = "y"),
                 cfb_num("x"), sframe_item("y", "y", type = "text"))
  expect_identical(r$outcome_levels, c("2", "9", "10"))
  expect_gt(r$coefficients["x", 1], 0)
})
