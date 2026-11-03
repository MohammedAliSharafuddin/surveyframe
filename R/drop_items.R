# R/drop_items.R
#
# Dropping an item from a scale or a model after the item analysis flags it
# (session 8a, item c). The question stays in the instrument and its answers
# stay in the data, so the drop is reversible and the item can still be
# reported. Recording the change is amend_sframe()'s job, not this one's.

#' Drop items from scales or models
#'
#' Takes items out of the named scales or models, and out of any plan block
#' role that lists them with other variables, such as the item list of a
#' reliability or factor analysis block. The questions stay in the
#' instrument and their answers stay in the data. Nothing is recorded:
#' record the change with [amend_sframe()], where a change to how a scale is
#' scored is a design-tier amendment and needs a deviation report.
#'
#' A role that names only the dropped item, such as the variable of a
#' frequency table, keeps it, since that block analyses the item itself. A
#' scale's reverse keys and weights follow its items, and a dropped item no
#' longer names the scale (`scale_id`) or carries its reverse flag. A model drops the item
#' from every construct that measures it.
#'
#' @param instrument An `sframe` object.
#' @param items Character. The item ids to drop.
#' @param from Character. The ids of the scales or models to drop them from.
#'
#' @return The changed `sframe` object, with a message of class
#'   `sframe_drop_items_message` saying what changed.
#' @export
#' @seealso [sframe_item_flags()] to find the items past the usual cut-offs,
#'   [amend_sframe()] to record the drop.
#' @family Amendments functions
#'
#' @examples
#' ins <- sframe_demo("likert_scale")$instrument
#' revised <- sframe_drop_items(ins, "org_4", from = "organisation")
#' revised$scales[[1]]$items
sframe_drop_items <- function(instrument, items, from) {
  sframe_check_instrument(instrument)
  abort <- function(msg) rlang::abort(msg, class = c("sframe_validation_error", "sframe_error"))
  if (!is.character(items) || !length(items) || anyNA(items)) {
    abort("`items` must be a character vector of item ids.")
  }
  if (!is.character(from) || !length(from) || anyNA(from)) {
    abort("`from` must be a character vector of scale or model ids.")
  }
  ids <- function(l) vapply(l %||% list(), function(x) as.character(x$id %||% "")[1], character(1))
  scale_ids <- ids(instrument$scales)
  model_ids <- ids(instrument$models)
  unknown <- setdiff(from, c(scale_ids, model_ids))
  if (length(unknown)) {
    abort(sprintf("No scale or model has the id %s.", paste0("\"", unknown, "\"", collapse = ", ")))
  }
  missing_items <- setdiff(items, ids(instrument$items))
  if (length(missing_items)) {
    abort(sprintf("No item has the id %s.", paste0("\"", missing_items, "\"", collapse = ", ")))
  }

  done <- character(0)
  # Takes the items out of 1 member list, with weights kept in step.
  thin <- function(x, what) {
    keep <- !as.character(x$items) %in% items
    if (all(keep)) return(x)
    if (!any(keep)) abort(sprintf("Dropping these items would leave %s with no items.", what))
    if (length(x$weights) == length(x$items)) x$weights <- x$weights[keep]
    x$items <- as.character(x$items)[keep]
    if (length(x$reverse_items)) {
      rev <- setdiff(as.character(x$reverse_items), items)
      x$reverse_items <- if (length(rev)) rev else NULL
    }
    done <<- c(done, what)
    x
  }

  for (k in which(scale_ids %in% from)) {
    instrument$scales[[k]] <- thin(instrument$scales[[k]], paste0("scale ", scale_ids[k]))
  }
  # A question no longer names a scale it left, and its reverse flag, which
  # means reversed within that scale, goes with it. The scale held the
  # reverse key, and putting the item back restores it there.
  for (k in seq_along(instrument$items)) {
    it <- instrument$items[[k]]
    if (it$id %in% items && !is.null(it$scale_id) && it$scale_id %in% intersect(from, scale_ids)) {
      instrument$items[[k]]$scale_id <- NULL
      if (isTRUE(it$reverse)) instrument$items[[k]]$reverse <- FALSE
    }
  }
  for (k in which(model_ids %in% from)) {
    cons <- instrument$models[[k]]$measurement$constructs %||% list()
    for (j in seq_along(cons)) {
      cons[[j]] <- thin(cons[[j]], sprintf("construct %s in model %s",
                                           cons[[j]]$id %||% j, model_ids[k]))
    }
    if (length(cons)) instrument$models[[k]]$measurement$constructs <- cons
  }

  for (k in seq_along(instrument$analysis_plan)) {
    b <- instrument$analysis_plan[[k]]
    hit <- FALSE
    for (r in names(b$roles %||% list())) {
      v <- b$roles[[r]]
      flat <- as.character(unlist(v))
      if (length(flat) > 1 && any(flat %in% items)) {
        rest <- flat[!flat %in% items]
        b$roles[[r]] <- if (is.list(v)) as.list(rest) else rest
        hit <- TRUE
      }
    }
    if (length(b$variables) > 1 && any(as.character(unlist(b$variables)) %in% items)) {
      b$variables <- setdiff(as.character(unlist(b$variables)), items)
      hit <- TRUE
    }
    if (hit) {
      instrument$analysis_plan[[k]] <- b
      done <- c(done, paste0("plan block ", b$id %||% k))
    }
  }

  rlang::inform(
    if (length(done)) {
      sprintf("Dropped %s from %s. The questions and their answers stay. Record it with amend_sframe().",
              paste(items, collapse = ", "), paste(done, collapse = ", "))
    } else {
      sprintf("%s is in none of %s, so nothing changed.",
              paste(items, collapse = ", "), paste(from, collapse = ", "))
    },
    class = "sframe_drop_items_message")
  instrument
}
