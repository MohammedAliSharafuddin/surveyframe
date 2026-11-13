# read_responses.R

#' Read and validate survey responses
#'
#' Loads survey response data and checks that it conforms to the instrument
#' specification. Column names in the response file must match item IDs defined
#' in the instrument. Non-item columns are allowed only when declared through
#' `respondent_id`, `submitted_at`, or `meta_cols`.
#'
#' # Columns
#'
#' A single-answer item has one column named by its ID. A matrix, ranking,
#' multiple-choice or decision item has one column per row, option, pair or
#' criterion, named `item__sub`, and each is checked: a battery with some of its
#' columns absent is reported by name. Two columns with the same name are
#' refused, since one would otherwise be lost.
#'
#' A choice set with `allow_other` ("Other, please specify") adds
#' `<id>__other_text` to a single choice item, whose own column then holds
#' the code `"other"` when Other is chosen, and `<id>__other` (1 or 0) and
#' `<id>__other_text` to a multiple choice item.
#'
#' # Records
#'
#' Every row of a file must have as many fields as its header. When every
#' data row has exactly 1 field more and that field is empty in all of them,
#' as a trailing separator gives, the field is dropped with a message. Any
#' other row of a different width is refused, naming the lines, since reading
#' it would move answers into the wrong columns. In a file of 1 column, a
#' blank line is a respondent who left the question unanswered, so it is kept
#' as a missing answer, except after the last line that holds anything.
#'
#' # Values
#'
#' A CSV file is read as text, so identifiers such as `001`, dates and text
#' answers arrive exactly as written, a literal `NA` included. Columns of items
#' with numeric responses (numeric, slider and rating items, choice items whose
#' codes are all numbers, and ranking, multiple-choice and decision expansion
#' columns) are then converted to numbers, with an empty cell or `NA` read as
#' missing. A column that does not convert cleanly is kept as text, with a
#' warning naming the column and up to 3 of the values. In every column, a
#' blank answer (an empty cell, or only spaces) is missing, and a factor
#' column of a data frame becomes text. The column
#' of a single choice item that allows Other, and every `<id>__other_text`
#' column, stay text. Data frames
#' go through the same conversion, so a CSV file and a data frame holding the
#' same responses read the same.
#'
#' @param x A file path to a delimited text file, a `data.frame`, or a `tibble`.
#' @param instrument An `sframe` object created by [sframe_instrument()].
#' @param respondent_id Character or NULL. The name of the column containing
#'   unique respondent identifiers. If NULL, no respondent ID column is
#'   expected.
#' @param submitted_at Character or NULL. The name of the column containing
#'   submission timestamps.
#' The metadata columns surveyframe's own collectors write, `respondent_id`,
#' `response_id`, `started_at` and `submitted_at`, are recognised without being
#' declared: a file this package collected reads back without naming the columns
#' it wrote. Anything else outside the instrument still has to be declared, or
#' `strict = FALSE` used.
#'
#' @param meta_cols Character vector or NULL. Additional column names, outside
#'   the item IDs, to retain (for example, condition assignment or
#'   source URL).
#' @param strict Logical. When `TRUE` (default), a column outside the declared
#'   item IDs, their expansion columns and the metadata columns is an error,
#'   naming the columns. When `FALSE`, such columns are kept, placed last, with
#'   a warning.
#' @param delim `NULL` (default), `","`, `";"` or `"\t"`. The field separator
#'   of a file. When `NULL` it is detected from the header line as a comma,
#'   semicolon or tab, and a message names the separator when it is not a
#'   comma. A semicolon file is read the way Excel writes one in a comma
#'   decimal locale, so a comma is the decimal mark in its numeric columns
#'   (`3,5` reads as 3.5). A byte order mark is ignored. Not used for data
#'   frames.
#'
#' @return A `data.frame` with columns ordered as: metadata columns first, then
#'   item columns in instrument order, each item followed by its expansion
#'   columns, then any undeclared columns kept under `strict = FALSE`. To keep
#'   an extra column under `strict = TRUE`, name it in `meta_cols`, or select
#'   the columns you need before reading.
#' @export
#' @seealso [sframe_quality_results()], [score_scales()]
#'
#' @examples
#' responses <- read_responses(
#'   x = system.file("extdata", "tourism_services_responses.csv",
#'                   package = "surveyframe"),
#'   instrument = read_sframe(
#'     system.file("extdata", "tourism_services_demo.sframe",
#'                 package = "surveyframe")
#'   ),
#'   respondent_id = "respondent_id",
#'   submitted_at = "submitted_at",
#'   meta_cols = "started_at"
#' )
#' head(responses[, c("respondent_id", "visit_type", "dm_1")])
#' @family Responses functions
read_responses <- function(
    x,
    instrument,
    respondent_id = NULL,
    submitted_at  = NULL,
    meta_cols     = NULL,
    strict        = TRUE,
    delim         = NULL
) {
  sframe_check_instrument(instrument)

  dec <- "."
  # Load data
  if (is.character(x)) {
    if (!file.exists(x)) {
      sframe_abort_import(
        paste0("Response file not found: '", x, "'. Check the file path and ensure the file exists."),
        path = x
      )
    }
    # Read as text, with only an empty cell as missing. Type inference turned
    # an id of 001 into 1 and a text answer of NA into a missing value.
    # Declared numeric columns are converted below, for both routes.
    sep <- sframe_resolve_delim(x, delim)
    if (!identical(sep, ",")) {
      rlang::inform(paste0(
        "Reading '", basename(x), "' with ",
        c(";" = "a semicolon", "\t" = "a tab")[[sep]],
        " as the separator",
        if (identical(sep, ";")) " and a comma as the decimal mark",
        "."))
    }
    if (identical(sep, ";")) dec <- ","
    data <- sframe_read_csv_records(x, sep)
    # A byte order mark stays out of the first name. Re-encoding the file to
    # drop it would stop at the first byte that is not UTF-8, which cut a
    # Windows-1252 export short.
    if (ncol(data)) names(data)[1] <- sub("^\ufeff", "", names(data)[1])
  } else if (is.data.frame(x)) {
    data <- sframe_as_data_frame(x)
  } else {
    rlang::abort(
      "`x` must be a CSV file path, a data.frame, or a tibble.",
      class = c("sframe_import_error", "sframe_error")
    )
  }

  dup <- unique(colnames(data)[duplicated(colnames(data))])
  if (length(dup) > 0) {
    sframe_abort_import(paste0(
      "The response data has more than one column named ",
      paste0("'", dup, "'", collapse = ", "),
      ". Rename or remove the duplicate, since one of them would be lost."))
  }

  all_item_ids <- vapply(instrument$items, function(i) i$id, character(1))
  display_only_types <- c("section_break", "text_block")
  response_items <- Filter(
    function(i) !identical(i$type %in% display_only_types, TRUE),
    instrument$items
  )
  item_ids <- vapply(response_items, function(i) i$id, character(1))
  display_item_ids <- setdiff(all_item_ids, item_ids)
  # surveyframe's own collectors write respondent_id, response_id, started_at
  # and submitted_at, so those names count as declared without the researcher
  # naming columns the package itself produced. Before this, reading a
  # collected file strictly meant listing started_at in meta_cols, and adding
  # respondent_id to the Shiny row would have broken every caller who had.
  declared  <- c(respondent_id, submitted_at, meta_cols,
                 sframe_reserved_response_columns)
  data_cols <- colnames(data)

  # Matrix and ranking items arrive from the collectors as one column per
  # sub-item or option (item__sub, item__option). Accept those expansions
  # alongside the base id: an expanded multi-column item is not "missing"
  # when its base column is absent, and its expansion columns are never
  # "undeclared".
  # Shared with validate_sframe() so the accepted expansion columns cannot
  # drift between what the reader accepts and what design-time validation
  # recognises. See sframe_item_expansion_columns() in R/decision_data.R.
  expanded_ids <- sframe_item_expansion_columns(instrument, response_items)
  multi_ids <- vapply(
    Filter(function(i) identical(i$type, "matrix") ||
             identical(i$type, "ranking") ||
             identical(i$type, "multiple_choice") ||
             i$type %in% sframe_expanded_comparison_types, response_items),
    function(i) i$id, character(1)
  )
  # An item is present through its expected expansion columns, never through
  # any column that happens to share its prefix. Some expected columns present
  # and some absent is reported separately, by name.
  partial <- character(0)
  covered_by_expansion <- multi_ids[vapply(multi_ids, function(id) {
    item <- response_items[[which(item_ids == id)]]
    expected <- sframe_item_expansion_columns(instrument, list(item))
    if (length(expected) == 0) return(any(startsWith(data_cols, paste0(id, "__"))))
    present <- intersect(expected, data_cols)
    if (length(present) > 0 && length(present) < length(expected)) {
      partial <<- c(partial, setdiff(expected, present))
    }
    length(present) > 0
  }, logical(1))]
  if (length(partial) > 0) {
    sframe_warn_missing(paste0(
      sframe_count_noun(length(partial), "expansion column"),
      sframe_plural(length(partial), " is", " are"), " absent from the response data ",
      "for items whose other columns are present: ", paste(partial, collapse = ", ")))
  }

  # Detect R's automatic name repair before reporting the corresponding
  # declared expansion columns as missing. In strict mode the import cannot
  # continue, so emitting a missing-column warning immediately before the
  # more useful name-repair error only obscures the actionable diagnosis.
  undeclared <- setdiff(data_cols,
                        c(item_ids, expanded_ids, display_item_ids, declared))
  known <- c(item_ids, expanded_ids, display_item_ids, declared)
  mangled <- undeclared[make.names(undeclared) == undeclared &
                          undeclared %in% make.names(known)]
  hint <- if (length(mangled) > 0) {
    originals <- known[make.names(known) %in% mangled]
    paste0(
      " ", length(mangled), " of these match a declared column after R's",
      " name repair (for example '", originals[1], "' became '",
      mangled[1], "'), so the header was most likely rewritten on import.",
      " Re-read the file with check.names = FALSE, as in",
      " read.csv(path, check.names = FALSE)."
    )
  } else {
    ""
  }
  if (strict && length(mangled) > 0) {
    sframe_abort_import(paste0(
      sframe_count_noun(length(undeclared), "undeclared column"), " found in response data: ",
      paste(undeclared, collapse = ", "),
      ". Declare them in meta_cols or set strict = FALSE.", hint
    ))
  }

  # Check required item columns are present.
  missing_items <- setdiff(item_ids, c(data_cols, covered_by_expansion))
  if (length(missing_items) > 0) {
    sframe_warn_missing(
      paste0(
        sframe_count_noun(length(missing_items), "item column"),
        sframe_plural(length(missing_items), " is", " are"),
        " absent from the response data: ",
        paste(missing_items, collapse = ", ")
      )
    )
  }

  # Handle other undeclared columns.
  if (length(undeclared) > 0) {
    # A matrix row or choice label containing a space produces an expansion
    # column with a space, which the collectors write correctly. read.csv()
    # then rewrites it: "q1__Row one" arrives as "q1__Row.one", because
    # check.names defaults to TRUE. The columns are then undeclared through no
    # fault of the researcher, and the plain message sends them looking for a
    # declaration problem that does not exist. Name the real cause instead.
    if (strict) {
      sframe_abort_import(
        paste0(
          sframe_count_noun(length(undeclared), "undeclared column"),
          " found in response data: ",
          paste(undeclared, collapse = ", "),
          ". Declare them in meta_cols or set strict = FALSE.",
          hint
        )
      )
    } else {
      sframe_warn_quality(
        paste0(
          sframe_count_noun(length(undeclared), "undeclared column"),
          " retained with a warning: ",
          paste(undeclared, collapse = ", ")
        )
      )
    }
  }

  # Reorder: metadata first, then items in instrument order (expanded
  # columns follow their base item), then undeclared
  ordered_item_cols <- unlist(lapply(response_items, function(i) {
    c(i$id, expanded_ids[startsWith(expanded_ids, paste0(i$id, "__"))])
  }), use.names = FALSE)
  ordered_cols <- intersect(
    c(declared, ordered_item_cols, display_item_ids, undeclared),
    data_cols
  )

  out <- sframe_as_data_frame(data[, ordered_cols, drop = FALSE])
  sframe_convert_declared_columns(out, instrument, response_items, dec)
}

