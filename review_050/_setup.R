# review_050/_setup.R
# Shared setup for every file in the 0.5 text-analysis review suite.
# Each .qmd sources this in its first chunk. Nothing here prints.

# ---------------------------------------------------------------------------
# 1. Load the dev checkout this suite sits inside, wherever it happens to be
# ---------------------------------------------------------------------------
# The 0.5 text-analysis engineering is only on this `dev` checkout (never
# pushed/released), unlike review_040 which could fall back to an installed
# 0.4.0 tarball. So this suite always load_all()s the current repository
# rather than trying an install path. extract_quotes() is new in 0.5 and a
# reliable marker that the right build is loaded.

sf_is_050 <- function() {
  isTRUE(requireNamespace("surveyframe", quietly = TRUE)) &&
    length(getNamespaceExports("surveyframe")) > 0 &&
    "extract_quotes" %in% getNamespaceExports("surveyframe")
}

if (!sf_is_050()) {
  # review_050/ sits at the repo root alongside review_040/, so ".." from a
  # `quarto render` invocation (cwd = review_050/) is the package root.
  candidates <- c("..", "../..")
  hit <- NULL
  for (p in candidates) {
    if (file.exists(file.path(p, "DESCRIPTION"))) { hit <- p; break }
  }
  if (is.null(hit)) {
    stop("Cannot find the dev source tree with the 0.5 text-analysis work. ",
         "Expected one of:\n  ", paste(candidates, collapse = "\n  "),
         call. = FALSE)
  }
  suppressMessages(devtools::load_all(hit, quiet = TRUE))
}

suppressPackageStartupMessages(library(surveyframe))

# ---------------------------------------------------------------------------
# 2. Comparison helpers
# ---------------------------------------------------------------------------
# Every accuracy chunk in this suite ends the same way: one table with a
# verdict column, then one plot. The reviewer scans the verdict column for
# anything that is not "match", and glances at the plot to see the size of
# any gap rather than only its existence.

#' Build one comparison row.
#'
#' tol defaults to 1e-6. Loosen it only with a stated reason in the chunk,
#' because a silently loosened tolerance is how a real difference hides.
compare_row <- function(quantity, surveyframe, reference, source, tol = 1e-6) {
  s <- suppressWarnings(as.numeric(surveyframe)[1])
  r <- suppressWarnings(as.numeric(reference)[1])
  d <- abs(s - r)
  data.frame(
    quantity    = quantity,
    surveyframe = s,
    reference   = r,
    source      = source,
    difference  = d,
    tolerance   = tol,
    verdict     = if (is.na(d)) "CHECK" else if (d <= tol) "match" else "DIFFERS",
    stringsAsFactors = FALSE, row.names = NULL
  )
}

#' Stack comparison rows and print them as a table.
compare_table <- function(...) {
  tab <- do.call(rbind, list(...))
  tab$surveyframe <- signif(tab$surveyframe, 8)
  tab$reference   <- signif(tab$reference, 8)
  tab$difference  <- signif(tab$difference, 3)
  tab
}

#' Show a comparison table with the verdict column highlighted.
compare_show <- function(tab, caption = NULL) {
  knitr::kable(tab[, c("quantity", "surveyframe", "reference", "source",
                       "difference", "verdict")],
               caption = caption, row.names = FALSE)
}

#' Plot a comparison table: one row per quantity, surveyframe against its
#' reference, with the tolerance drawn as a line. Anything above the line is
#' a real disagreement.
compare_plot <- function(tab, main = "surveyframe vs reference") {
  d   <- pmax(tab$difference, .Machine$double.xmin)
  tol <- tab$tolerance
  op  <- graphics::par(mar = c(4, 11, 3, 1))
  on.exit(graphics::par(op), add = TRUE)
  cols <- ifelse(tab$verdict == "match", "#1b7837",
                 ifelse(tab$verdict == "CHECK", "#8c8c8c", "#b2182b"))
  graphics::barplot(
    rev(log10(d)), horiz = TRUE, names.arg = rev(tab$quantity), las = 1,
    col = rev(cols), border = NA, xlab = "log10 absolute difference",
    main = main, cex.names = 0.85,
    xlim = range(c(log10(d), log10(tol), -18), finite = TRUE)
  )
  graphics::abline(v = log10(tol[1]), lty = 2, col = "#404040")
  graphics::mtext("dashed line = tolerance; green = match, red = DIFFERS",
                  side = 1, line = 2.6, cex = 0.75)
  invisible(tab)
}

