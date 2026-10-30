# utils.R
# Shared internal helpers.

# Minimal HTML escaping for internal report rendering. Collapses a vector
# to one space-joined string first, so this is for a single scalar of
# text (a caption, a title, a message), never for a vector whose elements
# must stay in separate table cells: use htmltools_escape_each() for that.
htmltools_escape <- function(x) {
  if (length(x) == 0 || all(is.na(x))) {
    return("")
  }

  x <- paste(as.character(x), collapse = " ")
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  x
}

# Same escaping, element by element, with no collapsing: for building one
# table header or one table row, where each vector element must become
# its own <th>/<td> rather than being merged into the neighbouring cell.
htmltools_escape_each <- function(x) {
  vapply(x, function(el) htmltools_escape(el), character(1))
}

sframe_as_data_frame <- function(x) {
  data.frame(x, stringsAsFactors = FALSE, check.names = FALSE)
}

# A single id/value -> label lookup for an instrument, covering item ids,
# scale ids, and every choice set's coded values, built once per instrument
# and reused everywhere a result needs to show what a respondent saw
# instead of the id or code it was stored under. First writer wins on a
# collision (an item/scale id takes priority over a choice value that
# happens to share the same string, since ids and choice codes are drawn
# from different, non-overlapping namespaces in practice).
sframe_label_lookup <- function(instrument) {
  if (is.null(instrument) || !inherits(instrument, "sframe")) {
    return(character(0))
  }
  lookup <- character(0)
  add <- function(id, label) {
    if (is.null(id) || !nzchar(id) || is.null(label) || is.na(label) || !nzchar(label)) return()
    if (!id %in% names(lookup)) lookup[[id]] <<- label
  }
  for (i in instrument$items %||% list()) add(i$id, i$label)
  for (s in instrument$scales %||% list()) add(s$id, s$label)

  # A choice code is scoped to its choice set, and this dictionary has no
  # column context to scope by. A code meaning 2 different things in 2 sets
  # used to take whichever label was read first, so "1" from a frequency item
  # printed as "Strongly disagree". A code carrying one meaning across the
  # whole instrument still relabels; an ambiguous one stays as its code, and
  # sframe_item_value_labels() gives the labels where the item is known.
  code_labels <- list()
  for (cs in instrument$choices %||% list()) {
    vals <- as.character(cs$values %||% character(0))
    labs <- as.character(cs$labels %||% character(0))
    if (length(vals) != length(labs)) next
    for (k in seq_along(vals)) {
      code_labels[[vals[k]]] <- unique(c(code_labels[[vals[k]]], labs[k]))
    }
  }
  ids <- names(lookup)
  for (code in names(code_labels)) {
    if (length(code_labels[[code]]) == 1) add(code, code_labels[[code]])
  }
  # Mark which entries are choice codes, so sframe_humanize_table() can keep
  # them out of cells that hold statistics.
  attr(lookup, "codes") <- setdiff(names(lookup), ids)
  lookup
}

# The value labels for one item, read through the choice set it names. This is
# the context-aware counterpart to sframe_label_lookup(), for a caller that
# knows which item a column holds.
sframe_item_value_labels <- function(instrument, item_id) {
  if (is.null(instrument) || !inherits(instrument, "sframe")) {
    return(character(0))
  }
  ids <- vapply(instrument$items %||% list(),
                function(i) as.character(i$id %||% "")[1], character(1))
  hit <- match(as.character(item_id)[1], ids)
  if (is.na(hit)) return(character(0))
  set_id <- as.character(instrument$items[[hit]]$choice_set %||% "")[1]
  if (!nzchar(set_id)) return(character(0))
  for (cs in instrument$choices %||% list()) {
    if (!identical(as.character(cs$id %||% "")[1], set_id)) next
    vals <- as.character(cs$values %||% character(0))
    labs <- as.character(cs$labels %||% character(0))
    if (length(vals) != length(labs)) return(character(0))
    return(stats::setNames(labs, vals))
  }
  character(0)
}

