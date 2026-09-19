# check_house_style.R
#
# A dev-only checker for the prose house style. It reads the roxygen comments
# in R/, the vignettes, NEWS.md and README.md, and reports 2 things per file:
# the rate of negative markers per 1,000 words against a ceiling of 8, and any
# banned construction.
#
# The rule tightened on 2026-09-12: "rather than", "instead of a" and "and not"
# joined the ban that already covered "not X but Y".
#
# Run it from the package root:
#   Rscript data-raw/check_house_style.R
#   Rscript data-raw/check_house_style.R vignettes/mcdm-analysis.Rmd
#
# It exits 1 where a file breaks the rule, so a hook or a CI job can gate on it.
# This file is dev-only and ships in neither the tarball nor the repository's
# build, through the entries for data-raw/ in .Rbuildignore.

CEILING <- 8

NEGATIVE <- "\\b(not|no|never|none|nothing|without|cannot|neither|nor|n't)\\b"

BANNED <- c(
  "rather than"      = "rather than",
  "instead of a"     = "instead of a",
  "instead of the"   = "instead of the",
  # Anchored at both ends: without the closing boundary this fired on
  # "and nothing is uploaded", which is not the banned construction.
  "and not"          = "\\band not\\b",
  "not X but Y"      = "\\bnot\\b[^.;]{1,60}\\bbut\\b",
  "em or en dash"    = "—|–",
  "semicolon"        = ";",
  "ellipsis"         = "\\.\\.\\."
)

# Prose only. Code, output and object names carry negations that say nothing
# about the writing, so they are stripped before counting.
prose_of <- function(path) {
  x <- readLines(path, warn = FALSE)
  # NEWS.md keeps every past release. The style applies to what is being
  # written, so only the section at the top is read.
  if (basename(path) == "NEWS.md") {
    heads <- grep("^# ", x)
    if (length(heads) > 1) x <- x[heads[1]:(heads[2] - 1)]
  }
  if (grepl("[.]R$", path)) {
    x <- sub("^\\s*#'\\s?", "", grep("^\\s*#'", x, value = TRUE))
    x <- x[!grepl("^@(param|return|export|rdname|inheritParams|importFrom|keywords|aliases|name|docType|useDynLib|srrstats)", x)]
  }
  if (grepl("[.]Rmd$", path)) {
    fence <- cumsum(grepl("^\\s*```", x))
    x <- x[fence %% 2 == 0 & !grepl("^\\s*```", x)]
    x <- x[!grepl("^---\\s*$", x)]
    # The vignettes carry a <style> block whose CSS comments are code.
    open_s <- grepl("<style>", x); close_s <- grepl("</style>", x)
    inside <- cumsum(open_s) - cumsum(close_s)
    x <- x[inside == 0 & !open_s & !close_s]
  }
  x <- gsub("`[^`]*`", " ", x)                      # inline code
  x <- gsub("\\[([^]]*)\\]\\([^)]*\\)", "\\1", x)   # links, keeping the text
  x <- gsub("<[^>]*>", " ", x)                      # html and urls
  paste(x, collapse = " ")
}

check_one <- function(path) {
  body <- prose_of(path)
  txt <- tolower(body)
  words <- length(strsplit(trimws(gsub("[^a-z0-9 ]", " ", txt)), "\\s+")[[1]])
  if (words < 50) return(NULL)
  hits <- gregexpr(NEGATIVE, txt)[[1]]
  n <- if (hits[1] > 0) length(hits) else 0
  rate <- 1000 * n / words
  found <- names(BANNED)[vapply(BANNED, function(p) grepl(p, body), logical(1))]
  data.frame(file = path, words = words, negatives = n,
             per_1000 = round(rate, 1),
             over = rate > CEILING,
             banned = paste(found, collapse = ", "),
             stringsAsFactors = FALSE)
}

args <- commandArgs(trailingOnly = TRUE)
files <- if (length(args)) args else c(
  list.files("R", pattern = "[.]R$", full.names = TRUE),
  list.files("vignettes", pattern = "[.]Rmd$", full.names = TRUE),
  "NEWS.md", "README.md")
files <- files[file.exists(files)]

res <- do.call(rbind, lapply(files, check_one))
# Files under 50 words are skipped, so a short-file-only run has nothing to
# report. Say that, because ordering a NULL frame aborts with an error about
# a unary operator, which reads as a broken checker.
if (is.null(res)) {
  cat("Nothing to check: every file given is under 50 words.\n")
  quit(status = 0)
}
res <- res[order(-res$per_1000), ]
bad <- res[res$over | nzchar(res$banned), ]

cat(sprintf("%d files read, ceiling %d negative markers per 1,000 words\n\n",
            nrow(res), CEILING))
if (nrow(bad)) {
  print(bad[, c("file", "words", "per_1000", "over", "banned")], row.names = FALSE)
  cat(sprintf("\n%d files to reword.\n", nrow(bad)))
  quit(status = 1)
}
cat("Every file is within the style.\n")
