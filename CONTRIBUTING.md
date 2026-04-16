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
`hash.value` field set to an empty string. Do not modify the JSON schema
without updating `write_sframe()`, `read_sframe()`, and the schema version in
`DESCRIPTION`.

## Code style

- Use the `sf_` prefix for all constructor functions
- Use snake_case throughout
- No em dashes in documentation prose
- Roxygen descriptions should be complete sentences
- Every exported function needs a `@examples` block, even if the example is
  wrapped in `\dontrun{}`
