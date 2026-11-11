# tests/testthat/test-validate-field-shapes.R
# Fable sitting 1 FR-13. validate_sframe(strict = FALSE) stopped with a plain
# R error, "argument is of length zero", on an item whose choice_set holds 2
# ids, a branching rule with no item_id or no depends_on, and a check with no
# item_id, where it promises to report the problem and return. A file holding
# such a rule failed read_sframe() with the same plain error.

shape_instr <- function() {
  cs <- sframe_choice_set("ag5", 1:5, c("SD", "D", "N", "A", "SA"))
  g <- sframe_choice_set("grp", c("a", "b"), c("Group A", "Group B"))
  it <- lapply(1:4, function(i) sframe_item(paste0("s_", i), paste("Item", i), type = "likert",
                                            choice_set = "ag5", scale_id = "sat"))
  gi <- sframe_item("grp_q", "Group", type = "single_choice", choice_set = "grp")
  sc <- sframe_scale("sat", "Satisfaction", items = paste0("s_", 1:4))
  sframe_instrument("Shapes", components = c(list(cs, g, gi, sc), it))
}

test_that("FR-13: the 4 shapes give a diagnostic naming the field", {
  cases <- list(
    choice_set = list(function(x) { x$items[[2]]$choice_set <- c("ag5", "grp"); x },
                      "Item 2's choice_set must be one value, and has length 2"),
    rule_item = list(function(x) {
      x$branching <- list(structure(list(depends_on = "s_1", operator = "==", value = 1),
                                    class = "sf_branch")); x },
      "Branching rule 1's item_id is missing"),
    rule_depends = list(function(x) {
      x$branching <- list(structure(list(item_id = "s_2", operator = "==", value = 1),
                                    class = "sf_branch")); x },
      "Branching rule 1's depends_on is missing"),
    check_item = list(function(x) {
      x$checks <- list(structure(list(id = "c1", type = "attention", pass_values = 1),
                                 class = "sf_check")); x },
      "Check 1's item_id is missing"))
  for (n in names(cases)) {
    x <- cases[[n]][[1]](shape_instr())
    d <- validate_sframe(x, strict = FALSE)
    expect_false(sframe_is_valid(d), label = n)
    expect_true(any(grepl(cases[[n]][[2]], sframe_problems(d), fixed = TRUE)), label = n)
    expect_error(validate_sframe(x), class = "sframe_validation_error", label = n)
  }
})

test_that("FR-13: a file holding a rule with no item_id is refused with the field named", {
  f <- tempfile(fileext = ".sframe")
  write_sframe(shape_instr(), f)
  p <- jsonlite::read_json(f, simplifyVector = FALSE)
  p$branching <- list(list(depends_on = "s_1", operator = "==", value = 1))
  p$hash$value <- surveyframe:::sframe_hash_payload(p, parsed = TRUE)
  writeLines(jsonlite::toJSON(p, auto_unbox = TRUE, null = "null", digits = NA, pretty = TRUE), f)
  expect_error(read_sframe(f), "item_id is missing", class = "sframe_validation_error")
})
