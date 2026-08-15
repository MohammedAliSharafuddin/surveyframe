# todo_rstudio_addin.md — RStudio add-in, isolated build

Dev-only planning file. Not tracked on `main`; force-add on `dev` the same
way `CLAUDE.md` and `revision_todo_0.3.md` are (see CLAUDE.md's Dev-only
files list) and add its name to `.gitignore`. This file supersedes
`todo_0.4.md` section 9 for the RStudio add-in specifically — that section
now just points here.

> **Status 2026-08-15: built, merged, and owner-verified. This file is now
> a record.** H1 built the add-in on 2026-08-02 on `feature/rstudio-addin`
> (3 launchers plus the skeleton insert, the agreed 4 and nothing more, 26
> tests), it merged to `main` on 2026-08-03, and H2 verified all 4 bindings
> inside a real RStudio session on 2026-08-15. It ships in CRAN 0.4.0.
> Two things the verification found. First, `devtools::load_all()` leaves the
> Addins-menu Package column blank and every click fails, since RStudio
> builds the call as `<package>:::<binding>()` and cannot resolve a package
> name for a dev-loaded package, so `devtools::install()` plus a full
> RStudio restart is needed. Second, the inserted skeleton built a 2-item
> scale, which reduces alpha to a single pairwise correlation and leaves a
> factor unidentifiable in any later measurement model, so it now builds 3
> items. Full detail in `todo_master_0.4.md` block H.

## Isolation is the point of this file

The paragraph below is the original 2026-07 framing, kept for the record.

**0.3.4 is mid-release** (mas_review_034 verification in progress, then
CRAN submission). This work must not touch anything the release depends
on, and must not land on `dev`/`main` until 0.3.4 is confirmed accepted.

- **Build on a separate branch**, e.g. `feature/rstudio-addin`, cut from
  `dev` now. Prefer a `git worktree` for the actual working directory so
  the 0.3.4 release tree stays completely undisturbed while both are in
  progress side by side (`git worktree add ../surveyframe-rstudio-addin
  feature/rstudio-addin`).
- **Touch only new files** plus one line in `DESCRIPTION`. Nothing in this
  scope should ever require editing a file mas_review_034 might also be
  touching. If a review fix and this work ever conflict on `DESCRIPTION`,
  that's a signal this branch drifted from "new files only" — stop and
  reconsider.
- **Do not merge to `dev` until told 0.3.4 is submitted to CRAN and
  accepted.** Even though this work is version-agnostic (no code depends
  on the 0.3.4 vs 0.4 distinction), merging early creates a diff that
  mixes an in-flight release with new unreleased surface area, which is
  exactly what CLAUDE.md's branch model exists to avoid.
- No hard-dependency risk: `rstudioapi` goes in `Suggests` only, guarded
  by `requireNamespace()`. This cannot affect the 0.3.4 `R CMD check`
  result even if both were (hypothetically) merged together, but keep the
  branches separate anyway — the goal is a clean, reviewable diff and zero
  risk of confusing the release process.

---

## Brainstorm — what could go in the add-in menu

Evaluated against the original scope (`inst/rstudio/addins.dcf` +
`R/rstudio_addins.R`, launchers only, no analytical code) from
`../portfolio-planner/development_instructions/05_v04_implementation.md`.

