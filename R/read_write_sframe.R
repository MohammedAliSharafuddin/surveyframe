# read_sframe.R and write_sframe.R

sframe_strip_component_class <- function(component) {
  class(component) <- NULL
  component
}

# Put a component through the reader's own restore function before writing it,
# then drop the class. A component built by an sf_* constructor carries every
# optional field as NULL, and the restore functions drop those, so a fresh
# component serialised more keys than the same component after a round trip.
# That is one half of why write, read, write used to change an instrument's
# hash. The restore functions are idempotent on content, checked against both
# fresh and shipped components, so this leaves settled files byte-identical.
sframe_normalise_component <- function(component, restore) {
  sframe_strip_component_class(restore(sframe_strip_component_class(component)))
}

# Fields that are always collections, per the published instrument profile and
# the builder. Marked with I() so jsonlite writes a one-member vector as a
# JSON array. auto_unbox wrote a one-item scale as "items": "sat_1", which
# fails the profile, and the builder, writing true arrays, hashed the same
# instrument differently.
sframe_collection_fields <- list(
  items   = c("matrix_items", "comparison_items"),
  choices = c("values", "labels"),
  scales  = c("items", "reverse_items", "weights"),
  amendments = "changed_fields"
)

sframe_box_collections <- function(component, fields) {
  for (f in fields) {
    v <- component[[f]]
    if (!is.null(v) && is.atomic(v)) component[[f]] <- I(unname(v))
  }
  component
}

#' The `.sframe` format version, written into every file as `sframe_format`.
#'
#' Tracks the shape of the serialised object, not the package version and not
#' the instrument's own version. Bump it only when the file's structure
#' changes in a way a consumer must react to. `sframe-schema` conformance
#' profiles are keyed to this value.
#' @keywords internal
SFRAME_FORMAT_VERSION <- "1.0"

sframe_serialization_payload <- function(instrument, hash_value = "", box = TRUE) {
  # box = FALSE reproduces the pre-0.4.2 scalar form, used only to recognise
  # content fingerprints recorded by older versions.
  boxer <- function(components, fields) {
    if (isTRUE(box)) lapply(components, sframe_box_collections, fields) else components
  }
  # Strip list-level names before serialisation so items, choices, scales,
  # branching, and checks are always written as JSON arrays. Without unname(),
  # instruments built with Map() (which attaches item IDs as list names) produce
  # a JSON object keyed by item ID, while the round-tripped structure produces
  # integer-keyed or differently keyed objects, causing a hash mismatch on read.
  payload <- list(
    # The format's own version, distinct from `version` below, which is the
    # instrument's. Without this a consumer cannot tell which shape of file it
    # is holding, so it cannot version-negotiate or validate against a schema.
    # Added 2026-08-22. Files written before then carry no such field: the
    # reader hashes whatever the file contains, so those still verify, and only
    # a read-then-rewrite changes their hash, which is correct because the
    # content genuinely changed.
    sframe_format = SFRAME_FORMAT_VERSION,
    hash = sframe_hash_object(hash_value),
    version = instrument$meta$version,
    meta = instrument$meta,
    items    = unname(boxer(lapply(instrument$items,
                                   sframe_normalise_component, sframe_restore_item),
                            sframe_collection_fields$items)),
    choices  = unname(boxer(lapply(instrument$choices,
                                   sframe_normalise_component, sframe_restore_choices),
                            sframe_collection_fields$choices)),
    scales   = unname(boxer(lapply(instrument$scales,
                                   sframe_normalise_component, sframe_restore_scale),
                            sframe_collection_fields$scales)),
    branching = unname(lapply(instrument$branching,
                              sframe_normalise_component, sframe_restore_branch)),
    checks   = unname(lapply(instrument$checks,
                             sframe_normalise_component, sframe_restore_check)),
    # Normalised through the same restore path the reader uses, so that
    # writing an instrument and writing it again after a read produce the
    # same bytes and therefore the same hash.
    #
    # Without this, serialisation was not a fixed point. A plan block built
    # by sframe_instrument() carries only what the caller supplied, while
    # sframe_restore_analysis_block() fills in 8 fields on read (options,
    # decision_rule, reporting_references, status, requires_data, test,
    # interpretation, citations). So write, read, write changed the hash of
    # identical content: measured ec822fff then 3fa36502 on a plain 2-item
    # Likert instrument. An instrument could carry 2 different hashes
    # depending on whether it had been through a read, which is a poor
    # property for a value that is meant to be the instrument's identity.
    #
    # The function is idempotent, verified on both a fresh block and a
    # shipped one, so applying it here leaves already-settled files
    # untouched and only pulls fresh ones up to the same form.
    analysis_plan = unname(lapply(
      instrument$analysis_plan %||% list(),
      sframe_restore_analysis_block
    )),
    models = unname(lapply(instrument$models %||% list(), sframe_model_plain)),
    # Written in the shape it holds. sframe_instrument() makes an empty render an
    # empty named list, written as {}, which is what render is: it was
    # written as [], which a host reading the JSON took for a list (Ethos
    # request 3). An instrument read from a file written with [] keeps [], so
    # it re-serialises to the hash its file stores, and its amendment log
    # still matches.
    render = instrument$render %||% list()
  )

  # `designs` is added only when the instrument actually declares one.
  #
  # The hash covers the payload's key set, so writing an empty
  # `designs` array would change the hash of every instrument that
  # does not use the feature. Reading an old file would still
  # succeed, because read_sframe() hashes the parsed payload and
  # that payload has no `designs` key either, so it stays
  # self-consistent. The damage is subtler: an instrument read from
  # an existing file and written back would come out with a
  # different hash from the one it went in with, so the same content
  # would silently change identity. It would also desync from the
  # builder's JS sframeJcs(). Measured on the tourism demo:
  # c3df10ec before, febd07c5 after.
  designs <- instrument$designs %||% list()
  if (length(designs) > 0) {
    payload$designs <- unname(lapply(designs, sframe_conjoint_plain))
  }

  # `amendments` follows the same added-only-when-non-empty rule as `designs`
  # above and for the same reason: an instrument that has never been amended
  # must hash identically before and after this feature existed.
  amendments <- instrument$amendments %||% list()
  if (length(amendments) > 0) {
    payload$amendments <- unname(boxer(lapply(amendments, sframe_amendment_plain),
                                       sframe_collection_fields$amendments))
  }

  # `references` (0.4.3) follows the same rule again: an instrument that cites
  # nothing hashes exactly as it did before references existed. See
  # R/references.R for why the cite links live on the reference.
  # `study` (D13, 0.4.3), the same rule: written only when declared.
  study <- sframe_study_plain(instrument$study)
  if (!is.null(study)) payload$study <- study

  references <- instrument$references %||% list()
  if (length(references) > 0) {
    payload$references <- unname(lapply(references, sframe_reference_plain))
  }

  payload
}

