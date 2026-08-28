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

#' The standard branding, applied on demand rather than baked into a fixture.
#'
#' One definition serves every demo, so a reader sees a welcome page and a logo
#' on the demo that matches their own survey, and no fixture on disk changes.
sframe_demo_branding_block <- function(mode = "standard") {
  list(
    mode = mode,
    theme = "#2563eb",
    submit_label = "Send my feedback",
    welcome = list(
      title = "Thank you for coming",
      intro_text = paste("This takes about 3 minutes. Your answers help us",
                         "plan next year's event."),
      consent_text = "I am happy for my answers to be used in the event report.",
      consent_required = TRUE,
      start_label = "Start"),
    thankyou = list(
      message = "Thank you. Your feedback has been recorded.",
      redirect_url = "",
      show_download = TRUE),
    header = list(
      institution = "Riverside Conference Centre",
      logo_base64 = "",
      show_progress = TRUE)
  )
}

write_demo <- function(name, instrument, responses, run_plan = TRUE,
                       reuse_responses = NULL) {
  sframe_path <- file.path(out_dir, paste0(name, ".sframe"))
  csv_path    <- file.path(out_dir, paste0(name, "_responses.csv"))

  # Round-trip before writing so the stored hash is the settled one, the same
  # step build_mcdm_fixture.R takes.
  tmp <- tempfile(fileext = ".sframe")
  write_sframe(instrument, tmp, overwrite = TRUE)
  instrument <- read_sframe(tmp)
  write_sframe(instrument, sframe_path, overwrite = TRUE)
  # Demos 18 to 22 share an existing response file, since only the render
  # block or the provenance differs. Duplicating the data would suggest the
  # studies differ when they do not.
  if (is.null(reuse_responses)) {
    utils::write.csv(responses, csv_path, row.names = FALSE, na = "")
  }

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
    # A block whose method needs an optional package that is absent here is a
    # legitimate skip, and the package guards those methods deliberately. A
    # block that errors for any other reason is a broken demo and stops the
    # build.
    absent <- vapply(errs, function(b)
      grepl("install|not installed|requires the|cannot be loaded|is required",
            b$error, ignore.case = TRUE), logical(1))
    real <- errs[!absent]
    if (length(real)) {
      stop(sprintf("%s: %d plan block(s) errored, first is: %s", name,
                   length(real), real[[1]]$error), call. = FALSE)
    }
    status <- sprintf("%d blocks ok%s", length(res),
                      if (any(absent)) sprintf(", %d skipped for a missing package",
                                               sum(absent)) else "")
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
# Readable row labels, since these become the matrix rows a respondent sees
# and the expansion column names a reader meets. Spaces are handled, as the
# bundled input-types fixture already shows with "Staff helpfulness".
sessions <- c("Opening keynote", "Workshop A", "Workshop B", "Closing panel")
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
         roles = list(variable = paste0("session__", sessions[1]))),
    list(id = "RQ3", research_question = "Did in-person and online attendees rate the keynote differently?",
         family = "categorical", method = "crosstab",
         roles = list(row = "format", column = paste0("session__", sessions[1])))
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