#' One call for the common case: table then plot.
compare_report <- function(tab, caption = NULL, main = NULL) {
  print(compare_show(tab, caption))
  compare_plot(tab, main = main %||% (caption %||% "surveyframe vs reference"))
  invisible(tab)
}

`%||%` <- function(x, y) if (is.null(x)) y else x

# ---------------------------------------------------------------------------
# 3. Verdict banner
# ---------------------------------------------------------------------------
# Put sf_verdict(tab) at the end of a file to get a one-line summary of
# every comparison it ran.

.sf_verdicts <- new.env(parent = emptyenv())
.sf_verdicts$rows <- list()

sf_log <- function(tab) {
  .sf_verdicts$rows[[length(.sf_verdicts$rows) + 1L]] <- tab
  invisible(tab)
}

sf_verdict <- function() {
  if (!length(.sf_verdicts$rows)) return(cat("No comparisons logged.\n"))
  all <- do.call(rbind, .sf_verdicts$rows)
  n   <- table(factor(all$verdict, levels = c("match", "DIFFERS", "CHECK")))
  cat(sprintf("%d comparisons: %d match, %d DIFFERS, %d CHECK\n",
              nrow(all), n[["match"]], n[["DIFFERS"]], n[["CHECK"]]))
  if (n[["DIFFERS"]] || n[["CHECK"]]) {
    print(all[all$verdict != "match",
              c("quantity", "surveyframe", "reference", "source", "verdict")],
          row.names = FALSE)
  }
  invisible(all)
}

# ---------------------------------------------------------------------------
# 4. Small conveniences used across files
# ---------------------------------------------------------------------------

#' Path to a bundled fixture, whether installed or loaded with load_all().
sf_fixture <- function(name) {
  p <- system.file("extdata", name, package = "surveyframe")
  if (!nzchar(p)) stop("Fixture not found: ", name, call. = FALSE)
  p
}

# ---------------------------------------------------------------------------
# 5. Route checks: the same instrument down the HTML route and the Shiny route
# ---------------------------------------------------------------------------
# Every workflow demo in this suite runs both, because 0.4.0 fixed a defect
# where the Shiny collector wrote a column shape the reader could not read
# back. Checking only one route would not have caught it.

sf_collecting_items <- function(instrument) {
  Filter(function(i) !i$type %in% c("section_break", "text_block"),
         instrument$items)
}

#' The full column contract an instrument promises: plain items keep their
#' own id, multi-column items expand. This is what a response file must
#' contain and what read_responses() checks against.
sf_columns <- function(instrument) {
  items <- sf_collecting_items(instrument)
  expanded_types <- c("matrix", "ranking", "multiple_choice",
                      "pairwise_comparison", "criteria_weight")
  plain <- vapply(Filter(function(i) !i$type %in% expanded_types, items),
                  function(i) i$id, character(1))
  data.frame(
    column = c(plain, sframe_item_expansion_columns(instrument)),
    stringsAsFactors = FALSE, row.names = NULL
  )
}

#' Export an instrument to the static HTML survey and report on the file.
#' The file path is attached, so you can open it yourself with
#' browseURL(attr(x, "path")) and click through the real thing.
sf_html_route <- function(instrument, open = FALSE) {
  f <- tempfile(fileext = ".html")
  suppressMessages(export_static_survey(instrument, output_path = f,
                                        open = FALSE, overwrite = TRUE))
  html <- paste(readLines(f, warn = FALSE), collapse = "\n")
  ids  <- vapply(sf_collecting_items(instrument), function(i) i$id,
                 character(1))
  found <- vapply(ids, function(x) grepl(x, html, fixed = TRUE), logical(1))
  out <- data.frame(
    check = c("file written", "size (KB)", "data-collecting items",
              "items present in the exported HTML"),
    value = c(as.character(file.exists(f)),
              as.character(round(file.size(f) / 1024, 1)),
              as.character(length(ids)),
              as.character(sum(found))),
    stringsAsFactors = FALSE
  )
  if (open && interactive()) utils::browseURL(f)
  attr(out, "path") <- f
  attr(out, "missing") <- ids[!found]
  out
}

