# review_041/_setup.R
# Shared setup for every file in the 0.4.1 review suite.
# Each .qmd sources this in its first chunk. Nothing here prints.
#
# Inherits the 0.4.0 harness deliberately: compare_row(), compare_report(),
# sf_log(), sf_verdict(), and the 2 route helpers are unchanged, so a file
# written for review_040 runs here. review_040/HANDOVER.md documents them and
# is not repeated. What is new in this suite is section 6, the coverage
# ledger, and section 7, the Quarto audit probes.

# ---------------------------------------------------------------------------
# 1. Load the 0.4.1 build, wherever it happens to be
# ---------------------------------------------------------------------------
# DESCRIPTION reads 0.4.0.9000 on dev and 0.4.0 on main, so a version string
# cannot tell the development build apart from CRAN 0.4.0. Test for a 0.4.1
# feature instead. sframe_branch_in_values() is internal to this release and
# did not exist in 0.4.0.

sf_is_041 <- function() {
  isTRUE(requireNamespace("surveyframe", quietly = TRUE)) &&
    "sframe_branch_in_values" %in% ls(asNamespace("surveyframe"), all.names = TRUE)
}

if (!sf_is_041()) {
  candidates <- c(".", "..", "../surveyframe-dev",
                  "~/Documents/GitHub/surveyframe-dev")
  hit <- NULL
  for (p in candidates) {
    p <- path.expand(p)
    if (file.exists(file.path(p, "DESCRIPTION")) &&
        file.exists(file.path(p, "R", "sf_branch.R"))) { hit <- p; break }
  }
  if (is.null(hit)) {
    stop("Cannot find the 0.4.1 source tree. Expected one of:\n  ",
         paste(candidates, collapse = "\n  "), call. = FALSE)
  }
  suppressMessages(pkgload::load_all(hit, quiet = TRUE))
}

suppressPackageStartupMessages(library(surveyframe))

`%||%` <- function(x, y) if (is.null(x)) y else x

# ---------------------------------------------------------------------------
# 2. Comparison helpers, unchanged from review_040/_setup.R
# ---------------------------------------------------------------------------

compare_row <- function(quantity, surveyframe, reference, source, tol = 1e-6) {
  s <- suppressWarnings(as.numeric(surveyframe)[1])
  r <- suppressWarnings(as.numeric(reference)[1])
  d <- abs(s - r)
  data.frame(
    quantity = quantity, surveyframe = s, reference = r, source = source,
    difference = d, tolerance = tol,
    verdict = if (is.na(d)) "CHECK" else if (d <= tol) "match" else "DIFFERS",
    stringsAsFactors = FALSE, row.names = NULL
  )
}

compare_table <- function(...) {
  tab <- do.call(rbind, list(...))
  tab$surveyframe <- signif(tab$surveyframe, 8)
  tab$reference   <- signif(tab$reference, 8)
  tab$difference  <- signif(tab$difference, 3)
  tab
}

compare_show <- function(tab, caption = NULL) {
  knitr::kable(tab[, c("quantity", "surveyframe", "reference", "source",
                       "difference", "verdict")],
               caption = caption, row.names = FALSE)
}

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

compare_report <- function(tab, caption = NULL, main = NULL) {
  print(compare_show(tab, caption))
  compare_plot(tab, main = main %||% (caption %||% "surveyframe vs reference"))
  invisible(tab)
}

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

sf_fixture <- function(name) {
  p <- system.file("extdata", name, package = "surveyframe")
  if (!nzchar(p)) stop("Fixture not found: ", name, call. = FALSE)
  p
}

# ---------------------------------------------------------------------------
# 3 to 5. Route helpers, unchanged from review_040/_setup.R
# ---------------------------------------------------------------------------

sf_collecting_items <- function(instrument) {
  Filter(function(i) !i$type %in% c("section_break", "text_block"),
         instrument$items)
}

