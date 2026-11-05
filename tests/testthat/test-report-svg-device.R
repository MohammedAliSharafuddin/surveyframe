# tests/testthat/test-report-svg-device.R
#
# Session CI (CI run 41984181153). On a Mac without XQuartz, R's own svg()
# cannot load Cairo: capabilities("cairo") still says TRUE, svg() only warns
# and opens nothing, so knitr wrote no figure and Quarto's Typst route, which
# draws SVG by default, stopped with "file not found". render_report() now
# probes svg() and falls back to svglite, else PNG. These tests mock the
# probe, so the fallback runs on Linux too.

test_that("the svg() probe leaves the graphics devices as it found them", {
  env <- surveyframe:::.sframe_figure_env
  old <- env$cairo_svg
  on.exit(env$cairo_svg <- old, add = TRUE)
  env$cairo_svg <- NULL
  grDevices::pdf(NULL)
  mine <- grDevices::dev.cur()
  on.exit(grDevices::dev.off(mine), add = TRUE)
  before <- grDevices::dev.list()
  res <- surveyframe:::sframe_cairo_svg_works()
  expect_type(res, "logical")
  expect_length(res, 1L)
  expect_identical(grDevices::dev.list(), before)
  expect_identical(grDevices::dev.cur(), mine)
  # Cached for the session: a second call does not probe again.
  expect_identical(env$cairo_svg, res)
})

test_that("the report's SVG device is svg(), else svglite, else PNG", {
  local_mocked_bindings(sframe_cairo_svg_works = function() TRUE,
                        sframe_has_svglite = function() TRUE, .package = "surveyframe")
  expect_identical(surveyframe:::sframe_report_svg_device(), "svg")
  local_mocked_bindings(sframe_cairo_svg_works = function() FALSE, .package = "surveyframe")
  expect_identical(surveyframe:::sframe_report_svg_device(), "svglite")
  local_mocked_bindings(sframe_has_svglite = function() FALSE, .package = "surveyframe")
  expect_identical(surveyframe:::sframe_report_svg_device(), "png")
})

test_that("ggsave() SVG counts as available only with svglite", {
  local_mocked_bindings(sframe_has_svglite = function() FALSE, .package = "surveyframe")
  expect_false(surveyframe:::sframe_svg_available())
  expect_error(surveyframe:::sframe_check_svg(), "svglite", class = "sframe_error")
})

typst_pdf <- function() {
  old <- options(surveyframe.use_quarto = TRUE, surveyframe.latex = FALSE)
  on.exit(options(old), add = TRUE)
  d <- sframe_demo("likert_scale")
  out <- tempfile(fileext = ".pdf")
  msgs <- character(0)
  withCallingHandlers(
    render_report(d$instrument, data = d$responses, output_file = out, format = "pdf",
                  open = FALSE),
    message = function(m) {
      msgs <<- c(msgs, conditionMessage(m))
      invokeRestart("muffleMessage")
    })
  list(out = out, msgs = msgs)
}

test_that("a Typst PDF draws PNG figures where svg() cannot open and svglite is absent", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  local_mocked_bindings(sframe_cairo_svg_works = function() FALSE,
                        sframe_has_svglite = function() FALSE, .package = "surveyframe")
  r <- typst_pdf()
  expect_identical(readBin(r$out, "raw", 4), charToRaw("%PDF"))
  expect_true(any(grepl("figures are drawn with PNG", r$msgs, fixed = TRUE)))
  expect_true(any(grepl("XQuartz", r$msgs, fixed = TRUE)))
})

test_that("a Typst PDF draws its figures with svglite where svg() cannot open", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  skip_if_not_installed("svglite")
  local_mocked_bindings(sframe_cairo_svg_works = function() FALSE, .package = "surveyframe")
  r <- typst_pdf()
  expect_identical(readBin(r$out, "raw", 4), charToRaw("%PDF"))
  expect_true(any(grepl("figures are drawn with svglite", r$msgs, fixed = TRUE)))
})

test_that("the report source renders a Typst PDF where svg() opens nothing", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  # Quarto's own R session starts with this profile, which makes svg() act
  # as it does on a Mac without XQuartz: a warning and no device.
  profile <- tempfile(fileext = ".R")
  writeLines(c(
    "local({",
    "  ns <- asNamespace('grDevices')",
    "  unlockBinding('svg', ns)",
    "  assign('svg', function(...) { warning('failed to load cairo DLL'); invisible() }, envir = ns)",
    "  lockBinding('svg', ns)",
    "})"), profile)
  d <- sframe_demo("likert_scale")
  dir <- tempfile("svg-source-")
  suppressMessages(render_report(d$instrument, data = d$responses, output_file = dir,
                                 format = "qmd", open = FALSE))
  out <- quarto_render_in(dir, "typst", c(R_PROFILE_USER = profile))
  expect_true(file.exists(file.path(dir, "report.pdf")),
              info = paste(utils::tail(out, 20), collapse = "\n"))
})
