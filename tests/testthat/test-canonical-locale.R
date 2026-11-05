# tests/testthat/test-canonical-locale.R
#
# Session CI (CI run 42014288465). Canonical JSON sorted its keys with
# order(), which follows LC_COLLATE: a C session put "Scale" before
# "ceiling_pct", an en_US one after, so a report source rendered by Quarto's
# R on macOS (en_US) said its numbers differ from the record written under
# R CMD check (C). Keys now sort by code point, as SurveyBuilder's
# sframeCanon() does with JavaScript's sort().

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
