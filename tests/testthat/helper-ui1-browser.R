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
      proc$kill_tree()
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

# kill_tree(), since kill() left a Studio child alive twice, holding its
# memory scope and the shared test lock.
ui1_close <- function() {
  for (demo in ls(ui1_apps)) {
    try(ui1_apps[[demo]]$b$close(), silent = TRUE)
    try(ui1_apps[[demo]]$proc$kill_tree(), silent = TRUE)
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

# The text and background pairs below WCAG 2.2 AA in a document, measured
# from computed colours (UX-21). Each element with its own visible text is
# measured against its background, laid over its ancestors' backgrounds down
# to white, so a translucent colour is measured as it shows. Large text
# (24 px, or 18.66 px bold) needs 3 to 1, other text 4.5 to 1. Disabled
# controls are exempt. Returns a data frame of the failures.
ui1_contrast_js <- "(function(doc){
  function parse(c){ var m = /rgba?\\(([^)]+)\\)/.exec(c || '');
    if (m) { var p = m[1].split(',').map(parseFloat); return {r:p[0], g:p[1], b:p[2], a: p.length > 3 ? p[3] : 1}; }
    // color-mix() computes to color(srgb r g b / a), each channel 0 to 1.
    m = /color\\(srgb ([^)]+)\\)/.exec(c || ''); if (!m) return null;
    var q = m[1].replace('/', ' ').trim().split(/\\s+/).map(parseFloat);
    return {r:q[0]*255, g:q[1]*255, b:q[2]*255, a: q.length > 3 ? q[3] : 1}; }
  function over(t, u){ var a = t.a; return {r:t.r*a+u.r*(1-a), g:t.g*a+u.g*(1-a), b:t.b*a+u.b*(1-a), a:1}; }
  function back(el){ var s = []; for (var e = el; e; e = e.parentElement) {
      var c = parse(doc.defaultView.getComputedStyle(e).backgroundColor);
      if (c && c.a > 0) { s.push(c); if (c.a >= 1) break; } }
    var o = {r:255, g:255, b:255, a:1}; for (var i = s.length - 1; i >= 0; i--) o = over(s[i], o); return o; }
  function lum(c){ function f(v){ v /= 255; return v <= 0.03928 ? v/12.92 : Math.pow((v+0.055)/1.055, 2.4); }
    return 0.2126*f(c.r) + 0.7152*f(c.g) + 0.0722*f(c.b); }
  var out = [], seen = [], w = doc.createTreeWalker(doc.body, NodeFilter.SHOW_TEXT);
  while (w.nextNode()) {
    var t = w.currentNode, el = t.parentElement;
    if (!el || !t.nodeValue.trim() || seen.indexOf(el) >= 0) continue; seen.push(el);
    if (['SCRIPT','STYLE','NOSCRIPT','OPTION','TITLE'].indexOf(el.tagName) >= 0) continue;
    var r = el.getBoundingClientRect(), cs = doc.defaultView.getComputedStyle(el);
    if (!r.width || !r.height || cs.visibility === 'hidden' || el.closest('[hidden]')) continue;
    if (el.closest('[disabled], .disabled, [aria-hidden=\"true\"]')) continue;
    var fc = parse(cs.color); if (!fc) { out.push({text: t.nodeValue.trim().slice(0, 40), sel: el.tagName.toLowerCase(), fg: cs.color, bg: 'unread', ratio: 0, need: 0}); continue; }
    var b = back(el), fg = over(fc, b), L1 = lum(fg), L2 = lum(b);
    var ratio = (Math.max(L1, L2) + 0.05) / (Math.min(L1, L2) + 0.05);
    var size = parseFloat(cs.fontSize), bold = parseInt(cs.fontWeight, 10) >= 700;
    var need = (size >= 24 || (bold && size >= 18.66)) ? 3 : 4.5;
    if (ratio + 1e-9 < need) out.push({text: t.nodeValue.trim().slice(0, 40),
      sel: el.tagName.toLowerCase() + (el.id ? '#' + el.id : '') +
        (typeof el.className === 'string' && el.className.trim() ? '.' + el.className.trim().split(/\\s+/).join('.') : ''),
      fg: cs.color, bg: 'rgb(' + Math.round(b.r) + ', ' + Math.round(b.g) + ', ' + Math.round(b.b) + ')',
      ratio: Math.round(ratio * 100) / 100, need: need});
  }
  return JSON.stringify(out);
})(%s)"

ui1_contrast <- function(b, doc = "document") {
  out <- jsonlite::fromJSON(ui2_js(b, sprintf(ui1_contrast_js, doc)))
  if (!length(out)) data.frame() else as.data.frame(out)
}