# Conjoint designs carry data frames, which jsonlite would restore as a list
# of rows with the column types guessed. Stored as plain column lists and
# rebuilt on read, so a design round-trips with its hash intact.
sframe_conjoint_plain <- function(design) {
  out <- unclass(design)
  out$profiles <- as.list(design$profiles)
  out$tasks    <- as.list(design$tasks)
  out
}

sframe_json_object <- function() {
  structure(list(), names = character())
}

# The canonical form a hash is taken over (0.4.3 onwards): RFC 8785, the JSON
# Canonicalization Scheme. Object keys sorted by UTF-16 code units, numbers in
# ECMAScript's shortest round-trip form, strings escaped as JSON.stringify()
# escapes them, null kept as null, and no whitespace. SurveyBuilder and the
# verifier page build the same string in JavaScript (sframeJcs() in
# inst/builder/survey_builder.html and pkgdown/extra/verify/index.html), and
# tests/testthat/test-canonical-form.R hashes a shared set of payloads in all
# 3 through node.
#
# Earlier forms are kept only to recognise a file hashed by them:
# - "dev", the 0.4.3 development form: sframe_canonical_payload() turned null
#   into {}, keys sorted by code point, and jsonlite printed the numbers with
#   15 significant digits and escaped "</" as "<\/".
# - "locale", the form before 0.4.3: the same, with keys in the order of a
#   collation (the session's, C or en_US), since order() followed LC_COLLATE.
# New hashes are always written in the RFC 8785 form.
.sframe_order_env <- new.env(parent = emptyenv())

sframe_hash_form <- function() .sframe_order_env$form %||% "jcs"

# The canonical form a hash names (hash.canonical, from 0.4.3). It sits inside
# the hashed payload, with only hash.value emptied, so changing it breaks the
# hash. A file written before the field existed names none. The "jcs0" form
# (RFC 8785 without the field, as written at 4bd8aba to e86e80e) recognises
# such hashes in the records that hold sframe_hash_value().
SFRAME_CANONICAL <- "rfc8785"

sframe_hash_object <- function(value) {
  if (identical(sframe_hash_form(), "jcs")) {
    list(algo = "sha256", value = value, canonical = SFRAME_CANONICAL)
  } else {
    list(algo = "sha256", value = value)
  }
}

# What a parsed file's hash says of its canonical form: "rfc8785", "absent",
# or "unknown" with the value's canonical text, which every reader refuses.
sframe_hash_canonical <- function(hash) {
  if (!is.list(hash) || !("canonical" %in% names(hash))) return("absent")
  value <- hash[["canonical"]]
  if (identical(value, SFRAME_CANONICAL)) return(SFRAME_CANONICAL)
  structure("unknown", value = sframe_jcs(value))
}

sframe_key_order <- function(x) {
  if (!identical(sframe_hash_form(), "locale")) return(order(x, method = "radix"))
  sframe_collate_order(x, .sframe_order_env$collate)
}

sframe_key_sort <- function(x) x[sframe_key_order(x)]

# order() in a named collation: NULL is the session's, "C" is code point order
# and "en_US" is American English, whatever the session uses. Where en_US is
# not installed the session's order is used.
sframe_collate_order <- function(x, collate = NULL) {
  if (is.null(collate)) return(order(x))
  if (identical(collate, "C")) return(order(x, method = "radix"))
  old <- Sys.getlocale("LC_COLLATE")
  on.exit(suppressWarnings(Sys.setlocale("LC_COLLATE", old)), add = TRUE)
  for (loc in c("en_US.UTF-8", "en_US.utf8", "en_US", "English_United States.utf8",
                "English_United States.1252")) {
    if (nzchar(suppressWarnings(Sys.setlocale("LC_COLLATE", loc)))) break
  }
  order(x)
}

# Evaluate fun() with hashes taken in an earlier form.
sframe_in_form <- function(form, fun, collate = NULL) {
  old_form <- .sframe_order_env$form
  old_collate <- .sframe_order_env$collate
  on.exit({
    .sframe_order_env$form <- old_form
    .sframe_order_env$collate <- old_collate
  }, add = TRUE)
  .sframe_order_env$form <- form
  .sframe_order_env$collate <- collate
  fun()
}

sframe_with_locale_order <- function(code) {
  sframe_in_form("locale", function() code)
}

# The values fun() gives in every earlier form: RFC 8785 without
# hash.canonical, the 0.4.3 development form,
# then the pre-0.4.3 form in the session's, the C and the en_US collation, so a
# file hashed in an English session is recognised in a C one (FR-08).
sframe_old_form_values <- function(fun) {
  unique(c(
    sframe_in_form("jcs0", fun),
    sframe_in_form("dev", fun),
    sframe_in_form("locale", fun),
    sframe_in_form("locale", fun, collate = "C"),
    sframe_in_form("locale", fun, collate = "en_US")
  ))
}

# Said when a hash matched only in a form used before 0.4.3.
sframe_inform_locale_order <- function(what) {
  rlang::inform(paste0(
    what, " was hashed in a form surveyframe used before 0.4.3. It is accepted. ",
    "Save it again to update the hash."),
    class = c("sframe_locale_order_hash", "sframe_message"))
}

sframe_abort_canonical <- function(msg) {
  rlang::abort(msg, class = c("sframe_canonical_error", "sframe_validation_error",
                              "sframe_error"))
}

# The 0.4.3 development and pre-0.4.3 canonical payload, kept to recognise
# files hashed in those forms. It mapped null to {}, so a null changed to {}
# kept its hash (P2-01).
sframe_canonical_payload <- function(x) {
  if (is.null(x)) {
    return(sframe_json_object())
  }
  if (is.list(x)) {
    x <- lapply(x, sframe_canonical_payload)
    nm <- names(x)
    if (!is.null(nm)) {
      x <- x[sframe_key_order(nm)]
    }
  }
  x
}

