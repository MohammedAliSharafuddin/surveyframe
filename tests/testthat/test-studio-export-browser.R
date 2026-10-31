# tests/testthat/test-studio-export-browser.R
#
# SurveyStudio's Export screen (session 7): the report options
# render_report() takes, a line naming the engine that will write the
# report, the analysis notebook as one zip, and a screen short enough to
# read. With the input_types demo's 36 research questions it was 43,730 px
# tall as a full page. Driven in a real Chrome against the build under test,
# with the built-in engine so the report is quick to write.

test_that("the Export screen offers the report options and stays short", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("shiny")
  skip_if_not_installed("chromote")
  skip_if_not_installed("callr")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")

  # The child loads the build under test with library(), never load_all().
  libpath <- sframe_build_libpath()
  port <- httpuv::randomPort()
  proc <- callr::r_bg(function(port) {
    options(surveyframe.use_quarto = FALSE)
    library(surveyframe)
    launch_studio(demo = "input_types", screen = "export", port = port,
                  launch.browser = FALSE)
  }, args = list(port), libpath = libpath)
  on.exit(proc$kill(), add = TRUE)
  url <- paste0("http://127.0.0.1:", port)
  for (i in 1:180) {
    up <- tryCatch({ suppressWarnings(readLines(url, n = 1)); TRUE }, error = function(e) FALSE)
    if (up) break
    Sys.sleep(0.5)
  }
  skip_if(!up, "Studio did not start")
  b <- chromote::ChromoteSession$new(width = 1280, height = 900)
  on.exit(b$close(), add = TRUE)
  b$Page$navigate(url)
  js <- function(code) {
    b$Runtime$evaluate(code, returnByValue = TRUE, awaitPromise = TRUE,
                      timeout_ = 120)$result$value
  }
  wait <- function(cond) {
    for (i in 1:300) {
      if (isTRUE(tryCatch(js(cond), error = function(e) FALSE))) return(TRUE)
      Sys.sleep(0.5)
    }
    FALSE
  }

  expect_true(wait("$('#screen-export').hasClass('active')"))
  expect_true(wait("$('#export_interpretations_ui img').length > 0"))
  Sys.sleep(2)
  expect_identical(js("$('.result-canvas-block').length"), 36L)
  expect_lt(js("document.documentElement.scrollHeight"), 8000)

  # Every option render_report() takes from a host is on the screen.
  for (id in c("rpt_title", "rpt_authors", "rpt_format", "rpt_show_code",
               "rpt_fig_width", "rpt_fig_height", "rpt_fig_dpi", "rpt_fig_format",
               "rpt_csl", "rpt_bibtex")) {
    expect_true(js(paste0("document.getElementById('", id, "') !== null")), info = id)
  }
  expect_true(wait("$('#export_engine_note').text().indexOf('built-in engine') >= 0"))

  # The options reach the report.
  js("$('#rpt_title').val('A title set on the Export screen').trigger('change'); true")
  js("$('#rpt_show_code').prop('checked', false).trigger('change'); true")
  Sys.sleep(1.5)
  report <- js("fetch($('#download_report_btn').attr('href')).then(function(r) { return r.text(); })")
  expect_match(report, "A title set on the Export screen", fixed = TRUE)
  expect_false(grepl("Show R code", report, fixed = TRUE))

  # The notebook's 3 files come as one zip.
  js("$('#qmd_prepare_btn').click(); true")
  expect_true(wait("!!$('#qmd_dl_zip').attr('href') && $('#qmd_dl_zip').attr('href') !== '#'"))
  head <- js(paste0(
    "fetch($('#qmd_dl_zip').attr('href')).then(function(r) { return r.arrayBuffer(); })",
    ".then(function(b) { var u = new Uint8Array(b); return String.fromCharCode(u[0], u[1]) + ':' + u.length; })"))
  expect_match(head, "^PK:")
  expect_gt(as.numeric(sub("^PK:", "", head)), 1000)
})
