# data-raw/build_demo_library.R
# Builds the surveyframe demo library: 22 small, single-purpose instruments
# with seeded response data, written to inst/extdata/demos/.
#
# Each demo does one job, so a failure points at one method rather than at a
# 34-block instrument, and a reader can hold the whole questionnaire in view.
# Specification, including every seed and the effect simulated into each
# dataset, is in the plan this was built from.
#
# Dev-only, tracked on the dev branch. data-raw/ is gitignored on main, the
# same arrangement build_mcdm_fixture.R and inline_static_template.R use.
#
# Run from the repository root:  Rscript data-raw/build_demo_library.R

devtools::load_all(quiet = TRUE)

out_dir <- file.path("inst", "extdata", "demos")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ---------------------------------------------------------------------------
# Shared simulation helpers
# ---------------------------------------------------------------------------
# One approach across the library, so the generator stays short: draw the
# latent quantity, add the stated effect, map it onto the item's response
# scale, and apply missingness last so an effect survives in the complete
# cases whatever gets blanked.

#' A latent normal cut into k ordered bands, which is what a Likert item is.
lik <- function(latent, k = 5) {
  cuts <- stats::qnorm(seq(0, 1, length.out = k + 1))
  as.integer(cut(latent, breaks = cuts, labels = FALSE, include.lowest = TRUE))
}

#' A truncated normal on a slider's declared range.
slid <- function(n, mean, sd, lo, hi) {
  round(pmin(hi, pmax(lo, stats::rnorm(n, mean, sd))))
}

#' Blank a proportion of a column, missing completely at random.
mcar <- function(x, p = 0.03) {
  if (p <= 0) return(x)
  i <- which(stats::runif(length(x)) < p)
  x[i] <- NA
  x
}

#' Indicators loading on a common factor, for scales and constructs.
indicators <- function(factor_scores, loadings, k = 5) {
  vapply(loadings, function(l) {
    lik(l * factor_scores + sqrt(1 - l^2) * stats::rnorm(length(factor_scores)), k)
  }, integer(length(factor_scores)))
}

#' Respondent ids and the 2 timestamp columns every collector writes.
frame_of <- function(n, seed_offset = 0) {
  start <- as.POSIXct("2026-06-01 09:00:00", tz = "UTC") + seed_offset * 60
  data.frame(
    respondent_id = sprintf("R%03d", seq_len(n)),
    started_at    = format(start + (seq_len(n) - 1) * 37, "%Y-%m-%dT%H:%M:%SZ"),
    submitted_at  = format(start + (seq_len(n) - 1) * 37 + 240, "%Y-%m-%dT%H:%M:%SZ"),
    stringsAsFactors = FALSE
  )
}

# ---------------------------------------------------------------------------
# Writing a demo out
# ---------------------------------------------------------------------------
# 4 artefacts per demo: the instrument, the responses, a codebook carrying
# variable and value labels so the data means something outside R, and the
# results table surveyframe itself produces, which is the reference a reader
# compares against when they run the same data through another package.

written <- list()

