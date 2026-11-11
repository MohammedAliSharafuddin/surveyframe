# tests/testthat/test-canonical-form.R
# The canonical form R, SurveyBuilder and the verifier page hash: RFC 8785, the
# JSON Canonicalization Scheme (Codex pass 2 P2-01 and P2-06, Fable sitting 1
# FR-01, FR-02, FR-03, FR-09, FR-10 and FR-12). The cases are shared with the
# JavaScript twins through fixtures/canonical/cases.tsv and run in node.

canon_cases <- function() {
  lines <- readLines(test_path("fixtures", "canonical", "cases.tsv"), encoding = "UTF-8")
  lines <- lines[nzchar(lines) & !startsWith(lines, "#")]
  parts <- strsplit(lines, "\t", fixed = TRUE)
  data.frame(
    id = vapply(parts, `[`, "", 1),
    text = vapply(parts, `[`, "", 2),
    expect = vapply(parts, function(p) if (length(p) >= 3) p[3] else "", ""),
    stringsAsFactors = FALSE)
}

# The expected column writes characters from U+0080 up as \u escapes, which the
# canonical form holds as they are.
canon_unescape <- function(s) {
  m <- gregexpr("\\\\u[0-9a-fA-F]{4}", s)
  regmatches(s, m) <- lapply(regmatches(s, m), function(x) {
    cp <- strtoi(substring(x, 3), 16L)
    ifelse(cp >= 0x80, vapply(cp, intToUtf8, ""), x)
  })
  s
}

canon_r <- function(text) {
  bad <- surveyframe:::sframe_escape_problem(text)
  if (!is.null(bad)) return(list(refused = bad[["kind"]]))
  p <- jsonlite::parse_json(text, simplifyVector = FALSE)
  dup <- surveyframe:::sframe_duplicate_key(p)
  if (!is.null(dup)) return(list(dup = dup[["key"]]))
  if (!is.null(names(p)) && is.list(p$hash)) p$hash$value <- ""
  canon <- surveyframe:::sframe_jcs(p)
  list(canon = canon, hash = surveyframe:::sframe_sha256_json(canon))
}

canon_pages <- function() {
  pages <- c(builder = system.file("builder", "survey_builder.html", package = "surveyframe"),
             verifier = test_path("..", "..", "pkgdown", "extra", "verify", "index.html"))
  pages[file.exists(pages)]
}

canon_node <- function(page, texts, mode = "hash") {
  inp <- tempfile(fileext = ".json")
  out <- tempfile(fileext = ".json")
  on.exit(unlink(c(inp, out)), add = TRUE)
  writeLines(jsonlite::toJSON(texts), inp, useBytes = TRUE)
  status <- system2("node", c(shQuote(test_path("fixtures", "canonical", "canon_hash.js")),
                              shQuote(page), mode, shQuote(inp), shQuote(out)))
  expect_equal(status, 0L)
  jsonlite::read_json(out, simplifyVector = FALSE)
}

skip_if_no_node <- function() {
  skip_if(!nzchar(Sys.which("node")), "node is not installed")
}

canon_instrument <- function() {
  cs <- sframe_choice_set("ag5", 1:5, c("SD", "D", "N", "A", "SA"))
  it <- lapply(1:4, function(i) sframe_item(paste0("s_", i), paste("Item", i),
                                            type = "likert", choice_set = "ag5",
                                            scale_id = "sat"))
  sc <- sframe_scale("sat", "Satisfaction", items = paste0("s_", 1:4))
  sframe_instrument("Canonical probe", components = c(list(cs, sc), it))
}

test_that("the canonical form follows RFC 8785 on every pinned case", {
  cases <- canon_cases()
  pinned <- cases[nzchar(cases$expect), ]
  expect_gt(nrow(pinned), 30)
  for (i in seq_len(nrow(pinned))) {
    expect_identical(canon_r(pinned$text[i])$canon, canon_unescape(pinned$expect[i]),
                     label = pinned$id[i])
  }
})

test_that("null and {} hash differently, as do numbers apart in the 17th digit (P2-01, FR-10)", {
  h <- function(t) canon_r(t)$hash
  expect_false(identical(h('{"a":null}'), h('{"a":{}}')))
  expect_false(identical(h('{"a":0.1}'), h('{"a":0.10000000000000002}')))
  expect_false(identical(h('{"a":[]}'), h('{"a":{}}')))
})

test_that("R, SurveyBuilder and the verifier page give 1 hash for every shared case", {
  skip_if_no_node()
  cases <- canon_cases()
  r <- lapply(cases$text, canon_r)
  pages <- canon_pages()
  expect_true("builder" %in% names(pages))
  for (page in names(pages)) {
    js <- canon_node(pages[[page]], cases$text)
    for (i in seq_len(nrow(cases))) {
      expect_identical(js[[i]], r[[i]], label = paste(cases$id[i], page))
    }
  }
})

test_that("the builder and the verifier page carry the same canonical block", {
  pages <- canon_pages()
  skip_if(length(pages) < 2, "the verifier page is not in this tree")
  block <- function(p) {
    x <- paste(readLines(p, encoding = "UTF-8"), collapse = "\n")
    regmatches(x, regexpr("// sframe-canon:begin.*// sframe-canon:end", x))
  }
  expect_length(block(pages[["builder"]]), 1)
  expect_identical(block(pages[["builder"]]), block(pages[["verifier"]]))
})

