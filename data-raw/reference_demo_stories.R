# data-raw/reference_demo_stories.R
# The 2 reference datasets get the treatment the teaching demos get from
# demo_stories.R (Session 10, coordinator 2026-11-14): the placeholder
# author, a research-style purpose, a study, and H0, H1 and a decision rule
# on each block that tests a hypothesis. No generator builds these 2 files,
# so this reads each committed file, applies its story and writes it again
# at version 1.0.0. Items, choices (the yes, no order among them), scales,
# models and responses are untouched. Running it again changes nothing.
#
# Run from the repository root:  Rscript data-raw/reference_demo_stories.R

devtools::load_all(quiet = TRUE)
source(file.path("data-raw", "demo_stories.R"))

diff2 <- function(what, groups) hyp(
  paste0(what, " does not differ between ", groups, "."),
  paste0(what, " differs between ", groups, "."))
diffk <- function(what, groups) hyp(
  paste0(what, " is the same across ", groups, "."),
  paste0(what, " differs for at least 1 of ", groups, "."))
within <- function(what) hyp(
  paste0("Respondents rate ", what, " the same."),
  paste0("Respondents rate ", what, " differently."))
assoc <- function(a, b) hyp(
  paste0(a, " and ", b, " are not associated."),
  paste0(a, " and ", b, " are associated."))
pred <- function(x, y) hyp(
  paste0(x, " do not predict ", y, "."),
  paste0(x, " predict ", y, "."))
fit <- hyp("The declared model reproduces the observed covariances.",
           "The declared model does not reproduce the observed covariances.")
# Every block in both files already has a decision rule, which is kept.

