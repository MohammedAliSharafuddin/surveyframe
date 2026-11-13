# FR-20 (Fable sitting 2), Session CF-B: a single_choice or multiple_choice
# item enters a model as a category, whatever its codes, with its reference
# category named. Region coded 1, 2, 3 entered as 1 slope.

cfb_region_data <- function() {
  set.seed(202); n <- 90
  d <- data.frame(g3 = sample(1:3, n, TRUE), x = round(rnorm(n), 2))
  d$y <- 1 + 0.4 * d$x + 0.8 * (d$g3 == 2) - 0.6 * (d$g3 == 3) + rnorm(n)
  d
}
cfb_region <- function() {
  list(sframe_choice_set("reg", 1:3, c("North", "South", "East")),
       sframe_item("g3", "Region", type = "single_choice", choice_set = "reg"))
}

test_that("linear regression gives a numeric-coded region 2 indicator terms", {
  d <- cfb_region_data()
  r <- do.call(cfb_block, c(list(d, "regression_linear",
                                 list(predictors = c("x", "g3"), dependent = "y")),
                            cfb_region(), list(cfb_num("x"), cfb_num("y"))))
  expect_null(r$error)
  ref <- summary(lm(y ~ x + factor(g3), d))
  expect_equal(r$r2, ref$r.squared)
  expect_equal(nrow(r$coefficients), 4L)
  expect_equal(r$predictor_coding, list(g3 = c("1", "2", "3")))
  expect_match(r$apa, "\"Region\" enters as 2 indicator terms against the reference category North.",
               fixed = TRUE)
})

test_that("a multiple_choice item and the ANCOVA covariates enter as categories too", {
  d <- cfb_region_data()
  d$grp <- rep(c("a", "b"), 45)
  r <- cfb_block(d, "ancova", list(group = "grp", outcome = "y", covariates = c("x", "g3")),
                 sframe_choice_set("reg", 1:3, c("North", "South", "East")),
                 sframe_item("g3", "Region", type = "multiple_choice", choice_set = "reg"),
                 sframe_item("grp", "grp", type = "text"), cfb_num("x"), cfb_num("y"))
  expect_null(r$error)
  ref <- drop1(lm(y ~ grp + x + factor(g3), d), test = "F")
  expect_equal(r$table$df[r$table$effect == "Region"], 2)
  expect_equal(r$table$F[r$table$effect == "grp"], ref$`F value`[2])
  expect_match(r$apa, "reference category North", fixed = TRUE)
})

test_that("the reference is the first declared code with answers, after unused levels drop", {
  d <- cfb_region_data()
  d$g3[d$g3 == 1] <- 3
  r <- do.call(cfb_block, c(list(d, "regression_linear",
                                 list(predictors = c("x", "g3"), dependent = "y")),
                            cfb_region(), list(cfb_num("x"), cfb_num("y"))))
  expect_equal(r$predictor_coding, list(g3 = c("2", "3")))
  expect_match(r$apa, "1 indicator term against the reference category South", fixed = TRUE)
})

test_that("binary and multinomial logistic models code a choice predictor as a category", {
  d <- cfb_region_data()
  d$out <- ifelse(d$y > 1, 1, 0)
  r <- do.call(cfb_block, c(list(d, "regression_logistic_binary",
                                 list(predictors = c("x", "g3"), dependent = "out")),
                            cfb_region(), list(cfb_num("x"), cfb_num("out"))))
  expect_null(r$error)
  ref <- glm(out ~ x + factor(g3), binomial, d)
  expect_equal(unname(r$coefficients$Estimate), unname(coef(ref)), tolerance = 1e-6)
  skip_if_not_installed("nnet")
  d$m3 <- cut(d$y, c(-Inf, 0.5, 1.5, Inf), labels = c("lo", "mid", "hi"))
  d$m3 <- as.character(d$m3)
  r <- do.call(cfb_block, c(list(d, "regression_logistic_multinomial",
                                 list(predictors = c("x", "g3"), dependent = "m3")),
                            cfb_region(), list(cfb_num("x"), sframe_item("m3", "m3", type = "text"))))
  expect_null(r$error)
  expect_equal(ncol(r$coefficients), 4L)
})
