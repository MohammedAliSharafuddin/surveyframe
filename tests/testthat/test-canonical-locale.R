# tests/testthat/test-canonical-locale.R
#
# Session CI (CI run 42014288465). Canonical JSON sorted its keys with
# order(), which follows LC_COLLATE: a C session put "Scale" before
# "ceiling_pct", an en_US one after, so a report source rendered by Quarto's
# R on macOS (en_US) said its numbers differ from the record written under
# R CMD check (C). Keys now sort by code point, as SurveyBuilder's
# sframeJcs() does with JavaScript's sort().

with_collate <- function(locale, code) {
  old <- Sys.getlocale("LC_COLLATE")
  on.exit(Sys.setlocale("LC_COLLATE", old), add = TRUE)
  if (!nzchar(suppressWarnings(Sys.setlocale("LC_COLLATE", locale)))) return(NULL)
  force(code)
}

natural_locale <- function() {
  for (l in c("en_US.UTF-8", "en_GB.UTF-8", "English_United States.1252")) {
    if (!is.null(with_collate(l, TRUE))) return(l)
  }
  NA_character_
}

test_that("canonical JSON sorts keys by code point in every locale", {
  loc <- natural_locale()
  skip_if(is.na(loc), "no en_US or en_GB locale installed")
  x <- list(ceiling_pct = 1, Scale = "a", choices = 2, choice_set = 3, `_id` = 4)
  in_c <- with_collate("C", as.character(surveyframe:::sframe_hash_json(x)))
  in_natural <- with_collate(loc, as.character(surveyframe:::sframe_hash_json(x)))
  expect_identical(in_natural, in_c)
  # Code point order, as JavaScript's Object.keys(x).sort() gives.
  expect_identical(names(jsonlite::fromJSON(in_c)),
                   c("Scale", "_id", "ceiling_pct", "choice_set", "choices"))
})

test_that("a results record and an instrument hash are the same in every locale", {
  loc <- natural_locale()
  skip_if(is.na(loc), "no en_US or en_GB locale installed")
  d <- sframe_demo("likert_scale")
  res <- run_analysis_plan(d$responses, d$instrument)
  record <- function() surveyframe:::sframe_results_record_json(res, d$instrument, 1L)
  hash <- function() surveyframe:::sframe_hex(surveyframe:::sframe_hash_value(d$instrument))
  expect_identical(with_collate(loc, record()), with_collate("C", record()))
  expect_identical(with_collate(loc, hash()), with_collate("C", hash()))
})

# Files hashed before 0.4.3, in the locale's key order (owner, 2026-11-05):
# accepted with a message to save them again, while a tampered file fails.
locale_instrument <- function() {
  ins <- sframe_demo("likert_scale")$instrument
  # Keys whose order differs between the C locale and an English one.
  ins$render$Theme_note <- "x"
  ins$render$accent <- "y"
  ins$meta$title <- "Locale order check"
  ins$amendments <- list()
  ins
}

test_that("a .sframe hashed in the old locale order verifies, with a message", {
  loc <- natural_locale()
  skip_if(is.na(loc), "no en_US or en_GB locale installed")
  ins <- locale_instrument()
  f <- tempfile(fileext = ".sframe")
  with_collate(loc, {
    expect_false(identical(surveyframe:::sframe_hash_value(ins),
                           surveyframe:::sframe_with_locale_order(surveyframe:::sframe_hash_value(ins))))
    surveyframe:::sframe_with_locale_order(write_sframe(ins, f, new_instrument = TRUE))
    expect_message(r <- read_sframe(f), "used before 0.4.3", class = "sframe_locale_order_hash")
    expect_true(attr(r, "sframe_verified"))
    # Saved again, it is hashed in code point order and reads silently.
    g <- tempfile(fileext = ".sframe")
    write_sframe(r, g)
    expect_no_message(read_sframe(g), class = "sframe_locale_order_hash")
    # A tampered copy still fails.
    txt <- sub("(\"accent\": *)\"y\"", "\\1\"z\"", readLines(f))
    h <- tempfile(fileext = ".sframe")
    writeLines(txt, h)
    expect_error(read_sframe(h), "Integrity check failed")
  })
})

test_that("a results record written in the old locale order still matches, with a message", {
  loc <- natural_locale()
  skip_if(is.na(loc), "no en_US or en_GB locale installed")
  d <- sframe_demo("likert_scale")
  # Read in the current hash form and written below in the old one, which no
  # session does, so the read-time origin is dropped.
  attr(d$instrument, "sframe_origin") <- NULL
  dir <- tempfile("locale-source-")
  with_collate(loc, {
    surveyframe:::sframe_with_locale_order(suppressMessages(
      render_report(d$instrument, data = d$responses, output_file = dir, format = "qmd",
                    open = FALSE)))
    msgs <- character(0)
    src <- withCallingHandlers(sframe_report_source(dir), sframe_locale_order_hash = function(m) {
      msgs <<- c(msgs, conditionMessage(m))
      invokeRestart("muffleMessage")
    })
    expect_true(src$check$numbers_match)
    expect_true(any(grepl("results record", msgs, fixed = TRUE)))
    # Changed numbers still differ.
    resp <- utils::read.csv(file.path(dir, "responses.csv"))
    # Within the 1 to 5 scale, so the file still reads.
    resp$org_1[1:5] <- ifelse(resp$org_1[1:5] == 1, 2, 1)
    utils::write.csv(resp, file.path(dir, "responses.csv"), row.names = FALSE)
    src2 <- suppressMessages(sframe_report_source(dir))
    expect_false(src2$check$numbers_match)
  })
})
