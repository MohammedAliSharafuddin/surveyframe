# tests/testthat/test-item-flags.R
#
# Session 8a, item (d) (owner 2026-11-01). sframe_item_flags(result) lists
# the items past the usual cut-offs in a reliability, item, EFA readiness,
# EFA, CFA, validity or PLS result, with a ready reason. Checked against the
# Codex T1 oracle (psych, lavaan and seminr called directly, surveyframe not
# loaded), copied into fixtures/t1_expected_flags.csv with its 6 PLS rows
# corrected: 4 of 249 rows are flagged.

t1 <- function() {
  utils::read.csv(test_path("fixtures", "t1_expected_flags.csv"), stringsAsFactors = FALSE)
}
t1_rows <- function(dataset, type, statistic) {
  x <- t1()
  x[x$dataset == dataset & x$result_type == type & x$statistic == statistic, ]
}
# Compares flag rows to oracle rows by item, value and flag.
# A joint oblimin EFA is iterative, and the oracle rotates reverse-keyed data,
# which starts it elsewhere: the 2 agree to about 2e-6, so `tolerance` is
# looser there.
expect_matches_oracle <- function(flags, oracle, statistic, tolerance = 1e-6) {
  got <- flags[flags$statistic == statistic, ]
  expect_setequal(got$item, oracle$item)
  m <- match(oracle$item, got$item)
  expect_equal(got$value[m], oracle$value, tolerance = tolerance)
  expect_identical(got$flagged[m], as.logical(oracle$flagged))
}
# The numeric, reverse-keyed item data of 1 scale, as the oracle builds it.
scale_data <- function(d, scale_id) {
  sc <- Filter(function(s) identical(s$id, scale_id), d$instrument$scales)[[1]]
  x <- sframe_scale_matrix(d$responses, d$instrument, sc, as.character(sc$items))
  as.data.frame(x[stats::complete.cases(x), , drop = FALSE])
}

test_that("(d) reliability and item results match psych", {
  d <- sframe_demo("factor_structure")
  rel <- sframe_item_flags(suppressWarnings(sframe_reliability_results(d$responses, d$instrument)), all = TRUE)
  expect_matches_oracle(rel, t1_rows("factor_structure", "reliability", "alpha_if_item_deleted_minus_alpha"),
                        "alpha_if_item_deleted_minus_alpha")
  it <- sframe_item_flags(sframe_item_results(d$responses, d$instrument), all = TRUE)
  expect_matches_oracle(it, t1_rows("factor_structure", "item_analysis", "corrected_item_total_r"),
                        "corrected_item_total_r")
})

test_that("(d) EFA readiness and a 1-factor EFA per scale match psych", {
  d <- sframe_demo("factor_structure")
  for (s in c("organisation", "content")) {
    o <- t1()
    o <- o[o$dataset == "factor_structure" & o$scale_or_factor == s, ]
    r <- sframe_item_flags(sframe_efa_readiness_results(d$responses, d$instrument, scales = s), all = TRUE)
    expect_matches_oracle(r, o[o$result_type == "efa_readiness", ], "KMO_MSA_item")
    ids <- as.character(Filter(function(z) identical(z$id, s), d$instrument$scales)[[1]]$items)
    e <- sframe_item_flags(sframe_efa_solution(d$responses, d$instrument, items = ids, nfactors = 1), all = TRUE)
    expect_matches_oracle(e, o[o$result_type == "efa", ], "absolute_primary_loading")
  }
})

test_that("(d) the joint EFA gives the oracle's 4 flagged rows", {
  joint <- function(demo, dataset) {
    d <- sframe_demo(demo)
    ids <- unique(unlist(lapply(d$instrument$scales, function(s) as.character(s$items))))
    f <- sframe_item_flags(sframe_efa_solution(d$responses, d$instrument, items = ids,
                                               nfactors = length(d$instrument$scales)), all = TRUE)
    o <- t1()
    o <- o[o$dataset == dataset & o$scale_or_factor == "all_scales", ]
    expect_matches_oracle(f, o[o$statistic == "absolute_primary_loading", ], "absolute_primary_loading", tolerance = 1e-4)
    expect_matches_oracle(f, o[o$statistic == "primary_minus_cross_loading", ], "primary_minus_cross_loading", tolerance = 1e-4)
    f[f$flagged, ]
  }
  a <- joint("input_types", "surveyframe_input_types_demo")
  b <- joint("tourism_services", "tourism_services_demo")
  flagged <- rbind(a, b)
  expect_equal(nrow(flagged), 4L)
  expect_setequal(paste(flagged$item, flagged$statistic), c(
    "digital_confusion absolute_primary_loading", "digital_confusion primary_minus_cross_loading",
    "digital_trust primary_minus_cross_loading", "sat_1 primary_minus_cross_loading"))
  # Low loading and cross-loading are separate reasons, each with its numbers.
  dc <- flagged[flagged$item == "digital_confusion", ]
  expect_match(dc$reason[dc$statistic == "absolute_primary_loading"], "digital_confusion: loading .39, below .40", fixed = TRUE)
  expect_match(dc$reason[dc$statistic == "primary_minus_cross_loading"], "apart, below .20", fixed = TRUE)
  # all = FALSE keeps the flagged rows only.
  d <- sframe_demo("tourism_services")
  ids <- unique(unlist(lapply(d$instrument$scales, function(s) as.character(s$items))))
  only <- sframe_item_flags(sframe_efa_solution(d$responses, d$instrument, items = ids,
                                                nfactors = length(d$instrument$scales)))
  expect_true(all(only$flagged))
  expect_identical(only$item, "sat_1")
})

