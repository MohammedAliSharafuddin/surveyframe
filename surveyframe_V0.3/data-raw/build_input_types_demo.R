# Build a bundled demo instrument that covers all surveyframe input types.
# Run from the package root.

if (requireNamespace("pkgload", quietly = TRUE)) {
  try(pkgload::load_all("."), silent = TRUE)
}

set.seed(20260514)

dir.create("inst/extdata", recursive = TRUE, showWarnings = FALSE)

agree5 <- sf_choices(
  id = "agree5",
  values = 1:5,
  labels = c(
    "Strongly disagree",
    "Disagree",
    "Neither agree nor disagree",
    "Agree",
    "Strongly agree"
  )
)

visit_type <- sf_choices(
  id = "visit_type",
  values = c("first_time", "repeat"),
  labels = c("First-time visitor", "Repeat visitor")
)

visit_purpose <- sf_choices(
  id = "visit_purpose",
  values = c("holiday", "business", "family", "education", "other"),
  labels = c("Holiday", "Business", "Family visit", "Education", "Other")
)

channels <- sf_choices(
  id = "channels",
  values = c("search_engine", "instagram", "facebook", "youtube", "travel_blog", "friend"),
  labels = c("Search engine", "Instagram", "Facebook", "YouTube", "Travel blog", "Friend or family")
)

yes_no <- sf_choices(
  id = "yes_no",
  values = c("yes", "no"),
  labels = c("Yes", "No")
)

feature_rank <- sf_choices(
  id = "feature_rank",
  values = c("service_quality", "price", "sustainability", "location", "digital_information"),
  labels = c("Service quality", "Price", "Sustainability", "Location", "Digital information")
)

items <- list(
  sf_item(
    id = "sec_intro",
    label = "Section 1: Visit background",
    type = "section_break",
    section_intro = "This section demonstrates display-only section breaks."
  ),
  sf_item(
    id = "info_block",
    label = "This is a display text block. It should not be treated as a response variable.",
    type = "text_block"
  ),
  sf_item(
    id = "respondent_name",
    label = "Respondent display name",
    type = "text",
    placeholder = "Optional short name"
  ),
  sf_item(
    id = "visit_type",
    label = "Was this your first visit?",
    type = "single_choice",
    required = TRUE,
    choice_set = "visit_type"
  ),
  sf_item(
    id = "visit_purpose",
    label = "What was the main purpose of your visit?",
    type = "single_choice",
    required = TRUE,
    choice_set = "visit_purpose"
  ),
  sf_item(
    id = "other_purpose",
    label = "Please specify the other purpose.",
    type = "text",
    placeholder = "Write the other purpose"
  ),
  sf_item(
    id = "information_channels",
    label = "Which channels helped you before the visit?",
    type = "multiple_choice",
    required = TRUE,
    choice_set = "channels",
    help = "Select all that apply."
  ),
  sf_item(
    id = "booking_date",
    label = "When did you make the booking?",
    type = "date",
    required = TRUE
  ),
  sf_item(
    id = "nights_stayed",
    label = "How many nights did you stay?",
    type = "numeric",
    required = TRUE,
    help = "Enter the number of nights."
  ),
  sf_item(
    id = "digital_ease",
    label = "Online information made the visit easier to plan.",
    type = "likert",
    required = TRUE,
    choice_set = "agree5",
    scale_id = "digital_experience"
  ),
  sf_item(
    id = "digital_trust",
    label = "The online information appeared trustworthy.",
    type = "likert",
    required = TRUE,
    choice_set = "agree5",
    scale_id = "digital_experience"
  ),
  sf_item(
    id = "digital_confusion",
    label = "Online information made the planning process confusing.",
    type = "likert",
    required = TRUE,
    choice_set = "agree5",
    scale_id = "digital_experience",
    reverse = TRUE
  ),
  sf_item(
    id = "service_matrix",
    label = "Please rate the following service aspects.",
    type = "matrix",
    required = TRUE,
    choice_set = "agree5",
    matrix_items = c("Cleanliness", "Staff helpfulness", "Food quality", "Transport support")
  ),
  sf_item(
    id = "value_slider",
    label = "How would you rate value for money?",
    type = "slider",
    required = TRUE,
    slider_min = 0,
    slider_max = 100,
    slider_step = 5
  ),
  sf_item(
    id = "feature_ranking",
    label = "Rank the following features by importance.",
    type = "ranking",
    required = TRUE,
    choice_set = "feature_rank"
  ),
  sf_item(
    id = "overall_rating",
    label = "Overall experience rating",
    type = "rating",
    required = TRUE,
    rating_max = 5,
    rating_icon = "star"
  ),
  sf_item(
    id = "recommend",
    label = "I would recommend this service to others.",
    type = "likert",
    required = TRUE,
    choice_set = "agree5",
    scale_id = "behavioural_intention"
  ),
  sf_item(
    id = "reuse",
    label = "I would use a similar service again.",
    type = "likert",
    required = TRUE,
    choice_set = "agree5",
    scale_id = "behavioural_intention"
  ),
  sf_item(
    id = "attention",
    label = "For quality control, please select Agree.",
    type = "single_choice",
    required = TRUE,
    choice_set = "agree5"
  ),
  sf_item(
    id = "follow_up_permission",
    label = "May the research team contact you for clarification?",
    type = "single_choice",
    required = TRUE,
    choice_set = "yes_no"
  ),
  sf_item(
    id = "open_comment",
    label = "Please add any comments about your visit.",
    type = "textarea",
    placeholder = "Optional comment"
  )
)

