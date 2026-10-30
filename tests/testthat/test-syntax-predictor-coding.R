# tests/testthat/test-syntax-predictor-coding.R
# Session 3 syntax gap. Every regression runner codes its predictors through
# sframe_predictor_frame(), and the code analysis_syntax() writes codes them the
# same way, so a number-like text predictor enters both as a number and the
# generated code reproduces the package's coefficients.

pc_data <- function(n = 80) {
  set.seed(23)
  x1 <- stats::rnorm(n)
  xt <- sample(1:5, n, replace = TRUE)
  lin <- 0.6 * x1 + 0.4 * xt
  data.frame(
    x1  = x1,
    xt  = as.character(xt),
    cat = rep(c("north", "south", "west"), length.out = n),
    grp = rep(c("a", "b", "c"), each = ceiling(n / 3))[seq_len(n)],
    y   = lin + stats::rnorm(n),
    bin = ifelse(lin + stats::rnorm(n) > 1.5, "yes", "no"),
    ord = as.character(cut(lin + stats::rnorm(n), 3,
                           labels = c("high", "low", "mid"))),
    stringsAsFactors = FALSE)
}

pc_instrument <- function() {
  sf_instrument("Predictor coding", components = c(
    lapply(c("x1", "y"), function(x) sf_item(x, x, type = "numeric")),
    lapply(c("xt", "cat", "grp", "bin", "ord"),
           function(x) sf_item(x, x, type = "text"))
  ))
}

pc_result <- function(method, roles) {
  instr <- pc_instrument()
  sf_plan(instr) <- list(list(id = "RQ1", research_question = "Q",
                              family = "inferential", method = method,
                              roles = roles))
  res <- run_analysis_plan(pc_data(), instr)$RQ1
  expect_null(res$error, info = method)
  res
}

pc_run <- function(res) {
  code <- sframe_syntax_call(res)
  expect_false(is.null(code), info = res$test)
  env <- new.env(parent = globalenv())
  env$scored <- pc_data()
  eval(parse(text = paste(code, collapse = "\n")), envir = env)
}

test_that("linear regression code enters number-like text as a number", {
  res <- pc_result("regression_linear",
                   list(predictors = c("xt", "x1"), dependent = "y"))
  got <- pc_run(res)
  expect_true("xt" %in% rownames(got$coefficients))
  expect_equal(unname(got$coefficients[, 1]),
               res$coefficients[["Estimate"]], tolerance = 1e-8)
})

test_that("binary logistic code enters number-like text as a number", {
  res <- pc_result("regression_logistic_binary",
                   list(predictors = c("xt", "x1"), dependent = "bin"))
  got <- pc_run(res)
  expect_true("xt" %in% rownames(got))
  expect_equal(unname(got[, 1]), res$coefficients[["odds_ratio"]],
               tolerance = 1e-8)
})

test_that("ordinal logistic code enters number-like text as a number", {
  skip_if_not_installed("MASS")
  res <- pc_result("regression_logistic_ordinal",
                   list(predictors = c("xt", "x1", "cat"), dependent = "ord"))
  expect_true("xt" %in% rownames(res$coefficients))
  got <- pc_run(res)
  expect_equal(unname(got$coefficients[, 1]), res$coefficients[[1]],
               tolerance = 1e-6)
})

test_that("multinomial logistic code enters number-like text as a number", {
  skip_if_not_installed("nnet")
  res <- pc_result("regression_logistic_multinomial",
                   list(predictors = c("xt", "x1"), dependent = "grp"))
  expect_true("xt" %in% colnames(res$coefficients))
  got <- pc_run(res)
  expect_equal(unname(got$coefficients), unname(res$coefficients),
               tolerance = 1e-4)
})

test_that("ANCOVA code codes covariates as the runner does", {
  res <- pc_result("ancova", list(group = "grp", outcome = "y",
                                  covariates = c("xt", "cat")))
  got <- pc_run(res)
  expect_equal(got[["F value"]][rownames(got) == "group"], res$table$F[1],
               tolerance = 1e-8)
})
