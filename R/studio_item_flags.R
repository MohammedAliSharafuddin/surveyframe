# R/studio_item_flags.R
#
# SurveyStudio's Drop from scale and Put back (UI-1, owner 2026-11-01, moved
# from 8a). Under a result that sframe_item_flags() reads, each flagged item
# gets "Drop from scale", which opens the 1 amendment dialog with the change
# from sframe_drop_items() and the flag's reason filled in. Put back is a
# second amendment, so history is never deleted. An amendment entry records
# no before state, so Studio keeps the instrument from before each drop it
# records in the session, keyed by the entry's new hash, and Put back copies
# the parts the drop changed back from it. After a reopen that state is gone,
# and the item goes back through Design instead.

# The flagged rows of 1 plan result, or an empty data frame for a result
# sframe_item_flags() does not read. A flag with no item (AVE, HTMT) has
# nothing to drop and is left out.
sframe_studio_result_flags <- function(result) {
  f <- tryCatch(suppressWarnings(sframe_item_flags(result)),
                error = function(e) NULL)
  if (!is.data.frame(f) || !nrow(f)) return(data.frame())
  f <- f[f$flagged & !is.na(f$item) & nzchar(f$item), , drop = FALSE]
  f[!duplicated(f$item), , drop = FALSE]
}

# The scales or models a flagged item is dropped from. Reliability and item
# analysis name the scale. A CFA or PLS flag names a construct, so the item
# leaves the models that measure it. An EFA flag names a factor, so the item
# leaves the scales that hold it.
sframe_studio_drop_targets <- function(instrument, flag) {
  ids <- function(l) vapply(l %||% list(), function(x) as.character(x$id %||% "")[1], character(1))
  item <- flag$item[1]
  holds <- function(l) vapply(l %||% list(), function(x) item %in% as.character(x$items), logical(1))
  scales <- ids(instrument$scales)[holds(instrument$scales)]
  if (flag$group[1] %in% scales) return(flag$group[1])
  if (flag$result_type[1] %in% c("cfa", "pls")) {
    models <- instrument$models %||% list()
    in_model <- vapply(models, function(m)
      any(holds(m$measurement$constructs)), logical(1))
    return(ids(models)[in_model])
  }
  scales
}

# What the dialog needs to record a drop: the instrument after it, the
# targets, the reason from the flag and the dialog's lead line. NULL when the
# item is in no scale or model.
sframe_studio_drop_proposal <- function(instrument, flag) {
  from <- sframe_studio_drop_targets(instrument, flag)
  if (!length(from)) return(NULL)
  item <- flag$item[1]
  after <- suppressMessages(sframe_drop_items(instrument, item, from))
  list(
    item = item, from = from, block = flag$block[1], after = after,
    start_label = sprintf("Drop %s from %s, flagged in %s.", item,
                          paste(from, collapse = ", "), flag$block[1]),
    defaults = list(
      reason_code = "model_respecification",
      reason_text = flag$reason[1],
      deviation_report = sprintf(
        "%s dropped from %s after the item analysis flagged it: %s",
        item, paste(from, collapse = ", "), flag$reason[1]))
  )
}

# The components of 1 kind that differ between 2 instruments, by id.
sframe_studio_changed_ids <- function(before, after) {
  ids <- function(l) vapply(l %||% list(), function(x) as.character(x$id %||% "")[1], character(1))
  b <- stats::setNames(before %||% list(), ids(before))
  a <- stats::setNames(after %||% list(), ids(after))
  Filter(function(id) !identical(b[[id]], a[[id]]), intersect(names(b), names(a)))
}

# The instrument with a drop undone: every scale, model, question and plan
# block the drop changed comes back as it was before it, so the item's
# scale_id and reverse key return with its place in the scale. `drop` holds
# the before and after instruments Studio kept. A part changed again since
# the drop is not overwritten: the error says to put the item back in Design.
sframe_studio_put_back <- function(current, drop) {
  out <- current
  ids <- function(l) vapply(l %||% list(), function(x) as.character(x$id %||% "")[1], character(1))
  for (kind in c("scales", "models", "items", "analysis_plan")) {
    changed <- sframe_studio_changed_ids(drop$before[[kind]], drop$after[[kind]])
    for (id in changed) {
      k <- match(id, ids(out[[kind]]))
      was <- drop$after[[kind]][[match(id, ids(drop$after[[kind]]))]]
      if (is.na(k) || !identical(out[[kind]][[k]], was)) {
        rlang::abort(sprintf(paste0(
          "%s has changed since %s was dropped, so Studio cannot put it back ",
          "by itself. Put it back in Design."), id, drop$item),
          class = c("sframe_put_back_error", "sframe_error"))
      }
      out[[kind]][[k]] <- drop$before[[kind]][[match(id, ids(drop$before[[kind]]))]]
    }
  }
  out
}
