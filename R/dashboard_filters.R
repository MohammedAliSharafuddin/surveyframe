# R/dashboard_filters.R
#
# Helpers for the SurveyStudio Dashboard screen's filter bar (inst/shiny/app.R).
# They choose which columns offer a filter and read dates in the formats
# survey tools write. Internal, no export.

# Free-text items never offer a filter, however few distinct answers they
# happen to have.
#' @noRd
#' @keywords internal
dashboard_categorical_columns <- function(data, instrument = NULL) {
  if (is.null(data) || !is.data.frame(data)) return(character(0))
  text_ids <- character(0)
  if (inherits(instrument, "sframe")) {
    text_ids <- unlist(lapply(instrument$items, function(i)
      if (i$type %in% c("text", "textarea")) i$id))
  }
  cols <- names(data)[vapply(data, function(x) {
    if (!(is.character(x) || is.factor(x) || is.logical(x))) return(FALSE)
    vals <- unique(x[!is.na(x)])
    length(vals) > 1 && length(vals) <= 12
  }, logical(1))]
  setdiff(cols, c(text_ids, grep("(^|_)id$", cols, value = TRUE)))
}

#' @noRd
#' @keywords internal
dashboard_date_column <- function(data) {
  if (is.null(data) || !is.data.frame(data)) return(NULL)
  candidates <- names(data)[vapply(data, function(x) {
    inherits(x, c("Date", "POSIXct", "POSIXlt")) ||
      (is.character(x) && any(!is.na(dashboard_parse_date(x))))
  }, logical(1))]
  candidates <- intersect(c("submitted_at", "started_at", candidates), candidates)
  if (length(candidates)) candidates[[1]] else NULL
}

#' @noRd
#' @keywords internal
dashboard_parse_date <- function(x) {
  if (inherits(x, "Date"))                   return(as.Date(x))
  if (inherits(x, c("POSIXct", "POSIXlt"))) return(as.Date(x))
  if (!is.character(x))                      return(rep(as.Date(NA), length(x)))

  # Blanks and whitespace-only become NA before any format attempt.
  x_clean <- trimws(x)
  x_clean[!nzchar(x_clean)] <- NA_character_

  out  <- rep(as.Date(NA_character_), length(x))
  todo <- which(!is.na(x_clean))

  # Explicit formats: when format= is given, as.POSIXct returns NA for
  # non-matching strings instead of throwing an error. Try in priority order.
  formats <- c(
    "%Y-%m-%dT%H:%M:%SZ",  # ISO 8601 Z suffix  2024-01-15T10:30:00Z
    "%Y-%m-%dT%H:%M:%S",   # ISO 8601 no tz     2024-01-15T10:30:00
    "%Y-%m-%d %H:%M:%S",   # space datetime     2024-01-15 10:30:00
    "%Y-%m-%d",            # date only          2024-01-15
    "%d/%m/%Y",            # UK dd/mm/yyyy      15/01/2024
    "%m/%d/%Y"             # US mm/dd/yyyy      01/15/2024
  )

  for (fmt in formats) {
    if (!length(todo)) break
    parsed <- tryCatch(
      as.Date(as.POSIXct(x_clean[todo], format = fmt, tz = "UTC")),
      error = function(e) rep(as.Date(NA), length(todo))
    )
    good <- !is.na(parsed)
    if (any(good)) {
      out[todo[good]] <- parsed[good]
      todo <- todo[!good]
    }
  }

  # Last-resort auto-detection for any remaining unparsed strings, wrapped in
  # tryCatch so it can never crash the dashboard.
  if (length(todo)) {
    fallback <- tryCatch(
      as.Date(suppressWarnings(as.POSIXct(x_clean[todo], tz = "UTC"))),
      error = function(e) rep(as.Date(NA), length(todo))
    )
    good <- !is.na(fallback)
    if (any(good)) out[todo[good]] <- fallback[good]
  }

  out
}