test_that("(d) a fitted lavaan CFA matches the oracle's standardised loadings", {
  skip_if_not_installed("lavaan")
  d <- sframe_demo("factor_structure")
  for (s in c("organisation", "content")) {
    x <- scale_data(d, s)
    fit <- lavaan::cfa(paste0(s, " =~ ", paste(names(x), collapse = " + ")), data = x, std.lv = TRUE)
    f <- sframe_item_flags(fit, all = TRUE)
    o <- t1_rows("factor_structure", "cfa", "absolute_standardised_loading")
    expect_matches_oracle(f, o[o$scale_or_factor == s, ], "absolute_standardised_loading")
  }
})

test_that("(d) validity: AVE and HTMT match, and the HTMT threshold is kept", {
  skip_if_not_installed("lavaan")
  d <- sframe_demo("sem_pls")
  cons <- d$instrument$models[[1]]$measurement$constructs
  syntax <- paste(vapply(cons, function(z) paste0(z$id, " =~ ", paste(z$items, collapse = " + ")), ""),
                  collapse = "\n")
  std <- lavaan::standardizedSolution(lavaan::cfa(syntax, data = d$responses, std.lv = TRUE))
  std <- std[std$op == "=~", ]
  v <- sframe_validity_results(
    data.frame(construct = std$lhs, item = std$rhs, loading = std$est.std),
    items_by_construct = stats::setNames(lapply(cons, function(z) d$responses[z$items]),
                                         vapply(cons, `[[`, "", "id")))
  f <- sframe_item_flags(v, all = TRUE)
  o <- t1()
  o <- o[o$dataset == "sem_pls" & o$result_type == "validity", ]
  ave <- f[f$statistic == "AVE", ]
  oa <- o[o$statistic == "AVE", ]
  expect_equal(ave$value[match(oa$scale_or_factor, ave$group)], oa$value, tolerance = 1e-6)
  ht <- f[f$statistic == "HTMT", ]
  oh <- o[o$statistic == "HTMT", ]
  expect_equal(ht$value[match(oh$scale_or_factor, ht$group)], oh$value, tolerance = 1e-6)
  expect_identical(attr(f, "htmt_threshold"), 0.85)
  expect_identical(attr(sframe_item_flags(v, htmt = 0.90), "htmt_threshold"), 0.90)
  expect_error(sframe_item_flags(v, htmt = 0.8), "htmt", class = "sframe_error")
})

test_that("(d) PLS outer loadings use each item's own construct, with .708 kept", {
  skip_if_not_installed("seminr")
  d <- sframe_demo("sem_pls")
  m <- d$instrument$models[[2]]
  mm <- do.call(seminr::constructs, lapply(m$measurement$constructs, function(z)
    seminr::composite(z$id, as.character(z$items), weights = seminr::mode_A)))
  sm <- do.call(seminr::relationships, lapply(m$structural$paths, function(z)
    seminr::paths(from = z$from, to = z$to)))
  fit <- suppressMessages(seminr::estimate_pls(d$responses, mm, sm))
  f <- sframe_item_flags(fit, all = TRUE)
  o <- t1_rows("sem_pls", "pls", "absolute_outer_loading")
  expect_matches_oracle(f, o, "absolute_outer_loading")
  expect_false(any(f$flagged))
  expect_true(all(f$cutoff == 0.708))
  # A result of another kind is refused, naming the kinds read.
  expect_error(sframe_item_flags(structure(list(), class = "other")), "reliability", class = "sframe_error")
})

test_that("(d) a plan block result gives its block id in the reason", {
  d <- sframe_demo("factor_structure")
  res <- suppressWarnings(run_analysis_plan(d$responses, d$instrument))
  b <- Filter(function(r) identical(r$test, "efa_solution") || identical(r$method, "efa_solution"), res)
  skip_if(length(b) == 0, "no EFA block in this demo")
  f <- sframe_item_flags(b[[1]], all = TRUE)
  expect_true(nrow(f) > 0)
  expect_true(all(nzchar(f$block)))
})
