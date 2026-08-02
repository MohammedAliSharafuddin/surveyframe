# surveyframe dogfeed log + 0.3.3/0.3.4 build runbook

Excluded from the CRAN build (via .Rbuildignore) and from the public repo
(via .gitignore). Lives only in the dev workspace.

This file has two jobs now. It is still the running dogfeed log (real-user
feedback on the SurveyBuilder, captured 2026-07-06 to 2026-07-08). It is also
a build runbook, assembled 2026-07-08 for an automated session (assigned to
Fable 5) that is meant to take both v0.3.3 and v0.3.4 to ship-ready in one
pass. Read the "Read this first" section before doing anything else — the
two version scopes in `roadmap.md` do not fully overlap with what got
dogfooded in this session, and that gap has to be closed by Fable 5, not
assumed away.

Status key for individual items: `open` (raised, not yet triaged), `planned`
(assigned to a version in roadmap.md), `fixed` (done, needs a note in
NEWS.md), `wontfix` (decided against, with reason).

---

## Read this first (Fable 5)

**Do not start editing source until the project owner has explicitly said
"dogfeed is complete."** Per `CLAUDE.md`, no source file (`R/`, `inst/`,
tests, vignettes) is touched while a dogfeed session is open. This runbook
does not itself close the session.

**The three bodies of work below are not the same thing, and this dogfeed
session only actually covered one of them:**

1. **v0.3.3 as scoped in `roadmap.md`** is real-world hardening of the
   AIC-RSAM room-service mobile static survey (from the local
   `AI_Room_service/` prototype) plus the first live end-to-end verification
   of the Google Sheets collector. **This dogfeed session never opened or
   tested that instrument.** Everything logged here is from clicking around
   `surveyframe::launch_builder()` on desktop. Phase A below tells you how to
   actually do the 0.3.3 work; you cannot mark 0.3.3 exit criteria met just
   by fixing the items in Phase B.
2. **v0.3.4 as scoped in `roadmap.md`** is the ggplot2 visualisation layer:
   a brand theme, `plots = TRUE` on the analysis runners, the first family
   of plots, and a `$table` slot on inferential runners. **Nothing in this
   dogfeed session touched that code path either** — the SurveyBuilder is a
   client-side HTML/JS app with no ggplot2 involvement. Phase C below is a
   fresh task breakdown from the roadmap deliverables, not derived from
   dogfeeding.
3. **What this dogfeed session actually produced** is a batch of SurveyBuilder
   desktop-UI bugs, logic gaps, and a UX redesign proposal (Phase B). Some of
   these are small, patch-safe logic/text fixes that plausibly ride along
   with 0.3.3's "UI/UX fixes from the ICSRI presentation audience" deliverable.
   Others (the design-system rework, the editable report writer) are new
   capability that does not fit either version's scope as roadmap.md defines
   it today and should not be silently bundled in. Each item in Phase B is
   tagged with a recommended lane; don't override the tag without checking
   with the project owner first, since `roadmap.md` is the canonical schedule
   and this file is not authorised to silently amend it.

**Session scope, confirmed 2026-07-08:** this session targets v0.3.3 and
v0.3.4 only. **v0.3.5 through v0.4 are explicitly out of scope for this
session** — the project owner confirmed this after being asked whether to
push further. That arc (six ~21-day patches plus a 0.4 minor) is real,
scoped, months of work in `roadmap.md`; don't start any of it here. Treat
"After this session" at the bottom of this file as the actual handoff point,
not a suggestion.

**v0.3.3's A6 deliverable is blocked, not merely deferred — exclude it from
this session's exit criteria.** "UI/UX fixes from the ICSRI presentation
audience" depends on feedback from a conference that happens 8-9 August
2026, which has not occurred yet (this runbook was written 2026-07-08). No
amount of session time closes that gap. Ship v0.3.3 against A1-A5 and A7 only,
and either (a) hold the release until real ICSRI feedback exists and file A6
as a follow-up patch, or (b) get the project owner to explicitly drop A6 from
this release's exit criteria and amend `roadmap.md` accordingly — don't
invent placeholder "audience feedback" to check the box.

**Execution order for a single session covering both versions:**

1. Phase A (v0.3.3, roadmap-scoped, A6 excluded per above) — do this first;
   it is the version closest to shipping and has external, physical exit
   criteria (a phone test, a live Google Sheets round trip) that need the
   most lead time.
2. Phase B (SurveyBuilder findings from this dogfeed session) — patch-safe
   items only (tagged `lane: 0.3.3-safe` below) ride along with Phase A.
   Items tagged `lane: defer` should become their own tracked
   `roadmap.md` entry, not get built in this session.
3. Phase C (v0.3.4, roadmap-scoped) — start only once Phase A's exit
   criteria (A1-A5, A7) are met and 0.3.3 is ready to tag.
4. Ship checklist — run once after 0.3.3 tags, and again after 0.3.4 tags.
   Do not batch both versions into one tag/release; `DESCRIPTION`'s `Version:`
   field only ever holds one version at a time, and `roadmap.md` tracks them
   as separate dated releases.
5. Stop. Do not continue into v0.3.5. Leave anything unfinished, deferred, or
   out of scope in "After this session" for the project owner to re-scope.

---

## Session log

### 2026-07-06 — session opened

Fresh dogfeed session started via `surveyframe::launch_builder()`. Source
files are not to be edited until this session is declared complete; items are
logged only.

### 2026-07-08 — session continued, then reframed as a build runbook

Resumed the same dogfeed session, still `surveyframe::launch_builder()`. Same
no-source-edit rule in force.

Two interactions manually re-checked and confirmed working, no item needed:

- **Item list drag-to-reorder** (Build tab, left sidebar) — works fine as of
  now. Re-verify after Phase B's design-improvement arc lands, since that
  work touches the same item-list markup/CSS.
- **Undo/redo** (Ctrl+Z / Ctrl+Y, header toolbar buttons) — works fine.

A full read of `R/builder.R` and `inst/builder/survey_builder.html` (2,358
lines) was done to compare against what had actually been dogfooded so far,
producing the "Flagged for review" inventory folded into Phase B.

