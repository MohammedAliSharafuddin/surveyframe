# tests/testthat/test-v034-family-plots.R
# v0.3.4 visualisation breadth: regression diagnostics, EFA scree/loadings,
# reliability plot, mosaic, correlation matrix heatmap, quality plot, and the
# shared dashboard/studio item and scale charts. Uses the bundled demo data
# (sframe_demo_data()) so results reflect a realistic multi-scale instrument.

test_that("regression diagnostics: run_analysis_plan attaches four ggplot panels", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  res <- run_analysis_plan(demo$responses, demo$instrument, plots = TRUE)
  reg <- Filter(function(r) identical(r$test, "regression_linear"), res)
  skip_if(length(reg) == 0, "demo plan has no regression_linear block")
  dp <- reg[[1]]$diagnostic_plots
  expect_type(dp, "list")
  expect_setequal(names(dp), c("residuals_fitted", "qq", "scale_location", "leverage"))
  expect_true(all(vapply(dp, inherits, logical(1), what = "ggplot")))
})

test_that("sframe_plot_regression_diagnostics returns NULL without a diagnostics data frame", {
  skip_if_not_installed("ggplot2")
  expect_null(sframe_plot_regression_diagnostics(list(test = "regression_linear")))
})

test_that("plot.sframe_reliability_report builds a ggplot with alpha and omega bars", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  scored <- score_scales(demo$responses, demo$instrument)
  rr <- reliability_report(scored, demo$instrument)
  gg <- plot(rr)
  expect_s3_class(gg, "ggplot")
})

test_that("plot.sframe_efa_report builds a scree plot with the suggested-factor marker", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  scored <- score_scales(demo$responses, demo$instrument)
  er <- efa_report(scored, demo$instrument)
  gg <- plot(er)
  expect_s3_class(gg, "ggplot")
})

test_that("plot.sframe_efa_solution builds a loadings heatmap", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  scored <- score_scales(demo$responses, demo$instrument)
  es <- efa_solution(scored, demo$instrument, nfactors = 2)
  gg <- plot(es)
  expect_s3_class(gg, "ggplot")
})

test_that("plot.sframe_quality_report builds a straight-lining flag-rate bar chart", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  qr <- quality_report(demo$responses, demo$instrument)
  gg <- plot(qr)
  expect_s3_class(gg, "ggplot")
})

test_that("report-level results (quality, reliability, EFA) gain a plot via run_analysis_plan", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  res <- run_analysis_plan(demo$responses, demo$instrument, plots = TRUE)
  by_test <- function(t) Filter(function(r) identical(r$test, t), res)
  for (t in c("quality", "reliability_alpha", "reliability_omega",
              "efa_readiness", "efa_solution")) {
    blocks <- by_test(t)
    skip_if(length(blocks) == 0, paste("no", t, "block in demo plan"))
    expect_s3_class(blocks[[1]]$plot, "ggplot")
  }
})

test_that("sframe_plot_correlation_matrix builds a heatmap from real response data", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  num_items <- unique(unlist(lapply(demo$instrument$scales, function(s) s$items)))
  num_items <- intersect(num_items, names(demo$responses))[1:4]
  gg <- sframe_plot_correlation_matrix(demo$responses, num_items)
  expect_s3_class(gg, "ggplot")
})

test_that("sframe_plot_correlation_matrix returns NULL on a runner error", {
  skip_if_not_installed("ggplot2")
  gg <- sframe_plot_correlation_matrix(data.frame(a = 1), c("a", "missing_col"))
  expect_null(gg)
})

test_that("sframe_draw_mosaic renders a crosstab result without error", {
  demo <- sframe_demo_data()
  res <- run_analysis_plan(demo$responses, demo$instrument, plots = FALSE)
  ct <- Filter(function(r) identical(r$test, "crosstab"), res)
  skip_if(length(ct) == 0, "demo plan has no crosstab block")
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  grDevices::png(tmp, width = 500, height = 400)
  expect_no_error(sframe_draw_mosaic(ct[[1]]))
  grDevices::dev.off()
  expect_gt(file.size(tmp), 0)
})

test_that("sframe_draw_mosaic no-ops gracefully on an errored result", {
  expect_null(sframe_draw_mosaic(list(error = "no data")))
})

test_that("sframe_plot_item_chart covers choice, numeric, and unsupported item types", {
  skip_if_not_installed("ggplot2")
  likert_item <- list(type = "likert", label = "Satisfaction")
  cs <- list(values = 1:5, labels = c("SD", "D", "N", "A", "SA"))
  gg1 <- sframe_plot_item_chart(likert_item, sample(1:5, 40, replace = TRUE), cs)
  expect_s3_class(gg1, "ggplot")

  numeric_item <- list(type = "numeric", label = "Age")
  gg2 <- sframe_plot_item_chart(numeric_item, sample(18:70, 40, replace = TRUE))
  expect_s3_class(gg2, "ggplot")

  text_item <- list(type = "text", label = "Comments")
  expect_null(sframe_plot_item_chart(text_item, c("a", "b")))

  expect_null(sframe_plot_item_chart(numeric_item, c(NA, NA)))
})

test_that("sframe_plot_scale_chart draws a histogram with a mean line and handles empty input", {
  skip_if_not_installed("ggplot2")
  gg <- sframe_plot_scale_chart(rnorm(50, 3, 1), "Satisfaction")
  expect_s3_class(gg, "ggplot")
  expect_null(sframe_plot_scale_chart(c(NA_real_, NA_real_), "Empty"))
})

