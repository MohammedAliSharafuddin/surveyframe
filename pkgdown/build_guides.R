# pkgdown/build_guides.R
# The method guides of surveyframe.org (Session W, plan: method guides): 1
# web-only page per teaching demo, vignettes/articles/guides/<slug>.Rmd, with
# a question-shaped title, a direct-answer lead, the SurveyStudio route, the
# R code, and a result shell that names what each block reports without a
# number (the site shows no simulated numbers). Plus the index,
# vignettes/articles/guides.Rmd. The demos' own names and functions are
# unchanged. Run from the repository root:  Rscript pkgdown/build_guides.R

devtools::load_all(quiet = TRUE)

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
  mcdm_choice = "How to choose between options on several criteria",
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
groups <- c(analysis = "Analyse", presentation = "Present the survey", provenance = "Keep the record")

idx_df <- sframe_list_demos()
idx_df <- idx_df[idx_df$focus != "reference", ]
slug <- function(t) sub("-$", "", gsub("-+", "-", gsub("[^a-z0-9]+", "-", tolower(sub("^How to ", "", t)))))
pages <- file.path("vignettes", "articles", "guides")
dir.create(pages, recursive = TRUE, showWarnings = FALSE)
q <- function(x) gsub("\"", "\\\\\"", x)

for (k in seq_len(nrow(idx_df))) {
  nm <- idx_df$name[k]
  title <- guides[[nm]]
  d <- sframe_demo(nm, preview = FALSE)
  ins <- d$instrument
  plan <- ins$analysis_plan %||% list()
  methods <- unique(vapply(plan, function(b) sframe_method_words(sframe_analysis_method(b)), character(1)))
  lead <- paste0(sub("\\.$", "", ins$meta$description), ". ",
                 if (length(methods)) paste0("surveyframe declares the analysis in advance (",
                                             paste(methods, collapse = ", "),
                                             ") and reports it in APA 7.") else
                   "surveyframe writes the questionnaire and its record.")
  # The result shell: each block and what it reports, no values.
  shell <- NULL
  if (file.exists(d$results_path %||% "")) {
    res <- utils::read.csv(d$results_path, stringsAsFactors = FALSE)
    if (nrow(res)) {
      res <- res[!duplicated(res[, c("block", "method")]), c("block", "method")]
      shell <- c("| Research question | Method | What the report gives |", "|---|---|---|",
                 vapply(seq_len(nrow(res)), function(i) {
                   b <- Filter(function(x) identical(x$id, res$block[i]), plan)
                   rq <- if (length(b)) b[[1]]$research_question else res$block[i]
                   sprintf("| %s | %s | The APA 7 sentence, its table and chart |",
                           gsub("\\|", "/", rq), sframe_method_words(res$method[i]))
                 }, character(1)))
    }
  }
  shot <- file.path("pkgdown", "assets", "studies", nm, "design.png")
  rmd <- c(
    "---", sprintf("title: \"%s\"", q(title)), sprintf("description: \"%s\"", q(lead)), "---", "",
    lead, "",
    "## In SurveyStudio", "",
    sprintf("In RStudio, open the Addins menu, choose **surveyframe: Try a demo** and pick `%s`. The study opens on the Design screen. Plan shows each research question with its method and decision rule, Analyse runs them as declared, and Report writes the APA 7 report.", nm), "",
    if (file.exists(shot)) c(sprintf("![The Design screen with the %s study.](../../studies/%s/design.png){width=100%%}", nm, nm), "") ,
    "## In R", "",
    "```r",
    sprintf("d <- sframe_demo(\"%s\")", nm),
    if (length(plan)) "results <- run_analysis_plan(d$responses, d$instrument)",
    if (length(plan)) "render_report(d$instrument, d$responses)",
    "```", "",
    if (length(shell)) c("## What the report gives", "", shell, ""),
    "The demo's data is simulated, so the site shows no numbers. Run it in SurveyStudio or R to see the results, each marked as demonstration data.", "",
    "## Related", "",
    "- [Survey studies to start from](../studies.html)",
    "- [All method guides](../guides.html)", ""
  )
  writeLines(rmd, file.path(pages, paste0(slug(title), ".Rmd")))
}

idx <- c("---", "title: \"Method guides\"",
         "description: \"How to answer a research question with a survey: compare groups, check a scale, predict an outcome, analyse open answers and more, each in SurveyStudio and in R.\"",
         "---", "", "Each guide answers 1 research question, with the SurveyStudio route first and the R code after.", "")
for (g in names(groups)) {
  idx <- c(idx, paste("##", groups[[g]]), "")
  for (nm in idx_df$name[idx_df$focus == g]) idx <- c(idx, sprintf("- [%s](guides/%s.html)", guides[[nm]], slug(guides[[nm]])))
  idx <- c(idx, "")
}
writeLines(idx, file.path("vignettes", "articles", "guides.Rmd"))
cat("Wrote", nrow(idx_df), "guides and the index.\n")
