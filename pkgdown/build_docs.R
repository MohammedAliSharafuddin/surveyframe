# pkgdown/build_docs.R
# The Docs section of surveyframe.org (Session W, owner 2026-11-14, Quill
# Forms docs as the model): how to set up each of the 13 answerable question
# types. For each type it captures 2 screenshots, the builder's editor with the
# question selected and its settings outlined, and the question as the
# respondent sees it, into pkgdown/assets/docs/question-types/ (site only),
# and writes the page, vignettes/articles/docs/question-types/<slug>.Rmd, and
# the landing page, vignettes/articles/docs.Rmd. Rebuilt at every release,
# never viewed shot by shot.
#
# Run from the repository root:  Rscript pkgdown/build_docs.R

pkg_root <- normalizePath(".")
devtools::load_all(pkg_root, quiet = TRUE)
stopifnot(requireNamespace("chromote", quietly = TRUE))

ref_kp <- "Krosnick, J. A., & Presser, S. (2010). Question and questionnaire design. In P. V. Marsden & J. D. Wright (Eds.), *Handbook of survey research* (2nd ed., pp. 263-313). Emerald."
ref_dsc <- "Dillman, D. A., Smyth, J. D., & Christian, L. M. (2014). *Internet, phone, mail, and mixed-mode surveys: The tailored design method* (4th ed.). Wiley."
ref_saaty <- "Saaty, T. L. (1980). *The analytic hierarchy process*. McGraw-Hill."