sf_html_route <- function(instrument, open = FALSE) {
  f <- tempfile(fileext = ".html")
  suppressMessages(export_static_survey(instrument, output_path = f,
                                        open = FALSE, overwrite = TRUE))
  html <- paste(readLines(f, warn = FALSE), collapse = "\n")
  ids  <- vapply(sf_collecting_items(instrument), function(i) i$id, character(1))
  found <- vapply(ids, function(x) grepl(x, html, fixed = TRUE), logical(1))
  out <- data.frame(
    check = c("file written", "size (KB)", "data-collecting items",
              "items present in the exported HTML"),
    value = c(as.character(file.exists(f)),
              as.character(round(file.size(f) / 1024, 1)),
              as.character(length(ids)), as.character(sum(found))),
    stringsAsFactors = FALSE
  )
  attr(out, "path") <- f
  attr(out, "missing") <- ids[!found]
  out
}

sf_shiny_roundtrip <- function(instrument, answers, n = 1L) {
  stopifnot(requireNamespace("shiny", quietly = TRUE))
  branch <- sframe_branch_lookup(instrument)
  rows <- lapply(seq_len(n), function(i) {
    vals <- if (is.function(answers)) answers(i) else answers
    sframe_response_row(instrument, vals, branch, started_at = Sys.time() - 300)
  })
  raw <- do.call(rbind, rows)
  read <- tryCatch(
    read_responses(raw, instrument,
                   meta_cols = c("started_at", "submitted_at")),
    error = function(e) e)
  list(
    collected = raw, read_back = read,
    summary = data.frame(
      check = c("collector produced a row", "columns written",
                "read_responses() accepted it", "rows read back"),
      value = c(as.character(nrow(raw) == n), as.character(ncol(raw)),
                as.character(!inherits(read, "error")),
                if (inherits(read, "error")) conditionMessage(read)
                else as.character(nrow(read))),
      stringsAsFactors = FALSE))
}

sf_both_routes <- function(instrument, answers, n = 3L) {
  h  <- sf_html_route(instrument)
  rt <- sf_shiny_roundtrip(instrument, answers, n = n)
  out <- rbind(
    data.frame(route = "static HTML", h, stringsAsFactors = FALSE),
    data.frame(route = "Shiny", rt$summary, stringsAsFactors = FALSE))
  attr(out, "path") <- attr(h, "path")
  attr(out, "read_back") <- rt$read_back
  out
}

# ---------------------------------------------------------------------------
# 6. The coverage ledger, new in this suite
# ---------------------------------------------------------------------------
# "Comprehensive" has to mean something checkable, or it is a claim rather
# than a property. The ledger enumerates the package's own export list at
# render time and reports what this suite touched, so it cannot drift as
# functions are added: a new export appears as an uncovered row on the next
# render rather than silently going untested.

#' Every exported object, minus S3 methods, which are exercised through their
#' generics rather than called by name.
sf_exports <- function() {
  ex <- getNamespaceExports("surveyframe")
  ex <- ex[!grepl("^(print|format|summary|plot|as\\.data\\.frame|\\[)\\.", ex)]
  sort(ex)
}

.sf_cov <- new.env(parent = emptyenv())
.sf_cov$rows <- list()

