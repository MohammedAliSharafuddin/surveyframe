# data-raw/make_apa_reference_docs.R
#
# Builds inst/templates/apa-reference.docx and apa-reference.odt, the
# reference documents Quarto styles a Word or OpenDocument report with
# (NAMING decision 6). Each starts from pandoc's own default reference
# document, so every style pandoc writes exists, and sets APA 7: Times New
# Roman 12 throughout, black text, double spacing, a half-inch first-line
# indent in body text, level 1 headings centred and bold, level 2 bold,
# level 3 bold italic, and tables single-spaced.
#
# Run from the package root with Quarto and the zip command on the PATH:
#   Rscript data-raw/make_apa_reference_docs.R

quarto <- Sys.which("quarto")
stopifnot(nzchar(quarto), nzchar(Sys.which("zip")))
out_dir <- file.path("inst", "templates")

default_doc <- function(ext) {
  path <- tempfile(fileext = paste0(".", ext))
  status <- system2(quarto, c("pandoc", "-o", shQuote(path),
                              "--print-default-data-file", paste0("reference.", ext)))
  stopifnot(identical(status, 0L), file.exists(path))
  path
}

unpack <- function(path) {
  dir <- tempfile("refdoc-")
  utils::unzip(path, exdir = dir)
  dir
}

# mimetype first and stored, as OpenDocument requires, and harmless in docx.
repack <- function(dir, dest) {
  dest <- file.path(normalizePath(dirname(dest)), basename(dest))
  unlink(dest)
  old <- setwd(dir)
  on.exit(setwd(old), add = TRUE)
  if (file.exists("mimetype")) system2("zip", c("-X", "-0", "-q", shQuote(dest), "mimetype"))
  files <- setdiff(list.files(".", recursive = TRUE, all.files = TRUE), "mimetype")
  system2("zip", c("-X", "-q", shQuote(dest), shQuote(files)))
}

read_text <- function(path) paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
write_text <- function(text, path) writeLines(text, path, useBytes = TRUE)

# Word ----------------------------------------------------------------------
tnr_w <- "<w:rFonts w:ascii=\"Times New Roman\" w:hAnsi=\"Times New Roman\" w:eastAsia=\"Times New Roman\" w:cs=\"Times New Roman\" />"
double_w <- "<w:spacing w:before=\"0\" w:after=\"0\" w:line=\"480\" w:lineRule=\"auto\" />"

edit_w_style <- function(xml, id, f) {
  pattern <- sprintf("(?s)<w:style [^>]*w:styleId=\"%s\">.*?</w:style>", id)
  m <- regexpr(pattern, xml, perl = TRUE)
  stopifnot(m > 0)
  block <- regmatches(xml, m)
  regmatches(xml, m) <- f(block)
  xml
}
set_w_spacing <- function(block, spacing) {
  if (grepl("<w:spacing [^>]*/>", block)) sub("<w:spacing [^>]*/>", spacing, block)
  else sub("<w:pPr>", paste0("<w:pPr>", spacing), block, fixed = TRUE)
}
add_w_ppr <- function(block, tag) {
  if (grepl("<w:pPr>", block, fixed = TRUE)) sub("</w:pPr>", paste0(tag, "</w:pPr>"), block, fixed = TRUE)
  else sub("(<w:style [^>]*>)", paste0("\\1<w:pPr>", tag, "</w:pPr>"), block, perl = TRUE)
}
add_w_rpr <- function(block, tags) {
  block <- gsub("<w:b ?/>|<w:bCs ?/>|<w:i ?/>|<w:iCs ?/>", "", block)
  if (grepl("<w:rPr>", block, fixed = TRUE)) sub("<w:rPr>", paste0("<w:rPr>", tags), block, fixed = TRUE)
  else sub("</w:style>", paste0("<w:rPr>", tags, "</w:rPr></w:style>"), block, fixed = TRUE)
}

