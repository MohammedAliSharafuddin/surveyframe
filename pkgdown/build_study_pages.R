# pkgdown/build_study_pages.R
# The 10 use-case study pages of surveyframe.org (Session W, plan: demos and
# website redesign). The pkgdown workflow runs it before building the site,
# so the generated files below are not tracked (.gitignore), only the pages
# and the screenshots. For each study it writes, into pkgdown/assets/studies/
# <demo>/ (copied to the site root, never into the tarball):
#   preview.html   the questionnaire as respondents see it, which collects nothing
#   plan.html      the pre-analysis plan, render_report(instrument) with no data
#   <demo>.sframe  the instrument, to download (never responses or results)
# and the page itself, vignettes/articles/studies/<slug>.Rmd, a web-only
# article (vignettes/articles is in .Rbuildignore). The 5 SurveyStudio
# screenshots come from data-raw/capture_study_screenshots.R. The site shows
# no result numbers.
#
# Run from the repository root:  Rscript pkgdown/build_study_pages.R

devtools::load_all(quiet = TRUE)

studies <- list(
  list(slug = "thesis-questionnaire-likert-scale", demo = "likert_scale", audience = "students",
       title = "Thesis questionnaire with a Likert scale",
       lead = "A short questionnaire that measures 1 idea with a 4-item Likert scale, including a reverse-worded item, and checks that the scale holds together before its score is used. surveyframe gives you the questionnaire, a pre-analysis plan to submit with your proposal, and an APA 7 report.",
       faq = c("Can I use this for my thesis?" = "Yes. Replace the items with your own, keep the plan, and submit the pre-analysis plan to your supervisor or ethics committee before you collect data.",
               "How do I check that my scale is reliable?" = "The plan declares Cronbach's alpha and McDonald's omega with a decision rule, .70 or above, and item diagnostics that flag an item that sits poorly with the rest.",
               "Does it work without coding?" = "Yes. Install surveyframe, then choose Try a demo from RStudio's Addins menu, and the whole study opens in SurveyStudio.")),
  list(slug = "pilot-study-small-sample", demo = "small_sample", audience = "students",
       title = "Pilot study with a small sample",
       lead = "A pilot with 18 participants that answers the main study's questions with methods suited to a small sample: a rank-based comparison, an exact test and a penalised logistic regression. surveyframe gives you the questionnaire, the pre-analysis plan and the report.",
       faq = c("Which tests work with fewer than 30 participants?" = "The plan uses the Mann-Whitney U test, Fisher's exact test and Firth logistic regression, which stay valid where large-sample tests do not.",
               "Should a pilot test hypotheses?" = "A pilot mainly checks the questionnaire and the procedure. Declaring the tests in advance still shows which comparisons the main study should power.",
               "Can I run the pilot without coding?" = "Yes. The whole study opens in SurveyStudio from RStudio's Addins menu.")),
  list(slug = "course-evaluation-survey", demo = "matrix_likert", audience = "teaching",
       title = "Course evaluation survey",
       lead = "A course evaluation in which students rate each part of a course on 1 grid, compared between students who took it in person and online. surveyframe gives you the questionnaire, the analysis plan and a report for the teaching team.",
       faq = c("Can I change the parts of the course?" = "Yes. Edit the rows of the grid in SurveyStudio's Design screen. Each row becomes its own column in the data.",
               "Can students answer anonymously?" = "Yes. The questionnaire asks for no name, and the respondent id is generated, not entered.",
               "How do I collect the answers?" = "Download the survey as 1 HTML file from the Collect screen and share it, with a free Google Sheet collecting the answers.")),
  list(slug = "pre-post-training-evaluation", demo = "paired", audience = "teaching",
       title = "Pre and post training evaluation",
       lead = "A training evaluation that measures confidence, and willingness to recommend, before and after a workshop in the same participants. surveyframe gives you the questionnaire, a plan with paired tests declared in advance, and the report.",
       faq = c("Why paired tests?" = "The same people answer before and after, so their answers are compared with themselves: the paired t-test, the Wilcoxon signed-rank test and McNemar's test.",
               "Can I add a third time point?" = "Yes. With 3 or more measurements the plan uses a repeated measures ANOVA or the Friedman test.",
               "Does it work without coding?" = "Yes. The whole study opens in SurveyStudio from RStudio's Addins menu.")),
  list(slug = "customer-satisfaction-return-intention", demo = "logistic", audience = "organisations",
       title = "Customer satisfaction and return intention",
       lead = "A customer study of whether using a service more predicts that customers return, how satisfied they are and which offer they prefer. surveyframe gives you the questionnaire, a plan with logistic regressions declared in advance, and the report.",
       faq = c("Which model predicts a yes or no answer?" = "A binary logistic regression, with the odds ratio of each predictor and its confidence interval.",
               "Can I predict a rating instead?" = "Yes. An ordinal logistic regression predicts an ordered rating, and a multinomial model a choice among several options.",
               "Can my team use it without R?" = "Yes. SurveyStudio runs the whole study in a browser window, started from RStudio's Addins menu.")),
  list(slug = "employee-engagement-survey", demo = "factor_structure", audience = "organisations",
       title = "Employee engagement survey",
       lead = "An engagement survey of 8 items written to measure 2 dimensions, how work is organised and the content of the work, with a check that employees' answers support 2 scores. surveyframe gives you the questionnaire, the analysis plan and the report.",
       faq = c("How do I know the survey measures 2 things?" = "The plan checks that the data suit factor analysis, then runs an exploratory factor analysis that shows which items load on which factor.",
               "Can I report 2 scores?" = "Yes, once the factor analysis supports them. Each scale's score and reliability are reported.",
               "Can answers stay anonymous?" = "Yes. The questionnaire asks for no name, and results are reported for the group.")),
  list(slug = "choosing-between-options", demo = "mcdm_choice", audience = "organisations",
       title = "Choosing between options: a supplier or a venue",
       lead = "A decision study that weights several criteria from a committee's judgements and ranks the options by 10 methods, to show whether they agree. surveyframe gives you the questionnaire, the analysis plan and the report.",
       faq = c("Which methods rank the options?" = "AHP and ANP weight the criteria, DEMATEL shows which drive the others, and TOPSIS, VIKOR, MOORA, SMART, WASPAS, PROMETHEE and ELECTRE rank the options.",
               "Are the judgements consistent?" = "The plan accepts pairwise judgements when the consistency ratio is below .10.",
               "Can a committee answer it?" = "Yes. Each member answers the same questionnaire, and the judgements are combined.")),
  list(slug = "open-ended-feedback", demo = "open_text", audience = "organisations",
       title = "Open-ended feedback",
       lead = "A feedback survey of what worked and what to change, analysed as text: frequent words and phrases, words in context, sentiment and topics. surveyframe gives you the questionnaire, the analysis plan and the report.",
       faq = c("What can surveyframe do with open answers?" = "Word and phrase frequencies, keywords in context, co-occurrence, sentiment, a document-feature matrix and topic models.",
               "Can I compare groups?" = "Yes. The plan can compare what in-person and online respondents write.",
               "Does it replace reading the answers?" = "No. It shows where to look, and the report keeps the quotes that represent each topic.")),
  list(slug = "preregistered-survey-study", demo = "verification", audience = "research-labs",
       title = "Pre-registered survey study, sealed and amended",
       lead = "A survey study whose instrument and analysis plan are sealed with a hash before data collection, with any later change recorded as a disclosed amendment. surveyframe gives you the pre-analysis plan to register on OSF or Zenodo, and a report that names the instrument it analysed.",
       faq = c("How do I preregister the plan on OSF?" = "Write the pre-analysis plan with render_report() and no data, or from SurveyStudio, and upload it with the .sframe file. The plan names the file's hash.",
               "How does a reader check the questionnaire?" = "Anyone can open the .sframe file at surveyframe.org/verify. A file changed after sealing fails the check.",
               "What if I must change the questionnaire?" = "Record the change as an amendment, with its reason and a deviation report. The amendment log stays in the file.")),
  list(slug = "measurement-structural-model", demo = "sem_pls", audience = "research-labs",
       title = "Measurement and structural model study",
       lead = "A study of whether content quality builds satisfaction, and satisfaction the intention to return, with the measurement model and the structural paths declared in advance. surveyframe gives you the questionnaire, the model syntax for lavaan and seminr, and the report.",
       faq = c("Which software estimates the model?" = "surveyframe writes the syntax for lavaan (covariance-based SEM and CFA) and seminr (PLS-SEM), and runs the mediation and moderation.",
               "Can I declare the model before collecting data?" = "Yes. Constructs, paths and the indirect effect are declared in the instrument and sealed with it.",
               "Does it work without coding?" = "Yes. The model layer opens in SurveyStudio from RStudio's Addins menu."))
)