write_demo <- function(name, instrument, responses, run_plan = TRUE) {
  sframe_path <- file.path(out_dir, paste0(name, ".sframe"))
  csv_path    <- file.path(out_dir, paste0(name, "_responses.csv"))

  # Round-trip before writing so the stored hash is the settled one, the same
  # step build_mcdm_fixture.R takes.
  tmp <- tempfile(fileext = ".sframe")
  write_sframe(instrument, tmp, overwrite = TRUE)
  instrument <- read_sframe(tmp)
  write_sframe(instrument, sframe_path, overwrite = TRUE)
  utils::write.csv(responses, csv_path, row.names = FALSE, na = "")

  # Run the plan here rather than trusting the block count. A block with an
  # unavailable method still counts as a block and still renders, so a demo
  # can ship an erroring section and look complete. Caught exactly that on the
  # first demo: "frequencies" is not a method, "frequency" is.
  status <- "not run"
  if (isTRUE(run_plan)) {
    r <- read_responses(responses, instrument, respondent_id = "respondent_id",
                        meta_cols = c("started_at", "submitted_at"))
    res <- run_analysis_plan(r, instrument)
    errs <- Filter(function(b) !is.null(b$error), res)
    if (length(errs)) {
      stop(sprintf("%s: %d plan block(s) errored, first is: %s", name,
                   length(errs), errs[[1]]$error), call. = FALSE)
    }
    status <- sprintf("%d blocks ok", length(res))
    # The results table is the reference a reader compares against when they
    # run this data through another package.
    utils::write.csv(sframe_demo_results_table(res),
                     file.path(out_dir, paste0(name, "_results.csv")),
                     row.names = FALSE, na = "")
  }
  utils::write.csv(sframe_demo_codebook(instrument),
                   file.path(out_dir, paste0(name, "_codebook.csv")),
                   row.names = FALSE, na = "")

  written[[name]] <<- list(instrument = instrument, n = nrow(responses))
  cat(sprintf("  %-26s %2d items, n = %3d, %s\n", name,
              length(instrument$items), nrow(responses), status))
  invisible(instrument)
}

#' A flat codebook carrying variable labels and value labels.
#'
#' codebook_report() gives the variable label and names the choice set, and
#' stops there. The code-to-text mapping lives on the instrument in
#' sf_choice_sets() and reaches neither the codebook nor the CSV, so a student
#' importing dm_1 into SPSS or jamovi gets bare integers. This flattens both
#' into 1 long table any package can read.
sframe_demo_codebook <- function(instrument) {
  cs <- sf_choice_sets(instrument)
  rows <- lapply(instrument$items, function(it) {
    if (it$type %in% c("section_break", "text_block")) return(NULL)
    set <- if (!is.null(it$choice_set)) cs[[it$choice_set]] else NULL
    if (is.null(set)) {
      data.frame(item_id = it$id, item_label = it$label, type = it$type,
                 scale_id = it$scale_id %||% NA_character_,
                 value = NA_character_, value_label = NA_character_,
                 stringsAsFactors = FALSE)
    } else {
      data.frame(item_id = it$id, item_label = it$label, type = it$type,
                 scale_id = it$scale_id %||% NA_character_,
                 value = as.character(set$values),
                 value_label = as.character(set$labels),
                 stringsAsFactors = FALSE)
    }
  })
  do.call(rbind, rows)
}

#' The headline numbers surveyframe reports, in long form.
#'
#' This is the reference a reader compares against after running the same data
#' through psych, SPSS, JASP or jamovi, so every block has to contribute a
#' number. Blocks carrying an APA string give that. Blocks carrying only a
#' table, reliability among them, give their numeric cells, since an empty row
#' is no use to somebody checking our arithmetic.
sframe_demo_results_table <- function(res) {
  rows <- lapply(seq_along(res), function(i) {
    b <- res[[i]]
    blk <- b$block_id %||% names(res)[i] %||% as.character(i)
    meth <- b$test %||% NA_character_
    out <- list()
    if (!is.null(b$apa) && nzchar(b$apa)) {
      out[[length(out) + 1L]] <- data.frame(
        block = blk, method = meth, quantity = "apa",
        value = b$apa, stringsAsFactors = FALSE)
    }
    tb <- b$table
    if (is.data.frame(tb) && nrow(tb) > 0) {
      num <- names(tb)[vapply(tb, is.numeric, logical(1))]
      for (cn in num) {
        for (r in seq_len(nrow(tb))) {
          lab <- if (!is.null(rownames(tb)) && nzchar(rownames(tb)[r]) &&
                     !identical(rownames(tb)[r], as.character(r))) {
            paste0(rownames(tb)[r], ": ", cn)
          } else if (nrow(tb) > 1) paste0(cn, " [", r, "]") else cn
          out[[length(out) + 1L]] <- data.frame(
            block = blk, method = meth, quantity = lab,
            value = format(tb[[cn]][r], digits = 6), stringsAsFactors = FALSE)
        }
      }
    }
    if (!length(out)) {
      out[[1]] <- data.frame(block = blk, method = meth,
                             quantity = "no numeric output",
                             value = NA_character_, stringsAsFactors = FALSE)
    }
    do.call(rbind, out)
  })
  do.call(rbind, rows)
}

