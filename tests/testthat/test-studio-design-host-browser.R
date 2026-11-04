# tests/testthat/test-studio-design-host-browser.R
#
# The builder inside SurveyStudio's Design screen (session 7, owner review of
# f8fe6a6). Studio has its own name, its own Preview Survey screen and its
# own Collect screen, so inside Studio the builder drops its brand, its
# Preview mode and its Export survey button. Its save state reads "Saved" or
# "Unsaved changes", and Studio's line reads "Editing: <title> (<version>)",
# with a reminder only while the builder has unsaved changes. The builder on
# its own keeps all of these. Its Analyse mode is "Plan" in both, after the
# stages Design, Plan, Preview and Collect. Driven in a real Chrome against
# the build under test.

test_that("inside Studio the builder is a Design screen, not a second app", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("shiny")
  skip_if_not_installed("chromote")
  skip_if_not_installed("callr")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")

  # The child loads the build under test with library(), never load_all().
  libpath <- sframe_build_libpath()
  port <- httpuv::randomPort()
  proc <- callr::r_bg(function(port) {
    library(surveyframe)
    launch_studio(demo = "likert_scale", screen = "design", port = port,
                  launch.browser = FALSE)
  }, args = list(port), libpath = libpath)
  on.exit(proc$kill(), add = TRUE)
  url <- paste0("http://127.0.0.1:", port)
  for (i in 1:180) {
    up <- tryCatch({ suppressWarnings(readLines(url, n = 1)); TRUE }, error = function(e) FALSE)
    if (up) break
    Sys.sleep(0.5)
  }
  skip_if(!up, "Studio did not start")
  b <- sframe_chrome_session(width = 1280, height = 900)
  on.exit(b$close(), add = TRUE)
  b$Page$navigate(url)
  js <- function(code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
  wait <- function(cond, n = 120) {
    for (i in 1:n) {
      if (isTRUE(tryCatch(js(cond), error = function(e) FALSE))) return(TRUE)
      Sys.sleep(0.5)
    }
    FALSE
  }
  frame <- "document.getElementById('design_frame').contentWindow"
  doc <- paste0(frame, ".document")
  hidden <- function(sel) js(paste0("(function(){ var e = ", doc, ".querySelector(\"", sel,
                                    "\"); return !!e && e.offsetParent === null; })()"))
  status <- "((document.getElementById('design_status')||{}).innerText||'')"
  unsaved <- "(function(){ var e = document.getElementById('design_unsaved'); return !!e && e.offsetParent !== null; })()"
  save_st <- paste0(doc, ".getElementById('saveSt').textContent")

  expect_true(wait(paste0(frame, ".S && ", frame, ".S.items.length > 0")))
  expect_true(hidden(".tb-brand"))
  expect_true(hidden(".m-btn[data-mode='preview']"))
  expect_true(hidden("#exportBtn"))
  expect_identical(js(paste0(doc, ".querySelector(\".m-btn[data-mode='analyse']\").textContent")), "Plan")

  title <- js(paste0(frame, ".S.meta.title"))
  version <- js(paste0(frame, ".S.meta.version"))
  expect_true(wait(paste0(status, ".indexOf(", jsonlite::toJSON(
    paste0("Editing: ", title, " (", version, ")"), auto_unbox = TRUE), ") >= 0")))
  expect_false(grepl("Save to Studio in the builder", js(status), fixed = TRUE))
  expect_true(wait(paste0(save_st, " === 'Saved'")))
  expect_false(js(unsaved))

  # An edit: both sides say there are unsaved changes, until a save.
  js(paste0(frame, ".setDirty(); true"))
  expect_true(wait(paste0(save_st, " === 'Unsaved changes'")))
  expect_true(wait(unsaved))
  expect_match(js("document.getElementById('design_unsaved').innerText"),
               "Unsaved changes. Save to Studio to keep them.", fixed = TRUE)
  js(paste0("var w=", frame, "; w.S._origin = null; w.S.meta.title = 'Saved in Design'; w.saveSframe(); true"))
  # The demo has a history, so the save opens the amendment dialog (8a).
  expect_true(wait("$('#amend_dlg-as_new').is(':visible')"))
  js("$('#amend_dlg-as_new').click(); true")
  expect_true(wait(paste0(status, ".indexOf('Editing: Saved in Design') >= 0")))
  expect_true(wait(paste0("!", unsaved)))
  expect_true(wait(paste0(save_st, " === 'Saved'")))
})

test_that("the builder on its own keeps its brand, Preview and Export survey", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("chromote")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")
  # The first library on the path is the build under test.
  builder <- Filter(file.exists, file.path(sframe_build_libpath(), "surveyframe",
                                          "builder", "survey_builder.html"))[1]
  skip_if(is.na(builder), "the build under test has no builder")
  b <- sframe_chrome_session(width = 1280, height = 900)
  on.exit(b$close(), add = TRUE)
  loaded <- b$Page$loadEventFired(wait_ = FALSE)
  b$Page$navigate(paste0("file://", normalizePath(builder)), wait_ = FALSE)
  b$wait_for(loaded)
  js <- function(code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
  shown <- function(sel) js(paste0("(function(){ var e = document.querySelector(\"", sel,
                                   "\"); return !!e && e.offsetParent !== null; })()"))
  expect_true(shown(".tb-brand"))
  expect_true(shown(".m-btn[data-mode='preview']"))
  expect_true(shown("#exportBtn"))
  expect_true(shown("#openBtn"))
  expect_identical(js("document.querySelector(\".m-btn[data-mode='analyse']\").textContent"), "Plan")
})
