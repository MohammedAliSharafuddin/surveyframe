# tests/testthat/test-weight-check.R
# D6 (CX-09). One weight check for every weighted method: a negative or
# non-finite weight and an all-zero total are block errors, and a missing
# weight drops its row and says so.

weight_instr <- function() {
  sf_instrument(
    "Weights",
    components = list(
      sf_choices("col", values = c("red", "blue"), labels = c("Red", "Blue")),
      sf_item("colour", "Colour", type = "single_choice", choice_set = "col"),
      sf_item("shape", "Shape", type = "single_choice", choice_set = "col"),
      sf_item("score", "Score", type = "numeric")
    )
  )
}

weight_data <- function(w) {
  data.frame(colour = c("red", "red", "blue", "blue", "red"),
             shape = c("red", "blue", "blue", "red", "red"),
             score = c(1, 2, 3, 4, 5), w = w, stringsAsFactors = FALSE)
}

weight_block <- function(test, roles) {
  list(id = "RQ1", research_question = "Q", method = test, test = test,
       roles = roles, variables = unlist(roles), options = list())
}

blocks <- function() {
  list(
    frequency = weight_block("frequency", list(variables = "colour", weights = "w")),
    crosstab = weight_block("crosstab", list(row = "colour", column = "shape", weights = "w")),
    descriptives = weight_block("descriptives", list(variables = "score", weights = "w"))
  )
}

run_all <- function(w) {
  lapply(blocks(), function(b) {
    suppressWarnings(sframe_run_one_block(b, weight_data(w), weight_instr()))
  })
}

test_that("negative and non-finite weights are block errors naming the column", {
  for (bad in list(c(1, -1, 1, 1, 1), c(1, Inf, 1, 1, 1))) {
    res <- run_all(bad)
    for (nm in names(res)) {
      expect_match(res[[nm]]$error %||% "", "'w'", info = nm)
      expect_match(res[[nm]]$error %||% "", "1 ", info = nm)
    }
  }
})

test_that("an all-zero total is a block error", {
  res <- run_all(rep(0, 5))
  for (nm in names(res)) expect_match(res[[nm]]$error %||% "", "zero", info = nm)
})

test_that("a missing weight drops its row and the result says how many", {
  res <- run_all(c(1, NA, 1, 2, 1))
  expect_null(res$frequency$error)
  expect_equal(res$frequency$weights_dropped, 1)
  expect_match(res$frequency$note, "1 row")
  expect_match(res$frequency$apa, "1 row")
  expect_equal(res$frequency$n, 4)
  expect_equal(res$crosstab$weights_dropped, 1)
  expect_equal(res$crosstab$n, 4)
  expect_match(res$crosstab$note, "1 row")
})

test_that("valid weights add no note", {
  res <- run_all(c(1, 2, 1, 2, 1))
  expect_null(res$frequency$error)
  expect_equal(res$frequency$weights_dropped, 0)
  expect_null(res$frequency$note)
})

test_that("a weight that is text and not a number is refused, not dropped", {
  chk <- sframe_check_weights(c("1", "2", "heavy", NA, ""), "w")
  expect_match(chk$error, "'w' has 1 ")
  ok <- sframe_check_weights(c("1", "2", NA, ""), "w")
  expect_null(ok$error)
  expect_equal(ok$dropped, 2)
})
