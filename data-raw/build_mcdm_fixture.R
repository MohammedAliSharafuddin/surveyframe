# data-raw/build_mcdm_fixture.R
# Regenerates the section 1g worked example (hotel supplier selection) and its
# simulated responses into inst/extdata, so the tests and the MCDM vignette
# read one fixture rather than each rebuilding it.
#
# Dev-only, tracked on the dev branch. data-raw/ is gitignored on main and on
# the release branch, the same arrangement inline_static_template.R uses.

devtools::load_all(quiet = TRUE)
set.seed(2026)

crits   <- c("service", "location", "price", "delivery")
vendors <- c("Alpha", "Basilica", "Coral", "Dhoni", "Equator")

components <- list(
  sf_item("crit_pairs", "Compare the importance of each pair of criteria",
          type = "pairwise_comparison", comparison_items = crits,
          comparison_scale = "saaty", required = TRUE),

  sf_item("crit_points", "Divide 100 points across the criteria",
          type = "criteria_weight", comparison_items = crits, required = TRUE),

  sf_choices("q5", values = 1:5,
             labels = c("Very poor", "Poor", "Fair", "Good", "Excellent")),
  sf_item("rate_service",  "Rate each supplier: service quality",
          type = "matrix", matrix_items = vendors, choice_set = "q5"),
  sf_item("rate_location", "Rate each supplier: location",
          type = "matrix", matrix_items = vendors, choice_set = "q5"),
  sf_item("rate_price",    "Rate each supplier: value for money",
          type = "matrix", matrix_items = vendors, choice_set = "q5"),
  sf_item("rate_delivery", "Rate each supplier: delivery speed",
          type = "matrix", matrix_items = vendors, choice_set = "q5"),

  sf_item("crit_influence", "How strongly does each factor influence the others?",
          type = "pairwise_comparison", comparison_items = crits,
          comparison_scale = "influence", required = TRUE)
)

study <- sf_instrument(
  title       = "Hotel supplier selection",
  version     = "1.0.0",
  description = "Worked MCDM example: 5 suppliers judged on 4 criteria.",
  components  = components,
  analysis_plan = list(
    list(id = "RQ1",
         research_question = "What weight does each criterion carry?",
         family = "decision", method = "ahp",
         roles = list(pairwise = "crit_pairs"),
         options = list(cr_filter = FALSE)),
    list(id = "RQ2",
         research_question = "Which supplier ranks best on the audited figures?",
         family = "decision", method = "topsis",
         roles = list(weights_item = "crit_pairs"),
         options = list(
           matrix = list(c(4.1, 3.0, 210, 36),
                         c(3.6, 4.5, 180, 48),
                         c(4.8, 2.5, 260, 24),
                         c(3.9, 4.0, 150, 72),
                         c(4.4, 3.8, 230, 30)),
           alternatives   = vendors,
           criteria       = crits,
           criteria_types = c("benefit", "benefit", "cost", "cost"))),
    list(id = "RQ3",
         research_question = "Which supplier do staff rate best overall?",
         family = "decision", method = "topsis",
         roles = list(performance_items = c("rate_service", "rate_location",
                                            "rate_price", "rate_delivery"),
                      weights_item = "crit_points"),
         options = list(criteria_types = c("benefit", "benefit",
                                           "benefit", "benefit"))),
    list(id = "RQ4",
         research_question = "Which criteria drive the others?",
         family = "decision", method = "dematel",
         roles = list(pairwise = "crit_influence"))
  )
)

# ---- simulated responses ---------------------------------------------------
n <- 12
true_w <- c(service = 0.40, location = 0.25, price = 0.20, delivery = 0.15)

pair_cols <- sframe_comparison_columns(
  Filter(function(i) identical(i$id, "crit_pairs"), study$items)[[1]]
)
pairs <- sframe_comparison_pairs(crits, "saaty")

# Saaty judgements drawn around the true ratio, then encoded as the signed
# integers the export contract stores (never a fraction).
saaty_signed <- function(ratio) {
  if (ratio >= 1) {
    max(1, min(9, round(ratio)))
  } else {
    -max(2, min(9, round(1 / ratio)))
  }
}

