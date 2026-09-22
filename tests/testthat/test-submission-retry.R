# Batch 4 #22: submission appended to CSV and then called on_submit, both
# inside one error handler. Where the append succeeded and the callback
# failed, the participant saw "Could not save response" and stayed on the
# form. Submitting again appended the same answers a second time, so a
# callback failure turned into duplicate collection.

retry_instrument <- function() {
  sf_instrument("Retry", components = list(
    sf_item("q1", "How was it?", type = "text")
  ))
}

test_that("22: a saved row is written once, whatever the callback does", {
  path <- tempfile(fileext = ".csv")
  row <- sframe_response_row(retry_instrument(), list(q1 = "fine"),
                             list(), Sys.time())

  state <- sframe_new_submission_state()
  failing <- function(...) stop("the callback failed")

  first <- sframe_persist_response(row, path, failing, state)
  expect_true(first$saved)
  expect_false(first$notified)
  expect_equal(nrow(utils::read.csv(path)), 1)

  # the participant tries again: the row is already held, so only the
  # callback runs again
  second <- sframe_persist_response(row, path, failing, first$state)
  expect_true(second$saved)
  expect_false(second$notified)
  expect_equal(nrow(utils::read.csv(path)), 1)
})

test_that("22: a retry that succeeds completes the submission", {
  path <- tempfile(fileext = ".csv")
  row <- sframe_response_row(retry_instrument(), list(q1 = "fine"),
                             list(), Sys.time())
  state <- sframe_new_submission_state()

  first <- sframe_persist_response(row, path, function(...) stop("nope"), state)
  expect_false(first$notified)

  seen <- NULL
  second <- sframe_persist_response(row, path,
                                    function(r) { seen <<- r; invisible(NULL) },
                                    first$state)
  expect_true(second$saved)
  expect_true(second$notified)
  expect_s3_class(seen, "data.frame")
  expect_equal(nrow(utils::read.csv(path)), 1)
})

test_that("22: the two failures are told apart", {
  # a directory where a file has to go, so the write cannot succeed
  path <- tempfile(); dir.create(path)
  row <- sframe_response_row(retry_instrument(), list(q1 = "fine"),
                             list(), Sys.time())
  state <- sframe_new_submission_state()

  # the write itself fails, which is the one the participant has to act on
  write_warnings <- character()
  res <- withCallingHandlers(
    sframe_persist_response(row, path, NULL, state),
    warning = function(w) {
      write_warnings <<- c(write_warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  expect_length(write_warnings, 2)
  expect_true(any(grepl("not a regular file", write_warnings, fixed = TRUE)))
  expect_true(any(grepl("it is a directory", write_warnings, fixed = TRUE)))
  expect_false(res$saved)
  expect_match(res$message, "could not be saved", fixed = TRUE)

  # a callback failure, where the answers are held
  ok_path <- tempfile(fileext = ".csv")
  res2 <- sframe_persist_response(row, ok_path, function(...) stop("x"),
                                  sframe_new_submission_state())
  expect_true(res2$saved)
  expect_match(res2$message, "saved", fixed = TRUE)
})

test_that("22: with no callback, one save completes the submission", {
  path <- tempfile(fileext = ".csv")
  row <- sframe_response_row(retry_instrument(), list(q1 = "fine"),
                             list(), Sys.time())
  res <- sframe_persist_response(row, path, NULL, sframe_new_submission_state())
  expect_true(res$saved)
  expect_true(res$notified)
  expect_null(res$message)
})
