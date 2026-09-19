# tests/testthat/test-demo-results-parity.R
#
# Batch 5, finding 15. Every demo ships <demo>_results.csv, the numbers
# surveyframe produced, so a reader can check them in other software. Nothing
# compared those snapshots with what the package computes, so a corrected
# statistic left a stale reference result shipping beside it.
#
# Slow, since it runs every demo's plan, so skipped on CRAN. A block whose
# method needs an optional package absent here is skipped, as the generator
# skips it.

skip_on_cran()

test_that("15: every shipped demo result matches what the package computes now", {
  dir <- sframe_demo_dir()
  idx <- sframe_demo_index()
  mismatches <- character(0)
  for (name in idx$name) {
    shipped_path <- file.path(dir, paste0(name, "_results.csv"))
    if (!file.exists(shipped_path)) next
    shipped <- utils::read.csv(shipped_path, colClasses = "character",
                               na.strings = "", check.names = FALSE)
    demo <- suppressWarnings(sframe_demo(name))
    res <- suppressWarnings(run_analysis_plan(demo$responses, demo$instrument))
    now <- sframe_demo_results_table(res)
    now$value <- as.character(now$value)
    absent <- vapply(res, function(b) !is.null(b$error) &&
      grepl("install|not installed|requires the|cannot be loaded|is required",
            b$error, ignore.case = TRUE), logical(1))
    skip_blocks <- names(res)[absent]
    key <- function(d) paste(d$block, d$quantity, sep = " | ")
    s <- shipped[!shipped$block %in% skip_blocks, ]
    n <- now[!now$block %in% skip_blocks, ]
    diff_keys <- union(setdiff(key(s), key(n)), setdiff(key(n), key(s)))
    both <- intersect(key(s), key(n))
    changed <- both[s$value[match(both, key(s))] != n$value[match(both, key(n))] |
                      xor(is.na(s$value[match(both, key(s))]), is.na(n$value[match(both, key(n))]))]
    changed <- changed[!is.na(changed)]
    for (k in c(diff_keys, changed)) {
      mismatches <- c(mismatches, sprintf("%s: %s | shipped %s | now %s", name, k,
        s$value[match(k, key(s))], n$value[match(k, key(n))]))
    }
  }
  expect_identical(mismatches, character(0))
})
