# review_040 defect 7 (owner 2026-11-13), Session CF-B: render_results()
# accepted citation_format "ama" and "vancouver" and never used them, so 3
# formats gave 1 document. Only "apa" is accepted now.

cfb_rr <- function() {
  ins <- sframe_instrument("R", components = list(cfb_num("x"), cfb_num("y")))
  sframe_plan(ins) <- list(list(id = "r1", research_question = "Q", family = "inferential",
                                method = "correlation_pearson", roles = list(x = "x", y = "y")))
  set.seed(1)
  d <- data.frame(x = rnorm(30), y = rnorm(30))
  list(ins = ins, res = run_analysis_plan(d, ins, scored = FALSE))
}

test_that("ama and vancouver are refused, naming the format", {
  rr <- cfb_rr()
  for (f in c("ama", "vancouver")) {
    expect_error(render_results(rr$res, rr$ins, output_file = tempfile(fileext = ".html"),
                                citation_format = f),
                 paste0("`citation_format = \"", f, "\"` is not supported"),
                 fixed = TRUE, class = "sframe_error")
  }
})

test_that("apa, the default, still renders", {
  rr <- cfb_rr()
  p <- tempfile(fileext = ".html")
  out <- suppressMessages(render_results(rr$res, rr$ins, output_file = p, citation_format = "apa"))
  expect_true(file.exists(p))
})
