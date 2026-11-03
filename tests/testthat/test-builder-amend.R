# tests/testthat/test-builder-amend.R
#
# Session 8a, CX-12 (replaces D2's interim save). SurveyBuilder saved changed
# content of an opened file only as a new instrument. It now offers a third
# way, "Record an amendment": the entry is built as amend_sframe() builds it,
# with the same content fingerprints, changed fields, tier rule and version
# suggestion, so the saved file reads back in R with its log verified and
# writes again without new_instrument = TRUE. The builder runs under V8
# (helper-v8-builder.R).

# A builder whose amendment dialog answers with `answer`, a JavaScript
# expression for the object amendDialog() resolves with.
amend_context <- function(answer = "null") {
  ctx <- builder_context()
  ctx$eval(sprintf("var __amendCalls = [];
    amendDialog = function(info){ __amendCalls.push(info);
      return Promise.resolve(%s); };", answer))
  ctx
}
amend_gate <- function(ctx) {
  ctx$eval("(async function(){ return String(await sframeRevisionGate()); })()",
           await = TRUE) == "true"
}
# The file the builder writes after the gate has run.
amend_save <- function(ctx) {
  expect_true(amend_gate(ctx))
  builder_save(ctx)
}
read_quiet <- function(path) {
  withCallingHandlers(read_sframe(path),
                      sframe_amendment_warning = function(w) stop(conditionMessage(w)))
}
opened_from_file <- function(instrument) {
  path <- tempfile(fileext = ".sframe")
  write_sframe(instrument, path)
  read_sframe(path)
}

test_that("CX-12: a recorded amendment reads back verified and matches amend_sframe()", {
  ins <- sframe_demo("likert_scale")$instrument
  ctx <- amend_context("{ mode:'amend', reason_code:'other', reason_text:'Clarified the wording.',
                          tier:'pipeline', version:'1.0.1' }")
  builder_open(ctx, ins)
  ctx$eval("S.items[0].label = 'A clearer label';")
  back <- read_quiet(amend_save(ctx))
  log <- sframe_get_amendments(back)
  expect_equal(nrow(log), 1L)
  expect_identical(log$new_hash, sframe_content_hash(back))
  expect_identical(log$previous_hash, sframe_content_hash(opened_from_file(ins)))
  expect_identical(log$tier, "pipeline")
  expect_identical(back$meta$version, "1.0.1")

  # The same change made in R records the same fields.
  before <- opened_from_file(ins)
  after <- before
  after$items[[1]]$label <- "A clearer label"
  r <- suppressMessages(amend_sframe(before, after, "other", "Clarified the wording.",
                                     tier = "pipeline", version = "1.0.1"))
  expect_identical(log$changed_fields, sframe_get_amendments(r)$changed_fields)
  expect_identical(log$new_hash, sframe_get_amendments(r)$new_hash)

  # The file writes again with no flag, and takes a further amendment.
  out <- tempfile(fileext = ".sframe")
  expect_no_error(write_sframe(back, out))
  again <- back
  again$items[[1]]$label <- "Clearer still"
  expect_no_error(suppressMessages(
    amend_sframe(back, again, "other", "Second pass.", tier = "pipeline")))
})

test_that("CX-12: the dialog is told what changed, the tier and the suggested version", {
  ctx <- amend_context("null")
  builder_open(ctx, sframe_demo("likert_scale")$instrument)
  ctx$eval("S.items[0].label = 'Changed';")
  expect_false(amend_gate(ctx))
  info <- ctx$get("__amendCalls")
  expect_equal(nrow(info), 1L)
  expect_identical(unlist(info$changed_fields), "items")
  expect_false(info$design_forced)
  expect_identical(info$suggest_design$version, "1.1.0")
  expect_identical(info$suggest_pipeline$version, "1.0.1")
  expect_identical(info$new_version, "1.0.1")
  expect_true(info$can_amend)
})

test_that("CX-12: Cancel saves nothing and changes nothing", {
  ctx <- amend_context("null")
  builder_open(ctx, sframe_demo("likert_scale")$instrument)
  ctx$eval("S.items[0].label = 'Changed';")
  expect_false(amend_gate(ctx))
  expect_identical(ctx$get("S.meta.version"), "1.0.0")
  expect_null(ctx$get("S._carry.amendments"))
})

test_that("CX-12: a scale or plan change is design tier and needs a deviation report", {
  ins <- sframe_demo("likert_scale")$instrument
  ctx <- amend_context("{ mode:'amend', reason_code:'data_correction',
                          reason_text:'Dropped an item.', tier:'pipeline' }")
  builder_open(ctx, ins)
  ctx$eval("S.scales[0].items = S.scales[0].items.slice(1);")
  expect_false(amend_gate(ctx))
  expect_true(ctx$get("__amendCalls")$design_forced)
  expect_match(builder_toasts(ctx)$msg[nrow(builder_toasts(ctx))], "deviation report")

  ctx2 <- amend_context("{ mode:'amend', reason_code:'data_correction',
                           reason_text:'Dropped an item.', tier:'pipeline',
                           deviation_report:'The item loaded below .40.' }")
  builder_open(ctx2, ins)
  ctx2$eval("S.scales[0].items = S.scales[0].items.slice(1);")
  back <- read_quiet(amend_save(ctx2))
  log <- sframe_get_amendments(back)
  expect_identical(log$tier, "design")
  expect_identical(log$deviation_report, "The item loaded below .40.")
  expect_identical(log$new_hash, sframe_content_hash(back))
})

test_that("CX-12: a second amendment follows the first", {
  ins <- sframe_demo("likert_scale")$instrument
  ctx <- amend_context("{ mode:'amend', reason_code:'other', reason_text:'One.', tier:'pipeline' }")
  builder_open(ctx, ins)
  ctx$eval("S.items[0].label = 'First'; var Blob = function(){};
    var URL = { createObjectURL:function(){ return ''; } };")
  ctx$eval("(async function(){ await saveSframe(); })()", await = TRUE)
  ctx$eval("S.items[0].label = 'Second';")
  back <- read_quiet(amend_save(ctx))
  log <- sframe_get_amendments(back)
  expect_equal(nrow(log), 2L)
  expect_identical(log$previous_hash[2], log$new_hash[1])
  expect_identical(log$new_hash[2], sframe_content_hash(back))
  expect_no_error(write_sframe(back, tempfile(fileext = ".sframe")))
})

test_that("CX-12: a file whose hash does not match offers only a new instrument", {
  path <- tempfile(fileext = ".sframe")
  write_sframe(sframe_demo("likert_scale")$instrument, path)
  j <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  j$items[[1]]$label <- "Edited on disk"
  ctx <- amend_context("null")
  ctx$call("openSframeText", jsonlite::toJSON(j, auto_unbox = TRUE, null = "null"))
  ctx$eval("S.items[0].label = 'Changed';")
  expect_false(amend_gate(ctx))
  expect_false(ctx$get("__amendCalls")$can_amend)
})

test_that("CX-12: the builder's version suggestion is R's", {
  ctx <- builder_context()
  for (v in c("1.0.0", "2.3.4", "1.2", "3", "", "draft")) {
    for (tier in c("design", "pipeline")) {
      js <- ctx$call("sframeSuggestVersion", v, tier)
      r <- sframe_suggest_version(v, tier)
      expect_identical(js$version, r$version, info = paste(v, tier))
      expect_identical(js$reason, r$reason, info = paste(v, tier))
    }
  }
})

test_that("CX-12: the builder's content fingerprint is R's on a larger demo", {
  ins <- sframe_demo("tourism_services")$instrument
  ctx <- amend_context("{ mode:'amend', reason_code:'model_respecification',
                          reason_text:'Plan block dropped.', deviation_report:'RQ dropped.' }")
  builder_open(ctx, ins)
  ctx$eval("S.analysis_plan = S.analysis_plan.slice(1);")
  back <- read_quiet(amend_save(ctx))
  log <- sframe_get_amendments(back)
  expect_identical(log$previous_hash, sframe_content_hash(opened_from_file(ins)))
  expect_identical(log$new_hash, sframe_content_hash(back))
  expect_identical(log$tier, "design")
})

test_that("CX-12: read_sframe() warns on a log that does not end at the content", {
  ins <- opened_from_file(sframe_demo("likert_scale")$instrument)
  after <- ins
  after$items[[1]]$label <- "Changed"
  am <- suppressMessages(amend_sframe(ins, after, "other", "Wording.", tier = "pipeline"))
  path <- tempfile(fileext = ".sframe")
  write_sframe(am, path)
  j <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  j$amendments[[1]]$new_hash <- strrep("0", 64)
  j$hash$value <- ""
  j$hash$value <- sframe_hash_payload(j)
  writeLines(jsonlite::toJSON(j, auto_unbox = TRUE, pretty = TRUE, null = "null"), path)
  expect_warning(read_sframe(path), "does not end at", class = "sframe_amendment_warning")
  # A log that ends at its content reads with no warning.
  ok <- tempfile(fileext = ".sframe")
  write_sframe(am, ok)
  expect_no_warning(read_sframe(ok))
})