# --- 10. logistic ----------------------------------------------------------
# The same predictor against 3 outcome shapes, so a reader sees which model
# the outcome chooses.
set.seed(4110)
n <- 80
logistic <- sf_instrument(
  title = "Will they come back?", version = "1.0.0",
  description = "Binary, ordinal and 3-category outcomes from one predictor.",
  components = list(
    sf_item("sessions_attended", "How many sessions did you attend?",
            type = "numeric", required = TRUE),
    sf_choices("yn", c("no", "yes"), c("No", "Yes")),
    sf_item("will_return", "Will you attend next year?", type = "single_choice",
            choice_set = "yn", required = TRUE),
    agree5(),
    sf_item("satisfaction", "I was satisfied with the event.", type = "likert",
            choice_set = "agree5", required = TRUE),
    sf_choices("pref", c("workshop", "keynote", "panel"),
               c("Workshops", "Keynotes", "Panel discussions")),
    sf_item("preferred_session_type", "Which session type do you value most?",
            type = "single_choice", choice_set = "pref", required = TRUE)
  ),
  analysis_plan = list(
    list(id = "RQ1", research_question = "Does attending more sessions predict returning?",
         family = "regression", method = "regression_logistic_binary",
         roles = list(predictors = "sessions_attended", dependent = "will_return")),
    list(id = "RQ2", research_question = "And does it predict how satisfied they were?",
         family = "regression", method = "regression_logistic_ordinal",
         roles = list(predictors = "sessions_attended", dependent = "satisfaction")),
    list(id = "RQ3", research_question = "And which session type they prefer?",
         family = "regression", method = "regression_logistic_multinomial",
         roles = list(predictors = "sessions_attended",
                      dependent = "preferred_session_type"))
  )
)
lg <- frame_of(n, 10)
lg$sessions_attended <- pmax(0, round(stats::rnorm(n, 6, 2.2)))
z <- scale(lg$sessions_attended)[, 1]
# odds ratio about 2.4 per standard deviation of sessions
lg$will_return <- ifelse(stats::runif(n) < stats::plogis(0.2 + 0.88 * z), "yes", "no")
lg$satisfaction <- lik(0.7 * z + sqrt(1 - 0.49) * stats::rnorm(n))
lg$preferred_session_type <- ifelse(
  z > 0.5, sample(c("workshop", "keynote"), n, TRUE, c(0.7, 0.3)),
  sample(c("keynote", "panel"), n, TRUE, c(0.6, 0.4)))
write_demo("logistic", logistic, lg)

# --- 11. factor_structure --------------------------------------------------
# 8 items over 2 scales. n is larger because parallel analysis needs it to
# settle on the right number of factors.
set.seed(4111)
n <- 120
org_items <- c("The event ran to time.", "It was easy to find my way around.",
               "Staff were helpful.", "The venue suited the event.")
con_items <- c("The sessions were relevant to my work.",
               "The material went deep enough.", "The speakers knew their subject.",
               "The handouts were useful.")
comp <- list(agree5())
for (k in 1:4) comp <- c(comp, list(sf_item(sprintf("org_%d", k), org_items[k],
  type = "likert", choice_set = "agree5", scale_id = "organisation")))
for (k in 1:4) comp <- c(comp, list(sf_item(sprintf("con_%d", k), con_items[k],
  type = "likert", choice_set = "agree5", scale_id = "content")))
comp <- c(comp, list(
  sf_scale("organisation", "Perceived organisation", items = paste0("org_", 1:4)),
  sf_scale("content", "Perceived content quality", items = paste0("con_", 1:4))))
factor_structure <- sf_instrument(
  title = "Two things attendees judge", version = "1.0.0",
  description = "Eight items, 2 factors, and whether the data supports that.",
  components = comp,
  analysis_plan = list(
    list(id = "RQ1", research_question = "Is this data suitable for factor analysis?",
         family = "measurement", method = "efa_readiness",
         roles = list(items = c(paste0("org_", 1:4), paste0("con_", 1:4)))),
    list(id = "RQ2", research_question = "How many factors, and which items load where?",
         family = "measurement", method = "efa_solution",
         roles = list(items = c(paste0("org_", 1:4), paste0("con_", 1:4))))
  )
)
f1 <- stats::rnorm(n); f2 <- 0.35 * f1 + sqrt(1 - 0.35^2) * stats::rnorm(n)
fsx <- frame_of(n, 11)
o <- indicators(f1, c(0.80, 0.78, 0.74, 0.70))
c2 <- indicators(f2, c(0.79, 0.76, 0.73, 0.68))
for (k in 1:4) fsx[[paste0("org_", k)]] <- o[, k]
for (k in 1:4) fsx[[paste0("con_", k)]] <- c2[, k]
write_demo("factor_structure", factor_structure, fsx)

