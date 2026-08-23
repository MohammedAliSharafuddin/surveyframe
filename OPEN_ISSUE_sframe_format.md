# Open issue: `sframe_format` and the full-suite fixture revert

**Top priority when surveyframe development resumes.** Raised 2026-08-22.
Work is uncommitted on `dev`. Do not commit or release until this is
understood.

## What was changed

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
  whatever the file contains, so **old files still verify**. Confirmed.
- Only a read-then-rewrite moves an old file's hash, which is correct, since
  the content genuinely changed.
- The 3 bundled fixtures in `inst/extdata/` were regenerated for this reason.

## The unexplained failure

`test-serialisation-fixed-point.R:71`, "the bundled instruments still hash to
the value they store", 3 failures, one per bundled fixture.

**It depends on how the suite is run.**

| How run | Result |
|---|---|
| `test_file("tests/testthat/test-serialisation-fixed-point.R")` | **passes**, 12/12 |
| `test_dir(filter = "zzprobe\|serialisation")` | **passes** |
| `test_dir("tests/testthat")`, full suite | **fails**, 3 |

After a **full** suite run, `inst/extdata/*.sframe` revert to their
pre-change bytes: `git status` reports them clean and `sframe_format` is gone.
After a filtered run they are untouched, md5 identical before and after.

So something in the full suite, and not in the serialisation tests
themselves, rewrites those 3 files with pre-change content.

## What has been ruled out

- **No test writes to `inst/extdata`.** Grepped for `write_sframe`,
  `file.copy`, `export_static_survey`, `unlink`, `system(` across
  `tests/testthat/*.R`. Nothing targets those paths.
- **No setup, teardown or helper files exist** in `tests/testthat/`.
- **`system.file()` resolves correctly.** A probe test run inside `test_dir`
  printed `/home/maxx/Documents/GitHub/surveyframe-dev/inst/extdata/...` and
  `HAS FIELD: TRUE`, so it is not reading an installed copy.
- **The constant loads.** `surveyframe:::SFRAME_FORMAT_VERSION` returns
  `"1.0"` under `pkgload::load_all()`.

## Leads worth trying first

1. Run the full suite and watch the 3 files with `inotifywait`, or poll their
   md5 between test files, to identify which test file is the mutator.
2. Bisect: run `test_dir` over halves of the suite until the revert
   reproduces.
3. Check whether any test attaches the **installed** surveyframe (a bare
   `library(surveyframe)`), which would shadow `load_all()` and write the old
   format. An installed 0.4.0 is present in the library.
4. Consider whether `surveyframe.Rcheck/` copies are involved; stale trees
   exist at `surveyframe.Rcheck/surveyframe/extdata/` and
   `surveyframe.Rcheck/00_pkg_src/surveyframe/inst/extdata/`.

## Note for whoever picks this up

An earlier attempt at regenerating the fixtures **reported success and did not
persist**: the script printed `fmt=1.0` for all 3 files, and the bytes on disk
were unchanged afterwards. Verify with `git status` and `md5sum`, not with the
script's own output.

## Downstream, already done and not blocked by this

- `sframe-schema` gained an `instrument` conformance profile keyed to
  `sframe_format`, and its validator reports which profile it checked.
- A `.sframe` plus CSV pair was driven through PocketStat successfully.
