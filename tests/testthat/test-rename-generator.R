# tests/testthat/test-rename-generator.R
#
# R/superseded.R is written by data-raw/rename_0.4.3.R. The 2 dashboard
# launchers were added to R/superseded.R by hand when the dashboard app became
# a Studio screen, so a rerun of the generator dropped them. A rerun on a copy
# of the source must change no file.

test_that("rerunning data-raw/rename_0.4.3.R changes no file", {
  skip_on_cran()
  skip_if_not_slow()
  src <- sframe_build_source()
  skip_if(!nzchar(src) || !file.exists(file.path(src, "data-raw", "rename_0.4.3.R")),
          "package source not found")
  copy <- file.path(tempfile("rename-"), "pkg")
  dir.create(copy, recursive = TRUE)
  on.exit(unlink(dirname(copy), recursive = TRUE), add = TRUE)
  parts <- c("R", "tests", "vignettes", "inst", "data-raw", "README.md")
  file.copy(file.path(src, parts), copy, recursive = TRUE)
  files <- list.files(copy, recursive = TRUE)
  before <- tools::md5sum(file.path(copy, files))
  out <- callr::rscript(file.path("data-raw", "rename_0.4.3.R"), wd = copy,
                        show = FALSE, fail_on_status = TRUE)
  after <- tools::md5sum(file.path(copy, files))
  expect_identical(files[after != before], character(0))
  expect_setequal(list.files(copy, recursive = TRUE), files)
  sup <- readLines(file.path(copy, "R", "superseded.R"))
  expect_true(any(grepl("^launch_dashboard <- function", sup)))
  expect_true(any(grepl("^launch_dashboard_demo <- function", sup)))
})
