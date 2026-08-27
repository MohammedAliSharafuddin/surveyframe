# Contributing to surveyframe

## Three rules that form the package contract

These apply to every exported function, without exception.

**Rule 1.** Every exported function takes `instrument` explicitly unless its
sole purpose is to construct part of the instrument. Functions that build
`sf_item`, `sf_scale`, `sf_choices`, `sf_branch`, and `sf_check` objects are
the only exceptions.

**Rule 2.** Every reporting function returns a structured object first and
prints second. The object should be useful to downstream code. The print
method is a convenience, not the primary output.

**Rule 3.** Every validator fails with a custom condition class from
`R/conditions.R`. Raw `stop()` calls are not permitted in exported functions.
Use `rlang::abort()` with a named class from the `sframe_` family.

## Condition classes

All condition classes are defined in `R/conditions.R`. Use the appropriate
class:

- `sframe_validation_error`: instrument structure is invalid
- `sframe_import_error`: file cannot be read or parsed
- `sframe_branching_error`: branching rule references a missing item
- `sframe_quality_warning`: data quality issue flagged during response review
- `sframe_missing_data_warning`: missing data exceeds threshold
- `sframe_scoring_warning`: scoring cannot proceed due to structural issue

## File format

`.sframe` files are UTF-8 JSON with a SHA-256 integrity hash in the top-level
`hash` key. The hash is computed over the full serialised content with the
`hash.value` field set to an empty string. The full field-by-field format is
documented independently of the R source in `inst/schema/sframe_schema.json`
(a JSON Schema, so a reviewer or a second tool can validate a `.sframe` file
without installing this package). Do not modify the payload's top-level keys
without updating, together: `sframe_serialization_payload()` and
`read_sframe()`'s reconstruction in `R/read_write_sframe.R`, the schema file,
and this document.

An `.sframe` file's SHA-256 hash proves the file on disk is unchanged since
`write_sframe()` produced it. It proves nothing about the content's
methodological quality, and it cannot be a substitute for disclosed
revision -- `amend_sframe()` gives legitimate revision a structured,
recorded path, but it is opt-in: nothing stops a contributor from
reconstructing an instrument and writing it fresh instead of calling
`amend_sframe()` first. Do not describe the hash, the amendment log, or
`link_git_commit()` in documentation as detecting or preventing
undisclosed change beyond what they actually do -- the hash detects that
a file changed; the amendment log records a change the researcher chose
to disclose. Neither compels disclosure.

## Stability policy

Exported functions are not removed or renamed without a deprecation cycle:
mark the old name `.Deprecated()`, keep it working for at least one minor
release, and record the change in `NEWS.md` under a "Deprecated" heading.
Breaking changes to an exported function's arguments or return type are
also recorded in `NEWS.md`, explicitly labelled "Breaking," whether or not
the function's name changed (see the 0.4.0 entry for `validate_sframe()`'s
return-type change as the pattern to follow). The `.sframe` JSON Schema
(`inst/schema/sframe_schema.json`) follows the same rule: a new required
top-level key breaks every file written before it existed, so new keys are
added only as optional, backward-compatible additions (see how `designs`
and `amendments` are both added-only-when-present in
`sframe_serialization_payload()` for the pattern).

## Code style

- Use the `sf_` prefix for all constructor functions
- Use snake_case throughout
- No em dashes in documentation prose
- Roxygen descriptions should be complete sentences
- Every exported function needs a `@examples` block, even if the example is
  wrapped in `\dontrun{}`
