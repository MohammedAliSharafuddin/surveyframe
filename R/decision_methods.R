# R/decision_methods.R
# The MCDM computation layer and its runners. Computation helpers are pure
# base R, take (matrix, weights, criteria_types), and return raw outputs. The
# runners wrap them, resolve their two inputs through the fixed order
# (researcher-supplied options first, collected item roles second, typed error
# third), record where each input came from, and return the flat named list
# every other runner in the package returns.

# The decision family's method ids. Descriptive metadata elsewhere in the
# package dispatches on `test`, never on `family`, so this vector is what the
# engine uses to recognise a decision block. Ids are added here as each
# method lands.
sframe_decision_methods <- c("topsis")

# ---------------------------------------------------------------------------
# Shared input validation
# ---------------------------------------------------------------------------

# Returns a list carrying the cleaned inputs plus `note`, or a single `error`
# string. Runners never stop(): they hand their error back to the caller so
# the report can show it beside the research question.
sframe_check_decision_input <- function(x, weights, criteria_types) {
  if (!is.matrix(x) || !is.numeric(x)) {
    return(list(error = "The decision matrix must be a numeric matrix."))
  }
  if (nrow(x) < 2) {
    return(list(error = "A ranking needs at least 2 alternatives."))
  }
  if (anyNA(x)) {
    return(list(error = "The decision matrix contains missing values."))
  }
  weights <- suppressWarnings(as.numeric(weights))
  if (length(weights) != ncol(x)) {
    return(list(error = sprintf(
      "There are %d weight(s) for %d criteria.", length(weights), ncol(x)
    )))
  }
  if (anyNA(weights) || any(weights < 0)) {
    return(list(error = "Weights must be non-negative numbers."))
  }
  if (sum(weights) <= 0) {
    return(list(error = "The weights sum to zero."))
  }
  note <- NULL
  if (abs(sum(weights) - 1) > 1e-6) {
    note <- sprintf(
      "The supplied weights summed to %.4f and were renormalised to 1.",
      sum(weights)
    )
    weights <- weights / sum(weights)
  }
  criteria_types <- as.character(criteria_types)
  if (length(criteria_types) != ncol(x)) {
    return(list(error = sprintf(
      "There are %d criterion type(s) for %d criteria.",
      length(criteria_types), ncol(x)
    )))
  }
  bad <- setdiff(unique(criteria_types), c("benefit", "cost"))
  if (length(bad) > 0) {
    return(list(error = sprintf(
      "Criterion types must be \"benefit\" or \"cost\". Found: %s.",
      paste(bad, collapse = ", ")
    )))
  }
  list(matrix = x, weights = weights, criteria_types = criteria_types,
       note = note)
}

# ---------------------------------------------------------------------------
# TOPSIS computation
# ---------------------------------------------------------------------------

# Vector (Euclidean) normalisation, the weighted ideal and anti-ideal points,
# the two separation distances, and the closeness coefficient. Direction is
# handled once, at the ideal/anti-ideal step: normalisation itself never
# flips a cost column, since doing both cancels out and silently scores a
# cost criterion as a benefit.
sframe_topsis_compute <- function(x, weights, criteria_types) {
  norms <- sqrt(colSums(x^2))
  norms[norms == 0] <- 1
  normalised <- sweep(x, 2, norms, "/")
  weighted <- sweep(normalised, 2, weights, "*")

  benefit <- criteria_types == "benefit"
  ideal <- ifelse(benefit, apply(weighted, 2, max), apply(weighted, 2, min))
  anti_ideal <- ifelse(benefit, apply(weighted, 2, min),
                       apply(weighted, 2, max))

  d_plus <- sqrt(rowSums(sweep(weighted, 2, ideal, "-")^2))
  d_minus <- sqrt(rowSums(sweep(weighted, 2, anti_ideal, "-")^2))
  denom <- d_plus + d_minus
  scores <- ifelse(denom > 0, d_minus / denom, 0)
  names(scores) <- rownames(x)

  list(
    scores       = scores,
    ranks        = rank(-scores, ties.method = "min"),
    normalised   = normalised,
    weighted     = weighted,
    ideal        = ideal,
    anti_ideal   = anti_ideal,
    d_plus       = d_plus,
    d_minus      = d_minus
  )
}

# ---------------------------------------------------------------------------
# Input resolution, shared by every ranking runner
# ---------------------------------------------------------------------------