#' Call one exported function and record what happened.
#'
#' The point is not that the call returns the right answer, which is what the
#' per-family accuracy files are for. The point is that the function can be
#' called at all, and that a function nobody has ever called is visible as
#' such. Several of this package's defects were in code paths no test and no
#' review file had ever entered.
#'
#' `expect` is what a healthy call looks like: "value" for anything non-NULL,
#' "error" where erroring is the correct behaviour, "skip" where calling it
#' needs a browser, a network, or a human.
sf_smoke <- function(name, expr, expect = c("value", "error", "skip"),
                     note = "") {
  expect <- match.arg(expect)
  if (identical(expect, "skip")) {
    res <- list(status = "skipped", detail = note)
  } else {
    out <- tryCatch(list(v = force(expr), e = NULL),
                    error = function(e) list(v = NULL, e = e))
    res <- if (!is.null(out$e)) {
      list(status = if (identical(expect, "error")) "errors as intended" else "ERROR",
           detail = conditionMessage(out$e))
    } else if (identical(expect, "error")) {
      list(status = "NO ERROR", detail = "expected an error and got a value")
    } else if (is.null(out$v)) {
      list(status = "NULL", detail = "returned NULL")
    } else {
      list(status = "ok", detail = paste(class(out$v), collapse = "/"))
    }
  }
  row <- data.frame(fn = name, status = res$status,
                    detail = substr(res$detail, 1, 90), note = note,
                    stringsAsFactors = FALSE, row.names = NULL)
  .sf_cov$rows[[length(.sf_cov$rows) + 1L]] <- row
  invisible(row)
}

#' Everything sf_smoke() has recorded so far.
sf_covered <- function() {
  if (!length(.sf_cov$rows)) return(data.frame())
  do.call(rbind, .sf_cov$rows)
}

#' The ledger: every export, and whether this suite called it.
#'
#' `also_called_in` lets a file credit calls made in prose-driven workflow
#' chunks rather than through sf_smoke(), by passing the .qmd sources to scan.
sf_coverage_ledger <- function(also_called_in = NULL) {
  ex <- sf_exports()
  smoked <- sf_covered()
  called <- if (nrow(smoked)) unique(smoked$fn) else character(0)
  if (!is.null(also_called_in)) {
    txt <- paste(unlist(lapply(also_called_in, function(f) {
      if (file.exists(f)) readLines(f, warn = FALSE) else character(0)
    })), collapse = "\n")
    esc <- gsub("([.\\[\\]<-])", "\\\\\\1", ex)
    called <- unique(c(called,
      ex[vapply(esc, function(p) grepl(paste0("\\b", p, "\\s*\\("), txt),
                logical(1))]))
  }
  status <- vapply(ex, function(f) {
    if (nrow(smoked) && f %in% smoked$fn) smoked$status[match(f, smoked$fn)]
    else if (f %in% called) "called in a workflow chunk"
    else "NOT EXERCISED"
  }, character(1))
  data.frame(fn = ex, status = status, stringsAsFactors = FALSE,
             row.names = NULL)
}

#' One-line summary of the ledger, plus the uncovered names.
sf_coverage_verdict <- function(ledger) {
  bad <- c("NOT EXERCISED", "ERROR", "NO ERROR", "NULL")
  n <- nrow(ledger)
  uncovered <- ledger[ledger$status %in% bad, ]
  cat(sprintf("%d exported functions: %d exercised, %d skipped, %d need attention\n",
              n, sum(!ledger$status %in% c(bad, "skipped")),
              sum(ledger$status == "skipped"), nrow(uncovered)))
  if (nrow(uncovered)) print(uncovered, row.names = FALSE)
  invisible(uncovered)
}

# ---------------------------------------------------------------------------
# 7. Quarto audit probes, new in this suite
# ---------------------------------------------------------------------------
# render_report() prefers Quarto and falls back to a base-R HTML writer when
# Quarto is absent or its render fails. The fallback is silent: both paths
# return the destination path and nothing else, so a caller cannot tell which
# engine produced the file in front of them. For a report that is meant to be
# the audit artefact of a study, that is the difference between a
# parameterised, reproducible render and a different document entirely.
#
# These probes make the engine observable from outside the package, which is
# what the audit file uses to check the claim rather than assume it.

sf_quarto_bin <- function() unname(Sys.which("quarto"))

sf_quarto_available <- function() nzchar(sf_quarto_bin())

sf_quarto_version <- function() {
  if (!sf_quarto_available()) return(NA_character_)
  tryCatch(system2(sf_quarto_bin(), "--version", stdout = TRUE)[1],
           error = function(e) NA_character_)
}

