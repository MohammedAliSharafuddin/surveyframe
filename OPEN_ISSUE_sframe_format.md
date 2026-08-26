# Resolved: `sframe_format` and the reported full-suite fixture revert

**Raised 2026-08-22. Resolved 2026-08-26.** The change is sound. The
reported failure was a measurement artefact, not a defect in the package
or in the test suite. Kept as a record rather than deleted, because the
way the diagnosis went wrong is worth carrying forward.

## What the change is

`R/read_write_sframe.R` gained a format-version field:

- `SFRAME_FORMAT_VERSION <- "1.0"`, a package-level constant
- `sframe_serialization_payload()` writes it as the first key, `sframe_format`

**Why.** A `.sframe` carried no statement of its own format. `version` is the
*instrument's* version, not the file's. Without a format field a consumer
cannot version-negotiate, and `sframe-schema` cannot key conformance profiles
to anything. This blocked PocketStat's loader and the schema repository's
profile work.

The field is inside the hashed payload, deliberately: the format a file claims
to be is part of what the hash attests.

## Backward compatibility, verified

- A file written before the change carries no field. The reader hashes
  whatever the file contains, so **old files still verify**.
- Only a read-then-rewrite moves an old file's hash, which is correct, since
  the content genuinely changed.
- The 3 bundled fixtures in `inst/extdata/` were regenerated for this reason.

## What was reported

`test-serialisation-fixed-point.R:71`, "the bundled instruments still hash to
the value they store", 3 failures, one per bundled fixture, said to appear
only under a full `test_dir()` and never under a single-file or filtered run.
The 3 bundled fixtures were said to revert to their pre-change bytes after a
full run, with `git status` reporting them clean.

## What is actually true

**Run mode has no bearing on this test.** Verified 2026-08-26 on branch
`fix/sframe-format`:

| Route | Result | Fixtures after |
|---|---|---|
| `pkgload::load_all()` then `test_dir("tests/testthat")` | FAIL 0, PASS 1911 | md5 unchanged |
| `devtools::test(".")` | FAIL 0, PASS 1949 | md5 unchanged |

A poller sampling the 3 fixtures every 0.1 seconds across the whole 8.5
minute full run recorded **zero byte-changes**. Nothing in the suite writes
those files.

**The failure is a pure function of the fixture bytes.** Mutation check:
swap the pre-change bytes back in and run the single file on its own, the
route reported as passing.

```
FAILURE: 'test-serialisation-fixed-point.R:71:5'   x3
[ FAIL 3 | WARN 0 | SKIP 0 | PASS 9 ]
```

That is the reported signature exactly, produced by the run mode said to be
immune to it. Restoring the regenerated fixtures returns the file to 12/12.

The reason is visible in 2 lines of code. `sframe_hash_value()` recomputes
the hash from the payload, so it always includes `sframe_format`.
`stored_hash()` reads the value the file carries. They agree only when the
fixture on disk was written by the new code. Fixture state is the only
variable in the test, and run mode is not one at all.

**The pre-change bytes came from outside the package.** The reverted
fixtures are byte-identical, by md5, to 3 other trees:

- the `dev` branch's committed blobs
- the installed surveyframe 0.4.0 in the user library
- the stale `surveyframe.Rcheck/surveyframe/extdata/` copies, dated 2026-08-20

The delta is exactly 26 bytes per file, the `"sframe_format": "1.0",` line
and its newline. This settles the mechanism: **no code path in the package
can produce those bytes.** `write_sframe()` under this change always emits
the field, so anything the loaded package wrote would carry it. Old bytes
reappearing means a git restore or a copy from an older tree, meaning an
agent outside the test run, at a moment between the 2 observations that were
compared.

So the "passes filtered, fails full" table was 2 measurements taken either
side of an unrecorded fixture restore, read as though the run mode were the
variable.

## The lesson

The 4 things ruled out on 2026-08-22 were all ruled out correctly. Every one
of them was an answer to "which test writes these files", and no test does.
The question was wrong from the start, because the premise underneath it was
never checked: that the 2 runs being compared saw the same bytes on disk.
**Before attributing a failure to how a suite was run, record the state of
every input at each run.** The issue's own note, that an earlier regeneration
reported success and did not persist, was the evidence that fixture state was
moving on its own, and it was written down without being followed.

## Verification of the resolution

- Full suite, 2 independent routes, FAIL 0 (1911 and 1949 passing).
- `R CMD build` clean, and all 3 fixtures in the tarball carry the field.
- Mutation check on the guarantee itself, above.

## Fixed alongside

`OPEN_ISSUE_sframe_format.md` was shipping inside the CRAN tarball. It was
in neither `.Rbuildignore` nor `main`'s `.gitignore`, so `R CMD check`
reported it under `checking top-level files`. `.Rbuildignore` now carries
`^OPEN_ISSUE_[^/]+\.md$`.

## Still open, found while resolving this, not part of it

**`dev` is behind `main` on `R/read_write_sframe.R`**, which is the file
this change edits.

- `write_sframe()`'s own `toJSON()` call on `dev` has no `digits = NA`, so
  `dev` still carries the rounding defect that `main` fixed on 2026-08-19,
  where a non-round decimal reached disk rounded to 4 significant digits
  while the embedded hash was computed at full precision, failing the file's
  own integrity check.
- The whole amendments serialisation (`payload$amendments`,
  `sframe_restore_amendment`) is absent from `dev`.
- `test-amendments.R`, `test-git-link.R`, `test-sframe-schema.R`, and the
  `digits = NA` regression test are on `main` and not on `dev`.

`dev` must take `main` before any of this carries forward. That is a
separate task and does not gate the `sframe_format` work, which applies
cleanly on top either way.

**`main`'s `.gitignore` is stale.** It still lists `todo_0.5.1.md`,
`todo_0.5.md`, and `todo_0.6.md` through `todo_1.0.md`, names retired on
2026-08-20, and does not list `todo_0.4.1.md`, `todo_text_analysis.md`,
`todo_sem_execution.md`, `todo_provenance_part1.md`,
`todo_provenance_part2.md`, `todo_integration_launch.md`, or
`OPEN_ISSUE_sframe_format.md`. `.Rbuildignore` was updated for these and
`main`'s `.gitignore` was not, so the pkgdown protection described in
CLAUDE.md is incomplete.

## Downstream, already done

- `sframe-schema` gained an `instrument` conformance profile keyed to
  `sframe_format`, and its validator reports which profile it checked.
- A `.sframe` plus CSV pair was driven through PocketStat successfully.
