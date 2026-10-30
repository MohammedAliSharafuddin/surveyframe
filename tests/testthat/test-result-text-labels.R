# tests/testthat/test-result-text-labels.R
# Result text and interaction terms showed raw ids, such as attendee_type,
# in_person and attendee_role:format, where the tables and charts beside
# them show the instrument's labels (CX-20).

test_that("result text names variables and groups by their labels", {
  d <- sframe_demo("two_group")
  res <- suppressWarnings(run_analysis_plan(d$responses, d$instrument))
  expect_match(res$RQ1$apa, "higher in In person", fixed = TRUE)
  expect_false(grepl("in_person", res$RQ1$apa, fixed = TRUE))
  expect_match(res$RQ2$apa, "higher in In person", fixed = TRUE)

  p <- sframe_demo("paired")
  res <- suppressWarnings(run_analysis_plan(p$responses, p$instrument))
  expect_match(res$RQ1$apa, "higher in \"And now? (0 to 100)\"", fixed = TRUE)
  expect_false(grepl("confidence_after", res$RQ2$apa, fixed = TRUE))

  f <- sframe_demo("first_survey")
  res <- suppressWarnings(run_analysis_plan(f$responses, f$instrument))
  expect_match(res$RQ1$apa,
               "for \"Have you attended this event before?\" (N = 50)", fixed = TRUE)
  expect_false(grepl("attendee_type", res$RQ1$prompt, fixed = TRUE))
})

test_that("a reference category is named by its choice label", {
  l <- sframe_demo("logistic")
  res <- suppressWarnings(run_analysis_plan(l$responses, l$instrument))
  expect_match(res$RQ3$apa, "reference category Keynotes", fixed = TRUE)
})

test_that("an interaction term reads as its labels joined by a times sign", {
  m <- sframe_demo("multi_group")
  res <- suppressWarnings(run_analysis_plan(m$responses, m$instrument))
  cells <- unlist(lapply(res$RQ3$table, as.character))
  expect_false(any(grepl("attendee_role:format", cells, fixed = TRUE)))
  expect_true(any(grepl("Which best describes you? \u00d7 How did you attend?",
                        cells, fixed = TRUE)))
})

test_that("a variable is named by its quoted label and a code by its choice label", {
  d <- sframe_demo("two_group")
  out <- .sframe_with_text_labels(d$instrument, c(
    sframe_text_var(c("format", "not_an_item", "format__online")),
    sframe_text_value("format", c("in_person", "other"))))
  expect_identical(out, c("\"How did you attend?\"", "not_an_item",
                          "\"How did you attend? Online\"", "In person", "other"))
  # Outside a plan run the id is used as it is.
  expect_identical(sframe_text_var("format"), "format")
})

# A demo with its ids renamed, so the ids are words the result templates use.
rename_demo_ids <- function(demo, map, labels = character(0)) {
  ins <- demo$instrument
  for (k in seq_along(ins$items)) {
    id <- ins$items[[k]]$id
    if (id %in% names(labels)) ins$items[[k]]$label <- labels[[id]]
    if (id %in% names(map)) ins$items[[k]]$id <- map[[id]]
  }
  swap <- function(x) {
    if (is.list(x)) return(lapply(x, swap))
    if (is.character(x)) return(ifelse(x %in% names(map), map[x], x))
    x
  }
  for (k in seq_along(ins$analysis_plan)) {
    ins$analysis_plan[[k]]$roles <- swap(ins$analysis_plan[[k]]$roles)
  }
  d <- demo$responses
  names(d) <- ifelse(names(d) %in% names(map), map[names(d)], names(d))
  list(instrument = ins, responses = d)
}

test_that("ids that are template words label only the variable, quotes included", {
  m <- rename_demo_ids(sframe_demo("multi_group"),
                       c(attendee_role = "group", age = "time", sessions_attended = "mean"),
                       c(age = "Age in \"years\""))
  res <- suppressWarnings(run_analysis_plan(m$responses, m$instrument))
  expect_match(res$RQ4$apa, "the group effect was", fixed = TRUE)
  expect_match(res$RQ4$apa, "\"Age in 'years'\"", fixed = TRUE)
  expect_false(grepl("Adjusted for time", res$RQ4$apa, fixed = TRUE))

  p <- rename_demo_ids(sframe_demo("paired"),
                       c(confidence_before = "test", confidence_after = "model"),
                       c(confidence_after = "And \"now\"?"))
  res <- suppressWarnings(run_analysis_plan(p$responses, p$instrument))
  expect_match(res$RQ1$prompt, "The paired-samples t-test", fixed = TRUE)
  expect_match(res$RQ1$prompt, "mean difference", fixed = TRUE)
  expect_match(res$RQ1$apa, "higher in \"And 'now'?\"", fixed = TRUE)
})

test_that("a runner called outside a plan run names variables by their ids", {
  d <- sframe_demo("paired")
  r <- sframe_run_t_test_pair(d$responses, c("confidence_before", "confidence_after"))
  expect_match(r$apa, "higher in confidence_after", fixed = TRUE)
  expect_match(r$prompt, "between confidence_before", fixed = TRUE)
  g <- sframe_demo("two_group")
  r <- sframe_run_t_test(g$responses, c("format", "sessions_attended"))
  expect_match(r$apa, "higher in in_person", fixed = TRUE)
  r <- sframe_run_frequency(g$responses, "format")
  expect_match(r$apa, "Frequency distribution for format", fixed = TRUE)
})
