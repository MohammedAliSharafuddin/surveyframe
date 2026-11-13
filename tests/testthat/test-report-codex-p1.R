# tests/testthat/test-report-codex-p1.R
#
# Codex pass 1 at af1f806, report findings P1-01 to P1-05 (Session RF,
# owner 2026-11-10). Every check uses the two_group demo, in the built-in
# engine and, on the slow tier, the Quarto engine.

p1_demo <- function() {
  d <- sframe_demo("two_group")
  list(instrument = d$instrument, data = d$responses)
}

p1_builtin_html <- function(...) {
  d <- p1_demo()
  f <- tempfile(fileext = ".html")
  surveyframe:::.render_report_html(d$instrument, d$data, output_path = f,
                                    include_analysis = FALSE, ...)
  paste(readLines(f, warn = FALSE), collapse = "\n")
}

p1_quarto_html <- function() {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  old <- options(surveyframe.use_quarto = TRUE)
  on.exit(options(old), add = TRUE)
  d <- p1_demo()
  out <- tempfile(fileext = ".html")
  res <- suppressMessages(render_report(d$instrument, data = d$data,
                                        output_file = out,
                                        include_analysis = FALSE, open = FALSE))
  expect_identical(attr(res, "engine"), "quarto")
  paste(readLines(out, warn = FALSE), collapse = "\n")
}

# A table of an HTML report, found by its caption: the heading cells and
# each body row's cells, as text.
p1_table <- function(doc, caption) {
  tables <- regmatches(doc, gregexpr("(?s)<table.*?</table>", doc, perl = TRUE))[[1]]
  hit <- tables[grepl(caption, tables, fixed = TRUE)]
  if (!length(hit)) return(NULL)
  cells_of <- function(row, tag) {
    m <- regmatches(row, gregexpr(sprintf("(?s)<%s[^>]*>.*?</%s>", tag, tag), row, perl = TRUE))[[1]]
    trimws(gsub("<[^>]+>", "", m))
  }
  rows <- regmatches(hit[1], gregexpr("(?s)<tr.*?</tr>", hit[1], perl = TRUE))[[1]]
  list(head = cells_of(rows[grepl("<th", rows)][1], "th"),
       body = lapply(rows[!grepl("<th", rows)], cells_of, tag = "td"))
}

# The valid and missing counts a table gives one item.
p1_counts <- function(doc, caption, item) {
  t <- p1_table(doc, caption)
  if (is.null(t)) return(NULL)
  row <- Filter(function(r) item %in% r, t$body)[[1]]
  valid <- grep("valid", t$head, ignore.case = TRUE)[1]
  missing <- grep("missing", t$head, ignore.case = TRUE)[1]
  c(valid = row[valid], missing = row[missing])
}

# The row of the missing-data patterns table: pattern, n and percent cells.
p1_complete_row <- function(doc) {
  m <- regmatches(doc, regexpr(
    "Complete case \\(no missing items\\)\\s*</td>\\s*<td[^>]*>[^<]*</td>\\s*<td[^>]*>[^<]*</td>",
    doc, perl = TRUE))
  if (!length(m)) return(character(0))
  cells <- regmatches(m, gregexpr("<td[^>]*>[^<]*</td>", m, perl = TRUE))[[1]]
  trimws(gsub("<[^>]+>", "", cells))
}

test_that("P1-01: missing-data patterns store a percentage and a proportion", {
  d <- p1_demo()
  mr <- sframe_missing_data_results(d$data, d$instrument)
  expect_true(all(c("percent", "prop") %in% names(mr$patterns)))
  expect_equal(sum(mr$patterns$percent), 100)
  expect_equal(sum(mr$patterns$prop), 1)
  expect_equal(mr$patterns$percent, mr$patterns$prop * 100)
})

test_that("P1-01: the built-in report prints Complete case | 60 | 100", {
  expect_identical(p1_complete_row(p1_builtin_html()), c("60", "100"))
})

test_that("P1-01: the Quarto report prints Complete case | 60 | 100", {
  expect_identical(p1_complete_row(p1_quarto_html()), c("60", "100"))
})

