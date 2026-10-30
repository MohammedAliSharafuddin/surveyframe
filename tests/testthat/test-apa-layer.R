# tests/testthat/test-apa-layer.R
# The one APA layer (CX-15, CX-22, CX-24, D9): result text, table cells and
# headings, and numbered tables and figures, formatted in one place for
# every renderer.

test_that("a statistic bounded by 1 loses its leading zero, others keep it", {
  expect_identical(
    sframe_apa_text("r(58) = 0.53, 95% CI [0.33, 0.69], p < .001"),
    "r(58) = .53, 95% CI [.33, .69], p < .001")
  expect_identical(sframe_apa_text("tau = -0.39, 95% CI [-0.60, -0.10], p = .004, N = 60"),
                   "tau = -.39, 95% CI [-.60, -.10], p = .004, N = 60")
  expect_identical(sframe_apa_text("r_s(28) = 0.55"), "r_s(28) = .55")
  expect_identical(sframe_apa_text("R\u00b2 = 0.362, F(2, 57) = 16.20, p < .001"),
                   "R\u00b2 = .362, F(2, 57) = 16.20, p < .001")
  expect_identical(
    sframe_apa_text("\u03c7\u00b2(1, N = 60) = 1.20, p = .273, Cramer's V = 0.24"),
    "\u03c7\u00b2(1, N = 60) = 1.20, p = .273, Cramer's V = .24")
  expect_identical(sframe_apa_text("F(2, 57) = 3.10, p = .052, \u03b7\u00b2 = 0.098"),
                   "F(2, 57) = 3.10, p = .052, \u03b7\u00b2 = .098")
  expect_identical(sframe_apa_text("phi = 0.15"), "phi = .15")
  # d, t, z, means and other unbounded values keep the zero.
  unbounded <- "t(57.30) = 0.45, p = .652, d = 0.12, 95% CI [-0.40, 0.63], z = 0.80, M = 0.50"
  expect_identical(sframe_apa_text(unbounded), unbounded)
  expect_identical(sframe_apa_text("net causal role (D - R = 0.893)"),
                   "net causal role (D - R = 0.893)")
  expect_identical(sframe_apa_text(c("r = 1.00", NA)), c("r = 1.00", NA))
})

test_that("a run block's result text and prompt carry no leading zero on r", {
  set.seed(2)
  d <- data.frame(a = 1:40, b = 1:40 + stats::rnorm(40, sd = 15))
  instr <- sf_instrument("APA", components = list(
    sf_item("a", "A", type = "numeric"), sf_item("b", "B", type = "numeric")))
  sf_plan(instr) <- list(list(id = "RQ1", research_question = "Is a related to b?",
    family = "relationship", method = "correlation_pearson",
    roles = list(x = "a", y = "b")))
  res <- run_analysis_plan(d, instr)
  expect_match(res$RQ1$apa, "^r\\(38\\) = -?\\.[0-9]{2}, 95% CI \\[-?\\.[0-9]+, -?\\.[0-9]+\\]")
  expect_match(res$RQ1$prompt, "r\\(38\\) = -?\\.[0-9]{2}")
})

test_that("table cells: p by its rules, bounded values without a zero, blanks for missing (CX-15)", {
  x <- data.frame(term = c("a", NA, "b"), t = c(2.345, 10, 1),
                  p = c(.004, .00001, 1), r = c(.53, -.2, NA), n = c(10L, 20L, 30L),
                  stringsAsFactors = FALSE)
  out <- sframe_apa_cells(x)
  expect_identical(out$p, c(".004", "<.001", "1.000"))
  expect_identical(out$r, c(".53", "-.20", ""))
  expect_identical(out$t, c("2.35", "10.00", "1.00"))
  expect_identical(out$n, c("10", "20", "30"))
  expect_identical(out$term, c("a", "", "b"))
  expect_identical(sframe_p_cell(c(.032, NA)), c(".032", ""))
})

test_that("every report engine shows a p of .004 as .004 (CX-15)", {
  tbl <- data.frame(term = "x", t = 3.1, p = 0.004)
  expect_match(surveyframe:::.render_report_table(tbl, "T"), "<td>.004</td>", fixed = TRUE)
  tpl <- readLines(system.file("templates", "report.qmd", package = "surveyframe"))
  kables <- grep("kable\\(.*(r\\$table|sup\\$table)", tpl, value = TRUE)
  expect_true(length(kables) >= 2)
  expect_true(all(grepl("sframe_apa_cells(", kables, fixed = TRUE)))
})

