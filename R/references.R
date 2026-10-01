# R/references.R
# References carried by an instrument, and the bibliography a report builds
# from them. Added for 0.4.3.
#
# A reference is a CSL-JSON record, the format Zotero, Mendeley and pandoc
# share, so a host can hand the list straight to a citation processor. Each
# record may say where the instrument cites it: the instrument as a whole, an
# item, a scale, or an analysis-plan block. Keeping that link on the
# reference, instead of adding a field to items, scales and plan blocks, has
# 2 consequences that are both intended:
#
#   1. An instrument with no references serialises exactly as before, so its
#      file hash does not change. `references` is written only when non-empty,
#      the rule `designs` and `amendments` already follow.
#   2. Citing a source is bibliographic disclosure, not a design change. The
#      content hash that amend_sframe() records leaves `references` out, so
#      adding a source to a published instrument needs no amendment.

# Pandoc's citation-key rule: starts with a letter, digit or underscore, and
# may hold internal punctuation from this set.
sframe_reference_id_pattern <- "^[A-Za-z0-9_]([A-Za-z0-9_:.#$%&+?<>~/-]*[A-Za-z0-9_])?$"

# Where an instrument can cite a reference.
sframe_reference_target_pattern <- "^(instrument|(item|scale|plan|model):.+)$"

# CSL item types a reference may take. A subset of CSL 1.0.2, the ones a
# survey instrument plausibly cites.
sframe_reference_types <- c(
  "article-journal", "book", "chapter", "paper-conference", "report",
  "thesis", "webpage", "software", "dataset", "manuscript", "document"
)

#' Create a reference
#'
#' Builds one bibliographic reference as a CSL-JSON record, the format that
#' Zotero, Mendeley and pandoc share. Attach references to an instrument with
#' [add_references()] or through `sf_instrument(components = )`, cite them in
#' text as `[@id]`, and [render_report()] lists every cited reference once, at
#' the end of the report.
#'
#' @param id Character. The citation key, for example `"cohen_1988"`. Starts
#'   with a letter, digit or underscore, as pandoc requires.
#' @param title Character. The work's title.
#' @param author Character vector of names written `"Family, Given"`, or a
#'   single organisation name written `"{R Core Team}"` in braces. `NULL` for
#'   none.
#' @param year Integer or character. Year of publication.
#' @param type Character. A CSL item type: `"article-journal"` (default),
#'   `"book"`, `"chapter"`, `"paper-conference"`, `"report"`, `"thesis"`,
#'   `"webpage"`, `"software"`, `"dataset"`, `"manuscript"` or `"document"`.
#' @param container Character. The journal, or the book a chapter is in.
#' @param volume,issue,pages Character. Volume, issue and page range, for
#'   example `"591-611"`, or an article number.
#' @param publisher Character. Publisher, or for a thesis the institution.
#' @param edition Character. Edition, for example `"2"`.
#' @param editor Character vector of editor names, written as for `author`.
#' @param doi Character. The DOI without the `https://doi.org/` prefix.
#' @param url Character. A web address.
#' @param version Character. A software version.
#' @param language Character. The work's language as a code, for example
#'   `"fr"`. Set it for a work not in English: a citation style title-cases
#'   English titles only, and would otherwise capitalise "et" or "ir" in a
#'   French or Lithuanian journal name.
#' @param cited_by Character vector. Where the instrument cites this
#'   reference: `"instrument"`, `"item:<id>"`, `"scale:<id>"`,
#'   `"plan:<block id>"` or `"model:<id>"`. Optional.
#'
#' @return An object of class `sf_reference`.
#' @seealso [read_bibtex()], [add_references()], [sframe_references()]
#' @export
#' @examples
#' ref <- sf_reference(
#'   id = "cronbach_1951", type = "article-journal",
#'   author = "Cronbach, L. J.", year = 1951,
#'   title = "Coefficient alpha and the internal structure of tests",
#'   container = "Psychometrika", volume = "16", issue = "3",
#'   pages = "297-334", cited_by = "scale:satisfaction"
#' )
#' ref$id
sf_reference <- function(id,
                         title,
                         author    = NULL,
                         year      = NULL,
                         type      = "article-journal",
                         container = NULL,
                         volume    = NULL,
                         issue     = NULL,
                         pages     = NULL,
                         publisher = NULL,
                         edition   = NULL,
                         editor    = NULL,
                         doi       = NULL,
                         url       = NULL,
                         version   = NULL,
                         language  = NULL,
                         cited_by  = NULL) {
  if (!is.character(id) || length(id) != 1L || !grepl(sframe_reference_id_pattern, id)) {
    sframe_abort_validation(paste0(
      "A reference id must be one citation key that starts with a letter, ",
      "digit or underscore, for example 'cohen_1988'. Got '",
      paste(id, collapse = ", "), "'."
    ))
  }
  if (!is.character(title) || length(title) != 1L || !nzchar(trimws(title))) {
    sframe_abort_validation(paste0("Reference '", id, "' needs a title."))
  }
  type <- rlang::arg_match0(type, sframe_reference_types)
  cited_by <- sframe_reference_targets(cited_by, id)

  record <- list(
    id = id,
    type = type,
    title = trimws(title),
    author = sframe_reference_names(author),
    editor = sframe_reference_names(editor),
    issued = sframe_reference_issued(year),
    `container-title` = sframe_reference_text(container),
    volume = sframe_reference_text(volume),
    issue = sframe_reference_text(issue),
    page = sframe_reference_text(pages),
    publisher = sframe_reference_text(publisher),
    edition = sframe_reference_text(edition),
    DOI = sframe_reference_doi(doi),
    URL = sframe_reference_text(url),
    version = sframe_reference_text(version),
    language = sframe_reference_text(language),
    cited_by = cited_by
  )
  structure(Filter(Negate(is.null), record), class = "sf_reference")
}

