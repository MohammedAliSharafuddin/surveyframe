# data-raw/demo_calibration.R
# Calibration targets for the demo simulators (plan step 2, 2026-11-26).
#
# The demos ship surveyframe's own simulated data, never a published dataset
# What the simulators borrow from published data is its
# shape: how answers spread over the categories of an item, how items of 1
# scale correlate, and how scales and constructs relate. This script reads 2
# published datasets, both dev-only (psych and seminr are never needed to
# install or check surveyframe), and writes those numbers to
# data-raw/demo_calibration_targets.R, which build_demo_library.R sources.
#
#   psych::bfi    25 Big Five personality items on a 6-point scale, 2800
#                 respondents of the SAPA project. Real skew, and reverse-
#                 keyed items that sit weakly with their scale (A1 most of all).
#   seminr::mobi  The ECSI mobile phone customer satisfaction data, 250
#                 respondents on 10-point items, with the measurement and
#                 structural sizes a customer satisfaction model shows.
#
# A 5-point item takes its category shares from a 6-point source by merging
# the 2 middle categories (3 and 4), and from a 10-point source by merging
# neighbouring pairs (1-2, 3-4, 5-6, 7-8, 9-10). Item correlations are
# polychoric for bfi, the latent correlation a 6-point item is cut from, and
# Pearson for mobi, whose 10 categories need no polychoric correction (psych
# refuses one past 8 categories).
#
# Run from the repository root:  Rscript data-raw/demo_calibration.R

stopifnot(requireNamespace("psych", quietly = TRUE),
          requireNamespace("seminr", quietly = TRUE))

shares <- function(x, k) {
  x <- x[!is.na(x)]
  as.numeric(table(factor(x, levels = seq_len(k)))) / length(x)
}
merge6to5 <- function(p) c(p[1], p[2], p[3] + p[4], p[5], p[6])
merge10to5 <- function(p) p[c(1, 3, 5, 7, 9)] + p[c(2, 4, 6, 8, 10)]
r3 <- function(x) round(x, 4)

# --- psych::bfi -------------------------------------------------------------
bfi <- psych::bfi
bfi_items <- names(bfi)[1:25]
bfi_keys <- list(
  agreeableness     = c("-A1", "A2", "A3", "A4", "A5"),
  conscientiousness = c("C1", "C2", "C3", "-C4", "-C5"),
  extraversion      = c("-E1", "-E2", "E3", "E4", "E5"),
  neuroticism       = c("N1", "N2", "N3", "N4", "N5"),
  openness          = c("O1", "-O2", "O3", "O4", "-O5"))
reversed <- sub("^-", "", grep("^-", unlist(bfi_keys), value = TRUE))

bfi_p6 <- lapply(stats::setNames(bfi_items, bfi_items), function(i) r3(shares(bfi[[i]], 6)))
bfi_p5 <- lapply(bfi_p6, function(p) r3(merge6to5(p)))
bfi_poly <- r3(suppressWarnings(psych::polychoric(bfi[bfi_items]))$rho)
scored <- psych::scoreItems(bfi_keys, bfi[bfi_items])
bfi_scale_r <- r3(unclass(scored$cor))
dimnames(bfi_scale_r) <- list(names(bfi_keys), names(bfi_keys))
bfi_alpha <- r3(stats::setNames(as.numeric(scored$alpha), names(bfi_keys)))

# The pooled shares of every item scored in its keyed direction: the shape a
# generic positively worded 5-point item takes, which lik() cuts at.
keyed5 <- lapply(bfi_items, function(i) {
  p <- merge6to5(shares(bfi[[i]], 6))
  if (i %in% reversed) rev(p) else p
})
lik_default <- r3(Reduce(`+`, keyed5) / length(keyed5))
lik_default <- r3(lik_default / sum(lik_default))

# Alpha of the item sets the demos draw on, from bfi itself, so each demo's
# story can state what its population value is.
alpha_of <- function(items, rev_items) {
  a <- psych::alpha(bfi[items], keys = rev_items, warnings = FALSE)
  c(alpha = r3(a$total$raw_alpha),
    stats::setNames(r3(a$item.stats[items, "r.drop"]), paste0("r_drop_", items)))
}
likert_scale_alpha <- alpha_of(c("A2", "A3", "A5", "A1"), "A1")

# Mean of the absolute within-scale polychoric correlations: the one number
# a rating grid whose rows are separate parts of 1 course borrows.
within_r <- unlist(lapply(bfi_keys, function(k) {
  k <- sub("^-", "", k)
  m <- abs(bfi_poly[k, k])
  m[lower.tri(m)]
}))
bfi_mean_within_r <- r3(mean(within_r))

