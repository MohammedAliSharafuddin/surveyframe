# sframe_demo() at the console printed every response, 125 to 1,112 lines a
# demo. It now prints a short card (Session 10), and the parts are unchanged.

test_that("every demo prints a card of at most 15 lines", {
  for (name in sframe_list_demos()$name) {
    out <- capture.output(res <- print(sframe_demo(name)))
    expect_lte(length(out), 15)
    expect_match(out[1], paste0("^-- Demo: ", name, " -+$"))
    expect_true(any(grepl("Demonstration data, not collected", out, fixed = TRUE)),
                info = name)
    expect_s3_class(res, "sframe_demo")
  }
})

test_that("the commands the card names parse and call exported functions", {
  out <- capture.output(print(sframe_demo("two_group")))
  cmds <- sub("\\s{3,}.*$", "", trimws(out[grepl("^  ", out)]))
  expect_length(cmds, 6)
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
  d <- sframe_demo("two_group", preview = FALSE)
  d$instrument$analysis_plan <- list()
  out <- capture.output(print(d))
  expect_false(any(grepl("run_analysis_plan", out, fixed = TRUE)))
})

test_that("the card names the planned methods", {
  out <- capture.output(print(sframe_demo("two_group")))
  expect_match(out[3], "^2 questions, 60 responses, 2 planned analyses \\(t_test_ind, mann_whitney\\)$")
})

test_that("with cli run links the commands are links, without them plain text", {
  local_mocked_bindings(sframe_has_run_links = function() FALSE)
  plain <- capture.output(print(sframe_demo("two_group")))
  expect_false(any(grepl("x-r-run:", plain, fixed = TRUE)))
  skip_if_not_installed("cli")
  old <- options(cli.hyperlink = TRUE, cli.hyperlink_run = TRUE)
  on.exit(options(old), add = TRUE)
  local_mocked_bindings(sframe_has_run_links = function() TRUE)
  linked <- capture.output(print(sframe_demo("two_group")))
  expect_true(any(grepl("x-r-run:launch_studio(demo = \"two_group\")", linked, fixed = TRUE)))
  expect_identical(length(linked), length(plain))
  expect_identical(cli::ansi_strip(linked), plain)
})

test_that("preview opens the survey only in an interactive session", {
  shown <- NULL
  local_mocked_bindings(sframe_show = function(path, ...) shown <<- path)
  local_mocked_bindings(sframe_is_interactive = function() FALSE)
  sframe_demo("two_group", preview = TRUE)
  expect_null(shown)
  local_mocked_bindings(sframe_is_interactive = function() TRUE)
  old <- options(knitr.in.progress = NULL, surveyframe.demo_preview = NULL)
  on.exit(options(old), add = TRUE)
  sframe_demo("two_group", preview = FALSE)
  expect_null(shown)
  sframe_demo("two_group", preview = TRUE)
  expect_match(shown, "\\.html$")
  expect_true(file.exists(shown))
  shown <- NULL
  options(surveyframe.demo_preview = FALSE)
  sframe_demo("two_group", preview = TRUE)
  expect_null(shown)
})

test_that("internal callers never open a preview", {
  calls <- 0
  local_mocked_bindings(sframe_show = function(...) calls <<- calls + 1,
                        sframe_is_interactive = function() TRUE)
  old <- options(knitr.in.progress = NULL, surveyframe.demo_preview = NULL)
  on.exit(options(old), add = TRUE)
  suppressWarnings(sframe_demo_data())
  path <- preview_survey("two_group", open = FALSE)
  expect_equal(calls, 0)
})

test_that("sframe_list_demos() prints 1 line per demo, grouped, two_group first", {
  local_mocked_bindings(sframe_has_run_links = function() FALSE)
  x <- sframe_list_demos()
  out <- capture.output(print(x))
  expect_identical(out[1], 'Start here: sframe_demo("two_group")')
  expect_true(all(c("Analysis (17)", "Presentation (3)", "Provenance (2)",
                    "Reference datasets (2)") %in% out))
  for (nm in x$name) expect_true(any(startsWith(out, paste0("  ", nm, " "))), info = nm)
  expect_lte(length(out), 35)
  expect_identical(class(as.data.frame(x)), "data.frame")
  expect_identical(nrow(as.data.frame(x)), nrow(x))
})

test_that("with cli run links each demo name runs sframe_demo()", {
  skip_if_not_installed("cli")
  old <- options(cli.hyperlink = TRUE, cli.hyperlink_run = TRUE)
  on.exit(options(old), add = TRUE)
  local_mocked_bindings(sframe_has_run_links = function() FALSE)
  plain <- capture.output(print(sframe_list_demos()))
  local_mocked_bindings(sframe_has_run_links = function() TRUE)
  linked <- capture.output(print(sframe_list_demos()))
  expect_true(any(grepl('x-r-run:sframe_demo("sem_pls")', linked, fixed = TRUE)))
  expect_identical(cli::ansi_strip(linked), plain)
})