#' @export
print.sf_reference <- function(x, ...) {
  names <- vapply(x$author %||% list(), function(a) a$family %||% a$literal %||% "",
                  character(1))
  year <- x$issued$`date-parts`[[1]][[1]] %||% "n.d."
  cat("<sf_reference> [@", x$id, "] ", paste(names, collapse = ", "),
      if (length(names)) " " else "", "(", year, "). ", x$title, "\n", sep = "")
  if (length(x$cited_by)) cat("  cited by: ", paste(x$cited_by, collapse = ", "), "\n", sep = "")
  invisible(x)
}

# "Family, Given" or "{Organisation}" to CSL name objects. A name with no comma
# is read as "Given Family", the last word being the family name.
sframe_reference_names <- function(x) {
  if (is.null(x) || length(x) == 0) return(NULL)
  if (is.list(x) && !is.null(names(x[[1]]))) return(unname(x))
  x <- trimws(as.character(unlist(x)))
  x <- x[nzchar(x)]
  if (!length(x)) return(NULL)
  lapply(x, function(name) {
    if (grepl("^\\{.*\\}$", name)) return(list(literal = sub("^\\{(.*)\\}$", "\\1", name)))
    if (grepl(",", name, fixed = TRUE)) {
      parts <- trimws(strsplit(name, ",", fixed = TRUE)[[1]])
      out <- list(family = parts[1])
      if (length(parts) > 1 && nzchar(parts[2])) out$given <- paste(parts[-1], collapse = ", ")
      return(out)
    }
    words <- strsplit(name, "\\s+")[[1]]
    if (length(words) == 1) return(list(literal = name))
    list(family = words[length(words)], given = paste(words[-length(words)], collapse = " "))
  })
}

sframe_reference_issued <- function(year) {
  if (is.null(year) || length(year) == 0 || is.na(year[1]) || !nzchar(as.character(year[1]))) return(NULL)
  value <- suppressWarnings(as.integer(year[1]))
  if (is.na(value)) return(list(literal = as.character(year[1])))
  list(`date-parts` = list(list(value)))
}

sframe_reference_text <- function(x) {
  if (is.null(x) || length(x) == 0 || is.na(x[1])) return(NULL)
  x <- trimws(as.character(x[1]))
  if (nzchar(x)) x else NULL
}

sframe_reference_doi <- function(x) {
  x <- sframe_reference_text(x)
  if (is.null(x)) return(NULL)
  sub("^(https?://(dx\\.)?doi\\.org/|doi:\\s*)", "", x, ignore.case = TRUE)
}

sframe_reference_targets <- function(x, id) {
  if (is.null(x) || length(x) == 0) return(NULL)
  x <- unique(trimws(as.character(unlist(x))))
  bad <- x[!grepl(sframe_reference_target_pattern, x)]
  if (length(bad)) {
    sframe_abort_validation(paste0(
      "Reference '", id, "' has cited_by target(s) ", paste0("'", bad, "'", collapse = ", "),
      ". Use 'instrument', 'item:<id>', 'scale:<id>', 'plan:<block id>' or 'model:<id>'."
    ))
  }
  x
}

