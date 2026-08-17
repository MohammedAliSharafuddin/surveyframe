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

# Pairwise within-response term co-occurrence on the top `top_n` terms
# (ranked the same way term_frequency() ranks them, so the 2 outputs agree
# on which terms matter). For every response, every unordered pair of
# distinct top terms both present in that response's token set counts once,
# regardless of how many times either token repeats within the response.
#
# @return A data.frame with columns `term_a`, `term_b`, `n`, one row per
#   pair with n > 0, sorted by n descending, term_a < term_b alphabetically.
.sframe_cooccurrence <- function(text, top_n = 20L, stop_words = NULL) {
  toks_by_resp <- .sframe_tokenise(text, stop_words)
  top <- term_frequency(text, stop_words = stop_words, top_n = top_n)
  if (nrow(top) < 2) {
    return(data.frame(term_a = character(0), term_b = character(0),
                       n = integer(0), stringsAsFactors = FALSE))
  }
  top_terms <- top$term
  pair_counts <- new.env(parent = emptyenv())
  for (toks in toks_by_resp) {
    present <- unique(toks[toks %in% top_terms])
    if (length(present) < 2) next
    pairs <- utils::combn(sort(present), 2, simplify = FALSE)
    for (p in pairs) {
      key <- paste(p[1], p[2], sep = "")
      pair_counts[[key]] <- (pair_counts[[key]] %||% 0L) + 1L
    }
  }
  keys <- ls(pair_counts)
  if (!length(keys)) {
    return(data.frame(term_a = character(0), term_b = character(0),
                       n = integer(0), stringsAsFactors = FALSE))
  }
  parts <- strsplit(keys, "", fixed = TRUE)
  out <- data.frame(
    term_a = vapply(parts, `[[`, character(1), 1),
    term_b = vapply(parts, `[[`, character(1), 2),
    n = as.integer(unlist(mget(keys, envir = pair_counts), use.names = FALSE)),
    stringsAsFactors = FALSE, row.names = NULL
  )
  out <- out[order(-out$n, out$term_a, out$term_b), ]
  row.names(out) <- NULL
  out
}

# Runner contract wrapper around .sframe_cooccurrence(): $table, apa
# (n_responses and n_pairs), prompt. `roles$item` names the text/textarea
# item; `options$top_n` (default 20L) sets how many top terms co-occurrence
# is computed over. No group role for this id.
sframe_run_co_occurrence <- function(data, roles, options, instrument) {
  item_id <- sframe_role_values(roles, "item", "")[1]
  err <- sframe_require_columns(data, item_id, "Co-occurrence")
  if (!is.null(err)) return(list(test = "co_occurrence", error = err))
  top_n <- options$top_n %||% 20L

  cleaned <- clean_text_responses(data, item_id, instrument = instrument)
  n_resp <- length(cleaned)
  if (n_resp < .sframe_text_min_responses) {
    return(list(
      test = "co_occurrence",
      error = sprintf(
        "Co-occurrence needs at least %d usable responses (found %d).",
        .sframe_text_min_responses, n_resp
      )
    ))
  }

  edges <- .sframe_cooccurrence(cleaned, top_n = top_n, stop_words = options$stop_words)
  if (nrow(edges) == 0) {
    return(list(test = "co_occurrence", error = "No co-occurring term pairs found."))
  }

  list(
    test = "co_occurrence", variable = item_id,
    n = n_resp, table = edges,
    apa = sprintf("Term co-occurrence for %s (N = %d responses, %d co-occurring pairs).",
                  item_id, n_resp, nrow(edges)),
    prompt = "Review the strongest co-occurring term pairs for coherence with the research question."
  )
}


# ---------------------------------------------------------------------------
# Topic models: LDA (topicmodels) and STM (stm)
# ---------------------------------------------------------------------------
#
# Both runners emit a $table with the same 4 core columns (topic, term, beta,
# rank), even though the 2 packages compute "beta" differently (LDA's is
# tidytext::tidy()'s per-topic word probability; STM's is exp() of the
# fitted content-covariate-free log word-topic distribution, fit$beta$logbeta,
# which is a probability over the vocabulary in exactly the same sense). This
# is deliberate: sframe_plot_topics() below reads that shared shape and needs
# no result$test dispatch to serve both. STM's table additionally carries a
# `proportion` column (mean per-document topic weight from fit$theta) since
# that is part of the brief's requested STM table, but it is not needed by
# the shared plot.
#
# The fitted model object ($fit$model) is runtime-only, exactly like every
# other run_analysis_plan() result (see R/read_write_sframe.R's
# sframe_restore_analysis_block(): only block *definitions* are persisted to
# a .sframe file, never computed results). It is kept on the result list
# only so extract_quotes() can read it back in the same R session; it must
# never be copied into anything JSON-safe (jsonlite::toJSON(), a builder
# payload, a hash target) and callers must not assume it survives a
# save/reload round trip.

