# FR-33 (Fable sitting 2), Session CF-B: each block's random stream is seeded
# from the plan seed and its block id, so a block's bootstrap interval does
# not change when another block is put before it. The d interval of a t test
# was [0.097, 1.221] alone and [0.079, 1.180] after a Spearman block.

cfb_seed_plan <- function(blocks) {
  ins <- sframe_instrument("S", components = list(cfb_num("x"), cfb_num("y"),
                                                  sframe_item("g", "g", type = "text")))
  sframe_plan(ins) <- blocks
  ins
}

test_that("a block's interval is the same alone and after another block", {
  set.seed(8)
  d <- data.frame(x = rnorm(40), y = rnorm(40), g = rep(c("a", "b"), 20))
  t_block <- list(id = "T", research_question = "q", family = "inferential",
                  method = "t_test_ind", roles = list(group = "g", outcome = "y"))
  s_block <- list(id = "S", research_question = "q", family = "inferential",
                  method = "correlation_spearman", roles = list(x = "x", y = "y"))
  alone <- run_analysis_plan(d, cfb_seed_plan(list(t_block)), scored = FALSE)$T
  after <- run_analysis_plan(d, cfb_seed_plan(list(s_block, t_block)), scored = FALSE)$T
  expect_equal(alone$d_ci, after$d_ci)
  again <- run_analysis_plan(d, cfb_seed_plan(list(t_block)), scored = FALSE)$T
  expect_identical(alone$d_ci, again$d_ci)
  other <- run_analysis_plan(d, cfb_seed_plan(list(t_block)), scored = FALSE, seed = 7L)$T
  expect_false(identical(alone$d_ci[["lower"]], other$d_ci[["lower"]]))
})

test_that("the caller's random stream is left as it was", {
  set.seed(1); before <- runif(1)
  set.seed(1)
  d <- data.frame(x = 1:10, y = c(2, 1, 4, 3, 6, 5, 8, 7, 10, 9), g = rep(c("a", "b"), 5))
  invisible(run_analysis_plan(d, cfb_seed_plan(list(list(
    id = "T", research_question = "q", family = "inferential",
    method = "t_test_ind", roles = list(group = "g", outcome = "y")))), scored = FALSE))
  expect_identical(runif(1), before)
})
