# tests/testthat/test-figure-settings.R
#
# Ethos request 19 (2026-10-03). render_report() and the plot functions fixed
# their own output: a report gave its figures at 1344 by 960 px with no way to
# ask otherwise, and the built-in engine saved charts at 110 dpi.

png_size <- function(path) {
  # Width and height from the PNG header, bytes 17 to 24.
  con <- file(path, "rb"); on.exit(close(con))
  h <- readBin(con, "raw", 24)
  c(width = sum(as.integer(h[17:20]) * 256^(3:0)), height = sum(as.integer(h[21:24]) * 256^(3:0)))
}

test_that("19: figure settings are checked", {
  expect_error(surveyframe:::sframe_figure_settings(list(dpi = -1)), "positive")
  expect_error(surveyframe:::sframe_figure_settings(list(size = 3)), "Unknown: size")
  expect_error(surveyframe:::sframe_figure_settings(list(format = "bmp")), "must be one of")
  expect_identical(surveyframe:::sframe_figure_settings(list(format = "JPG"))$format, "jpeg")
})

test_that("19: sframe_save_figures() writes each chart at the stated size and resolution", {
  skip_if_not_installed("ggplot2")
  d <- sframe_demo("two_group")
  res <- run_analysis_plan(d$responses, d$instrument, plots = TRUE)
  dir <- file.path(tempdir(), "fig-save-test")
  paths <- sframe_save_figures(res, dir, width = 5, height = 3, dpi = 300)
  expect_true(length(paths) > 0)
  expect_true(all(file.exists(paths)))
  expect_equal(unname(png_size(paths[[1]])), c(1500, 900))
  tiff <- sframe_save_figures(res[1], dir, format = "tiff", dpi = 100, width = 4, height = 2)
  expect_match(tiff[[1]], "\\.tiff$")
  expect_true(file.exists(tiff[[1]]))
})

test_that("19: the built-in engine draws charts at the stated size and dpi", {
  skip_if_not_installed("ggplot2")
  gg <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) + ggplot2::geom_point()
  env <- surveyframe:::.sframe_figure_env
  old <- env$settings; on.exit(env$settings <- old)
  env$settings <- list(width = 4, height = 2, dpi = 200)
  img <- surveyframe:::.render_report_ggplot_png(gg)
  b64 <- sub("\".*$", "", sub("^.*base64,", "", img))
  f <- tempfile(fileext = ".png"); writeBin(openssl::base64_decode(b64), f)
  expect_equal(unname(png_size(f)), c(800, 400))
  env$settings <- list(format = "svg")
  expect_match(surveyframe:::.render_report_ggplot_png(gg), "data:image/svg+xml;base64,", fixed = TRUE)
})

test_that("19: render_report() takes figures and figure_dir", {
  skip_on_cran()
  skip_if_not_installed("ggplot2")
  d <- sframe_demo("two_group")
  dir <- file.path(tempdir(), "fig-report-test")
  out <- tempfile(fileext = ".html")
  suppressMessages(render_report(d$instrument, d$responses, output_file = out,
                                 figures = list(width = 6, height = 4, dpi = 150),
                                 figure_dir = dir))
  saved <- list.files(dir, pattern = "\\.png$", full.names = TRUE)
  expect_true(length(saved) > 0)
  expect_equal(unname(png_size(saved[1])), c(900, 600))
  # Inside the report, the analysis charts are drawn at 6 by 4 inches, 150 dpi.
  html <- paste(readLines(out, warn = FALSE), collapse = "")
  imgs <- regmatches(html, gregexpr("data:image/png;base64,[A-Za-z0-9+/=]+", html))[[1]]
  sizes <- vapply(imgs, function(s) {
    f <- tempfile(fileext = ".png")
    writeBin(openssl::base64_decode(sub("^data:image/png;base64,", "", s)), f)
    paste(png_size(f), collapse = "x")
  }, character(1))
  expect_true("900x600" %in% sizes)
  expect_error(render_report(d$instrument, NULL, output_file = out, figure_dir = dir),
               "needs `data`")
})