test_that("plot.sframe_descriptives_report builds a skewness/kurtosis bar chart", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  dr <- descriptives_report(demo$responses)
  gg <- plot(dr)
  expect_s3_class(gg, "ggplot")
})

test_that("sframe_plot_descriptives facets by group when split_by is used", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  skip_if_not("visit_type" %in% names(demo$responses), "demo data has no visit_type column")
  dr <- descriptives_report(demo$responses, split_by = "visit_type")
  gg <- sframe_plot_descriptives(dr)
  expect_s3_class(gg, "ggplot")
  expect_true("FacetWrap" %in% class(gg$facet))
})

test_that("sframe_plot_descriptives returns NULL on an empty table", {
  skip_if_not_installed("ggplot2")
  empty <- structure(list(table = data.frame()), class = "sframe_descriptives_report")
  expect_null(sframe_plot_descriptives(empty))
})

test_that("descriptives results gain a plot via run_analysis_plan", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  res <- run_analysis_plan(demo$responses, demo$instrument, plots = TRUE)
  desc <- Filter(function(r) identical(r$test, "descriptives"), res)
  skip_if(length(desc) == 0, "demo plan has no descriptives block")
  expect_s3_class(desc[[1]]$plot, "ggplot")
})

test_that("group-comparison tests (t/Mann-Whitney/Kruskal-Wallis/ANOVA) gain a boxplot", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  res <- run_analysis_plan(demo$responses, demo$instrument, plots = TRUE)
  for (t in c("t_test_ind", "mann_whitney", "kruskal_wallis", "anova_one")) {
    blocks <- Filter(function(r) identical(r$test, t), res)
    skip_if(length(blocks) == 0, paste("no", t, "block in demo plan"))
    expect_s3_class(blocks[[1]]$plot, "ggplot")
  }
})

test_that("sframe_plot_group_comparison returns NULL for missing columns or a single group", {
  skip_if_not_installed("ggplot2")
  expect_null(sframe_plot_group_comparison(list(vars = c("a", "b")), data.frame(z = 1)))
  one_group <- data.frame(g = rep("x", 10), y = rnorm(10))
  expect_null(sframe_plot_group_comparison(list(vars = c("g", "y")), one_group))
})

test_that("paired tests (t_test_pair, wilcoxon_pair) gain a slope plot", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  res <- run_analysis_plan(demo$responses, demo$instrument, plots = TRUE)
  for (t in c("t_test_pair", "wilcoxon_pair")) {
    blocks <- Filter(function(r) identical(r$test, t), res)
    skip_if(length(blocks) == 0, paste("no", t, "block in demo plan"))
    expect_s3_class(blocks[[1]]$plot, "ggplot")
  }
})

test_that("sframe_plot_paired_comparison returns NULL with fewer than two complete pairs", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(x = c(1, NA), y = c(NA, 2))
  expect_null(sframe_plot_paired_comparison(list(vars = c("x", "y")), df))
})

test_that("sframe_plot_variable_distribution returns three ggplot panels", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  vd <- sframe_plot_variable_distribution(demo$responses, "dm_1")
  expect_setequal(names(vd), c("histogram", "boxplot", "qq"))
  expect_true(all(vapply(vd, inherits, logical(1), what = "ggplot")))
})

test_that("sframe_plot_variable_distribution returns NULL for a missing or degenerate column", {
  skip_if_not_installed("ggplot2")
  expect_null(sframe_plot_variable_distribution(data.frame(a = 1), "missing"))
  expect_null(sframe_plot_variable_distribution(data.frame(a = c(1, NA)), "a"))
})

test_that("plot_palette threads from run_analysis_plan to attached plots", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  res_p <- run_analysis_plan(demo$responses, demo$instrument,
                             plots = TRUE, plot_palette = "print")
  freq <- Filter(function(r) identical(r$test, "frequency"), res_p)
  skip_if(length(freq) == 0, "demo plan has no frequency block")
  # The print palette fills bars with the light print grey, never the teal.
  built <- ggplot2::ggplot_build(freq[[1]]$plot)
  fills <- unique(unlist(lapply(built$data, function(d) d$fill)))
  fills <- fills[!is.na(fills)]
  expect_true(any(grepl("#cccccc", fills, ignore.case = TRUE)))
  expect_false(any(grepl("#0E9694", fills, ignore.case = TRUE)))
  expect_error(
    run_analysis_plan(demo$responses, demo$instrument,
                      plots = TRUE, plot_palette = "neon"),
    "web|print"
  )
})

test_that("render_report accepts plot_palette and renders with the print theme", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  out <- tempfile(fileext = ".html")
  old <- options(surveyframe.use_quarto = FALSE)
  on.exit({options(old); unlink(out)}, add = TRUE)
  render_report(demo$instrument, demo$responses, output_file = out,
                plot_palette = "print")
  expect_true(file.exists(out))
  expect_true(grepl("<img", paste(readLines(out, warn = FALSE), collapse = "")))
})

test_that("render_report embeds regression diagnostic panels beside the main chart", {
  skip_if_not_installed("ggplot2")
  demo <- sframe_demo_data()
  old_opt <- options(surveyframe.use_quarto = FALSE)
  on.exit(options(old_opt), add = TRUE)
  out <- tempfile(fileext = ".html")
  on.exit(unlink(out), add = TRUE)
  render_report(demo$instrument, demo$responses, output_file = out)
  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  n_images <- lengths(regmatches(html, gregexpr("data:image/png;base64", html)))
  expect_gt(n_images, 30) # item distributions + family plots + 4 diagnostic panels
})
