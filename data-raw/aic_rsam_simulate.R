# data-raw/aic_rsam_simulate.R
# Simulates a plausible AIC-RSAM response set for v0.3.3 report and analysis
# checks (dev branch only). 200 eligible completes plus 20 screened-out
# partial rows, matching what the deployed survey and the Google Sheets
# collector actually produce (empty strings for unanswered hidden items).
# Output: data-raw/aic_rsam_responses.csv
# Run from the package root. Requires lavaan (Suggests) for simulateData.

devtools::load_all(".", quiet = TRUE)
rlang::check_installed("lavaan")
set.seed(20260708)

n_ok  <- 200L
n_out <- 20L

pop <- '
aia =~ 0.75*aia_1 + 0.72*aia_2 + 0.70*aia_3 + 0.74*aia_4
poa =~ 0.75*poa_1 + 0.73*poa_2 + 0.71*poa_3 + 0.72*poa_4
peou =~ 0.76*peou_1 + 0.74*peou_2 + 0.72*peou_3 + 0.75*peou_4
pu =~ 0.75*pu_1 + 0.73*pu_2 + 0.72*pu_3 + 0.74*pu_4
pr =~ 0.74*pr_1 + 0.72*pr_2 + 0.70*pr_3 + 0.73*pr_4
bi =~ 0.77*bi_1 + 0.75*bi_2 + 0.74*bi_3 + 0.76*bi_4
peou ~ 0.5*aia
poa ~ 0.5*aia
pu ~ 0.25*aia + 0.3*peou + 0.3*poa
bi ~ 0.2*peou + 0.2*poa + 0.35*pu + (-0.2)*pr
'
latent <- lavaan::simulateData(pop, sample.nobs = n_ok)
likert <- as.data.frame(lapply(latent, function(v) {
  as.integer(pmin(5, pmax(1, round(3 + v))))
}))

pick <- function(values, n, prob = NULL) {
  sample(values, n, replace = TRUE, prob = prob)
}

ok <- data.frame(
  respondent_id      = sprintf("R%03d", seq_len(n_ok)),
  started_at         = format(as.POSIXct("2026-07-01 09:00:00", tz = "UTC")
                              + cumsum(sample(60:900, n_ok, TRUE)),
                              "%Y-%m-%dT%H:%M:%SZ"),
  elig_age           = "yes",
  elig_nationality   = "yes",
  elig_resort_stay   = "yes",
  elig_stay_duration = pick(c("2_nights", "3_4_nights", "5_plus"), n_ok,
                            c(0.35, 0.45, 0.20)),
  elig_room_service  = pick(c("yes", "no"), n_ok, c(0.7, 0.3)),
  elig_smartphone    = pick(c("yes", "no"), n_ok, c(0.93, 0.07)),
  prof_mode_first    = pick(c("quick_book", "conv_book"), n_ok, c(0.55, 0.45)),
  prof_tried_other   = pick(c("yes", "no"), n_ok, c(0.6, 0.4)),
  prof_app_frequency = pick(c("never", "rarely", "sometimes", "often",
                              "very_often"), n_ok,
                            c(0.05, 0.15, 0.30, 0.30, 0.20)),
  prof_chatbot_prior = pick(c("yes", "no"), n_ok, c(0.55, 0.45)),
  prof_age_group     = pick(c("18_24", "25_34", "35_44", "45_plus"), n_ok,
                            c(0.25, 0.40, 0.22, 0.13)),
  prof_gender        = pick(c("male", "female", "prefer_not", "other"), n_ok,
                            c(0.48, 0.47, 0.04, 0.01)),
  stringsAsFactors   = FALSE
)
ok$elig_rs_times <- ifelse(
  ok$elig_room_service == "yes",
  pick(c("1_time", "2_3_times", "4_plus"), n_ok, c(0.35, 0.45, 0.20)),
  ""
)
ok <- cbind(ok, likert)
for (i in 1:6) {
  ok[[paste0("fe_", i)]] <- as.integer(pick(1:5, n_ok,
                                            c(0.03, 0.07, 0.2, 0.4, 0.3)))
}
liked <- c("Quick Book was fast", "The chat guidance was helpful",
           "Simple and clear steps", "The confirmation screen",
           "Menu search worked well", "")
improve <- c("Add pictures of dishes", "Faster loading", "More payment options",
             "Let me switch modes mid-order", "Nothing to add", "")
ok$od_1 <- pick(liked, n_ok)
ok$od_2 <- pick(improve, n_ok)

# Screened-out rows: fail one of the four gates, main questionnaire blank
gate_fail <- pick(1:4, n_out)
out <- data.frame(
  respondent_id      = sprintf("X%03d", seq_len(n_out)),
  started_at         = format(as.POSIXct("2026-07-01 08:00:00", tz = "UTC")
                              + cumsum(sample(60:900, n_out, TRUE)),
                              "%Y-%m-%dT%H:%M:%SZ"),
  elig_age           = ifelse(gate_fail == 1, "no", "yes"),
  elig_nationality   = ifelse(gate_fail == 1, "",
                        ifelse(gate_fail == 2, "no", "yes")),
  elig_resort_stay   = ifelse(gate_fail <= 2, "",
                        ifelse(gate_fail == 3, "no", "yes")),
  elig_stay_duration = ifelse(gate_fail <= 3, "", "1_night"),
  stringsAsFactors   = FALSE
)
for (col in setdiff(names(ok), names(out))) out[[col]] <- ""

dat <- rbind(ok, out[names(ok)])
dat$submitted_at <- format(as.POSIXct(dat$started_at,
                                      format = "%Y-%m-%dT%H:%M:%SZ",
                                      tz = "UTC")
                           + sample(240:900, nrow(dat), TRUE),
                           "%Y-%m-%dT%H:%M:%SZ")
dat <- dat[order(dat$submitted_at), ]

out_path <- file.path("data-raw", "aic_rsam_responses.csv")
utils::write.csv(dat, out_path, row.names = FALSE, na = "")
message("Simulated responses written to ", out_path,
        " (", nrow(dat), " rows).")
