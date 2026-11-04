# tests/testthat/test-studio-design-browser.R
#
# SurveyStudio's Design screen (session 7): the SurveyBuilder in an iframe.
# Studio sends it the open instrument, and a save in the builder becomes the
# open instrument. Both sides take a message only from the other window on
# the same origin. Driven in a real Chrome against the build under test.

test_that("design is a Studio screen launch_studio() accepts", {
  expect_true("design" %in% sframe_studio_screens())
  expect_identical(sframe_studio_screen("design"), "design")
})

test_that("the instrument text Studio sends the builder reads back", {
  demo <- sframe_demo("likert_scale")
  out <- sframe_studio_sframe_text(demo$instrument)
  expect_type(out$text, "character")
  expect_null(out$problem)
  back <- read_sframe(text = out$text)
  expect_identical(back$meta$title, demo$instrument$meta$title)
  expect_null(sframe_studio_sframe_text(NULL)$text)
})

# An amended instrument, then changed again with no amendment recorded.
design_unrecorded_change <- function() {
  item <- sframe_item("q1", "How satisfied are you?", type = "text")
  instr <- sframe_instrument("Demo", components = list(item))
  item2 <- sframe_item("q1", "How satisfied are you overall?", type = "text")
  revised <- sframe_instrument("Demo", components = list(item2))
  amended <- amend_sframe(instr, revised, reason_code = "instrument_revision",
                          reason_text = "Clarified wording.",
                          deviation_report = "Wording only.")
  amended$items[[1]]$label <- "Changed with no amendment"
  amended
}

test_that("Studio never sends Design an instrument stripped of its amendments", {
  changed <- design_unrecorded_change()
  out <- sframe_studio_sframe_text(changed)
  expect_null(out$text)
  expect_match(out$problem, "not recorded as an amendment", fixed = TRUE)
  expect_length(changed$amendments, 1L)
})