test_that("P1-02: descriptives count a categorical item's answers as valid", {
  d <- p1_demo()
  dr <- sframe_descriptives_results(d$data, variables = c("format", "sessions_attended"))
  fmt <- dr$table[dr$table$variable == "format", ]
  expect_identical(fmt$valid_n, 60L)
  expect_identical(fmt$missing_n, 0L)
  expect_true(is.na(fmt$mean) && is.na(fmt$sd) && is.na(fmt$ci_low))
  # A numeric item is unchanged.
  ses <- dr$table[dr$table$variable == "sessions_attended", ]
  expect_equal(ses$mean, mean(d$data$sessions_attended, na.rm = TRUE))
  # Text that reads as numbers is still summarised, and a blank is missing.
  dr2 <- sframe_descriptives_results(data.frame(x = c("1", "2", NA, "4")), "x")
  expect_identical(dr2$table$valid_n, 3L)
  expect_equal(dr2$table$mean, 7 / 3)
})

test_that("P1-02: the built-in report gives format 60 valid, 0 missing in both tables", {
  doc <- p1_builtin_html()
  expect_identical(p1_counts(doc, "Item-wise missingness", "format"),
                   c(valid = "60", missing = "0"))
  expect_identical(p1_counts(doc, "Descriptive statistics", "format"),
                   c(valid = "60", missing = "0"))
  expect_true(grepl("does not apply to an item answered with categories", doc, fixed = TRUE))
})

test_that("P1-02: the Quarto report gives format 60 valid, 0 missing in both tables", {
  doc <- p1_quarto_html()
  expect_identical(p1_counts(doc, "Item-wise missingness", "format"),
                   c(valid = "60", missing = "0"))
  expect_identical(p1_counts(doc, "Descriptive statistics", "format"),
                   c(valid = "60", missing = "0"))
  expect_true(grepl("does not apply to an item answered with categories", doc, fixed = TRUE))
})

# Column names a report must never print as a heading (Codex P1-03).
p1_raw_names <- c("variable", "group", "valid_n", "missing_n", "missing_prop",
                  "missing_pct", "sd", "se", "iqr", "ci_low", "ci_high",
                  "weighted_mean", "scale_id", "n_items", "min_valid",
                  "missing_rule", "description", "percent", "prop")

p1_headings <- function(doc) {
  th <- regmatches(doc, gregexpr("(?s)<th[^>]*>.*?</th>", doc, perl = TRUE))[[1]]
  trimws(gsub("<[^>]+>", "", th))
}

test_that("P1-03: 1 label map gives the headings, with italic symbols and the CI level", {
  nm <- c("n", "valid_n", "missing_n", "missing_prop", "mean", "sd", "median",
          "iqr", "se", "ci_low", "ci_high", "weighted_mean")
  html <- sframe_apa_col_labels(nm, "html")
  md <- sframe_apa_col_labels(nm, "markdown")
  expect_identical(html, c("<em>n</em>", "Valid <em>n</em>", "Missing <em>n</em>",
                           "Missing proportion", "<em>M</em>", "<em>SD</em>",
                           "<em>Mdn</em>", "IQR", "<em>SE</em>", "95% CI lower",
                           "95% CI upper", "Weighted <em>M</em>"))
  expect_identical(md[c(1, 5, 7, 10)], c("*n*", "*M*", "*Mdn*", "95% CI lower"))
  expect_identical(sframe_apa_col_labels("ci_low", "markdown", conf_level = 0.9),
                   "90% CI lower")
  # The built-in engine's headings come from the same map.
  expect_identical(surveyframe:::sframe_apa_headings(nm), html)
})

test_that("P1-03: the built-in report prints no raw column name", {
  h <- p1_headings(p1_builtin_html())
  expect_identical(intersect(h, p1_raw_names), character(0))
  expect_false(any(h == ""))
})

