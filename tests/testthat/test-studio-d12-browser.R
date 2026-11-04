# tests/testthat/test-studio-d12-browser.R
#
# The D12 Analysis Plan editor in a real Chrome. Test 1 types H0, leaves H1
# empty, types a decision rule, adds an independent t test block and saves
# the .sframe the way Studio does (the Download button), then reads the file
# back. Test 2 opens a file carrying the old fixed hypothesis sentences and
# saves it untouched, which must leave the content hash alone and raise no
# prompt to save it as a new instrument.

d12_instrument <- function(plan = NULL) {
  ins <- sframe_instrument(title = "D12 browser", components = list(
    sframe_choice_set("grp", values = c("a", "b"), labels = c("Group A", "Group B")),
    sframe_item("grp", "Which group are you in?", "single_choice", choice_set = "grp"),
    sframe_item("score", "Your score", "numeric")))
  if (!is.null(plan)) ins$analysis_plan <- plan
  ins
}

# Starts Studio on the Analysis Plan screen with `ins`, runs `code(js, wait,
# download)` against a live Chrome session and cleans up afterwards.
d12_with_studio <- function(ins, code) {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("shiny")
  skip_if_not_installed("chromote")
  skip_if_not_installed("callr")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")

  # The child loads the build under test with library(), as a user would.
  libpath <- sframe_build_libpath()
  port <- httpuv::randomPort()
  proc <- callr::r_bg(function(port, ins) {
    library(surveyframe)
    launch_studio(ins, screen = "analysis", port = port, launch.browser = FALSE)
  }, args = list(port, ins), libpath = libpath)
  on.exit(proc$kill(), add = TRUE)
  url <- paste0("http://127.0.0.1:", port)
  for (i in 1:180) {
    up <- tryCatch({ suppressWarnings(readLines(url, n = 1)); TRUE }, error = function(e) FALSE)
    if (up) break
    Sys.sleep(0.5)
  }
  skip_if(!up, "Studio did not start")
  b <- sframe_chrome_session(width = 1280, height = 900)
  on.exit(b$close(), add = TRUE)
  b$Page$navigate(url)
  js <- function(code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
  wait <- function(cond) {
    for (i in 1:300) {
      if (isTRUE(tryCatch(js(cond), error = function(e) FALSE))) return(TRUE)
      Sys.sleep(0.5)
    }
    FALSE
  }
  # The Download button's own link, fetched as the browser would.
  download <- function(path) {
    href <- js("document.getElementById('download_sframe_btn').getAttribute('href')")
    utils::download.file(paste0(url, "/", href), path, mode = "wb", quiet = TRUE)
    invisible(path)
  }
  code(js, wait, download)
}

# Types into a Shiny text area the way a person does.
d12_type <- function(js, id, text) {
  js(sprintf(
    "var e = document.getElementById('%s'); e.value = %s; e.dispatchEvent(new Event('input', {bubbles: true})); true",
    id, jsonlite::toJSON(text, auto_unbox = TRUE)))
}

# Opens the Export screen, as a researcher does before downloading. Since
# 746120a a hidden screen is not drawn, so the Download button has no link
# until its screen shows. These tests read the link from the hidden screen
# before then, which worked only while every screen was kept drawn.
d12_open_export <- function(js) {
  # Studio switches to its launch screen after its first flush, so a click
  # made before then is undone. Click until Export is open and stays open.
  open <- "document.getElementById('screen-export').classList.contains('active')"
  for (i in 1:20) {
    js("var a = document.querySelector('[data-tab=\"export\"]'); if (a) a.click(); true")
    Sys.sleep(1)
    if (isTRUE(js(open))) {
      Sys.sleep(1)
      if (isTRUE(js(open))) break
    }
  }
  testthat::expect_true(js(open))
}

# UI-1 (UX-02): Studio's Analyse no longer edits the plan, so the test that
# typed H0, H1 and the decision rule there went. The builder's Plan is the
# only plan editor, and test-builder-d12-browser.R checks those fields reach
# the saved block.

test_that("a file with the old fixed hypotheses saves untouched with the same hash", {
  old <- list(list(
    id = "RQ1", research_question = "Do groups differ?", family = "group_comparison",
    method = "t_test_ind", test = "t_test_ind",
    roles = list(group = "grp", outcome = "score"), variables = c("grp", "score"),
    options = list(alpha = 0.05),
    hypotheses = list(null = "No effect or association is present.",
                      alternative = "An effect or association is present."),
    decision_rule = "Reject H0 if p < .05.", interpretation = "",
    status = "valid_plan", requires_data = TRUE))
  original <- tempfile(fileext = ".sframe")
  write_sframe(d12_instrument(old), original)
  before <- attr(read_sframe(original), "sframe_origin")$content_hash
  expect_true(is.character(before) && nzchar(before))

  d12_with_studio(read_sframe(original), function(js, wait, download) {
    d12_open_export(js)
    expect_true(wait("!!document.getElementById('download_sframe_btn') && !!document.getElementById('download_sframe_btn').getAttribute('href')"))
    # No prompt to save it as a new instrument.
    expect_false(js("document.body.innerText.indexOf('Save as a new instrument') >= 0"))
    expect_false(js("!!document.getElementById('export_as_new')"))
    saved <- download(tempfile(fileext = ".sframe"))
    after <- attr(read_sframe(saved), "sframe_origin")$content_hash
    expect_identical(after, before)
    block <- read_sframe(saved)$analysis_plan[[1]]
    expect_identical(block$hypotheses$null, "No effect or association is present.")
    expect_identical(block$hypotheses$alternative, "An effect or association is present.")
  })
})
