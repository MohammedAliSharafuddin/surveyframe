# todo_0.5.1.md — surveyframe v0.5.1: Faculty demo proofing

Dev-only planning file, tracked on `dev` only. Its name is in `.gitignore`
and `.Rbuildignore`. Companion to `CLAUDE.md` and `todo_0.5.md`.
Renamed from `todo_0.4.1.md` 2026-07-25.

**Decision gate fired early, 2026-07-25 (owner decision, recorded in
`../portfolio-planner/decisions.md`, superseding the "wait for
2026-10-15" entry).** 0.4 has merged into 0.5 ahead of the scheduled
gate date rather than waiting to see whether the small-sample preprint
DOI landed by 2026-10-15. This patch is confirmed as **0.5.1**
(~2027-02, exact date depends on the merged 0.5's own schedule): the
faculty demo moves to the start of the new semester and adds the MCDM
material to the demo script. Content below is otherwise unchanged from
the original 0.4.1 draft, only the number, date, and demo scope line.

Last updated: 2026-07-25. Target CRAN submission: TBC, follows the
merged 0.5 release date in `../portfolio-planner/master_roadmap.md`
(update once that file's schedule is finalised post-merge). The
proofing mechanism is a live demo session to college faculty after the
merged release ships; the deliverable is the fixes that session
surfaces. **Strict patch scope: no new analytical features, no new
exports.** UI/UX and documentation fixes only (moved here from the
original 0.3.3 plan).

---

## Before the demo (preparation, not deliverables)

- Rebuild the demo flow on the released 0.4: instrument design in the
  builder, deployment, a handful of live responses, the analysis run
  including one small-sample block (the 0.4 headline), and the rendered
  report. Script it as a repeatable `demo/` R script or a documented
  click path so the session does not improvise.
- Verify the RStudio add-in (shipped with 0.4) registers and launches
  in a clean RStudio install — faculty will see the IDE surface first.
- Fresh install test on one machine that has never had surveyframe:
  `install.packages("surveyframe")`, README quick start, lead vignette.

## During and after

- Dogfeed protocol: capture every observation in `dogfeed.todo.md`
  live, one entry per item, status `open`, no fixing during the
  session. Include verbatim confusion moments (what a non-author
  expected a control or function to do) — those are the highest-value
  items this patch exists for.
- Triage to patch scope / version target / wontfix, then fix in
  mas_review rounds (`mas_review_041.md`), chromote-verified for UI
  items, exactly as in 0.3.4/0.3.5.
- Documentation fixes count as first-class deliverables here: help
  files, README, vignette copy, builder microcopy, error message
  wording.

## Release process

Same as todo_0.3.5.md: rebuild, review rounds, document, full suite,
`R CMD check --as-cran` 0/0/<=1 NOTE, win-builder both flavours,
`cran-comments.md`, NEWS.md, submission by 2026-12-11, holding CRAN's
release-spacing preference against the 0.4 acceptance date.

## Delegation and token budget

Same small-crew model as todo_0.3.5.md: lead triages and fixes, Haiku
for verification sweeps, at most one Sonnet agent for batched
independent copy/doc fixes. Token rules from `todo_0.4.md` apply.