# A number in ECMAScript's Number::toString form: the fewest significant
# digits, from 1 to 17, that read back to the same double, with the exponent
# written from 1e21 up and below 1e-6. The read back uses jsonlite's parser,
# which rounds correctly on every platform.
sframe_jcs_number <- function(x, path = "$") {
  if (is.na(x) && !is.nan(x)) return("null")
  if (!is.finite(x)) {
    sframe_abort_canonical(sprintf(
      "The number at %s is %s, which JSON cannot hold.", path, format(x)))
  }
  if (x == 0) return("0")
  if (abs(x) < 1e15 && x == trunc(x)) return(sprintf("%.0f", x))
  cands <- sprintf("%.*e", 0:16, x)
  back <- jsonlite::parse_json(paste0("[", paste(cands, collapse = ","), "]"),
                               simplifyVector = TRUE)
  hit <- which(back == x)
  sci <- cands[if (length(hit)) hit[1] else 17L]
  mant <- sub("e.*$", "", sub("^-", "", sci))
  n <- as.integer(sub("^.*e", "", sci)) + 1L
  digits <- sub("0+$", "", sub(".", "", mant, fixed = TRUE))
  k <- nchar(digits)
  out <- if (k <= n && n <= 21L) {
    paste0(digits, strrep("0", n - k))
  } else if (0L < n && n <= 21L) {
    paste0(substr(digits, 1L, n), ".", substr(digits, n + 1L, k))
  } else if (-6L < n && n <= 0L) {
    paste0("0.", strrep("0", -n), digits)
  } else {
    e <- n - 1L
    paste0(substr(digits, 1L, 1L), if (k > 1L) paste0(".", substr(digits, 2L, k)),
           "e", if (e >= 0L) "+" else "-", abs(e))
  }
  if (x < 0) paste0("-", out) else out
}

# A string as JSON.stringify() writes it: quote, backslash and the controls
# below U+0020 escaped, everything else, "/" and U+2028 among them, as is.
sframe_jcs_string <- function(s) {
  s <- enc2utf8(s)
  if (!grepl("[\"\\\\\001-\037]", s, useBytes = TRUE)) return(paste0("\"", s, "\""))
  cp <- utf8ToInt(s)
  ch <- intToUtf8(cp, multiple = TRUE)
  short <- c(`8` = "\\b", `9` = "\\t", `10` = "\\n", `12` = "\\f", `13` = "\\r",
             `34` = "\\\"", `92` = "\\\\")
  hit <- cp < 32L | cp == 34L | cp == 92L
  ch[hit] <- ifelse(as.character(cp[hit]) %in% names(short),
                    short[as.character(cp[hit])], sprintf("\\u%04x", cp[hit]))
  paste0("\"", paste(ch, collapse = ""), "\"")
}

# Key order by UTF-16 code units. Code point order (radix on UTF-8) is the same
# unless a key holds a character beyond U+FFFF.
sframe_utf16_order <- function(nm) {
  if (!any(utf8ToInt(paste(nm, collapse = "")) > 0xFFFF)) return(order(nm, method = "radix"))
  units <- vapply(nm, function(s) {
    cp <- utf8ToInt(s)
    u <- unlist(lapply(cp, function(c) {
      if (c <= 0xFFFF) return(c)
      v <- c - 0x10000
      c(0xD800 + v %/% 1024, 0xDC00 + v %% 1024)
    }))
    paste(sprintf("%04x", as.integer(u)), collapse = "")
  }, character(1), USE.NAMES = FALSE)
  order(units, method = "radix")
}

# The RFC 8785 string of a parsed JSON value: a list from
# jsonlite::parse_json(simplifyVector = FALSE), where an object is a named
# list and an array an unnamed one.
sframe_jcs <- function(x, path = "$") {
  if (is.null(x)) return("null")
  if (is.list(x)) {
    nm <- names(x)
    if (is.null(nm)) {
      if (length(x) == 0L) return("[]")
      parts <- vapply(seq_along(x), function(i) {
        sframe_jcs(x[[i]], paste0(path, "[", i, "]"))
      }, character(1))
      return(paste0("[", paste(parts, collapse = ","), "]"))
    }
    if (length(x) == 0L) return("{}")
    nm <- enc2utf8(nm)
    dup <- anyDuplicated(nm)
    if (dup) {
      sframe_abort_canonical(sprintf("The key \"%s\" appears more than once in %s.",
                                     nm[dup], path))
    }
    parts <- vapply(sframe_utf16_order(nm), function(i) {
      paste0(sframe_jcs_string(nm[i]), ":", sframe_jcs(x[[i]], paste0(path, ".", nm[i])))
    }, character(1))
    return(paste0("{", paste(parts, collapse = ","), "}"))
  }
  if (length(x) != 1L) {
    parts <- vapply(seq_along(x), function(i) sframe_jcs(x[i], paste0(path, "[", i, "]")),
                    character(1))
    return(paste0("[", paste(parts, collapse = ","), "]"))
  }
  if (is.double(x)) return(sframe_jcs_number(x, path))
  if (is.na(x)) return("null")
  if (is.character(x)) return(sframe_jcs_string(x))
  if (is.logical(x)) return(if (x) "true" else "false")
  if (is.integer(x)) return(as.character(x))
  sframe_abort_canonical(sprintf("The value at %s is a %s, which JSON cannot hold.",
                                 path, class(x)[1]))
}

# An escape R cannot hold: jsonlite cuts a string at an escaped NUL and turns a
# lone surrogate into "?" or bytes that are not UTF-8, so 2 different texts
# would read and hash the same in R. Checked on the raw text, and refused in R,
# SurveyBuilder and the verifier page alike (coordinator 2026-11-11).
# Returns c(kind, what), or NULL.
sframe_escape_problem <- function(text) {
  odd <- "(?<!\\\\)(?:\\\\\\\\)*"
  hi <- "\\\\u[dD][89abAB][0-9a-fA-F]{2}"
  lo <- "\\\\u[dD][c-fC-F][0-9a-fA-F]{2}"
  if (grepl(paste0(odd, "\\\\u0000"), text, perl = TRUE)) {
    return(c(kind = "nul", what = "the escaped character U+0000"))
  }
  if (grepl(paste0(odd, hi, "(?!", lo, ")"), text, perl = TRUE) ||
      grepl(paste0(odd, "(?<!", hi, ")", lo), text, perl = TRUE)) {
    return(c(kind = "surrogate", what = "a lone surrogate escape, U+D800 to U+DFFF without its pair"))
  }
  NULL
}

# The first duplicate key in a parsed file, as c(key, path), or NULL. R keeps both
# and the JavaScript twins the last, so such a file is refused (FR-12).
sframe_duplicate_key <- function(x, path = "$") {
  if (!is.list(x)) return(NULL)
  nm <- names(x)
  if (!is.null(nm)) {
    dup <- anyDuplicated(nm)
    if (dup) return(c(key = nm[dup], path = path))
  }
  for (i in seq_along(x)) {
    sub <- if (is.null(nm)) paste0(path, "[", i, "]") else paste0(path, ".", nm[i])
    hit <- sframe_duplicate_key(x[[i]], sub)
    if (!is.null(hit)) return(hit)
  }
  NULL
}