types <- list(
  likert = list(id = "digital_ease", slug = "likert", h1 = "Add a Likert question to a scale",
    how = "Add a question, choose Likert, and pick the agreement scale it answers on.",
    settings = c("Answer set" = "The labelled scale, such as Strongly disagree to Strongly agree. Items of 1 scale share it.",
                 "Scale" = "The scale the item scores into, so its score and reliability are computed together.",
                 "Reverse-scored" = "For an item worded against the others, so a high answer means the same on every item."),
    practice = "Label every point of the scale, and keep each item to 1 idea, so every respondent answers the same question.",
    concept = c(
      "A **question** asks 1 thing and is stored as 1 column. Its **response options** are the labelled choices it offers, such as Strongly disagree to Strongly agree, and related questions share 1 set of options. A **scored scale** combines a group of related questions into 1 score, and its reliability is checked as a whole.",
      "",
      "To build a scored scale:",
      "",
      "1. Add 1 Likert question for each item of the scale, each with 1 idea.",
      "2. Give every item the same answer set.",
      "3. In Scale, assign each item to the scale it scores into.",
      "4. Tick Reverse-scored for each item worded against the others.",
      "5. In the analysis plan, declare the scale's reliability and the analyses that use its score."),
    ref = ref_kp),
  single_choice = list(id = "visit_type", slug = "single-choice", h1 = "Add a single-choice question",
    how = "Add a question, choose Single choice, and give the options the respondent picks 1 from.",
    settings = c("Answer set" = "The options, each with a stored code and the label respondents see.",
                 "Other, please specify" = "Adds a text box for an answer the options miss, kept beside the code.",
                 "Ordered" = "Marks the options as ordered, so the item is analysed as ordinal."),
    practice = "Make the options exhaustive and mutually exclusive, or add Other: a respondent with no fitting option guesses.",
    ref = ref_kp),
  multiple_choice = list(id = "information_channels", slug = "multiple-choice", h1 = "Add a choose-any question",
    how = "Add a question, choose Multiple choice, and give the options the respondent may tick.",
    settings = c("Answer set" = "The options. Each becomes its own column in the data, ticked or not.",
                 "Required" = "Asks for at least 1 tick."),
    practice = "Prefer asking yes or no for each option when every option matters: a choose-any list makes an unticked box ambiguous.",
    ref = ref_dsc),
  numeric = list(id = "nights_stayed", slug = "numeric", h1 = "Add a number question",
    how = "Add a question, choose Numeric, and set the range the answer may take.",
    settings = c("Minimum and maximum" = "Refuses an answer outside the range at entry, so a typing slip does not reach the data."),
    practice = "Name the unit in the question, such as nights or years, so every respondent answers on the same scale.",
    ref = ref_dsc),
  text = list(id = "respondent_name", slug = "short-text", h1 = "Add a short text question",
    how = "Add a question and choose Short text for a word or a line.",
    settings = c("Required" = "Asks for an answer before the respondent goes on. Leave open questions optional where you can."),
    practice = "Use a short text where the possible answers are too varied to list. Where the answers can be listed, a choice question is quicker to answer and to analyse.",
    ref = ref_dsc),
  textarea = list(id = "open_comment", slug = "long-text", h1 = "Add an open-ended question",
    how = "Add a question and choose Long text for a paragraph.",
    settings = c("Required" = "Usually off: an open comment is better skipped than filled to move on."),
    practice = "Ask 1 specific thing, such as what to change, rather than for any comments: specific prompts give answers you can code.",
    ref = ref_kp),
  date = list(id = "booking_date", slug = "date", h1 = "Add a date question",
    how = "Add a question and choose Date. The respondent picks it from a calendar.",
    settings = c("Required" = "Asks for a date before the respondent goes on."),
    practice = "Ask for a date only when the day matters. For how long ago, a numeric question is quicker to answer.",
    ref = ref_dsc),
  matrix = list(id = "service_matrix", slug = "grid", h1 = "Add a grid of rating questions",
    how = "Add a question, choose Matrix, list the rows, and pick the scale every row is rated on.",
    settings = c("Rows" = "The things rated. Each row becomes its own column, named after it.",
                 "Answer set" = "The scale every row shares."),
    practice = "Keep a grid short: long grids invite the same answer down every row, which the quality checks flag as straight-lining.",
    ref = ref_dsc),
  slider = list(id = "value_slider", slug = "slider", h1 = "Add a slider rating",
    how = "Add a question, choose Slider, and set its range and step.",
    settings = c("Minimum, maximum and step" = "The range and how finely the respondent can place the handle."),
    practice = "Label both ends with what they mean. A slider that starts at a value records it as an answer, so check what was moved.",
    ref = ref_dsc),
  ranking = list(id = "feature_ranking", slug = "ranking", h1 = "Add a ranking question",
    how = "Add a question, choose Ranking, and give the options to put in order.",
    settings = c("Answer set" = "The options. The answer is their order, first to last."),
    practice = "Rank 5 options or fewer: beyond that, the middle of a ranking says little.",
    ref = ref_kp),
  rating = list(id = "overall_rating", slug = "star-rating", h1 = "Add a star rating",
    how = "Add a question and choose Rating for a row of stars.",
    settings = c("Number of stars" = "The top of the scale. The answer is the number of stars given."),
    practice = "Use stars for an overall judgement. For a scale of several items, use Likert questions that share an answer set.",
    ref = ref_dsc),
  pairwise_comparison = list(id = "feature_pairs", slug = "pairwise-comparison", h1 = "Add pairwise comparisons",
    how = "Choose the task first. To find which criteria matter most (AHP, ANP), use Saaty's importance scale. To find how criteria influence each other (DEMATEL), use the influence scale. Then add a question, choose Pairwise comparison and list the criteria.",
    settings = c("Criteria" = "The things compared. On Saaty's scale each pair is asked once, since judging A against B also answers B against A. On the influence scale each pair is asked in both directions, since the influence of A on B can differ from that of B on A.",
                 "Scale" = "Saaty's 1 to 9 for which matters more and by how much (AHP, ANP), or 0 to 4 for how much 1 influences another (DEMATEL)."),
    practice = "Keep to 7 criteria or fewer: the pairs grow fast, and the consistency ratio shows when judgements contradict each other.",
    ref = ref_saaty),
  criteria_weight = list(id = "feature_points", slug = "criteria-weights", h1 = "Add a criteria weighting question",
    how = "Add a question, choose Criteria weight, and list the criteria to divide 100 points across.",
    settings = c("Criteria" = "The things weighted. The points must add up to 100."),
    practice = "Use points when respondents can judge all criteria at once. For many criteria, pairwise comparisons are easier to answer.",
    ref = ref_saaty)
)

