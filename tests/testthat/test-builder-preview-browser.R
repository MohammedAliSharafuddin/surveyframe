# tests/testthat/test-builder-preview-browser.R
#
# One preview (session 7): the SurveyBuilder's Preview shows the deployable
# survey, the same page export_survey(preview = TRUE) writes and Studio's
# Preview Survey screen shows, with collection switched off. It drew its own
# copy of the layout, which ran no answers, required checks or branching.
# Driven in a real Chrome on the builder from the build under test.

test_that("the builder's Preview is the survey export_survey(preview = TRUE) writes", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("chromote")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")

  # The first library on the path is the build under test.
  builder <- Filter(file.exists, file.path(sframe_build_libpath(), "surveyframe",
                                          "builder", "survey_builder.html"))[1]
  skip_if(is.na(builder), "the build under test has no builder")

  instr <- sframe_demo("likert_scale")$instrument
  instr$meta$title <- "Preview check"
  instr$render$google_sheets_endpoint <- "https://example.org/collect"
  instr$render$thankyou$redirect_url <- "https://example.org/done"
  path <- tempfile(fileext = ".sframe")
  write_sframe(instr, path, new_instrument = TRUE)

  b <- chromote::ChromoteSession$new(width = 1280, height = 900)
  on.exit(b$close(), add = TRUE)
  loaded <- b$Page$loadEventFired(wait_ = FALSE)
  b$Page$navigate(paste0("file://", normalizePath(builder)), wait_ = FALSE)
  b$wait_for(loaded)
  js <- function(code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
  wait <- function(cond) {
    for (i in 1:60) {
      if (isTRUE(tryCatch(js(cond), error = function(e) FALSE))) return(TRUE)
      Sys.sleep(0.5)
    }
    FALSE
  }
  text <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  js(paste0("openSframeText(", jsonlite::toJSON(text, auto_unbox = TRUE), "); true"))
  expect_true(wait("S.items.length > 0"))
  js("setMode('preview'); true")
  frame <- "document.querySelector('#pvFrame iframe')"
  expect_true(wait(paste0("!!", frame, " && !!", frame, ".srcdoc")))
  shown <- js(paste0(frame, ".srcdoc"))

  out <- tempfile(fileext = ".html")
  suppressMessages(export_survey(instr, output_path = out, open = FALSE, preview = TRUE))
  written <- paste(readLines(out, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

  # The same page around the instrument. The instrument JSON is serialised by
  # JavaScript in one and by jsonlite in the other, so it is compared parsed.
  data_re <- "(<script type=\"application/json\" id=\"sf-data\">)[^<]*(</script>)"
  expect_identical(sub(data_re, "\\1\\2", shown), sub(data_re, "\\1\\2", written))
  json_of <- function(html) {
    m <- regmatches(html, regexpr("id=\"sf-data\">[^<]*", html))
    jsonlite::fromJSON(sub("^id=\"sf-data\">", "", m), simplifyVector = FALSE)
  }
  a <- json_of(shown)
  w <- json_of(written)
  expect_identical(vapply(a$items, `[[`, "", "id"), vapply(w$items, `[[`, "", "id"))
  expect_identical(a$meta$title, w$meta$title)

  # Collection is off: no endpoint, no redirect, and the page knows it.
  expect_false(grepl("example.org", shown, fixed = TRUE))
  expect_match(shown, "data-endpoint=\"\"", fixed = TRUE)
  expect_true(js(paste0(frame, ".contentWindow.eval('PREVIEW')")))
  expect_true(wait(paste0(frame, ".contentDocument.getElementById('app').innerText.length > 0")))
})
