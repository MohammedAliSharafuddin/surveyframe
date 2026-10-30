# tests/testthat/test-static-template-drafts.R
#
# Codex CX-05, decision D3 (0.4.3). draftKey() hashed the title, version and
# items alone, so a changed choice set or consent text resumed an old draft
# against new meaning. resumeDraft() skipped the consent check in
# startSurvey(), so a resumed draft never asked for consent.

draft_instrument <- function(choices = c(Yes = "1", No = "2"),
                             consent_text = "I agree to take part.",
                             consent_required = TRUE) {
  ins <- sf_instrument("Drafts", components = list(
      sf_choices("yn", values = unname(choices), labels = names(choices)),
      sf_item("q1", "Did it help?", type = "single_choice", choice_set = "yn"),
      sf_item("q2", "Anything else?", type = "text")))
  ins$render <- list(save_draft = TRUE,
                     welcome = list(title = "Hi", intro_text = "Welcome.",
                                    consent_text = consent_text,
                                    consent_required = consent_required))
  # The draft key covers created_at, stamped to the second. Each test builds
  # the instrument twice, so a second boundary between the 2 calls made them
  # different instruments and the draft failed to resume.
  ins$meta$created_at <- "2026-10-30T00:00:00Z"
  ins
}
draft_storage <- "window.localStorage = { _d:{},
  getItem:function(k){ return this._d.hasOwnProperty(k) ? this._d[k] : null; },
  setItem:function(k,v){ this._d[k] = String(v); },
  removeItem:function(k){ delete this._d[k]; } };"

# Saves a draft from `ins` and returns the storage, as a later visit sees it.
saved_draft <- function(ins, consented = TRUE) {
  ctx <- static_survey_context(ins, pre = draft_storage)
  if (consented) ctx$eval("document.getElementById('consent-chk').checked = true;")
  ctx$eval("startSurvey(); responses['q1'] = '1'; saveDraft();")
  ctx$get("window.localStorage._d")
}
revisit <- function(ins, stored) {
  static_survey_context(ins, pre = paste0(draft_storage, sprintf(
    " window.localStorage._d = %s;",
    jsonlite::toJSON(stored, auto_unbox = TRUE))))
}

test_that("CX-05: an unchanged instrument resumes its draft", {
  stored <- saved_draft(draft_instrument())
  ctx <- revisit(draft_instrument(), stored)
  expect_false(is.null(ctx$get("loadDraft()")))
})

test_that("CX-05: a changed choice set starts afresh", {
  stored <- saved_draft(draft_instrument())
  ctx <- revisit(draft_instrument(choices = c(No = "1", Yes = "2")), stored)
  expect_null(ctx$get("loadDraft()"))
})

test_that("CX-05: changed consent wording starts afresh", {
  stored <- saved_draft(draft_instrument())
  ctx <- revisit(draft_instrument(consent_text = "I agree, and may withdraw."),
                 stored)
  expect_null(ctx$get("loadDraft()"))
})

test_that("CX-05: a draft records that consent was given", {
  stored <- saved_draft(draft_instrument())
  expect_true(jsonlite::fromJSON(stored[[1]])$consented)
})

test_that("CX-05: a draft without recorded consent resumes at the welcome screen", {
  stored <- saved_draft(draft_instrument())
  draft <- jsonlite::fromJSON(stored[[1]])
  draft$consented <- NULL
  stored[[1]] <- as.character(jsonlite::toJSON(draft, auto_unbox = TRUE))
  ctx <- revisit(draft_instrument(), stored)
  ctx$eval("renderScreen(); resumeDraft();")
  expect_identical(ctx$get("screen"), "welcome")
  expect_match(ctx$get("document.getElementById('consent-err').textContent"),
               "consent", fixed = TRUE)
  # Ticking the box then resuming carries on with the saved answers.
  ctx$eval("document.getElementById('consent-chk').checked = true; resumeDraft();")
  expect_identical(ctx$get("screen"), "survey")
  expect_identical(ctx$get("responses.q1"), "1")
})

test_that("CX-05: a draft with recorded consent resumes into the survey", {
  stored <- saved_draft(draft_instrument())
  ctx <- revisit(draft_instrument(), stored)
  ctx$eval("renderScreen(); resumeDraft();")
  expect_identical(ctx$get("screen"), "survey")
})
