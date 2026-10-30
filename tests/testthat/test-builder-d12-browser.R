# tests/testthat/test-builder-d12-browser.R
#
# D12 in a real Chrome: the Plan editor's H0, H1 and decision rule fields
# save exactly what was typed, nothing from the placeholders, and an
# untouched plan block carrying the old fixed sentences saves with its
# content hash unchanged and without the "save as a new instrument" dialog.
#
# Skipped on CRAN and wherever chromote or Chrome is unavailable.

skip_on_cran()
skip_if_not_slow()
skip_if_not_installed("chromote")
chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome),
        "Chrome not available")

d12_builder_path <- function() {
  system.file("builder", "survey_builder.html", package = "surveyframe")
}

d12_js <- function(session, code, await = FALSE) {
  session$Runtime$evaluate(code, returnByValue = TRUE,
                           awaitPromise = await)$result$value
}

# Opens the shipped builder, then opens `path` in it as the Open button would.
d12_open <- function(path) {
  session <- chromote::ChromoteSession$new(width = 1280, height = 900)
  loaded <- session$Page$loadEventFired(wait_ = FALSE)
  session$Page$navigate(paste0("file://", normalizePath(d12_builder_path())),
                        wait_ = FALSE)
  session$wait_for(loaded)
  text <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"),
                collapse = "\n")
  d12_js(session, paste0("openSframeText(",
                         jsonlite::toJSON(text, auto_unbox = TRUE), ");1"))
  session
}

# Runs saveSframe() with the download captured, and returns the saved file as
# a path. Also reports whether the revision dialog opened.
d12_save <- function(session) {
  d12_js(session, paste0(
    "window.__blob=null;",
    "URL.createObjectURL=function(b){window.__blob=b;return 'blob:x';};",
    "HTMLAnchorElement.prototype.click=function(){};",
    "window.__dialog=false;",
    "var __ov=document.getElementById('confOv');",
    "new MutationObserver(function(){",
    "if(__ov.classList.contains('open'))window.__dialog=true;})",
    ".observe(__ov,{attributes:true});1"))
  d12_js(session, "saveSframe().then(function(){return 1;})", await = TRUE)
  json <- d12_js(session, "window.__blob ? window.__blob.text() : ''",
                 await = TRUE)
  path <- tempfile(fileext = ".sframe")
  writeLines(json, path, useBytes = TRUE)
  list(path = path,
       dialog = isTRUE(d12_js(session, "window.__dialog")))
}

d12_instrument <- function(plan = list()) {
  sf_instrument(
    "D12 browser", version = "1.0.0",
    components = list(
      sf_item("score", "Score", type = "numeric"),
      sf_item("group", "Group", type = "single_choice", choice_set = "yn"),
      sf_choices("yn", values = c("0", "1"), labels = c("No", "Yes"))),
    analysis_plan = plan)
}

# Opens the Plan editor on a t test and saves it with the fields given.
d12_plan_block <- function(h0 = NULL, h1 = NULL, rule = NULL) {
  src <- tempfile(fileext = ".sframe")
  write_sframe(d12_instrument(), src)
  session <- d12_open(src)
  on.exit(session$close(), add = TRUE)
  # The instrument is treated as one made in the builder, so the revision gate
  # for edits to an opened file does not ask about the plan block.
  d12_js(session, "S._origin=null;1")
  type <- function(id, value) {
    d12_js(session, paste0("document.getElementById('", id, "').value=",
                           jsonlite::toJSON(value, auto_unbox = TRUE), ";1"))
  }
  d12_js(session, paste0(
    "openRQModal();",
    "document.getElementById('rq-q').value='Do the groups differ?';",
    "document.getElementById('rq-test').value='t_test_ind';",
    "onTestChg(false);1"))
  shown <- d12_js(session,
                  "document.getElementById('rq-hyp-field').style.display")
  d12_js(session, paste0(
    "var r=document.getElementById('role_outcome');",
    "if(r)r.value='score';",
    "var g=document.getElementById('role_group');",
    "if(g)g.value='group';1"))
  if (!is.null(h0)) type("rq-h0", h0)
  if (!is.null(h1)) type("rq-h1", h1)
  if (!is.null(rule)) type("rq-interp", rule)
  d12_js(session, "saveRQ();1")
  saved <- d12_save(session)
  list(block = read_sframe(saved$path)$analysis_plan[[1]], shown = shown)
}

test_that("typed H0, H1 and decision rule are saved, and interpretation is empty", {
  res <- d12_plan_block(
    h0 = "Mean score does not differ by group.",
    h1 = "Mean score differs by group.",
    rule = "Reject H0 if p < .05.")
  expect_identical(res$shown, "block")
  block <- res$block
  expect_identical(block$method, "t_test_ind")
  expect_identical(block$hypotheses$null, "Mean score does not differ by group.")
  expect_identical(block$hypotheses$alternative, "Mean score differs by group.")
  expect_identical(block$decision_rule, "Reject H0 if p < .05.")
  expect_true(is.null(block$interpretation) || !nzchar(block$interpretation))
})

test_that("empty fields save no hypotheses and no placeholder text", {
  res <- d12_plan_block()
  block <- res$block
  expect_identical(block$method, "t_test_ind")
  expect_true(is.null(block$hypotheses$null) ||
                !nzchar(block$hypotheses$null))
  expect_true(is.null(block$hypotheses$alternative) ||
                !nzchar(block$hypotheses$alternative))
  expect_true(is.null(block$decision_rule) || !nzchar(block$decision_rule))
  expect_true(is.null(block$interpretation) || !nzchar(block$interpretation))
})

test_that("an untouched plan with the old fixed sentences keeps its hash", {
  plan <- list(list(
    id = "RQ1", research_question = "Do the groups differ?",
    family = "inferential", method = "t_test_ind", test = "t_test_ind",
    roles = list(outcome = "score", group = "group"),
    variables = c("score", "group"),
    hypotheses = list(
      null = "No effect or association is present.",
      alternative = "An effect or association is present.")))
  src <- tempfile(fileext = ".sframe")
  write_sframe(d12_instrument(plan), src)
  original <- attr(read_sframe(src), "sframe_origin")$content_hash

  expect_true(is.character(original) && nzchar(original))

  session <- d12_open(src)
  on.exit(session$close(), add = TRUE)
  saved <- d12_save(session)

  expect_false(saved$dialog)
  back <- read_sframe(saved$path)
  expect_identical(attr(back, "sframe_origin")$content_hash, original)
  expect_identical(back$analysis_plan[[1]]$hypotheses$null,
                   "No effect or association is present.")
})