# The resolution order for the decision family, in one place so all 10 methods
# behave identically: researcher-supplied options first, collected item roles
# second, a typed error naming what is missing third. Provenance is recorded
# for both inputs so the report can say where the numbers came from.
sframe_resolve_decision_inputs <- function(data, roles, options, instrument,
                                           method = "this method") {
  options <- sframe_decision_options(options)
  out <- list(notes = character(0))

  # 1. The performance matrix.
  if (!is.null(options[["matrix"]])) {
    out$matrix <- options[["matrix"]]
    out$matrix_source <- "supplied"
  } else {
    performance_items <- sframe_role_values(roles, "performance_items")
    if (length(performance_items) == 0) {
      return(list(error = sprintf(
        paste0("%s needs a performance matrix. Supply `options$matrix` with ",
               "`options$alternatives` and `options$criteria`, or declare a ",
               "`performance_items` role naming one matrix item per ",
               "criterion."),
        method
      )))
    }
    rated <- sframe_rated_matrix(data, instrument, performance_items)
    out$matrix <- rated$matrix
    out$matrix_source <- "collected"
    out$rated <- rated
    out$notes <- c(out$notes, sprintf(
      "The performance matrix is the respondent %s of %d rated item(s).",
      rated$statistic, length(performance_items)
    ))
  }
  criteria <- colnames(out$matrix)

  # 2. The criterion weights.
  if (!is.null(options[["weights"]])) {
    out$weights <- options[["weights"]]
    out$weights_source <- "supplied"
  } else {
    weights_item <- sframe_role_values(roles, "weights_item")
    if (length(weights_item) == 0) {
      return(list(error = sprintf(
        paste0("%s needs criterion weights. Supply `options$weights`, or ",
               "declare a `weights_item` role naming a criteria_weight or ",
               "pairwise_comparison item."),
        method
      )))
    }
    collected <- sframe_collected_weights(
      data, instrument, weights_item[1],
      cr_filter = isTRUE(options[["cr_filter"]])
    )
    if (length(collected$weights) != ncol(out$matrix)) {
      return(list(error = sprintf(
        paste0("Item '%s' weights %d criterion/criteria but the performance ",
               "matrix has %d column(s)."),
        weights_item[1], length(collected$weights), ncol(out$matrix)
      )))
    }
    out$weights <- collected$weights
    out$weights_source <- "collected"
    out$collected_weights <- collected
    out$notes <- c(out$notes, sprintf(
      "Weights come from %d respondent(s) via item '%s'%s.",
      collected$n_respondents, collected$item_id,
      if (collected$n_dropped > 0) {
        sprintf(", with %d dropped as incomplete or inconsistent",
                collected$n_dropped)
      } else ""
    ))
  }
  if (is.null(names(out$weights)) && length(criteria) == length(out$weights)) {
    names(out$weights) <- criteria
  }

  # 3. Criterion directions. All benefit unless declared otherwise.
  out$criteria_types <- options[["criteria_types"]] %||%
    rep("benefit", ncol(out$matrix))
  out$alternatives <- rownames(out$matrix)
  out$criteria <- criteria
  out$options <- options
  out
}

# ---------------------------------------------------------------------------
# TOPSIS runner
# ---------------------------------------------------------------------------

sframe_run_topsis <- function(data, roles, options, instrument) {
  resolved <- sframe_resolve_decision_inputs(data, roles, options, instrument,
                                             method = "TOPSIS")
  if (!is.null(resolved$error)) {
    return(list(test = "topsis", error = resolved$error))
  }
  checked <- sframe_check_decision_input(resolved$matrix, resolved$weights,
                                         resolved$criteria_types)
  if (!is.null(checked$error)) {
    return(list(test = "topsis", error = checked$error))
  }
  fit <- sframe_topsis_compute(checked$matrix, checked$weights,
                               checked$criteria_types)

  alternatives <- resolved$alternatives
  order_by_rank <- order(fit$ranks)
  table <- data.frame(
    Alternative = alternatives[order_by_rank],
    Score       = round(as.numeric(fit$scores)[order_by_rank], 4),
    Rank        = as.integer(fit$ranks)[order_by_rank],
    stringsAsFactors = FALSE
  )
  best <- alternatives[which.min(fit$ranks)]
  notes <- c(resolved$notes, checked$note)

  list(
    test           = "topsis",
    apa            = sprintf(
      paste0("TOPSIS ranked %d alternatives on %d criteria. %s ranked first ",
             "with a closeness coefficient of %.3f."),
      length(alternatives), ncol(checked$matrix), best, max(fit$scores)
    ),
    prompt         = paste0(
      "Report the full ranking, not the winner alone. Closeness ",
      "coefficients close together mean the alternatives are hard to ",
      "separate, so state where the weights came from and check how far the ",
      "ranking moves when they are perturbed."
    ),
    table          = table,
    score_label    = "Closeness coefficient",
    scores         = fit$scores,
    ranks          = fit$ranks,
    alternatives   = alternatives,
    criteria       = resolved$criteria,
    criteria_types = checked$criteria_types,
    weights        = checked$weights,
    weights_source = resolved$weights_source,
    matrix_source  = resolved$matrix_source,
    separation_positive = fit$d_plus,
    separation_negative = fit$d_minus,
    ideal          = fit$ideal,
    anti_ideal     = fit$anti_ideal,
    consistency    = resolved$collected_weights$consistency,
    notes          = notes[!vapply(notes, is.null, logical(1))]
  )
}
