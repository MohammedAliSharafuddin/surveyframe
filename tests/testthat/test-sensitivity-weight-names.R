# tests/testthat/test-sensitivity-weight-names.R
# Named weights match criteria by name in sensitivity_analysis(), as the
# ranking blocks already do. Unknown or missing names are errors, unnamed
# weights stay positional.

wn_args <- function(...) {
  utils::modifyList(
    list(
      x = matrix(c(4.1, 3.0, 210, 3.6, 4.5, 180, 4.8, 2.5, 260, 3.9, 4.0, 150),
                 nrow = 4, byrow = TRUE,
                 dimnames = list(c("A", "B", "C", "D"),
                                 c("service", "location", "price"))),
      weights = c(0.5, 0.3, 0.2),
      criteria_types = c("benefit", "benefit", "cost"),
      method = "topsis"),
    list(...))
}

test_that("named weights in another order give the same result as in order", {
  ordered <- do.call(sensitivity_analysis,
                     wn_args(weights = c(service = 0.5, location = 0.3,
                                         price = 0.2)))
  shuffled <- do.call(sensitivity_analysis,
                      wn_args(weights = c(price = 0.2, service = 0.5,
                                          location = 0.3)))
  expect_equal(shuffled$table, ordered$table)
  expect_equal(shuffled$base_ranks, ordered$base_ranks)
  expect_equal(shuffled$stable, ordered$stable)
})

test_that("a weight name that is not a criterion is an error naming it", {
  expect_error(
    do.call(sensitivity_analysis,
            wn_args(weights = c(service = 0.5, location = 0.3, cost = 0.2))),
    "cost")
})

test_that("a criterion with no named weight is an error naming it", {
  expect_error(
    do.call(sensitivity_analysis,
            wn_args(weights = c(service = 0.5, service = 0.3, location = 0.2))),
    "price")
})

test_that("unnamed weights stay positional", {
  a <- do.call(sensitivity_analysis, wn_args())
  b <- do.call(sensitivity_analysis,
               wn_args(weights = c(service = 0.5, location = 0.3, price = 0.2)))
  expect_equal(a$table, b$table)
})