test_that("result text in HTML: italic Latin symbols, subscripts, Greek letters (CX-24)", {
  expect_identical(
    sframe_apa_html("t(57.30) = 2.10, p = .040, d = 0.55, 95% CI [0.10, 1.00], higher in A"),
    "<em>t</em>(57.30) = 2.10, <em>p</em> = .040, <em>d</em> = 0.55, 95% CI [0.10, 1.00], higher in A")
  expect_identical(sframe_apa_html("r_s(28) = .55, p < .001"),
                   "<em>r</em><sub>s</sub>(28) = .55, <em>p</em> &lt; .001")
  expect_identical(sframe_apa_html("t(29) = 2.00, p = .050, d_z = 0.40"),
                   "<em>t</em>(29) = 2.00, <em>p</em> = .050, <em>d</em><sub>z</sub> = 0.40")
  expect_identical(sframe_apa_html("tau = .39, p = .002, N = 30"),
                   "\u03c4 = .39, <em>p</em> = .002, <em>N</em> = 30")
  expect_identical(sframe_apa_html("McNemar's chi-square(1) = 4.00, p = .046"),
                   "McNemar's \u03c7\u00b2(1) = 4.00, <em>p</em> = .046")
  expect_identical(sframe_apa_html("R\u00b2 = .362, F(2, 57) = 16.20"),
                   "<em>R</em>\u00b2 = .362, <em>F</em>(2, 57) = 16.20")
  expect_identical(sframe_apa_html("Cramer's V = .24"), "Cram\u00e9r's <em>V</em> = .24")
  expect_identical(sframe_apa_html("Hodges-Lehmann shift = 2.00, pseudomedian = 1.00"),
                   "Hodges-Lehmann shift = 2.00, pseudomedian = 1.00")
  expect_identical(sframe_apa_html("a <b> & c"), "a &lt;b&gt; &amp; c")
})

test_that("each HTML renderer marks up the result text (CX-24)", {
  set.seed(3)
  d <- data.frame(a = 1:40, b = 1:40 + stats::rnorm(40, sd = 15))
  instr <- sf_instrument("APA", components = list(
    sf_item("a", "A", type = "numeric"), sf_item("b", "B", type = "numeric")))
  sf_plan(instr) <- list(list(id = "RQ1", research_question = "Is a related to b?",
    family = "relationship", method = "correlation_pearson",
    roles = list(x = "a", y = "b")))
  res <- run_analysis_plan(d, instr)
  one <- render_result(res$RQ1, d, instr)$html
  expect_match(one, "<em>r</em>(38) = ", fixed = TRUE)
  built_in <- surveyframe:::.render_report_analysis_section(instr, d, show_code = FALSE)
  expect_match(built_in, "<em>r</em>(38) = ", fixed = TRUE)
  out <- render_results(res, instr, output_file = tempfile(fileext = ".html"))
  expect_true(any(grepl("<em>r</em>(38) = ", readLines(out), fixed = TRUE)))
})

test_that("table headings set symbols as APA 7 does and read as words (CX-24)", {
  expect_identical(
    sframe_apa_headings(c("p", "t", "df", "missing_pct", "r_s", "research_question",
                          "Pr(>|z|)", "SD", "std.error", "n_items")),
    c("<em>p</em>", "<em>t</em>", "<em>df</em>", "Missing (proportion)",
      "<em>r</em><sub>s</sub>", "Research question", "<em>p</em>", "<em>SD</em>",
      "<em>SE</em>", "N items"))
  expect_identical(sframe_apa_headings("a<b"), "A&lt;b")
  html <- surveyframe:::.render_report_table(data.frame(t = 2, p = .5, missing_pct = .25), "T")
  expect_match(html, "<th scope=\"col\"><em>p</em></th>", fixed = TRUE)
  expect_no_match(html, ">P<", fixed = TRUE)
  expect_match(html, "<td>.25</td>", fixed = TRUE)
})

test_that("result text and notes count with real plurals, never (s) (CX-24)", {
  fns <- c("sframe_run_descriptives_result", "sframe_resolve_decision_inputs",
           "sframe_resolve_pairwise_matrix", "sframe_run_anp",
           "sframe_resolve_dematel_matrix")
  for (fn in fns) {
    src <- paste(deparse(get(fn, envir = asNamespace("surveyframe"))), collapse = "\n")
    expect_false(grepl("[a-z]\\(s\\)", src), label = fn)
  }
})