#' Build every Shiny widget the instrument needs, without a browser.
#'
#' Deliberately an R-side check. Reading a Shiny widget through a headless
#' browser is unreliable, because selectize.js replaces the real <select> and
#' twice made a working dropdown look empty during this release. Here the
#' widget is inspected as an R object instead.
sf_shiny_widgets <- function(instrument) {
  stopifnot(requireNamespace("shiny", quietly = TRUE))
  lookup <- sframe_choices_lookup(instrument)
  items  <- sf_collecting_items(instrument)
  do.call(rbind, lapply(items, function(item) {
    w <- tryCatch(sframe_render_input(item, lookup),
                  error = function(e) e)
    ok <- !inherits(w, "error")
    data.frame(
      item = item$id, type = item$type,
      widget = if (ok) "built" else paste("ERROR:", conditionMessage(w)),
      html_bytes = if (ok) nchar(paste(as.character(w), collapse = "")) else NA_integer_,
      stringsAsFactors = FALSE, row.names = NULL
    )
  }))
}

#' What to call the elements of the `answers` list passed to
#' sf_shiny_roundtrip().
#'
#' Worth reading before writing a demo, because the Shiny input names are not
#' always the output column names. A matrix posts positional inputs
#' (svc__1, svc__2) while it writes labelled columns (svc__North,
#' svc__South). Ranking and multi-select post a single input under the item
#' id and expand on write. Getting this wrong yields a clean round trip full
#' of NA, which looks like a package bug and is not one.
sf_answer_template <- function(instrument) {
  items <- sf_collecting_items(instrument)
  do.call(rbind, lapply(items, function(item) {
    inp <- switch(
      item$type,
      matrix = paste0(item$id, "__", seq_along(item$matrix_items),
                      collapse = ", "),
      ranking = paste0(item$id, ' (one string, e.g. "B|A|C")'),
      multiple_choice = paste0(item$id, " (character vector of chosen codes)"),
      pairwise_comparison = ,
      criteria_weight = paste(sframe_item_expansion_columns(
        instrument, list(item)), collapse = ", "),
      item$id
    )
    data.frame(item = item$id, type = item$type, shiny_input_name = inp,
               stringsAsFactors = FALSE, row.names = NULL)
  }))
}

#' Run both collection routes for one instrument and summarise them in a
#' single table. Used by every file after 01, which shows the routes in full.
sf_both_routes <- function(instrument, answers, n = 3L) {
  h  <- sf_html_route(instrument)
  rt <- sf_shiny_roundtrip(instrument, answers, n = n)
  out <- rbind(
    data.frame(route = "static HTML", h, stringsAsFactors = FALSE),
    data.frame(route = "Shiny", rt$summary, stringsAsFactors = FALSE)
  )
  attr(out, "path") <- attr(h, "path")
  attr(out, "read_back") <- rt$read_back
  out
}

#' Drive the real Shiny collector with simulated answers and read the result
#' back with read_responses().
#'
#' This is the round trip that 0.4.0 fixed. Before this release the Shiny
#' path pipe-joined matrix, ranking, and multi-select answers into one
#' column, so data collected that way could not be read back by the package
#' at all, silently. Any workflow demo that only exercised the HTML route
#' would have missed it, which is why every demo here runs both.
sf_shiny_roundtrip <- function(instrument, answers, n = 1L) {
  stopifnot(requireNamespace("shiny", quietly = TRUE))
  branch <- sframe_branch_lookup(instrument)
  rows <- lapply(seq_len(n), function(i) {
    vals <- if (is.function(answers)) answers(i) else answers
    sframe_response_row(instrument, vals, branch,
                        started_at = Sys.time() - 300)
  })
  raw <- do.call(rbind, rows)
  # The collector stamps started_at and submitted_at on every row. They are
  # not instrument items, so read_responses() rejects them under strict
  # import unless they are declared. Declaring them is the correct call, and
  # is what a real collection script has to do too.
  read <- tryCatch(
    read_responses(raw, instrument,
                   meta_cols = c("started_at", "submitted_at")),
    error = function(e) e)
  list(
    collected = raw,
    read_back = read,
    summary = data.frame(
      check = c("collector produced a row", "columns written",
                "read_responses() accepted it", "rows read back"),
      value = c(as.character(nrow(raw) == n),
                as.character(ncol(raw)),
                as.character(!inherits(read, "error")),
                if (inherits(read, "error")) conditionMessage(read)
                else as.character(nrow(read))),
      stringsAsFactors = FALSE
    )
  )
}