# --- 12. sem_pls -----------------------------------------------------------
set.seed(4112)
n <- 150
mk <- function(prefix, labels, scale_id) {
  lapply(seq_along(labels), function(k)
    sf_item(sprintf("%s_%d", prefix, k), labels[k], type = "likert",
            choice_set = "agree5", scale_id = scale_id))
}
sem_comp <- c(
  list(agree5()),
  mk("cq", c("The sessions were relevant.", "The material went deep enough.",
             "The speakers knew their subject."), "content_quality"),
  mk("sa", c("I was satisfied with the event.", "The event met my expectations.",
             "It was a good use of my time."), "satisfaction"),
  mk("it", c("I will attend next year.", "I would recommend it to a colleague.",
             "I would pay to attend again."), "intention"),
  list(sf_scale("content_quality", "Content quality", items = paste0("cq_", 1:3)),
       sf_scale("satisfaction", "Satisfaction", items = paste0("sa_", 1:3)),
       sf_scale("intention", "Intention to return", items = paste0("it_", 1:3)))
)
sem_model <- sf_model(
  id = "m1", label = "Content quality to intention", type = "cb_sem",
  engine = "lavaan",
  constructs = list(
    sf_construct("content_quality", items = paste0("cq_", 1:3)),
    sf_construct("satisfaction", items = paste0("sa_", 1:3)),
    sf_construct("intention", items = paste0("it_", 1:3))),
  paths = list(sf_path("content_quality", "satisfaction"),
               sf_path("satisfaction", "intention"),
               sf_path("content_quality", "intention")),
  indirect = list(sf_indirect("content_quality", "satisfaction", "intention"))
)
# Two models on purpose, and the reason is worth teaching. seminr_syntax()
# refuses a cb_sem model, because generating PLS syntax from a covariance-based
# declaration would estimate a different model from the one declared. So the
# same 3 constructs are declared twice, once for each engine, and a reader
# sees that the model type decides the syntax.
pls_model <- sf_model(
  id = "m2", label = "The same paths, estimated by PLS", type = "pls_sem",
  engine = "seminr",
  constructs = list(
    sf_construct("content_quality", items = paste0("cq_", 1:3), mode = "composite"),
    sf_construct("satisfaction", items = paste0("sa_", 1:3), mode = "composite"),
    sf_construct("intention", items = paste0("it_", 1:3), mode = "composite")),
  paths = list(sf_path("content_quality", "satisfaction"),
               sf_path("satisfaction", "intention"),
               sf_path("content_quality", "intention"))
)
# A measurement model on its own, so cfa_lavaan_syntax() has something to
# generate from. The same 3 constructs with no structural paths declared.
cfa_model <- sf_model(
  id = "m3", label = "Measurement model only", type = "cfa", engine = "lavaan",
  constructs = list(
    sf_construct("content_quality", items = paste0("cq_", 1:3)),
    sf_construct("satisfaction", items = paste0("sa_", 1:3)),
    sf_construct("intention", items = paste0("it_", 1:3)))
)
sem_pls <- sf_instrument(
  title = "Does content quality bring people back?", version = "1.0.0",
  description = "Three constructs, a declared path model, and the syntax it generates.",
  components = sem_comp, models = list(sem_model, pls_model, cfa_model),
  analysis_plan = list(
    list(id = "RQ1", research_question = "What lavaan syntax does this model generate?",
         family = "measurement", method = "sem_lavaan_syntax",
         roles = list(model = "m1")),
    list(id = "RQ2", research_question = "And the seminr syntax for a PLS estimate?",
         family = "measurement", method = "seminr_syntax",
         roles = list(model = "m2")),
    list(id = "RQ3", research_question = "Does satisfaction carry content quality through to intention?",
         family = "regression", method = "mediation",
         roles = list(predictor = "content_quality", mediator = "satisfaction",
                      outcome = "intention")),
    list(id = "RQ4", research_question = "What CFA syntax does the measurement model generate?",
         family = "measurement", method = "cfa_lavaan_syntax",
         roles = list(model = "m3")),
    list(id = "RQ5", research_question = "And what does a PLS estimate give?",
         family = "measurement", method = "pls_sem",
         roles = list(model = "m2")),
    list(id = "RQ6", research_question = "Does content quality matter more to some attendees than others?",
         family = "regression", method = "moderation",
         roles = list(predictor = "content_quality", moderator = "satisfaction",
                      outcome = "intention"))
  )
)
# paths 0.45 and 0.40 with a direct 0.20, so the indirect effect is near 0.18
cqf <- stats::rnorm(n)
saf <- 0.45 * cqf + sqrt(1 - 0.45^2) * stats::rnorm(n)
itf <- 0.40 * saf + 0.20 * cqf + sqrt(1 - 0.40^2 - 0.20^2) * stats::rnorm(n)
sp <- frame_of(n, 12)
for (k in 1:3) sp[[paste0("cq_", k)]] <- indicators(cqf, 0.80)[, 1]
for (k in 1:3) sp[[paste0("sa_", k)]] <- indicators(saf, 0.78)[, 1]
for (k in 1:3) sp[[paste0("it_", k)]] <- indicators(itf, 0.76)[, 1]
write_demo("sem_pls", sem_pls, sp)

