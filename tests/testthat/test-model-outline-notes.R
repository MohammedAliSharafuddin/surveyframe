# tests/testthat/test-model-outline-notes.R
# model_report_template() gives each model type its own reporting notes, and a
# PLS-SEM outline lists each construct under the checks for its measurement
# mode. The seminr script's assessment section follows the same split.

outline_cons <- function(mode = "reflective") {
  list(
    sf_construct("A", items = paste0("a", 1:3), mode = mode),
    sf_construct("B", items = paste0("b", 1:3), mode = mode)
  )
}

test_that("an EFA outline asks for EFA reporting only", {
  m <- sf_model("e", type = "efa", constructs = outline_cons())
  txt <- model_report_template(m, include_json = FALSE)
  expect_false(grepl("fit indices|structural path|indirect", txt,
                     ignore.case = TRUE))
  expect_match(txt, "KMO")
  expect_match(txt, "Bartlett")
  expect_match(txt, "rotation", ignore.case = TRUE)
  expect_match(txt, "cross-loading", ignore.case = TRUE)
})

test_that("a CFA outline asks for the CFA fit and validity reports", {
  m <- sf_model("c", type = "cfa", constructs = outline_cons())
  txt <- model_report_template(m, include_json = FALSE)
  for (w in c("CFI", "TLI", "RMSEA", "SRMR", "AVE", "estimator")) {
    expect_match(txt, w, ignore.case = FALSE)
  }
  expect_false(grepl("indirect", txt, ignore.case = TRUE))
})

test_that("a CB-SEM outline adds the structural reports to the CFA ones", {
  m <- sf_model("s", type = "cb_sem", constructs = outline_cons(),
                paths = list(sf_path("A", "B")))
  txt <- model_report_template(m, include_json = FALSE)
  for (w in c("CFI", "RMSEA", "SRMR", "R squared", "indirect", "bootstrap")) {
    expect_match(txt, w, ignore.case = TRUE)
  }
})

pls_outline_model <- function(indirect = list()) {
  sf_model("p", type = "pls_sem", engine = "seminr",
    constructs = list(
      sf_construct("REF", items = paste0("r", 1:3), mode = "reflective"),
      sf_construct("FOR", items = paste0("f", 1:3), mode = "formative"),
      sf_construct("SIN", items = "s1", mode = "single_item")
    ),
    paths = list(sf_path("REF", "SIN"), sf_path("FOR", "SIN")),
    indirect = indirect)
}

test_that("a PLS-SEM outline lists each construct under its own checks", {
  txt <- model_report_template(pls_outline_model(), include_json = FALSE)
  expect_false(grepl("CFI|RMSEA|SRMR|TLI", txt))
  expect_match(txt, "doi:10.1007/978-3-030-80519-7", fixed = TRUE)
  expect_match(txt, "Hair, Hult, Ringle, Sarstedt, Danks and Ray (2021)",
               fixed = TRUE)
  sec <- function(head) {
    i <- grep(head, strsplit(txt, "\n")[[1]], fixed = TRUE)
    lines <- strsplit(txt, "\n")[[1]]
    nxt <- which(grepl("^### ", lines) & seq_along(lines) > i)
    paste(lines[i:(if (length(nxt)) nxt[1] - 1 else length(lines))],
          collapse = "\n")
  }
  refl <- sec("### Reflective constructs")
  form <- sec("### Formative constructs")
  sing <- sec("### Single-item constructs")
  expect_match(refl, "REF"); expect_false(grepl("FOR|SIN", refl))
  expect_match(form, "FOR"); expect_false(grepl("REF|SIN", form))
  expect_match(sing, "SIN"); expect_false(grepl("REF|FOR", sing))
  expect_match(refl, "HTMT"); expect_match(refl, "AVE")
  expect_match(form, "VIF"); expect_match(form, "weights")
  expect_match(sing, "no reliability", ignore.case = TRUE)
  expect_match(txt, "f squared", ignore.case = TRUE)
  expect_match(txt, "PLSpredict")
})

test_that("PLS-SEM mediation notes appear only when indirect effects are declared", {
  none <- model_report_template(pls_outline_model(), include_json = FALSE)
  expect_false(grepl("indirect", none, ignore.case = TRUE))
  m <- pls_outline_model(list(sf_indirect("REF", through = "FOR", to = "SIN")))
  m$structural$paths <- c(m$structural$paths, list(sf_path("REF", "FOR")))
  has <- model_report_template(m, include_json = FALSE)
  expect_match(has, "indirect", ignore.case = TRUE)
})

test_that("the seminr assessment section follows each construct's mode", {
  code <- seminr_syntax(pls_outline_model())
  expect_match(code, "htmt", ignore.case = TRUE)
  expect_match(code, "vif_items", fixed = TRUE)
  expect_match(code, "bootstrapped_weights", fixed = TRUE)
  expect_no_error(parse(text = code))
  only_ref <- sf_model("p", type = "pls_sem", engine = "seminr",
    constructs = list(sf_construct("A", items = paste0("a", 1:3), mode = "reflective"),
                      sf_construct("B", items = "b1", mode = "single_item")),
    paths = list(sf_path("A", "B")))
  code2 <- seminr_syntax(only_ref)
  expect_false(grepl("bootstrapped_weights|vif_items", code2))
})