# TRUE when a choice set's codes are numbers: numeric, or text that survives
# a numeric round trip. Codes like "01" read as numbers would lose their
# leading zero, so they are text. The codes are compared as declared:
# trimmed, " 1" counted as numeric and the answer " 1" became 1, a code the
# set does not hold (P3-04). The 1 test for the reader and
# export_responses(), which tested as.numeric() alone and wrote "01", "02"
# to .sav and .dta as 1 and 2 (P3-03).
sframe_codes_are_numbers <- function(values) {
  if (is.numeric(values)) return(TRUE)
  codes <- as.character(values)
  if (!length(codes)) return(FALSE)
  num <- suppressWarnings(as.numeric(codes))
  back <- vapply(num, format, character(1), scientific = FALSE,
                 trim = TRUE, digits = 15)
  all(!is.na(num) & back == codes)
}

# The response columns whose values are numbers, from the instrument, so only
# they are converted and identifiers, dates and text stay as written.
sframe_numeric_response_columns <- function(instrument, response_items) {
  numeric_codes <- function(item) {
    for (cs in instrument$choices %||% list()) {
      if (identical(cs$id, item$choice_set)) return(sframe_codes_are_numbers(cs$values))
    }
    FALSE
  }
  cols <- character(0)
  for (item in response_items) {
    type <- item$type
    # A single choice that allows Other holds the code "other" beside the
    # set's own codes, so its column stays text whatever the codes look like.
    other_code <- identical(type, "single_choice") &&
      sframe_item_allows_other(instrument, item)
    if (type %in% c("numeric", "slider", "rating") ||
        (type %in% c("likert", "single_choice") && !other_code && numeric_codes(item))) {
      cols <- c(cols, item$id)
    }
    if (identical(type, "matrix") && numeric_codes(item)) {
      cols <- c(cols, sframe_item_expansion_columns(instrument, list(item)))
    }
    if (type %in% c("ranking", "multiple_choice", sframe_expanded_comparison_types)) {
      cols <- c(cols, setdiff(sframe_item_expansion_columns(instrument, list(item)),
                           sframe_other_text_columns(instrument, list(item))))
    }
  }
  unique(cols)
}