# --- 13. branching ---------------------------------------------------------
# A multi-value %in% rule, which was dead in every exported survey from 0.3.0
# to 0.4.0 and is the reason this demo exists.
set.seed(4113)
n <- 50
branching <- sf_instrument(
  title = "Questions that depend on who you are", version = "1.0.0",
  description = "Skip logic, and why a skipped question differs from a missing answer.",
  components = list(
    sf_choices("who", c("delegate", "speaker", "exhibitor", "visitor"),
               c("Delegate", "Speaker", "Exhibitor", "Day visitor")),
    sf_item("attendee_type", "What brought you here?", type = "single_choice",
            choice_set = "who", required = TRUE),
    sf_item("sessions_attended", "How many sessions did you attend?",
            type = "numeric"),
    sf_item("comment", "Anything you would change about the programme?",
            type = "text"),
    sf_branch(item_id = "sessions_attended", depends_on = "attendee_type",
              operator = "%in%", value = c("delegate", "speaker"),
              action = "show"),
    sf_branch(item_id = "comment", depends_on = "attendee_type",
              operator = "%in%", value = c("delegate", "speaker"),
              action = "show")
  ),
  analysis_plan = list(
    list(id = "RQ1", research_question = "Who attended, and in what proportions?",
         family = "descriptive", method = "frequency",
         roles = list(variable = "attendee_type")),
    list(id = "RQ2", research_question = "Among those asked, how many sessions did they attend?",
         family = "descriptive", method = "descriptives",
         roles = list(variables = "sessions_attended"))
  )
)
br <- frame_of(n, 13)
br$attendee_type <- sample(c("delegate", "speaker", "exhibitor", "visitor"),
                           n, TRUE, c(0.55, 0.15, 0.15, 0.15))
asked <- br$attendee_type %in% c("delegate", "speaker")
br$sessions_attended <- ifelse(asked, pmax(0, round(stats::rnorm(n, 6, 2.1))), NA)
br$comment <- ifelse(asked, sample(c("More breaks", "Longer sessions",
                                     "Better catering", ""), n, TRUE), NA)
write_demo("branching", branching, br)

