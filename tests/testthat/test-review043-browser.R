# tests/testthat/test-review043-browser.R
#
# The SurveyStudio and SurveyBuilder defects of the Ubuntu run of review_043
# at 8676a43 (CLAUDE_UBUNTU_REVIEW_8676a43.md), checked in a real Chrome
# against the build under test: N5's blank CSV, Quality's wording (N6), the
# Responses error that stays (N3), and the builder's targets, Tab stops,
# hidden field, ORD badge and suggestions (M1 to M5).

skip_if_not_slow()
skip_on_cran()
skip_if_not_installed("chromote")
skip_if_not_installed("callr")
skip_if_not_installed("httpuv")

test_that("N5: the blank CSV on Responses holds the open instrument's columns", {
  b <- ui1_studio("two_group", width = 1280, height = 900)
  expect_true(ui1_screen(b, "responses"))
  expect_true(ui2_wait(b, "!!document.getElementById('download_sample_csv') && document.getElementById('download_sample_csv').getAttribute('href').indexOf('download') >= 0", 20))
  expect_match(ui1_text(b, "download_sample_csv"), "blank CSV for this instrument")
  head <- ui2_js(b, "fetch(document.getElementById('download_sample_csv').href).then(function(r){ return r.text(); })",
                 await = TRUE)
  first <- strsplit(head, "\r?\n")[[1]][1]
  want <- sframe_response_template_columns(sframe_demo("two_group", preview = FALSE)$instrument)
  expect_identical(first, paste0('"', want, '"', collapse = ","))
  expect_false(grepl("information_channels", head, fixed = TRUE))
})

test_that("N6: Quality never prints NA%, words no duplicates, and leads with its chart", {
  b <- ui1_studio("two_group", width = 1280, height = 900)
  expect_true(ui1_screen(b, "quality"))
  expect_true(ui2_wait(b, "$('#screen-quality').text().indexOf('Duplicates and missingness') >= 0", 30))
  q <- ui2_js(b, "document.getElementById('screen-quality').innerText")
  expect_false(grepl("NA%", q, fixed = TRUE))
  expect_false(grepl("^0 duplicate", q))
  expect_match(q, "No duplicate response rows\\.|[1-9][0-9]* duplicate response rows? detected")
  # the chart comes before the tables in the screen's order
  expect_true(ui2_js(b, "(function(){ var c = document.getElementById('studio_quality_chart'), t = document.getElementById('quality_output'); return !!(c.compareDocumentPosition(t) & Node.DOCUMENT_POSITION_FOLLOWING); })()"))
})

test_that("N3: a response file with the wrong columns leaves its reason on Responses", {
  b <- ui1_studio("two_group", width = 1280, height = 900)
  expect_true(ui1_screen(b, "responses"))
  f <- tempfile(fileext = ".csv")
  on.exit(unlink(f))
  writeLines(c("x,y", "1,2"), f)
  doc <- b$DOM$getDocument()
  node <- b$DOM$querySelector(doc$root$nodeId, "#resp_file")
  b$DOM$setFileInputFiles(files = list(normalizePath(f)), nodeId = node$nodeId)
  expect_true(ui2_wait(b, "$('#resp_file_progress').text().indexOf('complete') >= 0 || $('#resp_file_progress .progress-bar').width() > 0", 20))
  Sys.sleep(1)
  ui2_js(b, "document.getElementById('load_responses_btn').click(); true")
  expect_true(ui2_wait(b, "!!document.getElementById('responses_error_card')", 20))
  Sys.sleep(8)  # past a notification's life
  expect_match(ui1_text(b, "responses_error_card"), "undeclared columns")
})

ui1_close()

# -- SurveyBuilder ----------------------------------------------------------

rb_instrument <- function() {
  sframe_instrument("Review 043 builder", components = list(
    sframe_choice_set("agree", 1:5, c("Strongly disagree", "Disagree", "Neutral",
                                       "Agree", "Strongly agree")),
    sframe_choice_set("grp3", 1:3, c("A", "B", "C")),
    sframe_choice_set("lvl", 1:3, c("Low", "Medium", "High"), ordered = TRUE),
    sframe_item("sat", "Satisfied", "likert", choice_set = "agree"),
    sframe_item("age", "Age", type = "numeric"),
    sframe_item("grp", "Group", "single_choice", choice_set = "grp3"),
    sframe_item("level", "Level", "single_choice", choice_set = "lvl"),
    sframe_item("why", "Why?", type = "text")))
}

