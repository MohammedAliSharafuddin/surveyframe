# tests/testthat/test-ui-plurals.R
#
# Studio and the builder print "1 respondent" and "0 respondents", never the
# template plural "respondent(s)" (Codex P1-08). The source check reads every
# line of app.R and the builder that is not a comment, so a new "(s)" fails
# here before it reaches a screen.

ui_plural_sites <- function(path) {
  lines <- readLines(path, warn = FALSE)
  code <- !grepl("^\\s*(#|//|/\\*|\\*)", lines)
  # A lower-case word after a space or a quote, so calls such as
  # String(s), .test(s), function(s) and function esc(s) are not plurals.
  hit <- grepl("(?<!function)(^|[\\s'\">])(?!function\\()[a-z]+\\((s|es)\\)", lines, perl = TRUE) & code
  if (!any(hit)) return(character(0))
  paste0(basename(path), ":", which(hit))
}

test_that("Studio and the builder hold no '(s)' plural in any string they show (P1-08)", {
  files <- c(
    system.file("shiny", "app.R", package = "surveyframe"),
    system.file("builder", "survey_builder.html", package = "surveyframe"),
    system.file("builder", "field_tools.js", package = "surveyframe")
  )
  expect_true(all(nzchar(files)))
  expect_identical(unlist(lapply(files, ui_plural_sites)), character(0))
})

# Every string constant in the package's R functions, walked from the parsed
# code so it runs on the installed package. A message counts in words, "1
# item" and "2 items", never "item(s)" (Session LF, R plurals).
r_plural_strings <- function() {
  strings <- function(e) {
    if (is.character(e)) return(e)
    if (is.call(e) || is.pairlist(e) || is.expression(e)) {
      return(unlist(lapply(as.list(e), function(x) if (missing(x)) NULL else strings(x))))
    }
    if (is.function(e)) return(c(strings(formals(e)), strings(body(e))))
    NULL
  }
  ns <- asNamespace("surveyframe")
  out <- character(0)
  for (nm in ls(ns, all.names = TRUE)) {
    f <- get(nm, envir = ns)
    if (!is.function(f) || is.primitive(f)) next
    hit <- grep("[A-Za-z]\\((s|es)\\)", strings(f), value = TRUE)
    if (length(hit)) out <- c(out, paste0(nm, ": ", hit))
  }
  out
}

test_that("R messages hold no '(s)' plural (Session LF)", {
  expect_identical(r_plural_strings(), character(0))
})

# studio_validate_plan_roles() from app.R, parsed without running the app,
# against a registry of 1 method with a role of at most 1 and 1 of at most 3.
ui_roles_env <- function() {
  app <- system.file("shiny", "app.R", package = "surveyframe")
  skip_if(!nzchar(app), "studio app not available")
  exprs <- parse(app, keep.source = FALSE)
  pick <- Filter(function(e) is.call(e) && identical(e[[1]], as.name("<-")) &&
                   identical(e[[2]], as.name("studio_validate_plan_roles")), exprs)
  expect_length(pick, 1)
  env <- new.env(parent = asNamespace("surveyframe"))
  eval(pick[[1]], envir = env)
  env$analysis_registry <- list(m = list(roles = list(
    list(id = "x", label = "Predictor", min = 0, max = 1),
    list(id = "y", label = "Outcomes", min = 0, max = 3))))
  env
}

test_that("a role's maximum is counted in words, singular for 1 (P1-08)", {
  env <- ui_roles_env()
  msg <- env$studio_validate_plan_roles("m", list(x = c("a", "b"), y = c("a", "b", "c", "d")))
  expect_identical(msg$messages, c("Predictor allows at most 1 selection.",
                          "Outcomes allows at most 3 selections."))
})