reference_stories <- list(
  tourism_services = list(
    file = "tourism_services_demo.sframe",
    description = "A tourism services study of how digital marketing, service quality and sustainability communication relate to visitor satisfaction and the intention to return or recommend.",
    study = list(
      problem = "Tourism providers invest in digital marketing and sustainability messages without knowing how far these, beside service quality, shape satisfaction and return intention.",
      objectives = obj(O1 = "Check that the 5 scales are reliable and hold their structure.",
                       O2 = "Relate digital marketing, service quality and sustainability to satisfaction.",
                       O3 = "Relate satisfaction to behavioural intention, and compare first-time and repeat visitors."),
      sampling = list(population = "Visitors to tourism services at one destination", method = "convenience", planned_n = 120L)),
    hyp = list(
      rq_dm_sat = assoc("Perceived digital marketing", "satisfaction"),
      rq_predict_sat = pred("Digital marketing, service quality and sustainability perceptions", "satisfaction"),
      rq_visit_bi = diff2("Behavioural intention", "first-time and repeat visitors"),
      rq_sem_syntax = fit,
      rq_chisq = assoc("Visitor type", "the attention check response"),
      rq_fisher = assoc("Visitor type", "the behavioural intention rating"),
      rq_ttest_ind = diff2("Mean satisfaction", "first-time and repeat visitors"),
      rq_ttest_pair = within("the 2 satisfaction items"),
      rq_wilcoxon = within("the first 2 service quality items"),
      rq_kruskal = diffk("Satisfaction", "the visitor types"),
      rq_anova1 = diffk("Mean behavioural intention", "the visitor types"),
      rq_ancova = diffk("Satisfaction, adjusted for service quality,", "the visitor types"),
      rq_rep_anova = within("the 3 digital marketing items"),
      rq_friedman = within("the 3 service quality items"),
      rq_spearman = assoc("Service quality", "sustainability perceptions"),
      rq_kendall = assoc("Sustainability perception", "behavioural intention"),
      rq_partial = assoc("Digital marketing, with satisfaction held constant,", "behavioural intention"),
      rq_logit_bin = pred("Digital marketing and service quality perceptions", "visitor type"),
      rq_logit_ord = pred("Digital marketing and sustainability perceptions", "the ordered satisfaction rating"),
      rq_moderation = hyp("The effect of digital marketing on satisfaction does not depend on service quality.",
                          "The effect of digital marketing on satisfaction depends on service quality."),
      rq_mediation = hyp("Satisfaction does not carry the effect of digital marketing to behavioural intention.",
                         "Satisfaction carries part of the effect of digital marketing to behavioural intention."))
  ),

  input_types = list(
    file = "surveyframe_input_types_demo.sframe",
    description = "A visitor experience study of how online information, service and value relate to overall rating and the intention to recommend or reuse a service, asked with every kind of question a survey can hold.",
    study = list(
      problem = "A service wants to know how the online information visitors use before a visit relates to how they rate the visit and whether they would come back.",
      objectives = obj(O1 = "Describe the visitors and check the quality and reliability of their answers.",
                       O2 = "Relate digital experience to overall rating and behavioural intention.",
                       O3 = "Compare first-time and repeat visitors, and visits made for different purposes."),
      sampling = list(population = "Visitors who booked through the service this season", method = "simple_random", planned_n = 120L)),
    hyp = list(
      rq_digital_bi = NULL, rq_visit_rating = NULL,
      rq_sem_syntax = fit,
      rq_chisq = assoc("Visitor type", "the attention check response"),
      rq_fisher = assoc("Visitor type", "follow-up permission"),
      rq_ttest_ind = diff2("Mean digital experience", "first-time and repeat visitors"),
      rq_ttest_pair = within("the recommend and reuse items"),
      rq_wilcoxon = within("digital ease and digital trust"),
      rq_kruskal = diffk("Overall rating", "the visit purposes"),
      rq_anova1 = diffk("Mean digital experience", "the visit purposes"),
      rq_anova2 = hyp("Visitor type and visit purpose do not interact in overall rating.",
                      "Visitor type and visit purpose interact in overall rating."),
      rq_ancova = diffk("Overall rating, adjusted for nights stayed,", "the visitor types"),
      rq_rep_anova = within("the 3 digital experience items"),
      rq_friedman = within("the 3 digital experience items, on ranks,"),
      rq_spearman = assoc("Digital experience", "overall rating"),
      rq_kendall = assoc("Nights stayed", "overall rating"),
      rq_partial = assoc("Digital experience, with overall rating held constant,", "behavioural intention"),
      rq_reg_lin = pred("Digital experience and nights stayed", "overall rating"),
      rq_logit_bin = pred("Digital experience and overall rating", "follow-up permission"),
      rq_logit_ord = pred("Digital experience and nights stayed", "the ordered overall rating"),
      rq_logit_mult = pred("Digital experience and overall rating", "the visit purpose"),
      rq_moderation = hyp("The effect of digital experience on overall rating does not depend on behavioural intention.",
                          "The effect of digital experience on overall rating depends on behavioural intention."),
      rq_mediation = hyp("Overall rating does not carry the effect of digital experience to behavioural intention.",
                         "Overall rating carries part of the effect of digital experience to behavioural intention."))
  )
)

for (name in names(reference_stories)) {
  st <- reference_stories[[name]]
  path <- file.path("inst", "extdata", st$file)
  ins <- read_sframe(path)
  # Written again as the same instrument at 1.0.0, not amended (owner
  # 2026-11-14): the reference datasets were never a published instrument.
  attr(ins, "sframe_origin") <- NULL
  st$hyp <- Filter(Negate(is.null), st$hyp)
  ins <- apply_story(ins, st)
  # Each block serves an objective: descriptive and quality blocks the
  # first, the blocks naming digital experience or marketing the second,
  # the rest the third.
  for (k in seq_along(ins$analysis_plan)) {
    b <- ins$analysis_plan[[k]]
    m <- sframe_analysis_method(b)
    ins$analysis_plan[[k]]$objective <- if (!sframe_method_uses_alpha(m) || m == "sem_lavaan_syntax") "O1"
      else if (grepl("digital", b$research_question, ignore.case = TRUE)) "O2" else "O3"
  }
  write_sframe(ins, path, overwrite = TRUE)
  cat(sprintf("%-18s %s\n", name, jsonlite::fromJSON(path)$hash$value))
}
