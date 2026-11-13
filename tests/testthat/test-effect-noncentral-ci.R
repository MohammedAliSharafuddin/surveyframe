# FR-24 (Fable sitting 2), Session CF-B: the intervals for Cramer's V and eta
# squared are noncentrality intervals, as effectsize computes them, and reach
# 0. The percentile bootstrap gave an exactly independent table V = 0 with
# 95% CI [0.05, 0.50]. The reference values are effectsize 1.0.3's
# cramers_v(adjust = FALSE, alternative = "two.sided") and
# eta_squared(partial = FALSE, alternative = "two.sided").

test_that("Cramer's V intervals match effectsize", {
  ref <- list(am_cyl = c(0.5226355372, 0.1118232499, 0.8455312601),
              gear_carb = c(0.5080307452, 0, 0.6277300699),
              vs_am = c(0.1683451246, 0, 0.5146522851))
  tabs <- list(am_cyl = table(mtcars$am, mtcars$cyl), gear_carb = table(mtcars$gear, mtcars$carb),
               vs_am = table(mtcars$vs, mtcars$am))
  for (nm in names(ref)) {
    got <- sframe_cramers_v_ci(tabs[[nm]])
    expect_equal(unname(got[c("estimate", "lower", "upper")]), ref[[nm]], tolerance = 1e-6)
    expect_identical(attr(got, "method"), "noncentral chi-square")
  }
})

test_that("eta squared intervals match effectsize", {
  ref <- list(c("mpg", "cyl", 0.7324600596, 0.536217498, 0.828595017),
              c("hp", "gear", 0.4406389807, 0.1512997184, 0.6268051634),
              c("qsec", "am", 0.05283601596, 0, 0.2627709837))
  for (r in ref) {
    got <- sframe_eta_sq_ci(mtcars[[r[1]]], mtcars[[r[2]]])
    expect_equal(unname(got[c("estimate", "lower", "upper")]), as.numeric(r[3:5]), tolerance = 1e-5)
  }
})

test_that("an exactly independent table has V = 0 and an interval holding 0", {
  d <- data.frame(g2 = rep(c("a", "b"), 15), g3 = as.character(rep(1:3, each = 10)))
  r <- cfb_block(d, "chi_square", list(row = "g2", column = "g3"),
                 sframe_item("g2", "g2", type = "text"), sframe_item("g3", "g3", type = "text"))
  expect_equal(unname(r$v_ci[c("lower", "upper")]), c(0, 0))
  expect_false(grepl("[.05", r$apa, fixed = TRUE))
})

test_that("with no group difference the eta squared interval reaches 0", {
  set.seed(12)
  lows <- vapply(1:20, function(i) {
    sframe_eta_sq_ci(rnorm(45), rep(1:3, 15))[["lower"]]
  }, numeric(1))
  expect_gte(mean(lows == 0), 0.5)
  skip_if_not_installed("effectsize")
  e <- effectsize::cramers_v(table(mtcars$am, mtcars$cyl), adjust = FALSE, alternative = "two.sided")
  expect_equal(sframe_cramers_v_ci(table(mtcars$am, mtcars$cyl))[["lower"]], e$CI_low, tolerance = 1e-6)
})
