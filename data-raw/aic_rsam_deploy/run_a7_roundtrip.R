# data-raw/aic_rsam_deploy/run_a7_roundtrip.R
# A7: live Google Sheets round trip for the AIC-RSAM instrument.
# Usage (from the package root, after the Apps Script Web App is deployed):
#   Rscript data-raw/aic_rsam_deploy/run_a7_roundtrip.R <web_app_url> <sheet_url>
# Submits three test responses through the exported survey in headless
# Chrome (one eligible complete, one screen-out at E1, one screen-out at E4),
# then reads the sheet back with read_sheet_responses() using public
# link-read access and validates the result against the instrument.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) stop("Usage: run_a7_roundtrip.R <web_app_url> <sheet_url>")
endpoint  <- args[[1]]
sheet_url <- args[[2]]

devtools::load_all(".", quiet = TRUE)
library(chromote)

x <- read_sframe("tests/testthat/fixtures/aic_rsam_pilot.sframe")
out <- file.path(tempdir(), "aic_rsam_live.html")
export_static_survey(x, output_path = out, open = FALSE,
                     endpoint_url = endpoint, overwrite = TRUE)

open_page <- function(file) {
  b <- ChromoteSession$new()
  b$default_timeout <- 60
  b$Page$navigate(paste0("file://", normalizePath(file)))
  for (i in 1:50) {
    rs <- tryCatch(
      b$Runtime$evaluate("document.readyState", returnByValue = TRUE)$result$value,
      error = function(e) NULL)
    if (identical(rs, "complete")) break
    Sys.sleep(0.2)
  }
  b
}
js <- function(b, code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
answer <- function(b, id, value) {
  ok <- js(b, sprintf(
    "(function(){var el=document.querySelector('input[name=\"%s\"][value=\"%s\"]');
      if(!el)return false; el.click(); return true;})()", id, value))
  if (!isTRUE(ok)) stop("could not answer ", id)
}
start_survey <- function(b) {
  js(b, "document.getElementById('consent-chk').click();
         document.querySelector('.btn.btn-p.btn-lg').click(); true")
  Sys.sleep(0.2)
}
submit <- function(b) {
  js(b, "nextPage();")
  Sys.sleep(3)  # allow the fetch() POST to reach Apps Script
  scr <- js(b, "screen")
  rid <- js(b, "respId")
  cat("submitted, screen =", scr, "respondent =", rid, "\n")
  rid
}

ids <- character(0)

# Respondent 1: eligible, answers everything
b <- open_page(out); start_survey(b)
for (a in list(c("elig_age","yes"), c("elig_nationality","yes"),
               c("elig_resort_stay","yes"), c("elig_stay_duration","3_4_nights"),
               c("elig_room_service","yes"), c("elig_rs_times","2_3_times"),
               c("elig_smartphone","yes"),
               c("prof_mode_first","quick_book"), c("prof_tried_other","yes"),
               c("prof_app_frequency","often"), c("prof_chatbot_prior","yes"),
               c("prof_age_group","25_34"), c("prof_gender","male"))) {
  answer(b, a[1], a[2])
}
for (con in c("aia", "poa", "peou", "pu", "pr", "bi")) {
  for (i in 1:4) answer(b, paste0(con, "_", i), sample(2:5, 1))
}
for (i in 1:6) answer(b, paste0("fe_", i), sample(3:5, 1))
js(b, "setResp('od_1','Live round trip test response')")
js(b, "setResp('od_2','No changes needed')")
ids <- c(ids, submit(b)); b$close()

# Respondent 2: screened out at E1
b <- open_page(out); start_survey(b)
answer(b, "elig_age", "no")
ids <- c(ids, submit(b)); b$close()

# Respondent 3: screened out at E4 (1 night)
b <- open_page(out); start_survey(b)
for (a in list(c("elig_age","yes"), c("elig_nationality","yes"),
               c("elig_resort_stay","yes"), c("elig_stay_duration","1_night"))) {
  answer(b, a[1], a[2])
}
ids <- c(ids, submit(b)); b$close()

cat("\nWaiting 10s for Apps Script to append rows...\n")
Sys.sleep(10)

# Read back via read_sheet_responses() with public link access
googlesheets4::gs4_deauth()
resp <- read_sheet_responses(sheet_url, x)
cat("\nread_sheet_responses returned", nrow(resp), "rows,",
    ncol(resp), "columns\n")
print(resp[, c("respondent_id", "elig_age", "elig_stay_duration",
               "aia_1", "bi_4", "od_1")])

found <- ids %in% resp$respondent_id
cat("\nsubmitted respondents found in sheet:",
    paste(ids, found, collapse = ", "), "\n")
if (!all(found)) stop("Round trip FAILED: not all submissions reached the sheet")

# Validate the eligible respondent scores through the pipeline
qr <- quality_report(resp, x, respondent_id = "respondent_id")
cat("quality_report ran:", !is.null(qr), "\n")
cat("\nA7 round trip PASSED\n")
