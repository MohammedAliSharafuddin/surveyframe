# amendments.R
#
# A disclosed-revision path around read_sframe()'s hash check. Without this,
# any edit to an instrument -- a legitimate data-cleaning correction as much
# as an undisclosed change -- breaks the file's hash identically, and the
# only record of "why" lives outside the file (an email, a lab notebook, a
# memory). amend_sframe() makes the "why" part of the file itself: every
# amendment is appended to an ordered log, never overwritten, so the full
# revision history survives in the .sframe file alongside the content it
# describes. The hash still catches an undisclosed edit exactly as before --
# this adds a disclosed path next to it, it does not weaken the check.
#
# Two tiers, because not every amendment carries the same risk. A dataset or
# collection-pipeline correction ("bot_removal", "data_correction") is
# expected researcher behaviour and stays low-friction. A change to the
# analysis plan or the measurement/structural model after data collection has
# begun is exactly the behaviour the design-time plan binding
# (sframe_instrument()'s analysis_plan slot, run_analysis_plan()) exists to
# guard against, so it is disclosed but made more effortful: a mandatory
# `deviation_report`, and a `signoff` field that is never silently blank --
# it explicitly records "none" when no second reviewer is named, so the gap
# is visible to an auditor rather than indistinguishable from a signed-off
# change.

sframe_amendment_reason_codes <- c(
  "data_correction", "bot_removal", "model_respecification",
  "instrument_revision", "other"
)

sframe_amendment_tiers <- c("pipeline", "design")

# reason_code -> default tier. data_correction/bot_removal are ordinary
# pipeline hygiene; model_respecification is design-level by construction;
# instrument_revision and other default to design-level too, since a
# generic instrument edit or an unclassified reason should get the more
# careful path unless the caller explicitly asks for "pipeline".
sframe_amendment_default_tier <- function(reason_code) {
  if (reason_code %in% c("data_correction", "bot_removal")) "pipeline" else "design"
}

# Content-only hash: the same canonical-JSON SHA-256 sframe_hash_value() uses,
# but computed over the payload with `hash` AND `amendments` excluded. This
# sidesteps the self-reference a file-level hash would create (an amendment
# entry cannot record the hash of a payload that includes that entry's own
# hash field) while still giving a well-defined, independently reproducible
# digest of "what the substantive instrument content was at this point" --
# items, choices, scales, branching, checks, analysis plan, models, designs.
# Documented as distinct from write_sframe()'s file-level hash in
# amend_sframe()'s and sframe_get_amendments()'s roxygen so the two are never
# confused: `previous_hash`/`new_hash` in an amendment entry are a content
# fingerprint, not the .sframe file's own integrity hash.
# A canonical fingerprint of one amendment entry, over every field it records.
# The boundary used to compare each entry's new_hash alone, which covers the
# content the amendment produced and says nothing about the disclosure itself,
# so an entry's author, reason, tier or sign-off could be rewritten afterwards
# and the log still passed as intact.
sframe_amendment_entry_hash <- function(entry) {
  if (!is.list(entry)) return("")
  entry <- entry[sframe_key_order(names(entry))]
  sframe_sha256_json(sframe_hash_json(entry, canonical = TRUE))
}

sframe_amendment_entry_hashes <- function(amendments) {
  vapply(amendments %||% list(), sframe_amendment_entry_hash, character(1))
}

sframe_content_hash <- function(instrument, box = TRUE, empty_render_array = FALSE) {
  payload <- sframe_serialization_payload(instrument, box = box)
  # Before 0.4.3 an empty render serialised as [], and amendment logs
  # recorded then hash it that way.
  if (isTRUE(empty_render_array) && length(payload$render) == 0) payload$render <- list()
  payload$hash <- NULL
  payload$amendments <- NULL
  # Citing a source is disclosure, not a design change, so a reference added
  # to a published instrument needs no amendment. See R/references.R.
  payload$references <- NULL
  sframe_sha256_json(sframe_hash_json(payload, canonical = TRUE))
}

