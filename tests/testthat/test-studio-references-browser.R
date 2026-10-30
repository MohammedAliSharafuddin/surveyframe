# tests/testthat/test-studio-references-browser.R
#
# SurveyStudio's References screen (owner decision 2026-10-25), driven in a
# real Chrome: paste BibTeX, add it, see it listed, remove it. The rebuild
# that carries references into the open instrument is tested without a
# browser in test-studio-roundtrip-content.R.

test_that("references is a Studio screen launch_studio() accepts", {
  expect_true("references" %in% sframe_studio_screens())
  expect_identical(sframe_studio_screen("references"), "references")
})

test_that("the References screen adds and removes a reference", {
  skip_on_cran()
  skip_if_not_installed("shiny")
  skip_if_not_installed("chromote")
  skip_if_not_installed("callr")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")

  # The child loads the build under test with library(), as a user would,
  # never the source with load_all() (helper-build-under-test.R).
  libpath <- sframe_build_libpath()
  port <- httpuv::randomPort()
  proc <- callr::r_bg(function(port) {
    library(surveyframe)
    launch_studio_demo(screen = "references", port = port, launch.browser = FALSE)
  }, args = list(port), libpath = libpath)
  on.exit(proc$kill(), add = TRUE)
  url <- paste0("http://127.0.0.1:", port)
  for (i in 1:180) {
    up <- tryCatch({ suppressWarnings(readLines(url, n = 1)); TRUE }, error = function(e) FALSE)
    if (up) break
    Sys.sleep(0.5)
  }
  skip_if(!up, "Studio did not start")
  b <- chromote::ChromoteSession$new(width = 1280, height = 900)
  on.exit(b$close(), add = TRUE)
  b$Page$navigate(url)
  js <- function(code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
  wait <- function(cond) {
    for (i in 1:300) {
      if (isTRUE(tryCatch(js(cond), error = function(e) FALSE))) return(TRUE)
      Sys.sleep(0.5)
    }
    FALSE
  }
  table_text <- "((document.getElementById('refs_table')||{}).innerText||'')"
  expect_true(wait(paste0(table_text, ".indexOf('References in this instrument') >= 0")))
  expect_true(wait(paste0(table_text, ".indexOf('No references yet') >= 0")))

  js("Shiny.setInputValue('refs_bibtex', '@article{cronbach_1951, author = {Cronbach, Lee J.}, title = {Coefficient alpha and the internal structure of tests}, journal = {Psychometrika}, year = {1951}}'); true")
  Sys.sleep(0.5)
  js("document.getElementById('refs_add_btn').click(); true")
  expect_true(wait(paste0(table_text, ".indexOf('cronbach_1951') >= 0")))
  expect_match(js(table_text), "Cronbach (1951). Coefficient alpha", fixed = TRUE)

  expect_true(wait("document.getElementById('refs_remove_id').value === 'cronbach_1951'"))
  js("document.getElementById('refs_remove_btn').click(); true")
  expect_true(wait(paste0(table_text, ".indexOf('No references yet') >= 0")))
})
