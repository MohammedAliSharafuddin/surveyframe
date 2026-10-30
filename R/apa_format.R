# R/apa_format.R
#
# One APA layer (CX-15, CX-22, CX-24, D9). Each renderer used to format
# result text, table cells and headings on its own, so the built-in engine,
# render_results() and render_result() disagreed with each other and with
# APA 7. Everything a report shows of a statistic goes through here.

# Statistics that cannot exceed 1 in absolute value. APA 7 writes these, and
# their intervals, with no leading zero: r = .53, 95% CI [.33, .69].
.sframe_apa_bounded_symbols <- c(
  "p", "r", "r_s", "partial r", "R\u00b2", "McFadden R\u00b2",
  "tau", "\u03c4", "phi", "\u03c6", "Cramer's V", "Cram\u00e9r's V",
  "\u03b7\u00b2", "partial \u03b7\u00b2", "\u03c9\u00b2", "\u03b1", "\u03c9",
  "Kendall's W"
)

.sframe_apa_bounded_re <- local({
  syms <- .sframe_apa_bounded_symbols[order(-nchar(.sframe_apa_bounded_symbols))]
  syms <- gsub("([.()'])", "\\\\\\1", syms)
  paste0("(?<![A-Za-z_])(", paste(syms, collapse = "|"), ")",
         "(\\([^()]*\\))? [=<>] -?[0-9.]+",
         "(, [0-9]+% CI \\[-?[0-9.]+, -?[0-9.]+\\])?")
})

# Result text with the leading zero dropped from every bounded statistic and
# its interval. Other values, such as d, t, z or a mean, keep theirs.
sframe_apa_text <- function(x) {
  if (!is.character(x) || length(x) == 0) return(x)
  ok <- !is.na(x)
  m <- gregexpr(.sframe_apa_bounded_re, x[ok], perl = TRUE)
  y <- x[ok]
  regmatches(y, m) <- lapply(regmatches(y, m), function(s) {
    gsub("(?<![0-9.])0\\.(?=[0-9])", ".", s, perl = TRUE)
  })
  x[ok] <- y
  x
}
