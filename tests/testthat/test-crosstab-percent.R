# tests/testthat/test-crosstab-percent.R
#
# Cross-tab percentages and totals (owner 2026-10-31). crosstab and
# chi_square take options$percent = "row", "column" or "total", and every
# result carries a totals row and column. The percentages follow their
# denominator: the Total row of row percentages is the column distribution,
# and the Total column of column percentages is the row distribution.
# Expected values: Codex T2 (base R prop.table() and addmargins(), surveyframe
# not loaded), copied unchanged into fixtures/t2_crosstab_expected.csv: 3
# demo pairs, 30 rows, with a zero cell in `paired`.

t2 <- utils::read.csv(test_path("fixtures", "t2_crosstab_expected.csv"), stringsAsFactors = FALSE)
pairs <- unique(t2[c("dataset", "row_var", "col_var")])

cell <- function(tab, r, c) tab[match(r, tab[[1]]), c]

test_that("crosstab totals and percentages match prop.table() and addmargins()", {
  for (k in seq_len(nrow(pairs))) {
    p <- pairs[k, ]
    d <- sframe_demo(p$dataset)$responses
    exp <- t2[t2$dataset == p$dataset, ]
    for (how in c("row", "column", "total")) {
      res <- sframe_run_crosstab(d, c(p$row_var, p$col_var), list(percent = how))
      expect_null(res$error)
      expect_identical(res$percent, how)
      col <- c(row = "pct_row", column = "pct_col", total = "pct_total")[[how]]
      for (j in seq_len(nrow(exp))) {
        e <- exp[j, ]
        expect_equal(cell(res$totals, e$row_level, e$col_level), e$count,
                     info = paste(p$dataset, e$row_level, e$col_level))
        expect_equal(cell(res$percent_table, e$row_level, e$col_level), e[[col]],
                     tolerance = 1e-9, info = paste(p$dataset, how, e$row_level, e$col_level))
      }
    }
  }
})

test_that("the zero cell in paired is 0, and its percentages are 0", {
  exp <- t2[t2$dataset == "paired" & t2$count == 0, ]
  expect_true(nrow(exp) >= 1)
  d <- sframe_demo("paired")$responses
  res <- sframe_run_crosstab(d, c("recommend_before", "recommend_after"), list(percent = "row"))
  expect_equal(cell(res$totals, exp$row_level[1], exp$col_level[1]), 0)
  expect_equal(cell(res$percent_table, exp$row_level[1], exp$col_level[1]), 0)
})

test_that("without percent the result still has totals and no percent table", {
  d <- sframe_demo("categorical")$responses
  res <- sframe_run_crosstab(d, c("format", "preferred_session_type"))
  expect_true("Total" %in% res$totals[[1]])
  expect_true("Total" %in% names(res$totals))
  expect_null(res$percent_table)
  expect_null(sframe_result_supplement(res))
})

test_that("a percent that is not row, column or total is an error result", {
  d <- sframe_demo("categorical")$responses
  res <- sframe_run_crosstab(d, c("format", "preferred_session_type"), list(percent = "cell"))
  expect_match(res$error, "row, column or total", fixed = TRUE)
})

test_that("the APA table gives each count with its percentage beside it", {
  d <- sframe_demo("small_sample")$responses
  res <- sframe_run_crosstab(d, c("format", "will_return"), list(percent = "row"))
  sup <- sframe_result_supplement(res)
  expect_match(sup$caption, "row percentages", fixed = TRUE)
  expect_identical(cell(sup$table, "in_person", "no"), "1 (11.1%)")
  expect_identical(cell(sup$table, "Total", "Total"), "18 (100.0%)")
})

test_that("a plan block's percent option is read, not reported as ignored", {
  ins <- sframe_demo("categorical")$instrument
  d <- sframe_demo("categorical")$responses
  ins$analysis_plan <- list(list(id = "RQ1", research_question = "Do they differ?",
    method = "chi_square", roles = list(row = "format", column = "preferred_session_type"),
    options = list(percent = "column")))
  res <- suppressWarnings(run_analysis_plan(d, ins))
  expect_identical(res[[1]]$percent, "column")
  # Levels read as labels, as in the counts table, so the chart can match them.
  expect_identical(res[[1]]$totals[[1]], c(rownames(res[[1]]$table), "Total"))
  expect_identical(names(res[[1]]$totals)[-1], c(names(res[[1]]$table), "Total"))
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    built <- ggplot2::ggplot_build(sframe_plot_crosstab(res[[1]]))$data[[1]]
    expect_false(anyNA(built$y))
  }
  expect_false(any(grepl("percent", unlist(res[[1]]$options_ignored %||% character(0)))))
})

test_that("sframe_plot_crosstab() draws percentages when percent is set", {
  skip_if_not_installed("ggplot2")
  d <- sframe_demo("small_sample")$responses
  res <- sframe_run_crosstab(d, c("format", "will_return"), list(percent = "row"))
  g <- sframe_plot_crosstab(res)
  expect_match(g$labels$y, "Percent", fixed = TRUE)
  built <- ggplot2::ggplot_build(g)$data[[1]]
  expect_equal(sort(built$y), sort(c(100 / 9, 800 / 9, 200 / 9, 700 / 9)), tolerance = 1e-9)
  counts <- sframe_plot_crosstab(sframe_run_crosstab(d, c("format", "will_return")))
  expect_identical(counts$labels$y, "Count")
})
