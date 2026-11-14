# data-raw/reference_demo_status.R
# The 2 reference datasets' responses are marked as demonstration data, as
# the teaching demos' are (owner 2026-11-05): DEMO- respondent ids and a
# data_status column. Edited as text, so every other byte stays. Running it
# again changes nothing.
#
# Run from the repository root:  Rscript data-raw/reference_demo_status.R

status <- "Demonstration data, not collected from participants"
for (f in c("tourism_services_responses.csv", "surveyframe_input_types_responses.csv")) {
  path <- file.path("inst", "extdata", f)
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  if (grepl("\"data_status\"", lines[1], fixed = TRUE)) next
  lines[1] <- paste0(lines[1], ",\"data_status\"")
  body <- lines[-1]
  body <- sub("^\"R([0-9]+)\"", "\"DEMO-\\1\"", body)
  lines[-1] <- paste0(body, ",\"", status, "\"")
  writeLines(lines, path, useBytes = TRUE)
  cat(f, "marked\n")
}
