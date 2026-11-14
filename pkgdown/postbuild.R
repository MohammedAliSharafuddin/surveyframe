# pkgdown/postbuild.R
# Finishes the built site in docs/ after pkgdown and the verifier copy (Codex
# website review WR92, WR93, WR191). Run from the repository root, after
# build_site:  Rscript pkgdown/postbuild.R
#
# 1. llms.txt reads in the reader's order: the home page, then the articles
#    (Templates, How-to guides, Documentation and the rest, in _pkgdown.yml's
#    order), then the R reference, without its superseded names.
# 2. sitemap.xml leaves out the 404 page, lists the verifier, and puts the
#    home page, templates, guides and documentation first.
# 3. Every page pkgdown wrote names its canonical address, which pkgdown
#    2.2.1 leaves out. Redirect shells, the template previews and plans
#    (shown inside their template pages) and the dependency files are left
#    as they are.

site <- "https://surveyframe.org/"
docs <- "docs"

# 1. llms.txt
llms <- file.path(docs, "llms.txt")
if (file.exists(llms)) {
  x <- readLines(llms, warn = FALSE, encoding = "UTF-8")
  i_ref <- grep("^# Package index", x)[1]
  i_art <- grep("^# Articles", x)[1]
  if (!is.na(i_ref) && !is.na(i_art) && i_ref < i_art) {
    home <- x[seq_len(i_ref - 1)]
    ref <- x[i_ref:(i_art - 1)]
    art <- x[i_art:length(x)]
    ref[1] <- "# R reference"
    old <- grep("^## Old names", ref)
    if (length(old)) {
      nxt <- grep("^#{1,2} ", ref)
      nxt <- nxt[nxt > old[1]]
      end <- if (length(nxt)) nxt[1] - 1 else length(ref)
      ref <- ref[-(old[1]:end)]
    }
    writeLines(c(home, art, "", ref), llms, useBytes = TRUE)
  }
}

# 2. sitemap.xml
sitemap <- file.path(docs, "sitemap.xml")
if (file.exists(sitemap)) {
  x <- readLines(sitemap, warn = FALSE)
  locs <- sub(".*<loc>(.*)</loc>.*", "\\1", grep("<loc>", x, value = TRUE))
  locs <- setdiff(locs, paste0(site, "404.html"))
  locs <- union(locs, paste0(site, "verify/"))
  rank <- function(u) {
    p <- sub(site, "", u, fixed = TRUE)
    if (p %in% c("", "index.html")) return(0)
    if (grepl("^articles/templates", p)) return(1)
    if (grepl("^articles/guides", p)) return(2)
    if (grepl("^articles/docs", p)) return(3)
    if (grepl("^articles/", p)) return(4)
    if (grepl("^verify/", p)) return(5)
    6
  }
  locs <- locs[order(vapply(locs, rank, numeric(1)), locs)]
  writeLines(c("<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
               "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">",
               sprintf("<url><loc>%s</loc></url>", locs), "</urlset>"), sitemap)
}

# 3. Canonical links
pages <- list.files(docs, pattern = "\\.html$", recursive = TRUE)
pages <- pages[!grepl("^(deps|templates)/", pages)]
n <- 0L
for (p in pages) {
  f <- file.path(docs, p)
  h <- readLines(f, warn = FALSE, encoding = "UTF-8")
  if (any(grepl("rel=\"canonical\"", h, fixed = TRUE)) || any(grepl("http-equiv=\"refresh\"", h, fixed = TRUE))) next
  head_end <- grep("</head>", h, fixed = TRUE)[1]
  if (is.na(head_end)) next
  # A reference page's title, "Title \u2014 name" from pkgdown, reads
  # "Title (name)" in <title> and og:title (Codex WR561): no dash on the site.
  h <- gsub("(<title>|og:title\" content=\")([^<\"]*?) \u2014 ([A-Za-z0-9._]+)", "\\1\\2 (\\3)", h, perl = TRUE)
  writeLines(h, f, useBytes = TRUE)
  url <- paste0(site, sub("(^|/)index\\.html$", "\\1", p))
  h <- append(h, sprintf("<link rel=\"canonical\" href=\"%s\" />", url), after = head_end - 1)
  writeLines(h, f, useBytes = TRUE)
  n <- n + 1L
}
cat("postbuild: llms.txt reordered, sitemap.xml written, canonical links added to", n, "pages\n")
