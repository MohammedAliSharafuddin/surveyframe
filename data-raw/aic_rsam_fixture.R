# data-raw/aic_rsam_fixture.R
# Builds the AIC-RSAM regression fixture for v0.3.3 (dev branch only).
# Source: AI_Room_service prototype (questionnaire.md, research_design.md)
# and its surveyframe_Integration/instrument.R, verified against the
# questionnaire on 2026-07-08. Six reflective constructs, nine structural
# paths (H1 to H9), eligibility screening with a cascaded skip-logic chain.
# Output: tests/testthat/fixtures/aic_rsam_pilot.sframe (gitignored on main,
# force-added on dev). Regression tests: tests/testthat/test-aic-rsam-fixture.R.
# Run from the package root with devtools::load_all() active.

devtools::load_all(".", quiet = TRUE)

# ------------------------------------------------------------
# Choice sets
# ------------------------------------------------------------

agree5 <- sf_choices(
  "agree5", 1:5,
  c("Strongly disagree", "Disagree", "Neutral", "Agree", "Strongly agree")
)

yn <- sf_choices("yn", c("yes", "no"), c("Yes", "No"))

stay_dur_cs <- sf_choices(
  "stay_dur_cs",
  c("1_night", "2_nights", "3_4_nights", "5_plus"),
  c("1 night", "2 nights", "3 to 4 nights", "5 nights or more")
)

rs_times_cs <- sf_choices(
  "rs_times_cs",
  c("1_time", "2_3_times", "4_plus", "na"),
  c("1 time", "2 to 3 times", "4 or more times", "Not applicable")
)

mode_cs <- sf_choices(
  "mode_cs",
  c("quick_book", "conv_book"),
  c("Quick Book", "Conversational Book")
)

freq_cs <- sf_choices(
  "freq_cs",
  c("never", "rarely", "sometimes", "often", "very_often"),
  c("Never", "Rarely", "Sometimes", "Often", "Very often")
)

age_grp_cs <- sf_choices(
  "age_grp_cs",
  c("18_24", "25_34", "35_44", "45_plus"),
  c("18 to 24", "25 to 34", "35 to 44", "45 and above")
)

gender_cs <- sf_choices(
  "gender_cs",
  c("male", "female", "prefer_not", "other"),
  c("Male", "Female", "Prefer not to say", "Other")
)

# ------------------------------------------------------------
# Part 1: eligibility screening (E1 to E7)
# ------------------------------------------------------------

sec_eligibility <- sf_item(
  "sec_eligibility",
  "Part 1: Eligibility Screening",
  type          = "section_break",
  section_intro = "Please answer the following short questions before we begin."
)

elig_age <- sf_item(
  "elig_age", "Are you 18 years or older?",
  type = "single_choice", choice_set = "yn", required = TRUE
)

elig_nationality <- sf_item(
  "elig_nationality", "Are you a Maldivian national or resident?",
  type = "single_choice", choice_set = "yn", required = TRUE
)

elig_resort_stay <- sf_item(
  "elig_resort_stay",
  "Have you stayed in a Maldivian resort within the past 12 months?",
  type = "single_choice", choice_set = "yn", required = TRUE
)

elig_stay_duration <- sf_item(
  "elig_stay_duration",
  "How long was your most recent stay in a Maldivian resort?",
  type = "single_choice", choice_set = "stay_dur_cs", required = TRUE
)

elig_room_service <- sf_item(
  "elig_room_service",
  "During your most recent resort stay, did you order or attempt to order room service?",
  type = "single_choice", choice_set = "yn", required = FALSE
)

elig_rs_times <- sf_item(
  "elig_rs_times", "If yes, about how many times?",
  type = "single_choice", choice_set = "rs_times_cs", required = FALSE
)

elig_smartphone <- sf_item(
  "elig_smartphone",
  "Do you use a smartphone for online ordering or app-based services?",
  type = "single_choice", choice_set = "yn", required = FALSE,
  help = "This is a profile question and is not used as an exclusion criterion."
)

# ------------------------------------------------------------
# Part 2: respondent profile (P1 to P6)
# ------------------------------------------------------------

sec_profile <- sf_item(
  "sec_profile",
  "Part 2: Respondent Profile",
  type          = "section_break",
  section_intro = "A few background questions about your experience with the prototype."
)

prof_mode_first <- sf_item(
  "prof_mode_first", "Which mode did you try first in the prototype?",
  type = "single_choice", choice_set = "mode_cs", required = TRUE
)

prof_tried_other <- sf_item(
  "prof_tried_other", "Did you also try the other mode?",
  type = "single_choice", choice_set = "yn", required = TRUE
)

