# tests/testthat/test-validate-lets-through.R
# Fable sitting 1 FR-14. validate_sframe() accepted shapes the rest of the
# package then ignored or misread: a scale method of "banana" scored as the
# mean, a plan alpha of 5, -0.05 or "abc" changed nothing, values and labels
# of different lengths, an unknown branch operator, a branch on its own item,
# 2 rules in a cycle, a check pass value outside its item's codes, and an item
# scale_id its scale does not list. The first 5 are problems. The last 3 are
# notes, since SurveyBuilder saved them before 0.4.3, and the builder now
# refuses new ones (coordinator rulings 2026-11-11). A rule on an item asked
# later stays allowed. The other FR-14 rows are in todo_0.4.4.md.

lt_instr <- function() {
  cs <- sframe_choice_set("ag5", 1:5, c("SD", "D", "N", "A", "SA"))
  g <- sframe_choice_set("grp", c("a", "b"), c("Group A", "Group B"))
  gi <- sframe_item("grp_q", "Group", type = "single_choice", choice_set = "grp")
  it <- lapply(1:4, function(i) sframe_item(paste0("s_", i), paste("Item", i), type = "likert",
                                            choice_set = "ag5", scale_id = "sat"))
  sc <- sframe_scale("sat", "Satisfaction", items = paste0("s_", 1:4))
  x <- sframe_instrument("Lets through", components = c(list(cs, g, gi, sc), it))
  x$analysis_plan <- list(list(id = "P1", research_question = "RQ", family = "descriptive",
                               method = "frequency", roles = list(variable = "grp_q")))
  x
}

rule <- function(...) structure(list(...), class = "sf_branch")

lt_check <- function(x) {
  d <- validate_sframe(x, strict = FALSE)
  list(valid = sframe_is_valid(d), problems = if (sframe_is_valid(d)) character(0) else sframe_problems(d),
       notes = sframe_notes(d))
}

test_that("FR-14: a well-formed rule, a rule on a later item and a check are clean", {
  x <- lt_instr()
  x$branching <- list(rule(item_id = "s_1", depends_on = "grp_q", operator = "==", value = "a"),
                      rule(item_id = "grp_q", depends_on = "s_4", operator = ">=", value = 3))
  x$checks <- list(sframe_attention_check("ac1", "s_2", pass_values = 4))
  x$analysis_plan[[1]]$alpha <- 0.01
  r <- lt_check(x)
  expect_true(r$valid)
  expect_length(r$notes, 0)
})

test_that("FR-14: 5 shapes are problems naming what is wrong", {
  cases <- list(
    "V-07" = list(function(x) { x$scales[[1]]$method <- "banana"; x },
                  "Scale 'sat' has method 'banana'"),
    "V-60" = list(function(x) { x$analysis_plan[[1]]$alpha <- 5; x },
                  "Analysis plan 'P1''s alpha is 5"),
    "V-61" = list(function(x) { x$analysis_plan[[1]]$alpha <- -0.05; x }, "alpha is -0.05"),
    "V-62" = list(function(x) { x$analysis_plan[[1]]$alpha <- "abc"; x }, "alpha is abc"),
    "V-63" = list(function(x) { x$analysis_plan[[1]]$options <- list(alpha = 1); x },
                  "options$alpha is 1"),
    "V-28" = list(function(x) { x$choices[[1]]$labels <- x$choices[[1]]$labels[1:4]; x },
                  "Choice set 'ag5': it has 5 values and 4 labels"),
    "V-43" = list(function(x) { x$branching <- list(rule(item_id = "s_2", depends_on = "s_1",
                                                         operator = "~~", value = 1)); x },
                  "the operator '~~'"),
    "V-44" = list(function(x) { x$branching <- list(rule(item_id = "s_2", depends_on = "s_1",
                                                         value = 1)); x },
                  "has no operator"),
    "V-40" = list(function(x) { x$branching <- list(rule(item_id = "s_1", depends_on = "s_1",
                                                         operator = "==", value = 1)); x },
                  "depends on that item itself"))
  for (n in names(cases)) {
    r <- lt_check(cases[[n]][[1]](lt_instr()))
    expect_false(r$valid, label = n)
    expect_true(any(grepl(cases[[n]][[2]], r$problems, fixed = TRUE)),
                label = paste(n, "|", paste(r$problems, collapse = " | ")))
  }
})

