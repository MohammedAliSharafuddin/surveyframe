## replicate.R
## Replication script for
##   "surveyframe: A Proactive Survey Research Workflow for R"
##   Journal of Statistical Software submission
##
## Requirements: surveyframe (>= 0.3.0), psych (>= 2.3.0)
## Run with: Rscript replicate.R
## Or from R: source("replicate.R", echo = TRUE)
##
## All results below reproduce the output shown in the manuscript.
## No external data files or network access are required.

options(prompt = "R> ", continue = "+  ", width = 70,
        useFancyQuotes = FALSE, digits = 4)

library("surveyframe")
library("psych")

## Section 3: Instrument construction

agree5 <- sf_choices(
  id     = "agree5",
  values = 1:5,
  labels = c("Strongly disagree", "Disagree", "Neutral",
             "Agree", "Strongly agree")
)

dm_1 <- sf_item("dm_1",
  "Social media content influences my travel decisions.",
  type = "likert", choice_set = "agree5",
  scale_id = "digital_marketing", required = TRUE)

dm_2 <- sf_item("dm_2",
  "Online reviews shape my destination choices.",
  type = "likert", choice_set = "agree5",
  scale_id = "digital_marketing", required = TRUE)

dm_3 <- sf_item("dm_3",
  "Digital promotions encourage me to visit new places.",
  type = "likert", choice_set = "agree5",
  scale_id = "digital_marketing", required = TRUE)

sq_1 <- sf_item("sq_1",
  "The hospitality staff were attentive and helpful.",
  type = "likert", choice_set = "agree5",
  scale_id = "service_quality", required = TRUE)

sq_2 <- sf_item("sq_2",
  "Facilities were clean and well maintained.",
  type = "likert", choice_set = "agree5",
  scale_id = "service_quality", required = TRUE)

dm_scale <- sf_scale(
  id     = "digital_marketing",
  label  = "Digital marketing effectiveness",
  items  = c("dm_1", "dm_2", "dm_3"),
  method = "mean"
)

sq_scale <- sf_scale(
  id     = "service_quality",
  label  = "Service quality",
  items  = c("sq_1", "sq_2"),
  method = "mean"
)

instr_simple <- sf_instrument(
  title       = "Tourism Experience Survey",
  version     = "1.0.0",
  description = "Digital marketing and service quality perceptions.",
  authors     = "J. Researcher",
  components  = list(agree5, dm_1, dm_2, dm_3, sq_1, sq_2,
                     dm_scale, sq_scale)
)

print(instr_simple)

## Validation

result <- validate_sframe(instr_simple, strict = FALSE)
print(result$valid)
print(result$problems)

## Section 4: Load demo data

demo  <- sframe_demo_data()
instr <- demo$instrument
resp  <- demo$responses

print(instr$meta$title)
print(c(scales    = length(instr$scales),
        items     = length(instr$items),
        responses = nrow(resp)))

## Section 5.1: Data quality report

qr <- quality_report(resp, instr)
print(c(respondents = qr$summary$n_respondents,
        items       = qr$summary$n_items,
        flagged     = qr$summary$n_flagged))

## Section 5.2: Scale scoring

scored <- score_scales(resp, instr)
scale_cols <- c("digital_marketing", "service_quality",
                "sustainability", "satisfaction",
                "behavioural_intention")
print(summary(scored[, scale_cols]))

## Section 5.3: Reliability

rr <- reliability_report(resp, instr, omega = FALSE)
print(rr)

## Section 5.5: CFA syntax

syn <- cfa_syntax(instr)
cat(syn)

## Section 5.6: Analysis plan

results <- run_analysis_plan(resp, instr, scored = TRUE)
print(results)

## Section 6: Codebook

cb <- codebook_report(instr)
print(nrow(cb$items_table))
print(head(cb$items_table[, c("id", "type", "scale_id", "reverse")], 6))

## Session information

print(sessionInfo())
