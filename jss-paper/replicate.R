## replicate.R
## Replication script for:
##   "surveyframe: A Proactive Survey Research Workflow for R"
##   Journal of Statistical Software submission
##
## Requirements: surveyframe >= 0.3.0, psych >= 2.3.0 (optional)
## Run with: Rscript replicate.R
## Or from R: source("replicate.R")
##
## All outputs reproduce the results shown in the manuscript.
## No external data files or network access are required.

options(prompt = "R> ", continue = "+  ", width = 70,
        useFancyQuotes = FALSE, digits = 4)

library("surveyframe")

cat("\n=== Section 3: Instrument construction ===\n\n")

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
cat("\n")

result <- validate_sframe(instr_simple, strict = FALSE)
cat("Valid:", result$valid, "\n")
cat("Problems:", length(result$problems), "\n\n")


cat("=== Section 4: Load demo data ===\n\n")

demo  <- sframe_demo_data()
instr <- demo$instrument
resp  <- demo$responses

cat("Instrument:", instr$meta$title, "\n")
cat("Scales:", length(instr$scales), "\n")
cat("Items:", length(instr$items), "\n")
cat("Responses:", nrow(resp), "\n\n")


cat("=== Section 5.1: Data quality report ===\n\n")

qr <- quality_report(resp, instr)
cat("Respondents:", qr$summary$n_respondents, "\n")
cat("Items:      ", qr$summary$n_items, "\n")
cat("Flagged:    ", qr$summary$n_flagged, "\n\n")


cat("=== Section 5.2: Scale scoring ===\n\n")

scored <- score_scales(resp, instr)
scale_cols <- c("digital_marketing", "service_quality",
                "sustainability", "satisfaction",
                "behavioural_intention")
print(summary(scored[, scale_cols]))
cat("\n")


cat("=== Section 5.3: Reliability ===\n\n")

if (requireNamespace("psych", quietly = TRUE)) {
  rr <- reliability_report(resp, instr, omega = FALSE)
  print(rr)
} else {
  message("psych not installed; skipping reliability report.")
}
cat("\n")


cat("=== Section 5.5: CFA syntax ===\n\n")

syn <- cfa_syntax(instr)
cat(syn, "\n\n")


cat("=== Section 5.6: Analysis plan ===\n\n")

results <- run_analysis_plan(resp, instr, scored = TRUE)

r1 <- results[[1]]
cat("--- Test 1:", r1$test, "---\n")
cat("APA:   ", r1$apa, "\n")
cat("Effect:", r1$effect_label, "\n")
cat("Q:     ", r1$research_question, "\n\n")

r2 <- results[[2]]
cat("--- Test 2:", r2$test, "---\n")
cat("APA:", r2$apa, "\n\n")

r3 <- results[[3]]
cat("--- Test 3:", r3$test, "---\n")
cat("APA:   ", r3$apa, "\n")
cat("Effect:", r3$effect_label, "\n\n")


cat("=== Section 6: Codebook ===\n\n")

cb <- codebook_report(instr)
cat("Items in codebook:", nrow(cb$items_table), "\n")
print(head(cb$items_table[, c("id", "type", "scale_id", "reverse")], 6))
cat("\n")


cat("=== Session info ===\n\n")
sessionInfo()
