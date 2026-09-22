# cran-comments.md

## This is a corrective release

surveyframe 0.4.2 corrects defects found by an independent review of 0.4.1,
the version currently on CRAN. The review covered 8 areas of the package over
171 findings, 31 of them release-blocking. A second, targeted pass over the
0.4.2 candidate found 4 further blockers, 2 introduced by the first round of
fixes, and held one item pending closure. All are now addressed. Full detail
is in `NEWS.md` and, for the reviewer's own record, in the tracked files
`REVIEW_0.4.2.md` and `HANDOVER_0.4.2_GATES.md`.

## What it fixes

Two classes of defect motivated the timing:

- **Participant-response integrity.** A cleared numeric field could enter its
  boundary value instead of staying empty. A zero-coded choice was
  indistinguishable from a genuine non-response. A dragged ranking's
  displayed order and its submitted order could disagree. A Google Sheets
  collector could store an answer beginning with `=` as a formula instead of
  as typed text, and, closed in this release specifically, a deployment
  lacking the Sheets advanced service now refuses that write outright instead
  of storing it through a method that mutates it. The exported survey's
  thank-you screen no longer claims a response was recorded when delivery is
  unconfirmed (the POST is `no-cors`, so the collector's reply is unreadable
  from the page), and it withholds the destructive restart on that state.
- **Statistical correctness.** Cochran's Q, generated PLS-SEM syntax for
  non-contiguous indicators, MCDA criterion alignment by name instead of
  position, and reversal scope in scale scoring were each wrong in ways that
  produced a plausible number where an error should have appeared.
  `NEWS.md`'s "What you need to change" section lists every result class
  that moves between 0.4.1 and 0.4.2.

`NAMESPACE` gains 2 exports: `analysis_syntax()`, which returns the
statistical call behind a computed result so a report can show the exact code
that reproduces it, and `sframe_result_supplement()`, exported because the
Quarto report template runs in a separate R session against the installed
package and can only call exported functions.

## Checks run

- `R CMD check --as-cran` on the built tarball: **0 errors, 0 warnings,
  1 NOTE** (the incoming-feasibility note below). Examples,
  `--run-donttest`, tests, and vignette rebuilding all passed. Run against
  commit `872e60d`, tarball SHA-256
  `38cc2caf51bff95529370a15f44e61e5a4a04f6c6828210b32c5810fcfe09bae`.
- Full local test suite: 0 failures.
- [Platform and R-version matrix to fill in before submission. win-builder
  R-release and R-devel are still outstanding as of this file's drafting.]

## incoming-feasibility NOTE

```
Number of updates in past 6 months: 7
```

Understood. This is a corrective release addressing defects with real
consequences for data collected today (silent alteration or loss of a
participant's answer) and for results already computed and reported
(statistics that were wrong in ways that produced no error). The frequency
reflects catching and fixing those defects promptly, in place of batching
unrelated work into fewer releases.

## Downstream

No reverse dependencies are known to be affected. One first-party consumer,
Ethos, deliberately pins surveyframe 0.4.1 and is unaffected by this
release. `NEWS.md` records what changes for it if and when it upgrades.