resp <- data.frame(respondent_id = sprintf("r%02d", seq_len(n)),
                   stringsAsFactors = FALSE)

for (k in seq_len(nrow(pairs))) {
  r <- true_w[[pairs$a[k]]] / true_w[[pairs$b[k]]]
  vals <- vapply(seq_len(n), function(i) {
    saaty_signed(r * exp(stats::rnorm(1, 0, 0.18)))
  }, numeric(1))
  resp[[pair_cols[k]]] <- vals
}

# constant-sum weights, jittered around the true weights and forced to 100
cw_cols <- paste0("crit_points__", crits)
for (i in seq_len(n)) {
  raw <- pmax(5, round(true_w * 100 + stats::rnorm(4, 0, 6)))
  raw <- round(raw / sum(raw) * 100)
  raw[4] <- 100 - sum(raw[1:3])
  for (j in seq_along(crits)) resp[i, cw_cols[j]] <- raw[j]
}

# rated performance, one matrix item per criterion, higher is better on all 4
vendor_quality <- list(
  service  = c(Alpha = 4.1, Basilica = 3.6, Coral = 4.8, Dhoni = 3.9, Equator = 4.4),
  location = c(Alpha = 3.0, Basilica = 4.5, Coral = 2.5, Dhoni = 4.0, Equator = 3.8),
  price    = c(Alpha = 3.4, Basilica = 4.0, Coral = 2.6, Dhoni = 4.6, Equator = 3.0),
  delivery = c(Alpha = 3.5, Basilica = 2.8, Coral = 4.6, Dhoni = 2.2, Equator = 4.0)
)
for (cr in crits) {
  for (v in vendors) {
    col <- paste0("rate_", cr, "__", v)
    resp[[col]] <- pmax(1, pmin(5, round(
      vendor_quality[[cr]][[v]] + stats::rnorm(n, 0, 0.55)
    )))
  }
}

# directed influence, 0 to 4, no diagonal because ordered pairs exclude self
infl_cols <- sframe_comparison_columns(
  Filter(function(i) identical(i$id, "crit_influence"), study$items)[[1]]
)
infl_pairs <- sframe_comparison_pairs(crits, "influence")
true_infl <- matrix(c(0, 2, 3, 3,
                      1, 0, 1, 2,
                      1, 1, 0, 1,
                      1, 1, 2, 0),
                    nrow = 4, byrow = TRUE, dimnames = list(crits, crits))
for (k in seq_len(nrow(infl_pairs))) {
  base <- true_infl[infl_pairs$a[k], infl_pairs$b[k]]
  resp[[infl_cols[k]]] <- pmax(0, pmin(4, round(
    base + stats::rnorm(n, 0, 0.6)
  )))
}

# ---- write ----------------------------------------------------------------
sframe_path <- "inst/extdata/hotel_supplier_mcdm.sframe"
csv_path    <- "inst/extdata/hotel_supplier_mcdm_responses.csv"

# Written twice on purpose. A freshly constructed instrument is not a
# serialisation fixed point: read_sframe() drops the NULL fields that were
# written as {} and fills in analysis-plan defaults that were not written, so
# the first read produces a different payload and therefore a different hash.
# One round trip settles it, after which the file is stable. Shipping the
# settled form means the bundled fixture hashes to the value it stores, which
# is what the release gate asks for. The underlying asymmetry is a separate,
# pre-existing issue and is logged for triage rather than papered over here.
tmp <- tempfile(fileext = ".sframe")
write_sframe(study, tmp)
study <- read_sframe(tmp)
write_sframe(study, sframe_path, overwrite = TRUE)

utils::write.csv(resp, csv_path, row.names = FALSE)

cat("instrument:", sframe_path, "\n")
cat("responses :", csv_path, "  rows:", nrow(resp),
    " cols:", ncol(resp), "\n")
cat("expansion columns (excluding respondent_id):", ncol(resp) - 1, "\n")