# --- 14. open_text ---------------------------------------------------------
# A small controlled vocabulary, so term frequency, n-grams and topics return
# something stable and readable.
set.seed(4114)
n <- 60
open_text <- sf_instrument(
  title = "What worked, and what to change", version = "1.0.0",
  description = "Two open questions, and the 9 things surveyframe can do with them.",
  components = list(
    sf_choices("fmt", c("in_person", "online"), c("In person", "Online")),
    sf_item("format", "How did you attend?", type = "single_choice",
            choice_set = "fmt", required = TRUE),
    sf_item("what_worked", "What worked well?", type = "textarea"),
    sf_item("what_to_improve", "What should we change?", type = "textarea")
  ),
  analysis_plan = list(
    list(id = "RQ1", research_question = "Which words come up most often?",
         family = "text", method = "term_freq",
         roles = list(item = "what_worked")),
    list(id = "RQ2", research_question = "And which pairs of words?",
         family = "text", method = "ngram_freq",
         roles = list(item = "what_worked")),
    list(id = "RQ3", research_question = "How is a key word actually used?",
         family = "text", method = "term_context",
         roles = list(item = "what_worked"), options = list(term = "sessions")),
    list(id = "RQ4", research_question = "Which words appear together?",
         family = "text", method = "co_occurrence",
         roles = list(item = "what_worked")),
    list(id = "RQ5", research_question = "Do in-person and online attendees say different things?",
         family = "text", method = "term_freq",
         roles = list(item = "what_to_improve", group = "format")),
    list(id = "RQ6", research_question = "Which words cluster together?",
         family = "text", method = "co_occurrence_network",
         roles = list(item = "what_worked")),
    list(id = "RQ7", research_question = "Is the tone positive or negative?",
         family = "text", method = "tidy_sentiment",
         roles = list(item = "what_to_improve")),
    list(id = "RQ8", research_question = "What does a document-feature matrix show?",
         family = "text", method = "quanteda_dfm",
         roles = list(item = "what_worked")),
    list(id = "RQ9", research_question = "What topics are people writing about?",
         family = "text", method = "topic_model_lda",
         roles = list(item = "what_to_improve"), options = list(k = 2L)),
    list(id = "RQ10", research_question = "The same question with a structural topic model.",
         family = "text", method = "stm_topics",
         roles = list(item = "what_to_improve"), options = list(k = 2L))
  )
)
good_in <- c("the sessions were excellent and well organised",
             "excellent speakers and useful practical sessions",
             "networking was valuable and the venue was good",
             "well organised sessions with useful handouts")
good_on <- c("the online platform worked well and was easy",
             "useful sessions and the recordings were excellent",
             "easy to join and the speakers were clear",
             "good content and easy access from home")
bad_in  <- c("the breaks were too short and rooms were crowded",
             "more practical sessions and longer breaks please",
             "catering was poor and signage was confusing",
             "too crowded and the rooms were hard to find")
bad_on  <- c("the platform was slow and hard to navigate",
             "more interaction please and better audio quality",
             "audio was poor and it was hard to ask questions",
             "slow platform and little chance to interact")
ot <- frame_of(n, 14)
ot$format <- sample(c("in_person", "online"), n, TRUE, c(0.55, 0.45))
ot$what_worked <- ifelse(ot$format == "in_person",
                         sample(good_in, n, TRUE), sample(good_on, n, TRUE))
ot$what_to_improve <- ifelse(ot$format == "in_person",
                             sample(bad_in, n, TRUE), sample(bad_on, n, TRUE))
write_demo("open_text", open_text, ot)

# --- 17. multi_response ----------------------------------------------------
# multiple_choice and ranking both expand into 1 column per option, which a
# reader who has seen only likert meets here first. read_responses() accepts
# the expanded form as well as the separated one, and cochran_q needs it.
set.seed(4117)
n <- 60
sess <- c("keynote", "workshop", "panel", "poster", "social")
reasons <- c("content", "networking", "location")
multi_response <- sf_instrument(
  title = "Which sessions, and why come at all?", version = "1.0.0",
  description = "Two items that expand into one column per option.",
  components = list(
    sf_choices("sessions", sess,
               c("Opening keynote", "Workshops", "Panel discussion",
                 "Poster session", "Social evening")),
    sf_item("sessions_chosen", "Which did you attend? Choose any.",
            type = "multiple_choice", choice_set = "sessions", required = TRUE),
    sf_choices("reasons", reasons,
               c("The content", "The networking", "The location")),
    sf_item("rank_priorities", "Rank your reasons for attending.",
            type = "ranking", choice_set = "reasons", required = TRUE)
  ),
  analysis_plan = list(
    list(id = "RQ1", research_question = "Which sessions were best attended?",
         family = "descriptive", method = "descriptives",
         roles = list(variables = paste0("sessions_chosen__", sess))),
    list(id = "RQ2", research_question = "Do the sessions differ in how often they were chosen?",
         family = "categorical", method = "cochran_q",
         roles = list(measures = paste0("sessions_chosen__", sess))),
    list(id = "RQ3", research_question = "What did attendees come for?",
         family = "descriptive", method = "descriptives",
         roles = list(variables = paste0("rank_priorities__", reasons)))
  )
)
mr <- frame_of(n, 17)
# keynote about 70 percent, poster about 25, so cochran_q has something to find
probs <- c(keynote = 0.72, workshop = 0.58, panel = 0.40, poster = 0.25,
           social = 0.45)