# Replace ids and coded values with their labels wherever they appear in a
# result table: row names, column names, and character-column cell values.
# A blanket, single-pass substitution rather than a per-test-type change,
# so every table shape (frequency, crosstab, group comparison, regression
# coefficients, and so on) reads in respondent-facing language without
# touching each runner's own table-building code.
#
# `exclude_cols` opts specific columns (by their pre-relabel name) out of
# cell-value substitution, for a column whose values are free text rather
# than coded values (a text-family result's `term`/`term_a`/`match`
# column): a respondent's own word can otherwise collide with an unrelated
# item's choice CODE anywhere in the instrument and get silently swapped
# for that item's choice LABEL (found in review_050; a comment containing
# "pool" read back as "Pool area" because some other item happened to code
# a choice "pool"). Column names and row names are still relabelled
# normally; only cell values in an excluded column are left alone, so a
# genuinely coded column on the same table (a `group` column, say) keeps
# humanising as before.
sframe_humanize_table <- function(tbl, lookup, exclude_cols = character(0)) {
  if (!is.data.frame(tbl) || nrow(tbl) == 0 || length(lookup) == 0) {
    return(tbl)
  }
  relabel <- function(x, dict = lookup) {
    hit <- dict[x]
    ifelse(is.na(hit), x, unname(hit))
  }
  # A choice code such as "2" is also a number a statistic can take (CX-21:
  # "Suggested factors" 2 printed as "Disagree"). Ids relabel in any cell.
  # Codes relabel only in a column of response values: none of its cells is
  # a number that is not a code, and the table is not a statistic and value
  # layout, whose cells are statistics by construction.
  codes <- intersect(attr(lookup, "codes") %||% character(0), names(lookup))
  ids_only <- lookup[setdiff(names(lookup), codes)]
  numeric_like <- function(x) {
    grepl("^[<>=]?\\s*[-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?%?$", trimws(x))
  }
  stat_layout <- "Statistic" %in% names(tbl)
  response_col <- function(x) {
    if (stat_layout || length(codes) == 0) return(FALSE)
    x <- x[!is.na(x) & nzchar(x)]
    length(x) > 0 && !any(numeric_like(x) & !x %in% codes)
  }
  orig_names <- names(tbl)
  rn <- rownames(tbl)
  if (!is.null(rn) && !identical(rn, as.character(seq_len(nrow(tbl))))) {
    rownames(tbl) <- relabel(rn)
  }
  names(tbl) <- relabel(names(tbl))
  char_cols <- vapply(tbl, is.character, logical(1))
  char_cols[orig_names %in% exclude_cols] <- FALSE
  tbl[char_cols] <- lapply(tbl[char_cols], function(x) {
    sframe_label_terms(relabel(x, if (response_col(x)) lookup else ids_only), ids_only)
  })
  tbl
}

# An interaction term such as attendee_role:format as its labels joined by a
# times sign (CX-20). A cell whose parts are not all ids is left alone.
sframe_label_terms <- function(x, ids) {
  if (!length(ids)) return(x)
  vapply(x, function(s) {
    if (is.na(s) || !grepl(":", s, fixed = TRUE)) return(s)
    parts <- strsplit(s, ":", fixed = TRUE)[[1]]
    if (length(parts) < 2 || !all(parts %in% names(ids))) return(s)
    paste(unname(ids[parts]), collapse = " \u00d7 ")
  }, character(1), USE.NAMES = FALSE)
}

# Result text names a variable by its label in the instrument and a group by
# its choice label, as the tables and charts beside it do (CX-20). Each
# runner puts the name in where it puts the id, so the template's own words
# stay as they are. The instrument is set once around the runner call.
.sframe_text_label_env <- new.env(parent = emptyenv())

.sframe_with_text_labels <- function(instrument, code) {
  old <- as.list(.sframe_text_label_env)
  .sframe_text_label_env$instrument <- instrument
  .sframe_text_label_env$lookup <- sframe_label_lookup(instrument)
  on.exit({
    .sframe_text_label_env$instrument <- old$instrument
    .sframe_text_label_env$lookup <- old$lookup
  }, add = TRUE)
  force(code)
}

# A variable as result text names it: its label in double quotes, since a
# label is often a question, or the id where it has none. A choice column
# from a multiple-response item (`item__code`) reads as the item's label and
# the choice's label, after a colon unless the item label ends a sentence.
sframe_text_var <- function(id) {
  lookup <- .sframe_text_label_env$lookup
  # A label's own double quotes become single ones, as APA 7 nests them,
  # so "He said 'yes' today" reads unambiguously.
  in_quotes <- function(s) paste0("\"", gsub("\"", "'", s, fixed = TRUE), "\"")
  ids <- lookup[setdiff(names(lookup), attr(lookup, "codes"))]
  vapply(as.character(id), function(i) {
    if (is.na(i)) return(i)
    if (i %in% names(ids)) return(in_quotes(ids[[i]]))
    cut <- regexpr("__", i, fixed = TRUE)
    if (cut > 0) {
      base <- substr(i, 1, cut - 1)
      opt <- substr(i, cut + 2, nchar(i))
      if (base %in% names(ids)) {
        sep <- if (grepl("[?.!:]$", ids[[base]])) " " else ": "
        return(in_quotes(paste0(ids[[base]], sep, sframe_text_value(base, opt))))
      }
    }
    i
  }, character(1), USE.NAMES = FALSE)
}

# A coded value of `item` as its choice label, or the code where the item's
# choice set has none.
sframe_text_value <- function(item, code) {
  labs <- sframe_item_value_labels(.sframe_text_label_env$instrument, item)
  code <- as.character(code)
  ifelse(!is.na(code) & code %in% names(labs), unname(labs[code]), code)
}

# One seam for optional-package availability checks. Besides keeping runners
# consistent, this lets their missing-dependency branches be tested on a
# machine where the optional package happens to be installed.
sframe_has_package <- function(package) {
  requireNamespace(package, quietly = TRUE)
}
