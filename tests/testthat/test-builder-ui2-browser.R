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

test_that("Cite on the toolbar inside an open bracket adds ; @key without asking", {
  s <- ui2_builder(sframe_references_fixture())
  js(s, "openRQModal('rq1');var e=document.getElementById('rq-h1');e.value='As found [@likert_1932]';e.focus();e.setSelectionRange(22,22);1")
  js(s, "document.getElementById('rq-h1').parentNode.querySelector('.sfcp-tb[data-tool=cite]').click();1")
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
  expect_true(js(s, "!!document.getElementById('rsInterp_0').parentNode.querySelector('.sfcp-bar')"))
})


# -- Format toolbar ------------------------------------------------------------

bar_of <- function(id) sprintf("document.getElementById('%s').parentNode.querySelector('.sfcp-bar')", id)

test_that("the toolbar shows on focus, hides on blur and stays while in use", {
  s <- ui2_builder(sframe_references_fixture())
  js(s, "openRQModal('rq1');document.getElementById('rq-alpha').focus();1")
  expect_true(js(s, paste0(bar_of("rq-q"), ".hidden")))
  js(s, "document.getElementById('rq-q').focus();1")
  expect_false(js(s, paste0(bar_of("rq-q"), ".hidden")))
  expect_identical(js(s, paste0(bar_of("rq-q"), ".getAttribute('role')")), "toolbar")
  expect_identical(js(s, paste0(bar_of("rq-q"), ".getAttribute('aria-label')")),
                   "Format Research question")
  # Focus moving into the toolbar keeps it, arrow keys move along it, and
  # Escape returns to the field.
  js(s, paste0(bar_of("rq-q"), ".querySelector('.sfcp-tb').focus();1"))
  Sys.sleep(0.1)
  expect_false(js(s, paste0(bar_of("rq-q"), ".hidden")))
  ui2_key(s, "", "ArrowRight")
  expect_identical(js(s, "document.activeElement.getAttribute('data-tool')"), "italic")
  ui2_key(s, "", "End")
  expect_identical(js(s, "document.activeElement.getAttribute('data-tool')"), "math")
  ui2_key(s, "", "Escape")
  expect_identical(js(s, "document.activeElement.id"), "rq-q")
  expect_true(js(s, "document.getElementById('m-rq').classList.contains('open')"))
  # Cite keeps it while the picker is open.
  js(s, paste0(bar_of("rq-q"), ".querySelector('[data-tool=cite]').click();1"))
  expect_true(ui2_wait(s, "!document.querySelector('.sfcp').hidden"))
  Sys.sleep(0.1)
  expect_false(js(s, paste0(bar_of("rq-q"), ".hidden")))
  ui2_key(s, "#sfcp-q", "Escape")
  js(s, "document.getElementById('rq-alpha').focus();1")
  expect_true(ui2_wait(s, paste0(bar_of("rq-q"), ".hidden")))
})

test_that("bold wraps the selection and the saved plan holds the Markdown", {
  s <- ui2_builder(sframe_references_fixture())
  js(s, "openRQModal('rq1');var e=document.getElementById('rq-q');e.value='Does satisfaction differ by group?';e.focus();e.setSelectionRange(5,17);1")
  js(s, paste0(bar_of("rq-q"), ".querySelector('[data-tool=bold]').click();1"))
  expect_identical(js(s, "document.getElementById('rq-q').value"),
                   "Does **satisfaction** differ by group?")
  expect_identical(js(s, "document.activeElement.id"), "rq-q")
  # Ctrl+I in the field, on the word "group".
  js(s, "document.getElementById('rq-q').setSelectionRange(32,37);1")
  ui2_key(s, "#rq-q", "i", ctrl = TRUE)
  expect_identical(js(s, "document.getElementById('rq-q').value"),
                   "Does **satisfaction** differ by *group*?")
  pv <- js(s, "document.getElementById('rq-q').parentNode.querySelector('.sfcp-pv').innerHTML")
  expect_match(pv, "<strong>satisfaction</strong> differ by <em>group</em>?", fixed = TRUE)
  js(s, "saveRQ();1")
  expect_identical(js(s, "sframePayload().analysis_plan[0].research_question"),
                   "Does **satisfaction** differ by *group*?")
})