# Guard shared by both topic-model runners: package plus minimum-response
# checks, returning either NULL (fine to proceed) or an error string.
.sframe_topic_model_guard <- function(cleaned, k, test) {
  n_resp <- length(cleaned)
  if (n_resp < .sframe_text_min_responses) {
    return(sprintf(
      "%s needs at least %d usable responses (found %d).",
      test, .sframe_text_min_responses, n_resp
    ))
  }
  NULL
}

#' Fit an LDA topic model on open-ended text
#'
#' Cleans the text item via [clean_text_responses()], tokenises with the
#' package's shared internal tokeniser (reused rather than a second
#' tidytext-based tokeniser, so LDA and `term_frequency()` can never
#' drift on cleaning/stop-word rules), casts the token counts to a
#' document-term matrix with `tidytext::cast_dtm()`, and fits
#' `topicmodels::LDA()`.
#'
#' @param data A data.frame of responses.
#' @param roles A list with `item`, the text/textarea item id.
#' @param options A list; `k` (topic count, default `4L`), `seed` (default
#'   `42L`), `stop_words` (passed through to the tokeniser).
#' @param instrument Optional `sframe` instrument, passed to
#'   [clean_text_responses()] for item-type validation.
#'
#' @return A runner-contract result list: `test = "topic_model_lda"`,
#'   `table` (topic/term/beta/rank, top 10 terms per topic), `fit` (a
#'   runtime-only list holding the LDA model object and the document-row-to-
#'   respondent mapping needed by [extract_quotes()]), `apa`, `prompt`. On
#'   failure: `list(test = "topic_model_lda", error = <message>)`.
#' @keywords internal
sframe_run_topic_model_lda <- function(data, roles, options, instrument) {
  item_id <- sframe_role_values(roles, "item", "")[1]
  err <- sframe_require_columns(data, item_id, "LDA topic model")
  if (!is.null(err)) return(list(test = "topic_model_lda", error = err))

  install_err <- tryCatch({
    sframe_require_tidytext(reason = "to build the document-term matrix for LDA.")
    sframe_require_topicmodels(reason = "to fit LDA topic models.")
    NULL
  }, error = function(e) conditionMessage(e))
  if (!is.null(install_err)) return(list(test = "topic_model_lda", error = install_err))

  k <- options$k %||% 4L
  seed <- options$seed %||% 42L

  cleaned <- clean_text_responses(data, item_id, instrument = instrument)
  guard_err <- .sframe_topic_model_guard(cleaned, k, "LDA topic modelling")
  if (!is.null(guard_err)) return(list(test = "topic_model_lda", error = guard_err))

  toks <- .sframe_tokenise(cleaned, options$stop_words)
  doc_ids <- rep(seq_along(toks), lengths(toks))
  terms <- unlist(toks, use.names = FALSE)
  if (!length(terms)) {
    return(list(test = "topic_model_lda",
                error = "No usable tokens remain after cleaning and stop-word removal."))
  }
  long <- as.data.frame(table(doc = doc_ids, term = terms), stringsAsFactors = FALSE)
  names(long) <- c("doc", "term", "n")
  long <- long[long$n > 0, , drop = FALSE]
  long$doc <- as.integer(as.character(long$doc))

  dtm <- tidytext::cast_dtm(long, doc, term, n)
  if (nrow(dtm) < k) {
    return(list(test = "topic_model_lda", error = sprintf(
      "LDA needs at least k = %d documents with usable tokens (found %d).",
      k, nrow(dtm)
    )))
  }

  fit <- topicmodels::LDA(dtm, k = k, control = list(seed = seed))

  beta_tbl <- tidytext::tidy(fit, matrix = "beta")
  top_terms <- do.call(rbind, lapply(split(beta_tbl, beta_tbl$topic), function(d) {
    d <- d[order(-d$beta), , drop = FALSE]
    d <- utils::head(d, 10)
    d$rank <- seq_len(nrow(d))
    d
  }))
  top_terms <- top_terms[order(top_terms$topic, top_terms$rank),
                          c("topic", "term", "beta", "rank")]
  rownames(top_terms) <- NULL

  # Row-to-respondent mapping: dtm rownames are the "doc" ids that survived
  # tokenising/stop-word removal (as characters, so re-parsed to integer
  # rather than trusted to sort numerically), indexing into
  # clean_text_responses()'s own "respondent" attribute.
  respondent_attr <- attr(cleaned, "respondent")
  dtm_respondent <- respondent_attr[as.integer(rownames(dtm))]

  topic1 <- top_terms[top_terms$topic == 1, , drop = FALSE]
  topic1_terms <- utils::head(topic1$term, 5)

  list(
    test = "topic_model_lda",
    variable = item_id,
    n = nrow(dtm),
    table = top_terms,
    fit = list(
      model = fit,                      # runtime-only, see file header note
      dtm_respondent = dtm_respondent
    ),
    apa = sprintf(
      "LDA topic model (k = %d, N = %d documents). Topic 1 top terms: %s.",
      k, nrow(dtm), paste(topic1_terms, collapse = ", ")
    ),
    prompt = "Review topic coherence and label each topic from its top terms."
  )
}

