# sframe_demo() at the console printed every response, 125 to 1,112 lines a
# demo. It now prints a short card (Session 10), and the parts are unchanged.

test_that("every demo prints a card of at most 15 lines", {
  for (name in sframe_list_demos()$name) {
    out <- capture.output(res <- print(sframe_demo(name)))
    expect_lte(length(out), 15)
    expect_identical(out[1], paste0("<surveyframe demo: ", name, ">"))
    expect_true(any(grepl("Demonstration data, not collected", out, fixed = TRUE)),
                info = name)
    expect_s3_class(res, "sframe_demo")
  }
})

test_that("the commands the card names parse and call exported functions", {
  out <- capture.output(print(sframe_demo("two_group")))
  cmds <- sub("\\s+#.*$", "", trimws(out[grepl("^  ", out)]))
  expect_length(cmds, 5)
  for (cmd in cmds) {
    expr <- parse(text = cmd)[[1]]
    if (is.call(expr) && is.name(expr[[1]]) && !identical(expr[[1]], as.name("$"))) {
      expect_true(as.character(expr[[1]]) %in% getNamespaceExports("surveyframe"),
                  info = cmd)
    }
  }
})

test_that("a demo keeps its parts and its list access", {
  d <- sframe_demo("two_group")
  expect_s3_class(d, "sframe_demo")
  expect_s3_class(d$instrument, "sframe")
  expect_s3_class(d$responses, "data.frame")
  expect_setequal(names(d), c("instrument", "responses", "instrument_path",
                              "responses_path", "codebook_path", "results_path"))
  expect_true(file.exists(d$results_path))
  expect_s3_class(sframe_demo("tourism_services"), "sframe_demo")
})

test_that("a demo with no plan does not offer run_analysis_plan()", {
  d <- sframe_demo("two_group")
  d$instrument$analysis_plan <- list()
  out <- capture.output(print(d))
  expect_false(any(grepl("run_analysis_plan", out, fixed = TRUE)))
})
