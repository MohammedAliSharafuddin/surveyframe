# R/text_analysis.R
# Text and open-ended response analysis: cleaning, base-R term/n-gram
# frequency, keyword-in-context, and co-occurrence. See todo_0.5.md for the
# full 9-method-id build plan; this file grows across that build rather than
# landing complete in one diff.

# A small built-in English stop-word list so the base path (no tidytext
# installed) has sensible defaults. Based on the Snowball project's English
# stop word list (Porter, M., snowballstem.org/algorithms/english/stop.txt),
# which the project states is in the public domain; trimmed to single-word,
# non-contraction-fragment entries (the Snowball list also includes phrases
# like "she'd've", which .sframe_tokenise's own tokeniser never produces).
.sframe_text_stopwords_en <- c(
  "a", "about", "above", "after", "again", "against", "all", "am", "an",
  "and", "any", "are", "aren't", "as", "at", "be", "because", "been",
  "before", "being", "below", "between", "both", "but", "by", "can't",
  "cannot", "could", "couldn't", "did", "didn't", "do", "does", "doesn't",
  "doing", "don't", "down", "during", "each", "few", "for", "from",
  "further", "had", "hadn't", "has", "hasn't", "have", "haven't", "having",
  "he", "he'd", "he'll", "he's", "her", "here", "here's", "hers",
  "herself", "him", "himself", "his", "how", "how's", "i", "i'd", "i'll",
  "i'm", "i've", "if", "in", "into", "is", "isn't", "it", "it's", "its",
  "itself", "let's", "me", "more", "most", "mustn't", "my", "myself",
  "no", "nor", "not", "of", "off", "on", "once", "only", "or", "other",
  "ought", "our", "ours", "ourselves", "out", "over", "own", "same",
  "shan't", "she", "she'd", "she'll", "she's", "should", "shouldn't",
  "so", "some", "such", "than", "that", "that's", "the", "their",
  "theirs", "them", "themselves", "then", "there", "there's", "these",
  "they", "they'd", "they'll", "they're", "they've", "this", "those",
  "through", "to", "too", "under", "until", "up", "very", "was", "wasn't",
  "we", "we'd", "we'll", "we're", "we've", "were", "weren't", "what",
  "what's", "when", "when's", "where", "where's", "which", "while",
  "who", "who's", "whom", "why", "why's", "with", "won't", "would",
  "wouldn't", "you", "you'd", "you'll", "you're", "you've", "your",
  "yours", "yourself", "yourselves"
)

# Shared tokeniser for term_frequency() and ngram_frequency(), so the two
# can't drift on cleaning rules. Self-contained: lower-cases and strips
# punctuation itself (keeping internal apostrophes so "don't" survives as
# one token) rather than assuming the caller already ran
# clean_text_responses(), since term_frequency()/ngram_frequency() are
# usable standalone on any character vector. `stop_words = NULL` uses the
# built-in list above; `stop_words = character(0)` disables filtering.
#
# @return A list, one character vector of tokens per element of `text`.
.sframe_tokenise <- function(text, stop_words = NULL) {
  if (is.null(stop_words)) stop_words <- .sframe_text_stopwords_en
  text <- as.character(text)
  lapply(text, function(one) {
    if (is.na(one) || !nzchar(trimws(one))) return(character(0))
    one <- tolower(one)
    one <- gsub("[^a-z0-9' ]+", " ", one)
    toks <- strsplit(one, "\\s+")[[1]]
    toks <- toks[nzchar(toks)]
    # Strip stray leading/trailing apostrophes left by quoting punctuation
    # ("'great'" -> "great") without touching an internal one ("don't").
    toks <- gsub("^'+|'+$", "", toks)
    toks <- toks[nzchar(toks)]
    if (length(stop_words) > 0) toks <- toks[!(toks %in% stop_words)]
    toks
  })
}

#' Clean open-ended text responses for analysis
#'
#' Extracts one text/textarea item's responses from a response data frame and
#' applies light, configurable cleaning: lower-casing, punctuation removal,
#' and optional number stripping. Blank and missing responses are dropped
#' rather than kept as empty strings, since they carry no term-frequency
#' signal and would otherwise inflate downstream response counts.
#'
#' @param data A data.frame of responses.
#' @param item_id Character. The text/textarea item's column name.
#' @param lowercase Logical. Lower-case the text. Default `TRUE`.
#' @param remove_punct Logical. Strip punctuation. Default `TRUE`.
#' @param strip_numbers Logical. Strip digits. Default `FALSE`.
#' @param instrument Optional `sframe` instrument. When supplied, `item_id`
#'   is validated as a `"text"` or `"textarea"` item before cleaning.
#'
#' @return A character vector of cleaned responses, with an integer
#'   `"respondent"` attribute giving each entry's original row index in
#'   `data`, so quotes extracted later can cite a respondent.
#' @export
clean_text_responses <- function(data, item_id, lowercase = TRUE,
                                  remove_punct = TRUE, strip_numbers = FALSE,
                                  instrument = NULL) {
  if (!is.null(instrument)) {
    sframe_check_instrument(instrument)
    item <- Find(function(i) identical(i$id, item_id), instrument$items %||% list())
    if (is.null(item)) {
      rlang::abort(paste0("No item '", item_id, "' found in the instrument."),
                   class = "sframe_error")
    }
    if (!item$type %in% c("text", "textarea")) {
      rlang::abort(
        paste0("Item '", item_id, "' is type '", item$type,
               "', not 'text' or 'textarea'."),
        class = "sframe_error"
      )
    }
  }
  if (!item_id %in% colnames(data)) {
    rlang::abort(paste0("Column '", item_id, "' not found in data."),
                 class = "sframe_error")
  }
  raw <- as.character(data[[item_id]])
  keep <- !is.na(raw) & nzchar(trimws(raw))
  respondent <- which(keep)
  txt <- raw[keep]
  if (isTRUE(lowercase)) txt <- tolower(txt)
  if (isTRUE(strip_numbers)) txt <- gsub("[0-9]+", "", txt)
  if (isTRUE(remove_punct)) txt <- gsub("[^[:alnum:][:space:]']+", " ", txt)
  txt <- trimws(gsub("\\s+", " ", txt))
  structure(txt, respondent = respondent)
}

