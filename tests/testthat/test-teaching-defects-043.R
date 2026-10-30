# tests/testthat/test-teaching-defects-043.R
#
# Defects found on 2026-10-19 while building a teaching deck on 0.4.2, fixed
# in 0.4.3. Each test reproduced its defect before the fix.
#
# 1. A frequency block read only the first variable, and ignored a
#    `variables` role altogether ("Frequency distribution for NA").
# 2. A frequency table printed the raw codes of a numeric choice set.
# 3. A descriptives block reported a mean and SD for nominal choice codes.
# 8. A 3-item scale was never checked for straight-lining, and the printed
#    report gave no way forward.
# Plus 2 display defects from todo_0.4.3.md: the printed quality report left
# out duplicates.

teaching_instrument <- function(plan = list()) {
  sf_instrument(
    title = "Teaching deck", version = "1.0.0",
    components = list(
      sf_choices("gender_set", values = c("1", "2"), labels = c("Male", "Female")),
      sf_choices("region_set", values = c("1", "2", "3"),
                 labels = c("North", "South", "East")),
      sf_choices("contact_set", values = c("email", "phone", "post"),
                 labels = c("Email", "Phone", "Post")),
      sf_item("gender", "Gender", "single_choice", choice_set = "gender_set"),
      sf_item("region", "Region", "single_choice", choice_set = "region_set"),
      sf_item("contact", "Contact by", "multiple_choice",
              choice_set = "contact_set"),
      sf_item("age", "Age", "numeric"),
      sf_item("sat", "Satisfaction", "numeric")
    ),
    analysis_plan = plan
  )
}

