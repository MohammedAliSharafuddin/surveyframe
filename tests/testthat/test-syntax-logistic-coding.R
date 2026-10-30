# tests/testthat/test-syntax-logistic-coding.R
# The logistic code analysis_syntax() writes codes the outcome as the runner
# does: the second level of as.factor(), alphabetical for text, becomes 1.

test_that("logistic syntax gives the runner's coefficients for a text outcome", {
  set.seed(3)
  x <- rnorm(60)
  # "yes" sorts after "no", so the runner codes yes = 1. A numeric 0/1 read
  # with as.numeric(factor(y)) - 1 would agree here, a reversed coding would not.
  p <- stats::plogis(1.2 * x)
  d <- data.frame(x = x, y = ifelse(runif(60) < p, "yes", "no"),
                  stringsAsFactors = FALSE)
  instr <- sf_instrument(
    "Logit",
    components = list(sf_item("x", "X", type = "numeric"),
                      sf_item("y", "Y", type = "text")))
  block <- list(id = "RQ1", research_question = "Q",
                method = "regression_logistic_binary",
                test = "regression_logistic_binary",
                roles = list(outcome = "y", predictors = "x"),
                variables = c("x", "y"), options = list())
  res <- sframe_run_one_block(block, d, instr)
  expect_null(res$error)
  code <- paste(sframe_syntax_call(res), collapse = "\n")
  env <- new.env()
  env$scored <- d
  out <- eval(parse(text = code), env)
  expect_equal(unname(stats::coef(env$fit)["x"]),
               res$coefficients$Estimate[2],
               tolerance = 1e-8)
})

test_that("logistic syntax codes a numeric and a factor outcome as the runner does", {
  set.seed(4)
  x <- rnorm(60)
  y <- as.integer(runif(60) < stats::plogis(x))
  for (outcome in list(y, factor(ifelse(y == 1, "low", "high"),
                                 levels = c("low", "high")))) {
    d <- data.frame(x = x, y = outcome)
    instr <- sf_instrument(
      "Logit",
      components = list(sf_item("x", "X", type = "numeric"),
                        sf_item("y", "Y", type = "numeric")))
    block <- list(id = "RQ1", research_question = "Q",
                  method = "regression_logistic_binary",
                  test = "regression_logistic_binary",
                  roles = list(outcome = "y", predictors = "x"),
                  variables = c("x", "y"), options = list())
    res <- sframe_run_one_block(block, d, instr)
    env <- new.env()
    env$scored <- d
    eval(parse(text = paste(sframe_syntax_call(res), collapse = "\n")), env)
    expect_equal(unname(stats::coef(env$fit)[2]),
                 res$coefficients$Estimate[2], tolerance = 1e-8)
  }
})
