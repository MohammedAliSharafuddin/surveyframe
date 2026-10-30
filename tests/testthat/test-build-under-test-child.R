# tests/testthat/test-build-under-test-child.R
# Session 3, build-under-test regression. A child R process started from a
# test, as Quarto and Studio start one, must load the build under test: its
# first library is the build library and its surveyframe carries the source
# commit. Quick, renders nothing.

test_that("a child Rscript loads the build under test", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")),
          "the build is made for the run only where Quarto is installed")
  lib <- sframe_build_under_test()
  skip_if(is.na(lib), "the installed package is the build under test")
  skip_if(startsWith(lib, "skip:"), sub("^skip: ", "", lib))
  out <- system2(
    file.path(R.home("bin"), "Rscript"),
    c("-e", shQuote(paste0(
      "cat(.libPaths()[1], ",
      "utils::packageDescription('surveyframe')$RemoteSha, sep = '\\n')"))),
    stdout = TRUE)
  expect_equal(normalizePath(out[1]), normalizePath(lib))
  expect_equal(out[2], sframe_build_commit(sframe_build_source()))
})