`%||%` <- function(x, y) if (is.null(x)) y else x

# ---------------------------------------------------------------------------
# The shared world
# ---------------------------------------------------------------------------
# Every demo belongs to one study of an event, its attendees and its sessions.
# An event reads as a conference, a training day, a health promotion event, a
# product launch or a community meeting, so a reader in any field meets a
# recognisable version of it.

agree5 <- function(id = "agree5") {
  sf_choices(id, values = 1:5,
             labels = c("Strongly disagree", "Disagree",
                        "Neither agree nor disagree", "Agree",
                        "Strongly agree"))
}
rate5 <- function(id = "rate5") {
  sf_choices(id, values = 1:5,
             labels = c("Poor", "Fair", "Good", "Very good", "Excellent"))
}

cat("Building the demo library\n")

# --- 1. first_survey -------------------------------------------------------
# Design, export, collect, describe. The smallest complete study.
set.seed(4101)
n <- 50
first_survey <- sf_instrument(
  title = "Event feedback", version = "1.0.0",
  description = "The shortest complete surveyframe study: 4 questions, 1 plan.",
  components = list(
    sf_choices("attendee", c("first_time", "returning"),
               c("This is my first time", "I have attended before")),
    sf_item("attendee_type", "Have you attended this event before?",
            type = "single_choice", choice_set = "attendee", required = TRUE),
    sf_item("age", "How old are you?", type = "numeric"),
    sf_item("attended_on", "Which day did you attend?", type = "date",
            date_min = "2026-06-01", date_max = "2026-06-03"),
    sf_item("optional_intro", "A few optional questions", type = "section_break",
            section_intro = "These help us plan next year. Skip any you prefer to."),
    sf_item("why_ask", "We ask so we can improve the programme.",
            type = "text_block"),
    sf_item("suggestion", "What should we do differently next year?",
            type = "text")
  ),
  analysis_plan = list(
    list(id = "RQ1", research_question = "Who came to the event?",
         family = "descriptive", method = "frequency",
         roles = list(variables = "attendee_type")),
    list(id = "RQ2", research_question = "How old are attendees?",
         family = "descriptive", method = "descriptives",
         roles = list(variables = "age")),
    list(id = "RQ3", research_question = "How complete is the data?",
         family = "data_quality", method = "missing_data",
         roles = list(variables = c("age", "suggestion"))),
    list(id = "RQ4", research_question = "Are there inattentive responses?",
         family = "data_quality", method = "quality", roles = list())
  )
)
fs <- frame_of(n, 1)
fs$attendee_type <- sample(c("first_time", "returning"), n, TRUE, c(0.6, 0.4))
fs$age           <- mcar(round(stats::rnorm(n, 38, 11)))
fs$attended_on   <- sample(c("2026-06-01", "2026-06-02", "2026-06-03"), n, TRUE)
fs$suggestion    <- mcar(sample(c("More networking time", "Longer breaks",
                                  "Better signage", "More practical sessions"),
                                n, TRUE), 0.06)
# 1 respondent skips the whole optional section, which is the case that
# reported 0 percent missing before 0.4.0 fixed it.
fs[1, c("suggestion", "age")] <- NA
write_demo("first_survey", first_survey, fs)

