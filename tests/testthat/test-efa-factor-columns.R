# tests/testthat/test-efa-factor-columns.R
# EFA reads factor item columns through their labels, not level positions,
# in efa_report() and efa_solution().

efa_factor_fixture <- function() {
  set.seed(11)
  n <- 150
  f1 <- rnorm(n); f2 <- rnorm(n)
  mk <- function(f) pmin(5, pmax(1, round(3 + f + rnorm(n, sd = 0.7))))
  num <- data.frame(a1 = mk(f1), a2 = mk(f1), a3 = mk(f1),
                    b1 = mk(f2), b2 = mk(f2), b3 = mk(f2))
  # Labels 10..50 in a level order that differs from numeric order.
  fac <- as.data.frame(lapply(num, function(x) {
    factor(x * 10, levels = c(30, 50, 10, 40, 20))
  }))
  scaled <- as.data.frame(lapply(num, function(x) x * 10))
  instr <- sf_instrument("EFA factors", components = list(
    sf_choices("ag", 1:5, c("SD", "D", "N", "A", "SA")),
    sf_item("a1", "A1", type = "likert", choice_set = "ag"),
    sf_item("a2", "A2", type = "likert", choice_set = "ag"),
    sf_item("a3", "A3", type = "likert", choice_set = "ag"),
    sf_item("b1", "B1", type = "likert", choice_set = "ag"),
    sf_item("b2", "B2", type = "likert", choice_set = "ag"),
    sf_item("b3", "B3", type = "likert", choice_set = "ag"),
    sf_scale("A", "Scale A", items = c("a1", "a2", "a3")),
    sf_scale("B", "Scale B", items = c("b1", "b2", "b3"))
  ))
  list(num = scaled, fac = fac, instr = instr)
}

test_that("efa_report gives the same KMO for factor and numeric columns", {
  skip_if_not_installed("psych")
  fx <- efa_factor_fixture()
  a <- efa_report(fx$num, fx$instr)
  b <- efa_report(fx$fac, fx$instr)
  expect_equal(b$kmo$MSA, a$kmo$MSA)
})

test_that("efa_solution gives the same loadings for factor and numeric columns", {
  skip_if_not_installed("psych")
  fx <- efa_factor_fixture()
  a <- efa_solution(fx$num, fx$instr, nfactors = 2)
  b <- efa_solution(fx$fac, fx$instr, nfactors = 2)
  expect_equal(unname(as.matrix(b$loadings[sapply(b$loadings, is.numeric)])),
               unname(as.matrix(a$loadings[sapply(a$loadings, is.numeric)])),
               tolerance = 1e-4)
})