# The content fingerprints an earlier version could have recorded for the same
# content: before 0.4.2 one-member collections were serialised as scalars, and
# a fingerprint could be taken before validation set meta$validated. Used only
# to recognise an existing log, so older files are not refused. Before 0.4.3
# the keys also sorted in the session locale's order, so each form is also
# taken in that order.
sframe_content_hash_candidates <- function(instrument, target = NULL) {
  forms <- function() {
    out <- character(0)
    for (box in c(TRUE, FALSE)) {
      for (v in list("keep", "absent", FALSE, TRUE)) {
        ins <- instrument
        if (identical(v, "absent")) ins$meta$validated <- NULL
        else if (!identical(v, "keep")) ins$meta$validated <- v
        out <- c(out, sframe_content_hash(ins, box = box),
                 sframe_content_hash(ins, box = box, empty_render_array = TRUE))
      }
    }
    out
  }
  now <- unique(forms())
  # Earlier forms only when the hash sought is not among the current ones.
  if (!is.null(target) && all(target %in% now)) return(now)
  unique(c(now, sframe_old_form_values(forms)))
}

# The amendment checks write_sframe() applies. An amendment log is only worth
# something if it cannot be quietly bypassed, shortened or reordered, so:
# entries must follow one another, the content must match the last entry, and
# an instrument read from a file must keep that file's entries and record any
# change to its content. Writing changed content as a new instrument is an
# explicit declaration.
sframe_check_amendment_boundary <- function(instrument, new_instrument = FALSE) {
  abort <- function(msg) rlang::abort(msg, class = c("sframe_validation_error", "sframe_error"))
  am <- instrument$amendments %||% list()
  origin <- attr(instrument, "sframe_origin")

  if (length(am) > 1) {
    for (i in 2:length(am)) {
      if (!identical(am[[i]]$previous_hash, am[[i - 1]]$new_hash)) {
        abort(sprintf(paste0(
          "The amendment log is out of sequence at entry %d: it records a ",
          "previous state that entry %d did not produce. Entries may have been ",
          "removed or reordered."), i, i - 1))
      }
      if (isTRUE(am[[i]]$timestamp < am[[i - 1]]$timestamp)) {
        abort(sprintf("The amendment log timestamps run backwards at entry %d.", i))
      }
    }
  }

  # Content read without a matching hash ties to no state anyone wrote, so
  # it is written only as a new instrument, which starts a new log. Its own
  # log was read unchecked too: written back, an entry edited as text (a
  # sign-off, a tier, a timestamp, a deleted entry) would read back verified,
  # since the entry fingerprints compared below were taken from that same
  # unchecked read (Fable sitting 1 FR-05).
  if (!isTRUE(new_instrument) && isFALSE(origin$verified)) {
    abort(sprintf(paste0(
      "This instrument was read from '%s' without a matching integrity hash, ",
      "so neither its content nor its amendment log is checked. Write it as a ",
      "new instrument with new_instrument = TRUE, which starts a new ",
      "amendment log: clear the old one first with instrument$amendments <- ",
      "list()."), origin$path))
  }

  if (isTRUE(new_instrument)) {
    if (length(am) > 0) {
      abort(paste0(
        "new_instrument = TRUE declares a new instrument, which cannot carry ",
        "another instrument's amendment log. Clear it first with ",
        "instrument$amendments <- list()."))
    }
    # A new instrument with the title and version of the file it was read
    # from would be a second file claiming to be that instrument.
    if (!is.null(origin$version) &&
        identical(instrument$meta$title %||% "", origin$title) &&
        identical(instrument$meta$version %||% "", origin$version)) {
      # Content that still hashes to the file read has nothing to declare as
      # new, and writes without the flag.
      if (identical(sframe_content_hash(instrument), origin$content_hash)) {
        abort(paste0(
          "Nothing changed since it was read: write it without ",
          "`new_instrument = TRUE`."))
      }
      abort(sprintf(paste0(
        "new_instrument = TRUE declares a new instrument, but it keeps the ",
        "title and version of '%s' (\"%s\", version %s). Give it a new ",
        "meta$version or meta$title first."),
        origin$path, origin$title, origin$version))
    }
    return(invisible(TRUE))
  }

  current <- sframe_content_hash(instrument)
  if (length(am) > 0) {
    last <- am[[length(am)]]$new_hash %||% ""
    if (!identical(last, current) && !last %in% sframe_content_hash_candidates(instrument, last)) {
      abort(paste0(
        "The instrument has changed since its last recorded amendment. Record ",
        "the change with amend_sframe(), or write it as a new instrument with ",
        "new_instrument = TRUE."))
    }
  }

  if (!is.null(origin)) {
    # Compared over whole entries, so editing an existing amendment's author,
    # reason, tier or sign-off is caught. Comparing new_hash alone left every
    # field of the disclosure rewritable after the fact.
    loaded <- origin$amendment_entry_hashes %||%
      (origin$amendment_new_hashes %||% character(0))
    now <- if (is.null(origin$amendment_entry_hashes)) {
      vapply(am, function(a) a$new_hash %||% "", character(1))
    } else {
      sframe_amendment_entry_hashes(am)
    }
    if (length(now) < length(loaded) || !identical(now[seq_along(loaded)], loaded)) {
      abort(sprintf(paste0(
        "The amendment log read from '%s' has been shortened or altered. ",
        "An amendment log only grows, and a recorded entry stays as it was ",
        "written."), origin$path))
    }
    # The first entry on a file read with no log starts from the content read
    # (CX-01). Each later entry follows the one before, as checked above.
    if (length(loaded) == 0 && length(am) > 0 &&
        !identical(am[[1]]$previous_hash %||% "", origin$content_hash)) {
      abort(sprintf(paste0(
        "The first amendment does not start from the content read from '%s'. ",
        "Record changes with amend_sframe() from the instrument as read."),
        origin$path))
    }
    if (!identical(current, origin$content_hash) && length(now) == length(loaded)) {
      abort(sprintf(paste0(
        "This instrument was read from '%s' and its content has changed with ",
        "no amendment recorded. Record the change with amend_sframe(), or write ",
        "it as a new instrument with new_instrument = TRUE."), origin$path))
    }
  }
  invisible(TRUE)
}

