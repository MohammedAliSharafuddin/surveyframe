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

# Column names whose values cannot exceed 1, matched without case.
.sframe_apa_bounded_cols <- c(
  "r", "r_s", "rs", "rho", "tau", "phi", "cramer_v", "cramers_v", "cramer's v",
  "r2", "r_squared", "r.squared", "adj_r2", "adj.r.squared", "eta2", "eta_sq",
  "partial_eta2", "omega2", "alpha", "omega", "cronbach_alpha"
)

.sframe_apa_p_col_re <- "^p$|^p\\.value$|^p_value$|^Pr\\(>|^p[._ ]adj"

# A p value for a table cell: 3 decimals with no leading zero, <.001 below
# that, blank when missing.
sframe_p_cell <- function(p) {
  s <- sub("^0\\.", ".", formatC(p, digits = 3, format = "f"))
  ifelse(is.na(p), "", ifelse(p < .001, "<.001", s))
}

# A numeric column as text: whole numbers as they are, others to `digits`
# decimals, the leading zero dropped where the column cannot exceed 1, and a
# missing value left blank.
sframe_apa_number <- function(v, digits = 2, bounded = FALSE) {
  whole <- all(is.na(v) | !is.finite(v) | v == round(v))
  s <- if (whole) format(v, scientific = FALSE, trim = TRUE)
       else formatC(v, digits = digits, format = "f")
  if (bounded) s <- sub("^(-?)0\\.", "\\1.", s)
  s[is.na(v)] <- ""
  s
}

#' Format a result table's cells as an APA 7 report prints them
#'
#' The cells of a table from [run_analysis_plan()] as both report engines and
#' [render_result()] print them, so a table shows the same numbers wherever it
#' appears. A p value column shows 3 decimals with no leading zero, or
#' `<.001`. A column that cannot exceed 1, such as `r`, `tau` or `alpha`, drops
#' its leading zero. Other numbers show 2 decimals, whole numbers none. A
#' missing value is a blank cell.
#'
#' This is exported because the Quarto report template runs in a separate R
#' session against the installed package.
#'
#' @param x A data frame, such as a result's `table`.
#' @param digits Decimals for numbers other than p values.
#'
#' @return A data frame of character columns with the same names.
#' @export
#' @keywords internal
#' @seealso [render_results()], [render_report()]
#'
#' @examples
#' sframe_apa_cells(data.frame(t = 2.345, p = 0.004, r = 0.53, n = 40L))
sframe_apa_cells <- function(x, digits = 2) {
  if (!is.data.frame(x)) return(x)
  nm <- colnames(x)
  p_col <- grepl(.sframe_apa_p_col_re, nm, ignore.case = TRUE)
  bounded <- tolower(nm) %in% .sframe_apa_bounded_cols | grepl("_pct$", nm)
  for (j in seq_along(x)) {
    v <- x[[j]]
    x[[j]] <- if (is.numeric(v)) {
      if (p_col[j]) sframe_p_cell(v) else sframe_apa_number(v, digits, bounded[j])
    } else {
      v <- as.character(v)
      v[is.na(v) | v == "NA"] <- ""
      v
    }
  }
  x
}

# Result text as HTML: escaped, Latin statistical symbols in italics, r_s and
# d_z with subscripts, tau and phi as Greek letters, chi-square as its symbol
# (CX-24). A symbol is marked only where a value follows it, so words in the
# sentence are left alone.
sframe_apa_html <- function(x) {
  if (length(x) == 0) return(character(0))
  x <- vapply(as.character(x), htmltools_escape, character(1), USE.NAMES = FALSE)
  follows <- "(?=(\\([^()]*\\))? (=|&lt;|&gt;) )"
  before <- "(?<![A-Za-z_>])"
  x <- gsub("chi-square(?=\\()", "\u03c7\u00b2", x, perl = TRUE)
  x <- gsub(paste0(before, "tau", follows), "\u03c4", x, perl = TRUE)
  x <- gsub(paste0(before, "phi", follows), "\u03c6", x, perl = TRUE)
  x <- gsub("Cramer's V", "Cram\u00e9r's V", x, fixed = TRUE)
  x <- gsub(paste0(before, "(r|d)_([a-z])", follows),
            "<em>\\1</em><sub>\\2</sub>", x, perl = TRUE)
  x <- gsub(paste0(before, "R(?=\u00b2", substring(follows, 4)),
            "<em>R</em>", x, perl = TRUE)
  gsub(paste0(before, "(SD|SE|t|F|p|r|d|U|V|W|H|z|M|N|n|Q|b|k)", follows),
       "<em>\\1</em>", x, perl = TRUE)
}

