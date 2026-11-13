# FR-25 (Fable sitting 2), Session CF-B: every result sentence compares p with
# the block's alpha. Only the t test and the one-way ANOVA read it, so with
# alpha .001 a Pearson p of .014 was a "significant correlation".

cfb_alpha_data <- function() {
  set.seed(303); n <- 60
  y <- round(rnorm(n, 3 + 0.62 * rep(1:0, each = 30)), 1)
  data.frame(y = y, x = round(0.3 * y + rnorm(n), 1), g = rep(c("a", "b"), each = 30))
}

test_that("a Pearson correlation at p = .014 is non-significant at alpha .001", {
  d <- cfb_alpha_data()
  r <- cfb_block(d, "correlation_pearson", list(x = "x", y = "y"), cfb_num("x"), cfb_num("y"),
                 alpha = 0.001)
  expect_gt(r$p, 0.001)
  expect_lt(r$p, 0.05)
  expect_match(r$prompt, "non-significant", fixed = TRUE)
  expect_null(r$options_ignored)
  r05 <- cfb_block(d, "correlation_pearson", list(x = "x", y = "y"), cfb_num("x"), cfb_num("y"))
  expect_false(grepl("non-significant", r05$prompt, fixed = TRUE))
})

test_that("regression, Mann-Whitney and Kruskal-Wallis read the block's alpha", {
  d <- cfb_alpha_data()
  reg <- cfb_block(d, "regression_linear", list(predictors = "x", dependent = "y"),
                   cfb_num("x"), cfb_num("y"), alpha = 0.001)
  expect_lt(reg$p, 0.05)
  expect_match(reg$prompt, "was not statistically significant", fixed = TRUE)
  mw <- cfb_block(d, "mann_whitney", list(group = "g", outcome = "y"),
                  sframe_item("g", "g", type = "text"), cfb_num("y"), alpha = 0.0000001)
  expect_match(mw$prompt, "did not reveal", fixed = TRUE)
  kw <- cfb_block(d, "kruskal_wallis", list(group = "g", outcome = "y"),
                  sframe_item("g", "g", type = "text"), cfb_num("y"), alpha = 0.0000001)
  expect_match(kw$prompt, "did not reveal", fixed = TRUE)
})

test_that("the block's alpha does not leak into a later block", {
  d <- cfb_alpha_data()
  ins <- sframe_instrument("A", components = list(cfb_num("x"), cfb_num("y")))
  mk <- function(id, alpha) {
    b <- list(id = id, research_question = "q", family = "inferential",
              method = "correlation_pearson", roles = list(x = "x", y = "y"))
    b$alpha <- alpha
    b
  }
  sframe_plan(ins) <- list(mk("B1", 0.001), mk("B2", NULL))
  res <- run_analysis_plan(d, ins, scored = FALSE)
  expect_match(res$B1$prompt, "non-significant", fixed = TRUE)
  expect_false(grepl("non-significant", res$B2$prompt, fixed = TRUE))
})
