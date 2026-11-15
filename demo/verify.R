# This guided tour shows how an integrity hash detects a changed instrument.
# Both the sealed file and the changed copy stay in R's temporary folder.

step <- function(msg) if (interactive()) invisible(readline(paste0("\n", msg, " Press <Return>: ")))

step("Stage 1 of 4, seal: write the demo instrument with its integrity hash.")
study <- sframe_demo("two_group", preview = FALSE)
sealed_path <- file.path(tempdir(), "surveyframe-verify-sealed.sframe")
write_sframe(study$instrument, sealed_path, overwrite = TRUE)

step("Stage 2 of 4, verify: read the sealed instrument and check its hash.")
verified <- read_sframe(sealed_path)
print(verified)

step("Stage 3 of 4, change: edit 1 question in a plain-text copy.")
changed_path <- file.path(tempdir(), "surveyframe-verify-changed.sframe")
payload <- readLines(sealed_path, warn = FALSE)
payload <- sub("How many sessions did you attend?", "How many sessions did you join?", payload, fixed = TRUE)
writeLines(payload, changed_path, useBytes = TRUE)

step("Stage 4 of 4, catch: read the changed copy and inspect the integrity message.")
message <- tryCatch(
  {
    read_sframe(changed_path)
    "The changed copy passed its integrity check unexpectedly."
  },
  error = conditionMessage
)
cat(message, "\n")
cat("Verify a .sframe file at https://surveyframe.org/verify\n")
