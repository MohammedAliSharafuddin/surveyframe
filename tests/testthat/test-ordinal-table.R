# FR-35 (Fable sitting 2), Session CF-B: the ordinal logistic table gives p
# values and intervals, and no odds ratio for the thresholds.

test_that("slopes have p and an interval, thresholds have no odds ratio", {
  skip_if_not_installed("MASS")
  set.seed(202); n <- 90; x <- round(rnorm(n), 2)
  d <- data.frame(x = x, ord = as.character(cut(0.9 * x + rlogis(n), c(-Inf, -0.7, 0.7, Inf),
                                                labels = c("low", "medium", "high"))))
  r <- cfb_block(d, "regression_logistic_ordinal", list(predictors = "x", dependent = "ord"),
                 sframe_choice_set("lmh", c("low", "medium", "high"), c("Low", "Medium", "High")),
                 cfb_num("x"), sframe_item("ord", "Rating", type = "single_choice", choice_set = "lmh"))
  fit <- MASS::polr(factor(ord, c("low", "medium", "high"), ordered = TRUE) ~ x, d, Hess = TRUE)
  co <- summary(fit)$coefficients
  expect_equal(r$coefficients["x", "p"], 2 * pnorm(-abs(co["x", 1] / co["x", 2])))
  expect_true(all(is.na(r$coefficients[c("low|medium", "medium|high"), "odds_ratio"])))
  expect_true(all(c("p", "CI low", "CI high") %in% names(r$table)))
  thr <- r$table[r$table$Term %in% c("low|medium", "medium|high"), ]
  expect_true(all(thr$`Odds ratio` == ""))
  expect_true(nzchar(r$table$`Odds ratio`[r$table$Term == "x"]))
})
