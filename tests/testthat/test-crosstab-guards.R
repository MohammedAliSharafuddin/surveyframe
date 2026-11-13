# Session CF-B minors on the chi-square block: FR-27 (a constant variable)
# and P2-09 (a simulated p value prints no df).

test_that("a constant variable is refused, not tested for goodness of fit", {
  # FR-27: chi-square(2, N = 90) = 6.67, p = .036, V = NA at 2a910b0.
  d <- data.frame(g2 = "a", g3 = as.character(rep(1:3, c(40, 30, 20))))
  r <- cfb_block(d, "chi_square", list(row = "g2", column = "g3"),
                 sframe_item("g2", "Constant", type = "text"), sframe_item("g3", "g3", type = "text"))
  expect_match(r$error, "\"Constant\" has only 1 category with answers", fixed = TRUE)
})

test_that("a simulated chi-square omits df and says the p value is simulated", {
  # P2-09: chi-square(NA, N = 4) at 2a910b0.
  f <- get("sframe_run_crosstab", asNamespace("surveyframe"))
  set.seed(1)
  r <- f(data.frame(x = c("a", "a", "b", "b"), y = c("c", "d", "c", "d")), c("x", "y"),
         list(simulate_p_value = TRUE))
  expect_identical(r$p_method, "simulated")
  expect_false(grepl("NA", r$apa, fixed = TRUE))
  expect_match(r$apa, "(N = 4) = 0.00, p", fixed = TRUE)
  expect_match(r$apa, "(simulated from 2000 tables)", fixed = TRUE)
})
