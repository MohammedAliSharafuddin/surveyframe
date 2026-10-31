# tests/testthat/test-generated-syntax-runs.R
# The syntax generators emit code for engines this package never runs, so these
# tests fit the generated syntax rather than matching it as a string.
#
# Parsing is not enough: a mediation model once produced syntax lavaan accepted
# and then refused to fit, because the indirect effect referred to path labels
# that were never written.

syntax_instrument <- function() {
  items <- list()
  for (s in c("SAT", "TRU", "LOY")) {
    for (i in 1:3) {
      items <- c(items, list(sframe_item(paste0(tolower(s), i), paste(s, i),
                                     type = "likert", choice_set = "ag5",
                                     scale_id = s)))
    }
  }
  sframe_instrument(
    title = "Syntax", version = "1.0.0",
    components = c(
      list(sframe_choice_set("ag5", 1:5, as.character(1:5))),
      items,
      list(sframe_scale("SAT", "Satisfaction", items = paste0("sat", 1:3)),
           sframe_scale("TRU", "Trust",        items = paste0("tru", 1:3)),
           sframe_scale("LOY", "Loyalty",      items = paste0("loy", 1:3)))
    )
  )
}

mediation_model <- function(labels = FALSE) {
  lab <- function(x) if (labels) x else NULL
  sframe_model_spec(
    id = "m1", type = "cb_sem", engine = "lavaan",
    constructs = list(
      sframe_construct("SAT", items = paste0("sat", 1:3)),
      sframe_construct("TRU", items = paste0("tru", 1:3)),
      sframe_construct("LOY", items = paste0("loy", 1:3))
    ),
    paths = list(
      sframe_path("SAT", "TRU", label = lab("a")),
      sframe_path("TRU", "LOY", label = lab("b")),
      sframe_path("SAT", "LOY", label = lab("c"))
    ),
    indirect = list(sframe_indirect_effect(from = "SAT", through = "TRU", to = "LOY"))
  )
}

# Data with a known mediation structure, so a fit that runs can also be checked
# for having estimated something sensible rather than merely not erroring.
mediation_data <- function(n = 300, seed = 42) {
  set.seed(seed)
  f_sat <- stats::rnorm(n)
  f_tru <- 0.6 * f_sat + stats::rnorm(n, sd = 0.8)
  f_loy <- 0.5 * f_tru + 0.3 * f_sat + stats::rnorm(n, sd = 0.8)
  ind <- function(f) {
    as.data.frame(lapply(1:3, function(i) {
      round(pmin(5, pmax(1, 3 + f + stats::rnorm(n, sd = 0.6))))
    }))
  }
  d <- cbind(ind(f_sat), ind(f_tru), ind(f_loy))
  names(d) <- c(paste0("sat", 1:3), paste0("tru", 1:3), paste0("loy", 1:3))
  d
}

test_that("sframe_syntax_cfa() output parses and fits", {
  skip_if_not_installed("lavaan")
  syn <- sframe_syntax_cfa(syntax_instrument())
  expect_no_error(lavaan::lavParseModelString(syn))
  fit <- lavaan::cfa(syn, data = mediation_data())
  expect_true(lavaan::lavInspect(fit, "converged"))
})

test_that("a mediation model's generated syntax fits, not merely parses", {
  skip_if_not_installed("lavaan")
  syn <- sframe_syntax_sem(mediation_model(), syntax_instrument())

  # the regression: every label the := lines multiply must be defined on a
  # structural path, or lavaan rejects the model at fit time
  expect_no_error(lavaan::lavParseModelString(syn))
  fit <- expect_no_error(lavaan::sem(syn, data = mediation_data()))
  expect_true(lavaan::lavInspect(fit, "converged"))

  pe <- lavaan::parameterEstimates(fit)
  defined <- pe[pe$op == ":=", ]
  expect_true("indirect_SAT_TRU_LOY" %in% defined$label)
  # simulated truth: indirect = 0.6 * 0.5 = 0.30, attenuated by measurement
  # error, so a wide band that still fails if the estimate is nonsense
  est <- defined$est[defined$label == "indirect_SAT_TRU_LOY"]
  expect_true(est > 0.1 && est < 0.5)
})

test_that("an unlabelled path an indirect effect walks is labelled in the output", {
  # The generator derives a label for the := line. Before the fix it did not
  # write that label onto the path, so the definition referenced a name lavaan
  # had never seen.
  syn <- sframe_syntax_sem(mediation_model(), syntax_instrument())
  defined <- unlist(regmatches(syn, gregexpr("[A-Za-z0-9_]+(?=\\*)", syn, perl = TRUE)))
  used <- unlist(regmatches(syn, gregexpr("(?<=:= )[A-Za-z0-9_*+ ]+", syn, perl = TRUE)))
  used <- unlist(strsplit(gsub("[+ ]", "*", used), "*", fixed = TRUE))
  used <- setdiff(trimws(used[nzchar(used)]), "")
  # every name multiplied or added in a := line is either a defined path label
  # or another := effect name
  effects <- unlist(regmatches(syn, gregexpr("[A-Za-z0-9_]+(?= :=)", syn, perl = TRUE)))
  expect_true(all(used %in% c(defined, effects)))
})

test_that("hand-labelled paths keep their labels", {
  syn <- sframe_syntax_sem(mediation_model(labels = TRUE), syntax_instrument())
  expect_match(syn, "TRU ~ a*SAT", fixed = TRUE)
  expect_match(syn, "indirect_SAT_TRU_LOY := a*b", fixed = TRUE)
  expect_match(syn, "total_SAT_LOY := c + indirect_SAT_TRU_LOY", fixed = TRUE)
})

test_that("a model without indirect effects generates unlabelled paths as before", {
  plain <- sframe_model_spec(
    id = "m2", type = "cb_sem", engine = "lavaan",
    constructs = list(
      sframe_construct("SAT", items = paste0("sat", 1:3)),
      sframe_construct("LOY", items = paste0("loy", 1:3))
    ),
    paths = list(sframe_path("SAT", "LOY"))
  )
  syn <- sframe_syntax_sem(plain, syntax_instrument())
  expect_match(syn, "LOY ~ SAT", fixed = TRUE)
  expect_false(grepl("SAT__LOY", syn, fixed = TRUE))
})

test_that("sframe_syntax_pls() output is runnable R code", {
  skip_if_not_installed("seminr")
  m <- sframe_model_spec(
    id = "p1", type = "pls_sem", engine = "seminr",
    constructs = list(
      sframe_construct("SAT", items = paste0("sat", 1:3), mode = "composite"),
      sframe_construct("LOY", items = paste0("loy", 1:3), mode = "composite")
    ),
    paths = list(sframe_path("SAT", "LOY"))
  )
  code <- sframe_syntax_pls(m)
  exprs <- expect_no_error(parse(text = code))

  # Run everything up to the fit. The bootstrap is skipped because 5000
  # resamples is not a unit test, but the specification and the estimation are
  # the parts that can be generated wrongly.
  env <- new.env(parent = globalenv())
  assign("data", mediation_data(), envir = env)
  for (e in exprs) {
    txt <- paste(deparse(e), collapse = " ")
    if (grepl("bootstrap_model|boot_model|boot_summary", txt)) next
    eval(e, envir = env)
  }
  expect_true(exists("pls_model", envir = env))
  expect_s3_class(get("pls_model", envir = env), "seminr_model")
})
