# tests/testthat/test-report-source-roundtrip.R
#
# Session LF, the L4 defect (master review step L4, coordinator 2026-11-08).
# sframe_report_source() said the numbers differed on an untouched folder
# when the instrument was built in memory and never written, or when the
# responses were a plain data frame. Export computed the results record from
# the objects in memory and the check from the folder's files: the written
# instrument gains normalised fields, so its hash differs, and write.csv()
# keeps 15 significant digits, so a statistic moves in its last digit.
# Export now computes the record from what it wrote, read back.

roundtrip_instrument <- function() {
  sframe_instrument(
    "Mini",
    components = list(
      sframe_choice_set("g", c("A", "B"), c("A", "B")),
      sframe_item("grp", "Group", type = "single_choice", choice_set = "g"),
      sframe_item("y", "Score", type = "numeric")),
    analysis_plan = list(list(id = "RQ1", research_question = "Do groups differ?",
                              family = "group_comparison", method = "t_test_ind",
                              roles = list(group = "grp", outcome = "y"))))
}

roundtrip_data <- function() {
  set.seed(1)
  data.frame(respondent_id = sprintf("R%02d", 1:20), grp = rep(c("A", "B"), 10),
             y = stats::rnorm(20))
}

roundtrip_source <- function(instrument, data) {
  dir <- tempfile("report-source-rt-")
  suppressMessages(render_report(instrument, data, output_file = dir,
                                 format = "qmd", open = FALSE))
  dir
}

roundtrip_check <- function(dir) suppressMessages(sframe_report_source(dir))$check

test_that("an untouched source folder matches its record for in-memory and plain inputs", {
  ins <- roundtrip_instrument()
  dat <- roundtrip_data()
  csv <- tempfile(fileext = ".csv")
  utils::write.csv(dat, csv, row.names = FALSE, na = "")
  sf <- tempfile(fileext = ".sframe")
  write_sframe(ins, sf)
  ins_back <- read_sframe(sf)
  dat_read <- suppressMessages(read_responses(csv, ins_back))

  cases <- list(
    in_memory_instrument = roundtrip_check(roundtrip_source(ins, dat_read)),
    written_and_read_back = roundtrip_check(roundtrip_source(ins_back, dat_read)),
    plain_data_frame = roundtrip_check(roundtrip_source(ins, dat)))
  for (nm in names(cases)) {
    expect_true(cases[[nm]]$numbers_match, label = paste(nm, "numbers_match"))
    expect_true(cases[[nm]]$responses_match, label = paste(nm, "responses_match"))
    expect_false(cases[[nm]]$source_edited, label = paste(nm, "source_edited"))
  }
})

test_that("a changed response still turns the check FALSE", {
  dir <- roundtrip_source(roundtrip_instrument(), roundtrip_data())
  csv <- file.path(dir, "responses.csv")
  expect_true(file.exists(csv))
  rr <- utils::read.csv(csv, check.names = FALSE)
  rr$y[1] <- rr$y[1] + 1
  utils::write.csv(rr, csv, row.names = FALSE, na = "")
  chk <- roundtrip_check(dir)
  expect_false(chk$responses_match)
  expect_false(chk$numbers_match)
})