# Pick the field separator from the header line, or check an explicit one.
sframe_resolve_delim <- function(path, delim = NULL) {
  if (!is.null(delim)) {
    if (!is.character(delim) || length(delim) != 1L ||
        !delim %in% c(",", ";", "\t")) {
      sframe_abort_import(
        "`delim` must be NULL, \",\", \";\" or \"\\t\" (a comma, semicolon or tab).",
        path = path)
    }
    return(delim)
  }
  header <- readLines(path, n = 1L, warn = FALSE, encoding = "UTF-8")
  if (length(header) == 0L) return(",")
  header <- sub("^\ufeff", "", header)
  header <- gsub("\"[^\"]*\"", "", header)
  counts <- vapply(c(",", ";", "\t"),
                   function(ch) lengths(regmatches(header, gregexpr(ch, header, fixed = TRUE))),
                   integer(1))
  if (max(counts) == 0L) return(",")
  names(counts)[which.max(counts)]
}

# TRUE where a value is a blank answer: an empty string, or only white
# space. The 1 rule for a blank answer, in the reader and at the top of every
# analysis runner (P3-05, P2-04).
sframe_is_blank <- function(x) {
  if (!is.character(x) && !is.factor(x)) return(rep(FALSE, length(x)))
  x <- as.character(x)
  # Byte-wise, so text that is not valid UTF-8 (a Windows-1252 export) is
  # tested, not refused.
  !is.na(x) & grepl("^[[:space:]]*$", x, useBytes = TRUE)
}