#' Fit a structural topic model (STM) on open-ended text
#'
#' Cleans the text item via [clean_text_responses()], tokenises with
#' `tidytext::unnest_tokens()` (tidyeval column names via `rlang::sym()` and
#' `!!`, not bare symbols; see the source comment at the tokenising step for
#' why), casts to a document-term matrix, converts it to `stm`'s corpus
#' format with `stm::readCorpus(type = "slam")` and `stm::prepDocuments()`,
#' and fits `stm::stm()` after a fixed `set.seed()` (stm's own fit is not
#' otherwise seed-stable).
#'
#' @inheritParams sframe_run_topic_model_lda
#'
#' @return A runner-contract result list: `test = "stm_topics"`, `table`
#'   (topic/proportion/term/beta/rank; proportion is the topic's mean
#'   document weight, beta its per-term probability, both from the fitted
#'   `stm` object), `fit` (a runtime-only list holding the `stm` model
#'   object and the document-to-respondent mapping needed by
#'   [extract_quotes()]), `apa`, `prompt`. On failure:
#'   `list(test = "stm_topics", error = <message>)`.
#' @keywords internal
sframe_run_stm_topics <- function(data, roles, options, instrument) {
  item_id <- sframe_role_values(roles, "item", "")[1]
  err <- sframe_require_columns(data, item_id, "STM topic model")
  if (!is.null(err)) return(list(test = "stm_topics", error = err))

  install_err <- tryCatch({
    sframe_require_stm(reason = "to fit structural topic models.")
    sframe_require_tidytext(reason = "to tokenise text for STM.")
    NULL
  }, error = function(e) conditionMessage(e))
  if (!is.null(install_err)) return(list(test = "stm_topics", error = install_err))

  k <- options$k %||% 3L
  seed <- options$seed %||% 42L

  cleaned <- clean_text_responses(data, item_id, instrument = instrument)
  guard_err <- .sframe_topic_model_guard(cleaned, k, "STM topic modelling")
  if (!is.null(guard_err)) return(list(test = "stm_topics", error = guard_err))

  # Tokenising step, isolated and tested on its own (test-text-topics.R):
  # tidytext::unnest_tokens() evaluates its column-name arguments (the
  # output and input columns) with NSE. A bare symbol assembled from a
  # variable inside a function (as.name("word") or similar) does not
  # resolve the way a literal name typed at the call site does; the fix
  # verified here is rlang::sym() to build the symbol and `!!` to splice it
  # in, i.e. the standard tidyeval pattern, not unnest_tokens_() (superseded
  # in current tidytext).
  doc_df <- data.frame(.doc = seq_along(cleaned), .text = cleaned,
                        stringsAsFactors = FALSE)
  word_sym <- rlang::sym(".word")
  text_sym <- rlang::sym(".text")
  tokenised <- tidytext::unnest_tokens(doc_df, !!word_sym, !!text_sym)

  stop_words <- options$stop_words
  if (is.null(stop_words)) stop_words <- .sframe_text_stopwords_en
  if (length(stop_words) > 0) {
    tokenised <- tokenised[!(tokenised$.word %in% stop_words), , drop = FALSE]
  }
  if (nrow(tokenised) == 0) {
    return(list(test = "stm_topics",
                error = "No usable tokens remain after cleaning and stop-word removal."))
  }

  counts <- as.data.frame(table(doc = tokenised$.doc, term = tokenised$.word),
                           stringsAsFactors = FALSE)
  names(counts) <- c("doc", "term", "n")
  counts <- counts[counts$n > 0, , drop = FALSE]
  counts$doc <- as.integer(as.character(counts$doc))

  dtm <- tidytext::cast_dtm(counts, doc, term, n)
  respondent_attr <- attr(cleaned, "respondent")
  dtm_respondent <- respondent_attr[as.integer(rownames(dtm))]

  corp <- stm::readCorpus(dtm, type = "slam")
  prepped <- stm::prepDocuments(corp$documents, corp$vocab, verbose = FALSE)
  # prepDocuments() can drop documents left empty after its own vocabulary
  # trimming; drop the same rows from the respondent map so it stays
  # aligned 1:1 with prepped$documents (and, in turn, with the fitted
  # model's per-document rows).
  if (!is.null(prepped$docs.removed) && length(prepped$docs.removed) > 0) {
    dtm_respondent <- dtm_respondent[-prepped$docs.removed]
  }

  if (length(prepped$documents) < k) {
    return(list(test = "stm_topics", error = sprintf(
      "STM needs at least k = %d documents with usable tokens (found %d).",
      k, length(prepped$documents)
    )))
  }

  set.seed(seed)
  fit <- stm::stm(prepped$documents, prepped$vocab, K = k, verbose = FALSE)

  proportions <- colMeans(fit$theta)
  beta_mat <- exp(fit$beta$logbeta[[1]])  # K x V probabilities, no content covariate
  vocab <- prepped$vocab
  top_terms <- do.call(rbind, lapply(seq_len(k), function(topic_i) {
    ord <- order(-beta_mat[topic_i, ])
    top <- utils::head(ord, 10)
    data.frame(
      topic = topic_i,
      proportion = round(proportions[topic_i], 4),
      term = vocab[top],
      beta = beta_mat[topic_i, top],
      rank = seq_along(top),
      stringsAsFactors = FALSE
    )
  }))
  rownames(top_terms) <- NULL

  list(
    test = "stm_topics",
    variable = item_id,
    n = length(prepped$documents),
    table = top_terms,
    fit = list(
      model = fit,                   # runtime-only, see file header note
      respondent = dtm_respondent
    ),
    apa = sprintf("STM topic model (k = %d, N = %d documents).",
                  k, length(prepped$documents)),
    prompt = "Review topic coherence and proportions, and label each topic from its top terms."
  )
}

