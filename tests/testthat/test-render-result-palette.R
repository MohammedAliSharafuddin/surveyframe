# tests/testthat/test-render-result-palette.R
#
# CX-19. render_result() used the chart attached to a result whatever the
# `palette` argument said. An explicit palette now rebuilds the chart with it,
# and without one the attached chart is used.

test_that("CX-19: an explicit palette rebuilds the chart, no palette keeps the attached one", {
  skip_if_not_installed("ggplot2")
  d <- sframe_demo("two_group")
  res <- run_analysis_plan(d$responses, d$instrument)
  r <- res[[1]]
  attached <- ggplot2::ggplot() + ggplot2::ggtitle("attached chart")
  r$plot <- attached

  default <- render_result(r, d$responses, d$instrument, format = "png")
  expect_identical(default$chart$labels$title, "attached chart")

  web <- render_result(r, d$responses, d$instrument, palette = "web", format = "png")
  expect_false(identical(web$chart$labels$title, "attached chart"))
  print_pal <- render_result(r, d$responses, d$instrument, palette = "print", format = "png")
  expect_false(identical(print_pal$chart$labels$title, "attached chart"))
  expect_s3_class(print_pal$chart, "ggplot")

  # The rebuilt chart is the one the report would draw with that palette.
  fresh <- render_result(within(r, rm(plot)), d$responses, d$instrument,
                         palette = "print", format = "png")
  expect_identical(print_pal$chart$labels$title, fresh$chart$labels$title)
})