# Blank answers as NA. A factor comes back as text, as the reader keeps every
# answer as written.
sframe_blank_to_na <- function(x) {
  if (is.factor(x)) x <- as.character(x)
  if (!is.character(x)) return(x)
  x[sframe_is_blank(x)] <- NA_character_
  x
}

# Blank to NA first, for every text or factor column, then the declared
# numeric columns to numbers. A factor column kept its "" (only text columns
# were cleaned), and a declared numeric column with 1 value that did not
# convert stayed text, kept its "", and said nothing (P3-05). It now gives a
# warning naming the column and up to 3 of the values.
sframe_convert_declared_columns <- function(data, instrument, response_items,
                                            dec = ".") {
  for (col in colnames(data)) {
    if (is.character(data[[col]]) || is.factor(data[[col]])) {
      data[[col]] <- sframe_blank_to_na(data[[col]])
    }
  }
  for (col in intersect(sframe_numeric_response_columns(instrument, response_items),
                        colnames(data))) {
    x <- data[[col]]
    if (is.numeric(x)) {
      data[[col]] <- as.numeric(x)
      next
    }
    if (!is.character(x)) next
    text <- trimws(x)
    text[!is.na(text) & text == "NA"] <- NA_character_
    if (identical(dec, ",")) text <- sub(",", ".", text, fixed = TRUE)
    converted <- suppressWarnings(as.numeric(text))
    bad <- !is.na(text) & is.na(converted)
    if (!any(bad)) {
      data[[col]] <- converted
    } else {
      shown <- unique(x[bad])
      rlang::warn(paste0(
        "Column '", col, "' holds numeric answers, and ",
        sframe_count_noun(sum(bad), "value"), " did not read as a number (",
        paste0("\"", utils::head(shown, 3), "\"", collapse = ", "),
        if (length(shown) > 3) ", ..." else "",
        "), so the column stays text. Correct or remove ",
        if (sum(bad) == 1) "that value" else "those values",
        " to analyse it as numbers."),
        class = "sframe_warning")
    }
  }
  data
}

