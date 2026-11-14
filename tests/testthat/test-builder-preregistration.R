# SurveyBuilder edits study$preregistration on its Study tab, which Studio's
# Plan screen and the builder's Plan mode open with "Preregistration fields"
# (owner 2026-11-14). Run under V8 through helper-v8-builder.R.

prereg_file_instrument <- function() {
  ins <- sframe_demo("two_group", preview = FALSE)$instrument
  ins$study$preregistration <- list(stopping_rule = "At 120 responses.",
                                    multiplicity = "Holm correction across RQ1 and RQ2.")
  ins$meta$version <- "2.0.0"
  ins
}

test_that("a preregistration opened in the builder fills the Study tab and saves unchanged", {
  ctx <- builder_open(builder_context(), prereg_file_instrument(), new_instrument = TRUE)
  ctx$eval("openSettings('study')")
  expect_identical(ctx$eval("gv('s-pr-stopping_rule')"), "At 120 responses.")
  expect_identical(ctx$eval("gv('s-pr-exclusion_rules')"), "")
  expect_identical(ctx$eval("JSON.stringify(studyRead().preregistration)"),
                   '{"stopping_rule":"At 120 responses.","multiplicity":"Holm correction across RQ1 and RQ2."}')
  back <- read_sframe(builder_save(ctx))
  expect_identical(back$study$preregistration$multiplicity, "Holm correction across RQ1 and RQ2.")
})

test_that("a field written in the builder is saved, and a blank one left out", {
  ctx <- builder_open(builder_context(), prereg_file_instrument(), new_instrument = TRUE)
  ctx$eval("openSettings('study'); sv('s-pr-exclusion_rules', '  Failed attention check.  '); sv('s-pr-stopping_rule', '   '); saveSettings();")
  back <- read_sframe(builder_save(ctx), verify = FALSE)
  pr <- back$study$preregistration
  expect_identical(pr$exclusion_rules, "Failed attention check.")
  expect_null(pr$stopping_rule)
  expect_true(validate_sframe(back)$valid)
})

test_that("Plan mode has a button that opens the preregistration fields", {
  src <- sframe_installed_text("inst", "builder", "survey_builder.html")
  expect_match(src, "id=\"anPrereg\" onclick=\"openSettings('study')\">Preregistration fields</button>", fixed = TRUE)
  for (f in surveyframe:::sframe_preregistration_fields) {
    expect_match(src, paste0("id=\"s-pr-", f, "\""), fixed = TRUE, info = f)
  }
  expect_match(src, paste0("var PREREG_FIELDS=['", paste(surveyframe:::sframe_preregistration_fields, collapse = "','"), "'];"),
               fixed = TRUE)
})
