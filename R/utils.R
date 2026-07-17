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