test_that("M1: the builder's buttons are at least 44 px tall", {
  s <- ui2_builder(rb_instrument(), width = 1400, height = 900)
  expect_true(ui2_wait(s, "document.querySelectorAll('#itemList .ic').length > 2", 20))
  small <- ui2_js(s, "(function(){ var out = []; document.querySelectorAll('.topbar .btn, .m-btn, #undoBtn, #redoBtn, .sidebar .btn, #itemList .ib').forEach(function(e){ var r = e.getBoundingClientRect(); if (r.width > 0 && r.height < 43.5) out.push((e.id || e.className) + ':' + Math.round(r.height)); }); return out.join(', '); })()")
  expect_identical(small, "")
})

test_that("P1-11: a question row is 1 Tab stop, with arrows into its buttons", {
  s <- ui2_builder(rb_instrument(), width = 1280, height = 900)
  expect_true(ui2_wait(s, "document.querySelectorAll('#itemList .ic').length > 2", 20))
  expect_identical(ui2_js(s, "document.querySelectorAll('#itemList .ic .ib:not([tabindex=\"-1\"])').length"), 0L)
  id <- ui2_js(s, "document.querySelectorAll('#itemList .ic')[1].getAttribute('data-id')")
  row <- sprintf("#itemList .ic[data-id='%s']", id)
  ui2_js(s, sprintf("document.querySelector(\"%s\").focus(); 1", row))
  ui2_key(s, "", "ArrowRight")
  expect_identical(ui2_js(s, "document.activeElement.getAttribute('aria-label')"), "Move question up")
  ui2_key(s, "", "ArrowRight")
  expect_identical(ui2_js(s, "document.activeElement.getAttribute('aria-label')"), "Move question down")
  ui2_key(s, "", "Escape")
  expect_identical(ui2_js(s, "document.activeElement.getAttribute('data-id')"), id)
})

test_that("M2 and M3: the method description stays hidden, and an ordered single choice shows ORD", {
  s <- ui2_builder(rb_instrument(), width = 1400, height = 900)
  expect_true(ui2_wait(s, "document.querySelectorAll('#itemList .ic').length > 2", 20))
  expect_identical(ui2_js(s, "getComputedStyle(document.getElementById('s-other-f')).display"), "none")
  badges <- ui2_js(s, "document.querySelector('#itemList .ic[data-id=\"level\"]').innerText")
  expect_match(badges, "ORD", fixed = TRUE)
  expect_false(grepl("ORD", ui2_js(s, "document.querySelector('#itemList .ic[data-id=\"grp\"]').innerText"), fixed = TRUE))
  # the type menu shows whole at 900 px
  ui2_js(s, "toggleFabMenu(); true")
  expect_true(ui2_wait(s, "document.getElementById('fabMenu').classList.contains('open')", 5))
  expect_true(ui2_js(s, "(function(){ var m = document.getElementById('fabMenu'); return m.scrollHeight <= m.clientHeight + 1; })()"))
})

test_that("M5: the Plan dialog suggests a method from 2 variables of any kind", {
  s <- ui2_builder(rb_instrument(), width = 1400, height = 900)
  expect_true(ui2_wait(s, "document.querySelectorAll('#itemList .ic').length > 2", 20))
  ui2_js(s, "setMode('analyse'); openRQModal(); true")
  expect_true(ui2_wait(s, "!!document.getElementById('rq-sug-a') && document.getElementById('rq-sug-a').options.length > 2", 10))
  # the text-item nudge leaves the method where it was
  expect_identical(ui2_js(s, "document.getElementById('rq-test').value"), "mann_whitney")
  pick <- function(a, b) {
    ui2_js(s, sprintf("(function(){ var x = document.getElementById('rq-sug-a'), y = document.getElementById('rq-sug-b'); x.value = '%s'; y.value = '%s'; suggestFromPair(); return document.getElementById('rq-test').value; })()", a, b))
  }
  expect_identical(pick("sat", "age"), "correlation_spearman")
  expect_identical(pick("grp", "age"), "kruskal_wallis")
  expect_identical(pick("age", "why"), "term_freq")
  expect_identical(pick("age", "sat"), "correlation_spearman")
})

ui2_close()