# Doubles written in the canonical number form, so the file holds the same
# digits the hash was taken over. jsonlite with digits = NA keeps 15
# significant digits and C's exponent form (1e-07), which the JavaScript twins
# read differently (P2-06, FR-03). A number JSON cannot hold is refused with
# its field named.
sframe_json_numbers <- function(x, path = "$") {
  if (is.list(x) && !is.data.frame(x)) {
    nm <- names(x)
    # JSON allows an empty key, but jsonlite writes an R list element with an
    # empty name under its position ({"":3} beside a named field becomes
    # {"3":3}) or, when every name is empty, as an array, so content read from
    # a file would change on writing with no amendment. Refused with its path,
    # as an NA is (coordinator 2026-11-11, after CF-A milestone 4).
    if (length(nm) > 0 && !all(nzchar(nm))) {
      sframe_abort_canonical(sprintf(paste0(
        "The field at %s[%d] has an empty name. A .sframe file cannot hold an ",
        "empty key, since writing it from R would change it into another. Give ",
        "it a name, or remove it."), path, which(!nzchar(nm))[1]))
    }
    out <- lapply(seq_along(x), function(i) {
      key <- if (is.null(nm) || !nzchar(nm[i])) paste0("[", i, "]") else paste0(".", nm[i])
      sframe_json_numbers(x[[i]], paste0(path, key))
    })
    attributes(out) <- attributes(x)
    return(out)
  }
  cls <- oldClass(x)
  if (is.double(x) && (is.null(cls) || identical(cls, "AsIs")) &&
      is.null(dim(x)) && is.null(names(x))) {
    bad <- is.nan(x) | is.infinite(x)
    if (any(bad)) {
      sframe_abort_canonical(sprintf(
        "The number at %s is %s, which a .sframe file cannot hold.", path,
        format(x[bad][1])))
    }
    txt <- vapply(x, sframe_jcs_number, character(1), path = path)
    boxed <- inherits(x, "AsIs") || length(x) != 1L
    return(structure(if (boxed) paste0("[", paste(txt, collapse = ","), "]") else txt,
                     class = "json"))
  }
  x
}

# An NA is written as null only where the bundled schema (the published
# instrument profile) allows null for that field, and refused with the field
# named anywhere else (coordinator 2026-11-11, after CF-A milestone 1). A field
# the schema does not describe takes any value, null among them.
sframe_bundled_schema <- function() {
  if (is.null(.sframe_order_env$schema)) {
    .sframe_order_env$schema <- jsonlite::read_json(
      system.file("schema", "sframe_schema.json", package = "surveyframe"),
      simplifyVector = FALSE)
  }
  .sframe_order_env$schema
}

sframe_schema_resolve <- function(node, root) {
  ref <- if (is.list(node)) node[["$ref"]]
  if (is.null(ref)) return(node)
  for (part in strsplit(sub("^#/", "", ref), "/", fixed = TRUE)[[1]]) root <- root[[part]]
  root
}

sframe_schema_allows_null <- function(node, root) {
  node <- sframe_schema_resolve(node, root)
  if (!is.list(node)) return(TRUE)
  branches <- c(node$anyOf, node$oneOf)
  if (length(branches)) {
    return(any(vapply(branches, sframe_schema_allows_null, logical(1), root = root)))
  }
  if (!is.null(node$type)) return("null" %in% unlist(node$type))
  if ("const" %in% names(node)) return(is.null(node$const))
  if (!is.null(node$enum)) return(any(vapply(node$enum, is.null, logical(1))))
  TRUE
}

sframe_schema_child <- function(node, key, root) {
  node <- sframe_schema_resolve(node, root)
  if (!is.list(node)) return(NULL)
  if (is.null(key)) return(node$items)
  node$properties[[key]] %||% (if (is.list(node$additionalProperties)) node$additionalProperties)
}

sframe_check_na_schema <- function(x, node = sframe_bundled_schema(),
                                   root = sframe_bundled_schema(), path = "") {
  if (is.list(x) && !is.data.frame(x)) {
    nm <- names(x)
    for (i in seq_along(x)) {
      key <- if (is.null(nm) || !nzchar(nm[i])) NULL else nm[i]
      sub <- if (is.null(key)) paste0(path, "[", i, "]") else paste0(path, if (nzchar(path)) ".", key)
      sframe_check_na_schema(x[[i]], sframe_schema_child(node, key, root), root, sub)
    }
    return(invisible(TRUE))
  }
  if (!is.atomic(x) || !length(x) || !anyNA(x)) return(invisible(TRUE))
  array <- length(x) != 1L || inherits(x, "AsIs")
  target <- if (array) sframe_schema_child(node, NULL, root) else node
  if (!sframe_schema_allows_null(target, root)) {
    where <- if (array) sprintf(" at position %d", which(is.na(x))[1]) else ""
    rlang::abort(sprintf(paste0(
      "The field %s holds NA%s, and the .sframe schema allows no null there. ",
      "Give it a value or remove it."), path, where),
      class = c("sframe_validation_error", "sframe_error"))
  }
  invisible(TRUE)
}

# The JSON a payload is written as, by write_sframe() and for hashing.
sframe_payload_json <- function(payload, pretty = FALSE) {
  jsonlite::toJSON(sframe_json_numbers(payload), auto_unbox = TRUE, pretty = pretty,
                   null = "null", digits = NA, json_verbatim = TRUE)
}

# The text a hash is taken over. In the RFC 8785 form an R payload is first
# written as the file would be and read back, so the hash covers exactly what
# a reader of the file sees. `parsed = TRUE` says the payload came from
# jsonlite::parse_json() already.
sframe_hash_json <- function(payload, canonical = TRUE, parsed = FALSE) {
  if (sframe_hash_form() %in% c("jcs", "jcs0")) {
    if (!isTRUE(parsed)) {
      payload <- jsonlite::parse_json(sframe_payload_json(payload), simplifyVector = FALSE)
    }
    return(sframe_jcs(payload))
  }
  if (isTRUE(canonical)) {
    payload <- sframe_canonical_payload(payload)
  }
  jsonlite::toJSON(
    payload,
    auto_unbox = TRUE,
    pretty = FALSE,
    null = "null",
    digits = NA
  )
}

sframe_sha256_json <- function(json) {
  sframe_hex(openssl::sha256(charToRaw(enc2utf8(as.character(json)))))
}

