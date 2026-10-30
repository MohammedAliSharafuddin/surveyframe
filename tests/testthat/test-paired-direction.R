# tests/testthat/test-paired-direction.R
# The paired t test names the higher measure from the sign of the mean
# difference (first minus second), as the Wilcoxon signed-rank runner does.

test_that("paired t names the higher measure in the APA line and prompt", {
  d <- data.frame(pre = c(1, 2, 3, 4, 5, 6), post = c(2, 4, 4, 6, 8, 7))
  r <- sframe_run_t_test_pair(d, c("pre", "post"))
  expect_match(r$apa, ", higher in post$")
  expect_match(r$prompt, "higher in post")
  r2 <- sframe_run_t_test_pair(d, c("post", "pre"))
  expect_match(r2$apa, ", higher in post$")
  w <- suppressWarnings(sframe_run_wilcoxon_pair(d, c("pre", "post")))
  expect_match(w$apa, ", higher in post$")
})