prof_app_frequency <- sf_item(
  "prof_app_frequency", "How often do you use food-ordering apps?",
  type = "single_choice", choice_set = "freq_cs", required = TRUE
)

prof_chatbot_prior <- sf_item(
  "prof_chatbot_prior",
  "Have you used a chatbot or conversational ordering system before?",
  type = "single_choice", choice_set = "yn", required = TRUE
)

prof_age_group <- sf_item(
  "prof_age_group", "Age group",
  type = "single_choice", choice_set = "age_grp_cs", required = TRUE
)

prof_gender <- sf_item(
  "prof_gender", "Gender",
  type = "single_choice", choice_set = "gender_cs", required = TRUE
)

# ------------------------------------------------------------
# Sections A to F: the six AIC-RSAM constructs (4 items each)
# ------------------------------------------------------------

likert_block <- function(prefix, texts, scale_id) {
  Map(function(i, txt) {
    sf_item(paste0(prefix, "_", i), txt,
            type = "likert", choice_set = "agree5",
            scale_id = scale_id, required = TRUE)
  }, seq_along(texts), texts)
}

sec_aia <- sf_item(
  "sec_aia", "Section A: Perceived AI Assistance",
  type          = "section_break",
  section_intro = paste(
    "Please rate your agreement with the following statements about the AI",
    "features in the prototype. Use the scale: 1 = Strongly disagree,",
    "5 = Strongly agree."
  )
)
aia_items <- likert_block("aia", c(
  "The AI-assisted features helped me find suitable menu options more easily.",
  "The conversational guidance helped me express my food preferences clearly.",
  "The recommendations matched my likely needs well.",
  "The system reduced the effort needed to decide what to order."
), "aia")
scale_aia <- sf_scale("aia", "Perceived AI Assistance",
                      paste0("aia_", 1:4), method = "mean")

sec_poa <- sf_item("sec_poa", "Section B: Perceived Order Assurance",
                   type = "section_break")
poa_items <- likert_block("poa", c(
  "I believe this system can record a room-service order accurately.",
  "I believe this system can reduce misunderstandings compared with telephone ordering.",
  "I believe this system can route the order correctly to the relevant hotel units.",
  "The confirmation process gave me confidence that the order was captured properly."
), "poa")
scale_poa <- sf_scale("poa", "Perceived Order Assurance",
                      paste0("poa_", 1:4), method = "mean")

sec_peou <- sf_item("sec_peou", "Section C: Perceived Ease of Use",
                    type = "section_break")
peou_items <- likert_block("peou", c(
  "Learning to use this system would be easy for me.",
  "It was easy for me to complete an order using this system.",
  "The booking steps were clear and understandable.",
  "The overall interface was simple and user-friendly."
), "peou")
scale_peou <- sf_scale("peou", "Perceived Ease of Use",
                       paste0("peou_", 1:4), method = "mean")

sec_pu <- sf_item("sec_pu", "Section D: Perceived Usefulness",
                  type = "section_break")
pu_items <- likert_block("pu", c(
  "This system would make room-service ordering faster.",
  "This system would make room-service ordering more convenient.",
  "This system would help reduce booking errors.",
  "This system would be useful during a real resort stay."
), "pu")
scale_pu <- sf_scale("pu", "Perceived Usefulness",
                     paste0("pu_", 1:4), method = "mean")

sec_pr <- sf_item("sec_pr", "Section E: Perceived Risk",
                  type = "section_break")
pr_items <- likert_block("pr", c(
  "I worry that the system may record the wrong order.",
  "I worry that technical problems may interrupt the ordering process.",
  "I worry that using this system may reduce access to staff assistance when needed.",
  "I worry about the privacy or security of information entered into this system."
), "pr")
scale_pr <- sf_scale("pr", "Perceived Risk",
                     paste0("pr_", 1:4), method = "mean")

sec_bi <- sf_item("sec_bi", "Section F: Behavioural Intention to Use",
                  type = "section_break")
bi_items <- likert_block("bi", c(
  "I would use this system if it were available in a resort room.",
  "I would choose this system for routine room-service requests if it were available.",
  "I would use this system again during future resort stays.",
  "I would recommend this system to other resort guests."
), "bi")
scale_bi <- sf_scale("bi", "Behavioural Intention to Use",
                     paste0("bi_", 1:4), method = "mean")

# ------------------------------------------------------------
# Section G: feature evaluation (design feedback only)
# ------------------------------------------------------------