sframe_hash_payload <- function(payload, parsed = FALSE) {
  payload$hash$value <- ""
  sframe_sha256_json(sframe_hash_json(payload, canonical = TRUE, parsed = parsed))
}

# The hash of files written before canonical serialisation: jsonlite's
# defaults, keys in file order, null as {}, numbers with 4 decimals. Read only,
# never written. 4 decimals means 2 numbers that agree to 4 decimals hash the
# same in this form (FR-11).
sframe_legacy_hash_payload <- function(payload) {
  payload$hash$value <- ""
  json_for_hash <- jsonlite::toJSON(payload, auto_unbox = TRUE, pretty = FALSE)
  as.character(openssl::sha256(json_for_hash))
}

sframe_hash_value <- function(instrument) {
  sframe_hash_payload(sframe_serialization_payload(instrument))
}

#' Write an instrument to a .sframe file
#'
#' Serialises an `sframe` instrument object to a UTF-8 JSON file with a
#' SHA-256 integrity hash. The instrument is always validated before writing,
#' and an invalid instrument is refused. The hash is computed over the content
#' with `hash.value` set to an empty string, in the canonical form of RFC 8785,
#' the JSON Canonicalization Scheme: keys sorted, numbers in their shortest form
#' and no whitespace. So it identifies content, not the exact bytes, and
#' SurveyBuilder and the verifier page on the package website compute the same
#' hash. An `NA` is written as null where the published schema allows null for
#' that field, and refused with the field named anywhere else, as is a number
#' JSON cannot hold, such as `Inf`.
#'
#' The hash object is `{"algo": "sha256", "value": ..., "canonical": "rfc8785"}`.
#' `canonical` names the canonical form the hash was taken in. It sits inside
#' the hashed content, so changing it after writing breaks the hash.
#'
#' # Revisions and the amendment log
#'
#' Writing checks the amendment log recorded by [amend_sframe()]. Each entry must
#' follow the one before it, the instrument must still match its last recorded
#' amendment, and an instrument read with [read_sframe()] must keep every
#' amendment it was read with. Content changed since it was read is refused
#' unless the change was recorded with [amend_sframe()]. To publish changed
#' content as a different instrument, remove its amendment log and set
#' `new_instrument = TRUE`.
#'
#' These are checks on the content in hand. The hash is unsigned and can be
#' recomputed by anyone who edits a file, so it does not establish who wrote an
#' instrument or when.
#'
#' The link between an instrument and the file it was read from is an
#' attribute, `sframe_origin`, that [read_sframe()] sets. These checks rest on
#' it. The package's own functions keep it, among them [validate_sframe()],
#' [as_sframe()], [sframe_drop_items()], [sframe_add_references()],
#' `sframe_plan<-` and [sframe_add_model()], as do `$<-`, [modifyList()] and
#' [saveRDS()] with [readRDS()]. Base R that builds a new list from the parts
#' drops it, such as `x[names(x)]`, `c(x)` or [lapply()] over the fields:
#' the result is an instrument read from no file, and its changes are then
#' written with no amendment recorded. Change a read instrument's fields in
#' place, and record the change with [amend_sframe()].
#'
#' @param instrument An `sframe` object created by [sframe_instrument()].
#' @param path Character. The file path to write to. The `.sframe` extension
#'   is appended automatically if not already present.
#' @param pretty Logical. Whether to write formatted JSON with indentation.
#'   Defaults to `TRUE`. Set to `FALSE` for compact files.
#' @param overwrite Logical. Whether to overwrite an existing file. Defaults
#'   to `FALSE`.
#' @param new_instrument Logical. `TRUE` declares that the content is a new
#'   instrument, not a revision of the one it was read from, so no amendment is
#'   required. The instrument must carry no amendment log, and an instrument
#'   read with [read_sframe()] must have a new `meta$title` or `meta$version`,
#'   so 2 different files never claim to be one instrument. Defaults to
#'   `FALSE`.
#'
#' @return The file path, invisibly.
#' @export
#' @seealso [read_sframe()], [validate_sframe()]
#'
#' @examples
#' instr <- read_sframe(
#'   system.file("extdata", "tourism_services_demo.sframe",
#'               package = "surveyframe")
#' )
#' out <- write_sframe(instr, tempfile(fileext = ".sframe"))
#' sframe_show(out)
#' @family Design functions
write_sframe <- function(instrument, path, pretty = TRUE, overwrite = FALSE,
                         new_instrument = FALSE) {
  sframe_check_instrument(instrument)

  if (!endsWith(path, ".sframe")) {
    path <- paste0(path, ".sframe")
  }

  if (file.exists(path) && !overwrite) {
    sframe_abort_import(
      paste0("File already exists: '", path,
             "'. Use overwrite = TRUE to replace it."),
      path = path
    )
  }

  # Validate before writing and persist the validation flag. validate_sframe()
  # returns a diagnostic since 0.4.0, so the instrument comes back through
  # as_sframe().
  instrument <- as_sframe(validate_sframe(instrument, strict = TRUE))
  sframe_check_amendment_boundary(instrument, new_instrument)

  # Build the full JSON payload with an empty hash placeholder
  payload <- sframe_serialization_payload(instrument)
  sframe_check_na_schema(payload)

  # Insert real hash
  payload$hash$value <- sframe_hash_payload(payload)

  # The same writer the hash read back (sframe_payload_json()), so the file
  # holds every number in the digits the hash covers. jsonlite's default of 4
  # decimals once rounded a weight of 1/3 on disk after the hash was taken in
  # full, and the untouched file failed its own check.
  json_out <- sframe_payload_json(payload, pretty = pretty)
  writeLines(json_out, con = path, useBytes = FALSE)

  invisible(path)
}

sframe_as_vector <- function(x, mode = NULL) {
  if (is.null(x)) {
    return(NULL)
  }

  # A null in an array, as jsonlite writes NA, reads back as NA in its place.
  if (is.list(x)) x[vapply(x, is.null, logical(1))] <- list(NA)

  out <- unlist(x, recursive = TRUE, use.names = FALSE)
  if (is.null(mode)) {
    return(out)
  }

  switch(
    mode,
    character = as.character(out),
    numeric = as.numeric(out),
    logical = as.logical(out),
    out
  )
}

sframe_empty_to_null <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }

  if (is.list(x) && length(x) == 0) {
    return(NULL)
  }

  x
}