docx_dir <- unpack(default_doc("docx"))
sty_path <- file.path(docx_dir, "word", "styles.xml")
xml <- read_text(sty_path)
xml <- gsub("<w:rFonts [^>]*/>", tnr_w, xml)
xml <- gsub("<w:sz w:val=\"[0-9]+\" ?/>", "<w:sz w:val=\"24\" />", xml)
xml <- gsub("<w:szCs w:val=\"[0-9]+\" ?/>", "<w:szCs w:val=\"24\" />", xml)
xml <- gsub("<w:color [^>]*/>", "", xml)
xml <- sub("<w:spacing w:after=\"200\" />", double_w, xml, fixed = TRUE)
for (id in c("BodyText", "FirstParagraph")) {
  xml <- edit_w_style(xml, id, function(b) add_w_ppr(set_w_spacing(b, double_w), "<w:ind w:firstLine=\"720\" />"))
}
for (id in c("Title", "Subtitle", "Author", "Date", "Heading1")) {
  xml <- edit_w_style(xml, id, function(b) add_w_ppr(set_w_spacing(b, double_w), "<w:jc w:val=\"center\" />"))
}
for (id in c("Title", "Heading1", "Heading2")) {
  xml <- edit_w_style(xml, id, function(b) add_w_rpr(b, "<w:b /><w:bCs />"))
}
xml <- edit_w_style(xml, "Heading3", function(b) add_w_rpr(b, "<w:b /><w:bCs /><w:i /><w:iCs />"))
for (id in c("Heading2", "Heading3", "Heading4", "Heading5")) {
  xml <- edit_w_style(xml, id, function(b) set_w_spacing(b, double_w))
}
# Captions above the float, flush left and upright, kept with what follows.
for (id in c("Caption", "TableCaption", "ImageCaption")) {
  xml <- edit_w_style(xml, id, function(b) {
    b <- gsub("<w:i ?/>|<w:iCs ?/>", "", b)
    add_w_ppr(set_w_spacing(b, double_w), "<w:keepNext />")
  })
}
write_text(xml, sty_path)
repack(docx_dir, file.path(out_dir, "apa-reference.docx"))

# OpenDocument --------------------------------------------------------------
odt_dir <- unpack(default_doc("odt"))
sty_path <- file.path(odt_dir, "styles.xml")
xml <- read_text(sty_path)
xml <- gsub("style:font-name=\"Arial\"", "style:font-name=\"Times New Roman\"", xml, fixed = TRUE)
xml <- gsub("fo:font-size=\"[^\"]*\"", "fo:font-size=\"12pt\"", xml)
xml <- gsub("style:font-size-(asian|complex)=\"[^\"]*\"", "style:font-size-\\1=\"12pt\"", xml)
xml <- sub("<style:style style:name=\"Standard\" style:family=\"paragraph\"\\s+style:class=\"text\" />",
           paste0("<style:style style:name=\"Standard\" style:family=\"paragraph\" style:class=\"text\">",
                  "<style:paragraph-properties fo:line-height=\"200%\" fo:margin-top=\"0in\" fo:margin-bottom=\"0in\" />",
                  "<style:text-properties style:font-name=\"Times New Roman\" fo:font-size=\"12pt\" fo:color=\"#000000\" />",
                  "</style:style>"), xml, perl = TRUE)
stopifnot(grepl("fo:line-height=\"200%\"", xml, fixed = TRUE))
odt_style <- function(xml, name, f) {
  pattern <- sprintf("(?s)<style:style style:name=\"%s\".*?</style:style>", name)
  m <- regexpr(pattern, xml, perl = TRUE)
  stopifnot(m > 0)
  regmatches(xml, m) <- f(regmatches(xml, m))
  xml
}
xml <- odt_style(xml, "Text_20_body", function(b)
  sub("<style:paragraph-properties [^>]*/>",
      "<style:paragraph-properties fo:margin-top=\"0in\" fo:margin-bottom=\"0in\" fo:text-indent=\"0.5in\" style:contextual-spacing=\"false\" />",
      b, perl = TRUE))
xml <- odt_style(xml, "Heading", function(b)
  sub("<style:paragraph-properties [^>]*/>",
      "<style:paragraph-properties fo:margin-top=\"0in\" fo:margin-bottom=\"0in\" style:contextual-spacing=\"false\" fo:keep-with-next=\"always\" />",
      b, perl = TRUE))
upright <- function(b) gsub("(fo|style):font-style(-asian|-complex)?=\"italic\"", "", b, perl = TRUE)
xml <- odt_style(xml, "Heading_20_1", function(b)
  sub("<style:text-properties", "<style:paragraph-properties fo:text-align=\"center\" /><style:text-properties",
      upright(b), fixed = TRUE))
xml <- odt_style(xml, "Heading_20_2", upright)
xml <- odt_style(xml, "Caption", upright)
write_text(xml, sty_path)
repack(odt_dir, file.path(out_dir, "apa-reference.odt"))

cat("Wrote", file.path(out_dir, c("apa-reference.docx", "apa-reference.odt")), sep = "\n")