# The read-time check of an amendment log, as a warning: the file is
# self-consistent, and write_sframe() refuses to write it on until the log
# and content agree.
sframe_check_amendment_log_read <- function(instrument, path) {
  am <- instrument$amendments
  warn <- function(msg) rlang::warn(msg, class = c("sframe_amendment_warning", "sframe_warning"))
  if (length(am) > 1) {
    for (k in 2:length(am)) {
      if (!identical(am[[k]]$previous_hash, am[[k - 1]]$new_hash)) {
        warn(sprintf(paste0(
          "The amendment log in '%s' is out of sequence at entry %d: it records ",
          "a previous state that entry %d did not produce."), path, k, k - 1))
        return(invisible(FALSE))
      }
    }
  }
  last <- am[[length(am)]]$new_hash %||% ""
  if (!last %in% sframe_content_hash_candidates(instrument, last)) {
    warn(sprintf(paste0(
      "The amendment log in '%s' does not end at the content the file holds. ",
      "Its last entry records a different state, so the log does not describe ",
      "this content."), path))
    return(invisible(FALSE))
  }
  invisible(TRUE)
}

sframe_restore_amendment <- function(a) {
  a$timestamp <- as.character(a$timestamp %||% "")
  a$reason_code <- as.character(a$reason_code %||% "other")
  a$reason_text <- as.character(a$reason_text %||% "")
  a$tier <- as.character(a$tier %||% "pipeline")
  a$author <- sframe_empty_to_null(a$author)
  a$deviation_report <- sframe_empty_to_null(a$deviation_report)
  a$signoff <- as.character(a$signoff %||% "none")
  a$previous_hash <- as.character(a$previous_hash %||% "")
  a$new_hash <- as.character(a$new_hash %||% "")
  a$changed_fields <- sframe_as_vector(
    sframe_empty_to_null(a$changed_fields), "character"
  ) %||% character(0)
  class(a) <- "sf_amendment"
  a
}

sframe_amendment_plain <- function(a) {
  out <- unclass(a)
  out$author <- sframe_empty_to_null(out$author)
  out$deviation_report <- sframe_empty_to_null(out$deviation_report)
  out
}

# The scoring a scale declares: which items it takes, which are reverse keyed,
# their weights, the method and the minimum answered. A change to any of them
# changes every score the plan analyses, so it is a design-tier change, as a
# plan change is. A scale's label is wording and stays out.
sframe_scale_scoring <- function(scales) {
  scales <- scales %||% list()
  ids <- vapply(scales, function(s) as.character(s$id %||% "")[1], character(1))
  out <- lapply(scales, function(s) {
    list(items = as.character(unlist(s$items %||% list())),
         reverse_items = sframe_key_sort(as.character(unlist(s$reverse_items %||% list()))),
         weights = as.numeric(unlist(s$weights %||% list())),
         method = as.character(s$method %||% "mean")[1],
         min_valid = as.numeric(unlist(s$min_valid %||% list())))
  })
  out <- stats::setNames(out, ids)
  out[sframe_key_order(names(out))]
}