test_that("the equation button writes $...$ and the preview shows TeX as typed", {
  s <- ui2_builder(sframe_references_fixture())
  js(s, "openRQModal('rq1');var e=document.getElementById('rq-interp');e.value='Retain if r > 0.3';e.focus();e.setSelectionRange(10,17);1")
  js(s, paste0(bar_of("rq-interp"), ".querySelector('[data-tool=math]').click();1"))
  expect_identical(js(s, "document.getElementById('rq-interp').value"), "Retain if $r > 0.3$")
  expect_match(js(s, "document.getElementById('rq-interp').parentNode.querySelector('.sfcp-pv').innerHTML"),
               "<code>r &gt; 0.3</code>", fixed = TRUE)
})

# -- Study (D13) ----------------------------------------------------------------

test_that("the Study tab edits the study and Other asks for a description", {
  s <- ui2_builder(sframe_references_fixture())
  js(s, "openSettings('study');1")
  expect_true(js(s, "document.getElementById('sp-study').classList.contains('active')"))
  expect_true(js(s, "document.getElementById('s-other-f').hidden"))
  js(s, "var m=document.getElementById('s-method');m.value='other';m.dispatchEvent(new Event('change',{bubbles:true}));1")
  expect_false(js(s, "document.getElementById('s-other-f').hidden"))
  # The problem statement takes the toolbar and the picker.
  js(s, "document.getElementById('s-problem').focus();1")
  expect_false(js(s, "document.getElementById('s-problem').parentNode.querySelector('.sfcp-bar').hidden"))
  js(s, "document.querySelector('#sp-study .btn').click();1")
  expect_identical(js(s, "document.activeElement.getAttribute('aria-label')"), "Objective 1 id")
  js(s, "document.getElementById('s-problem').value='Why do delegates not return?';document.getElementById('s-other').value='Intercept at the exit';studyObjs[0].text='Describe the reasons.';saveSettings();1")
  st <- js(s, "sframePayload().study")
  expect_identical(st$problem, "Why do delegates not return?")
  expect_identical(st$objectives[[1]]$id, "O1")
  expect_identical(st$sampling, list(method = "other", method_other = "Intercept at the exit"))
})

# -- Centre pane -----------------------------------------------------------------

centre_instrument <- function() {
  sframe_instrument(
    "Centre", version = "1.0.0",
    components = list(
      sframe_item("q1", "How did you travel?", type = "single_choice", choice_set = "mode",
                  required = TRUE),
      sframe_item("sec", "About the venue", type = "section_break"),
      sframe_choice_set("mode", c("1", "2"), c("By train", "By car"))))
}
centre_doc <- "document.querySelector('#cvPvFrame iframe').contentDocument"
centre_item <- function(s, id) {
  ui2_wait(s, sprintf("%s&&%s.getElementById('item_%s')", centre_doc, centre_doc, id))
  js(s, sprintf("%s.getElementById('item_%s').outerHTML", centre_doc, id))
}

test_that("the centre draws the selected item as export_survey(preview = TRUE) does", {
  ins <- centre_instrument()
  s <- ui2_builder(ins)
  js(s, "selItem('q1');1")
  expect_true(js(s, "document.getElementById('cvPv').classList.contains('on')"))
  centre <- centre_item(s, "q1")
  expect_true(js(s, paste0(centre_doc, ".getElementById('app').hasAttribute('inert')")))
  # The same item on the exported preview page.
  path <- tempfile(fileext = ".html")
  suppressMessages(export_survey(ins, output_path = path, open = FALSE, preview = TRUE))
  p <- ui2_session("survey")
  ui2_navigate(p, paste0("file://", normalizePath(path)))
  expect_true(ui2_wait(p, "document.getElementById('item_q1')"))
  expect_identical(centre, js(p, "document.getElementById('item_q1').outerHTML"))
  # A section break shows as on its page.
  js(s, "selItem('sec');1")
  expect_match(centre_item(s, "sec"), "About the venue", fixed = TRUE)
})

test_that("an edit to a label and a choice appears in the centre", {
  s <- ui2_builder(centre_instrument())
  js(s, "selItem('q1');1")
  centre_item(s, "q1")
  js(s, "var e=document.getElementById('fi-lbl');e.value='How did you get here?';e.dispatchEvent(new Event('input',{bubbles:true}));updF('fi-lbl');1")
  js(s, "snap();S.choices[0].labels[1]='By coach';setDirty();1")
  expect_true(ui2_wait(s, sprintf("%s.body.textContent.indexOf('By coach')>=0", centre_doc)))
  txt <- js(s, paste0(centre_doc, ".body.textContent"))
  expect_match(txt, "How did you get here?", fixed = TRUE)
  expect_false(grepl("By car", txt, fixed = TRUE))
})