# Table headings that are statistical symbols, set as APA 7 sets them. A
# heading looked up here is HTML already.
.sframe_apa_heading_map <- c(
  p = "<em>p</em>", p.value = "<em>p</em>", p_value = "<em>p</em>",
  t = "<em>t</em>", F = "<em>F</em>", z = "<em>z</em>", U = "<em>U</em>",
  V = "<em>V</em>", W = "<em>W</em>", H = "<em>H</em>", Q = "<em>Q</em>",
  n = "<em>n</em>", N = "<em>N</em>", M = "<em>M</em>", SD = "<em>SD</em>",
  sd = "<em>SD</em>", SE = "<em>SE</em>", se = "<em>SE</em>",
  std.error = "<em>SE</em>", std_error = "<em>SE</em>", df = "<em>df</em>",
  r = "<em>r</em>", d = "<em>d</em>", b = "<em>b</em>",
  r_s = "<em>r</em><sub>s</sub>", d_z = "<em>d</em><sub>z</sub>",
  tau = "\u03c4", phi = "\u03c6", eta2 = "\u03b7\u00b2",
  partial_eta2 = "Partial \u03b7\u00b2", R2 = "<em>R</em>\u00b2",
  r2 = "<em>R</em>\u00b2", r_squared = "<em>R</em>\u00b2",
  adj_r2 = "Adjusted <em>R</em>\u00b2", OR = "<em>OR</em>",
  odds_ratio = "<em>OR</em>"
)

# Column names as table headings in HTML: symbols from the map above, a p
# column by its meaning, a `_pct` column (a proportion) named as one, and
# anything else in words with its first letter capitalised.
sframe_apa_headings <- function(names) {
  vapply(names, function(nm) {
    if (is.na(nm)) return("")
    if (nm %in% names(.sframe_apa_heading_map)) return(.sframe_apa_heading_map[[nm]])
    if (grepl(.sframe_apa_p_col_re, nm, ignore.case = TRUE)) return("<em>p</em>")
    if (grepl("_pct$", nm)) nm <- paste(sub("_pct$", "", nm), "(proportion)")
    htmltools_escape(.sframe_title_case_names(nm))
  }, character(1), USE.NAMES = FALSE)
}

# Tables and figures (CX-22). A renderer marks each table caption and figure
# caption with class "sf-apa-caption" and an already escaped title. Once the
# document is assembled, sframe_apa_number_floats() numbers them in reading
# order as APA 7 does: the number in bold, the title in italics on the line
# below, tables and figures counted apart.
sframe_apa_caption <- function(title) {
  sprintf("<caption class=\"sf-apa-caption\">%s</caption>", htmltools_escape(title))
}

sframe_apa_figure <- function(img, title) {
  if (is.null(img) || !nzchar(img)) return(img)
  sprintf(
    "<figure class=\"sf-figure\"><figcaption class=\"sf-apa-caption\">%s</figcaption>%s</figure>",
    htmltools_escape(title), img)
}

# A result's table and figure title: its block id and research question.
sframe_result_float_title <- function(result, i = NULL) {
  block_id <- as.character(result$block_id %||% "")[1]
  rq <- as.character(result$research_question %||% "")[1]
  title <- paste(c(if (nzchar(block_id)) block_id, if (nzchar(rq)) rq), collapse = ": ")
  if (nzchar(title)) title else paste("Research question", i %||% "")
}

sframe_apa_number_floats <- function(html) {
  html <- paste(html, collapse = "\n")
  re <- "<(caption|figcaption) class=\"sf-apa-caption\">"
  m <- gregexpr(re, html)
  hits <- regmatches(html, m)[[1]]
  if (!length(hits)) return(html)
  is_table <- startsWith(hits, "<caption")
  num <- ifelse(is_table, cumsum(is_table), cumsum(!is_table))
  label <- ifelse(is_table, "Table", "Figure")
  regmatches(html, m) <- list(sprintf("%s<strong>%s %d</strong><br><em>",
                                      hits, label, num))
  # Close the italic title before each marked caption's end tag.
  gsub("(<(caption|figcaption) class=\"sf-apa-caption\"><strong>[^<]*</strong><br><em>[^<]*)</(caption|figcaption)>",
       "\\1</em></\\3>", html)
}