sec_fe <- sf_item(
  "sec_fe", "Section G: Feature Evaluation",
  type          = "section_break",
  section_intro = "These items are for prototype refinement only and are not part of the structural model."
)
fe_items <- Map(function(i, txt) {
  sf_item(paste0("fe_", i), txt,
          type = "likert", choice_set = "agree5",
          scale_id = "fe", required = FALSE)
}, 1:6, c(
  "Having both Quick Book and Conversational Book in the same system is useful.",
  "Quick Book is suitable when I already know what I want.",
  "Conversational Book is suitable when I need help deciding.",
  "I would like the option to switch between the two modes during ordering.",
  "The menu search function should remain available throughout the process.",
  "Visual menu cards would improve the ordering experience."
))
scale_fe <- sf_scale("fe", "Feature Evaluation",
                     paste0("fe_", 1:6), method = "mean")

# ------------------------------------------------------------
# Section H: open-ended design feedback
# ------------------------------------------------------------

sec_od <- sf_item(
  "sec_od", "Section H: Design Feedback",
  type          = "section_break",
  section_intro = "Your written responses will be used for prototype refinement only."
)
od_1 <- sf_item("od_1", "What did you like most about the system?",
                type = "text", required = FALSE)
od_2 <- sf_item("od_2",
                "What should be improved before this system is tested in an actual resort?",
                type = "text", required = FALSE)

# ------------------------------------------------------------
# Branching: eligibility cascade
# Each gate shows only when the previous gate passes. The chain enforces
# the four hard exclusion criteria (E1, E2, E3 answered No, or E4 = 1 night).
# E5 to E7 are profile items shown once the duration gate passes, with E6
# additionally conditional on E5 = yes.
# ------------------------------------------------------------

br_nationality <- sf_branch("elig_nationality", depends_on = "elig_age",
                            operator = "==", value = "yes", action = "show")
br_resort_stay <- sf_branch("elig_resort_stay", depends_on = "elig_nationality",
                            operator = "==", value = "yes", action = "show")
br_stay_duration <- sf_branch("elig_stay_duration", depends_on = "elig_resort_stay",
                              operator = "==", value = "yes", action = "show")

br_elig_followup <- lapply(
  c("elig_room_service", "elig_rs_times", "elig_smartphone"),
  function(id) {
    sf_branch(id, depends_on = "elig_stay_duration",
              operator = "!=", value = "1_night", action = "show")
  }
)

br_rs_times <- sf_branch("elig_rs_times", depends_on = "elig_room_service",
                         operator = "==", value = "yes", action = "show")

# Main questionnaire visibility: everything after screening appears only
# once the final gate passes (duration answered and not 1 night).
main_item_ids <- c(
  "sec_profile",
  "prof_mode_first", "prof_tried_other", "prof_app_frequency",
  "prof_chatbot_prior", "prof_age_group", "prof_gender",
  "sec_aia",  paste0("aia_",  1:4),
  "sec_poa",  paste0("poa_",  1:4),
  "sec_peou", paste0("peou_", 1:4),
  "sec_pu",   paste0("pu_",   1:4),
  "sec_pr",   paste0("pr_",   1:4),
  "sec_bi",   paste0("bi_",   1:4),
  "sec_fe",   paste0("fe_",   1:6),
  "sec_od",   "od_1", "od_2"
)
br_main <- lapply(main_item_ids, function(id) {
  sf_branch(id, depends_on = "elig_stay_duration",
            operator = "!=", value = "1_night", action = "show")
})

# ------------------------------------------------------------
# AIC-RSAM model: six reflective constructs, nine paths (H1 to H9)
# ------------------------------------------------------------

aic_rsam_model <- sf_model(
  id     = "aic_rsam",
  label  = "AIC-RSAM: AI-Assisted Conversational Room-Service Acceptance Model",
  type   = "pls_sem",
  engine = "seminr",
  constructs = list(
    sf_construct("aia",  "Perceived AI Assistance",      items = paste0("aia_", 1:4),  mode = "reflective"),
    sf_construct("poa",  "Perceived Order Assurance",    items = paste0("poa_", 1:4),  mode = "reflective"),
    sf_construct("peou", "Perceived Ease of Use",        items = paste0("peou_", 1:4), mode = "reflective"),
    sf_construct("pu",   "Perceived Usefulness",         items = paste0("pu_", 1:4),   mode = "reflective"),
    sf_construct("pr",   "Perceived Risk",               items = paste0("pr_", 1:4),   mode = "reflective"),
    sf_construct("bi",   "Behavioural Intention to Use", items = paste0("bi_", 1:4),   mode = "reflective")
  ),
  paths = list(
    sf_path("aia",  "peou", "H1: AIA positively influences PEOU"),
    sf_path("aia",  "pu",   "H2: AIA positively influences PU"),
    sf_path("aia",  "poa",  "H3: AIA positively influences POA"),
    sf_path("peou", "pu",   "H4: PEOU positively influences PU"),
    sf_path("peou", "bi",   "H5: PEOU positively influences BI"),
    sf_path("poa",  "pu",   "H6: POA positively influences PU"),
    sf_path("poa",  "bi",   "H7: POA positively influences BI"),
    sf_path("pu",   "bi",   "H8: PU positively influences BI"),
    sf_path("pr",   "bi",   "H9: PR negatively influences BI")
  )
)