studio_design_session <- function(launch) {
  libpath <- sframe_build_libpath()
  port <- httpuv::randomPort()
  proc <- callr::r_bg(launch, args = list(port), libpath = libpath)
  url <- paste0("http://127.0.0.1:", port)
  for (i in 1:180) {
    up <- tryCatch({ suppressWarnings(readLines(url, n = 1)); TRUE }, error = function(e) FALSE)
    if (up) break
    Sys.sleep(0.5)
  }
  if (!up) {
    proc$kill()
    return(NULL)
  }
  b <- sframe_chrome_session(width = 1280, height = 900)
  b$Page$navigate(url)
  js <- function(code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
  wait <- function(cond, n = 300) {
    for (i in 1:n) {
      if (isTRUE(tryCatch(js(cond), error = function(e) FALSE))) return(TRUE)
      Sys.sleep(0.5)
    }
    FALSE
  }
  list(proc = proc, b = b, js = js, wait = wait)
}

skip_without_studio_browser <- function() {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("shiny")
  skip_if_not_installed("chromote")
  skip_if_not_installed("callr")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")
}

test_that("the Design screen opens the instrument and a save becomes the open instrument", {
  skip_without_studio_browser()
  # The child loads the build under test with library(), never load_all().
  s <- studio_design_session(function(port) {
    library(surveyframe)
    launch_studio(demo = "likert_scale", screen = "design", port = port,
                  launch.browser = FALSE)
  })
  skip_if(is.null(s), "Studio did not start")
  on.exit({ s$b$close(); s$proc$kill() }, add = TRUE)
  js <- s$js
  wait <- s$wait

  frame <- "document.getElementById('design_frame').contentWindow"
  expect_true(wait("$('#screen-design').hasClass('active')"))
  expect_true(wait(paste0(frame, ".S && ", frame, ".S.items.length > 0")))
  title <- js(paste0(frame, ".S.meta.title"))
  status <- "((document.getElementById('design_status')||{}).innerText||'')"
  expect_true(wait(paste0(status, ".indexOf(", jsonlite::toJSON(title, auto_unbox = TRUE), ") >= 0")))

  # In Studio the builder saves to Studio, not to disk, and opens nothing.
  expect_true(js(paste0("var d=", frame, ".document; d.getElementById('openBtn').offsetParent === null")))
  expect_match(js(paste0(frame, ".document.getElementById('saveBtn').textContent")), "Save to Studio")

  # A message from any window but the builder is ignored.
  # Each message holds a real instrument under a new title, so only the
  # origin check stops it. Studio records what it would pass to the server.
  js(paste0(
    "window.sfSent = []; var set = Shiny.setInputValue;",
    "Shiny.setInputValue = function(k, v, o) { if (k === 'builder_sframe') sfSent.push(v); return set.apply(this, arguments); };",
    "var p = JSON.parse(studioDesignText); p.meta.title = 'From the wrong window';",
    "window.sfForged = JSON.stringify(p); true"))
  js("window.postMessage({type: 'sframe', text: sfForged}, location.origin); true")
  # Posted by the builder window to itself, not by its parent.
  js(paste0(frame, ".eval(\"window.postMessage({type: 'sframe', text: parent.sfForged}, location.origin)\"); true"))
  Sys.sleep(1.5)
  expect_identical(js("sfSent.length"), 0L)
  expect_identical(js(paste0(frame, ".S.meta.title")), title)

  # A save of changed content becomes the open instrument.
  js(paste0("var w=", frame, "; w.S._origin = null; w.S.meta.title = 'Renamed in Design'; w.saveSframe(); true"))
  # The demo has a history, so the save opens the amendment dialog (8a).
  expect_true(wait("$('#amend_dlg-as_new').is(':visible')"))
  js("$('#amend_dlg-as_new').click(); true")
  expect_true(wait(paste0(status, ".indexOf('Renamed in Design') >= 0")))
  expect_true(wait(paste0(frame, ".document.getElementById('saveSt').textContent.indexOf('Saved') >= 0")))
})

test_that("Studio opens on Design when it has no instrument", {
  skip_without_studio_browser()
  s <- studio_design_session(function(port) {
    library(surveyframe)
    launch_studio(port = port, launch.browser = FALSE)
  })
  skip_if(is.null(s), "Studio did not start")
  on.exit({ s$b$close(); s$proc$kill() }, add = TRUE)
  expect_true(s$wait("$('#screen-design').hasClass('active')"))
  expect_true(s$wait("!!document.getElementById('design_frame').contentWindow.S"))
})

test_that("Design shows why it cannot load an instrument with an unrecorded change", {
  skip_without_studio_browser()
  s <- studio_design_session(function(port) {
    library(surveyframe)
    item <- sframe_item("q1", "How satisfied are you?", type = "text")
    instr <- sframe_instrument("Demo", components = list(item))
    item2 <- sframe_item("q1", "How satisfied are you overall?", type = "text")
    revised <- sframe_instrument("Demo", components = list(item2))
    amended <- amend_sframe(instr, revised, reason_code = "instrument_revision",
                            reason_text = "Clarified wording.",
                            deviation_report = "Wording only.")
    amended$items[[1]]$label <- "Changed with no amendment"
    launch_studio(amended, screen = "design", port = port, launch.browser = FALSE)
  })
  skip_if(is.null(s), "Studio did not start")
  on.exit({ s$b$close(); s$proc$kill() }, add = TRUE)
  js <- s$js
  frame <- "document.getElementById('design_frame').contentWindow"
  status <- "((document.getElementById('design_status')||{}).innerText||'')"
  expect_true(s$wait(paste0(status, ".indexOf('not recorded as an amendment') >= 0")))
  expect_true(s$wait(paste0(frame, ".S && ", frame, ".document.getElementById('saveBtn').disabled")))
  expect_identical(js(paste0(frame, ".S.items.length")), 0L)

  # A save from the builder cannot replace the instrument and its history.
  js(paste0("var w=", frame, "; w.S._origin = null; w.S.meta.title = 'Saved over it'; w.saveSframe(); true"))
  Sys.sleep(2)
  expect_false(grepl("Saved over it", js(status), fixed = TRUE))
  js("$('[data-tab=\"amendments\"]').click(); true")
  expect_true(s$wait("((document.getElementById('amendment_log_table')||{}).innerText||'').indexOf('Clarified wording.') >= 0"))
})

