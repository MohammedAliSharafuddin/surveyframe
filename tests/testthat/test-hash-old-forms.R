# tests/testthat/test-hash-old-forms.R
# Hashes taken before 0.4.3 (Fable sitting 1 FR-08 and FR-11): a file hashed
# in an English collation reads in a C session, and the verifier page's legacy
# hash is R's.

old_form_instrument <- function() {
  cs <- sframe_choice_set("ag5", 1:5, c("SD", "D", "N", "A", "SA"))
  it <- sframe_item("q1", "Item", type = "likert", choice_set = "ag5")
  x <- sframe_instrument("Old forms", components = list(cs, it))
  # Keys that sort differently in en_US and in C (Fable p04 L-05).
  x$meta$Zeta <- "z"
  x$meta$alpha <- "a"
  x$meta$a_b <- "b"
  x$meta$ab <- "c"
  x
}

test_that("a file hashed before 0.4.3 in en_US order reads in a C session (FR-08)", {
  keys <- c("Zeta", "alpha", "a_b", "ab")
  skip_if(identical(surveyframe:::sframe_collate_order(keys, "en_US"), order(keys, method = "radix")),
          "no en_US collation here")
  f <- tempfile(fileext = ".sframe")
  surveyframe:::sframe_in_form("locale", function() write_sframe(old_form_instrument(), f),
                               collate = "en_US")
  old <- Sys.getlocale("LC_COLLATE")
  on.exit(Sys.setlocale("LC_COLLATE", old), add = TRUE)
  Sys.setlocale("LC_COLLATE", "C")
  expect_message(y <- read_sframe(f), "Save it again", class = "sframe_locale_order_hash")
  expect_true(attr(y, "sframe_verified"))
  expect_identical(Sys.getlocale("LC_COLLATE"), "C")
})

test_that("the verifier page's legacy hash is R's (FR-11)", {
  skip_if(!nzchar(Sys.which("node")), "node is not installed")
  page <- test_path("..", "..", "pkgdown", "extra", "verify", "index.html")
  skip_if(!file.exists(page), "the verifier page is not in this tree")
  texts <- c(
    paste0('{"hash":{"algo":"sha256","value":"x"},"a":0.123456789,',
           '"b":[1e-7,0.00025,0.12345,2147483648.25,12345678901.123456,1e16,',
           '123456789012345678,-1.2e-5,99999.99999,7.00025,1e-5,9.99e-6,3,-3e10,',
           '0.5,1234.5678],"c":null,"d":"x </b> y","e":{},"f":[],"g":true}'),
    '{"hash":{"algo":"sha256","value":""},"meta":{"title":"T","w":[0.1,0.25,1e15]}}')
  r <- vapply(texts, function(t) {
    surveyframe:::sframe_legacy_hash_payload(jsonlite::parse_json(t, simplifyVector = FALSE))
  }, "", USE.NAMES = FALSE)
  inp <- tempfile(fileext = ".json")
  out <- tempfile(fileext = ".json")
  writeLines(jsonlite::toJSON(texts), inp, useBytes = TRUE)
  system2("node", c(shQuote(test_path("fixtures", "canonical", "canon_hash.js")),
                    shQuote(page), "legacy", shQuote(inp), shQuote(out)))
  js <- vapply(jsonlite::read_json(out), function(z) if (is.null(z$hash)) "" else z$hash, "")
  expect_identical(js, r)
})