test_that("the centre has a desktop and a mobile width, and closes with the editor", {
  s <- ui2_builder(centre_instrument())
  js(s, "selItem('q1');1")
  centre_item(s, "q1")
  js(s, "document.getElementById('cvW-mobile').click();1")
  expect_identical(js(s, "document.getElementById('cvW-mobile').getAttribute('aria-pressed')"), "true")
  expect_identical(js(s, "Math.round(document.querySelector('#cvPvFrame iframe').getBoundingClientRect().width)"), 390L)
  js(s, "document.getElementById('cvW-desktop').click();1")
  expect_gt(js(s, "document.querySelector('#cvPvFrame iframe').getBoundingClientRect().width"), 390)
  js(s, "closeInsp();1")
  expect_false(js(s, "document.getElementById('cvPv').classList.contains('on')"))
})


# -- Welcome and thank-you pages ----------------------------------------------

test_that("the welcome page is the first list entry, edited on the right and shown in the centre", {
  ins <- centre_instrument()
  ins$render$welcome <- list(intro_text = "This study asks about your trip.")
  s <- ui2_builder(ins)
  expect_identical(js(s, "document.querySelector('#itemList .ic').getAttribute('data-id')"), "__welcome")
  expect_identical(js(s, "Array.prototype.slice.call(document.querySelectorAll('#itemList .ic')).pop().getAttribute('data-id')"), "__thankyou")
  js(s, "document.querySelector('#itemList .ic').click();1")
  expect_identical(js(s, "document.getElementById('inspTypeLbl').textContent"), "Welcome page")
  expect_true(js(s, "document.querySelector('.insp-foot').hidden"))
  expect_true(ui2_wait(s, sprintf("%s&&%s.body.textContent.indexOf('about your trip')>=0", centre_doc, centre_doc)))
  js(s, "var e=document.getElementById('s-wi');e.focus();e.value='This study asks about your journey.';e.dispatchEvent(new Event('blur'));1")
  expect_true(ui2_wait(s, sprintf("%s.body.textContent.indexOf('about your journey')>=0", centre_doc)))
  expect_identical(js(s, "sframePayload().render.welcome.intro_text"), "This study asks about your journey.")
})

test_that("the thank-you page is the last entry, with its own editor", {
  s <- ui2_builder(centre_instrument())
  js(s, "selItem('__thankyou');1")
  expect_identical(js(s, "document.getElementById('inspTypeLbl').textContent"), "Thank-you page")
  expect_identical(js(s, "document.getElementById('s-tym').value"), "Thank you for participating.")
  js(s, "var e=document.getElementById('s-tydl');e.click();1")
  expect_true(js(s, "sframePayload().render.thankyou.show_download"))
})

test_that("Survey settings keeps General and Header, and the standalone builder keeps Google Sheets and References", {
  s <- ui2_builder(centre_instrument())
  js(s, "openSettings('meta');1")
  tabs <- js(s, "Array.prototype.map.call(document.querySelectorAll('#m-settings .stab'),function(t){return t.textContent;})")
  expect_identical(unlist(tabs), c("General", "Study", "Header", "Google Sheets", "References"))
  js(s, "showST('gsheets');1")
  expect_true(js(s, "document.querySelector('#sp-gsheets .studio-only').hidden"))
  expect_false(js(s, "document.querySelector('#sp-gsheets .studio-not').hidden"))
})

test_that("inside Studio, Google Sheets and References link to Studio's screens", {
  h <- ui2_studio_host()
  on.exit(httpuv::stopServer(h$server), add = TRUE)
  s <- h$session
  b <- "document.getElementById('b').contentWindow"
  js(s, paste0(b, ".openSettings('gsheets');1"))
  expect_false(js(s, paste0(b, ".document.querySelector('#sp-gsheets .studio-only').hidden")))
  expect_true(js(s, paste0(b, ".document.querySelector('#sp-gsheets .studio-not').hidden")))
  js(s, paste0(b, ".document.querySelector('#sp-gsheets .studio-only button').click();1"))
  expect_true(ui2_wait(s, "window.__msgs.some(function(m){return m&&m.type==='goto'&&m.screen==='collect';})"))
  expect_false(js(s, paste0(b, ".document.getElementById('m-settings').classList.contains('open')")))
  js(s, paste0(b, ".openSettings('refs');", b, ".document.querySelector('#sp-refs .studio-only button').click();1"))
  expect_true(ui2_wait(s, "window.__msgs.some(function(m){return m&&m.type==='goto'&&m.screen==='references';})"))
})


