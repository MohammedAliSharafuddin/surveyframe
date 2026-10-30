# tests/testthat/test-choice-descriptives.R
# D5 (CX-07). Descriptives of a choice item honour split_by and weights:
# counts and percentages per group, weighted when weights are given.

choice_instr <- function() {
  sf_instrument(
    "Choice descriptives",
    components = list(
      sf_choices("col", values = c("red", "blue"), labels = c("Red", "Blue")),
      sf_choices("arm", values = c("a", "b"), labels = c("A", "B")),
      sf_item("colour", "Colour", type = "single_choice", choice_set = "col"),
      sf_item("grp", "Arm", type = "single_choice", choice_set = "arm")
    )
  )
}

choice_data <- function() {
  data.frame(colour = c("red", "red", "blue", "red", "blue", "blue"),
             grp = c("a", "a", "a", "b", "b", "b"),
             w = c(1, 1, 2, 1, 1, 3), stringsAsFactors = FALSE)
}

choice_block <- function(roles) {
  list(id = "RQ1", research_question = "Q", method = "descriptives",
       test = "descriptives", roles = roles, variables = unlist(roles),
       options = list())
}

run_choice <- function(roles) {
  sframe_run_one_block(choice_block(roles), choice_data(), choice_instr())
}

test_that("counts are reported per split_by group", {
  tb <- run_choice(list(variables = "colour", split_by = "grp"))$categorical
  expect_true("Group" %in% names(tb))
  a <- tb[tb$Group == "A" & tb$Code == "red", ]
  b <- tb[tb$Group == "B" & tb$Code == "red", ]
  expect_equal(a$Frequency, 2)
  expect_equal(b$Frequency, 1)
  expect_equal(a$Percent, round(2 / 3 * 100, 1))
  expect_equal(sum(tb$Frequency), 6)
})

test_that("counts are weighted when weights are given", {
  tb <- run_choice(list(variables = "colour", weights = "w"))$categorical
  expect_equal(tb$Frequency[tb$Code == "red"], 3)
  expect_equal(tb$Frequency[tb$Code == "blue"], 6)
  expect_equal(tb$Percent[tb$Code == "blue"], round(6 / 9 * 100, 1))
})

test_that("split_by and weights together", {
  tb <- run_choice(list(variables = "colour", split_by = "grp", weights = "w"))$categorical
  expect_equal(tb$Frequency[tb$Group == "A" & tb$Code == "blue"], 2)
  expect_equal(tb$Frequency[tb$Group == "B" & tb$Code == "blue"], 4)
  expect_equal(tb$Percent[tb$Group == "B" & tb$Code == "blue"], 80)
})

test_that("without split_by or weights the table is unchanged", {
  tb <- run_choice(list(variables = "colour"))$categorical
  expect_false("Group" %in% names(tb))
  expect_equal(tb$Frequency[tb$Code == "red"], 3)
})
