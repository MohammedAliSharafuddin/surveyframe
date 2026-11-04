# tests/testthat/test-builder-ui2-browser.R
#
# Session UI-2's builder screens in a real Chrome, 1 tab for the file
# (helper-ui2-browser.R): the citation picker on the plan fields, and the
# items that follow it in the UI-2 block.
#
# Skipped on CRAN and wherever chromote or Chrome is unavailable.

skip_on_cran()
skip_if_not_slow()
skip_if_not_installed("chromote")
chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome),
        "Chrome not available")

js <- function(s, code, await = FALSE) ui2_js(s, code, await)
q <- function(x) jsonlite::toJSON(x, auto_unbox = TRUE)

# -- Citation picker -----------------------------------------------------------

test_that("typing @ in a plan field lists the references and inserts the pick", {
  s <- ui2_builder(sframe_references_fixture())
  js(s, "openRQModal('rq1');document.getElementById('rq-q').value='';1")
  ui2_type(s, "rq-q", "Agreement scales @")
  expect_true(ui2_wait(s, "!document.querySelector('.sfcp').hidden"))
  expect_identical(js(s, "document.activeElement.id"), "sfcp-q")
  expect_identical(js(s, "document.querySelectorAll('#sfcp-list .sfcp-o').length"), 4L)
  # Filtered as typed, by author.
  js(s, "var i=document.getElementById('sfcp-q');i.value='likert';i.dispatchEvent(new Event('input',{bubbles:true}));1")
  expect_identical(js(s, "document.querySelectorAll('#sfcp-list .sfcp-o').length"), 1L)
  expect_match(js(s, "document.querySelector('#sfcp-list .sfcp-o').textContent"),
               "@likert_1932Likert (1932)", fixed = TRUE)
  ui2_key(s, "#sfcp-q", "Enter")
  expect_false(js(s, "document.getElementById('sfcp-st').hidden"))
  expect_identical(js(s, "document.getElementById('sfcp-narr').textContent"), "Likert (1932)")
  expect_identical(js(s, "document.getElementById('sfcp-paren').textContent"), "(Likert, 1932)")
  js(s, "document.getElementById('sfcp-paren').click();1")
  expect_identical(js(s, "document.getElementById('rq-q').value"),
                   "Agreement scales [@likert_1932]")
  expect_true(js(s, "document.querySelector('.sfcp').hidden"))
  expect_identical(js(s, "document.activeElement.id"), "rq-q")
})

test_that("the Cite button inside an open bracket adds ; @key without asking", {
  s <- ui2_builder(sframe_references_fixture())
  js(s, "openRQModal('rq1');var e=document.getElementById('rq-h1');e.value='As found [@likert_1932]';e.focus();e.setSelectionRange(22,22);1")
  js(s, "document.getElementById('rq-h1').parentNode.querySelector('.sfcp-btn').click();1")
  expect_true(ui2_wait(s, "!document.querySelector('.sfcp').hidden"))
  js(s, "var i=document.getElementById('sfcp-q');i.value='working paper';i.dispatchEvent(new Event('input',{bubbles:true}));1")
  js(s, "document.querySelector('#sfcp-list .sfcp-o').click();1")
  expect_identical(js(s, "document.getElementById('rq-h1').value"),
                   "As found [@likert_1932; @max_nd]")
})

test_that("Escape closes the picker and keeps the @ typed", {
  s <- ui2_builder(sframe_references_fixture())
  js(s, "openRQModal('rq1');document.getElementById('rq-interp').value='';1")
  ui2_type(s, "rq-interp", "Mail @")
  expect_true(ui2_wait(s, "!document.querySelector('.sfcp').hidden"))
  ui2_key(s, "#sfcp-q", "Escape")
  expect_true(js(s, "document.querySelector('.sfcp').hidden"))
  expect_identical(js(s, "document.activeElement.id"), "rq-interp")
  expect_identical(js(s, "document.getElementById('rq-interp').value"), "Mail @")
  # The plan dialog stays open: Escape went to the picker alone.
  expect_true(js(s, "document.getElementById('m-rq').classList.contains('open')"))
})

test_that("an unknown key is shown under the field with its message", {
  s <- ui2_builder(sframe_references_fixture())
  js(s, "openRQModal('rq1');1")
  js(s, "var e=document.getElementById('rq-h0');e.value='No difference [@nobody_2001; @cohen_1988]';e.dispatchEvent(new Event('input',{bubbles:true}));1")
  expect_true(ui2_wait(s, "document.getElementById('rq-h0').getAttribute('aria-invalid')==='true'"))
  msg <- js(s, "document.getElementById(document.getElementById('rq-h0').getAttribute('aria-describedby').split(' ').pop()).textContent")
  # cohen_1988 is a built-in method reference, so only nobody_2001 is unknown.
  expect_identical(msg, "@nobody_2001 No reference with this key. Add it under References.")
  expect_identical(js(s, "document.querySelector('.sfcp-bad').textContent"), "@nobody_2001")
})

test_that("Manage references opens Settings on References above the plan", {
  s <- ui2_builder(sframe_references_fixture())
  js(s, "openRQModal('rq1');document.getElementById('rq-manage-refs').focus();document.getElementById('rq-manage-refs').click();1")
  expect_true(js(s, "document.getElementById('m-settings').classList.contains('open')"))
  expect_true(js(s, "document.getElementById('m-settings').classList.contains('stack')"))
  expect_true(js(s, "document.getElementById('sp-refs').classList.contains('active')"))
  js(s, "closeModal('m-settings');1")
  expect_true(js(s, "document.getElementById('m-rq').classList.contains('open')"))
  expect_identical(js(s, "document.activeElement.id"), "rq-manage-refs")
})

test_that("the report outline's interpretation takes the picker too", {
  s <- ui2_builder(sframe_references_fixture())
  # A block with a result, as one returned from R would carry.
  js(s, "S.analysis_plan[0].result={summary:'t(58) = 2.1'};setMode('analyse');setAnalyseTab('report');1")
  expect_true(ui2_wait(s, "document.getElementById('rsInterp_0')"))
  expect_true(js(s, "!!document.getElementById('rsInterp_0').parentNode.querySelector('.sfcp-btn')"))
})

ui2_close()