# --- seminr::mobi -----------------------------------------------------------
mobi <- get(utils::data("mobi", package = "seminr", envir = environment()))
perq <- paste0("PERQ", 1:7); cusa <- paste0("CUSA", 1:3); cusl <- paste0("CUSL", 1:3)
mobi_p10 <- lapply(stats::setNames(c(perq, cusa, cusl), c(perq, cusa, cusl)),
                   function(i) r3(shares(mobi[[i]], 10)))
mobi_p5 <- lapply(mobi_p10, function(p) r3(merge10to5(p)))

pls_of <- function(q_items) {
  mm <- seminr::constructs(
    seminr::composite("quality", q_items),
    seminr::composite("satisfaction", cusa),
    seminr::composite("loyalty", cusl))
  sm <- seminr::relationships(
    seminr::paths(from = "quality", to = c("satisfaction", "loyalty")),
    seminr::paths(from = "satisfaction", to = "loyalty"))
  utils::capture.output(fit <- seminr::estimate_pls(mobi, mm, sm))
  fit
}
full <- pls_of(perq)
full_loadings <- summary(full)$loadings
# The 3 perceived-quality items that load highest stand in for the demo's
# 3 content-quality items. All 3 loyalty items are kept, CUSL2 too: it asks
# whether a customer would switch for a lower price, loads weakly in every
# published analysis of mobi, and is the demo's "I would pay to attend again".
perq_top3 <- names(sort(full_loadings[perq, "quality"], decreasing = TRUE))[1:3]
perq_top3 <- perq[perq %in% perq_top3]
fit3 <- pls_of(perq_top3)
L3 <- summary(fit3)$loadings
own <- c(stats::setNames(rep("quality", 3), perq_top3),
         stats::setNames(rep("satisfaction", 3), cusa),
         stats::setNames(rep("loyalty", 3), cusl))
mobi_items <- c(perq_top3, cusa, cusl)
mobi_loadings <- r3(vapply(mobi_items, function(i) L3[i, own[[i]]], 0))
paths <- summary(fit3)$paths
mobi_paths <- r3(c(quality_satisfaction = paths["quality", "satisfaction"],
                   satisfaction_loyalty = paths["satisfaction", "loyalty"],
                   quality_loyalty      = paths["quality", "loyalty"]))
mobi_r <- r3(stats::cor(mobi[mobi_items]))

# --- write the targets ------------------------------------------------------
targets <- list(
  source = list(
    bfi = paste("Revelle, W. (2025). psych: Procedures for Psychological,",
                "Psychometric, and Personality Research. R package, dataset bfi:",
                "25 personality items from the SAPA project (Revelle, Wilt and",
                "Rosenthal, 2010), n = 2800, 6-point."),
    mobi = paste("Ray, S., Danks, N. P. and Calero Valdez, A. (2025). seminr:",
                 "Building and Estimating Structural Equation Models. R package,",
                 "dataset mobi: the ECSI mobile phone customer satisfaction data",
                 "(Tenenhaus, Esposito Vinzi, Chatelin and Lauro, 2005), n = 250, 10-point.")),
  bfi_keys = bfi_keys,
  bfi_p6 = bfi_p6,
  bfi_p5 = bfi_p5,
  bfi_poly = bfi_poly,
  bfi_scale_r = bfi_scale_r,
  bfi_alpha = bfi_alpha,
  bfi_mean_within_r = bfi_mean_within_r,
  likert_scale_alpha = likert_scale_alpha,
  lik_default = lik_default,
  mobi_items = mobi_items,
  mobi_p10 = mobi_p10[mobi_items],
  mobi_p5 = mobi_p5[mobi_items],
  mobi_r = mobi_r,
  mobi_loadings = mobi_loadings,
  mobi_paths = mobi_paths
)

out <- file.path("data-raw", "demo_calibration_targets.R")
con <- file(out, "w")
writeLines(c(
  "# data-raw/demo_calibration_targets.R",
  "# Written by data-raw/demo_calibration.R. Do not edit by hand.",
  "# Category shares, item correlations, scale correlations and path sizes",
  "# read from psych::bfi and seminr::mobi (sources in $source), which",
  "# build_demo_library.R simulates the demos to. No published data ships.",
  ""), con)
writeLines(paste("demo_calibration <-", paste(deparse(targets, control = c("keepNA", "keepInteger", "niceNames", "showAttributes")), collapse = "\n")), con)
close(con)
cat("Wrote", out, "\n")
cat("lik() shares:", lik_default, "\n")
cat("likert_scale alpha (A2, A3, A5, A1 reversed):", likert_scale_alpha[["alpha"]], "\n")
cat("mobi quality items:", perq_top3, "\n")
print(mobi_loadings); print(mobi_paths)
