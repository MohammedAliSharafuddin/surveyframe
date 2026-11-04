# tests/testthat/test-builder-dialogs.R
#
# UX-14: every SurveyBuilder dialog is a labelled modal dialog. Only Settings
# had a label, Escape removed every dialog's class directly so focus was
# lost, and Tab walked out to the page behind. Escape and Tab are checked in
# a real Chrome in test-builder-ui2-browser.R.

test_that("all 7 dialogs say they are modal and name their title", {
  src <- sframe_installed_text("inst", "builder", "survey_builder.html")
  tags <- regmatches(src, gregexpr('<div class="modal[^"]*" role="dialog"[^>]*>', src))[[1]]
  expect_length(tags, 7L)
  for (tag in tags) {
    expect_match(tag, 'aria-modal="true"', fixed = TRUE)
    label <- sub('^.*aria-labelledby="([^"]+)".*$', "\\1", tag)
    expect_false(identical(label, tag), info = tag)
    expect_match(src, sprintf('id="%s"', label), fixed = TRUE)
  }
  # Each close button has a name, where it was a bare multiplication sign.
  closes <- regmatches(src, gregexpr('<button type="button" class="mx"[^>]*>', src))[[1]]
  expect_true(all(grepl('aria-label="', closes, fixed = TRUE)))
})

test_that("Escape closes the top dialog through closeModal(), and Tab is kept inside", {
  src <- sframe_installed_text("inst", "builder", "survey_builder.html")
  expect_match(src, "if(e.key==='Escape'){var top=topModal();if(top){e.preventDefault();if(top.id==='m-amend')resAmend(false);else closeModal(top.id);}}",
               fixed = TRUE)
  expect_false(grepl("querySelectorAll('.mov.open').forEach(function(m){m.classList.remove('open');})",
                     src, fixed = TRUE))
  expect_match(src, "if(e.key==='Tab'){var tm=topModal();if(tm)trapTab(e,tm);}", fixed = TRUE)
})
