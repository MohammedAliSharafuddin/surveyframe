# R/field_markdown.R
#
# Markdown in free-text fields (owner 2026-11-04, 8b-R). The research
# question, H0, H1, decision rule, interpretation, study problem and an
# amendment's deviation report may hold Markdown: bold, italic, lists, links,
# [@key] citations, ~sub~, ^sup^, footnotes ^[...] and equations ($...$
# inline, $$...$$ display, by Pandoc's rule). The .sframe keeps the plain
# text. Each field is data: the Quarto template prints it with cat() in a
# results: asis chunk after knitr has run, so R code in a field never runs,
# and nothing from a field is written into a .qmd file.
#
# sframe_field_md() makes the text safe for both engines. Kept: the Markdown
# above. Neutralised, printed as typed: shortcodes {{< >}} (env and meta
# would print environment variables or metadata), raw blocks and inline raw
# ({=html}, {=latex}) and every other {...} attribute, ::: div fences,
# heading lines, a --- or ... line (Pandoc reads a YAML block anywhere in
# the body), HTML tags, and javascript: links. @word is a citation only for
# a key the report knows. Math and code spans are left as written.
#
# sframe_field_html() renders the safe text for the built-in engine with
# commonmark, converts sub, sup and footnotes in R, and prints each equation
# as its TeX in monospace, since the built-in page has no math library.

# Pandoc's rule for inline math: an opening $ has a non-space on its right,
# a closing $ a non-space on its left and no digit after it. So "costs $5
# and $10" stays prose and a lone "$x" is text.
sframe_md_math_pattern <- "(?s)\\$\\$.+?\\$\\$|\\$(?=[^\\s$])[^$\\n]*?(?<=[^\\s\\\\])\\$(?![0-9])"

sframe_md_protect <- function(text, pattern, tag) {
  m <- gregexpr(pattern, text, perl = TRUE)
  hits <- regmatches(text, m)[[1]]
  if (!length(hits)) return(list(text = text, hits = character(0)))
  keys <- sprintf("SFPROTECT%s%dZ", tag, seq_along(hits))
  regmatches(text, m)[[1]] <- keys
  list(text = text, hits = stats::setNames(hits, keys))
}

sframe_md_restore <- function(text, hits, wrap = identity) {
  for (k in rev(names(hits))) text <- gsub(k, wrap(hits[[k]]), text, fixed = TRUE)
  text
}

# The keys a field may cite: the instrument's references, any further ones
# the report is given, and the built-in method references.
sframe_md_keys <- function(instrument = NULL, references = NULL) {
  idx <- sframe_reference_index(instrument, references)
  unique(c(names(idx), names(.sframe_citation_csl)))
}

sframe_field_md <- function(text, keys = character(0)) {
  if (is.null(text) || !length(text) || is.na(text[1])) return("")
  text <- gsub("\r\n?", "\n", as.character(text[1]))
  if (!nzchar(trimws(text))) return("")
  math <- sframe_md_protect(text, sframe_md_math_pattern, "M")
  code <- sframe_md_protect(math$text, "(`+)[^`\n]+?\\1", "C")
  t <- code$text
  # Every brace: shortcodes, raw attributes, span and div attributes.
  t <- gsub("([{}])", "\\\\\\1", t)
  # Line starts: headings, div fences, YAML delimiters.
  t <- gsub("(?m)^([ \t]*)#", "\\1\\\\#", t, perl = TRUE)
  t <- gsub("(?m)^([ \t]*):", "\\1\\\\:", t, perl = TRUE)
  lines <- strsplit(t, "\n", fixed = TRUE)[[1]]
  yaml <- grepl("^[ \t]*(-{3,}|\\.{3})[ \t]*$", lines)
  lines[yaml] <- gsub("([-.])", "\\\\\\1", lines[yaml])
  t <- paste(lines, collapse = "\n")
  # HTML tags and comments.
  t <- gsub("<(?=[A-Za-z/!?])", "\\\\<", t, perl = TRUE)
  # javascript: links.
  t <- gsub("\\]\\((\\s*)javascript:", "]\\\\(\\1javascript:", t, ignore.case = TRUE)
  # @word is a citation only for a known key.
  m <- gregexpr("(?<![A-Za-z0-9_\\\\])@([A-Za-z0-9_](?:[A-Za-z0-9_:.#$%&+?<>~/-]*[A-Za-z0-9_])?)",
                t, perl = TRUE)
  hits <- regmatches(t, m)[[1]]
  if (length(hits)) {
    regmatches(t, m)[[1]] <- ifelse(substring(hits, 2) %in% keys, hits, paste0("\\", hits))
  }
  t <- sframe_md_restore(t, code$hits)
  sframe_md_restore(t, math$hits)
}

# One line for a heading: a research question.
sframe_field_md_line <- function(text, keys = character(0)) {
  gsub("\\s*\n\\s*", " ", sframe_field_md(text, keys))
}

# ~sub~ and ^sup^ in the text between tags, as Pandoc reads them: no spaces
# inside unless escaped.
sframe_md_subsup <- function(html) {
  parts <- strsplit(html, "(?=<)|(?<=>)", perl = TRUE)[[1]]
  text <- !grepl("^<", parts)
  parts[text] <- gsub("(?<!\\\\)~([^~\\s]+?)~", "<sub>\\1</sub>", parts[text], perl = TRUE)
  parts[text] <- gsub("(?<!\\\\)\\^([^\\^\\s]+?)\\^", "<sup>\\1</sup>", parts[text], perl = TRUE)
  paste(parts, collapse = "")
}

sframe_field_html <- function(text, keys = character(0), inline = FALSE) {
  md <- sframe_field_md(text, keys)
  if (!nzchar(md)) return("")
  math <- sframe_md_protect(md, sframe_md_math_pattern, "M")
  t <- math$text
  # A footnote reads as a parenthesis on the built-in page.
  t <- gsub("\\^\\[([^]]*)\\]", " (\\1)", t)
  html <- commonmark::markdown_html(t, extensions = FALSE)
  html <- sframe_md_subsup(html)
  html <- sframe_md_restore(html, math$hits, function(tex) {
    sprintf("<code class=\"sf-tex\">%s</code>", htmltools_escape(tex))
  })
  html <- trimws(html)
  if (isTRUE(inline)) html <- sub("^<p>(.*)</p>$", "\\1", html)
  html
}
