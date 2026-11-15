# The source tree under devtools::test(), the installed package under
# R CMD check, where tests run against the installed copy.
demo_dir <- testthat::test_path("..", "..", "demo")
if (!dir.exists(demo_dir)) demo_dir <- system.file("demo", package = "surveyframe")
demo_files <- file.path(demo_dir, c("tour.R", "verify.R"))
skip_if_no_demos <- function() {
  skip_if(!nzchar(demo_dir) || !all(file.exists(demo_files)), "the guided tours are not in this tree")
}

test_that("guided tour scripts parse and appear in the demo index", {
  skip_if_no_demos()
  expect_no_error(lapply(demo_files, parse))

  # The source tree keeps demo/00Index. An installed package keeps the index
  # in Meta/, which utils::demo() reads.
  index_file <- file.path(demo_dir, "00Index")
  items <- if (file.exists(index_file)) {
    read.delim(index_file, header = FALSE, sep = "\t", quote = "",
               stringsAsFactors = FALSE)[[1]]
  } else {
    utils::demo(package = "surveyframe")$results[, "Item"]
  }
  expect_setequal(items, c("tour", "verify"))
})

test_that("surveyframe functions called by guided tours are exported", {
  skip_if_no_demos()
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
  skip_if_no_demos()
  expect_false(interactive())

  for (path in demo_files) {
    expect_no_error(local({
      env <- new.env(parent = globalenv())
      sys.source(path, envir = env)
    }))
  }
})
