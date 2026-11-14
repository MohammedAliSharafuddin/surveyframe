# data-raw/input_types_comparison_items.R
# The all-types demo holds all 13 answerable types (owner 2026-11-05,
# Session 10): it gains a pairwise comparison on the Saaty scale, 1 on the
# influence scale and a criteria weight, over 3 features of a visit, with
# seeded answers appended to its responses file. The existing columns and
# their bytes are kept, so nothing already in the data changes. Running it
# again changes nothing. Run it before reference_demo_stories.R.
#
# Run from the repository root:  Rscript data-raw/input_types_comparison_items.R

devtools::load_all(quiet = TRUE)

ins_path <- file.path("inst", "extdata", "surveyframe_input_types_demo.sframe")
csv_path <- file.path("inst", "extdata", "surveyframe_input_types_responses.csv")
ins <- read_sframe(ins_path)
ids <- vapply(ins$items, function(it) it$id, character(1))
if ("feature_pairs" %in% ids) {
  cat("The comparison items are already in place.\n")
  quit(save = "no")
}
attr(ins, "sframe_origin") <- NULL

features <- c("price", "location", "service")
new_items <- list(
  sframe_item("feature_pairs", "Which of each pair matters more to you when choosing where to stay, and by how much?",
              type = "pairwise_comparison", comparison_items = features,
              comparison_scale = "saaty", required = FALSE),
  sframe_item("feature_points", "Divide 100 points across price, location and service by how much each matters to you.",
              type = "criteria_weight", comparison_items = features, required = FALSE),
  sframe_item("feature_influence", "How strongly does each of these influence the others for you?",
              type = "pairwise_comparison", comparison_items = features,
              comparison_scale = "influence", required = FALSE))
at <- match("feature_ranking", ids)
ins$items <- append(ins$items, new_items, after = at)

# Seeded answers. Price matters most, then location, then service.
set.seed(4113)
lines <- readLines(csv_path, warn = FALSE, encoding = "UTF-8")
n <- length(lines) - 1L
true_w <- c(price = 0.5, location = 0.3, service = 0.2)
saaty_signed <- function(ratio) {
  if (ratio >= 1) max(1, min(9, round(ratio))) else -max(2, min(9, round(1 / ratio)))
}
cols <- list()
pc <- sframe_comparison_columns(new_items[[1]])
pairs <- sframe_comparison_pairs(features, "saaty")
for (k in seq_len(nrow(pairs))) {
  r <- true_w[[pairs$a[k]]] / true_w[[pairs$b[k]]]
  cols[[pc[k]]] <- vapply(seq_len(n), function(i) saaty_signed(r * exp(stats::rnorm(1, 0, 0.18))), numeric(1))
}
pts <- t(vapply(seq_len(n), function(i) {
  raw <- pmax(5, round(true_w * 100 + stats::rnorm(3, 0, 6)))
  raw <- round(raw / sum(raw) * 100)
  raw[3] <- 100 - sum(raw[1:2])
  raw
}, numeric(3)))
for (j in seq_along(features)) cols[[paste0("feature_points__", features[j])]] <- pts[, j]
ic <- sframe_comparison_columns(new_items[[3]])
ipairs <- sframe_comparison_pairs(features, "influence")
true_infl <- matrix(c(0, 2, 3,  1, 0, 2,  1, 1, 0), nrow = 3, byrow = TRUE,
                    dimnames = list(features, features))
for (k in seq_len(nrow(ipairs))) {
  cols[[ic[k]]] <- pmax(0, pmin(4, round(true_infl[ipairs$a[k], ipairs$b[k]] + stats::rnorm(n, 0, 0.5))))
}

header <- paste0(lines[1], ",", paste0("\"", names(cols), "\"", collapse = ","))
body <- vapply(seq_len(n), function(i) {
  paste0(lines[i + 1L], ",", paste(vapply(cols, function(v) format(v[i], scientific = FALSE), character(1)),
                                   collapse = ","))
}, character(1))
writeLines(c(header, body), csv_path, useBytes = TRUE)
write_sframe(ins, ins_path, overwrite = TRUE)
cat("Added", length(new_items), "items and", length(cols), "columns.\n")