Later the same day, the file was restructured a second time into this
runbook after the project owner asked for something comprehensive enough for
Fable 5 to execute v0.3.3 and v0.3.4 together in one session. `roadmap.md`
was re-read in full for both versions' deliverables and exit criteria to
ground Phases A and C accurately (see "Read this first" above for why they
don't map cleanly onto the dogfeed findings).

### 2026-07-09 — live AIC-RSAM deployment reviewed (Fable 5 build session)

The AI_Room_service repo shows the instrument is already deployed and
collecting real responses: hosted at
https://mohammedalisharafuddin.github.io/live-surveys/aic-rsam.html, posting
to a live Google Sheet (ID 18Puv8W2Q5Uj5UTKvjtYkclvOxMKw8GjxaaWAaSMIQMo).
Its `export_survey.R` needed four manual splices, reviewed as 0.3.3
evidence:

- **Splice D (CORS) — real package bug, fixed in 0.3.3.** The stock template
  POSTs with `Content-Type: application/json`, which triggers a CORS
  preflight Apps Script never answers, so every hosted submission is
  silently blocked. Fixed to `mode: no-cors` + `text/plain`, with a
  regression test. After 0.3.3 the deployment can drop this splice.
- **Page-map patch (1b) — not reproducible as described.** Pages survive
  `sf_item(page =)`, post-assembly `instr$items[[i]]$page <-`, the .sframe
  round trip, and export, on both 0.3.2 and 0.3.3 code. The likely cause was
  modifying the standalone item objects after assembly (R copy semantics).
  A regression test now pins the working behaviour; the deployment can
  drop the regex patch by using either supported pattern.
- Splices A/B (iframe srcdoc embedding) and C (sessionStorage booking-state
  bridge) are app-specific integration, not package concerns. C's note
  about manually extending EXPECTED_COLUMNS stands as a future
  `export_google_sheet(extra_columns =)` candidate — not built this session.

A7 status: **verified end to end 2026-07-09 against the live deployment.**
After a local `gs4_auth()`, the 8 real responses collected so far were read
back through `read_sheet_responses()` (correct columns and values,
`quality_report()` runs) and through SurveyStudio's Google Sheet import
card (responses load, Quality Dashboard renders, completion-time analysis
shows a 163-second median after the timing fix below). Two fixes came out
of it, both in NEWS.md: `read_sheet_responses()` gained a `meta_cols`
passthrough so the deployment's `bk_*` bridge columns can be declared, and
SurveyStudio now passes `started_at`/`submitted_at` to `quality_report()`
so timing analysis works at all in the studio.

One usage note, no code change: importing sheet responses against the full
eligibility instrument flags 100 percent of respondents for missingness,
because the seven `elig_*` items are answered inside the booking prototype
and never reach the sheet. Import against the post-use instrument (the one
actually deployed) and the missingness numbers are meaningful. Worth a
mention in the Google Sheets vignette section in a future patch.

### 2026-07-11 — second round of reviewer feedback, applied

Six items raised while running mas_review_033.qmd chunk by chunk, all
fixed and regression-tested:

- **Multi-select export** was a single comma-joined column. Now exports
  one 0/1 column per option (`item__option`), matching the ranking
  pattern from the first review round: the exported survey payload, both
  Apps Script collector generators (R and the builder's own), and
  `read_responses()`'s column expansion all updated.
- **Mobile responsiveness**: stress-tested at 320px with long labels.
  Choice cards and Likert wrapped fine (no real bug there), but the
  matrix grid genuinely needed horizontal scrolling to complete, which is
  poor mobile UX. Below 600px a matrix now reflows into stacked row-cards
  (one card per row, each column becomes a labelled tap target), reusing
  the aria-labels the WCAG pass already added so no accessible name is
  lost. Desktop table layout is unchanged (verified explicitly).
- **Builder "+Add question"**: previously called `qAdd('likert')`
  directly with no type picker, exactly as flagged. It now opens the
  existing, already-WCAG-passing `fabMenu` type picker; the separate "⋮"
  icon button (which did the same job) was removed as redundant. The
  empty canvas's duplicate "+Add your first question" CTA was also
  removed (the sidebar's own button now covers that job), which
  incidentally addresses the "pushed off screen" complaint by shrinking
  the empty-state block — flexbox scroll containment was verified correct
  at down to 450px in isolation, so the push-down was more likely a very
  short RStudio Viewer pane than a CSS bug, but the fix resolves it
  regardless of cause.
- **Settings duplication**: the top-bar gear "Settings" button was a pure
  duplicate of the sidebar title button (both called
  `openSettings('meta')`). Removed per the owner's explicit instruction
  to keep all settings in the sidebar and reserve the top bar for future
  enterprise/academic admin controls. Sidebar entry point verified still
  works.
- **Report table+plot separation**: `run_analysis_plan(plots = TRUE)`
  plots were never wired into `render_report()` at all (neither the
  Quarto template nor the internal HTML fallback referenced `$plot`).
  Both paths now call `plots = requireNamespace("ggplot2", quietly =
  TRUE)` and print each block's chart directly under its table, as one
  unit per research question. New `.render_report_ggplot_png()` embeds
  the ggplot as a base64 PNG for the fallback path, mirroring the
  existing `.render_report_plot_png()` pattern.
- **Likert plots**: the report's "Response distributions" section used
  the same plain horizontal frequency bar for Likert, single-choice, and
  multiple-choice items. Likert items now get a proper diverging stacked
  bar (`sframe_draw_likert_diverging()` in R/plots.R, base graphics only,
  no ggplot2 dependency): darkest colour at each pole, lightest next to
  neutral, the middle category of an odd-length scale split across the
  zero line, verified visually at 4, 5, and 7 points and wired into both
  the Quarto and fallback report paths.

**New issue discovered, not fixed this session (out of scope):**
rendering `combined_quarto.html` from a from-scratch test instrument
showed every `kable()` table in the Quarto-rendered report (codebook,
analysis-plan results, and reliability tables alike) with all columns
collapsed into a single `<td>` per row instead of one cell per column,
under this machine's Quarto 1.8.24 / pandoc 3.9.0.2. Confirmed
pre-existing (the codebook table, untouched this session, shows the same
symptom) and NOT caused by anything in this round's changes. Two
isolated minimal reproductions (a bare kable() in an asis chunk, and one
copying report.qmd's exact YAML header) both rendered correctly, so the
cause is narrower than "asis mode" or "the YAML" alone; the embedded
plot images in the same document render correctly, so this is a
table-specific pandoc/kable interaction, not a document-wide rendering
failure. Needs a fresh investigation with report.qmd's actual
`codebook_report()` data shape as the next lead. Flagged here rather
than in mas_review_033.qmd since it was found through ad hoc testing,
not a checklist step; add it as an H-part item next time the checklist
is revised.

### 2026-07-11 — owner decisions from the review

The live AIC-RSAM deployment stays on the hand-patched 0.3.2 export until
collection ends; it is republished with 0.3.3 afterwards. The lead
vignette gains the plots = TRUE example in this release (added and
knit-verified). Win-builder submission is manual by the owner.

### 2026-07-11 — instrumented review execution and WCAG 2.2 pass

All runnable mas_review_033.qmd chunks executed headlessly; results ticked
in the checklist. An instrumented WCAG 2.2 audit of the exported survey now
reports zero findings across all pages (accessible names, focus visibility,
target sizes, contrast, error and required semantics, headings, keyboard
reordering for ranking). Builder quick wins applied: inspector labels are
programmatically associated and field hints meet contrast. Two real bugs
found and fixed: branching rules had no effect on section breaks and text
blocks (screen-out messages and branched section headings now work), and
`esc(0)` blanking zero-valued attributes. Known divergence recorded: the
Shiny survey renderer (`render_survey()`/`survey_module_ui()`) does not
carry Theme B or the accessibility pass; it converges in the 0.3.4 builder
rework.

### 2026-07-10 — releases merged: 0.3.4 folded into 0.3.3

Owner decision: since neither version had been pushed or submitted, the
planned 0.3.4 (visualisation foundation) and the Theme B survey redesign
merge into 0.3.3 as one release. Version stays 0.3.3, the NEWS entries are
combined, the v0.3.3 tag moves to the final commit, and the remaining
visualisation arc renumbers 0.3.4 to 0.3.8 (breadth, surfaces, effect-size
CIs, psychometric depth, PDF report). The runbook's original "two separate
tags" instruction is superseded by this decision.

### 2026-07-09 — Phase C (v0.3.4) executed after 0.3.3 tagged

v0.3.3 was tagged locally (v0.3.3 on main; pushes pending the project
owner). Phase C then ran to completion in the same session: C1 to C5 all
implemented, tested (519/519), and the plots verified visually against the
AIC-RSAM simulated data. One extra fix rode along, surfaced by looking at
the rendered charts: the frequency and cross-tab runners counted empty
strings as a real category, so partially completed sheet responses showed
as a phantom unnamed bar. They now count as missing. The categorical series
palette was validated programmatically for colour-vision-deficiency
separation and surface contrast rather than picked by eye; the validated
order is documented in `R/plots.R`.

---

## Phase A — v0.3.3: real-world embedding and conference feedback (target 2026-07-25)

Source of truth: `roadmap.md` lines ~130-158. Strict patch scope — **no new
analytical features.** Evidence sources are the AIC-RSAM room-service AI
prototype (local repo: `/home/maxx/Documents/GitHub/AI_Room_service/`, a
QR-accessed mobile static HTML survey with eligibility skip logic and a
six-construct, nine-path model — see `app.js`, `index.html`,
`questionnaire.md`, `research_design.md` there) and the ICSRI 2026
presentation at Villa College, 8-9 August 2026.

### A1. Reproduce the AIC-RSAM instrument as a dev-branch regression fixture

Not started. Read `AI_Room_service/questionnaire.md` and
`AI_Room_service/research_design.md` to rebuild the six-construct, nine-path
instrument as an `sframe` object (or export from surveyframe's builder to
match it), matching its eligibility skip logic. This becomes the fixture the
rest of Phase A is tested against. This mirrors the continuation prompt
already written for this work in `CLAUDE.md` ("Start the 0.3.3 real-world
feedback release").

### A2. Mobile static survey hardening

Not started. Deploy the reproduced instrument as a static HTML survey
(`inst/static_survey/template.html` path) and test on an actual phone-width
viewport (not just a resized desktop browser — check touch target size,
tap-and-hold text selection, on-screen keyboard covering inputs). Fix layout,
touch-target sizing, and progress-bar behaviour on narrow screens.

- **Where:** `inst/static_survey/template.html`, and whatever CSS it shares
  with `inst/builder/survey_builder.html`'s exported-survey template
  (`exportSurveyHtml()` — see Phase B's "Flagged for review" list, this is
  the same export path).
- **Exit signal:** the instrument is usable end to end on a real or
  accurately-emulated phone screen with no layout breakage, no unreachable
  buttons, no keyboard-covers-input issues.

### A3. Branching and skip-logic fixes surfaced by the room-service embedding

Not started — depends on A1 reproducing the instrument first. The AIC-RSAM
instrument has eligibility skip logic; exercise every branch path and fix
whatever the branching engine (`R.render` branching evaluator in the static
template, and the Branching Rule modal in the builder — see Phase B) gets
wrong for this specific instrument's rules.

### A4. Six-construct model syntax correctness checks

Not started — depends on A1. Once the instrument is reproduced, generate its
model syntax (`cfa_syntax()` / model layer) for the six constructs and
nine paths and confirm the syntax is correct lavaan/seminr syntax matching
the intended model. This is a correctness check on existing model-syntax
generation, not new modelling capability.

### A5. Report legibility fixes surfaced by the conference presentation

Not started — this needs an actual `render_report()` run on the AIC-RSAM
data (real or simulated) reviewed at presentation size/projector
resolution, not just a laptop screen. Fix whatever is illegible (font size,
table column width, contrast) in `inst/templates/report.qmd` /
`R/reporting.R` output.

### A6. UI/UX fixes from the ICSRI presentation audience — BLOCKED, excluded from this session

Confirmed 2026-07-08: **do not attempt this deliverable in this session.** It
depends on audience feedback from the 8-9 August 2026 presentation, which has
not happened yet. This isn't a sequencing choice, it's a hard external
blocker — no amount of session time produces real feedback from an event
that hasn't occurred. Do not invent placeholder "audience feedback" to check
this box.

v0.3.3 in this session ships against A1-A5 and A7 only. A6 becomes a
follow-up patch once real ICSRI feedback exists, tracked separately (or
folded into whichever future patch is live at that point) — file it in
`roadmap.md` then, not now. Small, patch-safe SurveyBuilder text/logic fixes
from Phase B tagged `lane: 0.3.3-safe` can still ride with A1-A5/A7 in this
session; they just don't depend on A6's ICSRI feedback to justify inclusion.

### A7. Google Sheets collection verified end to end — highest priority in Phase A

Not started; this is the one item in Phase A that is fully actionable right
now without waiting on external events, and it's explicitly flagged in
`CLAUDE.md` as not yet exercised since 0.3.2 shipped.

- **Where:** `inst/shiny/app.R` (SurveyStudio's Google Sheet response-import
  card), `R/read_sheet_responses.R` (or wherever `read_sheet_responses()`
  lives — confirm exact path), and the builder's Google Sheets settings tab
  / `exportSheetsCollector()` in `inst/builder/survey_builder.html` (also
  listed under Phase B's "Flagged for review", since this dogfeed session
  never opened that settings tab either).
- **What to do:** deploy the AIC-RSAM survey (or any survey) with the
  generated Apps Script collector (.gs file) to a live Google Sheet, submit
  real responses through the deployed static survey, then read them back
  both through SurveyStudio's import card and through
  `read_sheet_responses()` in R. Fix anything broken in that round trip.
- **Exit signal:** a response submitted through the deployed survey is
  correctly readable both in SurveyStudio and via `read_sheet_responses()`
  in R, with no manual data-massaging required.

### Phase A exit criteria (from roadmap.md, verbatim intent)

The room-service instrument deploys and collects responses on a phone
without layout or logic errors, including the Google Sheets collector read
back through SurveyStudio and `read_sheet_responses()`. The rendered report
is readable at conference presentation size.

**None of these can be verified by reading code alone** — A2, A5, and A7 all
require actually running the instrument/report and looking at the result on
the target medium (phone, projector-size render, live spreadsheet). Budget
session time for that, not just for code changes.

---

## Phase B — SurveyBuilder findings from this dogfeed session

Everything below was actually dogfooded (2026-07-06 to 2026-07-08) against
`surveyframe::launch_builder()` / `inst/builder/survey_builder.html`. Each
item has a **lane** tag:

- `lane: 0.3.3-safe` — a bug/logic/text fix, no new capability, small
  enough to plausibly ride with Phase A's "UI/UX fixes" deliverable if the
  project owner agrees. Build these after Phase A's A1-A5 are underway, not
  instead of them.
- `lane: defer` — new capability or a large redesign. Do not build this in
  the same session as Phase A/C without the project owner explicitly
  re-scoping `roadmap.md`. Log it there instead (see "After this session"
  at the bottom of this file) and stop.

### [fixed] `lane: 0.3.3-safe` — Section item's inspector panel mislabels its text field "Question text" instead of a section-appropriate label

Fixed in 0.3.3 (see NEWS.md): the field reads "Section header" for section breaks and "Block text" for text blocks.

- **Where:** SurveyBuilder (`launch_builder()`), Build tab, right-hand item panel, Identity section, for an item of type "Section" (e.g. `sec_1`). Likely `inst/builder/survey_builder.html`, in the inspector field-rendering logic (`renderInspBody()` / field labels keyed by item type).
- **What happened:** When a Section-break item is selected, its inspector shows the field labelled "Question text" (pre-filled with "New section") even though a section break isn't a question — it's a layout/divider element with a header and an introduction text.
- **Expected:** Rename the label for this field to something section-appropriate (e.g. "Section header") when the selected item's type is `section_break`, rather than reusing the generic "Question text" label. Text-only fix, no logic change.
- **Acceptance check:** select a Section item in the Build panel; the field label reads something other than "Question text".

### [open] `lane: defer` — Report writer is static; needs an editable step before exporting to Word/PDF/HTML

- **Where:** `render_report()` in `R/reporting.R` (lines ~192-290) and its Quarto template `inst/templates/report.qmd`. Currently `render_report()`'s `format` argument only accepts `"html"` (`format = c("html")`, `rlang::arg_match(format)`), rendered non-interactively via `quarto render` (or an R Markdown fallback when Quarto isn't installed) straight to a fixed `report.html`. There is no Word/`.docx` or PDF output path and no step where a user can edit content before export.
- **What happened:** The report writer is a one-shot, non-interactive pipeline: instrument + data go in, a fixed HTML report comes out. The user cannot review, edit, reorder, or annotate report content (text, table selection, plot choice) before it is finalised, and cannot export to Word or PDF at all today.
- **Expected:** Add an editable stage between report generation and export — the user should be able to see the drafted report (tables, plots, text) and make edits before committing to a final export, and be able to export the edited version to Word, PDF, and HTML.
- **Why deferred:** this is new capability. PDF export is already explicitly planned for v0.3.9 (`render_report(format = "pdf")` via pagedown, roadmap.md line ~225) — an editable pre-export stage and Word export are not currently in any version's deliverable list. Do not build this in the Phase A/C session; raise it as a candidate addition to v0.3.9 (or its own release) with the project owner instead.

### [open] `lane: defer` — Analyse tab's three sub-tabs need rework (Plan / Run preview / Report outline), and header nav bar needs a UX pass

- **Where:** SurveyBuilder (`launch_builder()`), Analyse tab — the "Plan" / "Run preview" / "Report outline" sub-tab strip, and separately the top header nav bar (Build / Preview / Analyse on the left; Settings / Open / Export survey / Save .sframe on the right). Likely `inst/builder/survey_builder.html`.
- **What happened:** The three Analyse sub-tabs don't currently match what their names imply or what would be most useful: "Plan" should hold the planning phase (adding/editing analysis plan cards, as it does now); "Run preview" should become an analysis queue where the plan cards can actually be drag-and-reordered; "Report outline" currently shows plan-card summaries with "Decision rule pending" placeholders rather than an actual skeleton of the eventual report (empty tables, plot placeholders). Separately, the header nav bar has three buttons grouped on the left and four on the right, which reads as visually unbalanced.
- **What happened (correction, 2026-07-08):** drag-and-reorder of analysis plan cards was checked directly in the source (`pStart`/`pOver`/`pDrop` acting on `S.analysis_plan`, wired to `#rqsBody .rq-card` on the Plan tab) and it does exist and appears functional on the Plan tab today. The original complaint stands for the *Run preview* tab specifically, which shows no plan cards or queue at all right now.
- **Expected:** Rework the three sub-tabs so each does the job its name implies. Decide whether "Report outline" is still the right name or whether "Report skeleton" / "Report preview" communicates it better. Separately, have a UI/UX pass on the header nav bar's left/right button grouping and balance.
- **Why deferred:** this is a redesign of existing surfaces, part of the "Design improvement arc" (below), not a bug fix.

### [open, suggestTest part fixed] `lane: 0.3.3-safe` (validation only) / `lane: defer` (rest) — Auto-draft Research question / Planned decision rule from selected variables; add a human-readable item label separate from Item ID

The suggestTest review ran in 0.3.3 and found two actual wrong suggestions, both fixed (see NEWS.md): Likert items were classified as categorical, so a Likert paired with a continuous variable suggested Mann-Whitney with a five-category grouping; and Mann-Whitney was suggested even when the grouping variable had more than two categories (now Kruskal-Wallis). Citation tags were checked against the ten references in CSHORT and are accurate. The auto-draft text generation and the human-readable item label remain `defer`.

- **Where:** SurveyBuilder (`launch_builder()`), Analyse tab, "Add Analysis Plan" modal — "Research question" and "Planned decision rule in Plan stage" free-text fields, populated after Grouping variable / Outcome variable / Variable X / Variable Y and Analysis method are chosen. Also Build tab, right-hand item panel, Identity section — "Item ID" field. Likely `inst/builder/survey_builder.html` and `R/analysis_plan.R`.
- **What happened:** "Research question" and "Planned decision rule" are currently blank free-text boxes the user must write from scratch, even though the grouping/outcome/X/Y variables and analysis method are already known at that point and could seed a sensible draft sentence. Separately, the only per-item label available in the Build panel is "Item ID" (e.g. `lik_1`, `rat_1`), a machine-safe identifier — there is no separate human-readable label field for an item, needed to print readable variable names in result tables and plots rather than raw IDs.
- **Also worth checking:** the builder already has a `suggestTest()` / suggestion-box feature that proposes a statistical test based on selected variable roles, and auto-populates reporting-citation tags (Field 2018, Cohen 1988, etc.) per method. Neither has been reviewed for quality of suggestion or citation accuracy.
- **Expected:** Auto-generate a draft "Research question" and "Planned decision rule" from the selected variables and method, editable by the user. Add a distinct human-readable label field per item.
- **Split:** if `suggestTest()` review turns up an actual wrong suggestion (not just "could be smarter"), that's a `0.3.3-safe` bug fix. The auto-draft text generation and the new item-label field are new capability — `defer`.

### [fixed] `lane: 0.3.3-safe` — Add Analysis Plan: no validation against picking the same variable for X and Y, and other logic gaps to review

Fixed in 0.3.3 (see NEWS.md): a variable can fill only one role per plan, covering X = Y, mediation X/M/Y conflicts, and dependent-in-predictors. The suggestTest review also found and fixed two wrong suggestions (Likert misclassified as a grouping candidate, and Mann-Whitney suggested for groupings with more than two categories). The processr/model-builder question stays open as its own future scoping item.

- **Where:** SurveyBuilder (`launch_builder()`), Analyse tab, "Add Analysis Plan" modal — Variable X / Variable Y selects for correlation-type methods, and the Analysis method dropdown (Association: Pearson, Spearman, Kendall tau, Partial correlation; Regression: Linear, Binary logistic, Ordinal logistic, Multinomial logistic, Mediation, Moderation; Measurement and models: Cronbach alpha, McDonald omega, Item diagnostics, EFA readiness, EFA solution, CFA lavaan syntax, ...). Likely `inst/builder/survey_builder.html` and the analysis-plan validation logic in `R/analysis_plan.R`.
- **What happened:** For Pearson correlation (and likely the other Association methods), Variable X and Variable Y can both be set to the same item with no warning, which is not a meaningful analysis. The modal's validation only checks "required roles are complete" and variable-type compatibility, not cross-field logical constraints.
- **Expected:** Add a validation rule preventing the same variable being assigned to both X and Y (and equivalent same-variable conflicts in other methods, e.g. mediation/moderation X/M/Y). Review the rest of the modal's methods for comparable logic holes.
- **Acceptance check:** in the Pearson correlation method, selecting the same item for X and Y produces a validation error/warning instead of a silently-accepted plan.
- **Separately raised, not in scope for this session:** whether to expand regression/modelling options by adopting an approach from cardiomoon/processr (https://github.com/cardiomoon/processr) or adding a point-and-click model-builder GUI. This needs a licence check before any adoption decision and is its own future scoping question — do not act on it in this session, just note it exists.

### [fixed, boundable half] `lane: 0.3.3-safe` — Builder startup flow skips survey settings, has no load-existing-survey path, and needs SHA-integrity handling surfaced — rethink against the Shiny (SurveyStudio) workflow

Fixed in 0.3.3 (see NEWS.md): opening a `.sframe` now verifies and reports SHA-256 integrity (verified / mismatch / no hash), and the empty canvas offers "Open an existing .sframe" and "Set up survey settings first" links. The full startup-sequence redesign (settings walkthrough before the canvas) remains `defer` as planned.

- **Where:** `surveyframe::launch_builder()` initial load state (blank canvas with "No questions yet" / "Select a question to edit"). Likely `inst/builder/survey_builder.html`, and worth comparing against `inst/shiny/app.R` (SurveyStudio) which already has an Upload/Open-existing-instrument flow.
- **What happened:** On startup the builder drops straight into an empty "Untitled Survey" build canvas with no questions and no prompt to configure the survey first. There is no visible option at startup to open/load an existing `.sframe` instrument (only "Open" in the header, not surfaced as a first-run choice), and no visible surfacing of the instrument's SHA-256 integrity hash when a survey is loaded or resumed.
- **Also confirmed present (not yet surfaced at startup):** the builder does have working SHA-256 hashing on save (`sframeHash()` in `inst/builder/survey_builder.html`, using `crypto.subtle` with a pure-JS RFC 6234 fallback). The mechanism exists; it's just never shown to the user at load/open time.
- **Expected:** (1) start by asking whether to create a new survey or open an existing `.sframe`, (2) for a new survey, walk through Survey Settings (or at least title/version/language) before landing on the empty build canvas, (3) when opening an existing instrument, verify and surface its SHA-256 integrity status rather than silently loading it. Design consistently with SurveyStudio's existing open/upload flow.
- **Note on lane:** the "open/load a survey at startup + surface SHA integrity on load" half is a straightforward, boundable fix — `0.3.3-safe`. The full startup-sequence redesign (settings walkthrough before the canvas) is closer to a UX redesign — if session time is short, do the load-path and integrity-surfacing half first and treat the rest as `defer`.

### [open] `lane: defer` — Survey settings has two separate entry points; consolidate into one prominent CTA in the left panel

- **Where:** SurveyBuilder (`launch_builder()`), Build tab — the gear icon next to "Demo 1" at the top of the left panel, and the "Settings" button in the header navigation bar. Likely `inst/builder/survey_builder.html`.
- **What happened:** Survey-level settings can be reached from two different places, which is likely to confuse users about which one to use or whether they do different things.
- **Expected:** Redesign into a single, prominent call-to-action button for survey settings, placed at the top of the left panel, above the Welcome/Logo/Thank You buttons. Remove or fold in the duplicate entry point in the header.
- **Why deferred:** layout redesign, part of the Design improvement arc below.

### [fixed] `lane: 0.3.3-safe` — New choice-based question inherits the previous question's choice set

Fixed in 0.3.3 (see NEWS.md): new choice questions start with their own sample set, and editing a shared set on a choice question forks it first.

- **Where:** SurveyBuilder (`launch_builder()`), Build tab, right-hand item panel, Configuration section — "Choice set" / "Choice labels" fields for a newly added Multiple choice / Single choice item. Likely `inst/builder/survey_builder.html`.
- **What happened:** Adding a new choice-based question pre-fills its Choice set / Choice labels with the previous question's choices (e.g. a new item showed `mul_1_choices (3 opts)` with Egg/Chicken/Soya carried over) instead of starting fresh.
- **Expected:** A newly added question of a choice-based type should start with either a blank choice set or a sample choice set appropriate to that specific question type, not the previous question's choices.
- **Acceptance check:** add a Multiple choice item after another Multiple/Single choice item exists; the new item's choice set is not the prior item's choices.

### [open] `lane: defer` (surfacing) / `lane: 0.3.3-safe` (default-choices bug above already covers the core defect) — "+ Add question" flow conflates type-picking, configuration, and choice-set selection

- **Where:** SurveyBuilder (`launch_builder()`), Build tab, "+ Add question" button and its adjacent "..." menu (bottom-left of the item list). Likely `inst/builder/survey_builder.html`.
- **What happened:** Clicking "+ Add question" immediately inserts a default question (an "Agreement item" / Likert type) instead of first asking what type of question to add. The type picker exists but is a separate control from the "+ Add question" button.
- **Also confirmed present (not yet surfaced up-front):** the choice-set modal already has quick-fill sample templates (5-pt agree, 7-pt agree, Yes/No, Frequency, Importance) plus "Include Other option" and "Randomise order" checkboxes — it's just buried inside the Choice Set modal rather than offered at add-question time.
- **Expected:** "+ Add question" should open the question-type dropdown directly rather than defaulting to Likert. Configuration options should live in their own dedicated panel/button, separate from the type-picker dropdown. Choice-set entry should surface the existing quick-fill templates at add-question time.
- **Why deferred:** the "+ Add question opens the type picker directly" change and moving configuration into its own panel is an interaction redesign. It's bundled with the Design improvement arc.

### [fixed] `lane: defer`, re-scoped by owner 2026-07-09 — Question-block designs need a standard design system, benchmarked against Formbricks

Resolved 2026-07-09 on the owner's instruction. Three mock directions were
built (Formbricks option cards, Typeform conversational, branded
editorial); the owner chose the conversational direction ("Theme B") and
asked for it to derive entirely from the builder's single theme-colour
selector. Applied to `inst/static_survey/template.html` (and re-inlined
into the builder): serif question typography, bordered option cards with
key chips and ticks, numbered Likert squares, underline text inputs,
topbar progress with a theme dot, per-question eyebrow in conversational
mode. All tints and shades derive from `--cp` via `color-mix()`, so any
picker colour re-skins the whole survey. Verified through the real export
path at phone width (teal, blue, violet variants), through SurveyStudio's
preview iframe, and by the headless branching suite (519/519). Touch
targets stay at 44px or better. The builder's own Preview tab still uses
its simplified renderer and will lag the new design; restyling it is the
remaining piece of this arc.

- **Where:** All rendered question types across the survey-taking surfaces (static survey template, SurveyStudio preview, builder preview) — multi-select checkboxes, single-select radios, rating/star scales, numeric scales.
- **What happened:** Reference screenshots supplied from formbricks.com/survey-templates (Employee Satisfaction and User Persona templates) show a consistent design language across block types: full-width selectable option rows/cards with visible borders and hover state, a top progress bar, consistent Back/Next button placement, a 1-5 button-style numeric scale, and a 5-star rating control. surveyframe's current blocks do not share one consistent visual system across types.
- **Expected:** Define one shared design system for all question-block types and apply it consistently. Formbricks templates are the reference benchmark, not a literal restyle target.
- **Why deferred:** this is exactly the kind of work the 0.3.4-0.3.9 visualisation/theming arc is for, but it is not one of v0.3.4's actual roadmap deliverables (which are ggplot2-analysis plots, not question-block CSS — see Phase C). Raise it as a candidate for its own slot in that arc, or as a v0.3.4.x addendum, with the project owner. Do not fold it into Phase C's ggplot2 work — they are unrelated code paths (client-side HTML/CSS vs. R/ggplot2).

### [fixed] `lane: 0.3.3-safe` — Header not shown on Welcome screen; inconsistent positioning on Survey screen

Fixed in 0.3.3 (see NEWS.md): the builder preview shows the branded header on Welcome, Survey, and Thank You, and both the preview and the static template give the logo a stable bounding box so the title no longer shifts with logo aspect ratio.

- **Where:** SurveyBuilder (`launch_builder()`), Preview tab — Welcome screen vs. Survey screen. Likely `inst/builder/survey_builder.html` and/or the shared header partial also used by `inst/static_survey/template.html` (`R.render.header`).
- **What happened:** The branded header (logo + title) does not render on the Welcome screen preview at all. It does render on the Survey screen, but its layout is not standard: the title text shifts position depending on the logo's proportions/aspect ratio.
- **Expected:** Header should render consistently on every screen (Welcome, Survey, Thank You), and its layout should be stable regardless of the logo's aspect ratio.
- **Why 0.3.3-safe:** this is a rendering bug in the same header/template code path A2 (mobile hardening) already touches for the AIC-RSAM instrument — fix it alongside A2 rather than as a separate pass, since it's plausible the AIC-RSAM instrument has a logo and hits this exact bug.

### Design improvement arc (all `lane: defer` items above, as one body of work)

These four items are one cohesive builder UX/design pass, not four unrelated
bugs. If/when the project owner scopes this as its own release or a v0.3.4.x
addendum, ship them together and re-verify item-list drag-to-reorder
(confirmed working, session log above) once this arc's markup/CSS changes
land:

1. Question-block design system, benchmarked against Formbricks.
2. Analyse tab's three sub-tabs rework + header nav bar balance.
3. Survey settings' two entry points consolidated to one CTA.
4. "+ Add question" flow reworked: type picker first, configuration and
   choice-set selection split into their own controls.

### Flagged for review — builder features not yet dogfooded

Compiled 2026-07-08 from a direct read of `R/builder.R` and
`inst/builder/survey_builder.html`. These exist in the builder today but
haven't been clicked through or commented on by a real user. Not bugs — an
inventory of what still needs eyes. If Fable 5 has session time left after
Phase A and the `0.3.3-safe` items above, exercising these (especially the
Google Sheets tab, which duplicates A7's scope from the builder side) is
higher value than starting Phase C early.

**Build tab — core editing**
- Item search box (`#itemSearch`) — live filter vs. requires Enter, unclear.
- Duplicate / Delete item, including the confirm dialog claiming deletion
  "removes the item from all scales, branches, and checks" — worth
  stress-testing that cross-reference cleanup actually happens correctly.
- Section break / Text block layout items beyond the label bug logged above.
- Individual question types not yet commented on: Matrix/grid, Numeric,
  Short text, Long text, Slider, Date, Ranking (in-survey drag reorder),
  Rating (surveyframe's own star control).

**Choice set / Scale / Branching / Attention check modals**
- Scale definer modal (mean/sum aggregation, min valid items, item picker,
  reverse-coded item picker) — untouched; feeds reliability/EFA downstream.
- Branching rule modal (target/controlling question, six condition
  operators, show/hide action) — untouched. **Relevant to A3** (AIC-RSAM
  skip logic) — review this modal while working A3.
- Attention check modal (attention/instructional/trap types, flag-vs-exclude
  fail action, correct-answer matching) — untouched.

**Analyse tab**
- Model Builder panel (lavaan CFA, lavaan CB-SEM, seminr PLS-SEM output
  engines; "Create model from scales"; path-from/path-to SEM diagram
  builder; "Export syntax") — a substantial, entirely untouched feature area.
  **Relevant to A4** (six-construct model syntax checks) — review this panel
  while working A4.
- Variable role classification (`varLevel()` in the builder script) — how
  item type maps to nominal/ordinal/likert/continuous/text/identifier;
  worth checking it classifies Slider and Date sensibly.

**Settings modal tabs**
- Welcome tab: consent checkbox + "require before starting" toggle,
  start-button label.
- Thank You tab: redirect URL, "Download my response" button toggle.
- Header tab: institution/study name field, progress-bar toggle.
- **Google Sheets tab: Sheet URL, "Generate collector (.gs)" button, Apps
  Script Web App URL — this is the builder-side surface for A7. Review it as
  part of A7, not separately.**
- Theme colour picker (swatch synced to hex text input).
- Presentation mode: Standard (all questions visible) vs Conversational (one
  question at a time) — changes the whole survey-taking UX, untested.

**Export / integrity**
- Export survey (self-contained deployable HTML via `exportSurveyHtml()`) —
  **this is the export path A2 needs for the AIC-RSAM mobile deployment.**
  Review it as part of A2, not separately.
- Open / Save `.sframe` round-trip end to end (beyond the hash mechanism
  itself, confirmed present above).

**Small polish**
- Toast notifications and the confirm-dialog overlay — no comments on
  wording/timing.
- Conversational-mode preview pagination (prev/next through one-question-
  at-a-time pages).

---

## Phase C — v0.3.4: visualisation foundation (target 2026-08-15)

Source of truth: `roadmap.md` lines ~160-172. **Start this phase only after
Phase A's exit criteria are met.** Patch scope rules apply: hard Imports stay
unchanged, ggplot2 goes in `Suggests` and every new capability is guarded
with `rlang::check_installed()`. Nothing here was dogfooded this session —
it's new implementation work from the roadmap deliverables, listed for
completeness so Fable 5 can execute both versions without switching context.

### C1. Add ggplot2 to Suggests

- **Where:** `DESCRIPTION` — current `Suggests:` block is `googlesheets4,
  shiny, psych, MASS, nnet, digest, lavaan, testthat, knitr, rmarkdown`. Add
  `ggplot2 (>= 3.4.0)` (confirm minimum version against what brand-theme work
  needs) to that list.
- **Guard pattern:** follow the existing `rlang::check_installed()` pattern
  already used for other optional packages in the codebase (check `R/` for
  precedent, e.g. how `lavaan` or `psych` are guarded) so plotting code
  degrades gracefully when ggplot2 isn't installed.

### C2. Brand theme: `theme_surveyframe()`

- Not started. A new exported `ggplot2::theme()` object matching the
  package's existing brand (colour palette, typography) used elsewhere
  (report tables, the builder's theme-colour picker default `#2563eb`,
  `man/figures/brand-preview.png` if that exists as a reference). Check
  `pkgdown`/brand source files referenced in `CLAUDE.md`'s ecosystem section
  for the canonical brand definition before inventing colours.

### C3. `plots = TRUE` argument on the main analysis runners

- Not started. Identify "the main analysis runners" precisely — likely the
  functions registered in `run_analysis_plan()`'s method registry
  (`R/analysis_plan.R`). Each needs a new `plots` argument, default `FALSE`
  (opt-in, per roadmap principle), that attaches a ggplot2 object (or list of
  them) to the result when `TRUE` and ggplot2 is installed.

### C4. First family of plots

- Not started. Two plot types per roadmap: bar charts for categorical
  runners (single/multiple choice, nominal association tests), and
  scatter/regression overlays for correlation and regression runners
  (Pearson/Spearman correlation, linear regression). Use `theme_surveyframe()`
  from C2.

### C5. `$table` slot on inferential runners

- Not started. Add a `$table` element to the return object of inferential
  runners (the same runners C3 touches) — a formatted `data.frame` suitable
  for `knitr::kable()`. Confirm the exact set of "inferential runners" by
  reading `R/analysis_plan.R` and `R/statistics_reports.R` (the two largest
  analysis files per `CLAUDE.md`'s key file map) rather than guessing from
  the roadmap's one-line description.

### Phase C exit criteria (from roadmap.md, verbatim intent)

Roadmap.md doesn't state an explicit exit-criteria line for v0.3.4 the way it
does for v0.3.3 — treat "all four deliverables (C1-C5) implemented, guarded,
tested, and documented" as the bar, and confirm with the project owner before
tagging a release if that reading is wrong.

---

## Ship checklist (run for whichever version(s) you actually complete)

Do not tag or announce either version as shipped without this. Adapted from
the `CLAUDE.md` continuation prompts and the 0.3.2 precedent in this file's
history (`revision_todo_0.3.md`, `cran-comments.md`).

1. `devtools::document()` — regenerate `man/` and `NAMESPACE` if any exported
   surface changed (Phase C almost certainly adds an export;
   `theme_surveyframe()` needs `@export`).
2. `devtools::test()` — full suite must pass. Current baseline is 368/368 at
   0.3.2 (see memory note "Test count 368" — verify this figure against
   `devtools::test()` output directly rather than trusting a stale number).
3. Bump `Version:` in `DESCRIPTION` (currently `0.3.2`) to `0.3.3` or `0.3.4`
   as appropriate, one version at a time — don't jump straight to 0.3.4 in
   `DESCRIPTION` while 0.3.3 hasn't been tagged/released.
4. Add a `NEWS.md` entry at the top, following the existing 0.3.2 entry's
   format and tone (see current top of `NEWS.md`) — describe what changed and
   why, no new hard dependencies for either version.
5. `R CMD build .` then `R CMD check --as-cran` on the resulting tarball.
   Target: 0 errors, 0 warnings, at most 1 NOTE (incoming feasibility).
6. Update `roadmap.md`: mark the version's status line as done, with the
   actual ship date, matching how prior versions in that file are marked
   (`done 2026-06-02` style).
7. Update or remove items in this file: anything actually fixed gets its
   status flipped to `fixed` (not deleted — the log stays for history) with
   a one-line note pointing at the NEWS.md entry. Anything explicitly
   decided against gets `wontfix` with the reason.
8. Follow the branch/remote convention exactly as documented in `CLAUDE.md`:
   package changes on `main`, pushed to both `origin` (private
   surveyframe-dev) and `public` (public surveyframe) per the *actual*
   `git remote -v` output — note `CLAUDE.md`'s prose names the remotes the
   other way around (`origin` = public, `private` = private); trust
   `git remote -v`, not the prose, if they disagree. Planning-file changes
   (this file, `roadmap.md`, etc.) stay on `dev`, pushed to the private
   remote only.
9. Only commit/push when the project owner asks — this rule from `CLAUDE.md`
   applies to Fable 5's session exactly as it does to any other.

## After this session

**Confirmed 2026-07-08: v0.3.5 through v0.4 are explicitly out of scope for
this session.** The project owner was asked whether to push the session all
the way to v0.4 and said no, given (a) A6's hard external blocker above and
(b) the six-patch 0.3.4-0.3.9 visualisation arc plus v0.4's small-sample
inference and RStudio add-in work is genuinely months of scoped,
21-day-cadence work in `roadmap.md` — not something to compress into one
session without a real quality cost. Once Phase C (v0.3.4) ships, stop.

Anything tagged `lane: defer` above, plus the Design improvement arc and the
"Flagged for review" inventory items that turn out to need real work, plus
v0.3.5 onward in general, should get written into `roadmap.md` as their own
scoped entry (a v0.3.4.x addendum, or a slot in the 0.3.5-0.3.9 arc) and
picked up in a future session, rather than live only in this dogfeed file
indefinitely or get started here. That's a decision for the project owner,
not something to self-assign mid-session.

---

## 2026-07-25 — 0.3.5 field-validation items carried from mas_review_034's second-round machine pass

Everything a machine could verify in `mas_review_034.qmd`'s pending list was
tested directly (source reads, live `load_all()` runs, hand computations,
`urlchecker`/`spelling`, a real pkgdown build) on 2026-07-25 — see that
file's "Second-round machine pass" note and the "Deferred to 0.3.5" section
for the full detail and verification notes. Two real bugs surfaced and were
fixed in that pass (unrelated to this list): the pkgdown GitHub Actions
workflow had been failing since 2026-07-18 (`_pkgdown.yml` missing 22
reference-index topics), and DESCRIPTION's pkgdown URL was missing a
trailing slash. Both fixed and confirmed live.

Everything below genuinely needs a human, a real device, or a live
interactive session, so it carries forward rather than blocking a sign-off.

**Re-laned 2026-08-02.** These were logged against a 0.3.5 release that was
cancelled and absorbed. The owner moved them to **0.4.1**, alongside the
ICSRI 2026 capture and the faculty demo, which are the human-judgement
rounds that collect exactly this kind of feedback. Keeping them in 0.4.0
would have put work only a person can do on the critical path of a release
whose other human gate was deliberately moved off it.

## C3 triage, 2026-08-02

Every open item was re-read against its own text rather than against the
summary label. That changed the picture, so the result is recorded here
before any of it is acted on.

**The "8 machine-fixable" grouping does not hold.** 6 of the 8 say in their
own entry that they need human eyes, and they were logged that way:

| Item | What its own entry says |
|---|---|
| B1.3 | "Prose judgement call" |
| H1.4/H1.5 | prose spot-read and presentability |
| J1.5 | APA interval prose |
| K1.7 | "Prose judgement call... methodologist read" |
| L1.4 to L1.7 | "All four need eyes on an actual rendered page" |
| N1.9 | "needs a real browser paste", headless Chrome cannot grant clipboard permission |

A 7th, D2.6, says "Scope this as its own task before 0.3.5, it is bigger
than a spot check" and carries 4 sub-tasks, one of which is a full audit of
`levels`/`labels` across every `sf_item()` type.

**Correction, same day.** The line above originally named E2.6 as the one
entry that was machine-fixable end to end. Its own text says "Visual
judgement call", so that was wrong, and wrong in exactly the way this
triage was written to catch: it trusted the summary label instead of the
entry. E2.6 belongs with the judgement items.

So of the 8, **7 are judgement calls** (B1.3, D2.5, E2.6, H1.4/H1.5, J1.5,
K1.7, L1.4 to L1.7, N1.9) and **none is machine-fixable end to end**. The
only machine-actionable work in the group is inside D2.6: auditing
`levels`/`labels` across every `sf_item()` type, and confirming ranking and
matrix items analyse end to end. D2.5 can be rendered at phone width by
machine, but the "readable?" verdict stays human.

**Consequence for the plan.** C4 as written, "clear the 8 machine-fixable
open items", is not achievable, because 6 of the 8 were never
machine-fixable. They are the same kind of judgement the ICSRI capture and
the faculty demo rounds exist to collect, and those moved to 0.4.1 on
2026-07-31. Leaving these 6 in 0.4.0 puts human-judgement work on the
critical path of a release whose other human gate was deliberately moved
off it.

Recommendation, for the owner rather than assumed: move the 6
judgement items to 0.4.1 beside F0, F0a and F3, keep E2.6 and the machine
halves of D2.6 in 0.4.0, and treat D2.5 as machine-render plus human
verdict wherever its verdict lands.

### [open] `lane: 0.4.1` — B1.3: interpretation/decision-rule pairing reads correctly to a researcher
Prose judgement call on the rendered report's "Planned decision rule" /
"Interpretation" pairing under each result. mas_review_034.qmd Part B1.

### [open] `lane: 0.4.1` — D2.5: scale-correlation heatmap readable at phone width
Visual/device check, dashboard Scales tab. mas_review_034.qmd Part D2.

### [open] `lane: 0.4.1` — D2.6: filter live-check and doc revision (audit and workflow halves done 2026-08-02)
The axis/title humanising half of the original feedback is already fixed
and confirmed (N1.5 in mas_review_034.qmd). What's left is real scoped
work, not quick verification: (1) confirm the dashboard's date/categorical
filters actually re-render the missingness chart live in a real browser
session; (2) audit that `levels`/`labels` work correctly for every `sf_item()`
type, not just the ones exercised by the demo instrument; (3) revise the
working examples, pkgdown reference, and vignettes to consistently use
labelled levels with proper spacing; (4) confirm ranking and matrix question
types produce a working end-to-end analysis without any extra hand-coding.
Scope this as its own task, it is bigger than a spot check.

**Sub-tasks (2) and (4) closed 2026-08-02.** The `levels`/`labels` audit ran
across all 11 `sf_item()` types: declared labels reach the analysis table for
every one of the 8 that carries a choice set, and text, textarea, and date
correctly show raw values because they have none. Ranking and matrix both
analyse end to end with no hand-coding.

That audit found one real defect, now fixed. A matrix row label containing a
space produces an expansion column containing a space, which the collectors
write correctly, but `read.csv()` rewrites it (`check.names` defaults to
`TRUE`), so `q1__Row one` arrives as `q1__Row.one` and `read_responses()`
rejected it as undeclared with nothing to say the header had been rewritten.
The error now names the cause and the fix, and stays quiet for a genuinely
stray column.

**Still open, and human:** (1) confirming the dashboard's date and categorical
filters re-render the missingness chart live in a real browser session, and
(3) revising the examples, pkgdown reference, and vignettes to use labelled
levels consistently.

### [open] `lane: 0.4.1` — E2.5: phone native date-wheel bounds
Device check: does a phone's native date picker actually respect
`date_min`/`date_max` on the exported survey. mas_review_034.qmd Part E2.

### [open] `lane: 0.4.1` — E2.6: bounds error message styling next to required-field message
Visual judgement call. mas_review_034.qmd Part E2.

### [open] `lane: 0.4.1` — F2.6: screen-reader spot check (VoiceOver/NVDA/Orca)
The builder's preview inputs need a real screen-reader pass to confirm
question labels are announced correctly; axe-core (already run, zero
violations) checks the accessibility tree's structure, not what a screen
reader actually says. mas_review_034.qmd Part F2.

### [open] `lane: 0.4.1` — H1.4/H1.5: vignette prose spot-read and flat browseVignettes() presentability
H1.4 is a house-style prose read (UK spellings, no em-dashes/semicolons,
banned words); H1.5 is whether the un-pkgdown-wrapped `browseVignettes()`
output looks presentable. mas_review_034.qmd Part H.

### [open] `lane: 0.4.1` — I1.1 to I1.4: full 30-minute fresh-eyes UX pass
Build a 5-question survey with a bounded date question in the builder,
export and answer it; separately spend 30 minutes in SurveyStudio running
the demo plan, writing two interpretations, and exporting the print-palette
report; read the full generated report top to bottom as a reviewer would.
A runnable setup chunk for the first half already exists in
mas_review_034.qmd's Part I (`fresh_eyes_check.sframe`). Log findings here
per I1.4's own instruction, do not fix inline until the session is
explicitly closed.

### [open] `lane: 0.4.1` — J1.5/J1.7: APA interval prose and perceived Run-tab timing
J1.5 is whether 3 read APA strings with confidence intervals read naturally
in context. J1.7's raw compute time is now measured (14.3s for the full
34-block demo plan with `plots = TRUE`, matching N1.10's "about half a
minute" total once Shiny rendering and chart encoding are added) — what's
left is whether that reads as acceptable inside the live Run tab, a UX call
the number alone doesn't answer. mas_review_034.qmd Part J.

### [open] `lane: 0.4.1` — K1.7: MCAR interpretation wording, methodologist read
Prose judgement call on `missing_data_report()`'s Little's MCAR
interpretation text. mas_review_034.qmd Part K.

### [open] `lane: 0.4.1` — L1.4 to L1.7: PDF pagination, greyscale legibility, browser print, brand colour
All four need eyes on an actual rendered page: pagination cleanliness
(no card/table split mid-block), greyscale legibility with
`plot_palette = "print"`, the browser's own Ctrl+P output, and whether the
accessible teal accent still reads as brand. PDF generation itself is
confirmed working (L1.1 to L1.3, L1.8 — 3.39 MB for the full demo,
comfortably under the 10 MB check). mas_review_034.qmd Part L.

### [open] `lane: 0.4.1` — N1.9/N1.10: SurveyStudio Copy-result clipboard and canvas timing feel
N1.9 needs a real browser paste to confirm the clipboard payload (headless
Chrome doesn't grant `navigator.clipboard` permissions without extra CDP
wiring, not attempted). N1.10 is a perceived-speed judgement, not something
a raw timing number settles alone. mas_review_034.qmd Part N.

### [open] `lane: 0.4.0` — Matrix responses collected through Shiny do not match the export contract
Found 2026-07-31 while building B6, not by any suite. `sframe_response_row()`
pipe-joins a matrix item's cells into a single column, so a matrix question
answered in the Shiny survey arrives as `mx = "4|5"` where
`read_responses()` and the whole analysis layer expect the `mx__r1`,
`mx__r2` expansion columns the static template and the Google Sheets
collector both emit. Verified directly: `read_responses()` does not accept
the row.

Consequence: a matrix-based survey run through `render_survey()` produces
data the package's own readers cannot parse, silently, with no error at
collection time. Ranking and multiple-choice items look likely to have the
same shape problem and were not checked.

B6 deliberately did not copy this precedent for the 2 decision item types,
which emit real expansion columns, so MCDM surveys are unaffected. Matrix
was left alone because fixing it changes the output shape for anyone
already collecting through Shiny, and that is a call to make rather than
slip into a decision-methods commit.

Needs a triage decision at C3: fix in 0.4.0 (breaking for existing Shiny
collectors), fix behind an option, or document the Shiny path as
static-survey-only for multi-column item types.

### [open] `lane: 0.4.0` — A freshly built instrument is not a serialisation fixed point
Found 2026-08-01 while checking B14's hash-stability gate. An instrument
constructed with `sf_instrument()` and written straight out does not hash to
the same value after a read and rewrite. `read_sframe()` drops the NULL
fields that `write_sframe()` emitted as `{}` (`choice_set`, `help`,
`date_min`, `date_max`), and `sframe_restore_analysis_block()` fills in
defaults that were never written (`citations`, `decision_rule`,
`interpretation`, `reporting_references`, `requires_data`). The payload after
one read therefore differs from the payload that was written, so the hash
differs too.

Confirmed on a plain 2-item Likert instrument with no decision items, so this
is not specific to the new types. Measured: written `ec822fff`, after read
`3fa36502`. It settles after one round trip and is stable from then on.

Consequence: the same instrument content can carry 2 different hashes
depending on whether it has been through a read, which weakens the claim that
the hash is the instrument's identity. Anyone building in R, writing, then
later reading and rewriting gets a hash change with no content change.

B14's fixture is shipped in its settled form (write, read, write) so its gate
passes honestly, and the generator says why. That is a workaround for one
file, not a fix.

Needs a triage decision at C3. Making serialise/restore a true fixed point is
the real fix, but it changes the hash of any file currently written the fresh
way, so it is an owner call rather than a quiet correction.

### [open] `lane: 0.4.0` — `variables` works for Kendall correlation and fails for Pearson and Spearman
Found 2026-08-02 while writing the 0.4.0 review suite. A plan block written
as `roles = list(variables = c("support", "wellbeing"))` behaves 3 different
ways inside 1 family:

| method | with `roles$variables` | with `roles$x` and `roles$y` |
|---|---|---|
| `correlation_kendall` | works, tau = -0.1020 | works, tau = -0.1020 |
| `correlation_pearson` | `Error: Test failed.` | works, r = -0.1387 |
| `correlation_spearman` | `Error: Test failed.` | works, r = -0.1382 |
| `partial_correlation` | `Error: undefined columns selected` | works, r = -0.1387 |

The cause is in `sframe_vars_for_method()` (`R/analysis_plan.R:860`). The 3
correlation entries read only the `x` and `y` roles, while 9 other methods
(`descriptives`, `missing_data`, `crosstab`, `chi_square`, `fisher_exact`,
`mcnemar`, `cochran_q`, `repeated_anova`, `friedman`) all list `variables` as
an accepted role. `correlation_kendall` only appears to work because it
dispatches to `sframe_run_kendall(data, roles)`, which reads `roles`
directly and never consults `sframe_vars_for_method()`.

Two separate problems, and the second is the worse one:

1. **Inconsistent role vocabulary.** `variables` is the natural name for a
   symmetric 2-variable test, it is accepted across most of the plan
   vocabulary, and it is accepted by 1 of the 3 correlations. A user who
   learns it from `descriptives` and applies it to `correlation_pearson`
   gets a failure with nothing pointing at the cause.
2. **The error names nothing.** When the roles resolve to no columns, the
   result is the string `Test failed.`, which does not say which roles were
   expected, which were supplied, or that roles were the problem at all.
   `partial_correlation` is worse again, leaking the raw R message
   `undefined columns selected`. This is the same shape as the 2 defects
   B11 and B13 found in this release: software returning something
   uninformative instead of saying what it needs.

Both halves look cheap to fix. Adding `variables` to the 3 correlation
entries is a 3-line change, and erroring through
`sframe_check_instrument()` with the expected role names when `vars` comes
back empty is contained to `sframe_run_one_block()`. Neither changes any
number the package currently reports.

Needs an owner decision: fix in 0.4.0, or document the correlation roles as
`x`/`y` only and lane the consistency work to 0.4.1.

### [open] `lane: 0.4.1` — `assumption_report()` says checks were computed when none were
Found 2026-08-02 while writing the 0.4.0 review suite. Every check in
`assumption_report()` is driven by the `variables` argument
(`R/statistics_reports.R:537`). Called with `outcome` and `group` but no
`variables`, which reads as a natural call for a 2-group comparison, it
returns empty normality and homogeneity frames, a NULL advisory, and this
APA sentence:

    Assumption checks were computed.

No check was computed. The sentence is drop-in text for a manuscript, so the
failure mode is a user reporting assumption checks they never ran. The same
class as B11 and B13: software returning something plausible instead of
saying it has no answer.

Suggested fix: when `variables` resolves to nothing, say so, either as a
typed condition or as an APA line that names what was missing. Worth pairing
with the correlation-roles entry above, since both are the plan vocabulary
failing quietly rather than a wrong number.

Not a wrong-number defect, so it does not block 0.4.0 on its own.

### [open] `lane: 0.4.0` — `item_report()` ignores `reverse = TRUE` while `reliability_report()` and `score_scales()` honour it
Found 2026-08-02 while writing review file 09. Same instrument, same data,
1 scale of 4 Likert items with `a4` declared `reverse = TRUE`:

| function | applies the declared reversal? |
|---|---|
| `score_scales()` | yes |
| `reliability_report()` | yes, alpha 0.8387 |
| `item_report()` | **no** |

`item_report()` (`R/psychometrics.R:160`) builds `scale_data` straight from
`data[, cols]` and never consults `item$reverse`. Measured item-rest
correlations:

    surveyframe item_report : 0.478  0.462  0.407  -0.669
    psych r.drop, raw       : 0.478  0.462  0.407  -0.669   <- exact match
    psych r.drop, reversed  : 0.697  0.660  0.660   0.669

Two consequences, and the second is the one that costs a user real data:

1. The reverse-keyed item reports a **strong negative** item-rest
   correlation on a scale whose own alpha reads 0.84. The obvious reading
   is "delete this item", and deleting it is wrong.
2. Every other item in the scale is **depressed too**, here 0.48 where the
   correct value is 0.70, because the unreversed item sits in the rest-sum
   and pulls against it. Items near a 0.3 retention threshold can be
   dropped on the strength of a keying error.

This is the same symptom A2 fixed in this release, a strong negative
item-rest on a reliable scale, arrived at by a different route. A2 corrected
the formula (`rowMeans()` where the standard needs the sum of the other
items). The keying was never in scope and is still wrong. Anyone who reads
the A2 fix note and sees a negative bar will conclude the fix did not ship.

The fix looks small: reverse `scale_data` before computing, using the same
declaration `score_scales()` already reads, so all 3 functions agree. It
changes numbers `item_report()` currently reports, which is the point.

Needs an owner decision. It is a wrong-number defect in a headline
psychometrics function, so the case for 0.4.0 is strong, but it does change
published output and belongs in NEWS as breaking if taken.

### [open] `lane: 0.4.0` — Display-only items get a response column from the Shiny collector, and it counts as missing data
Found 2026-08-03 while writing review file 02. `section_break` and
`text_block` collect nothing, but `sframe_response_row()`
(`R/render_survey.R:178`) builds `plain_items` as everything that is not an
expanding type, so both types land in `item_values` and the collector writes
a column for each, `NA` on every row.

`quality_report()` (`R/quality_report.R:265`) then counts those columns as
item data, because `item_cols` is the union of all item ids and all
expansion columns intersected with the data. Minimal case, 1 heading and 2
numeric items, every respondent answering both:

    Shiny collector columns : started_at submitted_at h1 q1 q2
    h1 all NA               : TRUE
    n_items counted         : 3   (2 items actually collect)
    respondent miss rates   : 0.3333 0.3333 0.3333 0.3333 0.3333

Mutation check: drop the `h1` column and the same 5 respondents read
`0 0 0 0 0`. So the whole of the reported missingness is the heading.

Three consequences.

1. **Every respondent carries a missing rate having skipped nothing.** In
   the 15-item instrument in review file 02 it is 8.3 percent, 2 columns of
   24. The number is small enough to look like ordinary item non-response,
   which is what makes it expensive.
2. **The default flag threshold is 0.2.** An instrument with enough page
   furniture crosses it on structure alone, and `quality_report()` flags
   respondents who answered everything. A user acting on that drops good
   cases.
3. **The Shiny route is the odd one out of 3.** Checked while writing review
   file 16, on 1 heading plus 2 numeric items:

       Google Sheets EXPECTED_COLUMNS : respondent_id started_at
                                        submitted_at q1 q2
       static HTML serialiser         : skips display-only items
       Shiny collector columns        : started_at submitted_at h1 q1 q2

   So 2 of the 3 collection routes already agree that a heading is not a
   column, and the Apps Script the package generates would drop `h1` on
   arrival because it is not in its expected set. Only the Shiny collector
   writes it. That is the same class of route mismatch 0.4.0 already fixed
   once for matrix, ranking, and multi-select.

`read_responses()` already knows the distinction: it carries
`display_only_types` at `R/read_responses.R:76`. `render_survey.R:56`
knows it too, returning `FALSE` from the answerable check for both types.
The collector and the quality report are the 2 places that do not.

Suggested fix, and it looks small: exclude display-only items from
`plain_items` in `sframe_response_row()` so the Shiny route matches the
static route, and exclude them from `item_cols` in `quality_report()` so
older files already carrying the columns are handled too. Both halves are
needed, since data collected before the fix keeps its extra columns.

Needs an owner decision. It changes the column set the Shiny collector
writes, so it is breaking in the same narrow sense the matrix fix was, and
it changes every missingness figure `quality_report()` has ever printed for
an instrument with a heading in it. Same shape as B11, B13, and the
assumption-report entry above: software returning something plausible
instead of saying it has nothing to report.

### [open] `lane: 0.4.0` — `sem_lavaan_syntax()` emits an indirect effect that references labels it never wrote, and lavaan refuses to parse it
Found 2026-08-03 while writing review file 10. A `cb_sem` model with a
declared `sf_indirect()` and unlabelled paths generates syntax that does not
run:

    # Structural paths
    loy ~ val + qual
    val ~ qual

    # Indirect and total effects
    indirect_qual_val_loy := qual__val*val__loy

    lavaan->lav_pt_con_def(): unknown label(s) in variable
    definition(s): "qual__val", "val__loy"

The 2 halves of `sem_lavaan_syntax()` (`R/model_layer.R:816` and
`R/model_layer.R:836`) disagree about labels. The path block writes a label
only when `path$label` is set, and otherwise writes the bare construct name.
The indirect block, given no label, invents one with
`gsub("[^A-Za-z0-9_]", "_", edge)`, which yields `qual__val`. Nothing has ever
been called that.

`sf_path(from, to, label = NULL)` makes the label optional, so the plain
2-argument call every example uses is exactly the one that breaks.

Isolated by 3 runs on the same instrument and data:

| model | generated syntax |
|---|---|
| paths unlabelled, no indirect effect | fits |
| paths unlabelled, 1 indirect effect | **lavaan parse error** |
| paths labelled `a`, `b`, `c`, 1 indirect effect | fits |

Labelling also changes the output in a second way. With labels the generator
adds the total-effect line:

    indirect_qual_val_loy := a*b
    total_qual_loy := c + indirect_qual_val_loy

Without them the total effect is omitted silently, because that branch is
guarded on the direct path carrying a label. So a user who never labels
anything loses the total effect and never learns it was available.

Two consequences, and the first is a release-quality one.

1. **The generated syntax does not run**, in the one case a structural model
   is usually declared for. Declaring an indirect effect is the reason to
   build a `cb_sem` model rather than a `cfa` one. This is not the
   plausible-but-wrong shape of the other entries in this log: it is a hard
   error, which at least surfaces immediately.
2. **The mediation vignette route is affected wherever paths are
   unlabelled.** Worth grepping the vignettes and the 2 GUIs, since the
   builder and SurveyStudio both let a user add a path without a label.

Suggested fix, and there is a clean one: give every path a generated label
when none is supplied, so the path block and the indirect block agree by
construction, rather than each deciding separately. That also makes the
total-effect line appear for everyone instead of only for users who happened
to label their paths.

Needs an owner decision on scope only, since the fix changes generated
syntax for every `cb_sem` model, labelled or not. The defect itself is not
in doubt.

### [open] `lane: 0.4.0` — `sf_conjoint_design(method = "balanced")` is rewarded for dropping a level entirely, and the balance report hides it
Found 2026-08-03 while writing review file 15. Three attributes, 3 by 3 by 2,
so 18 profiles in the full factorial, keeping 9:

    attributes: price    = low, mid, high
                response = 4 hours, 1 day, 3 days
                contract = 12 months, 24 months

    sf_conjoint_design("x", attributes = att, method = "balanced",
                       n_profiles = 9, n_alternatives = 3, seed = 20260803)

    reported imbalance : 2.89
    reported level_counts$response : 3 days 4  |  4 hours 5
    actual counts over the DECLARED levels :
        4 hours 5  |  1 day 0  |  3 days 4

`1 day` appears in no profile. No respondent ever sees it, so its effect
cannot be estimated, and a third of the response attribute is missing from
an experiment that declared it.

The cause is in `sframe_conjoint_imbalance()` (`R/conjoint_design.R:27`).
The level penalty is built from `table(col)` on the observed column, and
`table()` on a character vector only counts levels that are present. A level
with zero profiles contributes nothing to the penalty. Worse than nothing:
removing a level makes the surviving counts more even, so the search that is
meant to find balance is **actively rewarded** for throwing a level away.

`sframe_conjoint_select()` then keeps the lowest-penalty subset it found, and
that is systematically a subset with a level missing.

Measured over 60 seeds at this size:

| method | designs with at least 1 level nobody sees |
|---|---|
| `"balanced"` | **41 of 60** |
| `"random"` | 0 of 60 |

So `"balanced"` is far worse than `"random"` at the one job it exists to do,
and a user who reads the help file and picks `"balanced"` for a better design
gets a worse one. Brute force confirms subsets with every level present exist
in abundance at this size, so the search is not failing for want of a
solution.

The reporting compounds it. `$balance$level_counts` is built from the same
`table()` call, so the absent level is simply not listed rather than listed
as `0`. The help file says the achieved balance is reported "so the design
can be inspected rather than trusted", and inspecting it does not reveal the
problem. Nothing errors and an imbalance of 2.89 looks like a good score.

Suggested fix, and both halves are needed:

1. Count levels against the **declared** levels, not the observed ones, in
   `sframe_conjoint_imbalance()`. `table(factor(col, levels = declared))`
   makes a zero cell cost the most rather than nothing.
2. Reject any candidate subset that drops a level outright, rather than
   scoring it, since such a design is not merely unbalanced but partly
   inestimable. If no subset covering every level exists at the requested
   `n_profiles`, say so instead of returning one that does not.

`$balance$level_counts` should list every declared level including the zeros
either way, since that is what makes the report worth reading.

Needs an owner decision on scope only. This changes every design any
existing call produced, so anything already fielded from a `"balanced"`
design should be checked for an unseen level before the fix lands.