# ------------------------------------------------------------
# Analysis plan
# ------------------------------------------------------------

plan_plssem <- list(
  id                = "RQ1",
  research_question = "Which AIC-RSAM factors explain behavioural intention to use the AI-assisted room-service system, and which hypotheses (H1 to H9) are supported?",
  family            = "measurement",
  method            = "pls_sem",
  roles             = list(model = "aic_rsam"),
  options           = list(alpha = 0.05)
)

plan_reliability <- list(
  id                = "RQ1a",
  research_question = "Do the six reflective construct scales demonstrate adequate internal consistency and convergent validity?",
  family            = "measurement",
  method            = "reliability_alpha",
  roles             = list(items = c(paste0("aia_", 1:4), paste0("poa_", 1:4),
                                     paste0("peou_", 1:4), paste0("pu_", 1:4),
                                     paste0("pr_", 1:4), paste0("bi_", 1:4))),
  options           = list(alpha = 0.05)
)

plan_fe_desc <- list(
  id                = "RQ2",
  research_question = "How do participants evaluate the two-mode interface design (Quick Book and Conversational Book)?",
  family            = "measurement",
  method            = "reliability_alpha",
  roles             = list(items = paste0("fe_", 1:6)),
  options           = list(alpha = 0.05)
)

# ------------------------------------------------------------
# Assemble, validate, save
# ------------------------------------------------------------

aic_rsam <- sf_instrument(
  title       = "AIC-RSAM Pilot Study: AI-Assisted Conversational Room-Service Booking System",
  version     = "0.1.0",
  description = paste(
    "Post-use questionnaire for the AIC-RSAM prototype-based pilot study.",
    "Population: Maldivian adults who have stayed in a Maldivian resort within the past 12 months.",
    "Participants complete the prototype before this questionnaire."
  ),
  authors = "Sharafuddin, M. A.",
  render = list(
    mode  = "standard",
    theme = "#0f766e",
    welcome = list(
      title            = "AIC-RSAM Pilot Study",
      intro_text       = paste(
        "You have completed the prototype booking session.",
        "Please answer the following questions based on your experience with the system.",
        "There are no right or wrong answers.",
        "All responses are anonymous."
      ),
      consent_text     = paste(
        "I understand that my responses will be used for research purposes only,",
        "that participation is voluntary, and that I may stop at any time."
      ),
      consent_required = TRUE,
      start_label      = "Begin Questionnaire"
    ),
    thankyou = list(
      message = paste(
        "Thank you for completing the questionnaire.",
        "Your responses have been saved.",
        "You may now close this window."
      ),
      show_download = FALSE
    ),
    header = list(
      institution   = "AIC-RSAM Pilot Study",
      show_progress = TRUE
    ),
    submit_label = "Submit Questionnaire"
  ),
  components = c(
    list(agree5, yn, stay_dur_cs, rs_times_cs, mode_cs, freq_cs,
         age_grp_cs, gender_cs),
    list(sec_eligibility, elig_age, elig_nationality, elig_resort_stay,
         elig_stay_duration, elig_room_service, elig_rs_times,
         elig_smartphone),
    list(sec_profile, prof_mode_first, prof_tried_other, prof_app_frequency,
         prof_chatbot_prior, prof_age_group, prof_gender),
    c(list(sec_aia),  aia_items,  list(scale_aia)),
    c(list(sec_poa),  poa_items,  list(scale_poa)),
    c(list(sec_peou), peou_items, list(scale_peou)),
    c(list(sec_pu),   pu_items,   list(scale_pu)),
    c(list(sec_pr),   pr_items,   list(scale_pr)),
    c(list(sec_bi),   bi_items,   list(scale_bi)),
    c(list(sec_fe),   fe_items,   list(scale_fe)),
    list(sec_od, od_1, od_2),
    list(br_nationality, br_resort_stay, br_stay_duration),
    br_elig_followup,
    list(br_rs_times),
    br_main
  ),
  analysis_plan = list(plan_plssem, plan_reliability, plan_fe_desc),
  models        = list(aic_rsam_model)
)

validate_sframe(aic_rsam)
out_path <- file.path("tests", "testthat", "fixtures", "aic_rsam_pilot.sframe")
write_sframe(aic_rsam, out_path, overwrite = TRUE)
message("AIC-RSAM fixture written to ", out_path)
