# tests/testthat/test-studio-ui1-browser.R
#
# Session UI-1's SurveyStudio screens in a real Chrome, against the build
# under test. The tests share 1 Studio per demo (helper-ui1-browser.R) and run
# in order, so a later test starts from the state an earlier one left, and
# each says what it expects to find.

skip_on_cran()
skip_if_not_slow()
skip_if_not_installed("shiny")
skip_if_not_installed("chromote")
skip_if_not_installed("callr")
skip_if_not_installed("psych")
chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")

test_that("Drop from scale and Put back go through the 1 amendment dialog", {
  b <- ui1_studio("factor_structure", "analysis")
  expect_true(ui1_screen(b, "analysis"))
  ui2_js(b, "if ($('input[name=analysis_stage]').length) Shiny.setInputValue('analysis_stage', 'Run'); true")
  drop_btn <- "$('#screen-analysis .flag-list[data-block=\"RQ2\"] button:contains(\"Drop from scale\")')"
  expect_true(ui2_wait(b, paste0(drop_btn, ".length === 1"), 90))
  expect_match(ui1_text(b, "screen-analysis"), "con_4: loading .39 in RQ2, below .40",
               fixed = TRUE)

  ui2_js(b, paste0(drop_btn, ".click(); true"))
  expect_true(ui2_wait(b, ui1_modal_open, 20))
  expect_match(ui1_text(b, "shiny-modal"), "Drop con_4 from content", fixed = TRUE)
  expect_match(ui2_js(b, "$('#amend_dlg-reason_text').val()"), "loading .39", fixed = TRUE)
  expect_match(ui1_text(b, "shiny-modal"), "Scales whose scoring changes: content", fixed = TRUE)
  ui2_js(b, "$('#amend_dlg-record').click(); true")
  expect_true(ui2_wait(b, paste0("!", ui1_modal_open), 20))

  # The rerun shows the drop with Put back, and the status counts it.
  put_btn <- "$('#screen-analysis .flag-list[data-block=\"RQ2\"] button:contains(\"Put back\")')"
  expect_true(ui2_wait(b, paste0(put_btn, ".length === 1"), 90))
  expect_true(ui2_wait(b, "document.getElementById('status_instrument').innerText.indexOf('1 amendment') >= 0", 20))

  ui2_js(b, paste0(put_btn, ".click(); true"))
  expect_true(ui2_wait(b, ui1_modal_open, 20))
  expect_match(ui1_text(b, "shiny-modal"), "Put con_4 back in content", fixed = TRUE)
  ui2_js(b, "$('#amend_dlg-record').click(); true")
  expect_true(ui2_wait(b, paste0("!", ui1_modal_open), 20))
  expect_true(ui2_wait(b, "document.getElementById('status_instrument').innerText.indexOf('2 amendments') >= 0", 20))

  # The Amendments screen holds the whole history, with the hashes.
  expect_true(ui1_screen(b, "amendments"))
  expect_true(ui2_wait(b, "(document.getElementById('amendment_log_table')||{innerText:''}).innerText.indexOf('Put con_4 back') >= 0", 20))
  log <- ui1_text(b, "amendment_log_table")
  expect_match(log, "Hash before", fixed = TRUE)
  expect_match(log, "Model respecification: con_4: loading", fixed = TRUE)
  expect_match(ui1_text(b, "amend_version_line"), "2 amendments", fixed = TRUE)
  expect_match(ui1_text(b, "amend_put_back_note"), "put the item back in Design", fixed = TRUE)
})

test_that("Quality records a bot removal as a pipeline amendment", {
  b <- ui1_studio("factor_structure")
  expect_true(ui1_screen(b, "quality"))
  expect_true(ui2_wait(b, "!!document.getElementById('quality_amend_btn')", 30))
  ui2_js(b, "$('#quality_amend_btn').click(); true")
  expect_true(ui2_wait(b, ui1_modal_open, 20))
  expect_true(ui2_wait(b, "$('#amend_dlg-tier').val() === 'pipeline'", 10))
  ui1_set(b, "amend_dlg-reason_text", "Removed 2 bot responses.")
  Sys.sleep(1)
  ui2_js(b, "$('#amend_dlg-record').click(); true")
  expect_true(ui2_wait(b, paste0("!", ui1_modal_open), 20))
  expect_true(ui2_wait(b, "document.getElementById('status_instrument').innerText.indexOf('3 amendments') >= 0", 20))
})

test_that("Analyse shows the declared plan, and a plan change after the data is a design amendment", {
  b <- ui1_studio("factor_structure")
  expect_true(ui1_screen(b, "analysis"))
  expect_true(ui2_wait(b, "!!document.querySelector('#declared_plan_card table')", 30))
  plan <- ui1_text(b, "declared_plan_card")
  expect_match(plan, "RQ2", fixed = TRUE)
  expect_match(plan, "Research question", fixed = TRUE)
  expect_false(ui2_js(b, "!!document.querySelector('input[name=analysis_stage]')"))
  expect_false(ui2_js(b, "!!document.getElementById('analysis_method')"))

  ui2_js(b, "$('#analysis_change_plan').click(); true")
  expect_true(ui2_wait(b, "$('#screen-plan').hasClass('active') || $('#screen-design').hasClass('active')", 20))
  frame <- "document.getElementById('design_frame').contentWindow"
  expect_true(ui2_wait(b, paste0(frame, ".S && ", frame, ".S.analysis_plan.length > 1"), 60))
  ui2_js(b, paste0("var w=", frame, "; w.S.analysis_plan[1].research_question = 'A narrower question.'; w.setDirty(); w.saveSframe(); true"))
  expect_true(ui2_wait(b, ui1_modal_open, 30))
  expect_match(ui1_text(b, "shiny-modal"), "The plan changed after the responses were loaded", fixed = TRUE)
  expect_match(ui2_js(b, "$('#amend_dlg-deviation_report').val()"),
               "Plan changed after the responses were loaded: RQ2 changed. Reason: ", fixed = TRUE)
  ui2_js(b, "$('#amend_dlg-cancel').click(); true")
  expect_true(ui2_wait(b, paste0("!", ui1_modal_open), 20))
})

ui1_close()
