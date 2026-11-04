# tests/testthat/fixtures/make_t1_expected_flags.R
#
# Not run by the tests. Rebuilds t1_expected_flags.csv beside it from the Codex
# T1 oracle output (session 8a), read-only, with the 6 PLS rows corrected.
# The oracle read column 1 of seminr's loadings matrix only, so it_1 to it_3
# and sa_1 to sa_3 read 0. Each item's loading is now its own construct's.
# Run from the package root. The Codex folder is a sibling of the repository
# unless SF_CODEX_PREP_DIR names it.
src <- Sys.getenv("SF_CODEX_PREP_DIR", "../surveyframe-codex-prep-2026-11")
if (!dir.exists(src)) stop("Codex T1 folder not found: ", src, ". Set SF_CODEX_PREP_DIR.")
x <- utils::read.csv(file.path(src, "t1_expected_flags.csv"), stringsAsFactors = FALSE)
ext <- file.path(src, "src", "inst", "extdata", "demos")
instr <- jsonlite::fromJSON(file.path(ext, "sem_pls.sframe"), simplifyVector = FALSE)
responses <- utils::read.csv(file.path(ext, "sem_pls_responses.csv"), check.names = FALSE)
cons <- instr$models[[2]]$measurement$constructs
mm <- do.call(seminr::constructs, lapply(cons, function(z)
  seminr::composite(z$id, unlist(z$items), weights = seminr::mode_A)))
sm <- do.call(seminr::relationships, lapply(instr$models[[2]]$structural$paths, function(z)
  seminr::paths(from = z$from, to = z$to)))
pls <- seminr::estimate_pls(data = responses, measurement_model = mm, structural_model = sm)
L <- as.matrix(summary(pls)$loadings)
own <- setNames(rep(vapply(cons, `[[`, "", "id"), vapply(cons, function(z) length(z$items), 1L)),
                unlist(lapply(cons, `[[`, "items")))
rows <- x$dataset == "sem_pls" & x$result_type == "pls"
for (k in which(rows)) {
  x$value[k] <- abs(L[x$item[k], own[[x$item[k]]]])
  x$flagged[k] <- x$value[k] < 0.708
}
print(x[rows, c("item", "value", "flagged")])
cat("flagged rows:", sum(x$flagged), "of", nrow(x), "\n")
utils::write.csv(x, "tests/testthat/fixtures/t1_expected_flags.csv", row.names = FALSE, na = "")