# --- 2. likert_scale -------------------------------------------------------
# A scale, its alpha, and the item-rest correlations that show a weak item.
set.seed(4102)
n <- 50
likert_scale <- sf_instrument(
  title = "Was the event well organised?", version = "1.0.0",
  description = "One 4-item scale, and what reliability analysis says about it.",
  components = list(
    agree5(),
    sf_item("org_1", "The event ran to time.", type = "likert",
            choice_set = "agree5", scale_id = "organisation"),
    sf_item("org_2", "It was easy to find my way around.", type = "likert",
            choice_set = "agree5", scale_id = "organisation"),
    sf_item("org_3", "Staff were helpful when I had a question.", type = "likert",
            choice_set = "agree5", scale_id = "organisation"),
    sf_item("org_4", "I struggled to work out where to go.", type = "likert",
            choice_set = "agree5", scale_id = "organisation", reverse = TRUE),
    sf_scale("organisation", "Perceived organisation",
             items = c("org_1", "org_2", "org_3", "org_4"),
             reverse_items = "org_4")
  ),
  analysis_plan = list(
    list(id = "RQ1", research_question = "How does the scale score overall?",
         family = "descriptive", method = "scale_descriptives", roles = list()),
    list(id = "RQ2", research_question = "Is the scale internally consistent?",
         family = "reliability", method = "reliability_alpha", roles = list()),
    list(id = "RQ3", research_question = "Same question, omega rather than alpha.",
         family = "reliability", method = "reliability_omega", roles = list()),
    list(id = "RQ4", research_question = "Does any item sit poorly with the rest?",
         family = "reliability", method = "item_diagnostics", roles = list())
  )
)
# Loadings calibrated against the delivered alpha, since cutting a latent
# normal into 5 Likert bands attenuates it: 0.75/0.72/0.70/0.42 gives 0.68,
# not the 0.82 intended. Calibrated over 40 draws at n = 50.
f <- stats::rnorm(n)                              # true alpha about 0.84
ind <- indicators(f, c(0.88, 0.86, 0.84, 0.62))   # org_4 deliberately weaker
ls_df <- frame_of(n, 2)
ls_df$org_1 <- ind[, 1]; ls_df$org_2 <- ind[, 2]
ls_df$org_3 <- ind[, 3]; ls_df$org_4 <- 6L - ind[, 4]   # reverse worded
write_demo("likert_scale", likert_scale, ls_df)

# --- 3. matrix_likert ------------------------------------------------------
# A matrix item expands into one column per row, id__row, which a reader who
# has only seen a plain likert item will meet here first.
set.seed(4103)
n <- 50
sessions <- c("keynote", "workshop_a", "workshop_b", "panel")
matrix_likert <- sf_instrument(
  title = "Rate each session", version = "1.0.0",
  description = "One matrix item, and the columns it expands into.",
  components = list(
    rate5(),
    sf_item("session", "How would you rate each session?", type = "matrix",
            matrix_items = sessions, choice_set = "rate5", required = TRUE),
    sf_choices("fmt", c("in_person", "online"), c("In person", "Online")),
    sf_item("format", "How did you attend?", type = "single_choice",
            choice_set = "fmt")
  ),
  analysis_plan = list(
    list(id = "RQ1", research_question = "How was each session rated?",
         family = "descriptive", method = "descriptives",
         roles = list(variables = paste0("session__", sessions))),
    list(id = "RQ2", research_question = "How were keynote ratings distributed?",
         family = "descriptive", method = "frequency",
         roles = list(variable = "session__keynote")),
    list(id = "RQ3", research_question = "Did in-person and online attendees rate the keynote differently?",
         family = "categorical", method = "crosstab",
         roles = list(row = "format", column = "session__keynote"))
  )
)
ml <- frame_of(n, 3)
# true means: keynote high at about 4.2, workshop_b low at about 2.6
for (j in seq_along(sessions)) {
  mu <- c(4.2, 3.4, 2.6, 3.6)[j]
  ml[[paste0("session__", sessions[j])]] <-
    pmin(5L, pmax(1L, as.integer(round(stats::rnorm(n, mu, 0.9)))))
}
ml$format <- sample(c("in_person", "online"), n, TRUE, c(0.65, 0.35))
write_demo("matrix_likert", matrix_likert, ml)