scales <- list(
  sf_scale(
    id = "digital_experience",
    label = "Digital experience",
    items = c("digital_ease", "digital_trust", "digital_confusion"),
    method = "mean",
    min_valid = 2,
    reverse_items = "digital_confusion"
  ),
  sf_scale(
    id = "behavioural_intention",
    label = "Behavioural intention",
    items = c("recommend", "reuse"),
    method = "mean",
    min_valid = 2
  )
)

branches <- list(
  sf_branch(
    item_id = "other_purpose",
    depends_on = "visit_purpose",
    operator = "==",
    value = "other",
    action = "show"
  )
)

checks <- list(
  sf_check(
    id = "attention_agree",
    item_id = "attention",
    type = "attention",
    pass_values = 4,
    fail_action = "flag",
    label = "Instructional attention check",
    notes = "Respondent should select Agree."
  )
)

render <- list(
  mode = "standard",
  theme = "#1f6f78",
  submit_label = "Submit response",
  welcome = list(
    title = "surveyframe Input Types Demo",
    intro_text = paste(
      "This demo instrument covers the main input types supported by surveyframe.",
      "It is intended for testing the builder, studio, dashboard, and vignettes."
    ),
    consent_text = "I understand that this is simulated demonstration data.",
    consent_required = TRUE,
    start_label = "Start demo"
  ),
  thankyou = list(
    message = "Thank you for completing the input-types demo.",
    redirect_url = "",
    show_download = TRUE
  ),
  header = list(
    institution = "surveyframe demo",
    logo_base64 = "",
    show_progress = TRUE
  )
)

analysis_plan <- list(
  list(
    id = "rq_digital_bi",
    research_question = "Is digital experience associated with behavioural intention?",
    family = "association",
    method = "correlation_pearson",
    test = "correlation_pearson",
    roles = list(x = "digital_experience", y = "behavioural_intention"),
    variables = c("digital_experience", "behavioural_intention"),
    options = list(alpha = 0.05),
    hypotheses = list(
      null = "Digital experience is not associated with behavioural intention.",
      alternative = "Digital experience is associated with behavioural intention."
    ),
    decision_rule = "Report the direction, size, and uncertainty of the relationship.",
    interpretation = "Report the direction, size, and uncertainty of the relationship.",
    reporting_references = character(0),
    citations = character(0),
    status = "valid_plan",
    requires_data = TRUE
  ),
  list(
    id = "rq_visit_rating",
    research_question = "Do first-time and repeat visitors differ in overall rating?",
    family = "group_comparison",
    method = "mann_whitney",
    test = "mann_whitney",
    roles = list(group = "visit_type", outcome = "overall_rating"),
    variables = c("visit_type", "overall_rating"),
    options = list(alpha = 0.05),
    hypotheses = list(
      null = "First-time and repeat visitors do not differ in overall rating.",
      alternative = "First-time and repeat visitors differ in overall rating."
    ),
    decision_rule = "Compare the distribution of ratings across visitor groups.",
    interpretation = "Compare the distribution of ratings across visitor groups.",
    reporting_references = character(0),
    citations = character(0),
    status = "valid_plan",
    requires_data = TRUE
  )
)

