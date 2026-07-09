# tests/testthat/test-aic-rsam-branching.R
# v0.3.3 headless regression test of the static-survey branching evaluator
# against the AIC-RSAM eligibility cascade (dev branch only). Requires the
# AIC-RSAM fixture (data-raw/aic_rsam_fixture.R) and chromote with a local
# Chrome. Skips cleanly when either is absent, so the file is inert on CRAN.

test_that("AIC-RSAM eligibility cascade behaves correctly in the exported survey", {
  fixture <- test_path("fixtures", "aic_rsam_pilot.sframe")
  skip_if(!file.exists(fixture), "AIC-RSAM fixture not present (dev branch only)")
  skip_if_not_installed("chromote")
  skip_on_cran()

  x <- read_sframe(fixture)
  out <- tempfile(fileext = ".html")
  on.exit(unlink(out), add = TRUE)
  export_static_survey(x, output_path = out, open = FALSE, overwrite = TRUE)

  b <- chromote::ChromoteSession$new()
  on.exit(b$close(), add = TRUE)
  b$Page$navigate(paste0("file://", normalizePath(out)))

  js <- function(code) {
    b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
  }
  for (i in 1:50) {
    rs <- tryCatch(js("document.readyState"), error = function(e) NULL)
    if (identical(rs, "complete")) break
    Sys.sleep(0.2)
  }
  skip_if(!identical(js("typeof startSurvey"), "function"),
          "survey page did not initialise")

  js("document.getElementById('consent-chk').click();
      document.querySelector('.btn.btn-p.btn-lg').click(); true")

  vis <- function(id) {
    isTRUE(js(sprintf(
      "(function(){var el=document.getElementById('item_%s');
        return el ? !el.classList.contains('hidden') : null;})()", id)))
  }
  answer <- function(id, value) {
    ok <- js(sprintf(
      "(function(){var el=document.querySelector('input[name=\"%s\"][value=\"%s\"]');
        if(!el)return false; el.click(); return true;})()", id, value))
    expect_true(isTRUE(ok), label = paste("answer", id, "=", value))
  }
  main_probe <- c("prof_mode_first", "aia_1", "bi_4", "od_1")
  main_hidden  <- function() all(!vapply(main_probe, vis, logical(1)))
  main_visible <- function() all(vapply(main_probe, vis, logical(1)))

  # Fresh state and the four hard gates
  expect_false(vis("elig_nationality"))
  expect_true(main_hidden())
  answer("elig_age", "no")
  expect_false(vis("elig_nationality"))
  answer("elig_age", "yes")
  expect_true(vis("elig_nationality"))
  expect_false(vis("elig_resort_stay"))
  answer("elig_nationality", "yes")
  expect_true(vis("elig_resort_stay"))
  answer("elig_resort_stay", "yes")
  expect_true(vis("elig_stay_duration"))

  # E4 = 1 night is a hard exclusion
  answer("elig_stay_duration", "1_night")
  expect_false(vis("elig_room_service"))
  expect_true(main_hidden())

  # E4 = 2 nights admits the respondent
  answer("elig_stay_duration", "2_nights")
  expect_true(vis("elig_room_service"))
  expect_true(main_visible())
  expect_false(vis("elig_rs_times"))

  # E6 requires E5 = yes AND the duration gate (multi-rule AND regression)
  answer("elig_room_service", "yes")
  expect_true(vis("elig_rs_times"))
  answer("elig_stay_duration", "1_night")
  expect_false(vis("elig_rs_times"))
  answer("elig_stay_duration", "3_4_nights")
  expect_true(vis("elig_rs_times"))

  # Flipping the first gate hides the whole chain despite stale downstream
  # answers (cascade regression)
  answer("elig_age", "no")
  expect_false(vis("elig_stay_duration"))
  expect_false(vis("elig_rs_times"))
  expect_true(main_hidden())
  answer("elig_age", "yes")
  expect_true(vis("elig_rs_times"))

  # A screened-out respondent can submit: hidden required items do not block
  answer("elig_stay_duration", "1_night")
  js("nextPage();")
  Sys.sleep(0.3)
  expect_identical(js("screen"), "thankyou")
})
