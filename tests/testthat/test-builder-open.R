# tests/testthat/test-builder-open.R
#
# Opening a file in SurveyBuilder, run under V8 (helper-v8-builder.R).
#
# Ethos request 21 (2026-10-03), found building a study inside Ethos. Opening
# a .sframe replaced unsaved changes without asking. The inspector kept
# showing an item the opened file did not have. And the status then read
# "Saved just now", although nothing had been saved anywhere, which inside a
# host reads as saved in the host.

test_that("21: Open asks before discarding unsaved changes", {
  ctx <- builder_context()
  ctx$call("setDirty")
  ctx$call("openFile")
  expect_length(ctx$get("__clicks"), 0L)
  expect_true(ctx$get(V8::JS("document.getElementById('confOv').classList.contains('open')")))
  expect_match(ctx$eval("document.getElementById('confM').textContent"),
               "unsaved changes will be lost", fixed = TRUE)
  # Cancelling keeps the work, confirming opens the file chooser.
  ctx$eval("resConf(false)")
  expect_length(ctx$get("__clicks"), 0L)
  ctx$call("openFile")
  ctx$eval("resConf(true)")
  expect_identical(ctx$get("__clicks"), "fileInput")
})

test_that("21: Open goes straight to the file chooser when nothing is unsaved", {
  ctx <- builder_context()
  ctx$eval("dirty = false;")
  ctx$call("openFile")
  expect_identical(ctx$get("__clicks"), "fileInput")
})

test_that("21: opening a file clears the inspector and says Opened", {
  ctx <- builder_context()
  builder_open(ctx, sframe_demo("two_group")$instrument)
  ctx$eval("selId = S.items[0].id; document.getElementById('inspector').classList.add('open');")
  builder_open(ctx, sframe_demo("first_survey")$instrument)
  expect_null(ctx$get("selId"))
  expect_false(ctx$get(V8::JS("document.getElementById('inspector').classList.contains('open')")))
  status <- ctx$eval("document.getElementById('saveSt').textContent")
  expect_match(status, "^Opened")
  expect_no_match(status, "Saved")
})

test_that("21: after a save the status says Saved again", {
  ctx <- builder_context()
  builder_open(ctx, sframe_demo("first_survey")$instrument)
  ctx$eval("lastSaved = Date.now(); updSave();")
  expect_match(ctx$eval("document.getElementById('saveSt').textContent"), "^Saved")
})