test_that("P1-03: the Quarto HTML report prints no raw column name or row-name column", {
  h <- p1_headings(p1_quarto_html())
  expect_identical(intersect(h, p1_raw_names), character(0))
  expect_false(any(h == ""))
  expect_true(all(c("M", "SD", "Mdn", "95% CI lower") %in% h))
})

# P1-04 and P1-05 read the report in Word, OpenDocument and PDF through Typst
# and LaTeX. Each format renders once per test run.
p1_files <- new.env()
p1_quarto_file <- function(to) {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  if (to %in% c("typst", "latex")) p1_skip_unless_poppler()
  if (to == "latex") skip_if(!surveyframe:::sframe_latex_available(), "LaTeX is not installed")
  if (!is.null(p1_files[[to]])) return(p1_files[[to]])
  old <- options(surveyframe.use_quarto = TRUE,
                 surveyframe.latex = if (to == "typst") FALSE)
  on.exit(options(old), add = TRUE)
  format <- if (to %in% c("typst", "latex")) "pdf" else to
  d <- p1_demo()
  out <- tempfile(fileext = paste0(".", format))
  res <- suppressMessages(render_report(d$instrument, data = d$data, output_file = out,
                                        format = format, include_analysis = TRUE,
                                        open = FALSE))
  expect_identical(attr(res, "engine"), "quarto")
  p1_files[[to]] <- out
  out
}

# The text of a PDF from pdftotext, read from a file it writes. On Windows a
# temp path mixes / and \, and pdftotext -bbox writing to stdout exited 99
# on such a path in CI, so both paths are normalised with / and the output
# goes to a file. A missing pdftotext skips with that reason, and any other
# failure stops the test with the exit status.
#
# The PDF checks read poppler's pdftotext: its -bbox word boxes and its
# reading order. The Windows CI runner's pdftotext is xpdf 4.06, which has
# no -bbox (exit 99) and orders text differently ("Table 3" read apart from
# its title), so on any pdftotext that is not poppler's the PDF checks skip
# with that reason. Poppler prints "Poppler" in its -v output, xpdf does not.
p1_skip_unless_poppler <- function() {
  skip_if(!nzchar(Sys.which("pdftotext")), "pdftotext is not installed")
  if (is.null(p1_files$poppler)) {
    v <- suppressWarnings(system2("pdftotext", "-v", stdout = TRUE, stderr = TRUE))
    p1_files$poppler <- any(grepl("poppler", v, ignore.case = TRUE))
  }
  skip_if(!p1_files$poppler, "pdftotext is not poppler's (xpdf has no -bbox and reads in another order)")
}

p1_pdftotext <- function(path, bbox = FALSE) {
  p1_skip_unless_poppler()
  out <- tempfile(fileext = if (bbox) ".html" else ".txt")
  file.create(out)
  args <- c(if (bbox) "-bbox", "-enc", "UTF-8",
            shQuote(normalizePath(path, winslash = "/", mustWork = TRUE)),
            shQuote(normalizePath(out, winslash = "/", mustWork = TRUE)))
  status <- system2("pdftotext", args, stdout = TRUE, stderr = TRUE)
  code <- attr(status, "status")
  if (!is.null(code) && code != 0)
    stop(sprintf("pdftotext exited %s on %s: %s", code, path, paste(status, collapse = " ")))
  readLines(out, warn = FALSE, encoding = "UTF-8")
}

p1_unxml <- function(x) {
  x <- gsub("<[^>]+>", "", x)
  x <- gsub("&lt;", "<", gsub("&gt;", ">", gsub("&quot;", "\"", x, fixed = TRUE), fixed = TRUE), fixed = TRUE)
  gsub("&amp;", "&", x, fixed = TRUE)
}

