# B-04 (Fable sitting 2 p12, owner 2026-11-13), Session CF-B: an interval
# prints its own level. sframe_ci_string() printed 95% for a 90% bootstrap
# interval, since only the noncentrality intervals recorded their level.

f <- function(n) get(n, asNamespace("surveyframe"))

test_that("a 90% interval prints as 90%", {
  set.seed(1); x <- rnorm(30)
  b90 <- sframe_bootstrap_ci(x, mean, R = 300, conf.level = 0.90, seed = 5)
  expect_match(f("sframe_ci_string")(b90), "^, 90% CI \\[")
  d90 <- sframe_cohens_d_ci(x, x + 1, R = 300, conf.level = 0.90, seed = 5)
  expect_match(f("sframe_ci_string")(d90), "^, 90% CI \\[")
  z90 <- f("sframe_fisher_z_ci")(0.4, 50, conf.level = 0.90)
  expect_match(f("sframe_ci_string")(z90), "^, 90% CI \\[")
  v90 <- sframe_cramers_v_ci(table(mtcars$am, mtcars$cyl), conf.level = 0.90)
  expect_match(f("sframe_ci_string")(v90), "^, 90% CI \\[")
})

test_that("the default interval still prints 95%", {
  set.seed(1); x <- rnorm(30)
  expect_match(f("sframe_ci_string")(sframe_bootstrap_ci(x, mean, R = 300, seed = 5)), "^, 95% CI \\[")
  expect_match(f("sframe_ci_string")(c(lower = 1, upper = 2)), "^, 95% CI \\[")
})