# -- allow_other and randomise on the exported page --------------------------------

test_that("the exported page draws Other last and shuffles a randomised set once", {
  ins <- sframe_instrument(
    "Other", version = "1.0.0",
    components = list(
      sframe_item("one", "How did you hear of us?", type = "single_choice", choice_set = "src"),
      sframe_choice_set("src", c("a", "b", "c", "d", "e", "f"),
                        c("Web", "Friend", "Poster", "Radio", "Paper", "Email"),
                        allow_other = TRUE, randomise = TRUE)))
  path <- tempfile(fileext = ".html")
  suppressMessages(export_survey(ins, output_path = path, open = FALSE, preview = TRUE))
  p <- ui2_session("survey")
  ui2_navigate(p, paste0("file://", normalizePath(path)))
  expect_true(ui2_wait(p, "document.getElementById('item_one')"))
  vals <- function() unlist(js(p, "Array.prototype.map.call(document.querySelectorAll('input[name=one]'),function(e){return e.value;})"))
  first <- vals()
  expect_identical(sort(first[-length(first)]), c("a", "b", "c", "d", "e", "f"))
  expect_identical(first[length(first)], "other")
  # Typing in the box chooses Other, and a redraw keeps the order.
  js(p, "var t=document.getElementById('other_one');t.value='A podcast';t.dispatchEvent(new Event('input',{bubbles:true}));1")
  expect_true(js(p, "document.querySelector('input[name=one][value=other]').checked"))
  js(p, "renderSurvey();1")
  expect_identical(vals(), first)
  expect_identical(js(p, "document.getElementById('other_one').value"), "A podcast")
})


# -- Dialogs (UX-14) ----------------------------------------------------------------

tab_key <- function(s, shift = FALSE) {
  js(s, sprintf("document.activeElement.dispatchEvent(new KeyboardEvent('keydown',{key:'Tab',shiftKey:%s,bubbles:true,cancelable:true}));1",
                if (shift) "true" else "false"))
}

test_that("Tab stays inside an open dialog, and Escape closes it back to its opener", {
  s <- ui2_builder(centre_instrument())
  js(s, "var b=document.getElementById('cfgMoreBtn');b.focus();openChoiceModal();1")
  inside <- "document.getElementById('m-choice').contains(document.activeElement)"
  expect_true(js(s, inside))
  # The last control, then Tab, is the first. Shift+Tab from the first is the last.
  js(s, "var f=document.querySelectorAll('#m-choice .mfoot button');f[f.length-1].focus();1")
  tab_key(s)
  expect_true(js(s, inside))
  expect_identical(js(s, "document.activeElement.className"), "mx")
  tab_key(s, shift = TRUE)
  expect_true(js(s, inside))
  expect_match(js(s, "document.activeElement.textContent"), "Save choice set", fixed = TRUE)
  ui2_key(s, "", "Escape")
  expect_false(js(s, "document.getElementById('m-choice').classList.contains('open')"))
  expect_identical(js(s, "document.activeElement.id"), "cfgMoreBtn")
})

test_that("Escape on a dialog opened over another closes the top one alone", {
  s <- ui2_builder(sframe_references_fixture())
  js(s, "openRQModal('rq1');document.getElementById('rq-manage-refs').focus();manageRefs();1")
  ui2_key(s, "", "Escape")
  expect_false(js(s, "document.getElementById('m-settings').classList.contains('open')"))
  expect_true(js(s, "document.getElementById('m-rq').classList.contains('open')"))
  expect_identical(js(s, "document.activeElement.id"), "rq-manage-refs")
  ui2_key(s, "", "Escape")
  expect_false(js(s, "document.getElementById('m-rq').classList.contains('open')"))
})