#' Term frequency for open-ended text
#'
#' Tokenises `text` (splitting on whitespace, lower-casing, and stripping
#' punctuation), removes stop words, and counts term frequency. Ships a
#' small built-in English stop-word list so this works with zero optional
#' packages; pass `stop_words = character(0)` to disable filtering, or a
#' custom vector to override it.
#'
#' @param text Character vector of responses (raw or already cleaned by
#'   [clean_text_responses()]).
#' @param stop_words Character vector of words to exclude, or `NULL` to use
#'   the built-in English list, or `character(0)` for no filtering.
#' @param top_n Integer. Maximum number of terms to return, most frequent
#'   first. Default `30`.
#'
#' @return A data.frame with columns `term`, `n`, and `pct`.
#' @export
term_frequency <- function(text, stop_words = NULL, top_n = 30L) {
  toks <- unlist(.sframe_tokenise(text, stop_words), use.names = FALSE)
  if (!length(toks)) {
    return(data.frame(term = character(0), n = integer(0), pct = numeric(0),
                       stringsAsFactors = FALSE))
  }
  tbl <- sort(table(toks), decreasing = TRUE)
  total <- sum(tbl)
  out <- data.frame(
    term = names(tbl),
    n    = as.integer(tbl),
    pct  = round(as.numeric(tbl) / total * 100, 1),
    stringsAsFactors = FALSE, row.names = NULL
  )
  utils::head(out, top_n)
}

# Minimum usable responses below which text runners refuse to compute rather
# than produce a garbage "trend" from a handful of free-text answers.
.sframe_text_min_responses <- 10L

# Runner contract wrapper around term_frequency(): $table, apa (n_responses
# and the top term), prompt. `roles$item` names the text/textarea item;
# `options$group` (see sframe_run_one_block()'s group-role resolution)
# optionally splits by a nominal/ordinal covariate, one block of table rows
# per level, guarded per group as well as overall.
sframe_run_term_freq <- function(data, roles, options, instrument) {
  item_id <- sframe_role_values(roles, "item", "")[1]
  err <- sframe_require_columns(data, item_id, "Term frequency")
  if (!is.null(err)) return(list(test = "term_freq", error = err))
  top_n <- options$top_n %||% 30L
  group_id <- options$group %||% NULL

  build_one <- function(cleaned) {
    n_resp <- length(cleaned)
    if (n_resp < .sframe_text_min_responses) {
      return(list(
        table = NULL,
        error = sprintf(
          "Term frequency needs at least %d usable responses (found %d).",
          .sframe_text_min_responses, n_resp
        )
      ))
    }
    list(table = term_frequency(cleaned, stop_words = options$stop_words,
                                 top_n = top_n), error = NULL)
  }

  cleaned_all <- clean_text_responses(data, item_id, instrument = instrument)

  if (is.null(group_id) || !nzchar(group_id) || !group_id %in% colnames(data)) {
    built <- build_one(cleaned_all)
    if (!is.null(built$error)) return(list(test = "term_freq", error = built$error))
    return(list(
      test = "term_freq", variable = item_id,
      n = length(cleaned_all), table = built$table,
      apa = sprintf("Term frequency for %s (N = %d responses, top term \"%s\").",
                    item_id, length(cleaned_all),
                    if (nrow(built$table) > 0) built$table$term[1] else "none"),
      prompt = "Review the leading terms for coherence with the research question."
    ))
  }

  # Grouped path: split the *original* row set by group level, then clean
  # each subset the same way, so the respondent attribute (row index) stays
  # correct within each group's cleaned vector.
  group_vals <- as.character(data[[group_id]])
  respondent_of_cleaned <- attr(cleaned_all, "respondent")
  levels_present <- sort(unique(stats::na.omit(group_vals[respondent_of_cleaned])))
  blocks <- lapply(levels_present, function(lv) {
    idx <- respondent_of_cleaned[group_vals[respondent_of_cleaned] == lv]
    subset_txt <- structure(cleaned_all[respondent_of_cleaned %in% idx], respondent = idx)
    built <- build_one(subset_txt)
    if (!is.null(built$error)) {
      return(data.frame(group = lv, term = NA_character_, n = NA_integer_,
                         pct = NA_real_, note = built$error,
                         stringsAsFactors = FALSE))
    }
    tbl <- built$table
    if (nrow(tbl) == 0) return(NULL)
    tbl$group <- lv
    tbl$note <- NA_character_
    tbl[c("group", "term", "n", "pct", "note")]
  })
  blocks <- Filter(Negate(is.null), blocks)
  combined <- if (length(blocks)) do.call(rbind, blocks) else
    data.frame(group = character(0), term = character(0), n = integer(0),
               pct = numeric(0), note = character(0), stringsAsFactors = FALSE)
  list(
    test = "term_freq", variable = item_id, group = group_id,
    n = length(cleaned_all), table = combined,
    apa = sprintf("Term frequency for %s by %s (N = %d responses, %d groups).",
                  item_id, group_id, length(cleaned_all), length(levels_present)),
    prompt = "Compare the leading terms across groups for coherence with the research question."
  )
}
