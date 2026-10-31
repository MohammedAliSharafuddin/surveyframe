# tests/testthat/test-superseded.R
# Every old name from the 0.4.3 naming table still works, silently, and
# forwards to an exported replacement (naming decisions 1 and 3).

superseded_wrappers <- function() {
  ns <- asNamespace("surveyframe")
  exports <- getNamespaceExports("surveyframe")
  is_wrapper <- vapply(exports, function(nm) {
    f <- get(nm, envir = ns)
    is.function(f) && any(grepl("sframe_superseded(", deparse(body(f)), fixed = TRUE))
  }, logical(1))
  sort(exports[is_wrapper])
}

test_that("77 old names are kept as wrappers", {
  expect_length(superseded_wrappers(), 77)
})

test_that("each wrapper forwards to an exported function", {
  ns <- asNamespace("surveyframe")
  exports <- getNamespaceExports("surveyframe")
  for (old in superseded_wrappers()) {
    calls <- all.names(body(get(old, envir = ns)))
    target <- setdiff(calls, c("{", "sframe_superseded", "...", "=", old))
    expect_true(any(target %in% exports), info = old)
  }
})

test_that("an old name gives the new name's result, and warns only on request", {
  rlang::local_options(surveyframe.warn_superseded = NULL)
  expect_silent(old <- sf_item("q1", "Question 1", type = "text"))
  expect_identical(old, sframe_item("q1", "Question 1", type = "text"))

  rlang::local_options(surveyframe.warn_superseded = TRUE,
                       rlib_warning_verbosity = "verbose")
  expect_warning(sf_item("q1", "Question 1", type = "text"),
                 "Use `sframe_item\\(\\)` instead",
                 class = "sframe_superseded_warning")
})

test_that("cfa_syntax() keeps its own argument order", {
  cs <- sframe_choice_set("ag5", 1:5, c("SD", "D", "N", "A", "SA"))
  items <- lapply(1:3, function(i) {
    sframe_item(paste0("s", i), paste("Item", i), type = "likert",
                choice_set = "ag5", scale_id = "sat")
  })
  sc <- sframe_scale("sat", "Satisfaction", items = paste0("s", 1:3))
  instr <- sframe_instrument("Demo", components = c(list(cs), items, list(sc)))
  expect_identical(cfa_syntax(instr, "sat"),
                   sframe_syntax_cfa(instr, scales = "sat"))
})

test_that("the sf_plan replacement form still sets the plan", {
  demo <- sframe_demo("two_group")
  x <- demo$instrument
  plan <- sframe_plan(x)
  sframe_plan(x) <- list()
  sf_plan(x) <- plan
  expect_identical(sframe_plan(x), plan)
})