test_that("FR-14: a cycle, a pass value outside the codes and a stale scale_id are notes", {
  cases <- list(
    "V-41" = list(function(x) { x$branching <- list(
                    rule(item_id = "s_1", depends_on = "s_2", operator = "==", value = 1),
                    rule(item_id = "s_2", depends_on = "s_3", operator = "==", value = 1),
                    rule(item_id = "s_3", depends_on = "s_1", operator = "==", value = 1)); x },
                  "Branch rules on items 's_1', 's_2', 's_3' depend on each other in a cycle"),
    "V-50" = list(function(x) { x$checks <- list(sframe_attention_check("c1", "s_1", pass_values = 99)); x },
                  "Check 'c1' passes the value 99, which is no code of item 's_1's choice set 'ag5'"),
    "V-11" = list(function(x) {
                    x$scales <- c(x$scales, list(sframe_scale("sat2", "Second", items = c("s_1", "s_2"))))
                    x$scales[[1]]$items <- c("s_2", "s_3", "s_4"); x },
                  "Item 's_1' names scale 'sat' as its scale_id, but the scale does not list it"))
  for (n in names(cases)) {
    x <- cases[[n]][[1]](lt_instr())
    r <- lt_check(x)
    expect_true(r$valid, label = n)
    expect_true(any(grepl(cases[[n]][[2]], r$notes, fixed = TRUE)),
                label = paste(n, "|", paste(r$notes, collapse = " | ")))
    # A file holding it still writes and reads.
    f <- tempfile(fileext = ".sframe")
    expect_no_error(write_sframe(x, f))
    expect_true(attr(read_sframe(f), "sframe_verified"), label = n)
  }
  # A free-text item's check is not compared with codes.
  x <- lt_instr()
  x$items <- c(x$items, list(sframe_item("word", "Type the word blue", type = "text")))
  x$checks <- list(sframe_attention_check("c2", "word", pass_values = "blue"))
  expect_length(lt_check(x)$notes, 0)
})

test_that("FR-14: SurveyBuilder's item editor adds an item to the scale it names", {
  ctx <- builder_context()
  x <- lt_instr()
  x$items <- c(x$items, list(sframe_item("s_5", "Item 5", type = "likert", choice_set = "ag5")))
  builder_open(ctx, x)
  ctx$eval("selId = 's_5'; document.getElementById('fi-scale').value = 'sat'; updF('fi-scale');")
  expect_identical(ctx$get("S.scales[0].items"), paste0("s_", 1:5))
  expect_identical(ctx$get("S.items.find(function(i){return i.id==='s_5';}).scale_id"), "sat")
  y <- read_sframe(builder_save(ctx), validate = FALSE)
  expect_length(sframe_notes(validate_sframe(y, strict = FALSE)), 0)
})

test_that("FR-14: SurveyBuilder refuses a rule that closes a cycle", {
  ctx <- builder_context()
  x <- lt_instr()
  x$branching <- list(rule(item_id = "s_2", depends_on = "s_1", operator = "==", value = 1),
                      rule(item_id = "s_3", depends_on = "s_2", operator = "==", value = 1))
  builder_open(ctx, x)
  ctx$eval("sv('br-tgt','s_1'); sv('br-dep','s_3'); sv('br-val','1');
            document.getElementById('br-op').value = '=='; document.getElementById('br-act').value = 'show';
            saveBranch();")
  t <- builder_toasts(ctx)
  expect_identical(t$kind[nrow(t)], "err")
  expect_match(t$msg[nrow(t)], "close a cycle: s_1 depends on s_3 depends on s_2 depends on s_1", fixed = TRUE)
  expect_identical(ctx$get("S.branching.length"), 2L)
  # A rule that closes no cycle is added.
  ctx$eval("sv('br-tgt','s_4'); sv('br-dep','s_3'); saveBranch();")
  expect_identical(ctx$get("S.branching.length"), 3L)
})

test_that("FR-14: SurveyBuilder refuses a pass value that is no code of the item", {
  ctx <- builder_context()
  builder_open(ctx, lt_instr())
  ctx$eval("sv('ck-id','c1'); document.getElementById('ck-item').value = 's_1'; sv('ck-pass','4, 9');
            document.getElementById('ck-type').value = 'attention'; document.getElementById('ck-fail').value = 'flag';
            saveCheck();")
  t <- builder_toasts(ctx)
  expect_identical(t$kind[nrow(t)], "err")
  expect_match(t$msg[nrow(t)], "Pass value 9 is no code of s_1's choice set ag5", fixed = TRUE)
  expect_identical(ctx$get("S.checks.length"), 0L)
  ctx$eval("sv('ck-pass','4'); saveCheck();")
  expect_identical(ctx$get("S.checks.length"), 1L)
})
