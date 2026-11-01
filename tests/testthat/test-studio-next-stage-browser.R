# tests/testthat/test-studio-next-stage-browser.R
#
# Every SurveyStudio screen that has nothing to show yet names the next
# stage and links to it (session 7). With no instrument, each screen past
# Design and Open Instrument points to those 2. With an instrument and no
# responses, the screens that need responses point to Collect and
# Responses. Driven in a real Chrome against the build under test.

test_that("the screens list has the Design and Collect stages in order", {
  screens <- sframe_studio_screens()
  expect_true(all(c("design", "collect") %in% screens))
  expect_lt(match("design", screens), match("preview", screens))
  expect_lt(match("preview", screens), match("collect", screens))
  expect_lt(match("collect", screens), match("responses", screens))
})

next_stage_session <- function(launch) {
  libpath <- sframe_build_libpath()
  port <- httpuv::randomPort()
  proc <- callr::r_bg(launch, args = list(port), libpath = libpath)
  url <- paste0("http://127.0.0.1:", port)
  for (i in 1:180) {
    up <- tryCatch({ suppressWarnings(readLines(url, n = 1)); TRUE }, error = function(e) FALSE)
    if (up) break
    Sys.sleep(0.5)
  }
  if (!up) {
    proc$kill()
    return(NULL)
  }
  b <- chromote::ChromoteSession$new(width = 1280, height = 900)
  b$Page$navigate(url)
  js <- function(code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
  wait <- function(cond, n = 120) {
    for (i in 1:n) {
      if (isTRUE(tryCatch(js(cond), error = function(e) FALSE))) return(TRUE)
      Sys.sleep(0.5)
    }
    FALSE
  }
  # The tabs each screen's next-stage links point to, once the screen shows.
  links <- function(screen) {
    js(paste0("$('.studio-nav-item a[data-tab=\"", screen, "\"]').click(); true"))
    sel <- paste0("#screen-", screen, " .next-stage a[data-tab]")
    if (!wait(paste0("$('#screen-", screen, "').hasClass('active') && $('", sel, "').length > 0"), n = 20)) {
      return(character(0))
    }
    unlist(js(paste0("$('", sel, "').map(function() { return $(this).data('tab'); }).get()")))
  }
  list(proc = proc, b = b, js = js, wait = wait, links = links)
}

skip_without_next_stage_browser <- function() {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("shiny")
  skip_if_not_installed("chromote")
  skip_if_not_installed("callr")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")
}

test_that("with no instrument every later screen names Design and Open Instrument", {
  skip_without_next_stage_browser()
  # The child loads the build under test with library(), never load_all().
  s <- next_stage_session(function(port) {
    library(surveyframe)
    launch_studio(port = port, launch.browser = FALSE)
  })
  skip_if(is.null(s), "Studio did not start")
  on.exit({ s$b$close(); s$proc$kill() }, add = TRUE)
  expect_true(s$wait("$('#screen-design').hasClass('active')"))
  for (screen in setdiff(sframe_studio_screens(), c("design", "open"))) {
    expect_setequal(s$links(screen), c("design", "open"))
  }
  # A link goes to its stage.
  s$js("$('#screen-quality .next-stage a[data-tab=\"open\"]').click(); true")
  expect_true(s$wait("$('#screen-open').hasClass('active')"))
})

test_that("with no responses the screens that need them name Collect and Responses", {
  skip_without_next_stage_browser()
  s <- next_stage_session(function(port) {
    library(surveyframe)
    launch_studio(sframe_demo("likert_scale")$instrument, screen = "open",
                  port = port, launch.browser = FALSE)
  })
  skip_if(is.null(s), "Studio did not start")
  on.exit({ s$b$close(); s$proc$kill() }, add = TRUE)
  expect_true(s$wait("$('#screen-open').hasClass('active')"))
  for (screen in c("quality", "reliability", "dashboard")) {
    expect_setequal(s$links(screen), c("collect", "responses"))
  }
  s$js("$('#screen-dashboard .next-stage a[data-tab=\"collect\"]').click(); true")
  expect_true(s$wait("$('#screen-collect').hasClass('active')"))
})
