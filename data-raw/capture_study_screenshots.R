# data-raw/capture_study_screenshots.R
# The SurveyStudio screenshots of the 5 stages for each of the 10 study pages
# (Session 10, plan: demos and website redesign): design, collect, check,
# analyse and report, into pkgdown/assets/templates/<demo>/. Site only:
# pkgdown/ is in .Rbuildignore, so the tarball does not grow. Generated,
# never hand-captured, so they show what the package draws today.
#
# Run from the repository root:  Rscript data-raw/capture_study_screenshots.R [demo ...]

pkg_root <- normalizePath(".")
devtools::load_all(pkg_root, quiet = TRUE)
stopifnot(requireNamespace("chromote", quietly = TRUE),
          requireNamespace("callr", quietly = TRUE))

VIEW_W <- 1280L
VIEW_H <- 800L
OUT_W <- 1000L

# The demo behind each study page, as the plan's use-case table lists them.
study_demos <- c("likert_scale", "small_sample", "matrix_likert", "paired",
                 "logistic", "factor_structure", "mcdm_choice", "open_text",
                 "verification", "sem_pls")
# The 5 stages and the Studio screen each is shown on.
stages <- c(design = "design", collect = "collect", check = "quality",
            analyse = "analysis", report = "export")

args <- commandArgs(TRUE)
if (length(args)) study_demos <- intersect(args, study_demos)

shrink <- function(path) {
  system2("convert", c(shQuote(path), "-resize", paste0(OUT_W, "x"),
                       "-colors", "256", "-strip", shQuote(path)),
          stdout = FALSE, stderr = FALSE)
  if (nzchar(Sys.which("optipng"))) {
    system2("optipng", c("-quiet", "-o2", shQuote(path)), stdout = FALSE, stderr = FALSE)
  }
  cat(sprintf("  %-40s %4d KB\n", basename(path), round(file.size(path) / 1024)))
}
js <- function(b, code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
shiny_idle <- paste0("!!(window.Shiny && Shiny.shinyapp && Shiny.shinyapp.isConnected()) && ",
                     "!document.documentElement.classList.contains('shiny-busy')")
wait_stable <- function(b, secs = 240) {
  calm <- 0
  for (i in seq_len(secs * 2)) {
    calm <- if (isTRUE(tryCatch(js(b, shiny_idle), error = function(e) FALSE))) calm + 1 else 0
    if (calm >= 6) return(invisible(TRUE))
    Sys.sleep(0.5)
  }
  stop("SurveyStudio never settled.")
}

for (demo in study_demos) {
  cat(demo, "\n")
  out_dir <- file.path(pkg_root, "pkgdown", "assets", "templates", demo)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  port <- httpuv::randomPort()
  proc <- callr::r_bg(function(root, demo, port) {
    devtools::load_all(root, quiet = TRUE)
    launch_studio(demo = demo, screen = "design", port = port, launch.browser = FALSE)
  }, args = list(root = pkg_root, demo = demo, port = port))
  b <- chromote::ChromoteSession$new(width = VIEW_W, height = VIEW_H)
  url <- sprintf("http://127.0.0.1:%d", port)
  for (i in 1:150) {
    up <- tryCatch({ b$Page$navigate(url); TRUE }, error = function(e) FALSE)
    if (up && isTRUE(tryCatch(js(b, "!!window.Shiny"), error = function(e) FALSE))) break
    Sys.sleep(0.4)
  }
  wait_stable(b)
  for (stage in names(stages)) {
    js(b, sprintf("(function(){var a=document.querySelector('.studio-nav a[data-tab=\"%s\"]');if(a)a.click();return !!a;})()",
                  stages[[stage]]))
    Sys.sleep(1)
    wait_stable(b)
    Sys.sleep(2)
    out <- file.path(out_dir, paste0(stage, ".png"))
    # The site shows no result numbers (owner 2026-11-14), so Analyse is cut
    # off below its Declared plan card, above the first result.
    h <- VIEW_H
    if (identical(stage, "analyse")) {
      bottom <- js(b, paste0(
        "(function(){var hs=[].slice.call(document.querySelectorAll('h3,h4,h5,.card-title'));",
        "var t=hs.find(function(e){return /^Declared plan/.test(e.textContent.trim())&&e.offsetParent;});",
        "if(!t)return 0;var c=t.closest('.card,.well,section,.sf-card')||t.parentElement;",
        "return Math.ceil(c.getBoundingClientRect().bottom)+16;})()"))
      if (is.numeric(bottom) && bottom > 100) h <- min(VIEW_H, as.integer(bottom))
    }
    b$screenshot(filename = out, cliprect = c(0, 0, VIEW_W, h))
    shrink(out)
  }
  try(b$close(), silent = TRUE)
  proc$kill_tree()
}
