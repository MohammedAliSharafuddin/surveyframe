# pkgdown/build_guides.R
# The how-to guides of surveyframe.org (Session W, plan: method guides): 1
# web-only page per teaching demo, vignettes/articles/guides/<slug>.Rmd, with
# a task-shaped title, the reader's outcome, the example study in its own
# sentence, the SurveyStudio steps for that task, the R code for that task
# (both from pkgdown/guide_specs.R, Codex website review WR609 to WR635), and,
# for an analysis, a result shell that names what each research question
# reports without a number (the site shows no simulated numbers). Plus the
# index, vignettes/articles/guides.Rmd, grouped by the reader's task. The
# demos' own names and functions are unchanged.
# Run from the repository root:  Rscript pkgdown/build_guides.R

devtools::load_all(quiet = TRUE)
source(file.path("pkgdown", "guide_specs.R"))

guides <- c(
  first_survey = "How to run a complete survey, from questionnaire to report, in R",
  likert_scale = "How to check whether a Likert scale holds together",
  matrix_likert = "How to analyse a grid of rating questions",
  two_group = "How to compare 2 groups on a survey outcome",
  paired = "How to compare the same people before and after",
  multi_group = "How to compare 3 or more groups, with a covariate",
  repeated = "How to compare 3 or more measurements of the same people",
  categorical = "How to test whether 2 categorical answers are associated",
  correlation_regression = "How to find what goes with an outcome, and how much it explains",
  logistic = "How to predict a yes or no, an ordered rating or a choice",
  factor_structure = "How to check whether your items measure the factors you assumed",
  sem_pls = "How to test a measurement and structural model",
  branching = "How to ask questions only of those they apply to",
  open_text = "How to analyse open-ended answers",
  mcdm_choice = "How to choose between options on multiple criteria",
  small_sample = "How to analyse a survey with fewer than 30 respondents",
  multi_response = "How to analyse choose-any and ranking questions",
  weighted_survey = "How to weight a survey sample to its population",
  mediation_moderation = "How to test mediation and moderation",
  branded_survey = "How to add a welcome page, a logo and a colour to a survey",
  conversational_survey = "How to show a survey 1 question at a time",
  conversational_branching = "How to combine 1 question at a time with skip logic",
  instrument_revision = "How to change a questionnaire mid-study, on the record",
  verification = "How to prove a questionnaire file is the one you planned",
  citing_sources = "How to cite the sources of a scale and a method"
)
# The index groups the guides by the reader's task (WR568).
groups <- list(
  "Run a complete study" = "first_survey",
  "Design the questionnaire" = c("branching", "branded_survey", "conversational_survey", "conversational_branching"),
  "Analyse and report" = c("likert_scale", "matrix_likert", "two_group", "paired", "multi_group", "repeated",
                           "categorical", "correlation_regression", "logistic", "factor_structure", "sem_pls",
                           "open_text", "mcdm_choice", "small_sample", "multi_response", "weighted_survey",
                           "mediation_moderation"),
  "Record your research" = c("instrument_revision", "verification", "citing_sources")
)
stopifnot(setequal(unlist(groups), names(guides)), setequal(names(guide_specs), names(guides)))

# Methods that return model syntax to fit elsewhere, not estimates (R/analysis_plan.R).
syntax_methods <- c("cfa_lavaan_syntax", "sem_lavaan_syntax", "seminr_syntax", "pls_sem")
idx_df <- sframe_list_demos()
idx_df <- idx_df[idx_df$focus != "reference", ]
slug <- function(t) sub("-$", "", gsub("-+", "-", gsub("[^a-z0-9]+", "-", tolower(sub("^How to ", "", t)))))
pages <- file.path("vignettes", "articles", "guides")
dir.create(pages, recursive = TRUE, showWarnings = FALSE)
q <- function(x) gsub("\"", "\\\\\"", x)

for (k in seq_len(nrow(idx_df))) {
  nm <- idx_df$name[k]
  title <- guides[[nm]]
  sp <- guide_specs[[nm]]
  d <- sframe_demo(nm, preview = FALSE)
  ins <- d$instrument
  plan <- ins$analysis_plan %||% list()
  example <- sprintf("The example in this guide is *%s*%s %s", ins$meta$title,
                     if (grepl("[?!.]$", ins$meta$title)) "" else ".", ins$meta$description)
  # The result shell: each research question and what it reports, no values.
  shell <- NULL
  if (identical(idx_df$focus[k], "analysis") && file.exists(d$results_path %||% "")) {
    res <- utils::read.csv(d$results_path, stringsAsFactors = FALSE)
    if (nrow(res)) {
      res <- res[!duplicated(res[, c("block", "method")]), c("block", "method")]
      shell <- c("| Research question | Method | What the report gives |", "|---|---|---|",
                 vapply(seq_len(nrow(res)), function(i) {
                   b <- Filter(function(x) identical(x$id, res$block[i]), plan)
                   rq <- if (length(b)) b[[1]]$research_question else res$block[i]
                   gives <- if (res$method[i] %in% syntax_methods) "The model syntax, ready for you to fit in lavaan or seminr" else
                     "The APA 7 sentence and a table, with a chart where the method has one"
                   sprintf("| %s | %s | %s |", gsub("\\|", "/", rq), sframe_method_words(res$method[i]), gives)
                 }, character(1)))
    }
  }
  shot <- file.path("pkgdown", "assets", "templates", nm, "design.png")
  rmd <- c(
    "---", sprintf("title: \"%s\"", q(title)), sprintf("description: \"%s\"", q(sp$outcome)), "---", "",
    sp$outcome, "", example, "",
    "## In SurveyStudio", "",
    paste0(seq_along(sp$studio), ". ", sp$studio), "",
    if (file.exists(shot)) c(sprintf("![The Design screen with the %s study open.](../../templates/%s/design.png){width=100%%}", ins$meta$title, nm), ""),
    "## In R", "",
    "```r", sp$r, "```", "",
    if (length(shell)) c("## The research questions and what the report gives", "", shell, "",
                         "Run the example in SurveyStudio or R to see the results, each marked as demonstration data.", ""),
    "## Related", "",
    "- [Questionnaire templates](../templates.html)",
    "- [All how-to guides](../guides.html)", ""
  )
  writeLines(rmd, file.path(pages, paste0(slug(title), ".Rmd")))
}

idx <- c("---", "title: \"How-to guides\"",
         "description: \"Follow a complete task, from setting up a questionnaire to analysing responses and documenting your study, in SurveyStudio and in R.\"",
         "---", "", "Follow a complete task, from setting up a questionnaire to analysing responses and documenting your study. Each guide gives the SurveyStudio steps first and the R code after.", "")
for (g in names(groups)) {
  idx <- c(idx, paste("##", g), "")
  for (nm in groups[[g]]) idx <- c(idx, sprintf("- [%s](guides/%s.html)", guides[[nm]], slug(guides[[nm]])))
  idx <- c(idx, "")
}
writeLines(idx, file.path("vignettes", "articles", "guides.Rmd"))
cat("Wrote", nrow(idx_df), "guides and the index.\n")
