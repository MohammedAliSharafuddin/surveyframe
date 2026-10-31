# tests/testthat/test-studio-sidebar-active-browser.R
#
# Exactly 1 SurveyStudio sidebar entry looks selected, whichever way a
# screen is reached (session 7, owner review of f8fe6a6). With Design open,
# Design and Preview Survey both looked selected: an entry under the mouse
# took the selected look, teal bar and white text, so the selected screen
# and the hovered one could not be told apart. The test counts the entries
# that look selected, by computed style, with a real mouse resting on
# another entry, and the entries with the active class.

sidebar_session <- function(launch) {
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
  mouse <- function(type, sel) {
    xy <- js(paste0("(function(){ var r = document.querySelector('", sel,
                    "').getBoundingClientRect(); return [r.left + r.width / 2, r.top + r.height / 2]; })()"))
    b$Input$dispatchMouseEvent(type = type, x = xy[[1]], y = xy[[2]],
                               button = "left", clickCount = 1)
  }
  nav <- function(tab) paste0(".studio-nav-item a[data-tab=\"", tab, "\"]")
  # The entries that look selected, and the entries with the active class.
  looks <- function() {
    unlist(js(paste0(
      "var on = getComputedStyle($('.studio-nav-item a.active')[0] || document.body).borderLeftColor;",
      "$('.studio-nav-item a').filter(function() {",
      "  var s = getComputedStyle(this);",
      "  return s.borderLeftColor === 'rgb(22, 179, 177)' || s.color === 'rgb(255, 255, 255)';",
      "}).map(function() { return $(this).data('tab'); }).get()")))
  }
  active <- function() {
    unlist(js("$('.studio-nav-item a.active').map(function() { return $(this).data('tab'); }).get()"))
  }
  list(proc = proc, b = b, js = js, wait = wait, mouse = mouse, nav = nav,
       looks = looks, active = active)
}

skip_without_sidebar_browser <- function() {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("shiny")
  skip_if_not_installed("chromote")
  skip_if_not_installed("callr")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")
}

test_that("a sidebar click leaves exactly 1 entry selected, with the mouse on another", {
  skip_without_sidebar_browser()
  # The child loads the build under test with library(), never load_all().
  s <- sidebar_session(function(port) {
    library(surveyframe)
    launch_studio(demo = "likert_scale", screen = "open", port = port,
                  launch.browser = FALSE)
  })
  skip_if(is.null(s), "Studio did not start")
  on.exit({ s$b$close(); s$proc$kill() }, add = TRUE)
  expect_true(s$wait("$('#screen-open').hasClass('active')"))
  screens <- sframe_studio_screens()
  for (i in seq_along(screens)) {
    tab <- screens[[i]]
    s$mouse("mouseMoved", s$nav(tab))
    s$mouse("mousePressed", s$nav(tab))
    s$mouse("mouseReleased", s$nav(tab))
    expect_true(s$wait(paste0("$('#screen-", tab, "').hasClass('active')")), info = tab)
    # The mouse moves on to the next entry, as it does on the way to it.
    other <- screens[[if (i < length(screens)) i + 1 else 1]]
    s$mouse("mouseMoved", s$nav(other))
    Sys.sleep(0.4)
    expect_identical(s$active(), tab, info = tab)
    expect_identical(s$looks(), tab, info = paste(tab, "with the mouse on", other))
  }
})

test_that("an in-screen link leaves exactly 1 entry selected", {
  skip_without_sidebar_browser()
  s <- sidebar_session(function(port) {
    library(surveyframe)
    launch_studio(port = port, launch.browser = FALSE)
  })
  skip_if(is.null(s), "Studio did not start")
  on.exit({ s$b$close(); s$proc$kill() }, add = TRUE)
  expect_true(s$wait("$('#screen-design').hasClass('active')"))
  expect_identical(s$active(), "design")
  Sys.sleep(0.4)
  expect_identical(s$looks(), "design")
  # Every screen's next-stage links, from that screen.
  for (screen in setdiff(sframe_studio_screens(), c("design", "open"))) {
    s$js(paste0("$('", s$nav(screen), "').click(); true"))
    expect_true(s$wait(paste0("$('#screen-", screen, "').hasClass('active') && $('#screen-",
                              screen, " .next-stage a[data-tab]').length > 0"), n = 20), info = screen)
    for (to in unlist(s$js(paste0("$('#screen-", screen,
                                  " .next-stage a[data-tab]').map(function() { return $(this).data('tab'); }).get()")))) {
      s$js(paste0("$('", s$nav(screen), "').click(); true"))
      s$js(paste0("$('#screen-", screen, " .next-stage a[data-tab=\"", to, "\"]').click(); true"))
      expect_true(s$wait(paste0("$('#screen-", to, "').hasClass('active')"), n = 20), info = to)
      # The entries fade over 0.15 s.
      Sys.sleep(0.4)
      expect_identical(s$active(), to, info = paste(screen, "to", to))
      expect_identical(s$looks(), to, info = paste(screen, "to", to))
    }
  }
})
