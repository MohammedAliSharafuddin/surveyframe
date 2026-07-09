# tests/testthat/test-aic-rsam-fixture.R
# v0.3.3 regression tests against the AIC-RSAM room-service fixture
# (dev branch only; built by data-raw/aic_rsam_fixture.R). The fixture is
# gitignored on main and excluded from the CRAN build, so every test here
# skips when the fixture file is absent.

aic_rsam_path <- function() {
  test_path("fixtures", "aic_rsam_pilot.sframe")
}

skip_if_no_aic_rsam <- function() {
  skip_if(!file.exists(aic_rsam_path()),
          "AIC-RSAM fixture not present (dev branch only)")
}

test_that("AIC-RSAM fixture loads, validates, and matches the questionnaire", {
  skip_if_no_aic_rsam()
  x <- read_sframe(aic_rsam_path())
  expect_s3_class(x, "sframe")
  expect_no_error(validate_sframe(x))

  types <- vapply(x$items, function(i) i$type, character(1))
  ids   <- vapply(x$items, function(i) i$id, character(1))

  # 7 eligibility + 6 profile single-choice, 24 construct + 6 FE likert,
  # 2 open-text, 10 section breaks
  expect_identical(sum(types == "single_choice"), 13L)
  expect_identical(sum(types == "likert"), 30L)
  expect_identical(sum(types == "text"), 2L)
  expect_identical(sum(types == "section_break"), 10L)

  # Every construct block has exactly its four items (FE has six)
  for (con in c("aia", "poa", "peou", "pu", "pr", "bi")) {
    expect_identical(sum(grepl(paste0("^", con, "_[0-9]+$"), ids)), 4L)
  }
  expect_identical(sum(grepl("^fe_[0-9]+$", ids)), 6L)

  # Seven scales: six constructs plus feature evaluation
  scale_ids <- vapply(x$scales, function(s) s$id, character(1))
  expect_setequal(scale_ids, c("aia", "poa", "peou", "pu", "pr", "bi", "fe"))
})

test_that("AIC-RSAM eligibility cascade is fully declared", {
  skip_if_no_aic_rsam()
  x <- read_sframe(aic_rsam_path())

  br <- x$branching
  expect_identical(length(br), 54L)

  targets <- vapply(br, function(b) b$item_id %||% b$target %||% NA_character_,
                    character(1))
  deps    <- vapply(br, function(b) b$depends_on, character(1))

  # The three hard gates chain E1 -> E2 -> E3 -> E4
  gate <- function(target) br[[which(targets == target &
                                       deps != "elig_stay_duration")[1]]]
  expect_identical(gate("elig_nationality")$depends_on, "elig_age")
  expect_identical(gate("elig_resort_stay")$depends_on, "elig_nationality")
  expect_identical(gate("elig_stay_duration")$depends_on, "elig_resort_stay")

  # Every main questionnaire item is gated on the duration item
  main_gated <- targets[deps == "elig_stay_duration"]
  expect_true(all(c("prof_mode_first", "aia_1", "poa_1", "peou_1",
                    "pu_1", "pr_1", "bi_1", "fe_1", "od_1") %in% main_gated))

  # E6 additionally depends on E5
  rs_rules <- br[targets == "elig_rs_times"]
  rs_deps <- vapply(rs_rules, function(b) b$depends_on, character(1))
  expect_true("elig_room_service" %in% rs_deps)
})

test_that("AIC-RSAM model declares six constructs and the nine H1-H9 paths", {
  skip_if_no_aic_rsam()
  x <- read_sframe(aic_rsam_path())

  expect_identical(length(x$models), 1L)
  m <- x$models[[1]]
  expect_identical(m$type, "pls_sem")
  expect_identical(m$engine, "seminr")

  cons <- m$measurement$constructs
  expect_identical(length(cons), 6L)
  con_ids <- vapply(cons, function(k) k$id, character(1))
  expect_setequal(con_ids, c("aia", "poa", "peou", "pu", "pr", "bi"))
  for (k in cons) {
    expect_identical(length(k$items), if (k$id == "fe") 6L else 4L)
    expect_identical(k$mode, "reflective")
  }

  paths <- m$structural$paths %||% m$structural
  expect_identical(length(paths), 9L)
  edges <- vapply(paths, function(p) paste(p$from, p$to), character(1))
  expect_setequal(edges, c("aia peou", "aia pu", "aia poa",
                           "peou pu", "peou bi", "poa pu",
                           "poa bi", "pu bi", "pr bi"))
})

test_that("AIC-RSAM fixture round-trips through write_sframe unchanged", {
  skip_if_no_aic_rsam()
  x <- read_sframe(aic_rsam_path())
  tmp <- tempfile(fileext = ".sframe")
  on.exit(unlink(tmp), add = TRUE)
  write_sframe(x, tmp, overwrite = TRUE)
  y <- read_sframe(tmp)
  expect_no_error(validate_sframe(y))
  expect_identical(
    vapply(y$items, function(i) i$id, character(1)),
    vapply(x$items, function(i) i$id, character(1))
  )
  expect_identical(length(y$branching), length(x$branching))
  expect_identical(y$meta$title, x$meta$title)
})
