# tests/testthat/helper-ui2-browser.R
#
# Session UI-2's browser tests share 1 Chrome tab per app, opened through
# sframe_chrome_session() the first time a test asks for it and closed by
# ui2_close() at the end of the file. Each test reloads the page, so no state
# passes from one test to the next, and Chrome starts once per app, not once
# per test.

ui2_sessions <- new.env(parent = emptyenv())

ui2_session <- function(app, width = 1280, height = 900) {
  s <- ui2_sessions[[app]]
  if (is.null(s)) {
    s <- sframe_chrome_session(width = width, height = height)
    ui2_sessions[[app]] <- s
  } else {
    s$Emulation$setDeviceMetricsOverride(width = width, height = height,
                                         deviceScaleFactor = 1, mobile = FALSE)
  }
  s
}

ui2_close <- function() {
  for (app in ls(ui2_sessions)) {
    try(ui2_sessions[[app]]$close(), silent = TRUE)
    rm(list = app, envir = ui2_sessions)
  }
  invisible(NULL)
}

ui2_js <- function(session, code, await = FALSE) {
  r <- session$Runtime$evaluate(code, returnByValue = TRUE, awaitPromise = await)
  if (!is.null(r$exceptionDetails)) {
    d <- r$exceptionDetails
    stop("JavaScript error: ",
         if (is.null(d$exception$description)) d$text else d$exception$description,
         call. = FALSE)
  }
  r$result$value
}

ui2_navigate <- function(session, url) {
  loaded <- session$Page$loadEventFired(wait_ = FALSE)
  session$Page$navigate(url, wait_ = FALSE)
  session$wait_for(loaded)
  invisible(session)
}

# Waits until `cond` (JavaScript) is true, for up to `timeout` seconds.
ui2_wait <- function(session, cond, timeout = 5) {
  end <- Sys.time() + timeout
  repeat {
    if (isTRUE(ui2_js(session, paste0("!!(", cond, ")")))) return(TRUE)
    if (Sys.time() > end) return(FALSE)
    Sys.sleep(0.1)
  }
}

# The shipped builder, standalone or as Studio hosts it (?host=studio), with
# `instrument` opened as the Open button would.
ui2_builder <- function(instrument = NULL, width = 1280, height = 900,
                        query = "") {
  session <- ui2_session("builder", width, height)
  path <- system.file("builder", "survey_builder.html", package = "surveyframe")
  ui2_navigate(session, paste0("file://", normalizePath(path), query))
  if (!is.null(instrument)) {
    src <- tempfile(fileext = ".sframe")
    on.exit(unlink(src), add = TRUE)
    write_sframe(instrument, src)
    text <- paste(readLines(src, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
    ui2_js(session, paste0("openSframeText(",
                           jsonlite::toJSON(text, auto_unbox = TRUE), ");1"))
  }
  session
}

# Types `text` at the end of field `id` as a keyboard would: the value grows,
# the caret sits at its end, and an input event fires.
ui2_type <- function(session, id, text) {
  ui2_js(session, sprintf(
    "(function(){var e=document.getElementById(%s);e.focus();e.value+=%s;
      e.setSelectionRange(e.value.length,e.value.length);
      e.dispatchEvent(new Event('input',{bubbles:true}));return 1;})()",
    jsonlite::toJSON(id, auto_unbox = TRUE), jsonlite::toJSON(text, auto_unbox = TRUE)))
}

ui2_key <- function(session, selector, key, shift = FALSE, ctrl = FALSE) {
  # An empty selector sends the key to the element with focus.
  ui2_js(session, sprintf(
    "(function(){var s=%s;var e=s?document.querySelector(s):document.activeElement;
      e.dispatchEvent(new KeyboardEvent('keydown',{key:%s,shiftKey:%s,ctrlKey:%s,bubbles:true,cancelable:true}));return 1;})()",
    jsonlite::toJSON(selector, auto_unbox = TRUE), jsonlite::toJSON(key, auto_unbox = TRUE),
    if (shift) "true" else "false", if (ctrl) "true" else "false"))
}