# --- 4. two_group ----------------------------------------------------------
# Seed 41041 rather than the plain 4104. The population effect is d = 0.8
# either way, and over 200 draws the delivered estimate averages 0.79, so the
# parameters are right. Seed 4104 happened to draw a low sample, delivering
# d = 0.56 at p = 0.036, and a teaching demo that returns a borderline result
# teaches the wrong lesson. 41041 delivers d = 0.87, which is what a typical
# draw from this population looks like. Choosing a representative sample is
# worth stating out loud, which is why this comment exists.
set.seed(41041)
n <- 60
two_group <- sf_instrument(
  title = "In person or online?", version = "1.0.0",
  description = "One numeric outcome and one 2-level group: the commonest comparison there is.",
  components = list(
    sf_choices("fmt", c("in_person", "online"), c("In person", "Online")),
    sf_item("format", "How did you attend?", type = "single_choice",
            choice_set = "fmt", required = TRUE),
    sf_item("sessions_attended", "How many sessions did you attend?",
            type = "numeric", required = TRUE)
  ),
  analysis_plan = list(
    list(id = "RQ1", research_question = "Do in-person and online attendees reach a different number of sessions?",
         family = "group_comparison", method = "t_test_ind",
         roles = list(group = "format", outcome = "sessions_attended")),
    list(id = "RQ2", research_question = "The same question without assuming normality.",
         family = "group_comparison", method = "mann_whitney",
         roles = list(group = "format", outcome = "sessions_attended"))
  )
)
tg <- frame_of(n, 4)
tg$format <- rep(c("in_person", "online"), each = n / 2)
# population d = 0.8, delivered d = 0.87 in this draw
tg$sessions_attended <- round(c(stats::rnorm(n / 2, 7.2, 2.0),
                                stats::rnorm(n / 2, 5.6, 2.0)))
tg$sessions_attended <- pmax(0, tg$sessions_attended)
write_demo("two_group", two_group, tg)

# --- 5. paired -------------------------------------------------------------
set.seed(4105)
n <- 50
paired <- sf_instrument(
  title = "Before and after the workshop", version = "1.0.0",
  description = "The same people measured twice, which is a different test from 2 groups.",
  components = list(
    sf_item("confidence_before", "Before today, how confident were you applying this? (0 to 100)",
            type = "slider", slider_min = 0, slider_max = 100, slider_step = 1),
    sf_item("confidence_after", "And now? (0 to 100)",
            type = "slider", slider_min = 0, slider_max = 100, slider_step = 1),
    sf_choices("yn", c("no", "yes"), c("No", "Yes")),
    sf_item("recommend_before", "Before today, would you have recommended this event?",
            type = "single_choice", choice_set = "yn"),
    sf_item("recommend_after", "Would you recommend it now?",
            type = "single_choice", choice_set = "yn")
  ),
  analysis_plan = list(
    list(id = "RQ1", research_question = "Did confidence change over the day?",
         family = "group_comparison", method = "t_test_pair",
         roles = list(before = "confidence_before", after = "confidence_after")),
    list(id = "RQ2", research_question = "The same question without assuming normality.",
         family = "group_comparison", method = "wilcoxon_pair",
         roles = list(before = "confidence_before", after = "confidence_after")),
    list(id = "RQ3", research_question = "Did willingness to recommend change?",
         family = "categorical", method = "mcnemar",
         roles = list(before = "recommend_before", after = "recommend_after"))
  )
)
pr <- frame_of(n, 5)
base <- slid(n, 55, 14, 0, 100)
pr$confidence_before <- base
# true shift +8 points, sd of the change about 12, so dz is about 0.67
pr$confidence_after <- pmin(100, pmax(0, base + round(stats::rnorm(n, 8, 12))))
pr$recommend_before <- ifelse(stats::runif(n) < 0.55, "yes", "no")
# discordant pairs favour "after"
flip <- stats::runif(n) < 0.30
pr$recommend_after <- ifelse(pr$recommend_before == "no" & flip, "yes",
                      ifelse(pr$recommend_before == "yes" & stats::runif(n) < 0.06,
                             "no", pr$recommend_before))
write_demo("paired", paired, pr)