# Reads a delimited response file as text, every record checked against the
# header's width first (P3-01). read.csv() took a file whose data rows had 1
# field more than the header (a trailing separator, as spreadsheets write) and
# made its first column the row names: every answer and the respondent id
# moved 1 column left, with no warning. A record of another width is refused,
# naming the first 3 lines and both counts. The 1 exception is a file where
# every data row has exactly 1 extra field and it is empty in all of them:
# that field is dropped with a message.
sframe_read_csv_records <- function(x, sep) {
  widths <- utils::count.fields(x, sep = sep, quote = "\"", comment.char = "",
                                blank.lines.skip = FALSE)
  header <- widths[1]
  # NA marks a line inside a quoted field that spans lines, 0 a blank line.
  line <- seq_along(widths)
  rows <- !is.na(widths) & widths > 0 & line > 1
  wrong <- rows & widths != header
  read_text <- function(...) {
    utils::read.csv(x, sep = sep, stringsAsFactors = FALSE, check.names = FALSE,
                    colClasses = "character", na.strings = character(0), ...)
  }
  if (!any(wrong)) {
    if (!identical(header, 1L)) return(read_text())
    # In a file of 1 column, an unanswered respondent's row is a blank line,
    # which read.csv() skipped, so the respondent was lost (P3-02). Blank
    # lines are kept, except those after the last line holding anything.
    data <- read_text(blank.lines.skip = FALSE)
    trailing <- length(widths) - max(which(!is.na(widths) & widths > 0))
    if (trailing > 0 && nrow(data) >= trailing) {
      data <- data[seq_len(nrow(data) - trailing), , drop = FALSE]
    }
    return(data)
  }
  if (all(widths[rows] == header + 1L)) {
    raw <- utils::read.table(x, sep = sep, quote = "\"", header = FALSE,
                             comment.char = "", colClasses = "character",
                             na.strings = character(0), fill = TRUE,
                             col.names = paste0("V", seq_len(header + 1L)),
                             strip.white = FALSE)
    if (all(raw[-1, header + 1L] == "")) {
      data <- stats::setNames(raw[-1, seq_len(header), drop = FALSE],
                              as.character(unlist(raw[1, seq_len(header)])))
      rownames(data) <- NULL
      rlang::inform(paste0(
        "Every data row of '", basename(x), "' ends with an empty field after the last ",
        "column of its header, as a trailing separator gives. The empty field is dropped."))
      return(data)
    }
  }
  bad <- line[wrong]
  sframe_abort_import(paste0(
    "'", basename(x), "' has rows whose number of fields differs from its header's ",
    header, ": line", if (length(bad) > 1) "s" else "", " ",
    paste(utils::head(bad, 3), collapse = ", "),
    if (length(bad) > 3) paste0(" and ", length(bad) - 3, " more") else "",
    " (", paste(utils::head(widths[wrong], 3), collapse = ", "), " fields). ",
    "Reading it would move answers into the wrong columns. Check the separator ",
    "and quoting, or fix those rows."), path = x)
}
