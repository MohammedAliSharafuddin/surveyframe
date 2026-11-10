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