sframe_restore_item <- function(item) {
  item$required <- isTRUE(item$required)
  item$reverse <- isTRUE(item$reverse)
  item$choice_set <- sframe_empty_to_null(item$choice_set)
  item$scale_id <- sframe_empty_to_null(item$scale_id)
  item$help <- sframe_empty_to_null(item$help)
  item$placeholder <- sframe_empty_to_null(item$placeholder)
  item$matrix_items <- sframe_as_vector(
    sframe_empty_to_null(item$matrix_items),
    "character"
  )
  item$comparison_items <- sframe_as_vector(
    sframe_empty_to_null(item$comparison_items),
    "character"
  )
  item$comparison_scale <- sframe_empty_to_null(item$comparison_scale)
  if (!is.null(item$comparison_scale)) {
    item$comparison_scale <- as.character(item$comparison_scale)[1]
  }
  item$slider_min <- if (!is.null(sframe_empty_to_null(item$slider_min))) {
    as.numeric(item$slider_min)
  } else {
    NULL
  }
  item$slider_max <- if (!is.null(sframe_empty_to_null(item$slider_max))) {
    as.numeric(item$slider_max)
  } else {
    NULL
  }
  item$slider_step <- if (!is.null(sframe_empty_to_null(item$slider_step))) {
    as.numeric(item$slider_step)
  } else {
    NULL
  }
  item$rating_max <- if (!is.null(sframe_empty_to_null(item$rating_max))) {
    as.integer(item$rating_max)
  } else {
    NULL
  }
  item$rating_icon <- sframe_empty_to_null(item$rating_icon)
  item$date_min <- if (!is.null(sframe_empty_to_null(item$date_min))) {
    as.character(item$date_min)
  } else {
    NULL
  }
  item$date_max <- if (!is.null(sframe_empty_to_null(item$date_max))) {
    as.character(item$date_max)
  } else {
    NULL
  }
  item$section_intro <- sframe_empty_to_null(item$section_intro)
  item$page <- if (!is.null(sframe_empty_to_null(item$page))) {
    as.integer(item$page)
  } else {
    NULL
  }
  class(item) <- "sf_item"
  item
}

sframe_restore_choices <- function(choice) {
  choice$values <- sframe_as_vector(choice$values)
  choice$labels <- sframe_as_vector(choice$labels, "character")
  choice$allow_other <- isTRUE(choice$allow_other)
  choice$randomise <- isTRUE(choice$randomise)
  # Kept only when TRUE, as sframe_choice_set() stores it (0.4.3).
  choice$ordered <- if (isTRUE(choice$ordered)) TRUE else NULL
  class(choice) <- "sf_choices"
  choice
}

sframe_restore_scale <- function(scale) {
  scale$items <- sframe_as_vector(scale$items, "character")
  scale$reverse_items <- sframe_as_vector(scale$reverse_items, "character")
  scale$weights <- sframe_as_vector(scale$weights, "numeric")
  if (!is.null(scale$min_valid)) {
    scale$min_valid <- as.integer(scale$min_valid)
  }
  class(scale) <- "sf_scale"
  scale
}

sframe_restore_branch <- function(branch) {
  if (is.list(branch$value) && length(branch$value) > 0) {
    branch$value <- sframe_as_vector(branch$value)
  }
  class(branch) <- "sf_branch"
  branch
}

sframe_restore_conjoint <- function(design) {
  design$attributes <- lapply(design$attributes %||% list(),
                              function(x) sframe_as_vector(x, "character"))
  rebuild <- function(cols) {
    if (is.null(cols) || length(cols) == 0) return(NULL)
    cols <- lapply(cols, function(col) sframe_as_vector(col))
    as.data.frame(cols, stringsAsFactors = FALSE)
  }
  design$profiles <- rebuild(design$profiles)
  design$tasks    <- rebuild(design$tasks)
  # Round-tripping through JSON turns a length-1 integer into a double, and
  # the print method and the schedule arithmetic both expect integers.
  for (f in c("seed", "blocks", "n_alternatives", "n_tasks")) {
    if (!is.null(design[[f]])) design[[f]] <- as.integer(design[[f]])
  }
  class(design) <- "sf_conjoint_design"
  design
}

sframe_restore_check <- function(check) {
  check$pass_values <- sframe_as_vector(check$pass_values)
  class(check) <- "sf_check"
  check
}

sframe_restore_analysis_block <- function(block) {
  block$id <- as.character(block$id %||% "")
  block$research_question <- as.character(block$research_question %||% "")
  block$family <- as.character(block$family %||% "")
  block$method <- as.character(block$method %||% block$test %||% "")
  block$roles <- sframe_empty_to_null(block$roles) %||% list()
  block$options <- sframe_empty_to_null(block$options) %||% list()
  block$hypotheses <- sframe_empty_to_null(block$hypotheses)
  block$decision_rule <- as.character(block$decision_rule %||% block$interpretation %||% "")
  block$reporting_references <- sframe_as_vector(
    sframe_empty_to_null(block$reporting_references %||% block$citations),
    "character"
  ) %||% character(0)
  block$status <- as.character(block$status %||% "draft")
  block$requires_data <- if (is.null(block$requires_data)) TRUE else isTRUE(block$requires_data)
  block$variables <- sframe_as_vector(
    sframe_empty_to_null(block$variables),
    "character"
  )
  block$test <- as.character(block$test %||% block$method %||% "")
  block$alpha <- if (!is.null(sframe_empty_to_null(block$alpha))) {
    as.numeric(block$alpha)
  } else {
    sframe_empty_to_null(block$options$alpha)
  }
  block$interpretation <- as.character(block$interpretation %||% "")
  block$citations <- sframe_as_vector(
    sframe_empty_to_null(block$citations),
    "character"
  ) %||% character(0)
  block$result <- sframe_empty_to_null(block$result)
  block
}

sframe_restore_model <- function(model) {
  if (is.null(model$type)) model$type <- "cfa"
  if (identical(model$type, "sem")) model$type <- "cb_sem"
  if (is.null(model$engine)) {
    model$engine <- switch(
      model$type,
      cfa = "lavaan",
      cb_sem = "lavaan",
      pls_sem = "seminr",
      sem = "lavaan",
      "lavaan"
    )
  }
  if (is.null(model$measurement)) model$measurement <- list(constructs = list())
  if (is.null(model$measurement$constructs)) model$measurement$constructs <- list()
  if (is.null(model$structural)) {
    model$structural <- list(paths = list(), covariances = list(), indirect = list())
  }
  if (is.null(model$structural$paths)) model$structural$paths <- list()
  if (is.null(model$structural$covariances)) model$structural$covariances <- list()
  if (is.null(model$structural$indirect)) model$structural$indirect <- list()
  if (is.null(model$options)) model$options <- list()

  model$measurement$constructs <- lapply(model$measurement$constructs, function(con) {
    con$items <- sframe_as_vector(sframe_empty_to_null(con$items), "character") %||% character(0)
    con$mode <- as.character(con$mode %||% "reflective")
    class(con) <- "sf_construct"
    con
  })
  model$structural$paths <- lapply(model$structural$paths, function(path) {
    class(path) <- "sf_path"
    path
  })
  model$structural$covariances <- lapply(model$structural$covariances, function(cov) {
    class(cov) <- "sf_covariance"
    cov
  })
  model$structural$indirect <- lapply(model$structural$indirect, function(ind) {
    ind$through <- sframe_as_vector(sframe_empty_to_null(ind$through), "character") %||% character(0)
    class(ind) <- "sf_indirect"
    ind
  })
  class(model) <- "sf_model"
  model
}

