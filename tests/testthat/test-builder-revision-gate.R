# tests/testthat/test-builder-revision-gate.R
#
# Codex CX-12, decision D2 (0.4.3, interim). openSframeText() checked the
# file's hash on open and forgot it, and saveSframe() hashed whatever the
# builder held, so an edited instrument saved as verified with no amendment.
# The builder now keeps the content it opened. Saving changed content of a
# file that had a hash asks for a new instrument, a new version with no
# amendment log, or cancels.

gate_context <- function(answer = "false") {
  ctx <- builder_context()
  ctx$eval(sprintf("var __dialogs = [];
    conf2 = function(t, m, ok, val){ __dialogs.push({ title:t, value:val });
      return Promise.resolve(%s); };", answer))
  ctx
}
gate <- function(ctx) {
  ctx$eval("(async function(){ return String(await sframeRevisionGate()); })()",
           await = TRUE) == "true"
}
gate_instrument <- function() {
  sf_instrument("Gate", version = "1.2.0", components = list(
    sf_item("q1", "How was it?", type = "text")))
}

test_that("CX-12: an opened file saved unchanged needs no dialog", {
  ctx <- gate_context()
  builder_open(ctx, gate_instrument())
  expect_true(gate(ctx))
  expect_length(ctx$get("__dialogs"), 0L)
})

test_that("CX-12: changed content of an opened file asks, and Cancel saves nothing", {
  ctx <- gate_context("false")
  builder_open(ctx, gate_instrument())
  ctx$eval("S.items[0].label = 'Undisclosed builder label';")
  expect_false(gate(ctx))
  dialogs <- ctx$get("__dialogs")
  expect_equal(nrow(dialogs), 1L)
  # The dialog offers the next version.
  expect_identical(dialogs$value, "1.2.1")
  expect_identical(ctx$get("S.meta.version"), "1.2.0")
})

test_that("CX-12: Save as a new instrument takes the new version and drops the log", {
  ctx <- gate_context("'1.3.0'")
  builder_open(ctx, gate_instrument())
  ctx$eval("S.items[0].label = 'Changed'; S._carry.amendments = [{ new_hash:'x' }];")
  expect_true(gate(ctx))
  expect_identical(ctx$get("S.meta.version"), "1.3.0")
  saved <- jsonlite::fromJSON(builder_save(ctx), simplifyVector = FALSE)
  expect_identical(saved$version, "1.3.0")
  expect_null(saved$amendments)
})

test_that("CX-12: a new instrument needs a changed title or version", {
  ctx <- gate_context("'1.2.0'")
  builder_open(ctx, gate_instrument())
  ctx$eval("S.items[0].label = 'Changed';")
  expect_false(gate(ctx))
  ctx2 <- gate_context("'1.2.0'")
  builder_open(ctx2, gate_instrument())
  ctx2$eval("S.items[0].label = 'Changed'; S.meta.title = 'Gate, revised';")
  expect_true(gate(ctx2))
})

test_that("CX-12: after a save, the saved file is the new origin", {
  ctx <- gate_context("'1.3.0'")
  builder_open(ctx, gate_instrument())
  ctx$eval("S.items[0].label = 'Changed';
    var Blob = function(){}; var URL = { createObjectURL:function(){ return ''; } };")
  ctx$eval("(async function(){ await saveSframe(); })()", await = TRUE)
  ctx$eval("__dialogs = [];")
  expect_true(gate(ctx))
  expect_length(ctx$get("__dialogs"), 0L)
})

test_that("CX-12: a survey built from scratch saves without a dialog", {
  ctx <- gate_context()
  ctx$eval("S.items.push({ id:'q1', type:'text', label:'New' });")
  expect_true(gate(ctx))
  expect_length(ctx$get("__dialogs"), 0L)
})
