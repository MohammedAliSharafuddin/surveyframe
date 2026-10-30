# tests/testthat/test-builder-teaching-defects.R
#
# SurveyBuilder defects found on 2026-10-19 while building a teaching deck on
# 0.4.2, driven in a real headless Chrome since they live in the page's
# JavaScript and layout.
#
# 4. A regression block saved with `outcome` (which R accepts beside
#    `dependent`) opened with the dependent variable set to the first item.
# 6. The sidebar title read "Untitled Survey" on first load when the state was
#    injected, as launch_builder_demo() does.
# 7. The role dropdowns in the analysis plan dialog ran past its right edge.
#
# Skipped on CRAN and wherever chromote or Chrome is unavailable.

skip_on_cran()
skip_if_not_slow()
skip_if_not_installed("chromote")
chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome),
        "Chrome not available")

open_demo_builder <- function() {
  info <- launch_builder_demo(open = FALSE)
  session <- chromote::ChromoteSession$new(width = 1280, height = 900)
  loaded <- session$Page$loadEventFired(wait_ = FALSE)
  session$Page$navigate(paste0("file://", normalizePath(info$builder_path)),
                        wait_ = FALSE)
  session$wait_for(loaded)
  session
}

js <- function(session, code) {
  session$Runtime$evaluate(code, returnByValue = TRUE)$result$value
}

test_that("6: the sidebar shows the injected title on first load", {
  session <- open_demo_builder()
  on.exit(session$close(), add = TRUE)
  title <- sframe_input_types_demo_data()$instrument$meta$title

  expect_identical(js(session, "document.getElementById('sbTitle').textContent"),
                   title)
})

test_that("4: a plan saved with `outcome` opens with that outcome selected", {
  session <- open_demo_builder()
  on.exit(session$close(), add = TRUE)

  dependent <- js(session, paste0(
    "S.analysis_plan.push({id:'RQX',research_question:'Q',",
    "method:'regression_linear',roles:{predictors:['value_slider'],",
    "outcome:'overall_rating'}});",
    "openRQModal('RQX');",
    "document.getElementById('role_dependent').value"))
  expect_identical(dependent, "overall_rating")

  outcome <- js(session, paste0(
    "if(typeof closeModal==='function')closeModal('m-rq');",
    "S.analysis_plan.push({id:'RQY',research_question:'Q',",
    "method:'t_test_ind',roles:{group:'visit_type',",
    "dependent:'overall_rating'}});",
    "openRQModal('RQY');",
    "document.getElementById('role_outcome').value"))
  expect_identical(outcome, "overall_rating")
})

test_that("1: the frequency role takes more than one variable", {
  session <- open_demo_builder()
  on.exit(session$close(), add = TRUE)

  picked <- js(session, paste0(
    "S.analysis_plan.push({id:'RQF',research_question:'Q',",
    "method:'frequency',roles:{variables:['visit_type','visit_purpose']}});",
    "openRQModal('RQF');",
    "var s=document.getElementById('role_variable');",
    "s.multiple+':'+Array.from(s.selectedOptions).map(function(o){",
    "return o.value;}).join(',')"))
  expect_identical(picked, "true:visit_type,visit_purpose")
})

test_that("7: the role dropdowns stay inside the analysis plan dialog", {
  session <- open_demo_builder()
  on.exit(session$close(), add = TRUE)

  overflow <- js(session, paste0(
    "S.analysis_plan.push({id:'RQZ',research_question:'Q',",
    "method:'regression_linear',roles:{predictors:['value_slider',",
    "'nights_stayed'],dependent:'overall_rating'}});",
    "openRQModal('RQZ');",
    "var box=document.getElementById('rqRoleFields').getBoundingClientRect();",
    "Array.from(document.querySelectorAll('#rqRoleFields select'))",
    ".map(function(s){return s.getBoundingClientRect().right-box.right;})",
    ".reduce(function(a,b){return Math.max(a,b);},-1e9)"))
  expect_lte(overflow, 1)
})
