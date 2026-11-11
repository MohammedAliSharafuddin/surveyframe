# tests/testthat/test-hash-canonical.R
# The hash names the canonical form it was taken in, hash.canonical = "rfc8785"
# (owner, through the coordinator, 2026-11-11, Session CF-A). R, SurveyBuilder
# and the verifier page give each file in fixtures/canonical/hash_canonical the
# verdict verdicts.tsv names: ok, legacy (accepted with "Save it again"), fail
# (integrity check failed) or refused (a form this version does not know).

hc_dir <- function() test_path("fixtures", "canonical", "hash_canonical")

hc_cases <- function() {
  x <- utils::read.delim(file.path(hc_dir(), "verdicts.tsv"), comment.char = "#",
                         header = FALSE, col.names = c("file", "verdict", "what"),
                         stringsAsFactors = FALSE)
  x$text <- vapply(x$file, function(f) {
    paste(readLines(file.path(hc_dir(), f), encoding = "UTF-8"), collapse = "\n")
  }, "", USE.NAMES = FALSE)
  x
}

hc_r_verdict <- function(text) {
  msg <- FALSE
  tryCatch({
    withCallingHandlers(read_sframe(text = text), sframe_locale_order_hash = function(m) {
      msg <<- TRUE
      invokeRestart("muffleMessage")
    })
    if (msg) "legacy" else "ok"
  }, sframe_import_error = function(e) {
    if (grepl("Integrity check failed", conditionMessage(e))) "fail" else "refused"
  })
}

# The builder's own openSframeText(), under V8, judged by the toast it shows
# once its hash check has run.
hc_builder_verdict <- function(text) {
  ctx <- builder_context()
  ctx$call("openSframeText", text)
  ctx$eval("Promise.resolve(1)", await = TRUE)
  toasts <- vapply(builder_toasts_list(ctx), function(t) t$msg, "")
  last <- toasts[length(toasts)]
  if (!length(last)) return("none")
  if (grepl("newer surveyframe", last)) return("refused")
  if (grepl("Save it again", last)) return("legacy")
  if (grepl("integrity verified", last)) return("ok")
  if (grepl("mismatch", last)) return("fail")
  last
}

builder_toasts_list <- function(ctx) {
  jsonlite::parse_json(ctx$eval("JSON.stringify(__toasts)"), simplifyVector = FALSE)
}

test_that("write_sframe() writes hash.canonical inside the hashed content", {
  x <- sframe_instrument("Canonical field", components = list(
    sframe_item("q1", "Item", type = "text")))
  f <- tempfile(fileext = ".sframe")
  write_sframe(x, f)
  h <- jsonlite::read_json(f)$hash
  expect_identical(h$canonical, "rfc8785")
  expect_identical(names(h), c("algo", "value", "canonical"))
  # Hashed with the field: the hash of the same content without it differs.
  p <- jsonlite::read_json(f, simplifyVector = FALSE)
  without <- p
  without$hash$canonical <- NULL
  expect_false(identical(surveyframe:::sframe_hash_payload(p, parsed = TRUE),
                         surveyframe:::sframe_hash_payload(without, parsed = TRUE)))
  expect_identical(surveyframe:::sframe_hash_payload(p, parsed = TRUE), h$value)
})

test_that("read_sframe() gives each hash.canonical case its verdict", {
  cases <- hc_cases()
  expect_identical(nrow(cases), 8L)
  for (i in seq_len(nrow(cases))) {
    expect_identical(hc_r_verdict(cases$text[i]), cases$verdict[i], label = cases$file[i])
  }
  expect_error(read_sframe(file.path(hc_dir(), "unknown_value.sframe")),
               "canonical form as \"rfc9999\".*needs a newer surveyframe",
               class = "sframe_import_error")
  expect_error(read_sframe(file.path(hc_dir(), "unknown_null.sframe")),
               "canonical form as null", class = "sframe_import_error")
})

test_that("SurveyBuilder gives each hash.canonical case R's verdict", {
  cases <- hc_cases()
  for (i in seq_len(nrow(cases))) {
    expect_identical(hc_builder_verdict(cases$text[i]), cases$verdict[i], label = cases$file[i])
  }
})

test_that("the verifier page gives each hash.canonical case R's verdict", {
  skip_if(!nzchar(Sys.which("node")), "node is not installed")
  page <- test_path("..", "..", "pkgdown", "extra", "verify", "index.html")
  skip_if(!file.exists(page), "the verifier page is not in this tree")
  cases <- hc_cases()
  inp <- tempfile(fileext = ".json")
  out <- tempfile(fileext = ".json")
  writeLines(jsonlite::toJSON(cases$text), inp, useBytes = TRUE)
  status <- system2("node", c(shQuote(test_path("fixtures", "canonical", "canon_hash.js")),
                              shQuote(page), "verdict", shQuote(inp), shQuote(out)))
  expect_equal(status, 0L)
  js <- jsonlite::read_json(out, simplifyVector = FALSE)
  for (i in seq_len(nrow(cases))) {
    expect_identical(js[[i]]$verdict, cases$verdict[i], label = cases$file[i])
  }
  expect_match(js[[which(cases$file == "unknown_value.sframe")]]$message,
               "rfc9999.*newer surveyframe")
})

test_that("a file SurveyBuilder saves names rfc8785 and reads back with no message", {
  ctx <- builder_context()
  builder_open(ctx, read_sframe(file.path(hc_dir(), "present.sframe")))
  f <- builder_save(ctx)
  expect_identical(jsonlite::read_json(f)$hash$canonical, "rfc8785")
  expect_no_message(y <- read_sframe(f), class = "sframe_locale_order_hash")
  expect_true(attr(y, "sframe_verified"))
})