# The paragraphs of a report, in order: their text and whether all of the
# text is bold or italic. PDF text has no styles, so those are NA.
p1_paragraphs <- function(to) {
  path <- p1_quarto_file(to)
  if (to %in% c("typst", "latex")) {
    lines <- trimws(gsub("\f", "", p1_pdftotext(path), fixed = TRUE))
    lines <- lines[nzchar(lines)]
    return(data.frame(text = lines, bold = NA, italic = NA))
  }
  member <- if (to == "docx") "word/document.xml" else c("content.xml", "styles.xml")
  dir <- tempfile()
  utils::unzip(path, member, exdir = dir)
  read_member <- function(m) paste(readLines(file.path(dir, m), warn = FALSE, encoding = "UTF-8"), collapse = "")
  x <- read_member(member[1])
  if (to == "docx") {
    ps <- regmatches(x, gregexpr("(?s)<w:p[ >].*?</w:p>", x, perl = TRUE))[[1]]
    run_of <- function(p) regmatches(p, gregexpr("(?s)<w:r[ >].*?</w:r>", p, perl = TRUE))[[1]]
    text_of <- function(r) p1_unxml(paste(regmatches(r, gregexpr("(?s)<w:t[ >].*?</w:t>", r, perl = TRUE))[[1]], collapse = ""))
    styled <- function(p, tag) {
      runs <- run_of(p)
      runs <- runs[nzchar(trimws(vapply(runs, text_of, "")))]
      length(runs) > 0 && all(grepl(sprintf("<w:%s/>|<w:%s ", tag, tag), runs))
    }
    out <- data.frame(text = trimws(vapply(ps, function(p) paste(vapply(run_of(p), text_of, ""), collapse = ""), "")),
                      bold = vapply(ps, styled, logical(1), tag = "b"),
                      italic = vapply(ps, styled, logical(1), tag = "i"))
  } else {
    # Pandoc in Quarto 1.8 writes automatic styles (T1, T2) into content.xml.
    # Pandoc in Quarto 1.11 points at the named styles Emphasis and
    # Strong_20_Emphasis, which styles.xml defines with style:family first.
    # Both files are read, and the name is found in any attribute order.
    defs <- paste(x, read_member(member[2]))
    styles <- regmatches(defs, gregexpr("(?s)<style:style [^>]*style:name=\"[^\"]+\"[^>]*(?<!/)>.*?</style:style>", defs, perl = TRUE))[[1]]
    style_name <- sub("(?s)^<style:style [^>]*style:name=\"([^\"]+)\".*$", "\\1", styles, perl = TRUE)
    bold_styles <- style_name[grepl("fo:font-weight=\"bold\"", styles)]
    italic_styles <- style_name[grepl("fo:font-style=\"italic\"", styles)]
    ps <- regmatches(x, gregexpr("(?s)<text:(p|h)[ >].*?</text:(p|h)>", x, perl = TRUE))[[1]]
    styled <- function(p, set) {
      spans <- regmatches(p, gregexpr("(?s)<text:span text:style-name=\"[^\"]+\">.*?</text:span>", p, perl = TRUE))[[1]]
      if (!length(spans)) return(FALSE)
      nm <- sub("(?s)^<text:span text:style-name=\"([^\"]+)\">.*$", "\\1", spans, perl = TRUE)
      all(nm %in% set) && identical(trimws(p1_unxml(p)), trimws(p1_unxml(paste(spans, collapse = ""))))
    }
    out <- data.frame(text = trimws(p1_unxml(ps)),
                      bold = vapply(ps, styled, logical(1), set = bold_styles),
                      italic = vapply(ps, styled, logical(1), set = italic_styles))
  }
  out <- out[nzchar(out$text), ]
  rownames(out) <- NULL
  out
}

# APA 7 floats: "Table N" or "Figure N" in bold on its own line, the title
# in italics on the next, numbered 1, 2, 3 in order.
p1_expect_apa_floats <- function(to) {
  p <- p1_paragraphs(to)
  for (kind in c("Table", "Figure")) {
    at <- grep(sprintf("^%s [0-9]+$", kind), p$text)
    expect_gt(length(at), 0)
    expect_identical(p$text[at], sprintf("%s %d", kind, seq_along(at)))
    expect_false(any(grepl(sprintf("^%s [0-9]+[:.]", kind), p$text)))
    if (!is.na(p$bold[1])) {
      expect_true(all(p$bold[at]))
      expect_true(all(p$italic[at + 1]))
    }
  }
  tab1 <- grep("^Table 1$", p$text)
  expect_identical(p$text[tab1 + 1], "Provenance")
  # The not-applicable dash and its note print, and no raw column name does.
  all_text <- paste(p$text, collapse = " ")
  expect_true(grepl("—", all_text, fixed = TRUE))
  expect_true(grepl(gsub(" ", "\\s+", surveyframe:::sframe_not_applicable_note, fixed = TRUE),
                    all_text, perl = TRUE))
  expect_false(any(grepl("missing_n|valid_n|ci_low|ci_high|missing_prop", p$text)))
}