#' Extract representative quotes for each STM topic
#'
#' Takes the result of [sframe_run_stm_topics()] (not a raw `stm` model
#' object) and, for each topic, pulls the top `n_quotes` documents by
#' topic-document probability using `stm::findThoughts()`, then maps each
#' one back to its original respondent row via the mapping
#' [sframe_run_stm_topics()] stored on `result$fit`.
#'
#' @param model A `stm_topics` result list from [sframe_run_stm_topics()]
#'   (i.e. `result`, not `result$fit` and not the raw `stm` object).
#' @param text The response vector the topic model was fit on, indexed by
#'   *original* row/respondent. Either the raw or [clean_text_responses()]-
#'   cleaned vector works, since both are indexed the same way; only the
#'   text actually quoted differs (cleaned text is lower-cased and stripped
#'   of punctuation).
#' @param n_quotes Integer. Quotes to return per topic. Default `3L`.
#'
#' @return A data.frame with columns `topic`, `rank`, `respondent` (the
#'   original row index in the data the model's `text` argument came from,
#'   not a document-matrix or corpus row index), and `quote`.
#' @export
extract_quotes <- function(model, text, n_quotes = 3L) {
  sframe_require_stm(reason = "to extract representative quotes.")
  if (!is.list(model) || is.null(model$fit) || is.null(model$fit$model) ||
      is.null(model$fit$respondent)) {
    rlang::abort(
      paste0("`model` must be a stm_topics result list from sframe_run_stm_topics(), ",
             "carrying $fit$model and $fit$respondent."),
      class = "sframe_error"
    )
  }
  fit <- model$fit$model
  respondent_map <- model$fit$respondent
  k <- fit$settings$dim$K

  # findThoughts() takes `texts` aligned 1:1 with the model's own document
  # rows (fit-document order), which is exactly what respondent_map indexes
  # into; `text` is indexed by original row, so re-index it into
  # fit-document order first.
  doc_texts <- as.character(text)[respondent_map]

  ft <- stm::findThoughts(fit, texts = doc_texts, topics = seq_len(k), n = n_quotes)

  rows <- lapply(seq_len(k), function(topic_i) {
    idx <- ft$index[[topic_i]]
    if (!length(idx)) return(NULL)
    data.frame(
      topic = topic_i,
      rank = seq_along(idx),
      respondent = respondent_map[idx],
      quote = doc_texts[idx],
      stringsAsFactors = FALSE
    )
  })
  rows <- Filter(Negate(is.null), rows)
  out <- if (length(rows)) do.call(rbind, rows) else {
    data.frame(topic = integer(0), rank = integer(0),
               respondent = integer(0), quote = character(0),
               stringsAsFactors = FALSE)
  }
  rownames(out) <- NULL
  out
}