test_that("the arrow keys move along the Settings tabs and select each", {
  s <- ui2_builder(centre_instrument())
  js(s, "openSettings('meta');document.getElementById('st-meta').focus();1")
  ui2_key(s, "", "ArrowRight")
  expect_identical(js(s, "document.activeElement.id"), "st-study")
  expect_identical(js(s, "document.getElementById('st-study').getAttribute('aria-selected')"), "true")
  expect_identical(js(s, "document.getElementById('st-meta').getAttribute('tabindex')"), "-1")
  expect_true(js(s, "document.getElementById('sp-study').classList.contains('active')"))
  ui2_key(s, "", "End")
  expect_identical(js(s, "document.activeElement.id"), "st-refs")
  ui2_key(s, "", "ArrowRight")
  expect_identical(js(s, "document.activeElement.id"), "st-meta")
  ui2_key(s, "", "ArrowLeft")
  expect_identical(js(s, "document.activeElement.id"), "st-refs")
})


# -- Narrow screens (UX-01, UX-08) ---------------------------------------------------

narrow_overflow <- "(function(){var w=innerWidth,n=0;document.querySelectorAll('body *').forEach(function(e){var r=e.getBoundingClientRect();if(r.width>0&&r.right>w+1&&getComputedStyle(e).visibility!=='hidden')n++;});return [document.documentElement.scrollWidth<=w,n];})()"

test_that("at 390 x 844 Design shows 1 pane at a time, and no page is wider than the viewport", {
  s <- ui2_builder(centre_instrument(), width = 390, height = 844)
  shown <- function(sel) js(s, sprintf("getComputedStyle(document.querySelector('%s')).display!=='none'", sel))
  wide <- function() unlist(js(s, narrow_overflow))
  expect_true(shown(".sidebar"))
  expect_false(shown(".main"))
  expect_identical(wide(), c(1L, 0L))
  js(s, "selItem('q1');1")
  expect_false(shown(".sidebar"))
  expect_true(shown(".inspector"))
  expect_true(shown(".insp-back"))
  expect_true(ui2_wait(s, "document.getElementById('cvPv').classList.contains('on')"))
  expect_identical(wide(), c(1L, 0L))
  js(s, "document.querySelector('.insp-back').click();1")
  expect_true(shown(".sidebar"))
  expect_identical(js(s, "document.activeElement.getAttribute('data-id')"), "q1")
  for (mode in c("preview", "analyse")) {
    js(s, sprintf("setMode('%s');1", mode))
    expect_false(shown(".sidebar"))
    expect_identical(wide(), c(1L, 0L), info = mode)
  }
  js(s, "setMode('build');openSettings('meta');1")
  expect_identical(wide(), c(1L, 0L))
  # The wide layout comes back at a desktop width.
  ui2_session("builder", width = 1280, height = 900)
  expect_true(shown(".main"))
})

test_that("inside Studio at 390 wide the builder shows 1 pane at a time", {
  h <- ui2_studio_host()
  on.exit(httpuv::stopServer(h$server), add = TRUE)
  s <- h$session
  js(s, "var f=document.getElementById('b');f.style.width='390px';f.style.height='844px';1")
  b <- "document.getElementById('b').contentWindow"
  Sys.sleep(0.3)
  expect_identical(js(s, paste0(b, ".innerWidth")), 390L)
  expect_true(js(s, paste0(b, ".getComputedStyle(", b, ".document.querySelector('.main')).display==='none'")))
  expect_true(js(s, paste0(b, ".document.documentElement.scrollWidth<=390")))
})


# -- Reference targets (8b-R) -------------------------------------------------------

test_that("References offers the study and a block's hypotheses as cited-by targets", {
  ins <- sframe_references_fixture()
  ins$study <- list(problem = "Why do delegates not return?")
  ins$analysis_plan[[1]]$hypotheses <- list(alternative = "Satisfaction differs by group.")
  s <- ui2_builder(ins)
  js(s, "openSettings('refs');1")
  opts <- unlist(js(s, "Array.prototype.map.call(document.querySelectorAll('#r-cite option'),function(o){return o.value;})"))
  expect_true(all(c("study", "hypothesis:rq1") %in% opts))
  # Cleared from the plan, the hypothesis is no longer offered.
  js(s, "closeModal('m-settings');S.analysis_plan[0].hypotheses=null;openSettings('refs');1")
  opts <- unlist(js(s, "Array.prototype.map.call(document.querySelectorAll('#r-cite option'),function(o){return o.value;})"))
  expect_false("hypothesis:rq1" %in% opts)
  expect_true("study" %in% opts)
})


ui2_close()
