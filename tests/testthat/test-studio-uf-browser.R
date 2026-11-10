# tests/testthat/test-studio-uf-browser.R
#
# Session UF: the Studio minors from Codex pass 1 (P1-06 to P1-12), checked
# at 1280 and 390 px in a real Chrome against the build under test. Studio
# and its tab come from ui1_studio() (helper-ui1-browser.R): "none" opens
# Studio with no instrument, "two_group" with that demo. Both are closed at
# the end of the file.

skip_if_not_slow()
skip_on_cran()
skip_if_not_installed("chromote")
skip_if_not_installed("callr")
skip_if_not_installed("httpuv")

uf_widths <- c(1280, 390)

test_that("Studio's page declares its language as English (P1-06, WCAG 3.1.1)", {
  b <- ui1_studio("two_group", width = 1280, height = 900)
  expect_identical(ui2_js(b, "document.documentElement.getAttribute('lang')"), "en")
})

ui1_close()
