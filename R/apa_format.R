# R/apa_format.R
#
# One APA layer (CX-15, CX-22, CX-24, D9). Each renderer used to format
# result text, table cells and headings on its own, so the built-in engine,
# render_results() and sframe_format_result() disagreed with each other and with
# APA 7. Everything a report shows of a statistic goes through here.

# Statistics that cannot exceed 1 in absolute value. APA 7 writes these, and
# their intervals, with no leading zero: r = .53, 95% CI [.33, .69].
.sframe_apa_bounded_symbols <- c(
  "p", "r", "r_s", "partial r", "R\u00b2", "McFadden R\u00b2",
  "tau", "\u03c4", "phi", "\u03c6", "Cramer's V", "Cram\u00e9r's V",
  "\u03b7\u00b2", "partial \u03b7\u00b2", "\u03c9\u00b2", "\u03b1", "\u03c9",
  "Kendall's W",
  # Cramer's V as the chi-square runner writes it (FR-32). The Wilcoxon
  # signed-rank V is a rank sum printed with no decimals, so it never holds
  # the "0." this drops.
  "V"
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
  # A value that rounds to 0 is 0.00, never -0.00 (FR-32).
  y <- gsub("(?<![0-9.])-((?:0)?\\.0+|0)(?![0-9.])", "\\1", y, perl = TRUE)
  x[ok] <- y
  x
}

# Column names whose values cannot exceed 1, matched without case.
.sframe_apa_bounded_cols <- c(
  "r", "r_s", "rs", "rho", "tau", "phi", "cramer_v", "cramers_v", "cramer's v",
  "r2", "r_squared", "r.squared", "adj_r2", "adj.r.squared", "eta2", "eta_sq",
  "partial_eta2", "omega2", "alpha", "omega", "cronbach_alpha"
)

# floor_pct, ceiling_pct and missing_pct were renamed _prop in 0.4.3 and kept
# for 1 release. A table shows the _prop column alone.
sframe_drop_old_share_cols <- function(x) {
  old <- c("floor_pct", "ceiling_pct", "missing_pct")
  twin <- c("floor_prop", "ceiling_prop", "missing_prop")
  drop <- old[old %in% names(x) & twin %in% names(x)]
  if (length(drop)) x <- x[, setdiff(names(x), drop), drop = FALSE]
  x
}

# Columns of counts, whose whole values print with no decimals, and percent
# columns, whose whole values did so before and which Codex P1-01 settled as
# "100".
.sframe_apa_count_col_re <- paste0(
  "^(n|n[ _]?[0-9]|df|df[0-9]|frequency|count|k|items|rank|row|",
  "respondents|cases|.*_n|n_.*|.*[ _]count|weighted_frequency|",
  "percent|pct|.*_percent|.*_pct)$")

.sframe_apa_p_col_re <- "^p$|^p\\.value$|^p_value$|^Pr\\(>|^p[._ ]adj"

# A p value for a table cell: 3 decimals with no leading zero, <.001 below
# that, blank when missing.
sframe_p_cell <- function(p) {
  s <- vapply(p, function(v) if (is.na(v)) "" else sframe_p_digits(v), character(1))
  ifelse(is.na(p), "", ifelse(p < .001, "<.001", ifelse(p > .999, ">.999", s)))
}

# A numeric column as text: whole numbers as they are, others to `digits`
# decimals, the leading zero dropped where the column cannot exceed 1, and a
# missing value left blank.
sframe_apa_number <- function(v, digits = 2, bounded = FALSE, count = NULL) {
  # Whole numbers print with no decimals only in a column of counts: an
  # integer column or one named as a count. F values of 4 and 9 printed as
  # "4" and "9", and the same column with 1 fractional value as "4.00"
  # (FR-32).
  if (is.null(count)) count <- is.integer(v)
  whole <- count && all(is.na(v) | !is.finite(v) | v == round(v))
  s <- if (whole) format(v, scientific = FALSE, trim = TRUE)
       else formatC(v, digits = digits, format = "f")
  s <- sub("^-(0\\.0+)$", "\\1", s)
  if (bounded) s <- sub("^(-?)0\\.", "\\1.", s)
  s[is.na(v)] <- ""
  s
}

#' Format a result table's cells as an APA 7 report prints them
#'
#' The cells of a table from [run_analysis_plan()] as both report engines and
#' [sframe_format_result()] print them, so a table shows the same numbers wherever it
#' appears. A p value column shows 3 decimals with no leading zero, or
#' `<.001`. A column that cannot exceed 1, such as `r`, `tau` or `alpha`, drops
#' its leading zero. Other numbers show 2 decimals, and whole numbers in an
#' integer column, a column of counts (n, df, Frequency) or a percent column
#' none. A p value
#' above .999 shows `>.999`. A missing value is a blank cell.
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
#' @family SurveyStudio helpers
sframe_apa_cells <- function(x, digits = 2) {
  if (!is.data.frame(x)) return(x)
  x <- sframe_drop_old_share_cols(x)
  nm <- colnames(x)
  p_col <- grepl(.sframe_apa_p_col_re, nm, ignore.case = TRUE)
  bounded <- tolower(nm) %in% .sframe_apa_bounded_cols | grepl("_prop$", nm)
  count_col <- grepl(.sframe_apa_count_col_re, nm, ignore.case = TRUE)
  for (j in seq_along(x)) {
    v <- x[[j]]
    x[[j]] <- if (is.numeric(v)) {
      if (p_col[j]) sframe_p_cell(v) else sframe_apa_number(v, digits, bounded[j],
                                                           count = is.integer(v) || count_col[j])
    } else {
      v <- as.character(v)
      v[is.na(v) | v == "NA"] <- ""
      v
    }
  }
  x
}