teaching_data <- function() {
  data.frame(
    gender = c(1, 2, 2, 1, 2, 2, 1, 2, 2, 1),
    region = c(1, 2, 3, 3, 2, 1, 1, 3, 2, 2),
    contact__email = c(1, 0, 1, 1, 0, 1, 0, 1, 1, 0),
    contact__phone = c(0, 1, 0, 1, 1, 0, 0, 1, 0, 1),
    contact__post = c(0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
    age = c(21, 34, 45, 29, 52, 38, 41, 27, 33, 60),
    sat = c(4, 5, 3, 4, 2, 5, 4, 3, 4, 5)
  )
}

plan_block <- function(id, method, roles) {
  list(id = id, research_question = paste("Question", id), method = method,
       roles = roles)
}

# ── 1 ──

test_that("1: a frequency block gives one table per variable", {
  ins <- teaching_instrument(list(
    plan_block("RQ1", "frequency", list(variable = c("gender", "region")))))
  res <- run_analysis_plan(teaching_data(), ins)$RQ1

  expect_null(res$error)
  expect_identical(res$variable, c("gender", "region"))
  expect_named(res$tables, c("gender", "region"))
  expect_identical(nrow(res$tables$gender$table), 2L)
  expect_identical(nrow(res$tables$region$table), 3L)
  # The combined table names the variable on every row
  expect_true("Variable" %in% names(res$table))
  expect_setequal(unique(res$table$Variable), c("Gender", "Region"))
  expect_match(res$apa, "\"Gender\"", fixed = TRUE)
  expect_match(res$apa, "\"Region\"", fixed = TRUE)
})

test_that("1: a frequency block reads the `variables` role as well", {
  ins <- teaching_instrument(list(
    plan_block("RQ1", "frequency", list(variables = "gender"))))
  res <- run_analysis_plan(teaching_data(), ins)$RQ1

  expect_null(res$error)
  expect_identical(res$variable, "gender")
  expect_identical(sum(res$table$Frequency), 10L)
  expect_false(grepl("NA", res$apa, fixed = TRUE))
})

# ── 2 ──

test_that("2: frequency shows choice labels and keeps the code as a column", {
  ins <- teaching_instrument(list(
    plan_block("RQ1", "frequency", list(variable = "region"))))
  res <- run_analysis_plan(teaching_data(), ins)$RQ1

  expect_null(res$error)
  # "1" means Male in one set and North in another, so the instrument-wide
  # lookup cannot relabel it. The runner reads the item's own choice set.
  expect_setequal(res$table$Value, c("North", "South", "East"))
  expect_setequal(res$table$Code, c("1", "2", "3"))
  north <- res$table[res$table$Code == "1", ]
  expect_identical(north$Value, "North")
  expect_identical(north$Frequency, 3L)
})

test_that("2: a declared choice with no responses still appears, at 0", {
  dat <- teaching_data()
  dat$region[dat$region == 3] <- 2
  ins <- teaching_instrument(list(
    plan_block("RQ1", "frequency", list(variable = "region"))))
  res <- run_analysis_plan(dat, ins)$RQ1

  east <- res$table[res$table$Code == "3", ]
  expect_identical(east$Value, "East")
  expect_identical(east$Frequency, 0L)
})

# ── 3 ──

test_that("3: descriptives never reports a mean for a nominal item", {
  ins <- teaching_instrument(list(
    plan_block("RQ1", "descriptives", list(variables = c("gender", "age")))))
  res <- run_analysis_plan(teaching_data(), ins)$RQ1

  expect_null(res$error)
  # The numeric table holds age alone
  report <- surveyframe:::sframe_runtime(res, "report")
  expect_identical(report$table$variable, "age")
  expect_false(any(grepl("gender", report$table$variable)))
  # Gender is counted instead
  cat_tbl <- res$categorical
  expect_true(is.data.frame(cat_tbl))
  expect_setequal(cat_tbl$Value[cat_tbl$Variable == "Gender"],
                  c("Male", "Female"))
  female <- cat_tbl[cat_tbl$Variable == "Gender" & cat_tbl$Code == "2", ]
  expect_identical(female$Frequency, 6L)
  expect_equal(female$Percent, 60)
  expect_match(res$note, "\"Gender\" is a choice item", fixed = TRUE)
})

test_that("3: descriptives on choice items alone gives counts, not an error", {
  ins <- teaching_instrument(list(
    plan_block("RQ1", "descriptives",
               list(variables = c("gender", "contact__email",
                                  "contact__phone", "contact__post")))))
  res <- run_analysis_plan(teaching_data(), ins)$RQ1

  expect_null(res$error)
  expect_false(any(c("mean", "sd") %in% names(res$table)))
  expect_true(all(c("Frequency", "Percent") %in% names(res$table)))
  email <- res$table[res$table$Code == "contact__email", ]
  expect_identical(email$Frequency, 6L)
  expect_equal(email$Percent, 60)
})

# ── 8 ──

test_that("8: the printed report says how to check a short scale", {
  ins <- sf_instrument(title = "Short scale", components = list(
    sf_choices("ag", values = 1:5, labels = c("SD", "D", "N", "A", "SA")),
    sf_item("s1", "One", "likert", choice_set = "ag"),
    sf_item("s2", "Two", "likert", choice_set = "ag"),
    sf_item("s3", "Three", "likert", choice_set = "ag"),
    sf_scale("sc", "Short", items = c("s1", "s2", "s3"))
  ))
  dat <- data.frame(s1 = c(3, 3, 1, 5), s2 = c(3, 4, 1, 4), s3 = c(3, 2, 1, 5))

  qr <- quality_report(dat, ins)
  out <- paste(utils::capture.output(print(qr)), collapse = "\n")
  expect_match(out, "straightline_min_items = 3", fixed = TRUE)
  expect_identical(qr$straightline$sc$min_items, 4L)

  qr3 <- quality_report(dat, ins, straightline_min_items = 3)
  expect_true(qr3$straightline$sc$checked)
  expect_identical(qr3$straightline$sc$flagged_rows, c(1L, 3L))
})

# ── display: duplicates in the printed quality report ──

test_that("the printed quality report shows duplicates", {
  ins <- teaching_instrument()
  dat <- teaching_data()
  dat$respondent_id <- c("a", "b", "b", paste0("r", 4:10))

  checked <- quality_report(dat, ins, respondent_id = "respondent_id")
  out <- paste(utils::capture.output(print(checked)), collapse = "\n")
  expect_match(out, "Duplicates:", fixed = TRUE)
  expect_match(out, "1 duplicate", fixed = TRUE)

  unchecked <- quality_report(dat, ins)
  out <- paste(utils::capture.output(print(unchecked)), collapse = "\n")
  expect_match(out, "not checked", fixed = TRUE)
})