test_that("P1-04: Word sets each table and figure number in bold above an italic title", {
  p1_expect_apa_floats("docx")
})

test_that("P1-04: OpenDocument sets each table and figure number in bold above an italic title", {
  p1_expect_apa_floats("odt")
})

test_that("P1-04: the Typst PDF sets each table and figure number above its title", {
  p1_expect_apa_floats("typst")
})

test_that("P1-04: the LaTeX PDF sets each table and figure number above its title", {
  p1_expect_apa_floats("latex")
})

# P1-05: the descriptives table splits in 2 in every format, and no table
# in a PDF runs 1 column into the next or past the right margin.
p1_centre <- c("variable", "n", "valid_n", "missing_n", "mean", "sd", "median",
               "iqr", "min", "max")
p1_shape <- c("variable", "skewness", "kurtosis", "se", "ci_low", "ci_high")
p1_titles <- c("Descriptive statistics: centre and spread",
               "Descriptive statistics: shape and interval")

test_that("P1-05: descriptives split into centre and spread, and shape and interval", {
  d <- p1_demo()
  dr <- surveyframe:::sframe_report_descriptives(d$instrument, d$data)
  expect_identical(names(dr$centre), p1_centre)
  expect_identical(names(dr$shape), p1_shape)
  expect_identical(dr$centre$variable, c("format", "sessions_attended"))
  expect_identical(dr$centre$valid_n, c("60", "60"))
  expect_identical(dr$shape$skewness[1], "—")
  d$data$w <- seq_len(nrow(d$data))
  dw <- surveyframe:::sframe_report_descriptives(d$instrument, d$data, weights = "w")
  expect_identical(names(dw$shape), c(p1_shape, "weighted_mean"))
  expect_identical(names(dw$centre), p1_centre)
})

p1_expect_split <- function(doc) {
  centre <- p1_table(doc, p1_titles[1])
  shape <- p1_table(doc, p1_titles[2])
  expect_false(is.null(centre))
  expect_false(is.null(shape))
  expect_identical(centre$head, c("Variable", "n", "Valid n", "Missing n", "M", "SD",
                                  "Mdn", "IQR", "Min", "Max"))
  expect_identical(shape$head, c("Variable", "Skewness", "Kurtosis", "SE",
                                 "95% CI lower", "95% CI upper"))
  expect_false(grepl("Weighted", doc, fixed = TRUE))
}

test_that("P1-05: the built-in report prints the 2 descriptives tables", {
  p1_expect_split(p1_builtin_html())
})

test_that("P1-05: the Quarto HTML report prints the 2 descriptives tables", {
  p1_expect_split(p1_quarto_html())
})

# Every word of a PDF with its box, from pdftotext -bbox.
p1_words <- function(to) {
  path <- p1_quarto_file(to)
  x <- p1_pdftotext(path, bbox = TRUE)
  pages <- grep("<page ", x)
  num <- function(line, key) as.numeric(sub(sprintf('.*%s="([0-9.]+)".*', key), "\\1", line))
  w <- grep("<word ", x)
  data.frame(page = findInterval(w, pages), width = num(x[pages][findInterval(w, pages)], "width"),
             x0 = num(x[w], "xMin"), x1 = num(x[w], "xMax"),
             y0 = num(x[w], "yMin"), y1 = num(x[w], "yMax"),
             word = trimws(p1_unxml(x[w])))
}

