# review_040 defect 3 (owner 2026-11-13), Session CF-B: the assumption
# report's sentence names the checks that ran, or says none ran and what
# each needs. With an outcome and a group and no variables it gave empty
# tables and "Assumption checks were computed."

cfb_assump_data <- function() {
  set.seed(20260803)
  data.frame(x = rnorm(40), y = rnorm(40), g = rep(c("a", "b"), 20))
}

test_that("no check ran: the sentence says so and names the arguments", {
  ar <- sframe_assumption_results(cfb_assump_data(), outcome = "x", group = "g")
  expect_equal(nrow(ar$normality), 0)
  expect_false(grepl("were computed", ar$apa, fixed = TRUE))
  expect_match(ar$apa, "^No assumption checks ran\\.")
  expect_match(ar$apa, "`outcome` was given without `predictors`", fixed = TRUE)
  expect_match(ar$apa, "`group` was given without `variables`", fixed = TRUE)
})

test_that("the checks that ran are named", {
  ar <- sframe_assumption_results(cfb_assump_data(), variables = c("x", "y"), group = "g",
                                  outcome = "y", predictors = "x")
  expect_identical(ar$apa, paste0(
    "Assumption checks: normality (Shapiro-Wilk, skewness and kurtosis) for 2 variables, ",
    "homogeneity of variance (Levene and Brown-Forsythe) across g, ",
    "regression residuals, VIF and Cook's distance for y."))
})
