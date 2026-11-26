# tests/testthat/test-prop-columns.R
# The floor, ceiling and missing shares are proportions, so their columns are
# named floor_prop, ceiling_prop and missing_prop. The _pct columns hold the
# same shares as percentages (I5), and tables show the _prop column alone.

likert_demo <- function() sframe_demo("likert_scale")

test_that("item diagnostics name the floor and ceiling shares _prop", {
  diag <- sframe_item_results(likert_demo()$responses, likert_demo()$instrument)[[1]]$diagnostics
  expect_true(all(c("floor_prop", "ceiling_prop") %in% names(diag)))
  expect_equal(diag$floor_pct, 100 * diag$floor_prop)
  expect_equal(diag$ceiling_pct, 100 * diag$ceiling_prop)
  # the old columns come last, after n_missing
  expect_identical(utils::tail(names(diag), 2), c("floor_pct", "ceiling_pct"))
})

test_that("missing-data tables name the missing share _prop", {
  mr <- sframe_missing_data_results(likert_demo()$responses, likert_demo()$instrument)
  for (tab in list(mr$item_missing, mr$respondent_missing)) {
    expect_true("missing_prop" %in% names(tab))
    expect_equal(tab$missing_pct, 100 * tab$missing_prop)
    expect_true(all(tab$missing_pct >= 0 & tab$missing_pct <= 100))
  }
})

test_that("tables show the _prop column alone, headed in words", {
  cells <- sframe_apa_cells(data.frame(missing_prop = .25, missing_pct = .25))
  expect_identical(names(cells), "missing_prop")
  expect_identical(cells$missing_prop, ".25")
  expect_identical(sframe_apa_headings("missing_prop"), "Missing proportion")
  # an old column on its own still shows
  expect_identical(names(sframe_apa_cells(data.frame(missing_pct = .25))),
                   "missing_pct")
})

test_that("the (proportion) heading workaround is gone", {
  src <- sframe_source_text("R", "apa_format.R")
  expect_no_match(src, "_pct$", fixed = TRUE)
  expect_no_match(src, "(proportion)", fixed = TRUE)
})