# The version an amendment suggests, and why, from 1 place so the console,
# Studio's amendment dialog and the builder say the same. A design amendment
# changes what is measured or analysed, so the minor number moves (1.0.0 to
# 1.1.0). A pipeline amendment corrects data or wording, so the patch number
# moves (1.0.0 to 1.0.1). A version that is not numbers and dots gets no
# suggestion.
sframe_suggest_version <- function(version, tier = c("design", "pipeline")) {
  tier <- match.arg(tier)
  v <- trimws(as.character(version %||% "")[1])
  if (is.na(v) || !nzchar(v)) v <- "1.0.0"
  if (!grepl("^[0-9]+(\\.[0-9]+){0,2}$", v)) {
    return(list(version = NULL, reason = sprintf(paste0(
      "The version \"%s\" is not of the form 1.0.0, so no next version is ",
      "suggested."), v)))
  }
  n <- as.integer(strsplit(v, ".", fixed = TRUE)[[1]])
  n <- c(n, rep(0L, 3L - length(n)))
  if (identical(tier, "design")) {
    n <- c(n[1], n[2] + 1L, 0L)
    why <- paste0("A design amendment changes what is measured or analysed, ",
                  "so the minor number moves.")
  } else {
    n <- c(n[1], n[2], n[3] + 1L)
    why <- paste0("A pipeline amendment corrects data or wording, so the ",
                  "patch number moves.")
  }
  list(version = paste(n, collapse = "."), reason = why)
}

# What else decides a score or a flag, outside the scales: the items reverse
# keyed on the item (score_scales() reverses them as the scale's own
# reverse_items), the scale each item names, the choice codes of every item a
# scale scores, and what each attention check tests and passes. A change to
# any of them moves scale scores or who is flagged, so it is design tier
# (Fable sitting 1 FR-06). Each is a list named by id, so a component added
# with none of them set changes nothing here.
sframe_scoring_inputs <- function(payload) {
  items <- payload$items %||% list()
  id_of <- function(x) as.character(x$id %||% "")[1]
  ids <- vapply(items, id_of, character(1))
  sorted <- function(x) x[sframe_key_order(names(x))]
  reverse <- ids[vapply(items, function(i) isTRUE(i$reverse), logical(1))]
  scale_id <- lapply(items, function(i) as.character(unlist(i$scale_id %||% list())))
  names(scale_id) <- ids
  scale_id <- scale_id[lengths(scale_id) > 0]
  scored <- unique(c(
    unlist(lapply(payload$scales %||% list(), function(s) as.character(unlist(s$items %||% list())))),
    names(scale_id)))
  sets <- payload$choices %||% list()
  names(sets) <- vapply(sets, id_of, character(1))
  codes <- lapply(items[ids %in% scored], function(i) {
    cs <- as.character(i$choice_set %||% "")[1]
    as.character(unlist(sets[[cs]]$values %||% list()))
  })
  names(codes) <- ids[ids %in% scored]
  checks <- lapply(payload$checks %||% list(), function(k) {
    list(item_id = as.character(k$item_id %||% "")[1],
         pass_values = as.character(unlist(k$pass_values %||% list())))
  })
  names(checks) <- vapply(payload$checks %||% list(), id_of, character(1))
  list(
    "the items' reverse keys" = sframe_key_sort(reverse),
    "the scales the items name" = sorted(scale_id),
    "the choice codes of scored items" = sorted(codes),
    "the attention checks' pass values" = sorted(checks))
}

# The change between 2 serialisation payloads as amend_sframe() records it:
# the fields that differ, and those of them that make it design tier.
sframe_amendment_diff <- function(prev_payload, new_payload) {
  keys <- setdiff(union(names(prev_payload), names(new_payload)), c("hash", "amendments"))
  changed <- as.character(Filter(
    function(k) !identical(prev_payload[[k]], new_payload[[k]]), keys))
  design <- intersect(changed, c("analysis_plan", "models", "designs", "study"))
  before <- sframe_scoring_inputs(prev_payload)
  after <- sframe_scoring_inputs(new_payload)
  inputs <- names(before)[!vapply(names(before), function(k) identical(before[[k]], after[[k]]), logical(1))]
  design <- c(inputs, design)
  if (!identical(sframe_scale_scoring(prev_payload$scales),
                 sframe_scale_scoring(new_payload$scales))) {
    design <- c("the scales scored", design)
  }
  list(changed_fields = changed, design_changes = design)
}

