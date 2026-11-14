# data-raw/demo_stories.R
# The study each demo tells (Session 10, owner 2026-11-13 and 2026-11-14):
# a research-style purpose, the study's problem, objectives and sampling,
# a placeholder author, the question wording for its use case, and H0, H1
# and a decision rule on each inferential block, so each demo's
# pre-analysis plan shows every section. Item ids, choice codes, matrix
# rows and the simulated responses are unchanged, so no stored result
# number moves. Sourced by build_demo_library.R, which applies a story in
# write_demo() before the file is sealed.

demo_author <- "Demo author"

# A hypothesis pair and a decision rule, the shape a plan block holds.
hyp <- function(null, alternative) list(null = null, alternative = alternative)
rule_p <- "Reject H0 if p < .05, and report the effect size with its 95% confidence interval."
rule_np <- "Reject H0 if p < .05 on this rank-based test, and report the effect size with its 95% confidence interval."

obj <- function(...) {
  x <- list(...)
  lapply(seq_along(x), function(i) list(id = names(x)[i], text = x[[i]]))
}

demo_stories <- list(
  first_survey = list(
    description = "A short feedback survey for a one-day professional event, run to describe who attended and to check the quality of the answers before the programme is planned again.",
    study = list(
      problem = "The organisers plan next year's programme without knowing who attends or whether feedback forms are completed with care.",
      objectives = obj(O1 = "Describe who attended and how old they are.",
                       O2 = "Check how complete and attentive the responses are."),
      sampling = list(population = "Registered attendees of the 2025 event", method = "census", planned_n = 50L)),
    serves = c(RQ1 = "O1", RQ2 = "O1", RQ3 = "O2", RQ4 = "O2"),
    rules = c(RQ3 = "Treat a question with more than 10% missing answers as a problem to report.",
              RQ4 = "Flag a response as inattentive when it fails the quality checks, and report the count.")),

  likert_scale = list(
    description = "A thesis questionnaire measuring how well organised attendees found an event, on a 4-item Likert scale with 1 reverse-worded item.",
    study = list(
      problem = "A student's thesis needs a short scale of perceived event organisation, and the scale must hold together before its score is used.",
      objectives = obj(O1 = "Describe how organised the event felt to attendees.",
                       O2 = "Check that the organisation scale is reliable."),
      sampling = list(population = "Attendees of a regional conference", method = "convenience", planned_n = 80L)),
    serves = c(RQ1 = "O1", RQ2 = "O2", RQ3 = "O2", RQ4 = "O2"),
    rules = c(RQ2 = "Treat the scale as reliable when Cronbach's alpha is .70 or above.",
              RQ3 = "Treat the scale as reliable when omega is .70 or above.",
              RQ4 = "Review any item whose corrected item-total correlation is below .30.")),

  matrix_likert = list(
    description = "A course evaluation in which students rate each part of a course on one grid, compared across students who attended in person and online.",
    labels = c(session = "How would you rate each part of the course?",
               format = "How did you take the course?"),
    study = list(
      problem = "A teaching team wants each part of a course rated, and to know whether students who took it online judged it differently.",
      objectives = obj(O1 = "Describe how each part of the course was rated.",
                       O2 = "Compare ratings between in-person and online students."),
      sampling = list(population = "Students enrolled on the course this term", method = "census", planned_n = 60L)),
    serves = c(RQ1 = "O1", RQ2 = "O1", RQ3 = "O2"),
    rq = c(RQ1 = "How was each part of the course rated?",
           RQ2 = "How were ratings of the lectures distributed?",
           RQ3 = "Did in-person and online students rate the lectures differently?"),
    hyp = list(RQ3 = hyp("The rating of the lectures does not depend on how the course was taken.",
                         "The rating of the lectures depends on how the course was taken.")),
    rules = c(RQ3 = rule_p)),

  two_group = list(
    description = "A comparison of engagement between people who attended an event in person and those who attended online, measured by the number of sessions each attended.",
    study = list(
      problem = "Organisers are deciding whether to keep an online option, and do not know whether online attendees engage as much as those in the room.",
      objectives = obj(O1 = "Compare the number of sessions attended in person and online."),
      sampling = list(population = "Attendees of a hybrid conference", method = "convenience", planned_n = 60L)),
    serves = c(RQ1 = "O1", RQ2 = "O1"),
    rq = c(RQ2 = "Do in-person and online attendees differ in sessions attended, without assuming normality?"),
    hyp = list(RQ1 = hyp("Mean sessions attended do not differ between in-person and online attendees.",
                         "Mean sessions attended differ between in-person and online attendees."),
               RQ2 = hyp("The distribution of sessions attended is the same for both formats.",
                         "Sessions attended tend to be higher in one format.")),
    rules = c(RQ1 = rule_p, RQ2 = rule_np)),

  paired = list(
    description = "A pre and post training evaluation: participants rate their confidence, and say whether they would recommend the training, before and after it.",
    labels = c(confidence_before = "Before the training, how confident were you applying this skill? (0 to 100)",
               confidence_after = "After the training, how confident are you applying this skill? (0 to 100)",
               recommend_before = "Before the training, would you have recommended it to a colleague?",
               recommend_after = "After the training, would you recommend it to a colleague?"),
    study = list(
      problem = "A training unit needs evidence that a one-day workshop changes participants' confidence, not only that they enjoyed it.",
      objectives = obj(O1 = "Measure the change in confidence from before to after the training.",
                       O2 = "Measure the change in willingness to recommend it."),
      sampling = list(population = "Staff attending the workshop", method = "census", planned_n = 50L)),
    serves = c(RQ1 = "O1", RQ2 = "O1", RQ3 = "O2"),
    rq = c(RQ1 = "Did confidence change from before to after the training?",
           RQ2 = "Did confidence change, without assuming normality?"),
    hyp = list(RQ1 = hyp("Mean confidence is the same before and after the training.",
                         "Mean confidence differs before and after the training."),
               RQ2 = hyp("Confidence ratings are not shifted from before to after the training.",
                         "Confidence ratings are shifted from before to after the training."),
               RQ3 = hyp("The share willing to recommend is the same before and after.",
                         "The share willing to recommend differs before and after.")),
    rules = c(RQ1 = rule_p, RQ2 = rule_np, RQ3 = rule_p)),

  multi_group = list(
    description = "A comparison of engagement across 3 attendee roles, with attendance format as a second factor and age as a covariate.",
    study = list(
      problem = "Organisers suspect delegates, speakers and exhibitors engage differently, and need to know whether that holds once format and age are taken into account.",
      objectives = obj(O1 = "Compare sessions attended across the 3 roles.",
                       O2 = "Test whether format and age change that comparison."),
      sampling = list(population = "Attendees of an industry conference", method = "stratified", planned_n = 90L)),
    serves = c(RQ1 = "O1", RQ2 = "O1", RQ3 = "O2", RQ4 = "O2"),
    hyp = list(RQ1 = hyp("Mean sessions attended are equal across the 3 roles.",
                         "Mean sessions attended differ for at least 1 role."),
               RQ2 = hyp("Sessions attended have the same distribution across roles.",
                         "Sessions attended differ in distribution for at least 1 role."),
               RQ3 = hyp("Neither role, format nor their interaction affects sessions attended.",
                         "Role, format or their interaction affects sessions attended."),
               RQ4 = hyp("Adjusted for age, mean sessions attended are equal across roles.",
                         "Adjusted for age, mean sessions attended differ for at least 1 role.")),
    rules = c(RQ1 = rule_p, RQ2 = rule_np, RQ3 = rule_p, RQ4 = rule_p)),

  repeated = list(
    description = "A pre and post training evaluation over 3 days: the same participants rate each day of a training course.",
    labels = c(day1_rating = "How would you rate day 1 of the training?",
               day2_rating = "How would you rate day 2 of the training?",
               day3_rating = "How would you rate day 3 of the training?"),
    study = list(
      problem = "A 3-day training course is being redesigned, and the team needs to know whether participants' ratings change from day to day.",
      objectives = obj(O1 = "Compare ratings of the 3 days within the same participants."),
      sampling = list(population = "Participants of the 3-day course", method = "census", planned_n = 40L)),
    serves = c(RQ1 = "O1", RQ2 = "O1"),
    rq = c(RQ2 = "Did ratings change across the 3 days, without assuming normality?"),
    hyp = list(RQ1 = hyp("Mean ratings are equal on the 3 days.", "Mean ratings differ on at least 1 day."),
               RQ2 = hyp("Ratings have the same distribution on the 3 days.",
                         "Ratings differ in distribution on at least 1 day.")),
    rules = c(RQ1 = rule_p, RQ2 = rule_np)),

  categorical = list(
    description = "A study of whether attendance format is associated with the session type attendees value most.",
    study = list(
      problem = "Online and in-person attendees may value different kinds of session, which matters for how the programme is split between formats.",
      objectives = obj(O1 = "Test whether format and preferred session type are associated."),
      sampling = list(population = "Attendees of a hybrid conference", method = "convenience", planned_n = 60L)),
    serves = c(RQ1 = "O1", RQ2 = "O1", RQ3 = "O1"),
    rq = c(RQ3 = "Are format and preference associated, on an exact test for the small cell?"),
    hyp = list(RQ2 = hyp("Format and preferred session type are independent.",
                         "Format and preferred session type are associated."),
               RQ3 = hyp("Format and preferred session type are independent.",
                         "Format and preferred session type are associated.")),
    rules = c(RQ2 = rule_p, RQ3 = "Reject H0 if the exact p < .05, and report Cramer's V.")),

  correlation_regression = list(
    description = "A customer satisfaction study of what goes with the value customers get from a service, by correlation and regression.",
    labels = c(sessions_attended = "How many times did you use the service this year?",
               networking_minutes = "Roughly how many minutes did you spend with our staff?",
               overall_value = "Overall, how much value did you get from the service? (0 to 100)",
               age = "How old are you?"),
    study = list(
      problem = "A service provider wants to know which parts of a customer's experience go with the value they report, to decide where to invest.",
      objectives = obj(O1 = "Measure how use of the service relates to perceived value.",
                       O2 = "Estimate how much use and staff time together explain value."),
      sampling = list(population = "Customers who used the service in the last year", method = "simple_random", planned_n = 120L)),
    serves = c(RQ1 = "O1", RQ2 = "O1", RQ3 = "O1", RQ4 = "O1", RQ5 = "O2"),
    rq = c(RQ1 = "Do use of the service and perceived value go together?",
           RQ2 = "Do use and perceived value go together on ranks?",
           RQ3 = "Do use and perceived value go together, by Kendall's tau?"),
    hyp = list(RQ1 = hyp("Use and perceived value are not correlated.", "Use and perceived value are correlated."),
               RQ2 = hyp("Use and perceived value are not rank-correlated.", "Use and perceived value are rank-correlated."),
               RQ3 = hyp("Use and perceived value are not associated by Kendall's tau.", "Use and perceived value are associated by Kendall's tau."),
               RQ4 = hyp("Holding age constant, use and value are not correlated.", "Holding age constant, use and value are correlated."),
               RQ5 = hyp("Use and staff time explain none of the variance in value.", "Use and staff time explain some of the variance in value.")),
    rules = c(RQ1 = rule_p, RQ2 = rule_np, RQ3 = rule_np, RQ4 = rule_p, RQ5 = rule_p)),

  logistic = list(
    description = "A customer return-intention study: whether more use of a service predicts that customers return, how satisfied they are and which offer they prefer.",
    labels = c(sessions_attended = "How many times did you use the service this year?",
               will_return = "Will you use the service again next year?",
               satisfaction = "I was satisfied with the service.",
               preferred_session_type = "Which of our offers do you value most?"),
    study = list(
      problem = "A provider wants to know whether customers who use a service more are the ones who come back.",
      objectives = obj(O1 = "Test whether use predicts returning.",
                       O2 = "Test whether use predicts satisfaction and the offer preferred."),
      sampling = list(population = "Customers who used the service in the last year", method = "simple_random", planned_n = 150L)),
    serves = c(RQ1 = "O1", RQ2 = "O2", RQ3 = "O2"),
    rq = c(RQ1 = "Does using the service more predict returning?"),
    hyp = list(RQ1 = hyp("Use does not change the odds of returning.", "Use changes the odds of returning."),
               RQ2 = hyp("Use does not change the odds of a higher satisfaction rating.", "Use changes the odds of a higher satisfaction rating."),
               RQ3 = hyp("Use does not change which offer is preferred.", "Use changes which offer is preferred.")),
    rules = c(RQ1 = "Reject H0 if p < .05 for the use coefficient, and report its odds ratio with a 95% confidence interval.",
              RQ2 = "Reject H0 if p < .05 for the use coefficient, and report its odds ratio with a 95% confidence interval.",
              RQ3 = "Reject H0 if the likelihood-ratio test of use has p < .05.")),

  factor_structure = list(
    description = "An employee engagement survey of 8 items, written to measure 2 things employees judge: how their work is organised, and the content of their work.",
    labels = c(org_1 = "My work is planned well in advance.",
               org_2 = "I know where to find what I need to do my job.",
               org_3 = "My manager helps when I have a question.",
               org_4 = "My workplace suits the work I do.",
               con_1 = "My work is relevant to my goals.",
               con_2 = "My work challenges me enough.",
               con_3 = "The people I work with know their subject.",
               con_4 = "The tools I am given are useful."),
    study = list(
      problem = "An organisation's engagement survey assumes 2 dimensions, and it needs to check that its employees' answers support that before reporting 2 scores.",
      objectives = obj(O1 = "Check that the data are suitable for factor analysis.",
                       O2 = "Find how many factors the items form, and which items load where."),
      sampling = list(population = "Employees of one organisation", method = "census", planned_n = 200L)),
    serves = c(RQ1 = "O1", RQ2 = "O2"),
    rules = c(RQ1 = "Proceed when KMO is .60 or above and Bartlett's test has p < .05.",
              RQ2 = "Retain the factors parallel analysis supports, and read loadings of .40 or above.")),

  sem_pls = list(
    description = "A measurement and structural model study: whether the quality of a programme's content builds satisfaction, and satisfaction the intention to return.",
    study = list(
      problem = "A provider believes content quality drives return intention through satisfaction, and needs the measurement and the structural paths tested together.",
      objectives = obj(O1 = "Specify the measurement model for the 3 constructs.",
                       O2 = "Estimate the paths from content quality through satisfaction to intention."),
      sampling = list(population = "Attendees of a professional programme", method = "convenience", planned_n = 150L)),
    serves = c(RQ1 = "O1", RQ2 = "O1", RQ3 = "O2", RQ4 = "O1", RQ5 = "O2", RQ6 = "O2"),
    hyp = list(RQ1 = hyp("The declared model reproduces the observed covariances.",
                         "The declared model does not reproduce the observed covariances."),
               RQ3 = hyp("Satisfaction does not carry the effect of content quality to intention.",
                         "Satisfaction carries part of the effect of content quality to intention."),
               RQ6 = hyp("The effect of content quality on intention does not depend on the moderator.",
                         "The effect of content quality on intention depends on the moderator.")),
    rules = c(RQ1 = "Judge the model's fit as acceptable when CFI is .95 or above and RMSEA is .06 or below.",
              RQ3 = "Treat the indirect effect as present when its 95% bootstrap confidence interval excludes 0.",
              RQ5 = "Report a path as supported when its bootstrap confidence interval excludes 0.",
              RQ6 = rule_p)),

  branching = list(
    description = "A survey with skip logic, asking about sessions only of those who attended them, to separate a skipped question from a missing answer.",
    study = list(
      problem = "Exhibitors and day visitors do not attend sessions, so asking them about sessions gives answers that mean nothing.",
      objectives = obj(O1 = "Describe who attended, and the sessions of those who were asked."),
      sampling = list(population = "Everyone admitted to the event", method = "census", planned_n = 60L)),
    serves = c(RQ1 = "O1", RQ2 = "O1")),

  open_text = list(
    description = "An open-ended feedback study: what attendees say worked and what to change, analysed as text.",
    study = list(
      problem = "Rating questions tell organisers how much attendees liked the event, not why. The open answers hold the reasons.",
      objectives = obj(O1 = "Describe the words and topics in what worked and what to change.",
                       O2 = "Compare what in-person and online attendees write."),
      sampling = list(population = "Attendees of a hybrid conference", method = "convenience", planned_n = 80L)),
    serves = c(RQ1 = "O1", RQ2 = "O1", RQ3 = "O1", RQ4 = "O1", RQ5 = "O2", RQ6 = "O1",
               RQ7 = "O1", RQ8 = "O1", RQ9 = "O1", RQ10 = "O1")),

  mcdm_choice = list(
    description = "A decision study choosing next year's venue from candidate venues, weighting the criteria and ranking the venues by 10 methods.",
    study = list(
      problem = "The organising committee must choose a venue on several criteria at once, and needs a defensible ranking rather than a vote.",
      objectives = obj(O1 = "Weight the decision criteria.",
                       O2 = "Rank the venues, and check whether the methods agree."),
      sampling = list(population = "Members of the organising committee", method = "purposive", planned_n = 10L)),
    serves = c(RQ1 = "O1", RQ2 = "O1", RQ3 = "O1", RQ4 = "O2", RQ5 = "O2", RQ6 = "O2",
               RQ7 = "O2", RQ8 = "O2", RQ9 = "O2", RQ10 = "O2"),
    rules = c(RQ1 = "Accept the pairwise judgements when the consistency ratio is below .10.")),

  small_sample = list(
    description = "A pilot study with 18 participants, answering the main study's questions with methods suited to a small sample.",
    study = list(
      problem = "Before a full study, a pilot must show whether the main comparisons are worth testing, with too few people for large-sample methods.",
      objectives = obj(O1 = "Compare the 2 formats on sessions attended.",
                       O2 = "Test whether format and sessions attended relate to returning."),
      sampling = list(population = "Attendees of a pilot event", method = "convenience", planned_n = 18L)),
    serves = c(RQ1 = "O1", RQ2 = "O2", RQ3 = "O2"),
    hyp = list(RQ1 = hyp("Sessions attended have the same distribution in both formats.",
                         "Sessions attended tend to be higher in one format."),
               RQ2 = hyp("Format and returning are independent.", "Format and returning are associated."),
               RQ3 = hyp("Sessions attended do not change the odds of returning.",
                         "Sessions attended change the odds of returning.")),
    rules = c(RQ1 = rule_np, RQ2 = "Reject H0 if the exact p < .05.",
              RQ3 = "Reject H0 if the penalised likelihood p < .05, and report the odds ratio with its 95% confidence interval.")),

  multi_response = list(
    description = "A study of which sessions attendees chose and why they came, from a choose-any item and a ranking.",
    study = list(
      problem = "Organisers need to know which sessions drew people and which reasons for coming matter most.",
      objectives = obj(O1 = "Describe which sessions were chosen and the reasons ranked first.",
                       O2 = "Test whether the sessions differ in how often they were chosen."),
      sampling = list(population = "Attendees of a one-day event", method = "convenience", planned_n = 60L)),
    serves = c(RQ1 = "O1", RQ2 = "O2", RQ3 = "O1"),
    hyp = list(RQ2 = hyp("Every session is chosen equally often.", "At least 1 session is chosen more or less often.")),
    rules = c(RQ2 = rule_p)),

  branded_survey = list(
    description = "The event feedback survey with the organiser's welcome page, logo, colour and thank-you page.",
    study = list(
      problem = "Respondents trust and finish a survey that shows who is asking, so the event's feedback form carries its brand.",
      objectives = obj(O1 = "Describe who attended."),
      sampling = list(population = "Registered attendees of the 2025 event", method = "census", planned_n = 50L)),
    serves = c(RQ1 = "O1")),

  conversational_survey = list(
    description = "The event feedback survey shown one question at a time, for respondents on a phone.",
    study = list(
      problem = "Many attendees answer on a phone, where a long page of questions is easy to abandon.",
      objectives = obj(O1 = "Describe who attended."),
      sampling = list(population = "Registered attendees of the 2025 event", method = "census", planned_n = 50L)),
    serves = c(RQ1 = "O1")),

  conversational_branching = list(
    description = "The skip-logic survey shown one question at a time, so each respondent sees only the questions that apply to them.",
    study = list(
      problem = "Shown one at a time, skipped questions must not appear at all, or respondents meet questions that do not apply.",
      objectives = obj(O1 = "Describe who attended."),
      sampling = list(population = "Everyone admitted to the event", method = "census", planned_n = 60L)),
    serves = c(RQ1 = "O1")),

  weighted_survey = list(
    description = "A resident satisfaction survey whose sample over-represents 1 region, weighted back to the population's regional shares.",
    study = list(
      problem = "An online sample drew most of its answers from the north, so unweighted figures would overstate the north's view of the service.",
      objectives = obj(O1 = "Describe the sample and the population across regions.",
                       O2 = "Estimate satisfaction and its link with region for the population."),
      sampling = list(population = "Adult residents of the 3 regions", method = "quota", planned_n = 120L)),
    serves = c(RQ1 = "O1", RQ2 = "O1", RQ3 = "O2", RQ4 = "O2"),
    hyp = list(RQ4 = hyp("Weighted to the population, region and recommending are independent.",
                         "Weighted to the population, region and recommending are associated.")),
    rules = c(RQ4 = rule_p)),

  citing_sources = list(
    description = "A study of trust in a new team leader, measured with items adapted from a published model of trust, with each source cited where it is used.",
    study = list(
      problem = "Teams with a new leader report low trust, and the organisation needs a short measure grounded in an established model of trust.",
      objectives = obj(O1 = "Measure trust in the new leader and check the scale.",
                       O2 = "Compare newer and longer-serving team members."),
      sampling = list(population = "Members of teams with a leader appointed this year", method = "cluster", planned_n = 90L)),
    serves = c(RQ1 = "O1", RQ2 = "O1", RQ3 = "O2"),
    hyp = list(RQ3 = hyp("Mean trust does not differ between newer and longer-serving members.",
                         "Mean trust differs between newer and longer-serving members.")),
    rules = c(RQ2 = "Treat the scale as reliable when Cronbach's alpha is .70 or above [@cronbach_1951].",
              RQ3 = rule_p)),

  mediation_moderation = list(
    description = "An employee wellbeing study of whether stress carries the effect of workload to wellbeing, and whether a manager's support weakens the link from workload to stress.",
    study = list(
      problem = "Heavy workloads are linked to poor wellbeing, and an organisation needs to know whether stress is the route and whether managers can soften it.",
      objectives = obj(O1 = "Test whether stress mediates the effect of workload on wellbeing.",
                       O2 = "Test whether manager support moderates the effect of workload on stress."),
      sampling = list(population = "Employees of 1 organisation", method = "simple_random", planned_n = 200L)),
    serves = c(RQ1 = "O1", RQ2 = "O2"),
    hyp = list(RQ1 = hyp("Stress does not carry the effect of workload to wellbeing.",
                         "Stress carries part of the effect of workload to wellbeing."),
               RQ2 = hyp("The effect of workload on stress does not depend on manager support.",
                         "The effect of workload on stress depends on manager support.")),
    rules = c(RQ1 = "Treat the indirect effect as present when its 95% bootstrap confidence interval excludes 0.",
              RQ2 = "Reject H0 if p < .05 for the interaction term, and report the simple slopes.")),

  # instrument_revision is first_survey amended, so it takes first_survey's
  # story before the amendment and has none of its own.
  verification = NULL
)
demo_stories$verification <- demo_stories$first_survey

# Applies a demo's story to its instrument. NULL leaves it as it is.
apply_story <- function(instrument, story) {
  if (is.null(story)) return(instrument)
  instrument$meta$authors <- demo_author
  if (!is.null(story$description)) instrument$meta$description <- story$description
  if (!is.null(story$study)) instrument$study <- story$study
  for (id in names(story$labels)) {
    k <- which(vapply(instrument$items, function(it) identical(it$id, id), logical(1)))
    stopifnot(length(k) == 1)
    instrument$items[[k]]$label <- story$labels[[id]]
  }
  ids <- vapply(instrument$analysis_plan, function(b) b$id, character(1))
  set <- function(field, values) {
    for (id in names(values)) {
      k <- match(id, ids)
      stopifnot(!is.na(k))
      instrument$analysis_plan[[k]][[field]] <<- values[[id]]
    }
  }
  set("objective", story$serves)
  set("research_question", story$rq)
  set("hypotheses", story$hyp)
  set("decision_rule", story$rules)
  instrument
}