# The fields every .sframe profile shares. version, choices and scales are
# optional, and default when absent, so a minimal file conforming to the
# published instrument profile reads. A file with no sframe_format predates the
# field (2026-08-22) and is read as a legacy file. A newer major format version
# is refused, since its shape may have changed in ways this reader cannot see.
sframe_validate_parsed_payload <- function(parsed, path, require_hash = TRUE) {
  if (!is.null(parsed$sframe_format)) {
    fmt <- as.character(parsed$sframe_format)[1]
    if (!grepl("^[0-9]+\\.[0-9]+$", fmt)) {
      sframe_abort_import(
        paste0("Invalid .sframe file: sframe_format '", fmt,
               "' is not a version number."), path = path)
    }
    major <- as.integer(sub("\\..*$", "", fmt))
    supported <- as.integer(sub("\\..*$", "", SFRAME_FORMAT_VERSION))
    if (major > supported) {
      sframe_abort_import(
        paste0("This .sframe file uses format ", fmt, ", newer than the ",
               SFRAME_FORMAT_VERSION, " this version of surveyframe reads. ",
               "Update surveyframe to read it."), path = path)
    }
  }
  required <- c(if (require_hash) "hash", "meta", "items")
  missing <- setdiff(required, names(parsed))
  if (length(missing) > 0) {
    sframe_abort_import(
      paste0(
        "Invalid .sframe file: missing required ", sframe_plural(length(missing), "field"), ": ",
        paste(missing, collapse = ", "),
        "."
      ),
      path = path
    )
  }

  if (require_hash && (!is.list(parsed$hash) ||
      !identical(parsed$hash$algo %||% "", "sha256") ||
      is.null(parsed$hash$value))) {
    sframe_abort_import(
      "Invalid .sframe file: missing SHA-256 hash metadata.",
      path = path
    )
  }

  if (!is.list(parsed$meta) ||
      is.null(parsed$meta$title) ||
      !is.list(parsed$items) ||
      !(is.null(parsed$choices) || is.list(parsed$choices)) ||
      !(is.null(parsed$scales) || is.list(parsed$scales))) {
    sframe_abort_import(
      "Invalid .sframe file: expected a recognised payload structure.",
      path = path
    )
  }
}

