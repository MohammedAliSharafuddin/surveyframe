# FR-37 (Codex files review, 2026-11-12), Session CF-B: the chi_square
# cross-tab labels both axes from their own item's choice set. Workshop G3
# (channel by return) showed rows "1", "2", "3" and columns "No" and "1".

cfb_g3_instrument <- function() {
  ins <- sframe_instrument("G3", components = list(
    sframe_choice_set("chan", 1:3, c("Website", "Agent", "Walk-in")),
    sframe_choice_set("yn", 0:1, c("No", "Yes")),
    sframe_choice_set("ag", 1:5, c("SD", "D", "N", "A", "SA")),
    sframe_item("channel", "Booking channel", "single_choice", choice_set = "chan"),
    sframe_item("ret", "Would return", "single_choice", choice_set = "yn"),
    sframe_item("sat", "Satisfied", "likert", choice_set = "ag")))
  sframe_plan(ins) <- list(list(id = "G3", research_question = "q", family = "inferential",
                                method = "chi_square", roles = list(row = "channel", column = "ret"),
                                options = list(percent = "row")))
  ins
}

test_that("a 1:k and a 0:1 choice set read through read_responses() label both axes", {
  ins <- cfb_g3_instrument()
  set.seed(5)
  d <- data.frame(respondent_id = sprintf("%03d", 1:60),
                  channel = sample(1:3, 60, TRUE), ret = sample(0:1, 60, TRUE),
                  sat = sample(1:5, 60, TRUE))
  p <- tempfile(fileext = ".csv")
  utils::write.csv(d, p, row.names = FALSE)
  resp <- read_responses(p, ins)
  r <- run_analysis_plan(resp, ins)$G3
  expect_null(r$error)
  expect_identical(rownames(r$table), c("Website", "Agent", "Walk-in"))
  expect_identical(colnames(r$table), c("No", "Yes"))
  expect_identical(r$totals[[1]], c("Website", "Agent", "Walk-in", "Total"))
  expect_identical(names(r$percent_table)[-1], c("No", "Yes", "Total"))
  ref <- suppressWarnings(stats::chisq.test(table(d$channel, d$ret), correct = FALSE))
  expect_equal(r$chi_sq, unname(ref$statistic))
})

test_that("an item without a choice set keeps its values", {
  d <- data.frame(a = c("x", "y", "x", "y"), b = c("u", "u", "v", "v"))
  r <- cfb_block(d, "chi_square", list(row = "a", column = "b"),
                 sframe_item("a", "a", type = "text"), sframe_item("b", "b", type = "text"))
  expect_identical(rownames(r$table), c("x", "y"))
  expect_identical(colnames(r$table), c("u", "v"))
})