instr <- sf_instrument(
  title = "surveyframe Input Types Demo",
  version = "0.3.0",
  description = paste(
    "Simulated questionnaire covering section breaks, text blocks, text, textarea,",
    "single choice, multiple choice, numeric, date, Likert, matrix, slider, ranking,",
    "rating, branching, attention checks, scored scales, and analysis plans."
  ),
  authors = "Mohammed Ali Sharafuddin",
  languages = "en",
  components = c(
    list(agree5, visit_type, visit_purpose, channels, yes_no, feature_rank),
    items,
    scales,
    branches,
    checks
  ),
  render = render,
  analysis_plan = analysis_plan
)

instr <- validate_sframe(instr)

write_sframe(
  instr,
  path = "inst/extdata/surveyframe_input_types_demo.sframe",
  overwrite = TRUE
)

n <- 120

sample_channels <- function() {
  k <- sample(1:4, 1)
  paste(sample(channels$values, k), collapse = ";")
}

sample_ranking <- function() {
  paste(sample(feature_rank$values), collapse = ">")
}

sample_matrix <- function() {
  vals <- sample(2:5, 4, replace = TRUE)
  names(vals) <- c("cleanliness", "staff_helpfulness", "food_quality", "transport_support")
  jsonlite::toJSON(as.list(vals), auto_unbox = TRUE)
}

started <- as.POSIXct("2026-01-15 09:00:00", tz = "UTC") + seq(0, by = 97, length.out = n)
submitted <- started + sample(180:1200, n, replace = TRUE)

visit_purpose_vec <- sample(
  visit_purpose$values,
  n,
  replace = TRUE,
  prob = c(.45, .15, .18, .12, .10)
)

digital_latent <- round(pmin(pmax(rnorm(n, mean = 3.6, sd = .85), 1), 5))
behaviour_latent <- round(pmin(pmax(digital_latent + rnorm(n, 0, .75), 1), 5))

responses <- data.frame(
  respondent_id = sprintf("R%03d", seq_len(n)),
  started_at = format(started, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
  submitted_at = format(submitted, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
  respondent_name = ifelse(runif(n) < .30, "", paste0("Demo ", seq_len(n))),
  visit_type = sample(visit_type$values, n, replace = TRUE, prob = c(.62, .38)),
  visit_purpose = visit_purpose_vec,
  other_purpose = ifelse(visit_purpose_vec == "other", "Transit and short stay", ""),
  information_channels = replicate(n, sample_channels()),
  booking_date = format(as.Date("2025-12-01") + sample(0:60, n, replace = TRUE)),
  nights_stayed = sample(
    1:14,
    n,
    replace = TRUE,
    prob = c(.08, .13, .19, .18, .12, .09, .07, .05, .03, .02, .02, .01, .01, .01)
  ),
  digital_ease = pmin(pmax(digital_latent + sample(-1:1, n, replace = TRUE), 1), 5),
  digital_trust = pmin(pmax(digital_latent + sample(-1:1, n, replace = TRUE), 1), 5),
  digital_confusion = pmin(pmax(6 - digital_latent + sample(-1:1, n, replace = TRUE), 1), 5),
  service_matrix = replicate(n, sample_matrix()),
  value_slider = pmin(
    pmax(round((digital_latent + behaviour_latent) / 10 * 100 / 5) * 5 +
           sample(-10:10, n, replace = TRUE), 0),
    100
  ),
  feature_ranking = replicate(n, sample_ranking()),
  overall_rating = pmin(pmax(behaviour_latent + sample(-1:1, n, replace = TRUE), 1), 5),
  recommend = pmin(pmax(behaviour_latent + sample(-1:1, n, replace = TRUE), 1), 5),
  reuse = pmin(pmax(behaviour_latent + sample(-1:1, n, replace = TRUE), 1), 5),
  attention = 4,
  follow_up_permission = sample(c("yes", "no"), n, replace = TRUE, prob = c(.35, .65)),
  open_comment = sample(
    c(
      "",
      "The online information was helpful.",
      "The booking details could be clearer.",
      "The service experience was good.",
      "More sustainability information would be useful."
    ),
    n,
    replace = TRUE,
    prob = c(.45, .18, .12, .15, .10)
  ),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

responses$attention[sample(seq_len(n), 5)] <- sample(c(2, 3, 5), 5, replace = TRUE)
responses$digital_trust[sample(seq_len(n), 4)] <- NA
responses$open_comment[sample(seq_len(n), 3)] <- "Straight-line style response pattern for testing."

utils::write.csv(
  responses,
  file = "inst/extdata/surveyframe_input_types_responses.csv",
  row.names = FALSE,
  na = ""
)

message("Wrote:")
message("  inst/extdata/surveyframe_input_types_demo.sframe")
message("  inst/extdata/surveyframe_input_types_responses.csv")
