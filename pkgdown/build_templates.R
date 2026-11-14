# pkgdown/build_templates.R
# The 10 questionnaire templates of surveyframe.org (renamed from study pages,
# owner 2026-11-14) (Session W, plan: demos and
# website redesign). The pkgdown workflow runs it before building the site,
# so the generated files below are not tracked (.gitignore), only the pages
# and the screenshots. For each study it writes, into pkgdown/assets/templates/
# <demo>/ (copied to the site root, never into the tarball):
#   preview.html   the questionnaire as respondents see it, which collects nothing
#   plan.html      the pre-analysis plan, render_report(instrument) with no data
#   <demo>.sframe  the instrument, to download (never responses or results)
# and the page itself, vignettes/articles/templates/<slug>.Rmd, a web-only
# article (vignettes/articles is in .Rbuildignore). The 5 SurveyStudio
# screenshots come from data-raw/capture_study_screenshots.R. The site shows
# no result numbers.
#
# Run from the repository root:  Rscript pkgdown/build_study_pages.R

devtools::load_all(quiet = TRUE)

studies <- list(
  list(slug = "likert-scale-questionnaire", demo = "likert_scale", audience = "psychology",
       title = "Likert scale questionnaire",
       lead = "A short questionnaire that measures 1 idea with a 4-item Likert scale, including a reverse-worded item, and checks that the scale holds together before its score is used. surveyframe gives you the questionnaire, a pre-analysis plan to submit with your proposal, and an APA 7 report.",
       faq = c("Can I use this for my thesis?" = "Yes. Replace the items with your own, keep the plan, and submit the pre-analysis plan to your supervisor or ethics committee before you collect data.",
               "How do I check that my scale is reliable?" = "The plan declares Cronbach's alpha and McDonald's omega with a decision rule, .70 or above, and item diagnostics that flag an item that sits poorly with the rest.",
               "Can I run the whole study in SurveyStudio?" = "Yes. Install surveyframe, then choose Try a demo from RStudio's Addins menu, and the whole study opens in SurveyStudio.")),
  list(slug = "pilot-survey-small-sample", demo = "small_sample", audience = "research-methods",
       title = "Pilot survey with a small sample",
       lead = "A pilot with 18 participants that answers the main study's questions with methods suited to a small sample: a rank-based comparison, an exact test and a penalised logistic regression. surveyframe gives you the questionnaire, the pre-analysis plan and the report.",
       faq = c("Which tests suit fewer than 30 participants?" = "The example plan includes methods often considered for small samples: the Mann-Whitney U test, Fisher's exact test and Firth logistic regression. Choose methods that fit your design, measurements and assumptions, and the guide to small samples explains the example's choices.",
               "Should a pilot test hypotheses?" = "A pilot mainly checks the questionnaire and the procedure. Declaring the tests in advance still shows which comparisons the main study should power.",
               "Can I run the whole study in SurveyStudio?" = "Yes. The whole study opens in SurveyStudio from RStudio's Addins menu.")),
  list(slug = "course-evaluation-survey", demo = "matrix_likert", audience = "education",
       title = "Course evaluation survey",
       lead = "A course evaluation in which students rate each part of a course on 1 grid, compared between students who took it in person and online. surveyframe gives you the questionnaire, the analysis plan and a report for the teaching team.",
       faq = c("Can I change the parts of the course?" = "Yes. Edit the rows of the grid in SurveyStudio's Design screen. Each row becomes its own column in the data.",
               "Can students answer anonymously?" = "This example omits a name field and generates a response id. Review the remaining questions and your collection settings when you design the study's privacy arrangements.",
               "How do I collect the answers?" = "Download the survey as 1 HTML file from the Collect screen and share it, with a free Google Sheet collecting the answers.")),
  list(slug = "training-evaluation-before-and-after", demo = "paired", audience = "education",
       title = "Training evaluation before and after",
       lead = "A training evaluation that measures confidence, and willingness to recommend, before and after a workshop in the same participants. surveyframe gives you the questionnaire, a plan with paired tests declared in advance, and the report.",
       faq = c("Why paired tests?" = "The same people answer before and after, so their answers are compared with themselves: the paired t-test, the Wilcoxon signed-rank test and McNemar's test.",
               "Can I add a third time point?" = "Yes. With 3 or more measurements the plan uses a repeated measures ANOVA or the Friedman test.",
               "Can I run the whole study in SurveyStudio?" = "Yes. The whole study opens in SurveyStudio from RStudio's Addins menu.")),
  list(slug = "customer-satisfaction-survey", demo = "logistic", audience = "business",
       title = "Customer satisfaction survey",
       lead = "A customer study of whether using a service more predicts that customers return, how satisfied they are and which offer they prefer. surveyframe gives you the questionnaire, a plan with logistic regressions declared in advance, and the report.",
       faq = c("Which model predicts a yes or no answer?" = "A binary logistic regression, with the odds ratio of each predictor and its confidence interval.",
               "Can I predict a rating instead?" = "Yes. An ordinal logistic regression predicts an ordered rating, and a multinomial model a choice among 3 or more options.",
               "Can my team use it without writing code?" = "Yes. SurveyStudio runs the whole study in a window started from RStudio's Addins menu. R and RStudio need to be installed, as Get started shows.")),
  list(slug = "employee-engagement-survey", demo = "factor_structure", audience = "business",
       title = "Employee engagement survey",
       lead = "An engagement survey of 8 items written to measure 2 dimensions, how work is organised and the content of the work, with a check that employees' answers support 2 scores. surveyframe gives you the questionnaire, the analysis plan and the report.",
       faq = c("How do I know the survey measures 2 things?" = "The plan checks that the data suit factor analysis, then runs an exploratory factor analysis that shows which items load on which factor.",
               "Can I report 2 scores?" = "Yes, once the factor analysis supports them. Each scale's score and reliability are reported.",
               "Can answers stay anonymous?" = "The example omits a name field, and its report summarises the group. Review the identifying information you collect and who can access the responses in your own study.")),
  list(slug = "supplier-and-venue-selection", demo = "mcdm_choice", audience = "business",
       title = "Supplier and venue selection (decision making)",
       lead = "A decision study that weights the criteria from a committee's judgements and ranks the options by 10 methods, to show whether they agree. surveyframe gives you the questionnaire, the analysis plan and the report.",
       faq = c("Which methods rank the options?" = "AHP and ANP weight the criteria, DEMATEL shows which drive the others, and TOPSIS, VIKOR, MOORA, SMART, WASPAS, PROMETHEE and ELECTRE rank the options.",
               "Are the judgements consistent?" = "The plan accepts pairwise judgements when the consistency ratio is below .10.",
               "Can a committee answer it?" = "Yes. Each member answers the same questionnaire, and the judgements are combined.")),
  list(slug = "open-ended-feedback-survey", demo = "open_text", audience = "events-tourism",
       title = "Open-ended feedback survey",
       lead = "A feedback survey of what worked and what to change, analysed as text: frequent words and phrases, words in context, sentiment and topics. surveyframe gives you the questionnaire, the analysis plan and the report.",
       faq = c("What can surveyframe do with open answers?" = "Word and phrase frequencies, keywords in context, co-occurrence, sentiment, a document-feature matrix and topic models.",
               "Can I compare groups?" = "Yes. The plan can compare what in-person and online respondents write.",
               "How does it help with reading the answers?" = "It shows where to look first, and the report keeps the quotes that represent each topic, so you read the answers with a map.")),
  list(slug = "pre-registered-survey-sealed-and-amended", demo = "verification", audience = "research-methods",
       title = "Preparing a survey study for preregistration",
       lead = "A survey study whose instrument and analysis plan are saved with a hash before data collection, with any later change recorded as a disclosed amendment. surveyframe writes a pre-analysis plan for you to complete and register on OSF or Zenodo, and a report that names the instrument it analysed.",
       faq = c("How do I preregister the plan on OSF?" = "Export the pre-analysis plan from SurveyStudio's Report screen, or with render_report() and no data. Complete the fields it lists under To complete before submission, then upload it with the .sframe file. The plan names the file's hash.",
               "How does a reader check the questionnaire?" = "Anyone can check the .sframe file at surveyframe.org/verify: the page reports whether it matches the hash recorded when it was saved, and reads its disclosed amendments. To identify the registered version, compare the hash with the one in the registered plan.",
               "What if I must change the questionnaire?" = "Record the change as an amendment, with its reason and a deviation report. The amendment log stays in the file.")),
  list(slug = "measurement-model-questionnaire", demo = "sem_pls", audience = "psychology",
       title = "Measurement model questionnaire (CFA and SEM)",
       lead = "A study of whether content quality builds satisfaction, and satisfaction the intention to return, with the measurement model and the structural paths declared in advance. surveyframe gives you the questionnaire, the model syntax for lavaan and seminr, and the report.",
       faq = c("Which software estimates the model?" = "surveyframe writes the model syntax for you to fit in lavaan (covariance-based SEM and CFA) or seminr (PLS-SEM). It estimates the mediation and moderation itself, by regression, and reports those estimates.",
               "Can I declare the model before collecting data?" = "Yes. Constructs, paths and the indirect effect are declared in the instrument and saved with it.",
               "Can I run the whole study in SurveyStudio?" = "Yes. The model layer opens in SurveyStudio from RStudio's Addins menu."))
)