#' Read references from BibTeX
#'
#' Parses BibTeX, the format Google Scholar, Zotero, Mendeley and most journal
#' pages export, into [sf_reference()] records. Covers the common entry types
#' (`@article`, `@book`, `@incollection`, `@inbook`, `@inproceedings`,
#' `@techreport`, `@phdthesis`, `@mastersthesis`, `@misc`, `@online`,
#' `@software`, `@dataset`, `@unpublished`) and the common fields. Accented
#' letters written as LaTeX commands are converted. Needs no other package.
#'
#' @param file Path to a `.bib` file.
#' @param text BibTeX as a character string, used instead of `file`, for
#'   example an entry pasted from Google Scholar.
#' @param cited_by Optional `cited_by` targets given to every entry read, see
#'   [sf_reference()].
#'
#' @return A list of `sf_reference` objects, named by citation key. An entry
#'   that cannot be read is skipped with a warning naming it.
#' @export
#' @examples
#' refs <- read_bibtex(text = "@article{cronbach_1951,
#'   author  = {Cronbach, Lee J.},
#'   title   = {Coefficient alpha and the internal structure of tests},
#'   journal = {Psychometrika},
#'   year    = {1951},
#'   volume  = {16},
#'   number  = {3},
#'   pages   = {297--334}
#' }")
#' names(refs)
read_bibtex <- function(file = NULL, text = NULL, cited_by = NULL) {
  if (is.null(text)) {
    if (is.null(file) || !file.exists(file)) {
      sframe_abort_validation("read_bibtex() needs a `file` that exists, or `text`.")
    }
    text <- paste(readLines(file, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  }
  text <- paste(text, collapse = "\n")
  entries <- sframe_bibtex_entries(text)
  out <- list()
  for (entry in entries) {
    ref <- tryCatch(sframe_bibtex_to_reference(entry, cited_by), error = function(e) {
      rlang::warn(paste0("BibTeX entry '", entry$key, "' was skipped: ", conditionMessage(e)),
                  class = "sframe_warning")
      NULL
    })
    if (!is.null(ref)) out[[ref$id]] <- ref
  }
  out
}

# Splits BibTeX into entries by brace depth, so a value holding braces or an
# "@" does not end an entry early. @comment, @preamble and @string are skipped.
sframe_bibtex_entries <- function(text) {
  chars <- strsplit(text, "")[[1]]
  n <- length(chars)
  entries <- list()
  i <- 1L
  while (i <= n) {
    if (chars[i] != "@") { i <- i + 1L; next }
    head_end <- i + 1L
    while (head_end <= n && !chars[head_end] %in% c("{", "(")) head_end <- head_end + 1L
    if (head_end > n) break
    type <- tolower(trimws(paste(chars[(i + 1L):(head_end - 1L)], collapse = "")))
    close <- if (chars[head_end] == "{") "}" else ")"
    depth <- 1L
    j <- head_end + 1L
    while (j <= n && depth > 0L) {
      if (chars[j] == "{" || (close == ")" && chars[j] == "(")) depth <- depth + 1L
      else if (chars[j] == close) depth <- depth - 1L
      j <- j + 1L
    }
    body <- paste(chars[(head_end + 1L):(j - 2L)], collapse = "")
    i <- j
    if (type %in% c("comment", "preamble", "string") || !nzchar(type)) next
    comma <- regexpr(",", body, fixed = TRUE)
    if (comma < 0) next
    entries[[length(entries) + 1L]] <- list(
      type = type,
      key = trimws(substr(body, 1L, comma - 1L)),
      fields = sframe_bibtex_fields(substr(body, comma + 1L, nchar(body)))
    )
  }
  entries
}

sframe_bibtex_fields <- function(body) {
  chars <- strsplit(body, "")[[1]]
  n <- length(chars)
  fields <- list()
  i <- 1L
  while (i <= n) {
    while (i <= n && (grepl("\\s", chars[i]) || chars[i] == ",")) i <- i + 1L
    if (i > n) break
    eq <- i
    while (eq <= n && chars[eq] != "=") eq <- eq + 1L
    if (eq > n) break
    name <- tolower(trimws(paste(chars[i:(eq - 1L)], collapse = "")))
    k <- eq + 1L
    while (k <= n && grepl("\\s", chars[k])) k <- k + 1L
    if (k > n) break
    if (chars[k] == "{") {
      depth <- 1L
      m <- k + 1L
      while (m <= n && depth > 0L) {
        if (chars[m] == "{") depth <- depth + 1L else if (chars[m] == "}") depth <- depth - 1L
        m <- m + 1L
      }
      value <- paste(chars[(k + 1L):(m - 2L)], collapse = "")
      i <- m
    } else if (chars[k] == "\"") {
      m <- k + 1L
      depth <- 0L
      while (m <= n && !(chars[m] == "\"" && depth == 0L)) {
        if (chars[m] == "{") depth <- depth + 1L else if (chars[m] == "}") depth <- depth - 1L
        m <- m + 1L
      }
      value <- paste(chars[(k + 1L):(m - 1L)], collapse = "")
      i <- m + 1L
    } else {
      m <- k
      while (m <= n && chars[m] != ",") m <- m + 1L
      value <- trimws(paste(chars[k:(m - 1L)], collapse = ""))
      i <- m
    }
    if (nzchar(name)) fields[[name]] <- value
  }
  fields
}

# LaTeX accent commands and escapes to plain UTF-8 text. Covers the commands
# reference managers actually write. Remaining braces are protective and go.
sframe_bibtex_clean <- function(x, keep_braces = FALSE) {
  if (is.null(x)) return(NULL)
  accents <- list(
    "'" = c(a = "\u00e1", e = "\u00e9", i = "\u00ed", o = "\u00f3", u = "\u00fa", y = "\u00fd",
            A = "\u00c1", E = "\u00c9", I = "\u00cd", O = "\u00d3", U = "\u00da", c = "\u0107", n = "\u0144", s = "\u015b", z = "\u017a"),
    "`" = c(a = "\u00e0", e = "\u00e8", i = "\u00ec", o = "\u00f2", u = "\u00f9", A = "\u00c0", E = "\u00c8"),
    "\"" = c(a = "\u00e4", e = "\u00eb", i = "\u00ef", o = "\u00f6", u = "\u00fc", A = "\u00c4", O = "\u00d6", U = "\u00dc", y = "\u00ff"),
    "^" = c(a = "\u00e2", e = "\u00ea", i = "\u00ee", o = "\u00f4", u = "\u00fb"),
    "~" = c(a = "\u00e3", n = "\u00f1", o = "\u00f5", N = "\u00d1"),
    "c" = c(c = "\u00e7", C = "\u00c7", s = "\u015f"),
    "v" = c(c = "\u010d", s = "\u0161", z = "\u017e", r = "\u0159", e = "\u011b", C = "\u010c", S = "\u0160", Z = "\u017d")
  )
  for (cmd in names(accents)) {
    for (letter in names(accents[[cmd]])) {
      esc <- if (cmd %in% c("c", "v")) paste0("\\\\", cmd, "\\s*") else paste0("\\\\\\", cmd)
      x <- gsub(paste0("\\{", esc, "\\{?", letter, "\\}?\\}"), accents[[cmd]][[letter]], x, perl = TRUE)
      x <- gsub(paste0(esc, "\\{?", letter, "\\}?"), accents[[cmd]][[letter]], x, perl = TRUE)
    }
  }
  x <- gsub("\\{\\\\ss\\}|\\\\ss\\b", "\u00df", x, perl = TRUE)
  x <- gsub("\\{\\\\o\\}", "\u00f8", x, perl = TRUE)
  x <- gsub("\\{\\\\aa\\}", "\u00e5", x, perl = TRUE)
  x <- gsub("\\\\([&%$#_{}])", "\\1", x, perl = TRUE)
  x <- gsub("\\\\textendash\\b|\\\\textemdash\\b", "-", x, perl = TRUE)
  x <- gsub("---?", "-", x, perl = TRUE)
  x <- gsub("~", " ", x, fixed = TRUE)
  if (!keep_braces) x <- gsub("[{}]", "", x, perl = TRUE)
  trimws(gsub("\\s+", " ", x, perl = TRUE))
}

# Splits an author list on " and " outside braces, so "{Johnson and Johnson}"
# stays one organisation.
sframe_bibtex_split_names <- function(x) {
  if (is.null(x) || !nzchar(trimws(x))) return(NULL)
  chars <- strsplit(x, "")[[1]]
  depth <- 0L
  marks <- integer(0)
  for (i in seq_along(chars)) {
    if (chars[i] == "{") depth <- depth + 1L
    else if (chars[i] == "}") depth <- depth - 1L
    else if (depth == 0L && i + 4L <= length(chars) &&
             tolower(paste(chars[i:(i + 4L)], collapse = "")) == " and ") marks <- c(marks, i)
  }
  starts <- c(1L, marks + 5L)
  ends <- c(marks - 1L, length(chars))
  names <- trimws(substring(x, starts, ends))
  vapply(names[nzchar(names)], function(name) {
    # A whole name in braces is an organisation: keep it as one literal.
    if (grepl("^\\{[^{}]*\\}$", name)) return(paste0("{", sframe_bibtex_clean(name), "}"))
    sframe_bibtex_clean(name)
  }, character(1), USE.NAMES = FALSE)
}

sframe_bibtex_type <- function(type, fields) {
  switch(type,
    article = "article-journal",
    book = , booklet = "book",
    incollection = , inbook = "chapter",
    inproceedings = , conference = "paper-conference",
    techreport = , report = "report",
    phdthesis = , mastersthesis = , thesis = "thesis",
    online = , electronic = , www = "webpage",
    software = "software",
    dataset = , data = "dataset",
    unpublished = "manuscript",
    misc = if (!is.null(fields$url) || !is.null(fields$howpublished)) "webpage" else "document",
    "document"
  )
}

sframe_bibtex_to_reference <- function(entry, cited_by = NULL) {
  f <- entry$fields
  key <- entry$key
  if (!grepl(sframe_reference_id_pattern, key)) {
    rlang::abort(paste0("its key is not a valid citation key"))
  }
  title <- sframe_bibtex_clean(f$title)
  if (is.null(title) || !nzchar(title)) rlang::abort("it has no title")
  type <- sframe_bibtex_type(entry$type, f)
  container <- f$journal %||% f$journaltitle %||% f$booktitle %||% f$series
  year <- f$year %||% (if (!is.null(f$date)) substr(f$date, 1, 4))
  sf_reference(
    id = key,
    title = title,
    author = sframe_bibtex_split_names(f$author),
    editor = sframe_bibtex_split_names(f$editor),
    year = sframe_bibtex_clean(year),
    type = type,
    container = sframe_bibtex_clean(container),
    volume = sframe_bibtex_clean(f$volume),
    issue = sframe_bibtex_clean(f$number %||% f$issue),
    pages = sframe_bibtex_clean(f$pages),
    publisher = sframe_bibtex_clean(f$publisher %||% f$institution %||% f$school %||% f$organization),
    edition = sframe_bibtex_clean(f$edition),
    doi = sframe_bibtex_clean(f$doi),
    url = sframe_bibtex_clean(f$url),
    version = sframe_bibtex_clean(f$version),
    language = sframe_bibtex_clean(f$langid %||% f$language),
    cited_by = cited_by
  )
}

#' Add references to an instrument
#'
#' Attaches [sf_reference()] records to an instrument. A reference whose id is
#' already present replaces the old one when `replace = TRUE`, and is refused
#' otherwise, so a second source cannot silently take over a citation key.
#' `cited_by` targets of a replaced reference are merged.
#'
#' Adding references changes the file hash, as any edit does, and leaves the
#' content hash that [amend_sframe()] records unchanged: citing a source is
#' disclosure, not a change to the design.
#'
#' @param instrument An `sframe` object.
#' @param ... `sf_reference` objects, or lists of them such as
#'   [read_bibtex()] returns.
#' @param replace Logical. Replace a reference with the same id.
#'
#' @return The instrument, with the references added.
#' @export
#' @examples
#' instr <- sf_instrument("Demo", components = list(
#'   sf_item("q1", "How satisfied are you?", "likert", choice_set = "agree5"),
#'   sf_choices("agree5", 1:5, c("SD", "D", "N", "A", "SA"))
#' ))
#' instr <- add_references(instr, sf_reference(
#'   "likert_1932", "A technique for the measurement of attitudes",
#'   author = "Likert, R.", year = 1932, container = "Archives of Psychology",
#'   volume = "22", issue = "140", pages = "1-55", cited_by = "item:q1"
#' ))
#' length(sframe_references(instr))
add_references <- function(instrument, ..., replace = FALSE) {
  sframe_check_instrument(instrument)
  refs <- sframe_flatten_references(list(...))
  current <- instrument$references %||% list()
  ids <- vapply(current, function(r) r$id, character(1))
  for (ref in refs) {
    at <- match(ref$id, ids)
    if (is.na(at)) {
      current[[length(current) + 1L]] <- ref
      ids <- c(ids, ref$id)
    } else if (isTRUE(replace)) {
      ref$cited_by <- unique(c(current[[at]]$cited_by, ref$cited_by)) %||% NULL
      if (!length(ref$cited_by)) ref$cited_by <- NULL
      current[[at]] <- ref
    } else {
      sframe_abort_validation(paste0(
        "The instrument already has a reference with id '", ref$id,
        "'. Use replace = TRUE to replace it, or give the new one another id."
      ))
    }
  }
  instrument$references <- current
  instrument
}

sframe_flatten_references <- function(x) {
  out <- list()
  for (el in x) {
    if (inherits(el, "sf_reference")) out[[length(out) + 1L]] <- el
    else if (is.list(el)) out <- c(out, sframe_flatten_references(el))
    else sframe_abort_validation("add_references() takes sf_reference objects, or lists of them.")
  }
  out
}

#' List an instrument's references
#'
#' @param instrument An `sframe` object.
#' @param cited_by Optional target, for example `"scale:satisfaction"`, to
#'   list only the references cited there.
#'
#' @return A list of `sf_reference` objects, named by id.
#' @export
#' @examples
#' instr <- sframe_demo("likert_scale")$instrument
#' sframe_references(instr)
sframe_references <- function(instrument, cited_by = NULL) {
  sframe_check_instrument(instrument)
  refs <- instrument$references %||% list()
  if (!is.null(cited_by)) refs <- Filter(function(r) any(cited_by %in% (r$cited_by %||% character(0))), refs)
  stats::setNames(refs, vapply(refs, function(r) r$id, character(1)))
}

#' Write a bibliography as CSL-JSON
#'
#' Writes the references a report cites as CSL-JSON, which pandoc, Quarto and
#' reference managers read directly. It holds the instrument's own
#' references, the method references of any analysis results given, and any
#' further references a host supplies, each once. [render_report()] uses this
#' for its References section, and a host that builds its own documents can
#' use the same file.
#'
#' @param instrument An `sframe` object, or `NULL`.
#' @param results Optional results from [run_analysis_plan()], whose methods'
#'   references are included.
#' @param extra Optional further `sf_reference` objects, for example the
#'   references a host keeps for the write-up.
#' @param file Path to write. When `NULL`, the CSL-JSON is returned as a
#'   string.
#'
#' @return The path, invisibly, or the JSON string when `file` is `NULL`.
#' @export
#' @examples
#' instr <- sframe_demo("two_group")$instrument
#' cat(substr(sframe_bibliography(instr), 1, 200))
sframe_bibliography <- function(instrument = NULL, results = NULL, extra = NULL, file = NULL) {
  refs <- list()
  if (!is.null(instrument)) refs <- c(refs, sframe_references(instrument))
  if (!is.null(extra)) refs <- c(refs, sframe_flatten_references(list(extra)))
  refs <- c(refs, sframe_method_references(results))
  seen <- character(0)
  records <- list()
  for (ref in refs) {
    if (ref$id %in% seen) next
    seen <- c(seen, ref$id)
    records[[length(records) + 1L]] <- sframe_reference_csl(ref)
  }
  json <- jsonlite::toJSON(records, auto_unbox = TRUE, pretty = TRUE, null = "null")
  if (is.null(file)) return(as.character(json))
  writeLines(json, file, useBytes = TRUE)
  invisible(file)
}

# The record a citation processor reads: the `cited_by` links are surveyframe's
# own and are dropped, and `date-parts` keeps its nested array shape.
sframe_reference_csl <- function(ref) {
  out <- unclass(ref)
  out$cited_by <- NULL
  out
}

# Plain form for the .sframe payload. `cited_by` stays an array when it holds
# one target, so the file shape does not depend on how many there are.
sframe_reference_plain <- function(ref) {
  out <- unclass(ref)
  if (!is.null(out$cited_by)) out$cited_by <- I(unname(as.character(out$cited_by)))
  out
}

sframe_restore_reference <- function(r) {
  if (!is.null(r$cited_by)) r$cited_by <- as.character(unlist(r$cited_by))
  if (!length(r$cited_by)) r$cited_by <- NULL
  structure(r, class = "sf_reference")
}

# Every problem with an instrument's references, as messages for
# validate_sframe()'s "references" check.
sframe_reference_problems <- function(instrument) {
  refs <- instrument$references %||% list()
  if (!length(refs)) return(character(0))
  problems <- character(0)
  ids <- vapply(refs, function(r) as.character(r$id %||% ""), character(1))
  bad <- ids[!grepl(sframe_reference_id_pattern, ids)]
  if (length(bad)) problems <- c(problems, paste0("Invalid reference id(s): ", paste0("'", bad, "'", collapse = ", "), "."))
  dup <- unique(ids[duplicated(ids)])
  if (length(dup)) problems <- c(problems, paste0("Duplicate reference id(s): ", paste(dup, collapse = ", "), "."))
  for (r in refs) {
    if (!nzchar(trimws(as.character(r$title %||% "")))) problems <- c(problems, paste0("Reference '", r$id, "' has no title."))
  }
  known <- list(
    item = vapply(instrument$items %||% list(), function(x) as.character(x$id %||% ""), character(1)),
    scale = vapply(instrument$scales %||% list(), function(x) as.character(x$id %||% ""), character(1)),
    plan = vapply(instrument$analysis_plan %||% list(), function(x) as.character(x$id %||% ""), character(1)),
    model = vapply(instrument$models %||% list(), function(x) as.character(x$id %||% ""), character(1))
  )
  for (r in refs) {
    for (target in r$cited_by %||% character(0)) {
      if (identical(target, "instrument")) next
      kind <- sub(":.*$", "", target)
      id <- sub("^[a-z]+:", "", target)
      if (!grepl(sframe_reference_target_pattern, target) || !kind %in% names(known)) {
        problems <- c(problems, paste0("Reference '", r$id, "' is cited by '", target, "', which is not a target surveyframe knows."))
      } else if (!id %in% known[[kind]]) {
        problems <- c(problems, paste0("Reference '", r$id, "' is cited by ", kind, " '", id, "', which is missing from the instrument."))
      }
    }
  }
  problems
}

# The citation keys a set of analysis results relies on, in first-use order.
sframe_method_reference_keys <- function(results) {
  if (is.null(results)) return(character(0))
  blocks <- if (!is.null(results$block_id) || !is.null(results$citations)) list(results) else results
  keys <- character(0)
  for (r in blocks) {
    if (is.list(r)) keys <- c(keys, names(r$citations %||% list()))
  }
  unique(keys[nzchar(keys)])
}

sframe_method_references <- function(results) {
  keys <- sframe_method_reference_keys(results)
  Filter(Negate(is.null), lapply(keys, sframe_builtin_reference))
}

# A built-in method reference as an sf_reference. The 2 whose year or version
# follows the running software are filled in at call time, as their APA
# strings in .sframe_citations are.
sframe_builtin_reference <- function(key) {
  rec <- .sframe_citation_csl[[key]]
  if (is.null(rec)) return(NULL)
  if (identical(key, "surveyframe")) {
    rec$issued <- list(`date-parts` = list(list(as.integer(.sframe_release_year()))))
    rec$version <- tryCatch(as.character(utils::packageVersion("surveyframe")), error = function(e) NULL)
  } else if (identical(key, "r_core")) {
    rec$issued <- list(`date-parts` = list(list(as.integer(R.version$year))))
  }
  structure(c(list(id = key), rec), class = "sf_reference")
}

# The 30 built-in method references as CSL-JSON, transcribed from the APA
# strings in .sframe_citations (R/analysis_plan.R). test-references.R formats
# each one through pandoc with the bundled APA style and compares it with that
# string, so a transcription slip fails a test.
.n <- function(family, given) list(family = family, given = given)
.yr <- function(y) list(`date-parts` = list(list(as.integer(y))))
.sframe_citation_csl <- list(
  field_2018 = list(type = "book", author = list(.n("Field", "A.")), issued = .yr(2018),
    title = "Discovering statistics using IBM SPSS statistics", edition = "5", publisher = "SAGE"),
  cohen_1988 = list(type = "book", author = list(.n("Cohen", "J.")), issued = .yr(1988),
    title = "Statistical power analysis for the behavioral sciences", edition = "2", publisher = "Lawrence Erlbaum"),
  fisher_1925 = list(type = "book", author = list(.n("Fisher", "R. A.")), issued = .yr(1925),
    title = "Statistical methods for research workers", publisher = "Oliver & Boyd"),
  shapiro_1965 = list(type = "article-journal", author = list(.n("Shapiro", "S. S."), .n("Wilk", "M. B.")), issued = .yr(1965),
    title = "An analysis of variance test for normality", `container-title` = "Biometrika", volume = "52", issue = "3-4", page = "591-611"),
  mann_1947 = list(type = "article-journal", author = list(.n("Mann", "H. B."), .n("Whitney", "D. R.")), issued = .yr(1947),
    title = "On a test of whether one of two random variables is stochastically larger than the other",
    `container-title` = "Annals of Mathematical Statistics", volume = "18", issue = "1", page = "50-60"),
  kruskal_1952 = list(type = "article-journal", author = list(.n("Kruskal", "W. H."), .n("Wallis", "W. A.")), issued = .yr(1952),
    title = "Use of ranks in one-criterion variance analysis", `container-title` = "Journal of the American Statistical Association",
    volume = "47", issue = "260", page = "583-621"),
  spearman_1904 = list(type = "article-journal", author = list(.n("Spearman", "C.")), issued = .yr(1904),
    title = "The proof and measurement of association between two things", `container-title` = "The American Journal of Psychology",
    volume = "15", issue = "1", page = "72-101"),
  kendall_1938 = list(type = "article-journal", author = list(.n("Kendall", "M. G.")), issued = .yr(1938),
    title = "A new measure of rank correlation", `container-title` = "Biometrika", volume = "30", issue = "1/2", page = "81-93"),
  cronbach_1951 = list(type = "article-journal", author = list(.n("Cronbach", "L. J.")), issued = .yr(1951),
    title = "Coefficient alpha and the internal structure of tests", `container-title` = "Psychometrika", volume = "16", issue = "3", page = "297-334"),
  mcdonald_1999 = list(type = "book", author = list(.n("McDonald", "R. P.")), issued = .yr(1999),
    title = "Test theory: A unified treatment", publisher = "Lawrence Erlbaum"),
  hosmer_2013 = list(type = "book", author = list(.n("Hosmer", "D. W."), .n("Lemeshow", "S."), .n("Sturdivant", "R. X.")), issued = .yr(2013),
    title = "Applied logistic regression", edition = "3", publisher = "Wiley"),
  firth_1993 = list(type = "article-journal", author = list(.n("Firth", "D.")), issued = .yr(1993),
    title = "Bias reduction of maximum likelihood estimates", `container-title` = "Biometrika", volume = "80", issue = "1", page = "27-38"),
  heinze_2002 = list(type = "article-journal", author = list(.n("Heinze", "G."), .n("Schemper", "M.")), issued = .yr(2002),
    title = "A solution to the problem of separation in logistic regression", `container-title` = "Statistics in Medicine",
    volume = "21", issue = "16", page = "2409-2419"),
  hwang_1981 = list(type = "book", author = list(.n("Hwang", "C.-L."), .n("Yoon", "K.")), issued = .yr(1981),
    title = "Multiple attribute decision making: Methods and applications", publisher = "Springer"),
  saaty_1980 = list(type = "book", author = list(.n("Saaty", "T. L.")), issued = .yr(1980),
    title = "The analytic hierarchy process", publisher = "McGraw-Hill"),
  saaty_1996 = list(type = "book", author = list(.n("Saaty", "T. L.")), issued = .yr(1996),
    title = "Decision making with dependence and feedback: The analytic network process", publisher = "RWS Publications"),
  gabus_1972 = list(type = "book", author = list(.n("Gabus", "A."), .n("Fontela", "E.")), issued = .yr(1972),
    title = "World problems, an invitation to further thought within the framework of DEMATEL", publisher = "Battelle Geneva Research Centre"),
  si_2018 = list(type = "article-journal", author = list(.n("Si", "S.-L."), .n("You", "X.-Y."), .n("Liu", "H.-C."), .n("Zhang", "P.")), issued = .yr(2018),
    title = "DEMATEL technique: A systematic review of the state-of-the-art literature on methodologies and applications",
    `container-title` = "Mathematical Problems in Engineering", volume = "2018", page = "3696457", DOI = "10.1155/2018/3696457"),
  opricovic_2004 = list(type = "article-journal", author = list(.n("Opricovic", "S."), .n("Tzeng", "G.-H.")), issued = .yr(2004),
    title = "Compromise solution by MCDM methods: A comparative analysis of VIKOR and TOPSIS",
    `container-title` = "European Journal of Operational Research", volume = "156", issue = "2", page = "445-455", DOI = "10.1016/S0377-2217(03)00020-1"),
  brauers_2006 = list(type = "article-journal", author = list(.n("Brauers", "W. K. M."), .n("Zavadskas", "E. K.")), issued = .yr(2006),
    title = "The MOORA method and its application to privatization in a transition economy",
    `container-title` = "Control and Cybernetics", volume = "35", issue = "2", page = "445-469"),
  edwards_1977 = list(type = "article-journal", author = list(.n("Edwards", "W.")), issued = .yr(1977),
    title = "How to use multiattribute utility measurement for social decisionmaking",
    `container-title` = "IEEE Transactions on Systems, Man, and Cybernetics", volume = "7", issue = "5", page = "326-340", DOI = "10.1109/TSMC.1977.4309720"),
  zavadskas_2012 = list(type = "article-journal",
    author = list(.n("Zavadskas", "E. K."), .n("Turskis", "Z."), .n("Antucheviciene", "J."), .n("Zakarevicius", "A.")), issued = .yr(2012),
    title = "Optimization of weighted aggregated sum product assessment", `container-title` = "Elektronika ir Elektrotechnika",
    volume = "122", issue = "6", page = "3-6", DOI = "10.5755/j01.eee.122.6.1810", language = "lt"),
  brans_1985 = list(type = "article-journal", author = list(.n("Brans", "J. P."), .n("Vincke", "P.")), issued = .yr(1985),
    title = "A preference ranking organisation method: The PROMETHEE method for multiple criteria decision-making",
    `container-title` = "Management Science", volume = "31", issue = "6", page = "647-656", DOI = "10.1287/mnsc.31.6.647"),
  roy_1968 = list(type = "article-journal", author = list(.n("Roy", "B.")), issued = .yr(1968),
    title = "Classement et choix en presence de points de vue multiples (la methode ELECTRE)",
    `container-title` = "Revue Francaise d'Informatique et de Recherche Operationnelle", volume = "2", issue = "1", page = "57-75", language = "fr"),
  macKinnon_2008 = list(type = "book", author = list(.n("MacKinnon", "D. P.")), issued = .yr(2008),
    title = "Introduction to statistical mediation analysis", publisher = "Lawrence Erlbaum"),
  aiken_1991 = list(type = "book", author = list(.n("Aiken", "L. S."), .n("West", "S. G.")), issued = .yr(1991),
    title = "Multiple regression: Testing and interpreting interactions", publisher = "SAGE"),
  blondel_2008 = list(type = "article-journal",
    author = list(.n("Blondel", "V. D."), .n("Guillaume", "J.-L."), .n("Lambiotte", "R."), .n("Lefebvre", "E.")), issued = .yr(2008),
    title = "Fast unfolding of communities in large networks", `container-title` = "Journal of Statistical Mechanics: Theory and Experiment",
    volume = "2008", issue = "10", page = "P10008", DOI = "10.1088/1742-5468/2008/10/P10008"),
  fruchterman_1991 = list(type = "article-journal", author = list(.n("Fruchterman", "T. M. J."), .n("Reingold", "E. M.")), issued = .yr(1991),
    title = "Graph drawing by force-directed placement", `container-title` = "Software: Practice and Experience",
    volume = "21", issue = "11", page = "1129-1164", DOI = "10.1002/spe.4380211102"),
  r_core = list(type = "book", author = list(list(literal = "R Core Team")),
    title = "R: A language and environment for statistical computing", publisher = "R Foundation for Statistical Computing"),
  surveyframe = list(type = "software", author = list(.n("Sharafuddin", "M. A.")),
    title = "surveyframe: Survey Instrument Workflows", URL = "https://github.com/MohammedAliSharafuddin/surveyframe")
)
rm(.n, .yr)

# An APA in-text citation for built-in method references, for renderers that
# do not run a citation processor: "(Cohen, 1988; Field, 2018)". 1 or 2
# authors are named, 3 or more become "et al.". Unknown keys are left out.
sframe_intext_citation <- function(keys) {
  parts <- character(0)
  for (key in unique(keys)) {
    ref <- sframe_builtin_reference(key)
    if (is.null(ref)) next
    fam <- vapply(ref$author %||% list(), function(a) a$family %||% a$literal %||% "", character(1))
    who <- if (length(fam) >= 3) paste(fam[1], "et al.") else paste(fam, collapse = " & ")
    year <- ref$issued$`date-parts`[[1]][[1]] %||% "n.d."
    parts <- c(parts, paste0(who, ", ", year))
  }
  if (!length(parts)) return("")
  paste0("(", paste(sort(parts), collapse = "; "), ")")
}