#' N-gram frequency for open-ended text
#'
#' Tokenises `text` via the same tokeniser as [term_frequency()] (whitespace
#' splitting, lower-casing, punctuation stripping, and stop-word removal),
#' then slides a window of `n` tokens across each response's token vector
#' and counts how often each resulting n-gram occurs. `n = 2` (the default)
#' gives bigrams; `n = 3` gives trigrams. Because stop words are already
#' removed by the shared tokeniser, an n-gram never straddles a dropped
#' word; it is built only from tokens that survive filtering, in their
#' original order within each response.
#'
#' @param text Character vector of responses (raw or already cleaned by
#'   [clean_text_responses()]).
#' @param n Integer. N-gram size. Default `2` (bigrams).
#' @param stop_words Character vector of words to exclude, or `NULL` to use
#'   the built-in English list, or `character(0)` for no filtering.
#' @param top_n Integer. Maximum number of n-grams to return, most frequent
#'   first. Default `30`.
#'
#' @return A data.frame with columns `term` (the space-joined n-gram), `n`,
#'   and `pct`.
#' @export
ngram_frequency <- function(text, n = 2L, stop_words = NULL, top_n = 30L) {
  n <- as.integer(n)
  toks_list <- .sframe_tokenise(text, stop_words)
  grams <- unlist(lapply(toks_list, function(toks) {
    len <- length(toks)
    if (len < n) return(character(0))
    starts <- seq_len(len - n + 1L)
    vapply(starts, function(i) paste(toks[i:(i + n - 1L)], collapse = " "),
           character(1))
  }), use.names = FALSE)
  if (!length(grams)) {
    return(data.frame(term = character(0), n = integer(0), pct = numeric(0),
                       stringsAsFactors = FALSE))
  }
  tbl <- sort(table(grams), decreasing = TRUE)
  total <- sum(tbl)
  out <- data.frame(
    term = names(tbl),
    n    = as.integer(tbl),
    pct  = round(as.numeric(tbl) / total * 100, 1),
    stringsAsFactors = FALSE, row.names = NULL
  )
  utils::head(out, top_n)
}

#' Keyword-in-context concordance for open-ended text
#'
#' Finds every case-insensitive, whole-word match of `term` in `text` and
#' returns the words immediately before and after each match, so a reader
#' can judge how a term is actually being used rather than reading a bare
#' frequency count. Matching is on whole words only, so searching for
#' "room" does not match "roomy". `text` is expected to already have been
#' run through [clean_text_responses()] (its `respondent` attribute is used
#' to cite the original row index for each match; when absent, positions
#' `seq_along(text)` are used instead). Tokenisation here is a plain
#' whitespace split, not the internal stop-word-stripping tokeniser behind
#' [term_frequency()]: stop words are part of a match's context and
#' stripping them would corrupt the very thing a concordance is for.
#'
#' @param text Character vector of responses, ideally already cleaned by
#'   [clean_text_responses()].
#' @param term Character. A single keyword to search for.
#' @param window Integer. Maximum number of words of context to keep before
#'   and after each match. Default `6`.
#' @param max_matches Integer. Maximum number of matches to return, counted
#'   across all responses. Default `20`.
#'
#' @return A data.frame with columns `respondent`, `before`, `match`, and
#'   `after`.
#' @export
term_context <- function(text, term, window = 6L, max_matches = 20L) {
  if (!is.character(term) || length(term) != 1L || is.na(term) || !nzchar(term)) {
    rlang::abort("`term` must be a single non-empty string.", class = "sframe_error")
  }
  respondent <- attr(text, "respondent")
  if (is.null(respondent)) respondent <- seq_along(text)
  window <- as.integer(window)
  max_matches <- as.integer(max_matches)
  term_lower <- tolower(term)

  out_resp <- integer(0)
  out_before <- character(0)
  out_match <- character(0)
  out_after <- character(0)

  for (i in seq_along(text)) {
    if (length(out_resp) >= max_matches) break
    one <- text[i]
    if (is.na(one) || !nzchar(trimws(one))) next
    toks <- strsplit(one, "\\s+")[[1]]
    toks <- toks[nzchar(toks)]
    hits <- which(tolower(toks) == term_lower)
    if (!length(hits)) next
    for (h in hits) {
      if (length(out_resp) >= max_matches) break
      before_idx <- if (h > 1L) seq(max(1L, h - window), h - 1L) else integer(0)
      after_idx  <- if (h < length(toks)) seq(h + 1L, min(length(toks), h + window)) else integer(0)
      out_resp   <- c(out_resp, respondent[i])
      out_before <- c(out_before, if (length(before_idx)) paste(toks[before_idx], collapse = " ") else "")
      out_match  <- c(out_match, toks[h])
      out_after  <- c(out_after, if (length(after_idx)) paste(toks[after_idx], collapse = " ") else "")
    }
  }
  data.frame(respondent = out_resp, before = out_before, match = out_match,
             after = out_after, stringsAsFactors = FALSE)
}