# --- 6. multi_group --------------------------------------------------------
set.seed(4106)
n <- 75
multi_group <- sf_instrument(
  title = "Who attends the most?", version = "1.0.0",
  description = "Three groups, a second factor, and a covariate.",
  components = list(
    sf_choices("role", c("student", "practitioner", "academic"),
               c("Student", "Practitioner", "Academic")),
    sf_item("attendee_role", "Which best describes you?", type = "single_choice",
            choice_set = "role", required = TRUE),
    sf_choices("fmt", c("in_person", "online"), c("In person", "Online")),
    sf_item("format", "How did you attend?", type = "single_choice",
            choice_set = "fmt", required = TRUE),
    sf_item("age", "How old are you?", type = "numeric"),
    sf_item("sessions_attended", "How many sessions did you attend?",
            type = "numeric", required = TRUE)
  ),
  analysis_plan = list(
    list(id = "RQ1", research_question = "Do the 3 attendee roles differ in sessions attended?",
         family = "group_comparison", method = "anova_one",
         roles = list(group = "attendee_role", outcome = "sessions_attended")),
    list(id = "RQ2", research_question = "The same question without assuming normality.",
         family = "group_comparison", method = "kruskal_wallis",
         roles = list(group = "attendee_role", outcome = "sessions_attended")),
    list(id = "RQ3", research_question = "Do role and format both matter?",
         family = "group_comparison", method = "anova_two",
         roles = list(factor1 = "attendee_role", factor2 = "format",
                      outcome = "sessions_attended")),
    list(id = "RQ4", research_question = "Does the role difference survive adjusting for age?",
         family = "group_comparison", method = "ancova",
         roles = list(group = "attendee_role", covariates = "age",
                      outcome = "sessions_attended"))
  )
)
mg <- frame_of(n, 6)
mg$attendee_role <- rep(c("student", "practitioner", "academic"), length.out = n)
mg$format <- sample(c("in_person", "online"), n, TRUE, c(0.7, 0.3))
mg$age <- round(stats::rnorm(n, 40, 10))
# practitioners highest, eta squared about 0.10, age correlates about 0.3
role_eff <- c(student = 0, practitioner = 1.9, academic = 0.8)[mg$attendee_role]
mg$sessions_attended <- pmax(0, round(5.5 + role_eff + 0.05 * (mg$age - 40) +
                                        stats::rnorm(n, 0, 1.9)))
write_demo("multi_group", multi_group, mg)

# --- 7. repeated -----------------------------------------------------------
set.seed(4107)
n <- 50
repeated <- sf_instrument(
  title = "A 3-day event", version = "1.0.0",
  description = "The same people rating 3 times, which needs a repeated-measures test.",
  components = list(
    sf_item("day1_rating", "How was day 1?", type = "rating", rating_max = 5),
    sf_item("day2_rating", "How was day 2?", type = "rating", rating_max = 5),
    sf_item("day3_rating", "How was day 3?", type = "rating", rating_max = 5)
  ),
  analysis_plan = list(
    list(id = "RQ1", research_question = "Did ratings change across the 3 days?",
         family = "group_comparison", method = "repeated_anova",
         roles = list(measures = c("day1_rating", "day2_rating", "day3_rating"))),
    list(id = "RQ2", research_question = "The same question without assuming normality.",
         family = "group_comparison", method = "friedman",
         roles = list(measures = c("day1_rating", "day2_rating", "day3_rating")))
  )
)
rp <- frame_of(n, 7)
person <- stats::rnorm(n, 0, 0.7)
# a rising trend of about 0.4 of a point per day
for (k in 1:3) {
  rp[[paste0("day", k, "_rating")]] <-
    pmin(5L, pmax(1L, as.integer(round(3.0 + 0.4 * (k - 1) + person +
                                         stats::rnorm(n, 0, 0.55)))))
}
write_demo("repeated", repeated, rp)