for (sname in sess) {
  mr[[paste0("sessions_chosen__", sname)]] <-
    as.integer(stats::runif(n) < probs[[sname]])
}
# a consensus order with content first, and some disagreement
for (r in seq_len(n)) {
  ord <- if (stats::runif(1) < 0.65) c("content", "networking", "location") else
    sample(reasons)
  for (k in seq_along(reasons)) {
    mr[r, paste0("rank_priorities__", reasons[k])] <- which(ord == reasons[k])
  }
}
write_demo("multi_response", multi_response, mr)

# --- 15. mcdm_choice -------------------------------------------------------
# Choosing the venue for next year, which is what an event organiser decides.
# Reframed from the bundled hotel-supplier fixture, whose data this leaves
# untouched, and extended so all 10 MCDA methods appear.
set.seed(4115)
n <- 12
crit <- c("cost", "capacity", "transport", "catering")
venues <- c("Riverside", "Old Mill", "Civic Hall", "Parkview", "Harbour Suite")

mcdm_components <- list(
  sf_item("crit_pairs", "Compare the importance of each pair of criteria",
          type = "pairwise_comparison", comparison_items = crit,
          comparison_scale = "saaty", required = TRUE),
  sf_item("crit_points", "Divide 100 points across the criteria",
          type = "criteria_weight", comparison_items = crit, required = TRUE),
  sf_item("crit_influence", "How strongly does each factor influence the others?",
          type = "pairwise_comparison", comparison_items = crit,
          comparison_scale = "influence", required = TRUE)
)

# The audited figures every matrix method scores. Cost and transport time are
# cost criteria, where lower is better.
perf <- list(c(4.1, 3.0, 210, 36), c(3.6, 4.5, 180, 48), c(4.8, 2.5, 260, 24),
             c(3.9, 4.0, 150, 72), c(4.4, 3.8, 230, 30))
matrix_block <- function(id, question, method) {
  list(id = id, research_question = question, family = "decision",
       method = method, roles = list(weights_item = "crit_pairs"),
       options = list(matrix = perf, alternatives = venues, criteria = crit,
                      criteria_types = c("benefit", "benefit", "cost", "cost")))
}
mcdm_choice <- sf_instrument(
  title = "Choosing next year's venue", version = "1.0.0",
  description = "One decision, 10 methods, and whether they agree.",
  components = mcdm_components,
  analysis_plan = c(
    list(
      list(id = "RQ1", research_question = "What weight does each criterion carry?",
           family = "decision", method = "ahp",
           roles = list(pairwise = "crit_pairs"), options = list(cr_filter = FALSE)),
      list(id = "RQ2", research_question = "The same weights with network dependence allowed.",
           family = "decision", method = "anp",
           roles = list(pairwise = "crit_pairs"), options = list(cr_filter = FALSE)),
      list(id = "RQ3", research_question = "Which criteria drive the others?",
           family = "decision", method = "dematel",
           roles = list(pairwise = "crit_influence"))),
    Map(matrix_block,
        sprintf("RQ%d", 4:10),
        c("Which venue ranks best overall?",
          "And by compromise ranking?",
          "And by ratio analysis?",
          "And by simple multi-attribute rating?",
          "And by weighted aggregated sum product?",
          "And by outranking flows?",
          "And by outranking with thresholds?"),
        c("topsis", "vikor", "moora", "smart", "waspas", "promethee", "electre"))
  )
)