# Runner contract wrapper around ngram_frequency(): $table, apa, prompt.
# `roles$item` names the text/textarea item; `options$n` controls n-gram
# size (default 2, bigrams); `options$top_n`. No group role for this id.
sframe_run_ngram_freq <- function(data, roles, options, instrument) {
  item_id <- sframe_role_values(roles, "item", "")[1]
  err <- sframe_require_columns(data, item_id, "N-gram frequency")
  if (!is.null(err)) return(list(test = "ngram_freq", error = err))
  n <- as.integer(options$n %||% 2L)
  top_n <- options$top_n %||% 30L

  cleaned <- clean_text_responses(data, item_id, instrument = instrument)
  n_resp <- length(cleaned)
  if (n_resp < .sframe_text_min_responses) {
    return(list(
      test = "ngram_freq",
      error = sprintf(
        "N-gram frequency needs at least %d usable responses (found %d).",
        .sframe_text_min_responses, n_resp
      )
    ))
  }
  tbl <- ngram_frequency(cleaned, n = n, stop_words = options$stop_words, top_n = top_n)
  list(
    test = "ngram_freq", variable = item_id, n = n_resp, table = tbl,
    apa = sprintf("%d-gram frequency for %s (N = %d responses, top n-gram \"%s\").",
                  n, item_id, n_resp,
                  if (nrow(tbl) > 0) tbl$term[1] else "none"),
    prompt = "Review the leading n-grams for coherence with the research question."
  )
}

# Runner contract wrapper around term_context(): $table, apa, prompt. No
# plot for this id (keyword-in-context is a table only). `roles$item` names
# the text/textarea item; `roles$term` (or `options$term`) is the keyword
# to search, required; `options$window`, `options$max_matches`.
sframe_run_term_context <- function(data, roles, options, instrument) {
  item_id <- sframe_role_values(roles, "item", "")[1]
  err <- sframe_require_columns(data, item_id, "Term context")
  if (!is.null(err)) return(list(test = "term_context", error = err))
  term <- sframe_role_values(roles, "term", "")[1]
  if (!nzchar(term)) term <- as.character(options$term %||% "")[1]
  if (is.na(term) || !nzchar(term)) {
    return(list(
      test = "term_context",
      error = "Term context needs a keyword: set roles$term or options$term."
    ))
  }
  window <- options$window %||% 6L
  max_matches <- options$max_matches %||% 20L

  cleaned <- clean_text_responses(data, item_id, instrument = instrument)
  n_resp <- length(cleaned)
  if (n_resp < .sframe_text_min_responses) {
    return(list(
      test = "term_context",
      error = sprintf(
        "Term context needs at least %d usable responses (found %d).",
        .sframe_text_min_responses, n_resp
      )
    ))
  }
  tbl <- term_context(cleaned, term = term, window = window, max_matches = max_matches)
  list(
    test = "term_context", variable = item_id, term = term, table = tbl,
    apa = sprintf("Keyword-in-context for \"%s\" in %s (N = %d responses, %d matches).",
                  term, item_id, n_resp, nrow(tbl)),
    prompt = "Read the surrounding context of each match for coherence with the research question."
  )
}