# The ids of components that were added, removed or changed between 2 lists,
# named by id, with what happened to each.
sframe_component_changes <- function(before, after) {
  ids <- function(l) vapply(l %||% list(), function(x) as.character(x$id %||% "")[1], character(1))
  b <- stats::setNames(before %||% list(), ids(before))
  a <- stats::setNames(after %||% list(), ids(after))
  out <- character(0)
  for (id in union(names(b), names(a))) {
    what <- if (!id %in% names(a)) "removed" else if (!id %in% names(b)) "added" else
      if (!identical(b[[id]], a[[id]])) "changed" else NA_character_
    if (!is.na(what)) out[[id]] <- what
  }
  as.list(out)
}

# What Studio's amendment dialog shows before a change is applied: the
# fields, the scales whose scoring changes, the models and plan blocks
# touched, whether the change is design tier whatever is chosen, and the
# version each tier suggests, with the reason.
sframe_amendment_preview <- function(previous, instrument) {
  prev_v <- as_sframe(validate_sframe(previous, strict = FALSE))
  new_v <- as_sframe(validate_sframe(instrument, strict = FALSE))
  pp <- sframe_serialization_payload(prev_v)
  np <- sframe_serialization_payload(new_v)
  d <- sframe_amendment_diff(pp, np)
  sb <- sframe_scale_scoring(pp$scales)
  sa <- sframe_scale_scoring(np$scales)
  scales <- union(names(sb), names(sa))
  scales <- scales[!vapply(scales, function(s) identical(sb[[s]], sa[[s]]), logical(1))]
  models <- sframe_component_changes(pp$models, np$models)
  plan <- sframe_component_changes(pp$analysis_plan, np$analysis_plan)
  version <- previous$meta$version %||% ""
  list(
    changed = length(d$changed_fields) > 0,
    changed_fields = d$changed_fields,
    design_changes = d$design_changes,
    design_forced = length(d$design_changes) > 0,
    scales = scales,
    models = names(models), model_detail = models,
    plan_blocks = names(plan), plan_detail = plan,
    version = version,
    suggest = list(design = sframe_suggest_version(version, "design"),
                   pipeline = sframe_suggest_version(version, "pipeline"))
  )
}

