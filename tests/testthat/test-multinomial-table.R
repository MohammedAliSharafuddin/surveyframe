# tests/testthat/test-multinomial-table.R
#
# CX-14. The multinomial logistic runner gave a coefficient matrix and no
# table: no standard errors, z, p or confidence intervals, and the reference
# category was only implied. render_result() also dropped a result's syntax.

mn_data <- function() {
  set.seed(11)
  n <- 150
  x <- rnorm(n)
  z <- rnorm(n)
  y <- factor(sample(c("low", "mid", "high"), n, replace = TRUE),
              levels = c("mid", "low", "high"))
  data.frame(y = as.character(y), x = x, z = z, stringsAsFactors = FALSE)
}

test_that("CX-14: the multinomial result carries a full table against a named reference", {
  skip_if_not_installed("nnet")
  d <- mn_data()
  res <- sframe_run_multinomial_logistic(d, list(dependent = "y", predictors = c("x", "z")))
  expect_null(res$error)
  ref <- levels(as.factor(d$y))[1]
  expect_identical(res$reference, ref)
  tb <- sframe_result_table(res)
  expect_s3_class(tb, "data.frame")
  expect_true(all(c("Outcome", "Term", "b", "SE", "z", "p", "OR",
                    "CI low", "CI high") %in% names(tb)))
  # 2 non-reference categories times 3 terms (intercept, x, z)
  expect_equal(nrow(tb), 6L)
  expect_false(any(grepl(paste0("^", ref, " "), tb$Outcome)))
  expect_true(all(grepl(paste0("vs ", ref, "$"), tb$Outcome)))
  expect_match(res$apa, ref, fixed = TRUE)

  fit <- nnet::multinom(y ~ x + z, data = transform(d, y = as.factor(y)), trace = FALSE)
  s <- summary(fit)
  zz <- s$coefficients / s$standard.errors
  row1 <- tb[tb$Term == "x" & grepl("^low", tb$Outcome), ]
  expect_equal(as.numeric(row1$b), round(s$coefficients["low", "x"], 2))
  expect_equal(as.numeric(row1$SE), round(s$standard.errors["low", "x"], 2))
  expect_equal(as.numeric(row1$z), round(zz["low", "x"], 2))
  expect_equal(as.numeric(row1$OR), round(exp(s$coefficients["low", "x"]), 2))
  lo <- exp(s$coefficients["low", "x"] - stats::qnorm(.975) * s$standard.errors["low", "x"])
  expect_equal(as.numeric(row1$`CI low`), round(lo, 2))
})

test_that("CX-14: render_result() carries the result's syntax", {
  res <- list(test = "cfa_lavaan_syntax", block_id = "B1",
              syntax = "f =~ a + b", apa = "CFA lavaan syntax generated.")
  out <- render_result(res, data.frame(a = 1), format = "png")
  expect_identical(out$syntax, "f =~ a + b")
  out2 <- render_result(list(test = "x", error = "boom"), data.frame(a = 1))
  expect_null(out2$syntax)
})