#' Which engine produced a rendered report?
#'
#' Quarto stamps its own generator metadata and ships its runtime under
#' `quarto-` prefixed identifiers. The base-R fallback writes neither. This
#' reads the artefact rather than trusting the call that produced it, which
#' is the only way to check the claim from outside.
sf_report_engine <- function(path) {
  if (!file.exists(path)) return("no file")
  h <- paste(readLines(path, warn = FALSE), collapse = "\n")
  quarto_marks <- c("quarto-", "data-quarto", "generator\" content=\"quarto")
  if (any(vapply(quarto_marks, grepl, logical(1), x = h, fixed = TRUE))) {
    "quarto"
  } else {
    "fallback (base R)"
  }
}

#' Render the same report twice, once down each engine, and describe both.
#'
#' Returns 1 row per engine with the facts an auditor needs: which engine ran,
#' how big the artefact is, whether the instrument hash is stamped into it,
#' and how long it took.
sf_render_both_engines <- function(instrument, data = NULL, ...) {
  one <- function(label, use_quarto) {
    old <- options(surveyframe.use_quarto = use_quarto)
    on.exit(options(old), add = TRUE)
    f <- tempfile(fileext = ".html")
    t0 <- Sys.time()
    ok <- tryCatch({
      suppressMessages(render_report(instrument, data, output_path = f, ...))
      TRUE
    }, error = function(e) conditionMessage(e))
    secs <- round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1)
    hash <- sframe_hash_value(instrument)
    body <- if (file.exists(f)) paste(readLines(f, warn = FALSE), collapse = "\n") else ""
    row <- data.frame(
      requested = label,
      engine_used = if (isTRUE(ok)) sf_report_engine(f) else paste("FAILED:", ok),
      size_kb = if (file.exists(f)) round(file.size(f) / 1024) else NA_real_,
      seconds = secs,
      hash_stamped = grepl(substr(hash, 1, 16), body, fixed = TRUE),
      stringsAsFactors = FALSE, row.names = NULL)
    attr(row, "path") <- f
    row
  }
  a <- one("quarto", TRUE)
  b <- one("fallback", FALSE)
  out <- rbind(a, b)
  attr(out, "paths") <- c(attr(a, "path"), attr(b, "path"))
  out
}

#' Render the same inputs twice down the same engine and compare the bodies.
#'
#' Reproducibility means the same instrument and the same data produce the
#' same report. Timestamps and temp paths legitimately differ, so those lines
#' are stripped before the comparison and reported separately, rather than
#' being allowed to hide a real difference or to manufacture a false one.
sf_render_twice <- function(instrument, data = NULL, use_quarto = TRUE, ...) {
  old <- options(surveyframe.use_quarto = use_quarto)
  on.exit(options(old), add = TRUE)
  render_one <- function() {
    f <- tempfile(fileext = ".html")
    suppressMessages(render_report(instrument, data, output_path = f, ...))
    f
  }
  f1 <- render_one(); f2 <- render_one()
  strip <- function(p) {
    x <- readLines(p, warn = FALSE)
    x <- gsub("[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9:]{5,8}", "<TIMESTAMP>", x)
    x <- gsub("/tmp/[A-Za-z0-9_./-]+", "<TMPPATH>", x)
    x <- gsub("surveyframe-report-[A-Za-z0-9]+", "<RENDERDIR>", x)
    x[nzchar(trimws(x))]
  }
  a <- strip(f1); b <- strip(f2)
  list(
    engine = sf_report_engine(f1),
    identical_raw = identical(tools::md5sum(f1)[[1]], tools::md5sum(f2)[[1]]),
    identical_normalised = identical(a, b),
    differing_lines = if (identical(a, b)) 0L else sum(a != b[seq_along(a)], na.rm = TRUE),
    paths = c(f1, f2))
}