# The fields the templates are grouped by (owner 2026-11-14).
hubs <- c(psychology = "Psychology and measurement", education = "Education",
          business = "Business", "events-tourism" = "Events and tourism",
          "research-methods" = "Research methods")
stage_alt <- c(design = "on the Design screen, with its questions listed", collect = "on the Collect screen, which exports the survey web page",
               check = "on the Quality screen, which checks the responses", analyse = "on the Analyse screen, with the declared plan",
               report = "on the Report screen, which exports the report")

assets <- file.path("pkgdown", "assets", "templates")
pages <- file.path("vignettes", "articles", "templates")
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
  rel <- paste0("../../templates/", st$demo, "/")
  shots <- vapply(names(stage_alt), function(s) {
    sprintf("![The %s study %s.](%s%s.png){width=100%%}", st$title, stage_alt[[s]], rel, s)
  }, character(1))
  siblings <- Filter(function(o) identical(o$audience, st$audience) && o$slug != st$slug, studies)
  related <- vapply(utils::head(siblings, 2), function(o) sprintf("- [%s](%s.html)", o$title, o$slug), character(1))
  methods <- unique(vapply(d$instrument$analysis_plan, function(b) {
    sframe_method_words(sframe_analysis_method(b))
  }, character(1)))
  faq <- unlist(lapply(names(st$faq), function(h) c(paste("###", h), "", st$faq[[h]], "")))
  ld <- sprintf(paste0('<script type="application/ld+json">{"@context":"https://schema.org","@type":"TechArticle",',
                       '"headline":"%s","description":"%s","about":{"@type":"SoftwareSourceCode","name":"surveyframe",',
                       '"url":"https://surveyframe.org"},"url":"https://surveyframe.org/articles/templates/%s.html"}</script>'),
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
    sprintf("This is the questionnaire as respondents see it. It is a preview to try, and it stores no answers. [Open the %s preview in a new tab](%spreview.html){target=\"_blank\" rel=\"noopener\"}.", st$title, rel),
    "",
    "```{=html}",
    sprintf("<iframe src=\"%spreview.html\" title=\"Preview of the %s questionnaire\" style=\"width:100%%;height:560px;border:1px solid #d9e2ec;border-radius:6px\"></iframe>", rel, q(st$title)),
    "```",
    "",
    "## The example analysis plan",
    "",
    sprintf("Before any data is collected, surveyframe writes the pre-analysis plan: the study, the questionnaire, each research question with its hypotheses, method and decision rule, and the fields a preregistration still asks you to complete. [Read the %s plan](%splan.html), or [download the %s instrument (.sframe)](%s%s.sframe) to adapt it.", st$title, rel, st$title, rel, st$demo),
    "",
    sprintf("Methods it declares: %s.", paste(methods, collapse = ", ")),
    "",
    "## What you get",
    "",
    "The study in SurveyStudio, stage by stage: design, collect, check, analyse and report.",
    "",
    shots,
    "",
    "## Open this instrument in SurveyStudio",
    "",
    "1. Set up R, RStudio and surveyframe as [Get started](../start.html) shows.",
    sprintf("2. To explore the example with its demonstration responses, open RStudio's **Addins** menu, choose **surveyframe: Try a demo** and pick `%s`.", st$demo),
    "3. To make it your own study, download the instrument above, choose **surveyframe: Open analysis workspace** from the **Addins** menu, then **Open Instrument** in SurveyStudio's left menu, and select the file.",
    "4. Adapt the questions on the **Design** screen and the research questions under **Plan**, press **Save to Studio**, then press **Download copy** on the **Report** screen to save your study.",
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
    sprintf("- [All %s templates](../templates.html#%s)", tolower(hubs[[st$audience]]), st$audience),
    related,
    "- [How-to guides](../guides.html)",
    ""
  )
  writeLines(rmd, file.path(pages, paste0(st$slug, ".Rmd")))
}

# The index of all templates, by field.
idx <- c("---", "title: \"Questionnaire templates\"",
         "description: \"10 example questionnaires, each with an analysis plan to adapt, in psychology, education, business, events and tourism, and research methods.\"",
         "---", "",
         "Start with an example questionnaire and analysis plan, then adapt them to your study. Review the questions, the scoring and the registration fields before you collect responses. Each template opens and runs in SurveyStudio.", "")
for (h in names(hubs)) {
  idx <- c(idx, sprintf("## %s {#%s}", hubs[[h]], h), "")
  for (st in Filter(function(o) identical(o$audience, h), studies)) {
    idx <- c(idx, sprintf("- [%s](templates/%s.html)", st$title, st$slug))
  }
  idx <- c(idx, "")
}
writeLines(idx, file.path("vignettes", "articles", "templates.Rmd"))
cat("Wrote", length(studies), "template pages and the index.\n")
