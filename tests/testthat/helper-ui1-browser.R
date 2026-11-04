# tests/testthat/helper-ui1-browser.R
#
# Session UI-1's Studio browser tests share 1 Studio process and 1 Chrome tab
# per demo, started the first time a test asks for it and closed by
# ui1_close() at the end of test-studio-ui1-browser.R ("none" opens Studio
# with no instrument). Studio takes about
# 35 s to start, and a page load starts it again, so tests move between
# screens through the sidebar and never reload. The JavaScript helpers are
# ui2_js() and ui2_wait() from helper-ui2-browser.R.

ui1_apps <- new.env(parent = emptyenv())

ui1_studio <- function(demo = "factor_structure", screen = "open",
                       width = 1280, height = 900) {
  s <- ui1_apps[[demo]]
  if (is.null(s)) {
    libpath <- sframe_build_libpath()
    port <- httpuv::randomPort()
    proc <- callr::r_bg(function(demo, screen, port) {
      library(surveyframe)
      launch_studio(demo = if (identical(demo, "none")) NULL else demo,
                    screen = screen, port = port,
                    launch.browser = FALSE)
    }, args = list(demo, screen, port), libpath = libpath)
    url <- paste0("http://127.0.0.1:", port)
    up <- FALSE
    for (i in 1:180) {
      up <- tryCatch({ suppressWarnings(readLines(url, n = 1)); TRUE },
                     error = function(e) FALSE)
      if (up) break
      Sys.sleep(0.5)
    }
    if (!up) {
      proc$kill()
      testthat::skip("Studio did not start")
    }
    b <- sframe_chrome_session(width = width, height = height)
    ui2_navigate(b, url)
    s <- list(b = b, proc = proc, url = url)
    ui1_apps[[demo]] <- s
    if (!ui2_wait(b, "window.Shiny && Shiny.shinyapp && Shiny.shinyapp.isConnected()", 120))
      stop("Studio did not connect")
  } else {
    s$b$Emulation$setDeviceMetricsOverride(width = width, height = height,
                                           deviceScaleFactor = 1, mobile = FALSE)
  }
  try(s$b$Page$bringToFront(), silent = TRUE)
  s$b
}

ui1_close <- function() {
  for (demo in ls(ui1_apps)) {
    try(ui1_apps[[demo]]$b$close(), silent = TRUE)
    try(ui1_apps[[demo]]$proc$kill(), silent = TRUE)
    rm(list = demo, envir = ui1_apps)
  }
  invisible(NULL)
}

# Opens a Studio screen through its sidebar entry and waits until it shows.
ui1_screen <- function(b, screen, timeout = 20) {
  ui2_js(b, sprintf("$('[data-tab=\"%s\"]').click(); true", screen))
  ui2_wait(b, sprintf("(function(){ var s = document.getElementById('screen-%s'); return !!s && s.offsetParent !== null; })()", screen), timeout)
}

# Sets a Shiny input from the page, through selectize for a select.
ui1_set <- function(b, id, value) {
  ui2_js(b, sprintf("(function(){ var e = $('#%s'), v = %s; if (e[0] && e[0].selectize) e[0].selectize.setValue(v); else e.val(v).trigger('input').trigger('change'); return true; })()", id,
                    jsonlite::toJSON(value, auto_unbox = TRUE)))
}

ui1_text <- function(b, id) {
  ui2_js(b, sprintf("((document.getElementById('%s')||{}).innerText||'')", id))
}

ui1_modal_open <- "($('#shiny-modal').is(':visible') && $('#shiny-modal').text().indexOf('Record an amendment') >= 0)"

# Loads the page again, which starts Studio's session again, and waits for it.
ui1_reload <- function(demo) {
  s <- ui1_apps[[demo]]
  ui2_navigate(s$b, s$url)
  ui2_wait(s$b, "window.Shiny && Shiny.shinyapp && Shiny.shinyapp.isConnected()", 120)
}
