# tests/testthat/test-studio-amend-browser.R
#
# Session 8a, CX-12, UX-05, UX-06 and UX-19. A save from Design of an
# instrument with a history opens Studio's 1 amendment dialog, which shows
# what the change touches and the version suggested, then records the
# amendment with amend_sframe(), or saves a new instrument, or cancels. The
# Amendments screen says "Edit in Design" and folds the upload under
# "Import an externally revised version". Driven in a real Chrome against the
# build under test.

test_that("a Design save of an instrument with a history goes through the amendment dialog", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("shiny")
  skip_if_not_installed("chromote")
  skip_if_not_installed("callr")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")

  libpath <- sframe_build_libpath()
  port <- httpuv::randomPort()
  proc <- callr::r_bg(function(port) {
    library(surveyframe)
    launch_studio(demo = "likert_scale", screen = "design", port = port,
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
  frame <- "document.getElementById('design_frame').contentWindow"
  # The modal is position: fixed, so its offsetParent is always null.
  # In brackets, so paste0("!", modal_open) negates all of it.
  modal_open <- "($('#shiny-modal').is(':visible') && $('#shiny-modal').text().indexOf('Record an amendment') >= 0)"
  modal_text <- "((document.querySelector('#shiny-modal')||{}).innerText||'')"
  # A select is a selectize widget, so its value is set through selectize.
  set_input <- function(id, value) {
    js(sprintf("(function(){ var e = $('#%s'), v = %s; if (e[0] && e[0].selectize) e[0].selectize.setValue(v); else e.val(v).trigger('input').trigger('change'); return true; })()", id,
               jsonlite::toJSON(value, auto_unbox = TRUE)))
  }
  log_text <- "((document.getElementById('amendment_log_table')||{}).innerText||'')"

  expect_true(wait(paste0(frame, ".S && ", frame, ".S.items.length > 0")))

  # A wording edit, saved: the dialog opens and the builder's own gate does not.
  js(paste0("var w=", frame, "; w.S.items[0].label = 'Reworded in Design'; w.setDirty(); w.saveSframe(); true"))
  expect_true(wait(modal_open))
  expect_match(js(modal_text), "Changed: items", fixed = TRUE)
  expect_match(js(modal_text), "Saved from Design", fixed = TRUE)
  expect_false(js(paste0(frame, ".document.getElementById('m-amend').classList.contains('open')")))
  # Instrument revision defaults to design, so 1.1.0 is suggested.
  expect_true(wait("$('#amend_dlg-version').val() === '1.1.0'"))

  # Record with no reason: refused, and the dialog stays.
  js("$('#amend_dlg-record').click(); true")
  expect_true(wait("document.body.innerText.indexOf('Not recorded') >= 0"))
  expect_true(js(modal_open))

  # A pipeline wording fix: 1.0.1 is suggested, and it records.
  set_input("amend_dlg-reason_code", "other")
  # The server sets the tier from the reason, so choose pipeline after it has.
  expect_true(wait("$('#amend_dlg-tier').val() === 'design'"))
  Sys.sleep(1)
  set_input("amend_dlg-tier", "pipeline")
  expect_true(wait("$('#amend_dlg-version').val() === '1.0.1'"))
  set_input("amend_dlg-reason_text", "Clarified wording in Design.")
  js("$('#amend_dlg-record').click(); true")
  expect_true(wait(paste0("!", modal_open)))
  # The builder now holds the log and the version.
  expect_true(wait(paste0("(", frame, ".S._carry.amendments||[]).length === 1")))
  expect_true(wait(paste0(frame, ".S.meta.version === '1.0.1'")))
  js("$('[data-tab=\"amendments\"]').click(); true")
  expect_true(wait(paste0(log_text, ".indexOf('Clarified wording in Design.') >= 0")))

  # The Amendments screen: Edit in Design, and the upload folded away.
  expect_false(grepl("Edit it in the SurveyBuilder", js("document.body.innerText"), fixed = TRUE))
  expect_true(js("!!document.querySelector('details.amend-import #amend_revised_file')"))
  expect_false(js("!!document.getElementById('apply_amendment_btn')"))
  js("$('#amend_edit_design').click(); true")
  expect_true(wait("(function(){ var s = document.getElementById('screen-design'); return !!s && s.offsetParent !== null; })()"))

  # Cancel saves nothing: still 1 amendment, and the builder says so.
  js(paste0("var w=", frame, "; w.S.items[0].label = 'Changed again'; w.setDirty(); w.saveSframe(); true"))
  expect_true(wait(modal_open))
  js("$('#amend_dlg-cancel').click(); true")
  expect_true(wait(paste0("!", modal_open)))
  expect_true(wait(paste0(frame, ".document.body.innerText.indexOf('Nothing was saved') >= 0")))
  js("$('[data-tab=\"amendments\"]').click(); true")
  expect_false(grepl("Changed again", js(log_text), fixed = TRUE))
})