#' Record a disclosed amendment to an instrument
#'
#' Appends a structured, disclosed-revision entry to an instrument's
#' amendment log, comparing `previous` against `instrument` to record what
#' changed and why: a data-entry correction, bot-response removal, or a
#' documented model respecification. The record is kept inside the file,
#' beside the content it explains.
#'
#' [write_sframe()] refuses to write an instrument read from a file whose
#' content has changed with no amendment recorded, one that changed after its
#' last amendment, and one whose amendment log was shortened or reordered.
#' [read_sframe()] refuses a file edited on disk without its hash being
#' recomputed. These checks are local and the hashes are unsigned: someone
#' who rewrites both a file and its log, and recomputes the hashes, is not
#' detected, and nothing here establishes who made a change or when.
#'
#' Amendments come in two tiers. A `"pipeline"` amendment (data corrections,
#' bot removal) needs only a reason. A `"design"` amendment also requires a
#' `deviation_report` describing what changed in the research question,
#' method or model, and why. The tier follows the change itself: an amendment
#' that changes the analysis plan, a model, a conjoint design or how a scale
#' is scored (its items, reverse keys, weights, method or minimum answered)
#' is always design tier, whatever `reason_code` or `tier` says. So is a
#' change to an item's own `reverse` or `scale_id`, to the choice codes of an
#' item a scale scores, or to what an attention check tests and its pass
#' values, since each moves scale scores or who is flagged. `second_signoff` is
#' optional. When omitted, the entry records `signoff = "none"`, so the
#' absence of a named reviewer is visible. The tier, report and signoff are
#' what the author records. None of them is independent approval.
#'
#' `previous_hash` and `new_hash` on each entry are a content fingerprint: a
#' SHA-256 over a canonical serialisation of the instrument, with the `hash`,
#' `amendments` and `references` fields excluded, taken after validation, so `new_hash` is
#' the content that is written. It is distinct from the file's own integrity
#' hash from [write_sframe()], which also covers the amendment log. Both
#' identify content. Neither is byte identity.
#'
#' The amendment is sealed when the file is written: [write_sframe()] hashes
#' the object as it stands then, so a change made to the returned object
#' before it is written is part of the author's new version, covered by the
#' file's hash but not by this entry's `new_hash`.
#'
#' @section Wording on the participant's screens:
#' The welcome, consent and thank-you wording lives in `render`, and both
#' hashes cover `render`, so editing that wording changes the instrument as
#' much as editing an item does. On a published instrument, record it as a
#' pipeline-tier amendment with `reason_code = "other"` and a `reason_text`
#' saying what was reworded, then write the file with [write_sframe()]. This
#' is the intended path for a host that lets researchers edit these screens.
#' A file whose JSON is edited directly fails [read_sframe()]'s hash check.
#'
#' ```
#' revised <- instrument
#' revised$render$welcome$consent_text <- "I agree to take part."
#' revised <- amend_sframe(instrument, revised, "other",
#'                         "Consent wording shortened", tier = "pipeline")
#' write_sframe(revised, "study.sframe", overwrite = TRUE)
#' ```
#'
#' @param previous An `sframe` object: the instrument's state before this
#'   amendment. Read from a file, it must still match that file, or its last
#'   recorded amendment, so the log starts from a state a file held.
#'   An edit made to it after reading is refused, and so is one read with
#'   `verify = FALSE` that failed its integrity check.
#' @param instrument An `sframe` object: the instrument's state after the
#'   change this call discloses.
#' @param reason_code One of `"data_correction"`, `"bot_removal"`,
#'   `"model_respecification"`, `"instrument_revision"`, `"other"`.
#' @param reason_text Character. A free-text explanation. Required and must
#'   be non-empty regardless of `reason_code`.
#' @param tier `"pipeline"` or `"design"`. When `NULL` (the default), inferred
#'   from `reason_code`: `data_correction` and `bot_removal` default to
#'   `"pipeline"`, and everything else to `"design"`. A change to the
#'   analysis plan, a model, a conjoint design or a scale's scoring is always `"design"`, and
#'   asking for `"pipeline"` on one is an error.
#' @param author Character or `NULL`. Who made the change.
#' @param deviation_report Character or `NULL`. Required when `tier` is
#'   `"design"`: what changed in the research question, method, or model, and
#'   why. Ignored (may be `NULL`) for `"pipeline"` amendments.
#' @param second_signoff Character or `NULL`. A second reviewer's name or
#'   identifier (an ethics board reference, a co-author). When omitted, the
#'   entry records `signoff = "none"`.
#' @param version Character or `NULL`. The instrument's version after the
#'   amendment, written to `meta$version` and covered by the recorded
#'   content. `NULL` keeps the version `instrument` has. When that is still
#'   the version of `previous`, a message of class
#'   `sframe_version_suggestion` suggests the next one: the minor number for a
#'   design amendment (1.0.0 to 1.1.0), the patch number for a pipeline
#'   amendment (1.0.0 to 1.0.1).
#'
#' @return The amended `sframe` object, with the new entry appended to its
#'   amendment log. Call [write_sframe()] to persist it.
#' @export
#' @seealso [sframe_get_amendments()], [write_sframe()], [read_sframe()]
#'
#' @examples
#' item  <- sframe_item("q1", "How satisfied are you?", type = "text")
#' instr <- sframe_instrument("Demo", components = list(item))
#' item2 <- sframe_item("q1", "How satisfied are you overall?", type = "text")
#' revised <- sframe_instrument("Demo", components = list(item2))
#' amended <- amend_sframe(
#'   instr, revised,
#'   reason_code = "instrument_revision",
#'   reason_text = "Clarified item wording after a pilot round.",
#'   deviation_report = "Wording only; no change to the construct measured."
#' )
#' nrow(sframe_get_amendments(amended))
#' @family Amendments functions
amend_sframe <- function(previous, instrument, reason_code, reason_text,
                         tier = NULL, author = NULL, deviation_report = NULL,
                         second_signoff = NULL, version = NULL) {
  sframe_check_instrument(previous, arg = "previous")
  sframe_check_instrument(instrument, arg = "instrument")

  reason_code <- rlang::arg_match(reason_code, sframe_amendment_reason_codes)

  if (!is.character(reason_text) || length(reason_text) != 1 ||
      !nzchar(trimws(reason_text))) {
    rlang::abort(
      "`reason_text` must be a non-empty character string.",
      class = c("sframe_validation_error", "sframe_error")
    )
  }

  tier_requested <- !is.null(tier)
  if (is.null(tier)) {
    tier <- sframe_amendment_default_tier(reason_code)
  } else {
    tier <- rlang::arg_match(tier, sframe_amendment_tiers)
  }

  # An instrument that failed its integrity check holds content no file
  # vouches for, and an amendment from it would write that content back as
  # verified.
  if (isFALSE(attr(previous, "sframe_origin")$verified)) {
    rlang::abort(paste0(
      "This instrument failed its integrity check when read, so an amendment ",
      "cannot start from it. Restore the original file, or write the content ",
      "as a new instrument with `new_instrument = TRUE`."),
      class = c("sframe_validation_error", "sframe_error"))
  }

  # Fingerprints and the diff are taken on validated states, since validation
  # sets meta$validated and write_sframe() writes the validated state. Taken
  # before validation, new_hash described content that was never written.
  previous_v <- as_sframe(validate_sframe(previous, strict = TRUE))
  instrument_v <- as_sframe(validate_sframe(instrument, strict = TRUE))
  prev_payload <- sframe_serialization_payload(previous_v)
  new_payload  <- sframe_serialization_payload(instrument_v)
  diff <- sframe_amendment_diff(prev_payload, new_payload)
  changed_fields <- diff$changed_fields

  # The tier follows what changed. A plan, model, design or scale scoring
  # change is design tier, whatever the caller asked for, since that is the
  # change the declared-before-collection contract exists to expose.
  design_changes <- diff$design_changes
  if (length(design_changes) > 0) {
    if (tier_requested && identical(tier, "pipeline")) {
      rlang::abort(
        sprintf(paste0("This amendment changes %s, which makes it a design-tier ",
                       "amendment. It cannot be recorded as \"pipeline\"."),
                paste(design_changes, collapse = " and ")),
        class = c("sframe_validation_error", "sframe_error"))
    }
    tier <- "design"
  }

  if (identical(tier, "design") &&
      (is.null(deviation_report) || !nzchar(trimws(deviation_report)))) {
    rlang::abort(
      paste0(
        "A \"design\"-tier amendment requires `deviation_report`: describe ",
        "what changed in the research question, method, or model, and why. ",
        "Pipeline-tier amendments (data_correction, bot_removal) do not ",
        "need one."
      ),
      class = c("sframe_validation_error", "sframe_error")
    )
  }

  if (!is.null(version)) {
    if (!is.character(version) || length(version) != 1 || is.na(version) ||
        !nzchar(trimws(version))) {
      rlang::abort("`version` must be a single non-empty string, or NULL.",
                   class = c("sframe_validation_error", "sframe_error"))
    }
    instrument$meta$version <- trimws(version)
    instrument_v <- as_sframe(validate_sframe(instrument, strict = TRUE))
    new_payload <- sframe_serialization_payload(instrument_v)
    changed_fields <- sframe_amendment_diff(prev_payload, new_payload)$changed_fields
  } else if (identical(instrument$meta$version %||% "", previous$meta$version %||% "")) {
    sug <- sframe_suggest_version(previous$meta$version, tier)
    if (!is.null(sug$version)) {
      rlang::inform(sprintf(paste0(
        "The version stays %s. Suggested next version: %s. %s Set it with ",
        "`version = \"%s\"`."), previous$meta$version %||% "", sug$version,
        sug$reason, sug$version), class = "sframe_version_suggestion")
    }
  }

  signoff <- if (!is.null(second_signoff) && nzchar(trimws(second_signoff))) {
    trimws(second_signoff)
  } else {
    "none"
  }

  # The anchor: the previous state as the log last recorded it, else the
  # content of the file `previous` was read from (CX-01). A `previous` that
  # no longer matches its anchor carries an undisclosed edit, and a log
  # started from it would describe a state no file held. Candidates cover the
  # serialisations an older version may have used, such as the empty render
  # of 0.4.3. An instrument built in R, with no log and no file, is its own
  # anchor.
  last_new <- if (length(previous$amendments)) {
    previous$amendments[[length(previous$amendments)]]$new_hash %||% ""
  }
  origin <- attr(previous, "sframe_origin")
  previous_hash <- if (!is.null(last_new)) {
    if (!last_new %in% sframe_content_hash_candidates(previous_v, last_new)) {
      rlang::abort(paste0(
        "`previous` has changed since its last recorded amendment, so it is ",
        "not the state that amendment produced. Amend from the instrument as ",
        "read, and record every change in `instrument`."),
        class = c("sframe_validation_error", "sframe_error"))
    }
    last_new
  } else if (!is.null(origin$content_hash)) {
    if (!origin$content_hash %in% sframe_content_hash_candidates(previous_v, origin$content_hash)) {
      rlang::abort(sprintf(paste0(
        "`previous` has changed since it was read from '%s', so it is not the ",
        "state that file holds. Amend from the instrument as read, and record ",
        "every change in `instrument`."), origin$path),
        class = c("sframe_validation_error", "sframe_error"))
    }
    origin$content_hash
  } else {
    sframe_content_hash(previous_v)
  }

  entry <- structure(
    list(
      timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
      reason_code = reason_code,
      reason_text = trimws(reason_text),
      tier = tier,
      author = author,
      deviation_report = deviation_report,
      signoff = signoff,
      previous_hash = previous_hash,
      new_hash = sframe_content_hash(instrument_v),
      changed_fields = as.character(changed_fields)
    ),
    class = "sf_amendment"
  )

  # Base the appended log on previous$amendments, not instrument$amendments.
  # `instrument` is the "after" object a caller supplies; nothing guarantees
  # it already carries previous's full history forward (a builder or export
  # round trip unaware of this field could easily drop it), and this is an
  # audit log, so a caller's incomplete "after" state must never truncate it.
  amended <- instrument
  amended$amendments <- c(previous$amendments %||% list(), list(entry))

  # The log descends from the file `previous` was read from, so the write
  # boundary checks it against that file, whatever `instrument` was read from.
  amended <- as_sframe(validate_sframe(amended, strict = TRUE))
  attr(amended, "sframe_origin") <- origin
  amended
}

