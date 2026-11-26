# pkgdown/build_method_chooser.R
# Writes the method chooser charts as static SVG from
# pkgdown/method_chooser/chooser.js:
#   .github/readme/method-chooser-difference.svg   (README, 1 chart)
#   pkgdown/assets/docs/methods/choose-<chart>.svg (Docs page, 4 charts)
# The README and GitHub cannot run JavaScript, so the charts are drawn once in
# headless Chrome and saved with every colour and font as an attribute.
#
# Before writing, every method ID in the charts must be an arm of the method
# switch() in R/analysis_plan.R, so a renamed or removed method stops the
# build. After writing, no text may cross its box, checked with the build
# fonts and again with DejaVu Sans, which is wider than Segoe UI and stands in
# for a viewer's font.
#
# Run from the repository root:  Rscript pkgdown/build_method_chooser.R

stopifnot(requireNamespace("chromote", quietly = TRUE),
          requireNamespace("jsonlite", quietly = TRUE),
          file.exists("DESCRIPTION"))

page <- normalizePath(file.path("pkgdown", "method_chooser", "chooser.html"))

# The plan's methods: the arm names of the switch() that runs a plan block.
src <- readLines(file.path("R", "analysis_plan.R"))
arms <- unique(sub("^\\s+([a-z_]+)\\s+=.*$", "\\1",
                   grep("^\\s+[a-z_]+\\s+=\\s+(sframe_|\\{|,)", src, value = TRUE)))

b <- chromote::ChromoteSession$new(width = 1400, height = 1000)
on.exit(b$close(), add = TRUE)
js <- function(code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
invisible(b$Page$navigate(paste0("file://", page, "?build")))
for (i in 1:100) {
  if (isTRUE(tryCatch(js("typeof chooserSvg === 'function'"), error = function(e) FALSE))) break
  Sys.sleep(0.1)
}
stopifnot(isTRUE(js("typeof chooserSvg === 'function'")))

ids <- unlist(js("chooserRunIds()"))
unknown <- setdiff(ids, arms)
if (length(unknown)) {
  stop("Not a plan method in R/analysis_plan.R: ", paste(unknown, collapse = ", "),
       ". Update pkgdown/method_chooser/chooser.js.", call. = FALSE)
}

out <- list(
  list(chart = "difference", geom = "compact",
       file = file.path(".github", "readme", "method-chooser-difference.svg"))
)
for (k in unlist(js("chooserCharts"))) {
  out[[length(out) + 1]] <- list(chart = k, geom = "compact",
    file = file.path("pkgdown", "assets", "docs", "methods", paste0("choose-", k, ".svg")))
}

wide <- list(sans = "DejaVu Sans", mono = "DejaVu Sans Mono")
problems <- character(0)
for (o in out) {
  svg <- js(sprintf("chooserSvg(%s, %s)", jsonlite::toJSON(o$chart, auto_unbox = TRUE),
                    jsonlite::toJSON(o$geom, auto_unbox = TRUE)))
  call <- function(font) sprintf("chooserOverflow(%s, %s)", jsonlite::toJSON(svg, auto_unbox = TRUE),
                                 if (is.null(font)) "null" else jsonlite::toJSON(font, auto_unbox = TRUE))
  bad <- c(unlist(js(call(NULL))), paste("(DejaVu)", unlist(js(call(wide)))))
  bad <- bad[!grepl("^\\(DejaVu\\) $", bad)]
  if (length(bad)) problems <- c(problems, paste0(o$file, ": ", bad))
  dir.create(dirname(o$file), recursive = TRUE, showWarnings = FALSE)
  writeLines(paste0('<?xml version="1.0" encoding="UTF-8"?>\n', svg), o$file, useBytes = TRUE)
  w <- regmatches(svg, regexpr('width="[0-9]+"', svg))
  cat(sprintf("Wrote %s (%s)\n", o$file, w))
}
if (length(problems)) stop("Text crosses its box:\n", paste(problems, collapse = "\n"), call. = FALSE)
cat("All", length(ids), "method IDs are plan methods, and no text crosses its box.\n")