hubs <- c(students = "Students and thesis supervisors", teaching = "University and teaching evaluation",
          organisations = "Organisations: customer and employee research",
          "research-labs" = "Research labs and pre-analysis plans")
stage_alt <- c(design = "Design screen with the questionnaire", collect = "Collect screen",
               check = "Quality screen", analyse = "Analyse screen with the declared plan",
               report = "Report screen")

assets <- file.path("pkgdown", "assets", "studies")
pages <- file.path("vignettes", "articles", "studies")
dir.create(pages, recursive = TRUE, showWarnings = FALSE)
q <- function(x) gsub("\"", "\\\\\"", x)

for (st in studies) {
  cat(st$demo, "\n")
  d <- sframe_demo(st$demo, preview = FALSE)
  out <- file.path(assets, st$demo)
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  suppressMessages(export_survey(d$instrument, file.path(out, "preview.html"),
                                 preview = TRUE, open = FALSE, overwrite = TRUE))
  suppressMessages(render_report(d$instrument, output_file = file.path(out, "plan.html"),
                                 format = "html", open = FALSE))
  # The results record and manifest render_report() writes beside a report:
  # the site offers no results files.
  unlink(file.path(out, c("plan_results.json", "plan_manifest.json")))
  file.copy(d$instrument_path, file.path(out, paste0(st$demo, ".sframe")), overwrite = TRUE)
  rel <- paste0("../../studies/", st$demo, "/")
  shots <- vapply(names(stage_alt), function(s) {
    sprintf("![%s.](%s%s.png){width=100%%}", stage_alt[[s]], rel, s)
  }, character(1))
  siblings <- Filter(function(o) identical(o$audience, st$audience) && o$slug != st$slug, studies)
  related <- vapply(utils::head(siblings, 2), function(o) sprintf("- [%s](%s.html)", o$title, o$slug), character(1))
  methods <- unique(vapply(d$instrument$analysis_plan, function(b) {
    sframe_method_words(sframe_analysis_method(b))
  }, character(1)))
  faq <- unlist(lapply(names(st$faq), function(h) c(paste("###", h), "", st$faq[[h]], "")))
  ld <- sprintf(paste0('<script type="application/ld+json">{"@context":"https://schema.org","@type":"TechArticle",',
                       '"headline":"%s","description":"%s","about":{"@type":"SoftwareSourceCode","name":"surveyframe",',
                       '"url":"https://surveyframe.org"},"url":"https://surveyframe.org/articles/studies/%s.html"}</script>'),
                q(st$title), q(st$lead), st$slug)
  rmd <- c(
    "---",
    sprintf("title: \"%s\"", q(st$title)),
    sprintf("description: \"%s\"", q(st$lead)),
    "---",
    "",
    "```{=html}", ld, "```",
    "",
    st$lead,
    "",
    "## Preview the questionnaire",
    "",
    sprintf("This is the questionnaire as respondents see it. It is a preview, so answers go nowhere. [Open it in a new tab](%spreview.html).", rel),
    "",
    "```{=html}",
    sprintf("<iframe src=\"%spreview.html\" title=\"Preview of the %s questionnaire\" style=\"width:100%%;height:560px;border:1px solid #d9e2ec;border-radius:6px\"></iframe>", rel, q(st$title)),
    "```",
    "",
    "## The analysis plan, ready to preregister",
    "",
    sprintf("Before any data is collected, surveyframe writes the pre-analysis plan: the study, the questionnaire, each research question with its hypotheses, method and decision rule, and what a preregistration still asks for. [Read the plan](%splan.html), or [download the instrument (.sframe)](%s%s.sframe) and open it in SurveyStudio.", rel, rel, st$demo),
    "",
    sprintf("Methods it declares: %s.", paste(methods, collapse = ", ")),
    "",
    "## What you get",
    "",
    "The study in SurveyStudio, stage by stage: design, collect, check, analyse and report.",
    "",
    shots,
    "",
    "## Start in 2 steps (no coding)",
    "",
    "1. Install surveyframe in R: `install.packages(\"surveyframe\")`",
    sprintf("2. In RStudio, open the Addins menu, choose **surveyframe: Try a demo**, and pick `%s`. The study opens in SurveyStudio.", st$demo),
    "",
    "## Questions",
    "",
    faq,
    "## For R users",
    "",
    "```{=html}", "<details><summary>Open this study in R</summary>", "```",
    "",
    "```r",
    sprintf("d <- sframe_demo(\"%s\")", st$demo),
    "render_report(d$instrument)                 # the pre-analysis plan",
    "results <- run_analysis_plan(d$responses, d$instrument)",
    "```",
    "",
    "```{=html}", "</details>", "```",
    "",
    "## Related",
    "",
    sprintf("- [All %s studies](../studies.html#%s)", tolower(hubs[[st$audience]]), st$audience),
    related,
    "- [Method guides](../guides.html)",
    ""
  )
  writeLines(rmd, file.path(pages, paste0(st$slug, ".Rmd")))
}

# The index of all studies, by audience.
idx <- c("---", "title: \"Survey studies to start from\"",
         "description: \"10 survey studies, each with its questionnaire, a pre-analysis plan and the report, for students, teaching evaluation, organisations and research labs.\"",
         "---", "",
         "Each study is a complete survey project you can open in SurveyStudio with no code: the questionnaire, a pre-analysis plan ready to preregister, and the report.", "")
for (h in names(hubs)) {
  idx <- c(idx, sprintf("## %s {#%s}", hubs[[h]], h), "")
  for (st in Filter(function(o) identical(o$audience, h), studies)) {
    idx <- c(idx, sprintf("- [%s](studies/%s.html)", st$title, st$slug))
  }
  idx <- c(idx, "")
}
writeLines(idx, file.path("vignettes", "articles", "studies.Rmd"))
cat("Wrote", length(studies), "study pages and the index.\n")
