# pkgdown/studio_capture.R
# Captures SurveyStudio's Design screen for the Docs pages (owner 2026-11-15):
# the question-type editor shots (build_docs.R) and the method Plan cards
# (build_method_docs.R) are taken inside SurveyStudio, with its left menu and
# screen name in view, the way data-raw/capture_study_screenshots.R takes the
# 5 stage shots (Session 10). SurveyStudio runs in a background process and
# chromote drives the SurveyBuilder that its Design screen holds in an iframe.

stopifnot(requireNamespace("chromote", quietly = TRUE),
          requireNamespace("callr", quietly = TRUE))

STUDIO_W <- 1280L
STUDIO_H <- 800L

studio_js <- function(b, code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value

# Runs code inside the Design screen's SurveyBuilder iframe.
builder_js <- function(b, code) {
  studio_js(b, sprintf("(function(){var f=document.getElementById('design_frame');if(!f||!f.contentWindow)return null;return f.contentWindow.eval(%s);})()",
                       jsonlite::toJSON(code, auto_unbox = TRUE)))
}

studio_wait <- function(b, cond, secs = 240, frame = FALSE) {
  for (i in seq_len(secs * 5)) {
    ok <- tryCatch(if (frame) builder_js(b, cond) else studio_js(b, cond), error = function(e) FALSE)
    if (isTRUE(ok)) return(invisible(TRUE))
    Sys.sleep(0.2)
  }
  stop("Timed out waiting for: ", cond)
}

# Opens SurveyStudio on the Design screen with a demo, and returns the
# browser session and the background process.
studio_open <- function(pkg_root, demo, height = STUDIO_H) {
  port <- httpuv::randomPort()
  proc <- callr::r_bg(function(root, demo, port) {
    devtools::load_all(root, quiet = TRUE)
    launch_studio(demo = demo, screen = "design", port = port, launch.browser = FALSE)
  }, args = list(root = pkg_root, demo = demo, port = port))
  b <- chromote::ChromoteSession$new(width = STUDIO_W, height = height)
  url <- sprintf("http://127.0.0.1:%d", port)
  for (i in 1:150) {
    up <- tryCatch({ b$Page$navigate(url); TRUE }, error = function(e) FALSE)
    if (up && isTRUE(tryCatch(studio_js(b, "!!window.Shiny"), error = function(e) FALSE))) break
    Sys.sleep(0.4)
  }
  studio_wait(b, "typeof openInsp === 'function' && S.items.length > 0", frame = TRUE)
  # Toasts, such as the integrity message on opening, stay out of the shots.
  builder_js(b, "var st=document.createElement('style'); st.textContent='#toastR{display:none !important}'; document.head.appendChild(st); true")
  Sys.sleep(1)
  list(b = b, proc = proc)
}

studio_close <- function(s) {
  try(s$b$close(), silent = TRUE)
  try(s$proc$kill_tree(), silent = TRUE)
}

studio_shrink <- function(path, width = 1000L, colors = 256L) {
  system2("convert", c(shQuote(path), "-resize", shQuote(paste0(width, "x>")), "+dither", "-colors", as.character(colors), "-strip", shQuote(path)),
          stdout = FALSE, stderr = FALSE)
  if (nzchar(Sys.which("optipng"))) system2("optipng", c("-quiet", "-o2", shQuote(path)), stdout = FALSE, stderr = FALSE)
}

# Selects an item or page the way a click in the list does, which draws the
# centre preview and highlights the row, then waits for the preview to fill.
studio_select <- function(b, id, secs = 60) {
  builder_js(b, sprintf("selItem('%s'); true", id))
  studio_wait(b, paste0("(function(){var x=document.getElementById('cvPv');if(!x||!x.classList.contains('on'))return false;",
                        "var f=x.querySelector('iframe');if(!f||!f.contentDocument||!f.contentDocument.body)return false;",
                        "return f.contentDocument.body.innerText.trim().length>20;})()"), secs = secs, frame = TRUE)
}

# Outlines the settings panel, as the approved samples do.
studio_outline_panel <- function(b) {
  builder_js(b, "var i=document.getElementById('inspector'); if(i){i.style.outline='3px solid #d6336c'; i.style.outlineOffset='-3px';} true")
}

# Takes the keyboard focus off whatever holds it, such as a dialog's close
# button, so no focus ring shows in a shot. The app's focus style is untouched.
studio_blur <- function(b) {
  builder_js(b, "if(document.activeElement&&document.activeElement.blur)document.activeElement.blur(); true")
  studio_js(b, "if(document.activeElement&&document.activeElement.blur)document.activeElement.blur(); true")
}

# Opens the Plan screen from Studio's left menu.
studio_to_plan <- function(b) {
  studio_js(b, "(function(){var a=document.querySelector('.studio-nav a[data-nav=\"plan\"]');if(a)a.click();return !!a;})()")
  studio_wait(b, "document.body.getAttribute('data-mode')==='analyse'", secs = 60, frame = TRUE)
  Sys.sleep(2)
}
