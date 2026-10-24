# tests/testthat/test-plot-labels.R
# Charts drawn by run_analysis_plan() named variables by their bare ids, so a
# regression on the scale "sat" was titled "Observed against fitted values for
# Sat" while its coefficient table read "Satisfaction". SurveyStudio headed
# each result "RQ 4: RQ4" when the block id only repeated the number. Found on
# 0.4.3 during a teaching session.

label_inst <- function() {
  ag <- sf_choices("ag5", 1:5, c("SD", "D", "N", "A", "SA"))
  items <- list(ag)
  for (s in c("rel", "sat")) {
    for (k in 1:3) {
      items[[length(items) + 1]] <- sf_item(paste0(s, k), paste("Item", s, k),
        type = "likert", choice_set = "ag5", scale_id = s)
    }
  }
  items[[length(items) + 1]] <- sf_item("orders", "Online orders last month",
                                        type = "numeric")
  items[[length(items) + 1]] <- sf_scale("rel", "Delivery reliability",
                                         items = paste0("rel", 1:3))
  items[[length(items) + 1]] <- sf_scale("sat", "Satisfaction",
                                         items = paste0("sat", 1:3))
  sf_instrument("Labels", components = items, analysis_plan = list(
    list(id = "RQ1", family = "association", method = "correlation_pearson",
         research_question = "r", roles = list(x = "rel", y = "sat")),
    list(id = "RQ2", family = "regression", method = "regression_linear",
         research_question = "m",
         roles = list(predictors = c("rel", "orders"), dependent = "sat"))))
}

label_data <- function() {
  set.seed(42)
  n <- 60
  z <- rnorm(n)
  d <- data.frame(id = seq_len(n), orders = rpois(n, 5))
  for (k in 1:3) {
    d[[paste0("rel", k)]] <- pmin(5, pmax(1, round(3 + z + rnorm(n, sd = 0.6))))
    d[[paste0("sat", k)]] <- pmin(5, pmax(1, round(3 + 0.6 * z + rnorm(n, sd = 0.6))))
  }
  d
}

test_that("plan charts name variables by their instrument labels", {
  skip_if_not_installed("ggplot2")
  res <- run_analysis_plan(label_data(), label_inst(), plots = TRUE)

  cor_title <- res[[1]]$plot$labels$title
  expect_match(cor_title, "Delivery reliability", fixed = TRUE)
  expect_match(cor_title, "Satisfaction", fixed = TRUE)

  reg_title <- res[[2]]$plot$labels$title
  expect_identical(reg_title, "Observed against fitted values for Satisfaction")
})

test_that("labels apply only while plan charts are drawn", {
  skip_if_not_installed("ggplot2")
  run_analysis_plan(label_data(), label_inst(), plots = TRUE)
  expect_identical(surveyframe:::.sframe_title_case_names("sat"), "Sat")
  expect_identical(surveyframe:::.sframe_title_case_names("online_orders"),
                   "Online orders")
})

test_that("a Studio result heading drops a block id that repeats the number", {
  app <- system.file("shiny", "app.R", package = "surveyframe")
  skip_if(!nzchar(app) || !file.exists(app), "studio app not available")
  txt <- readLines(app, warn = FALSE)
  from <- grep("^studio_rq_heading <- function", txt)[1]
  to   <- grep("^studio_result_plot_tags <- function", txt)[1]
  skip_if(is.na(from) || is.na(to), "studio heading helper not found")
  env <- new.env()
  eval(parse(text = paste(txt[from:(to - 1)], collapse = "\n")), envir = env)

  expect_identical(env$studio_rq_heading(4, "RQ4"), "RQ 4")
  expect_identical(env$studio_rq_heading(4, "rq 4"), "RQ 4")
  expect_identical(env$studio_rq_heading(4, NULL), "RQ 4")
  expect_identical(env$studio_rq_heading(2, "H2a"), "RQ 2: H2a")
  expect_identical(env$studio_rq_heading(3, "RQ4"), "RQ 3: RQ4")
})

# Ethos request 20 (2026-10-03). The same report's figures labelled axes and
# legends with item ids and choice codes ("preferred_session_type",
# "in_person") where the tables beside them used the labels. The fix above
# covered variable names on 5 chart families. Group comparisons still showed
# the group codes, and crosstabs titled their axes with item ids.

built_texts <- function(p) {
  b <- ggplot2::ggplot_build(p)
  x <- b$layout$panel_params[[1]]$x$get_labels()
  c(as.character(x), unlist(p$labels))
}

test_that("Ethos 20: a group comparison chart shows the groups' labels in set order", {
  skip_if_not_installed("ggplot2")
  d <- sframe_demo("two_group")
  res <- run_analysis_plan(d$responses, d$instrument, plots = TRUE)
  tt <- Filter(function(r) identical(r$test, "t_test_ind"), res)[[1]]
  ticks <- as.character(ggplot2::ggplot_build(tt$plot)$layout$panel_params[[1]]$x$get_labels())
  expect_identical(ticks, c("In person", "Online"))
  expect_false(any(c("online", "in_person") %in% built_texts(tt$plot)))
})

test_that("Ethos 20: a crosstab chart titles its axes and legend with item labels", {
  skip_if_not_installed("ggplot2")
  d <- sframe_demo("categorical")
  res <- run_analysis_plan(d$responses, d$instrument, plots = TRUE)
  ct <- Filter(function(r) identical(r$test, "crosstab"), res)[[1]]
  ids <- ct$vars[1:2]
  labels <- vapply(ids, function(id) {
    Filter(function(i) identical(i$id, id), d$instrument$items)[[1]]$label
  }, character(1))
  expect_identical(c(ct$plot$labels$x, ct$plot$labels$fill), unname(labels))
  expect_false(any(ids %in% unlist(ct$plot$labels)))
})
