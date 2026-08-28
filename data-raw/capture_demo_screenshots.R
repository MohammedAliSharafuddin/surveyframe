# data-raw/capture_demo_screenshots.R
# Captures the screenshots the learn-by-example vignette embeds, into
# vignettes/figures/.
#
# Generated, never hand-captured, so they stay true to what the package
# renders today. Everything here is dev-only: the vignette itself builds with
# no browser and no network, reading the committed PNGs.
#
# Run from the repository root:
#   Rscript data-raw/capture_demo_screenshots.R
#
# Budget. The tarball has to stay well inside CRAN's practical 5 MB, so each
# shot is captured at a fixed 900 px viewport, resized to 760 px and quantised.
# The target is about 40 KB each. The script prints the running total, so an
# overrun is visible while it happens rather than at R CMD build.

devtools::load_all(quiet = TRUE)
stopifnot(requireNamespace("chromote", quietly = TRUE))

fig_dir <- file.path("vignettes", "figures")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

VIEW_W <- 900L
OUT_W  <- 760L

#' Shrink and quantise a PNG in place, so the vignette stays small.
shrink <- function(path, width = OUT_W) {
  if (nzchar(Sys.which("convert"))) {
    # 256 colours is visually lossless on a flat interface screenshot and
    # cuts each file to about a third, which is what keeps 22 captures inside
    # the tarball budget.
    system2("convert", c(shQuote(path), "-resize", paste0(width, "x"),
                         "-colors", "256", "-strip", shQuote(path)),
            stdout = FALSE, stderr = FALSE)
  }
  if (nzchar(Sys.which("optipng"))) {
    system2("optipng", c("-quiet", "-o2", shQuote(path)),
            stdout = FALSE, stderr = FALSE)
  }
  invisible(path)
}

#' Open a local HTML file and photograph it.
#'
#' Waits on document.readyState rather than Page.loadEventFired, which fires
#' before the handler is attached for a local file and then never arrives.
shoot <- function(html, out, height = 900L, click = NULL, settle = 0.6) {
  b <- chromote::ChromoteSession$new(width = VIEW_W, height = height)
  on.exit(try(b$close(), silent = TRUE), add = TRUE)
  b$Page$navigate(paste0("file://", normalizePath(html)))
  for (i in 1:60) {
    st <- tryCatch(b$Runtime$evaluate("document.readyState",
                                      returnByValue = TRUE)$result$value,
                   error = function(e) NA)
    if (identical(st, "complete")) break
    Sys.sleep(0.2)
  }
  if (!is.null(click)) {
    b$Runtime$evaluate(click)
    Sys.sleep(settle)
  }
  Sys.sleep(settle)
  b$screenshot(filename = out)
  shrink(out)
  invisible(out)
}

# Every exported survey opens on a landing page, so a capture taken without
# a click shows a Start button and nothing else. Reading the first run back
# showed 17 screenshots of exactly that, which teaches nobody the difference
# between a matrix and a Likert item.
#
# The branded demos also require consent, and pressing Start without ticking
# it produces "Please confirm your consent before continuing", which is the
# consent gate working and still the wrong screenshot.
start_click <- paste0(
  "(function(){",
  "var c=document.querySelector('input[type=checkbox]');",
  "if(c && !c.checked){c.click();}",
  "var b=Array.from(document.querySelectorAll('button'))",
  "  .find(function(x){return /start/i.test(x.textContent);});",
  "if(b)b.click(); return true;})()")

total_kb <- 0
record <- function(path, what) {
  kb <- round(file.size(path) / 1024)
  total_kb <<- total_kb + kb
  cat(sprintf("  %-42s %4d KB   (running total %4d KB)\n",
              basename(path), kb, total_kb))
}

# ---------------------------------------------------------------------------
# 1. One survey shot per demo section
# ---------------------------------------------------------------------------
# The 17 analysis demos. The presentation and provenance demos are covered by
# the dedicated shots below, which show the same instrument.

analysis_demos <- subset(sframe_demos(), focus == "analysis")$name

cat("Survey screenshots, 1 per analysis demo\n")
for (nm in analysis_demos) {
  d <- sframe_demo(nm)
  html <- tempfile(fileext = ".html")
  suppressMessages(export_static_survey(d$instrument, output_path = html,
                                        open = FALSE, overwrite = TRUE))
  out <- file.path(fig_dir, paste0("survey-", gsub("_", "-", nm), ".png"))
  shoot(html, out, click = start_click)
  record(out, nm)
}

# ---------------------------------------------------------------------------
# 2. Presentation: plain against branded, and the pages a respondent meets
# ---------------------------------------------------------------------------
cat("\nPresentation screenshots\n")

plain <- sframe_demo("first_survey")
html_plain <- tempfile(fileext = ".html")
suppressMessages(export_static_survey(plain$instrument, output_path = html_plain,
                                      open = FALSE, overwrite = TRUE))
shoot(html_plain, file.path(fig_dir, "presentation-plain.png"),
      click = start_click)
record(file.path(fig_dir, "presentation-plain.png"), "plain")

branded <- sframe_demo("branded_survey")
html_brand <- tempfile(fileext = ".html")
suppressMessages(export_static_survey(branded$instrument, output_path = html_brand,
                                      open = FALSE, overwrite = TRUE))
# The welcome page is what a respondent meets first.
shoot(html_brand, file.path(fig_dir, "presentation-welcome.png"))
record(file.path(fig_dir, "presentation-welcome.png"), "welcome")
# Then the questions, once they have started.
shoot(html_brand, file.path(fig_dir, "presentation-branded.png"), click = start_click)
record(file.path(fig_dir, "presentation-branded.png"), "branded")

conv <- sframe_demo("conversational_survey")
html_conv <- tempfile(fileext = ".html")
suppressMessages(export_static_survey(conv$instrument, output_path = html_conv,
                                      open = FALSE, overwrite = TRUE))
shoot(html_conv, file.path(fig_dir, "presentation-conversational.png"),
      click = start_click)
record(file.path(fig_dir, "presentation-conversational.png"), "conversational")

# Conversational mode combined with a skip rule, which is the combination most
# likely to surprise and has no other coverage.
convbr <- sframe_demo("conversational_branching")
html_cb <- tempfile(fileext = ".html")
suppressMessages(export_static_survey(convbr$instrument, output_path = html_cb,
                                      open = FALSE, overwrite = TRUE))
shoot(html_cb, file.path(fig_dir, "presentation-conversational-branching.png"),
      click = start_click)
record(file.path(fig_dir, "presentation-conversational-branching.png"), "conv+branch")

cat(sprintf("\nTotal: %d KB in %s\n", total_kb, fig_dir))