p1_expect_no_overlap <- function(to) {
  w <- p1_words(to)
  # The margins are the same on both sides, so text ends where the left
  # margin's width leaves off.
  # A glyph's side bearing can reach 1 or 2 points past it.
  right <- w$width - min(w$x0) + 4
  expect_identical(w$word[w$x1 > right], character(0))
  # Words on 1 line share a baseline, and none may cover another. The dot
  # leaders of the contents page are left out, and so are the rotated labels
  # of a chart, which LaTeX embeds as text: a box taller than any line.
  w <- w[!grepl("^[.]+$", w$word) & w$y1 - w$y0 < 24, ]
  clash <- character(0)
  for (pg in unique(w$page)) {
    p <- w[w$page == pg, ]
    for (i in seq_len(nrow(p))) {
      j <- which(seq_len(nrow(p)) > i & abs(p$y1 - p$y1[i]) < 1.5 &
                   p$x0 < p$x1[i] - 0.5 & p$x1 > p$x0[i] + 0.5)
      if (length(j)) clash <- c(clash, paste(p$word[i], p$word[j], sep = " / "))
    }
  }
  expect_identical(clash, character(0))
  # Glyphs that overlap come out as 1 word ("MdnIQRMin" in Table 8 before
  # the fix), so each heading and identifier of Tables 2, 3 and the 2
  # descriptives tables must come out as a word of its own.
  own <- c("Scale", "Reverse", "Required", "sessions_attended", "single_choice",
           "in_person", "t_test_ind", "mann_whitney", "Valid", "Missing", "Mdn",
           "IQR", "Min", "Max", "Skewness", "Kurtosis")
  expect_identical(setdiff(own, w$word), character(0))
  txt <- paste(w$word, collapse = " ")
  for (title in p1_titles) expect_true(grepl(title, txt, fixed = TRUE))
}

test_that("P1-05: no word in the Typst PDF overlaps another or crosses the margin", {
  p1_expect_no_overlap("typst")
})

test_that("P1-05: no word in the LaTeX PDF overlaps another or crosses the margin", {
  p1_expect_no_overlap("latex")
})

# A float's "Table N" or "Figure N" line and its title share a page with the
# float (Session UF, the RF follow-up): seen apart at a page foot, Figure 2
# in Typst and Table 2 in LaTeX. On the head's page, something must follow
# the title above the foot (the table's heading row, or the chart's own
# text), or there must be at least 200 pt left below it for a chart drawn
# as paths. A head whose float went over is the last text on its page.
p1_expect_heads_kept <- function(to) {
  w <- p1_words(to)
  x <- p1_pdftotext(p1_quarto_file(to), bbox = TRUE)
  height <- as.numeric(sub('.*height="([0-9.]+)".*', "\\1", x[grep("<page ", x)][1]))
  foot <- height - 72
  w <- w[order(w$page, w$y1, w$x0), ]
  w$line <- cumsum(c(TRUE, abs(diff(w$y1)) > 2 | diff(w$page) != 0))
  lines <- do.call(rbind, lapply(split(w, w$line), function(l)
    data.frame(page = l$page[1], y0 = min(l$y0), y1 = max(l$y1),
               text = paste(l$word[order(l$x0)], collapse = " "))))
  heads <- grep("^(Table|Figure) [0-9]+$", lines$text)
  expect_gt(length(heads), 10)
  stranded <- character(0)
  for (i in heads) {
    title <- i + 1
    after <- lines[seq_len(nrow(lines)) > title & lines$page == lines$page[i] &
                     lines$y0 < foot, ]
    if (!nrow(after) && foot - lines$y1[title] < 200)
      stranded <- c(stranded, sprintf("%s (page %d)", lines$text[i], lines$page[i]))
  }
  expect_identical(stranded, character(0))
}

test_that("UF: every table and figure number in the Typst PDF shares a page with its float", {
  p1_expect_heads_kept("typst")
})

test_that("UF: every table and figure number in the LaTeX PDF shares a page with its float", {
  p1_expect_heads_kept("latex")
})