| Idea | Verdict | Why |
|---|---|---|
| Open SurveyBuilder | **in** | Already an exported launcher (`launch_builder()`), zero new logic needed. |
| Open SurveyStudio | **in** | Same — `launch_studio()` exists. |
| Open Dashboard | **in** | Same — `launch_dashboard()` exists. |
| Insert sframe skeleton | **in** | Genuinely useful first-contact affordance; the original guide's version is written against a stale API and needs correcting (see below). |
| Insert `sf_item()` skeleton at cursor | **considered, cut** | Tempting since building an instrument is mostly repeated `sf_item()` calls, but it's a second insert-text add-in doing almost the same job as the instrument skeleton. Adds surface area for a marginal convenience gain. Revisit only if real usage shows the full-instrument skeleton isn't enough. |
| Open a demo builder/studio/dashboard (`launch_builder_demo()` etc.) | **considered, cut** | These are one-line calls from the console already; an add-in doesn't save meaningfully more than typing the function name, and it would double the menu size for a demo/onboarding use case, not a daily-driver one. |
| Validate active `.R` file's instrument (run `sframe_check_instrument()` on whatever `sf_instrument()` object the cursor's file defines) | **considered, cut** | Would need to source or partially evaluate the active document to find the instrument object, which is a real feature (fragile, needs error handling, arguably analytical) — explicitly out of scope per "no analytical code, `inst/` and `DESCRIPTION` only." A cleaner version of this idea belongs in a future RStudio-integration release, not this thin add-in layer. |
| Render report from the active `.sframe`/results file | **considered, cut** | Same reasoning — this is a real workflow action with failure modes (missing file, wrong format), not a one-line launcher. Out of scope here. |
| Quick-open the pkgdown reference site in a browser | **considered, cut** | A bookmark, not a coding tool. Doesn't belong in an RStudio add-in menu; a README link already covers this. |

**Conclusion: keep the original four.** They're the only items that are
purely mechanical (launch a browser tab, insert static text) with zero
analytical surface, which is exactly what keeps this add-in safe to build
in isolation and merge later without review risk.

---

## Corrected skeleton — the guide's version is stale

The implementation guide's `addin_insert_skeleton()` inserts:

```r
sf_instrument(
  id    = "my_study",
  title = "My Study",
  items = list(
    sf_item("q1", "likert", "Item 1 text",
            choices = sf_choices("agree5", 1:5,
              c("Strongly disagree","Disagree","Neutral",
                "Agree","Strongly agree")))
  )
)
```

This does not match the current API. Confirmed against source
(2026-07-24):

- `sf_instrument()` (`R/sf_instrument.R:74`) takes `title`, `version`,
  `description`, `authors`, `languages`, `components`, `render`,
  `analysis_plan`, `models` — **no `id` argument, and the items argument is
  named `components`, not `items`.**
- `sf_item()` (`R/sf_item.R:50`) takes `id`, `label`, `type`, `required`,
  `choice_set`, `scale_id`, `reverse`, ... — **`type` is a single string
  argument matched against a fixed set, and choices are referenced by
  `choice_set` (an id), not passed inline as a `choices =` argument.**
- `sf_choices()` (`R/sf_choices.R:40`) takes `id`, `values`, `labels`,
  `allow_other`, `randomise` — this part of the guide's snippet was
  roughly right, just not how it's wired into `sf_item()`.

**Before writing the corrected skeleton, read all three files in full**
(`sf_instrument.R`, `sf_item.R`, `sf_choices.R`) to confirm the exact
minimal valid call — in particular whether `sf_instrument()` needs
`components` to be a flat list of items or something with more structure
(e.g. sections), and whether a `choice_set` must be declared separately
and referenced by id, or passed as part of the component list. Get this
right by reading the source and, ideally, one working example already in
the repo (`grep -rl "sf_instrument(" vignettes/` and use the simplest
vignette example as the template) rather than guessing from the function
signatures alone — a skeleton that doesn't actually construct a valid
instrument is worse than no skeleton.

---

## Files to create

### `inst/rstudio/addins.dcf`

```
Name: Open SurveyBuilder
Description: Launch the SurveyBuilder Shiny HTML app in the default browser.
Binding: addin_launch_builder
Interactive: true

Name: Open SurveyStudio
Description: Launch the SurveyStudio Shiny app in the default browser.
Binding: addin_launch_studio
Interactive: true

Name: Open Dashboard
Description: Launch the surveyframe results dashboard in the default browser.
Binding: addin_launch_dashboard
Interactive: true

Name: Insert sframe skeleton
Description: Insert a minimal sf_instrument() call at the cursor position.
Binding: addin_insert_skeleton
Interactive: false
```