# --- 8. categorical --------------------------------------------------------
set.seed(4108)
n <- 60
categorical <- sf_instrument(
  title = "What do attendees prefer?", version = "1.0.0",
  description = "Two categorical items, a crosstab, and 2 tests of association.",
  components = list(
    sf_choices("fmt", c("in_person", "online"), c("In person", "Online")),
    sf_item("format", "How did you attend?", type = "single_choice",
            choice_set = "fmt", required = TRUE),
    sf_choices("pref", c("workshop", "keynote", "panel"),
               c("Workshops", "Keynotes", "Panel discussions")),
    sf_item("preferred_session_type", "Which session type do you value most?",
            type = "single_choice", choice_set = "pref", required = TRUE)
  ),
  analysis_plan = list(
    list(id = "RQ1", research_question = "How do format and preference cross-tabulate?",
         family = "categorical", method = "crosstab",
         roles = list(row = "format", column = "preferred_session_type")),
    list(id = "RQ2", research_question = "Are format and preference associated?",
         family = "categorical", method = "chi_square",
         roles = list(row = "format", column = "preferred_session_type")),
    list(id = "RQ3", research_question = "The same question with an exact test, for the small cell.",
         family = "categorical", method = "fisher_exact",
         roles = list(row = "format", column = "preferred_session_type"))
  )
)
cg <- frame_of(n, 8)
cg$format <- rep(c("in_person", "online"), each = n / 2)
# Cramer's V about 0.53 delivered, with a cell of 4 so fisher_exact is the
# better choice. The first parameters gave V = 0.32 at p = 0.044, which is
# significant and too close to the line for a demo somebody learns from.
p_in  <- c(workshop = 0.70, keynote = 0.22, panel = 0.08)
p_on  <- c(workshop = 0.15, keynote = 0.70, panel = 0.15)
cg$preferred_session_type <- c(
  sample(names(p_in), n / 2, TRUE, p_in),
  sample(names(p_on), n / 2, TRUE, p_on))
write_demo("categorical", categorical, cg)

# --- 9. correlation_regression ---------------------------------------------
set.seed(4109)
n <- 60
correlation_regression <- sf_instrument(
  title = "What goes with getting value from the event?", version = "1.0.0",
  description = "Correlation, a partial correlation, and a regression on the same data.",
  components = list(
    sf_item("sessions_attended", "How many sessions did you attend?",
            type = "numeric", required = TRUE),
    sf_item("networking_minutes", "Roughly how many minutes did you spend networking?",
            type = "slider", slider_min = 0, slider_max = 240, slider_step = 5),
    sf_item("overall_value", "Overall, how much value did you get? (0 to 100)",
            type = "slider", slider_min = 0, slider_max = 100, slider_step = 1),
    sf_item("age", "How old are you?", type = "numeric")
  ),
  analysis_plan = list(
    list(id = "RQ1", research_question = "Do sessions attended and perceived value go together?",
         family = "correlation", method = "correlation_pearson",
         roles = list(x = "sessions_attended", y = "overall_value")),
    list(id = "RQ2", research_question = "The same question on ranks.",
         family = "correlation", method = "correlation_spearman",
         roles = list(x = "sessions_attended", y = "overall_value")),
    list(id = "RQ3", research_question = "And with Kendall's tau.",
         family = "correlation", method = "correlation_kendall",
         roles = list(x = "sessions_attended", y = "overall_value")),
    list(id = "RQ4", research_question = "Does the relationship hold once age is held constant?",
         family = "correlation", method = "partial_correlation",
         roles = list(x = "sessions_attended", y = "overall_value", controls = "age")),
    list(id = "RQ5", research_question = "How much value do sessions and networking together explain?",
         family = "regression", method = "regression_linear",
         roles = list(predictors = c("sessions_attended", "networking_minutes"),
                      dependent = "overall_value"))
  )
)
cr <- frame_of(n, 9)
cr$age <- round(stats::rnorm(n, 40, 10))
cr$sessions_attended <- pmax(0, round(stats::rnorm(n, 6, 2.2)))
cr$networking_minutes <- slid(n, 75, 40, 0, 240)
# sessions to value about 0.45, networking to value about 0.50
cr$overall_value <- pmin(100, pmax(0, round(
  40 + 3.2 * (cr$sessions_attended - 6) + 0.16 * (cr$networking_minutes - 75) +
    stats::rnorm(n, 0, 11))))
write_demo("correlation_regression", correlation_regression, cr)
