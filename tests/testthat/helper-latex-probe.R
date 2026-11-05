# tests/testthat/helper-latex-probe.R
#
# A LaTeX engine can be on the PATH and still fail to typeset the report: the
# Ubuntu runners have Debian's TeX Live without the Latin Modern OpenType
# fonts, and Debian's tlmgr cannot fetch them. render_report() keeps its own
# error for that machine. The tests that need LaTeX skip instead, after the
# same engine Quarto runs fails a 1-line document in the report's font and
# size. Run once per test process.

latex_probe <- local({
  result <- NULL
  function() {
    if (!is.null(result)) return(result)
    engines <- Sys.which(c("lualatex", "xelatex"))
    engines <- engines[nzchar(engines)]
    # TinyTeX off the PATH, or pdflatex only: Quarto picks its own engine,
    # so there is nothing to probe and the test runs.
    if (!length(engines)) return(result <<- TRUE)
    dir <- tempfile("latex-probe-")
    dir.create(dir)
    on.exit(unlink(dir, recursive = TRUE, force = TRUE), add = TRUE)
    writeLines(c("\\documentclass[12pt]{article}", "\\usepackage{fontspec}",
                 "\\begin{document}x\\end{document}"), file.path(dir, "probe.tex"))
    status <- suppressWarnings(system2(
      engines[[1]],
      c("-interaction=batchmode", "-halt-on-error", paste0("-output-directory=", shQuote(dir)),
        shQuote(file.path(dir, "probe.tex"))),
      stdout = FALSE, stderr = FALSE, timeout = 120))
    result <<- identical(as.integer(status), 0L) && file.exists(file.path(dir, "probe.pdf"))
    result
  }
})

# Skip when LaTeX is found but cannot typeset the report's font.
skip_if_latex_broken <- function() {
  if (!surveyframe:::sframe_latex_available()) return(invisible())
  skip_if(!latex_probe(), "LaTeX is found but cannot load the report's font (lmroman12)")
}
