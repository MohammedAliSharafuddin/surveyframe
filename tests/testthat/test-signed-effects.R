# tests/testthat/test-signed-effects.R
# D1 (CX-11). A two-group effect size keeps its direction: first group minus
# second, in the declared order. Size labels read the magnitude, intervals
# are bootstrapped on the signed value, and the text names the higher group.

signed_instr <- function() {
  sf_instrument(
    "Signed effects",
    components = list(
      sf_choices("arm", values = c("treat", "ctrl"),
                 labels = c("Treatment", "Control")),
      sf_item("grp", "Arm", type = "single_choice", choice_set = "arm"),
      sf_item("score", "Score", type = "numeric")
    )
  )
}

# The second group (ctrl) scores higher, so every effect is negative.
signed_data <- function() {
  data.frame(grp = rep(c("treat", "ctrl"), each = 6),
             score = c(1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7),
             stringsAsFactors = FALSE)
}

signed_block <- function(test) {
  list(id = "RQ1", research_question = "Q", method = test, test = test,
       roles = list(group = "grp", outcome = "score"),
       variables = c("grp", "score"), options = list())
}

test_that("Cohen's d is first group minus second", {
  expect_gt(sframe_cohens_d(c(4, 5, 6), c(1, 2, 3)), 0)
  expect_lt(sframe_cohens_d(c(1, 2, 3), c(4, 5, 6)), 0)
  expect_equal(sframe_cohens_d(c(1, 2, 3), c(4, 5, 6)),
               -sframe_cohens_d(c(4, 5, 6), c(1, 2, 3)))
})

test_that("the d interval is of the signed value and can include zero", {
  x <- c(1:10, 5.5)
  y <- c(1:10, 5)
  ci <- cohens_d_ci(x, y, R = 500, seed = 1)
  expect_lt(ci[["lower"]], 0)
  expect_gt(ci[["upper"]], 0)
})

test_that("size labels read the magnitude", {
  expect_equal(sframe_effect_label(-0.9, "d"), "large")
  expect_equal(sframe_effect_label(-0.35, "r"), "medium")
})

test_that("the t test reports a signed d and names the higher group", {
  res <- sframe_run_one_block(signed_block("t_test_ind"), signed_data(),
                              signed_instr())
  expect_lt(res$d, 0)
  expect_lt(res$d_ci[["upper"]], 0)
  expect_equal(res$effect_label, "large")
  expect_match(res$apa, "d = -", fixed = TRUE)
  expect_match(res$apa, "higher in ctrl", fixed = TRUE)
  expect_match(res$prompt, "higher in ctrl", fixed = TRUE)
})

test_that("Mann-Whitney reports a signed r and names the higher group", {
  res <- sframe_run_one_block(signed_block("mann_whitney"), signed_data(),
                              signed_instr())
  expect_lt(res$r, 0)
  expect_lt(res$r_ci[["upper"]], 0)
  expect_equal(res$effect_label, "large")
  expect_match(res$apa, "r = -", fixed = TRUE)
  expect_match(res$apa, "higher in ctrl", fixed = TRUE)
})

test_that("the Wilcoxon r is signed by the differences", {
  d <- data.frame(pre = c(1, 2, 3, 4, 5, 6, 7, 8),
                  post = c(2, 4, 4, 6, 7, 7, 9, 11))
  block <- list(id = "RQ1", research_question = "Q", method = "wilcoxon_pair",
                test = "wilcoxon_pair", roles = list(before = "pre", after = "post"),
                variables = c("pre", "post"), options = list())
  res <- sframe_run_one_block(block, d, NULL)
  expect_lt(res$r, 0)
  expect_lt(res$r_ci[["upper"]], 0)
  expect_lt(sframe_signed_rank_r(d$pre - d$post), 0)
  expect_equal(res$effect_label, "large")
  expect_match(res$apa, "higher in post", fixed = TRUE)
})
