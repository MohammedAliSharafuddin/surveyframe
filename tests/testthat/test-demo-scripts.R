demo_dir <- testthat::test_path("..", "..", "demo")
demo_files <- file.path(demo_dir, c("tour.R", "verify.R"))

test_that("guided tour scripts parse and appear in the demo index", {
  expect_no_error(lapply(demo_files, parse))

  index <- read.delim(file.path(demo_dir, "00Index"), header = FALSE,
                      sep = "\t", quote = "", stringsAsFactors = FALSE)
  expect_identical(index[[1]], c("tour", "verify"))
  expect_identical(nrow(index), 2L)
})

test_that("surveyframe functions called by guided tours are exported", {
  namespace <- asNamespace("surveyframe")
  exports <- getNamespaceExports("surveyframe")

  for (path in demo_files) {
    names_used <- unique(all.names(parse(path), functions = TRUE))
    package_calls <- names_used[vapply(names_used, exists, logical(1),
      envir = namespace, inherits = FALSE)]
    expect_setequal(package_calls, intersect(package_calls, exports))
  }
})

test_that("guided tour scripts run outside an interactive session", {
  skip_on_cran()
  expect_false(interactive())

  for (path in demo_files) {
    expect_no_error(local({
      env <- new.env(parent = globalenv())
      sys.source(path, envir = env)
    }))
  }
})