This part of the guide needs no correction — copy as-is.

### `R/rstudio_addins.R`

```r
# R/rstudio_addins.R
# Path: R/rstudio_addins.R

addin_launch_builder <- function() {
  if (!requireNamespace("rstudioapi", quietly = TRUE)) {
    message("rstudioapi is required. Install with: install.packages('rstudioapi')")
    return(invisible(NULL))
  }
  launch_builder()
}

addin_launch_studio <- function() {
  if (!requireNamespace("rstudioapi", quietly = TRUE)) {
    message("rstudioapi is required. Install with: install.packages('rstudioapi')")
    return(invisible(NULL))
  }
  launch_studio()
}

addin_launch_dashboard <- function() {
  if (!requireNamespace("rstudioapi", quietly = TRUE)) {
    message("rstudioapi is required. Install with: install.packages('rstudioapi')")
    return(invisible(NULL))
  }
  launch_dashboard()
}

addin_insert_skeleton <- function() {
  if (!requireNamespace("rstudioapi", quietly = TRUE)) {
    message("rstudioapi is required. Install with: install.packages('rstudioapi')")
    return(invisible(NULL))
  }
  skeleton <- paste0(
    # fill in with the corrected, source-verified call from the section
    # above once confirmed — do not ship the guide's stale id=/items=/
    # inline-choices= form.
  )
  rstudioapi::insertText(skeleton)
}
```

Leave the `skeleton <-` body as a placeholder until the corrected call is
verified per the section above, then fill it in for real.

### `DESCRIPTION`

Add one line to `Suggests`:

```
rstudioapi (>= 0.13)
```

Nothing else in `DESCRIPTION` changes. No version bump on this branch —
the version bump belongs to whichever release (0.4, or earlier if it ships
sooner) actually carries this to CRAN.

---

## Constraints (repeat from todo_0.4.md, worth restating here since this
file now stands alone)

- No code in `R/` other than `R/rstudio_addins.R` may ever call an
  `rstudioapi::` function. The package must work identically outside
  RStudio.
- Every addin function must guard with
  `requireNamespace("rstudioapi", quietly = TRUE)` and fail soft
  (`message()` + `invisible(NULL)`), never `stop()`/`rlang::abort()` —
  these are interactive conveniences, not part of the API contract.
- No new hard dependency. `rstudioapi` is `Suggests`-only.

---

## Verification (manual — cannot be automated)

- `devtools::load_all()` inside a real RStudio session, confirm all four
  entries appear under the Addins menu.
- Click each of the three launchers, confirm the correct browser tab
  opens.
- Run "Insert sframe skeleton" with the cursor in an empty `.R` file,
  confirm the inserted code is syntactically valid and
  `sframe_check_instrument()` (or just sourcing it and calling
  `print()`/`sf_validate()`, whatever the real validation entry point is
  — check `R/conditions.R`) succeeds without error.
- Confirm the package still installs and `R CMD check` stays clean with
  `rstudioapi` **not installed** (the guard path) — run this check in a
  session/container where `rstudioapi` is absent, not just skip it.

## Exit checklist for this branch

- All four add-ins present and manually verified per above.
- `rstudioapi (>= 0.13)` in `Suggests`.
- `devtools::document()` clean (no new exports expected — addin binding
  functions are typically left unexported; confirm this is fine by
  checking how RStudio's addin mechanism resolves the `Binding:` name for
  an unexported function before assuming either way, since getting this
  wrong means the addin silently fails to launch).
- `devtools::test()` — full suite still passes (should be a no-op change
  as far as existing tests are concerned).
- `R CMD check --as-cran` clean, both with and without `rstudioapi`
  installed.
- Branch left unmerged. **Do not merge to `dev` until explicitly told
  0.3.4 has been submitted to and accepted by CRAN.** At that point, rebase
  onto current `dev`, re-verify, and merge.