#' @rdname sframe_apa_cells
#' @param names Column names.
#' @param format `"html"` for HTML headings, `"markdown"` for the pipe tables
#'   of Word, OpenDocument and PDF reports.
#' @param conf_level The confidence level a `ci_low` or `ci_high` heading
#'   states.
#' @details `sframe_apa_col_labels()` gives the headings both report engines
#'   print for a table's columns: words for a column such as `valid_n`
#'   ("Valid *n*"), statistic symbols in italics (*M*, *SD*, *Mdn*, *SE*) and
#'   the confidence level in an interval heading ("95% CI lower").
#' @export
sframe_apa_col_labels <- function(names, format = c("html", "markdown"),
                                  conf_level = 0.95) {
  format <- match.arg(format)
  html <- sframe_apa_headings(as.character(names), conf_level)
  if (format == "html") return(html)
  sframe_html_heading_md(html)
}

# An HTML heading as Markdown: italics between asterisks, a subscript
# between tildes, entities decoded.
sframe_html_heading_md <- function(x) {
  x <- gsub("<em>([^<]*)</em>", "*\\1*", x)
  x <- gsub("<sub>([^<]*)</sub>", "~\\1~", x)
  x <- gsub("<[^>]+>", "", x)
  x <- gsub("&lt;", "<", x, fixed = TRUE)
  x <- gsub("&gt;", ">", x, fixed = TRUE)
  x <- gsub("&quot;", "\"", x, fixed = TRUE)
  x <- gsub("&#39;", "'", x, fixed = TRUE)
  gsub("&amp;", "&", x, fixed = TRUE)
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

# Headings in words for the descriptive and missing-data columns, the same
# in every report engine and format (Codex P1-03). A statistic symbol is
# between asterisks, set in italics. "{level}" is the confidence level.
.sframe_apa_label_map <- c(
  variable = "Variable", group = "Group", valid_n = "Valid *n*",
  missing_n = "Missing *n*", missing_prop = "Missing proportion",
  mean = "*M*", Mean = "*M*", median = "*Mdn*", Median = "*Mdn*", iqr = "IQR",
  min = "Min", max = "Max",
  skewness = "Skewness", kurtosis = "Kurtosis",
  ci_low = "{level}% CI lower", ci_high = "{level}% CI upper",
  weighted_mean = "Weighted *M*", row = "Respondent",
  description = "Pattern", percent = "Percent", prop = "Proportion",
  scale_id = "Scale", n_items = "Items", min_valid = "Minimum valid items",
  missing_rule = "Missing rule"
)

# A heading from the label map as HTML.
sframe_apa_label_html <- function(label, conf_level = 0.95) {
  label <- gsub("{level}", sframe_conf_level_text(conf_level), label, fixed = TRUE)
  gsub("\\*([^*]+)\\*", "<em>\\1</em>", htmltools_escape(label))
}

sframe_conf_level_text <- function(conf_level) {
  format(round(100 * as.numeric(conf_level)[1], 1), trim = TRUE)
}

# Column names as table headings in HTML: the label map, symbols from the
# map above, a p column by its meaning, and anything else in words with its
# first letter capitalised.
sframe_apa_headings <- function(names, conf_level = 0.95) {
  vapply(names, function(nm) {
    if (is.na(nm)) return("")
    if (nm %in% names(.sframe_apa_label_map)) {
      return(sframe_apa_label_html(.sframe_apa_label_map[[nm]], conf_level))
    }
    if (nm %in% names(.sframe_apa_heading_map)) return(.sframe_apa_heading_map[[nm]])
    if (grepl(.sframe_apa_p_col_re, nm, ignore.case = TRUE)) return("<em>p</em>")
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

# The opening of a figure in the Quarto report. knitr writes the image
# between this and a closing </figure>, and sframe_quarto_apa_floats() gives
# the image the alt text kept in data-alt.
sframe_apa_figure_open <- function(title, alt) {
  sprintf(
    "<figure class=\"sf-figure\" data-alt=\"%s\"><figcaption class=\"sf-apa-caption\">%s</figcaption>",
    htmltools_escape(alt), htmltools_escape(title))
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

# The Quarto report (CX-22). knitr writes a table's caption as a plain
# <caption>, and the template wraps each chart in a marked figure carrying its
# alt text in data-alt, since knitr writes the image with none. Every caption
# is a numbered table title, and each marked figure's image takes its alt text.
sframe_quarto_apa_floats <- function(html) {
  html <- paste(html, collapse = "\n")
  html <- gsub("(?s)<caption>\\s*(.*?)\\s*</caption>",
               "<caption class=\"sf-apa-caption\">\\1</caption>", html, perl = TRUE)
  # pandoc sets a figure title on lines of its own.
  html <- gsub("(?s)(<figcaption class=\"sf-apa-caption\">)\\s*(.*?)\\s*</figcaption>",
               "\\1\\2</figcaption>", html, perl = TRUE)
  # Quarto adds its own classes after sf-figure.
  html <- gsub(
    "(?s)(<figure class=\"sf-figure[^\"]*\" data-alt=\"([^\"]*)\">(?:(?!<img |</figure>).)*?)<img (?![^>]*\\balt=)",
    "\\1<img alt=\"\\2\" ", html, perl = TRUE)
  sframe_apa_number_floats(html)
}