test_that("a file R writes verifies in both JavaScript twins (FR-01, FR-02, FR-03)", {
  skip_if_no_node()
  variants <- list(
    weight_1e7 = function(x) { x$scales[[1]]$weights <- c(1e-7, 1, 1, 1); x },
    weight_small = function(x) { x$scales[[1]]$weights <- c(0.00001, 1, 1, 1); x },
    weight_17 = function(x) { x$scales[[1]]$weights <- c(0.1 + 0.2, 1 / 3, 1, 1); x },
    weight_1e15 = function(x) { x$scales[[1]]$weights <- c(1e15, 1, 1, 1); x },
    html_label = function(x) { x$items[[1]]$label <- "Rate the <b>service</b> </script>"; x },
    line_sep = function(x) { x$items[[1]]$label <- paste0("a", intToUtf8(0x2028), "b"); x },
    na_help = function(x) { x$items[[1]]$help <- NA; x },
    na_author = function(x) { x$meta$authors <- c("A", NA); x }
  )
  texts <- character(0)
  for (v in names(variants)) {
    f <- tempfile(fileext = ".sframe")
    write_sframe(variants[[v]](canon_instrument()), f)
    expect_true(attr(read_sframe(f), "sframe_verified"), label = v)
    texts[v] <- paste(readLines(f, encoding = "UTF-8"), collapse = "\n")
  }
  stored <- vapply(texts, function(t) jsonlite::parse_json(t)$hash$value, "")
  for (page in canon_pages()) {
    js <- canon_node(page, unname(texts))
    expect_identical(vapply(js, function(r) if (is.null(r$hash)) "" else r$hash, ""), unname(stored))
  }
})

test_that("a file SurveyBuilder saves reads back verified in R", {
  skip_if_no_node()
  base <- paste0(
    '{"sframe_format":"1.0","hash":{"algo":"sha256","value":""},"version":"1.0.0",',
    '"meta":{"title":"T","version":"1.0.0","probe":%s},',
    '"items":[{"id":"q1","label":"L","type":"text","required":false,"reverse":false}],',
    '"choices":[],"scales":[],"branching":[],"checks":[],"analysis_plan":[],',
    '"models":[],"render":{}}')
  tokens <- c("0.30000000000000004", "0.3333333333333333", "0.00001", "0.0000001",
              "1.5e-7", "1e21", "1000000000000000", '"a </script> b"', "null", "{}",
              '{"10":1,"9":2,"":3}')
  sealed <- canon_node(canon_pages()[["builder"]], sprintf(base, tokens), mode = "seal")
  for (i in seq_along(tokens)) {
    f <- tempfile(fileext = ".sframe")
    writeLines(sealed[[i]]$text, f, useBytes = TRUE)
    expect_true(attr(read_sframe(f, validate = FALSE), "sframe_verified"), label = tokens[i])
  }
})

test_that("read_sframe() refuses a file that gives a key twice (FR-12)", {
  f <- tempfile(fileext = ".sframe")
  write_sframe(canon_instrument(), f)
  txt <- paste(readLines(f), collapse = "\n")
  txt <- sub('"items":', '"items": [],\n  "items":', txt, fixed = TRUE)
  writeLines(txt, f)
  expect_error(read_sframe(f), "\"items\" in \\$ appears more than once",
               class = "sframe_import_error")
})

test_that("an NA in a text field writes a file that reads back verified (FR-01)", {
  x <- canon_instrument()
  x$items[[1]]$help <- NA
  x$meta$authors <- c("A", NA)
  f <- tempfile(fileext = ".sframe")
  write_sframe(x, f)
  y <- read_sframe(f)
  expect_true(attr(y, "sframe_verified"))
  expect_identical(y$meta$authors, c("A", NA))
})

test_that("a number JSON cannot hold is refused at write with its field named", {
  x <- canon_instrument()
  x$meta$probe <- Inf
  expect_error(write_sframe(x, tempfile(fileext = ".sframe")), "\\$\\.meta\\.probe is Inf",
               class = "sframe_canonical_error")
})

test_that("a file hashed in the 0.4.3 development form reads with the save-again message", {
  x <- canon_instrument()
  # The 2 forms write 0.00001 as 1e-05 and 0.00001.
  x$scales[[1]]$weights <- c(0.00001, 1, 1, 1)
  f <- tempfile(fileext = ".sframe")
  surveyframe:::sframe_in_form("dev", function() write_sframe(x, f))
  expect_message(y <- read_sframe(f), "Save it again", class = "sframe_locale_order_hash")
  expect_true(attr(y, "sframe_verified"))
  g <- tempfile(fileext = ".sframe")
  write_sframe(y, g)
  expect_no_message(read_sframe(g), class = "sframe_locale_order_hash")
})

test_that("read_sframe() refuses an escaped NUL or a lone surrogate (coordinator, after milestone 1)", {
  f <- tempfile(fileext = ".sframe")
  x <- canon_instrument()
  x$items[[1]]$label <- "abcXdef"
  write_sframe(x, f)
  txt <- paste(readLines(f, encoding = "UTF-8"), collapse = "\n")
  # jsonlite cut "abc\u0000def" to "abc", so a change after the NUL kept the hash.
  writeLines(sub("abcXdef", "abc\\u0000xyz", txt, fixed = TRUE), f)
  expect_error(read_sframe(f), "U\\+0000", class = "sframe_import_error")
  writeLines(sub("abcXdef", "abc\\ud800def", txt, fixed = TRUE), f)
  expect_error(read_sframe(f), "lone surrogate", class = "sframe_import_error")
  # An escaped backslash before u0000 is plain text, refused only as an edit.
  writeLines(sub("abcXdef", "abc\\\\u0000def", txt, fixed = TRUE), f)
  expect_error(read_sframe(f), "Integrity check failed", class = "sframe_import_error")
})
