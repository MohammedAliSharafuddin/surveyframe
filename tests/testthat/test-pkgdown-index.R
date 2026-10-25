# tests/testthat/test-pkgdown-index.R
#
# Every exported topic appears in _pkgdown.yml's reference index. The
# references merge added 5 exports and none of them, so the next pkgdown build
# on main would have failed. Found 2026-10-26 with pkgdown::check_pkgdown(),
# which this runs.

test_that("pkgdown finds every exported topic in the reference index", {
  skip_on_cran()
  skip_if_not_installed("pkgdown")
  root <- sframe_source_path("_pkgdown.yml")
  skip_if(is.na(root), "source tree not available")
  expect_no_error(suppressMessages(pkgdown::check_pkgdown(dirname(root))))
})