#' Read an instrument from a .sframe file
#'
#' Reads a `.sframe` JSON file, or the same JSON held as text, and
#' reconstructs an `sframe` instrument object. The SHA-256 integrity hash is
#' verified by default, and content that does not match its hash is refused. The hash covers a canonical form of the
#' content, so it detects a change to the content of a written file, and it
#' ignores whitespace and key order. It is unsigned, so anyone who edits a file
#' can also recompute it.
#'
#' The hash's `canonical` field names the form it was taken in. A file naming
#' `"rfc8785"` is checked in RFC 8785 alone. A file naming no form was written
#' before the field existed: it is checked in RFC 8785 and then in the forms
#' surveyframe used before 0.4.3, and any match is accepted with a message of
#' class `sframe_locale_order_hash` asking you to save it again. A file naming
#' any other form is refused, since it needs a newer surveyframe.
#'
#' The instrument remembers the content and amendment log it was read with, so
#' [write_sframe()] can refuse an undisclosed revision.
#'
#' @param path Character. The path to a `.sframe` file. Leave it `NULL` and
#'   give `text` to read a payload held in memory.
#' @param validate Logical. Whether to validate the loaded instrument with
#'   [validate_sframe()]. Defaults to `TRUE`. This controls structural
#'   validation only. `verify` controls the integrity hash.
#' @param text Character. The `.sframe` JSON itself, for example a payload a
#'   host keeps in a database, read with no temporary file. One string, or
#'   lines to be joined.
#' @param verify Logical. Whether to refuse content whose hash is missing or
#'   does not match. Defaults to `TRUE`. With `FALSE`, such content is read
#'   with a warning of class `sframe_unverified_warning` and the instrument is
#'   marked unverified (see the Unverified reads section).
#'
#' @section Unverified reads:
#' `verify = FALSE` is for a host holding a payload it cannot vouch for, which
#' it would otherwise rebuild by hand and lose fields doing so. The result
#' carries the attribute `sframe_verified`, `FALSE` (it is `TRUE` on every
#' verified read), and `print()` says so. [write_sframe()] refuses to write an
#' unverified instrument unless `new_instrument = TRUE` declares it new, since
#' nothing ties its content to a state anyone wrote. That holds with the
#' amendment log it was read with too, since the log was read unchecked: a
#' sign-off, a tier or a timestamp edited as text would otherwise be written
#' back and read verified. A new instrument starts a new log, so clear the old
#' one first with `instrument$amendments <- list()`. No amendment can start
#' from it: [amend_sframe()] refuses it.
#'
#' @return An `sframe` object.
#' @export
#' @seealso [write_sframe()], [validate_sframe()]
#'
#' @examples
#' instr <- read_sframe(
#'   system.file("extdata", "tourism_services_demo.sframe",
#'               package = "surveyframe")
#' )
#' print(instr)
#' @family Design functions
read_sframe <- function(path = NULL, validate = TRUE, text = NULL, verify = TRUE) {
  # A payload held in memory (Ethos request 4), so a host need not write a
  # temporary file to read it faithfully.
  if (!is.null(text)) {
    if (!is.null(path)) {
      sframe_abort_import("Give `path` or `text`, not both.", path = path)
    }
    raw_text <- as.character(text)
    path <- "<text>"
  } else {
    if (is.null(path) || !file.exists(path)) {
      sframe_abort_import(
        paste0("File not found: '", path %||% "", "'."),
        path = path
      )
    }
    raw_text <- tryCatch(
      readLines(path, warn = FALSE, encoding = "UTF-8"),
      error = function(e) {
        sframe_abort_import(
          paste0("Could not read file: '", path, "'. ", conditionMessage(e)),
          path = path
        )
      }
    )
  }

  raw_json <- paste(raw_text, collapse = "\n")

  bad <- sframe_escape_problem(raw_json)
  if (!is.null(bad)) {
    sframe_abort_import(
      paste0("Invalid .sframe file '", path, "': it holds ", bad[["what"]],
             ", which R cannot read faithfully."), path = path)
  }

  parsed <- tryCatch(
    jsonlite::fromJSON(raw_json, simplifyVector = FALSE),
    error = function(e) {
      sframe_abort_import(
        paste0("Failed to parse JSON in '", path, "'. ", conditionMessage(e)),
        path = path
      )
    }
  )

  # A key given twice: R would keep the first and JavaScript the last, so the
  # file means 2 things (FR-12).
  dup <- sframe_duplicate_key(parsed)
  if (!is.null(dup)) {
    sframe_abort_import(
      paste0("Invalid .sframe file '", path, "': the key \"", dup[["key"]],
             "\" in ", dup[["path"]], " appears more than once."), path = path)
  }

  sframe_validate_parsed_payload(parsed, path, require_hash = verify)

  # Verify hash. A hash naming rfc8785 is checked in that form alone, one
  # naming no form (written before hash.canonical existed) in RFC 8785 and then
  # the earlier forms, and one naming any other form is refused.
  stored_hash <- if (is.list(parsed$hash)) parsed$hash$value
  canonical <- sframe_hash_canonical(parsed$hash)
  if (identical(as.vector(canonical), "unknown")) {
    sframe_abort_import(
      paste0("'", path, "' names its hash's canonical form as ",
             attr(canonical, "value"), ", which this version of surveyframe does ",
             "not know. The file needs a newer surveyframe."), path = path)
  }
  hash_ok <- FALSE
  if (!is.null(stored_hash)) {
    parsed$hash$value <- ""
    computed_hash <- tryCatch(
      sframe_hash_payload(parsed, parsed = TRUE),
      sframe_canonical_error = function(e) {
        sframe_abort_import(paste0("Integrity check failed for '", path, "'. ",
                                   conditionMessage(e)), path = path)
      })
    hash_ok <- identical(stored_hash, computed_hash)
    # Hashed before hash.canonical existed: RFC 8785 as at 4bd8aba, the 0.4.3
    # development form, the pre-0.4.3 form or the legacy one.
    if (identical(canonical, "absent")) {
      old_ok <- hash_ok || identical(stored_hash, sframe_legacy_hash_payload(parsed)) ||
        (is.character(stored_hash) && length(stored_hash) == 1L &&
           stored_hash %in% sframe_old_form_values(function() sframe_hash_payload(parsed)))
      if (old_ok) {
        hash_ok <- TRUE
        sframe_inform_locale_order(paste0("'", path, "'"))
      }
    }
  }

  if (!hash_ok && !verify) {
    rlang::warn(
      paste0("'", path, "' was read without a matching integrity hash and is ",
             "marked unverified. write_sframe() writes it only as a new ",
             "instrument, with new_instrument = TRUE and a new amendment log."),
      class = c("sframe_unverified_warning", "sframe_warning"))
  } else if (!hash_ok) {
    sframe_abort_import(
      paste0(
        "Integrity check failed for '", path, "'. ",
        "The file may have been modified after it was written. ",
        "Expected hash: ", computed_hash, ". ",
        "Stored hash: ", stored_hash, "."
      ),
      path = path
    )
  }

  # Reconstruct the sframe object
  instrument <- structure(
    list(
      # Read by name, since a minimal file need not list authors or languages.
      meta      = local({
        m <- parsed$meta
        if (!is.null(m$authors)) m$authors <- sframe_as_vector(m$authors, "character")
        if (!is.null(m$languages)) m$languages <- sframe_as_vector(m$languages, "character")
        m
      }),
      items     = lapply(parsed$items, sframe_restore_item),
      choices   = lapply(parsed$choices %||% list(), sframe_restore_choices),
      scales    = lapply(parsed$scales %||% list(), sframe_restore_scale),
      branching = lapply(parsed$branching %||% list(), sframe_restore_branch),
      checks    = lapply(parsed$checks %||% list(), sframe_restore_check),
      # Absent in every file written before conjoint designs existed, so this
      # stays an empty list rather than failing on an older instrument.
      designs   = lapply(parsed$designs %||% list(), sframe_restore_conjoint),
      analysis_plan = lapply(
        parsed$analysis_plan %||% list(),
        sframe_restore_analysis_block
      ),
      models    = lapply(parsed$models %||% list(), sframe_restore_model),
      render    = parsed$render %||% list(),
      # Absent in every file written before amend_sframe() existed, so this
      # stays an empty list rather than failing on an older instrument, same
      # precedent as `designs` above.
      amendments = lapply(parsed$amendments %||% list(), sframe_restore_amendment),
      # Absent in every file written before 0.4.3, same precedent again.
      references = lapply(parsed$references %||% list(), sframe_restore_reference),
      # D13, 0.4.3. Absent in older files.
      study = sframe_restore_study(parsed$study)
    ),
    class = "sframe"
  )

  if (validate) {
    instrument <- as_sframe(validate_sframe(instrument, strict = TRUE))
  }

  # What the instrument was when read, kept on the object and never written,
  # so write_sframe() can tell a disclosed revision from an undisclosed one.
  attr(instrument, "sframe_verified") <- hash_ok
  attr(instrument, "sframe_origin") <- list(
    path = path,
    verified = hash_ok,
    # A field R cannot write, such as an empty key, has no R fingerprint. The
    # file still reads, and write_sframe() refuses it with the field named.
    content_hash = tryCatch(sframe_content_hash(instrument),
                            sframe_canonical_error = function(e) NA_character_),
    # The identity read, so a new instrument written from it must differ.
    title = instrument$meta$title %||% "",
    version = instrument$meta$version %||% "",
    amendment_new_hashes = vapply(instrument$amendments %||% list(),
                                  function(a) a$new_hash %||% "", character(1)),
    # Every field of every recorded entry, so an edit to a disclosure is as
    # detectable as an edit to the content it describes.
    amendment_entry_hashes = sframe_amendment_entry_hashes(
      instrument$amendments %||% list())
  )

  # A file's hash vouches for the file, and says nothing of whether its
  # amendment log describes the content it holds. A log written by another
  # tool, SurveyBuilder among them, is checked here: each entry follows the
  # one before, and the last ends at this content.
  if (isTRUE(hash_ok) && length(instrument$amendments) > 0) {
    sframe_check_amendment_log_read(instrument, path)
  }

  instrument
}
