# tests/testthat/test-report-precomputed.R
#
# Naming decision 6. render_report() computes the report's content once,
# inside the namespace, and hands it to the Quarto template in an RDS file:
# the codebook display table, the plan results with their supplement tables,
# and every distribution chart. The template only prints. Before 0.4.3 the
# template ran the analysis plan and drew the charts itself through exported
# copies of internal helpers, so the 2 engines could disagree (CX-15).

skip_if_not_installed("ggplot2")

test_that("the chart specs carry a title, alt text and something to draw", {
  d <- sframe_demo("input_types")
  specs <- sframe_report_charts(d$instrument, d$responses)
  expect_true(length(specs) > 3)
  for (s in specs) {
    expect_true(nzchar(s$heading))
    expect_match(s$title, "^Distribution of ")
    expect_true(nzchar(s$alt))
    expect_true(inherits(s$plot, "ggplot") || is.function(s$draw))
  }
  # A scale draws its score.
  expect_true(any(grepl("scale scores$", vapply(specs, `[[`, "", "title"))))
})

test_that("the built-in engine draws the same charts, under the same titles", {
  d <- sframe_demo("input_types")
  specs <- sframe_report_charts(d$instrument, d$responses)
  html <- .render_report_distributions(d$instrument, d$responses)
  for (s in specs) {
    expect_match(html, htmltools_escape(s$title), fixed = TRUE)
  }
  expect_identical(lengths(regmatches(html, gregexpr("<figure", html))), length(specs))
})

test_that("the content holds the codebook table, the charts and the results", {
  d <- sframe_demo("two_group")
  content <- sframe_report_content(d$instrument, d$responses)
  expect_s3_class(content$codebook_items, "data.frame")
  expect_true(all(c("ID", "Label", "Required") %in% names(content$codebook_items)))
  expect_true(length(content$charts) > 0)
  direct <- run_analysis_plan(d$responses, d$instrument, plots = TRUE)
  expect_identical(vapply(content$results, function(r) r$apa %||% "", ""),
                   vapply(direct, function(r) r$apa %||% "", ""))
  expect_true(all(vapply(content$results, function(r) "supplement" %in% names(r), logical(1))))
})

test_that("the template prints the content and computes none of it", {
  qmd <- paste(readLines(system.file("templates", "report.qmd",
                                     package = "surveyframe")), collapse = "\n")
  expect_match(qmd, "params$content_path", fixed = TRUE)
  for (fn in c("run_analysis_plan(", "sframe_codebook_items_display(",
               "sframe_result_supplement(", "sframe_plot_item_chart(",
               "sframe_plot_scale_chart(", "sframe_draw_likert_diverging(",
               "sframe_likert_scale_groups(", "sframe_plot_likert_scale(",
               "sframe_plot_likert_matrix(")) {
    expect_false(grepl(fn, qmd, fixed = TRUE), label = fn)
  }
  expect_true("content_path" %in% sframe_quarto_param_names_path)
})
