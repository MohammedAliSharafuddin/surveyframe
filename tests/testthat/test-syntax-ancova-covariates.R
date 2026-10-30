# tests/testthat/test-syntax-ancova-covariates.R
# CX-02. The ANCOVA code analysis_syntax() writes carries every declared
# covariate, so it reproduces the runner's adjusted group F with 2 covariates.

test_that("ANCOVA syntax writes every covariate and matches the runner", {
  set.seed(7)
  d <- data.frame(grp = rep(c("a", "b", "c"), each = 10),
                  c1 = rnorm(30), c2 = rnorm(30), stringsAsFactors = FALSE)
  d$y <- d$c1 + 2 * d$c2 + (d$grp == "b") + rnorm(30)
  instr <- sf_instrument(
    "Ancova",
    components = list(
      sf_item("grp", "Group", type = "text"),
      sf_item("y", "Y", type = "numeric"),
      sf_item("c1", "C1", type = "numeric"),
      sf_item("c2", "C2", type = "numeric")))
  block <- list(id = "RQ1", research_question = "Q", method = "ancova",
                test = "ancova",
                roles = list(group = "grp", outcome = "y",
                             covariates = c("c1", "c2")),
                variables = c("grp", "y", "c1", "c2"), options = list())
  res <- sframe_run_one_block(block, d, instr)
  code <- paste(sframe_syntax_call(res), collapse = "\n")
  expect_match(code, "c1", fixed = TRUE)
  expect_match(code, "c2", fixed = TRUE)
  env <- new.env()
  env$scored <- d
  out <- eval(parse(text = code), env)
  f_code <- out[["F value"]][rownames(out) == "group"]
  f_run <- res$table$F[1]
  expect_equal(f_code, f_run, tolerance = 1e-8)
})