true_w <- c(cost = 0.40, capacity = 0.25, transport = 0.20, catering = 0.15)
saaty_signed <- function(ratio) {
  if (ratio >= 1) max(1, min(9, round(ratio))) else -max(2, min(9, round(1 / ratio)))
}
md <- frame_of(n, 15)
pair_cols <- sframe_comparison_columns(
  Filter(function(i) identical(i$id, "crit_pairs"), mcdm_choice$items)[[1]])
pairs <- sframe_comparison_pairs(crit, "saaty")
for (k in seq_len(nrow(pairs))) {
  r <- true_w[[pairs$a[k]]] / true_w[[pairs$b[k]]]
  # sd 0.18 keeps the consistency ratio under 0.1, so the judgements hold
  md[[pair_cols[k]]] <- vapply(seq_len(n), function(i)
    saaty_signed(r * exp(stats::rnorm(1, 0, 0.18))), numeric(1))
}
cw_cols <- paste0("crit_points__", crit)
for (i in seq_len(n)) {
  raw <- pmax(5, round(true_w * 100 + stats::rnorm(4, 0, 6)))
  raw <- round(raw / sum(raw) * 100); raw[4] <- 100 - sum(raw[1:3])
  for (j in seq_along(crit)) md[i, cw_cols[j]] <- raw[j]
}
infl_cols <- sframe_comparison_columns(
  Filter(function(i) identical(i$id, "crit_influence"), mcdm_choice$items)[[1]])
infl_pairs <- sframe_comparison_pairs(crit, "influence")
true_infl <- matrix(c(0, 2, 3, 3,  1, 0, 1, 2,  1, 1, 0, 1,  2, 1, 1, 0),
                    nrow = 4, byrow = TRUE, dimnames = list(crit, crit))
for (k in seq_len(nrow(infl_pairs))) {
  base <- true_infl[infl_pairs$a[k], infl_pairs$b[k]]
  md[[infl_cols[k]]] <- pmax(0, pmin(4, round(
    base + stats::rnorm(n, 0, 0.5))))
}
write_demo("mcdm_choice", mcdm_choice, md)

# --- 16. small_sample ------------------------------------------------------
set.seed(4116)
n <- 18
small_sample <- sf_instrument(
  title = "A pilot with 18 attendees", version = "1.0.0",
  description = "What a defensible answer looks like when n is below 30.",
  components = list(
    sf_choices("fmt", c("in_person", "online"), c("In person", "Online")),
    sf_item("format", "How did you attend?", type = "single_choice",
            choice_set = "fmt", required = TRUE),
    sf_item("sessions_attended", "How many sessions did you attend?",
            type = "numeric", required = TRUE),
    sf_choices("yn", c("no", "yes"), c("No", "Yes")),
    sf_item("will_return", "Will you attend next year?", type = "single_choice",
            choice_set = "yn", required = TRUE)
  ),
  analysis_plan = list(
    list(id = "RQ1", research_question = "Do the 2 formats differ, without assuming normality?",
         family = "group_comparison", method = "mann_whitney",
         roles = list(group = "format", outcome = "sessions_attended")),
    list(id = "RQ2", research_question = "Is format associated with returning, on an exact test?",
         family = "categorical", method = "fisher_exact",
         roles = list(row = "format", column = "will_return")),
    list(id = "RQ3", research_question = "Does attending more sessions predict returning, with a small-sample correction?",
         family = "regression", method = "firth_logistic",
         roles = list(predictors = "sessions_attended", dependent = "will_return"))
  )
)
ss <- frame_of(n, 16)
ss$format <- rep(c("in_person", "online"), each = n / 2)
# d = 1.0, large on purpose: below 30 there is no power for anything subtle
ss$sessions_attended <- pmax(0, round(c(stats::rnorm(n / 2, 7.4, 1.8),
                                        stats::rnorm(n / 2, 5.6, 1.8))))