#' Read an instrument's amendment log
#'
#' Returns the disclosed-amendment history recorded by [amend_sframe()] as a
#' data frame, one row per amendment in the order they were recorded.
#'
#' @param instrument An `sframe` object.
#'
#' @return A data frame with columns `timestamp`, `reason_code`,
#'   `reason_text`, `tier`, `author`, `deviation_report`, `signoff`,
#'   `previous_hash`, `new_hash`, and `changed_fields` (a comma-joined
#'   string). Zero rows if the instrument has no recorded amendments.
#'   Export with `write.csv()` for an external audit trail.
#' @export
#' @seealso [amend_sframe()]
#'
#' @examples
#' item  <- sframe_item("q1", "How satisfied are you?", type = "text")
#' instr <- sframe_instrument("Demo", components = list(item))
#' sframe_get_amendments(instr)
#' @family Amendments functions
sframe_get_amendments <- function(instrument) {
  sframe_check_instrument(instrument)
  amendments <- instrument$amendments %||% list()

  if (length(amendments) == 0) {
    return(data.frame(
      timestamp = character(0), reason_code = character(0),
      reason_text = character(0), tier = character(0),
      author = character(0), deviation_report = character(0),
      signoff = character(0), previous_hash = character(0),
      new_hash = character(0), changed_fields = character(0),
      stringsAsFactors = FALSE
    ))
  }

  col <- function(field, default = NA_character_) {
    vapply(amendments, function(a) {
      v <- a[[field]]
      if (is.null(v) || !length(v)) default else as.character(v)[1]
    }, character(1))
  }

  data.frame(
    timestamp = col("timestamp"),
    reason_code = col("reason_code"),
    reason_text = col("reason_text"),
    tier = col("tier"),
    author = col("author"),
    deviation_report = col("deviation_report"),
    signoff = col("signoff"),
    previous_hash = col("previous_hash"),
    new_hash = col("new_hash"),
    changed_fields = vapply(amendments, function(a) {
      paste(a$changed_fields %||% character(0), collapse = ", ")
    }, character(1)),
    stringsAsFactors = FALSE
  )
}

# The amendment list a report prints, oldest first, as a display table, or
# NULL when nothing is recorded. Both report engines print this table.
sframe_report_amendments <- function(instrument) {
  log <- sframe_get_amendments(instrument)
  if (nrow(log) == 0) return(NULL)
  labels <- c(data_correction = "Data correction", bot_removal = "Bot removal",
              model_respecification = "Model respecification",
              instrument_revision = "Instrument revision", other = "Other")
  code <- ifelse(log$reason_code %in% names(labels), labels[log$reason_code], log$reason_code)
  blank <- function(x) ifelse(is.na(x), "", x)
  data.frame(
    Date = substr(log$timestamp, 1, 10),
    Tier = log$tier,
    Reason = paste0(code, ": ", log$reason_text),
    `What changed` = log$changed_fields,
    `Deviation report` = blank(log$deviation_report),
    Author = blank(log$author),
    `Sign-off` = log$signoff,
    check.names = FALSE, stringsAsFactors = FALSE
  )
}