shot_dir <- file.path("pkgdown", "assets", "docs", "question-types")
page_dir <- file.path("vignettes", "articles", "docs", "question-types")
dir.create(shot_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(page_dir, recursive = TRUE, showWarnings = FALSE)
shrink <- function(path, width = 1000) {
  system2("convert", c(shQuote(path), "-resize", paste0(width, "x>"), "-colors", "256", "-strip", shQuote(path)),
          stdout = FALSE, stderr = FALSE)
}
js <- function(b, code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
wait_for <- function(b, cond, secs = 30) {
  for (i in seq_len(secs * 5)) {
    if (isTRUE(tryCatch(js(b, cond), error = function(e) FALSE))) return(TRUE)
    Sys.sleep(0.2)
  }
  stop("Timed out waiting for: ", cond)
}

demo <- sframe_demo("input_types", preview = FALSE)$instrument
builder <- sframe_builder_instrument_html(demo)
b <- chromote::ChromoteSession$new(width = 1280L, height = 800L)
b$Page$navigate(paste0("file://", normalizePath(builder)))
wait_for(b, "typeof openInsp === 'function' && S.items.length > 0")
# Toasts, such as the integrity message on opening, stay out of the shots.
js(b, "var st=document.createElement('style'); st.textContent='#toastR{display:none !important}'; document.head.appendChild(st); true")
for (tp in names(types)) {
  t <- types[[tp]]
  cat(tp, "\n")
  # The editor, with the question's settings outlined as Quill's docs do.
  js(b, sprintf("openInsp('%s'); var i=document.getElementById('inspector'); if(i){i.style.outline='3px solid #d6336c'; i.style.outlineOffset='-3px';} true", t$id))
  Sys.sleep(0.8)
  out <- file.path(shot_dir, paste0(t$slug, "-editor.png"))
  b$screenshot(filename = out, cliprect = c(0, 0, 1280, 800))
  shrink(out)
  # The question as the respondent sees it, from a 1-question copy, so no
  # welcome page stands in front of it.
  item <- Filter(function(it) identical(it$id, t$id), demo$items)[[1]]
  cs <- Filter(function(c) identical(c$id, item$choice_set %||% ""), demo$choices)
  one <- sframe_instrument(t$h1, components = c(list(item), cs))
  html <- tempfile(fileext = ".html")
  suppressMessages(export_survey(one, html, preview = TRUE, open = FALSE, overwrite = TRUE))
  p <- chromote::ChromoteSession$new(width = 900L, height = 900L)
  p$Page$navigate(paste0("file://", normalizePath(html)))
  wait_for(p, sprintf("!!document.getElementById('item_%s')", t$id))
  Sys.sleep(0.5)
  r <- js(p, sprintf("(function(){var e=document.getElementById('item_%s');var r=e.getBoundingClientRect();return [Math.max(0,r.left-12),Math.max(0,r.top-12),r.width+24,r.height+24];})()", t$id))
  out <- file.path(shot_dir, paste0(t$slug, "-preview.png"))
  p$screenshot(filename = out, cliprect = unlist(r))
  shrink(out, 900)
  p$close()
}
b$close()

for (tp in names(types)) {
  t <- types[[tp]]
  settings <- unlist(lapply(names(t$settings), function(s) c(sprintf("- **%s.** %s", s, t$settings[[s]]))))
  rmd <- c(
    "---", sprintf("title: \"%s\"", t$h1),
    sprintf("description: \"%s\"", t$how), "---", "",
    "[Documentation](../../docs.html) / [Question types](../../docs.html#question-types)", "",
    t$how, "",
    sprintf("![The questionnaire editor with the %s selected and its settings panel outlined.](../../../docs/question-types/%s-editor.png){width=100%%}", sub(" to a scale$", "", sub("^Add (a |an )?", "", t$h1)), t$slug), "",
    if (!is.null(t$concept)) c("## Questions, response options and scales", "", t$concept, "") else character(0),
    "## What the respondent sees", "",
    sprintf("![The %s as the respondent sees it.](../../../docs/question-types/%s-preview.png){width=90%%}", sub(" to a scale$", "", sub("^Add (a |an )?", "", t$h1)), t$slug), "",
    "## Settings", "", settings, "",
    "## Best practices for research", "", t$practice, "",
    paste0("Reference: ", t$ref), "",
    "## Related", "",
    "- [All question types](../../learn/question-types.html)",
    "- [The analysis plan](../../learn/analysis-plan.html)", ""
  )
  writeLines(rmd, file.path(page_dir, paste0(t$slug, ".Rmd")))
}

landing <- c("---", "title: \"Documentation: how to set up surveyframe\"",
  "description: \"How to set up each question type and analysis in surveyframe, step by step, with annotated SurveyStudio screenshots.\"",
  "---", "",
  "Set up each question type and each analysis method, step by step, with annotated SurveyStudio screenshots. To follow a complete task from start to finish, use a [how-to guide](guides.html).", "",
  sprintf("## Question types (%d pages) {#question-types}", length(types)), "",
  vapply(types, function(t) sprintf("- [%s](docs/question-types/%s.html)", t$h1, t$slug), character(1)), "")
writeLines(landing, file.path("vignettes", "articles", "docs.Rmd"))
cat("Wrote", length(types), "question-type pages and the landing page.\n")