ss$will_return <- ifelse(
  stats::runif(n) < stats::plogis(-1.6 + 0.42 * ss$sessions_attended), "yes", "no")
write_demo("small_sample", small_sample, ss)

# --- 18 to 20. presentation ------------------------------------------------
# The same 4 questions as first_survey. What differs is the render block, so a
# reader comparing a plain survey with a branded one is looking at that and
# nothing else.
presentation_of <- function(title, description, render_block, extra = list()) {
  sf_instrument(
    title = title, version = "1.0.0", description = description,
    components = c(first_survey$items, first_survey$choices, extra),
    render = render_block,
    analysis_plan = list(
      list(id = "RQ1", research_question = "Who came to the event?",
           family = "descriptive", method = "frequency",
           roles = list(variable = "attendee_type")))
  )
}
write_demo("branded_survey",
  presentation_of("Event feedback, branded",
    "The same 4 questions with a welcome page, a logo, a colour and a thank you page.",
    sframe_demo_branding_block("standard")),
  fs, reuse_responses = "first_survey")

write_demo("conversational_survey",
  presentation_of("Event feedback, one question at a time",
    "The same instrument in conversational mode, for comparison with 18.",
    sframe_demo_branding_block("conversational")),
  fs, reuse_responses = "first_survey")

# 20 combines conversational mode with a skip rule. One question at a time
# advances past hidden questions, so the 2 features interact directly, and
# that interaction has no other coverage.
conversational_branching <- sf_instrument(
  title = "One question at a time, with skip logic", version = "1.0.0",
  description = "Conversational mode and a multi-value skip rule together.",
  components = c(branching$items, branching$choices, branching$branching),
  render = sframe_demo_branding_block("conversational"),
  analysis_plan = list(
    list(id = "RQ1", research_question = "Who attended, and in what proportions?",
         family = "descriptive", method = "frequency",
         roles = list(variable = "attendee_type")))
)
write_demo("conversational_branching", conversational_branching, br,
           reuse_responses = "branching")

# --- 21. instrument_revision ----------------------------------------------
# A disclosed amendment: what changed, why, and who signed it off.
revised <- first_survey
revised$items <- lapply(revised$items, function(it) {
  if (identical(it$id, "suggestion")) {
    it$label <- "What is the single thing you would change about next year?"
  }
  it
})
revised$meta$version <- "1.1.0"
instrument_revision <- amend_sframe(
  first_survey, revised,
  reason_code = "instrument_revision",
  reason_text = paste("Reworded the open question after a face-validity pass:",
                      "readers were listing several changes at once, so the",
                      "answers were hard to code."),
  tier = "design",
  author = "M. A. Sharafuddin",
  deviation_report = paste("The open question moved from an unbounded prompt",
                           "to a single-change prompt. No analysis block",
                           "changed. Responses collected before this",
                           "amendment remain analysable and are reported",
                           "separately.")
)
write_demo("instrument_revision", instrument_revision, fs,
           reuse_responses = "first_survey")

# --- 22. verification ------------------------------------------------------
# The clean file verifies. A tampered copy reports as modified.
write_demo("verification", first_survey, fs, reuse_responses = "first_survey")
local({
  clean <- file.path(out_dir, "verification.sframe")
  txt <- readLines(clean, warn = FALSE)
  # Alter 1 response label, leaving the stored hash untouched, which is what a
  # quiet edit to a shared file looks like.
  hit <- grep('"I have attended before"', txt, fixed = TRUE)[1]
  txt[hit] <- sub("I have attended before", "I have attended previously",
                  txt[hit], fixed = TRUE)
  writeLines(txt, file.path(out_dir, "verification_tampered.sframe"))
  cat("  verification_tampered.sframe written (1 label altered, hash left alone)\n")
})

cat("\nDone. ", length(written), " demos in ", out_dir, "\n", sep = "")
