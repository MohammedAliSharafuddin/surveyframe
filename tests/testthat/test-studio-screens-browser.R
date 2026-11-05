# tests/testthat/test-studio-screens-browser.R
#
# Studio start-up in a real Chrome. Screens are shown and hidden with CSS
# classes, and Shiny suspends an output while its screen is hidden. The
# screen switch tells Shiny the screen is visible, so each screen's outputs
# draw when it opens, without keeping every output alive at start-up.

test_that("every Studio screen draws its content when opened", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("shiny")
  skip_if_not_installed("chromote")
  skip_if_not_installed("callr")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")

  # The child loads the build under test with library(), as a user would.
  libpath <- sframe_build_libpath()
  port <- httpuv::randomPort()
  proc <- callr::r_bg(function(port) {
    library(surveyframe)
    demo <- sframe_demo("likert_scale")
    launch_studio(demo$instrument, responses = demo$responses, screen = "open",
                  port = port, launch.browser = FALSE)
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
  wait <- function(cond, tries = 120) {
    for (i in seq_len(tries)) {
      if (isTRUE(tryCatch(js(cond), error = function(e) FALSE))) return(TRUE)
      Sys.sleep(0.5)
    }
    FALSE
  }
  expect_true(wait("window.Shiny && Shiny.shinyapp && Shiny.shinyapp.isConnected()"))
  # app.R runs as an app object, so www/ is served under sfstudio/.
  expect_true(wait("(function(){ var i = document.querySelector('img[src^=\"sfstudio/\"]');
    return !!i && i.complete && i.naturalWidth > 0; })()"), label = "header logo loads")

  # The output each screen must draw once it is opened.
  screens <- c(
    open = "instrument_summary_card", preview = "survey_preview_items",
    responses = "responses_summary_card", quality = "studio_quality_chart",
    reliability = "reliability_output", analysis = "analysis_declared_plan",
    dashboard = "studio_dashboard_content", export = "export_sframe_ui")
  for (tab in names(screens)) {
    js(sprintf("document.querySelector('[data-tab=\"%s\"]').click(); true", tab))
    drawn <- wait(sprintf(
      "(function(){ var e = document.getElementById('%s');
         return !!e && $('#screen-%s').hasClass('active') &&
           (e.querySelector('img') !== null || e.innerText.trim().length > 0); })()",
      screens[[tab]], tab))
    expect_true(drawn, label = paste("screen", tab, "draws", screens[[tab]]))
  }
})

test_that("Studio no longer keeps every screen's outputs alive", {
  src <- sframe_installed_text("shiny", "app.R")
  expect_false(grepl("outputOptions(output, .oid", src, fixed = TRUE))
  # The switch itself tells Shiny, rather than relying on the current_tab
  # round trip to make Shiny check visibility again.
  expect_match(src, "addClass('active').trigger('shown')", fixed = TRUE)
})

test_that("the launch screen does not override a screen picked before it", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("shiny")
  skip_if_not_installed("chromote")
  skip_if_not_installed("callr")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")

  libpath <- sframe_build_libpath()
  port <- httpuv::randomPort()
  proc <- callr::r_bg(function(port) {
    library(surveyframe)
    launch_studio(demo = "likert_scale", screen = "open", port = port,
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
  for (i in 1:120) {
    if (isTRUE(tryCatch(js("window.Shiny && Shiny.shinyapp && Shiny.shinyapp.isConnected()"),
                        error = function(e) FALSE))) break
    Sys.sleep(0.5)
  }
  expect_identical(js("typeof studioLaunchScreen"), "function")
  # With nothing picked, the launch switch still applies. The server's own
  # launch screen ("open") follows the first flush and can land after this
  # call (seen once on macOS), so the switch is applied until it holds.
  shown <- FALSE
  for (i in 1:40) {
    js("studioLaunchScreen('reliability'); true")
    shown <- isTRUE(js("$('#screen-reliability').hasClass('active')"))
    if (shown) break
    Sys.sleep(0.25)
  }
  expect_true(shown)
  # The researcher opens Preview, then the start-up switch to the launch
  # screen arrives late, as it does after a slow first flush.
  js("document.querySelector('[data-tab=\"preview\"]').click(); true")
  js("studioLaunchScreen('open'); true")
  expect_true(js("$('#screen-preview').hasClass('active')"))
  expect_false(js("$('#screen-open').hasClass('active')"))
})

test_that("a dashboard filter lowers the filtered-responses tile", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("shiny")
  skip_if_not_installed("chromote")
  skip_if_not_installed("callr")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")

  resp <- sframe_demo("input_types")$responses
  total <- nrow(resp)
  chosen <- sort(unique(as.character(resp$visit_type[!is.na(resp$visit_type)])))[1]
  expected <- sum(as.character(resp$visit_type) == chosen, na.rm = TRUE)
  expect_lt(expected, total)

  libpath <- sframe_build_libpath()
  port <- httpuv::randomPort()
  proc <- callr::r_bg(function(port) {
    library(surveyframe)
    launch_studio(demo = "input_types", screen = "dashboard", port = port,
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
  wait <- function(cond, tries = 120) {
    for (i in seq_len(tries)) {
      if (isTRUE(tryCatch(js(cond), error = function(e) FALSE))) return(TRUE)
      Sys.sleep(0.5)
    }
    FALSE
  }
  expect_true(wait("window.Shiny && Shiny.shinyapp && Shiny.shinyapp.isConnected()"))
  tile <- "(function(){ var e = document.getElementById('dash_filtered_tile');
    return e ? e.querySelector('.stat-val').innerText.trim() : ''; })()"
  expect_true(wait(sprintf("%s === '%d'", gsub("\n", " ", tile), total)),
              label = "tile shows every response before filtering")
  js(sprintf("Shiny.setInputValue('dash_filter_visit_type', ['%s']); true", chosen))
  expect_true(wait(sprintf("%s === '%d'", gsub("\n", " ", tile), expected)),
              label = "tile shows the filtered count")
})
