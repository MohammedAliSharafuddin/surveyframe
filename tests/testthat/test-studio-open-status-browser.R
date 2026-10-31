# tests/testthat/test-studio-open-status-browser.R
#
# The Open Instrument screen says where the open instrument came from
# (session 7, owner review of f8fe6a6): "Loaded from R" for one launch_studio()
# was given, "File checked: hash verified" for an opened file, "Saved from
# Design: hash verified" for a Design save, and the failure wording when a
# check fails. A Design save showed "Not verified", though its hash was
# checked. The screen no longer sends the researcher to the SurveyBuilder,
# and the plan's count is labelled "Research questions". Driven in a real
# Chrome against the build under test.

test_that("the Open Instrument screen says where the instrument came from", {
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
    library(surveyframe)
    launch_studio(demo = "likert_scale", screen = "open", port = port,
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
  js <- function(code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
  wait <- function(cond, n = 120) {
    for (i in 1:n) {
      if (isTRUE(tryCatch(js(cond), error = function(e) FALSE))) return(TRUE)
      Sys.sleep(0.5)
    }
    FALSE
  }
  status <- "((document.getElementById('open_status')||{}).innerText||'')"
  open_text <- "$('#screen-open').text()"
  go_open <- function() {
    js("$('.studio-nav-item a[data-tab=\"open\"]').click(); true")
    wait("$('#screen-open').hasClass('active')")
  }

  # From R.
  expect_true(wait("$('#screen-open').hasClass('active')"))
  expect_true(wait(paste0(status, ".indexOf('Loaded from R') >= 0")))
  expect_false(grepl("file-checked", js(status), fixed = TRUE))
  expect_false(grepl("no file was checked", js(status), fixed = TRUE))
  expect_false(grepl("Design questions, welcome screen", js(open_text), fixed = TRUE))
  expect_true(wait("$('#instrument_summary_card .stat-lbl').filter(function() { return $(this).text() === 'Research questions'; }).length === 1"))
  expect_identical(js("$('#screen-open .stat-lbl').filter(function() { return $(this).text() === 'Plans'; }).length"), 0L)

  # A Design save.
  frame <- "document.getElementById('design_frame').contentWindow"
  js("$('.studio-nav-item a[data-tab=\"design\"]').click(); true")
  expect_true(wait(paste0(frame, ".S && ", frame, ".S.items.length > 0")))
  js(paste0("var w=", frame, "; w.S._origin = null; w.S.meta.title = 'Saved in Design'; w.saveSframe(); true"))
  expect_true(wait("((document.getElementById('design_status')||{}).innerText||'').indexOf('Saved in Design') >= 0"))
  expect_true(go_open())
  expect_true(wait(paste0(status, ".indexOf('Saved from Design: hash verified') >= 0")))
  expect_false(grepl("Not verified", js(status), fixed = TRUE))

  # An opened file.
  path <- tempfile(fileext = ".sframe")
  write_sframe(sframe_demo("two_group")$instrument, path)
  doc <- b$DOM$getDocument()
  node <- b$DOM$querySelector(doc$root$nodeId, "#instr_file")
  b$DOM$setFileInputFiles(files = list(normalizePath(path)), nodeId = node$nodeId)
  expect_true(wait("$('#screen-preview').hasClass('active')"))
  expect_true(go_open())
  expect_true(wait(paste0(status, ".indexOf('File checked: hash verified') >= 0")))
})
