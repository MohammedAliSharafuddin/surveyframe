# MAS Review — surveyframe 0.3.3 Pre-Submission Review

**Reviewer:** Mohammed Ali Sharafuddin  
**Date created:** 2026-07-10  
**Version under review:** 0.3.3 (tagged v0.3.3, pushed to both remotes, not
yet on CRAN)  
**Purpose:** Human verification of everything that changed in 0.3.3 before
win-builder and CRAN submission. 0.3.3 merges three bodies of work: the
real-world AIC-RSAM hardening, the visualisation foundation (originally
planned as 0.3.4), and the Theme B survey redesign. The 0.3.2 review
(mas_review_032.md, 184 items) already covers the stable surfaces; this
review targets the delta plus the release-safety checks. Machine
verification (519 automated tests, headless browser drives, R CMD check
0/0/0) is done; this checklist is the human pass the machine cannot do:
does it look right, read right, and feel right.

Work through this document sequentially in a fresh RStudio session with a
real browser and, for Part C, a real phone if one is available.

---

## Prerequisites

- [x] RStudio open with a clean R session (restart R first).
- [x] Chrome or Firefox available.
- [x] `devtools`, `remotes`, `ggplot2`, `psych`, `lavaan`, `seminr`,
  `googlesheets4`, `shiny`, and `quarto` are installed.
- [x] Internet access (GitHub install, Google Sheets read-back).
- [x] Optional but recommended: a physical phone on the same network for
  Part C (a desktop device-mode emulation is the fallback).

---

## Part A — Installation and metadata (6 items)

### Step A1 — Install the tagged release from GitHub

```r
remotes::install_github("MohammedAliSharafuddin/surveyframe@v0.3.3",
                        force = TRUE)
packageVersion("surveyframe")
# Expected: '0.3.3'
```

- [x] A1.1 Installation completes with no errors or warnings.
- [x] A1.2 `packageVersion()` reports 0.3.3.

### Step A2 — Release metadata reads correctly

```r
news(package = "surveyframe")
```

- [ ] A2.1 The 0.3.3 NEWS entry leads and reads as ONE release covering
  hardening, visualisation foundation, and the survey redesign. There is no
  separate 0.3.4 heading anywhere in NEWS.
- [x] A2.2 The prose contains no em-dashes, semicolons, "not X but Y"
  constructions, or banned words, and uses UK spellings.
- [x] A2.3 `citation("surveyframe")` shows version 0.3.3 (the version is read
  dynamically, so this checks the mechanism still works).
- [x] A2.4 Open the LICENSE file at the repo root on GitHub (public repo,
  main branch): it must be the two-line CRAN template (`YEAR:` /
  `COPYRIGHT HOLDER:`), with the full MIT text in LICENSE.md only. This
  regressed once from a GitHub-web edit; confirm it stayed fixed.
Feedback: 
A2.1 The NEWS is way too comprehensive than what is actually needed. A first time reader wont know what is AIC-RSAM room-service study. So, proofread the NEWS in the package. Keep only the release related information which will be needed for readers for this release. There is also a raw markdown table that is not readable when opened in Rstudio. The extended analysis plan should be moved a bit earlier. Anyway, all the progress information should be recorded in the dev repo in either a separate markedown file or in the progress.  
---

## Part B — Branching engine fixes (8 items)

Build a small two-rule instrument and exercise it by hand in the browser.
This mirrors the AIC-RSAM eligibility cascade that drove the fixes.

```r
library(surveyframe)
yn  <- sf_choices("yn", c("yes","no"), c("Yes","No"))
q1  <- sf_item("q1", "Are you 18 or older?", type="single_choice",
               choice_set="yn", required=TRUE)
q2  <- sf_item("q2", "Did you order room service?", type="single_choice",
               choice_set="yn", required=TRUE)
q3  <- sf_item("q3", "How many times?", type="single_choice",
               choice_set="yn", required=FALSE)
b1  <- sf_branch("q2", depends_on="q1", operator="==", value="yes",
                 action="show")
b2  <- sf_branch("q3", depends_on="q1", operator="==", value="yes",
                 action="show")
b3  <- sf_branch("q3", depends_on="q2", operator="==", value="yes",
                 action="show")
instr <- sf_instrument("Branch check",
                       components=list(yn,q1,q2,q3,b1,b2,b3))
export_static_survey(instr, output_path=file.path(tempdir(),"branch.html"),
                     open=TRUE, overwrite=TRUE)
```

- [x] B1 On load, only q1 is visible.
- [X] B2 Answer q1 = Yes: q2 appears; q3 stays hidden (its second rule is
  unmet). This is the multi-rule AND fix; 0.3.2 would have shown q3 here.
- [x] B3 Answer q2 = Yes: q3 appears.
- [x] B4 Change q1 to No: q2 AND q3 both disappear, even though q2 still
  holds a stale Yes. This is the cascade fix; 0.3.2 kept q3 visible.
- [x] B5 Change q1 back to Yes: q2 and q3 return with their earlier answers
  still selected.
- [x] B6 With q1 = No, submit: no required-field error blocks the hidden
  questions, and the thank-you screen appears.
- [x] B7 The downloaded CSV contains columns only for q1/q2/q3 plus the
  metadata columns. No column for hidden-at-submit answers' values beyond
  the visible ones, and no section-break columns.
- [x] B8 Nothing in the flow feels laggy or flickers when visibility
  changes.

Feedback: the branching should have text to show the reason for example: Are you 18 or older?
and when the answer is no should show a text message "Sorry. You should be above 18 to participate in this survey". The current sf_choices and sf_item exports the results as raw text. which may further need cleaning / renumbering to numerical values when moving forward with analysis in R. So, rewrite the instrument and exercise with the more complex walk through. 

Feedback and Feature Request: Enhancing sf_choices to address structural, dynamic, and non-linear limitations in choice sets
Description: As the surveyframe ecosystem matures as a design-first, immutable framework for psychometric and survey modeling, the current schema for sf_choices presents several critical architecture bottlenecks. While a rigid key-value pairing enforces strict type integrity for upstream structural models, it restricts the package from handling complex, modern survey logic natively. Below is a breakdown of four primary limitations in the current choice set design, along with actionable architectural recommendations for the package development roadmap. Support for Nested and Hierarchical Structures (Cascading Choices)Current Limitation: sf_choices only accepts flat, one-dimensional vectors. It cannot handle relational or nested data structures natively. 
The Issue: Implementing common patterns like cascading lookups (such as selecting a Country that dynamically filters a child choice set for State or Province) requires splitting logic into multiple disjointed items or handling it externally.Development Recommendation: Introduce a hierarchical mapping parameter, such as nested_choices() or an option to pass a relational data.frame into sf_choices(), allowing child items to automatically subscribe to parent item mutations.Implementation of Dynamic Text Evaluation and Value Piping
Current Limitation: Choice sets are bounded statically upon sframe instantiation.
The Issue: Values and labels cannot accept dynamic text tokens injected on the fly based on previous respondent input, such as piping a text response from q_brand_name directly into the text label of a subsequent choice set item.Development Recommendation: Allow choice set labels to accept string-interpolated expressions or tidyverse-style glue syntax that the survey engine evaluates reactively during runtime execution.Native Integration for Discrete Choice Experiments (DCE)
Current Limitation: The architecture assumes standard social science scale variants like Likert, binary, or nominal scales, and has no structural awareness of conjoint or alternative-specific designs.
The Issue: Researchers building fractional factorial matrices or trade-off attributes must rely entirely on external packages, breaking the core surveyframe philosophy of an all-in-one pre-declared analysis contract.Development Recommendation: Create a dedicated sf_conjoint_design() constructor that dynamically feeds randomized attribute profiles into specialized matrix items while maintaining proper data schema exports for downstream multinomial logit modeling.Handling Non-Linear Type Invariance and Missing Value Declarations
Current Limitation: Strict type alignment between choice sets and latent construct mappings causes analytical execution failures if non-interval values are present.The Issue: Mixing data types, such as using an arbitrary numeric flag like 99 for Prefer not to say or Don't Know inside a standard 1-to-5 integer Likert scale, corrupts automatic psychometric aggregation like Cronbach's alpha or CFA scoring unless stripped out manually.
Development Recommendation: Introduce an explicit missing_codes argument directly within sf_choices() or add_item(). This would allow developers to designate specific labels as metadata bypasses, instructing upstream statistical models to automatically handle or drop these inputs during analysis pipeline execution.
Read these recommendations carefully and decide whether to apply them in this release or note them down in future release. Check whether they are logical as per surverframe core idea and then decide carefully.
---

## Part C — Theme B survey design (18 items)

The whole survey-taking experience was redesigned. Export the bundled demo
(or the AIC-RSAM fixture if working in surveyframe-dev) and review it as a
respondent would.

```r
demo <- sframe_input_types_demo_data()
export_static_survey(demo$instrument,
                     output_path=file.path(tempdir(),"themeb.html"),
                     open=TRUE, overwrite=TRUE)
```

### Desktop pass

- [x] C1 Welcome screen: serif title, intro text, tinted consent box, and a
  full-width start button in the theme colour. The branded header (dot +
  study name) shows above.
- [x] C2 Question text is serif and clearly larger than body text; help text
  is italic; the required marker is a small theme-coloured asterisk.
- [x] C3 Single-choice options are bordered cards with A/B/C key chips; the
  selected card shows a tinted background, a theme border, a filled chip,
  and a right-side tick.
- [x] C4 Multiple-choice cards behave the same and allow several selections.
- [x] C5 Likert items are numbered squares with small labels underneath; the
  selected square fills with the theme colour and its number turns white.
- [x] C6 Short text/number/date inputs are underline style; the underline
  turns the theme colour on focus. The textarea keeps a boxed style.
- [x] C7 Star rating: large stars, theme colour when active, subtle grow on
  hover.
- [x] C8 Slider, matrix, and ranking items still render and work (they kept
  their structure; check nothing looks broken next to the new blocks).
- [x] C9 Section breaks show the short theme-coloured rule above a serif
  heading with italic intro.
- [ ] C10 The sticky top bar shows the progress line, a label, and the
  percentage; on a single-page survey the label counts answered questions
  ("N of M answered") and updates as you answer.

Feedback:
C1 - The dot is unnecessary. Anyway, the is displayed before the logo. Check and fix it.
The How many nights did you stay?* Enter the number of nights. numerical selection range is still accepting negative numbers. Anyway, check what are the sf_choices for the calendar field and the range field.
c8 - Needs improvement in design and theme. Apply the new design principles to it.
c10 - There is a em dash in the sticky top bar. Remove it.
The data export from feature_ranking should go in separate columns with numbering for further statistical analysis.
### Theme colour selector

```r
demo$instrument$render$theme <- "#7c3aed"   # any colour you like
export_static_survey(demo$instrument,
                     output_path=file.path(tempdir(),"themeb2.html"),
                     open=TRUE, overwrite=TRUE)
```

- [x] C11 Every accent re-tints from the one colour: header dot, progress
  bar, chips, selected cards, Likert fills, stars, buttons, focus states.
  No element kept the old colour.
- [x] C12 Repeat once more from the SurveyBuilder's Settings colour picker
  (launch_builder, change the theme colour, Export survey) and confirm the
  exported file matches the picked colour.

### Phone pass (real device if possible)

Serve the exported file (`python3 -m http.server` in its folder) and open it
on the phone, or use browser device mode at 390 x 844.

- [x] C13 No horizontal scrolling anywhere.
- [x] C14 Option cards and Likert squares are comfortably tappable with a
  thumb; no mis-taps on adjacent options.
- [x] C15 The on-screen keyboard does not permanently cover a focused text
  input (the browser scrolls it into view).
- [ ] C16 A logo set in the header keeps a stable box: try one wide and one
  tall logo and confirm the study name does not jump horizontally.
- [ ] C17 Conversational mode: set `render$mode <- "conversational"`,
  re-export, and confirm one question per page, a "Question X of Y"
  eyebrow, the study title in the sticky bar (no duplicated page counter),
  and working Back/Next.
- [ ] C18 Overall judgement: the survey looks like the approved Theme B
  mock, and you would be happy sending this to a respondent today.
c16 not tested so far
c17 not tested so far
c18 pending decision. Will be done in a separate mobile session. 
---

## Part D — SurveyBuilder fixes (10 items)

```r
surveyframe::launch_builder()
```

- [ ] D1 Empty canvas offers "Open an existing .sframe" and "Set up survey
  settings first" links alongside "+ Add question".
- [] D2 Open a `.sframe` saved by R or by the builder: the toast reports
  "integrity verified (sha256 ...)" with the hash prefix. Loading a file
  edited by hand in a text editor reports an integrity mismatch instead.
- [ ] D3 Select a Section item: the inspector labels its text field
  "Section header" (a Text block reads "Block text"); ordinary questions
  still read "Question text".
- [ ] D4 Add a Multiple choice question, edit its choices to something
  distinctive, then add another Multiple choice question: the new one gets
  a fresh Option 1/2/3 set, never the previous question's choices.
- [ ] D5 Edit the choices of a choice question that shares its set with
  another question: the other question's choices are untouched (the set
  forks).
- [ ] D6 Analyse tab, Add Analysis Plan, Pearson correlation: pick the same
  variable for X and Y. The modal shows "The same variable cannot fill more
  than one role" and Save stays disabled until fixed.
- [ ] D7 In the suggestion box, select one Likert item and one numeric item:
  the suggested test is Spearman correlation (never Mann-Whitney).
- [ ] D8 Select a single-choice item with more than two categories plus a
  numeric outcome: the suggestion is Kruskal-Wallis; with a two-category
  grouping it stays Mann-Whitney.
- [ ] D9 Known and accepted: the builder's own Preview tab still uses the
  old simplified rendering and lags Theme B. Confirm this is noted in
  dogfeed.todo.md and does not block submission (the Export survey output
  is the real design).
- [ ] D10 Export survey and Generate collector still download files without
  errors after all the above.
Feedback: 
D1: The empty canvas is not up to the WCAG 2.2 standards in terms of size, positioning, buttons, colour and contrast. The Open an existing .sframe · Set up survey settings first - supposed to be the primary CTA buttons are worst in terms of positioning, background colour and font colour. Improve the  empty canvas, design, colour and layout.
D2: I tried to load a older version of the surveyframe. The old design template appeared. Tried to build a fresh one. Still the old template is there. The new design principles are not available. 
The Add Question button adds Agreement item 1 by default. The three dot drop down acts separately. Split them into four buttons. One dropdown for question selection. Another for branching, another for adding section break, and another for configuration. Read / review the popular survey builder saas like limesurvey, formbricks, and so on and then rework the dashboard to fit surveyframe
The surveyframe::launch_builder() needs a complete fable 5 review and proofing as UI and UX emgineer to revise it. 
---

## Part E — Model syntax fixes (7 items)

```r
con1 <- sf_construct("SAT", "Satisfaction", paste0("sat_", 1:3))
con2 <- sf_construct("LOY", "Loyalty", paste0("loy_", 1:3))
m <- sf_model("m1", "Labelled", type="cb_sem",
              constructs=list(con1, con2),
              paths=list(sf_path("SAT","LOY",
                                 "H1: SAT positively influences LOY")))
cat(sem_lavaan_syntax(m))
```

- [x] E1 The structural line reads `LOY ~ H1*SAT`. The free-text label was
  reduced to the `H1` tag; no spaces or colons appear in the parameter.
- [ ] E2 `lavaan::lavaanify()` on the string parses without warnings about
  identifiers with spaces.

Feedback: con1 <- sf_construct("SAT", "Satisfaction", paste0("sat_", 1:3))
con2 <- sf_construct("LOY", "Loyalty", paste0("loy_", 1:3))
m <- sf_model("m1", "Labelled", type="cb_sem",
              constructs=list(con1, con2),
              paths=list(sf_path("SAT","LOY",
                                 "H1: SAT positively influences LOY")))
cat(sem_lavaan_syntax(m))
lavaan::lavaanify(m)
Error: lavaan->lav_parse_tokens_formulas():  
   formula without valid operator 
   at line 1, pos 1
m1 
^

```r
pls <- sf_model("p1", type="pls_sem",
  constructs=list(sf_construct("SAT","Satisfaction", paste0("sat_",1:3),
                               mode="composite"),
                  sf_construct("LOY","Loyalty","loy_1", mode="single_item")),
  paths=list(sf_path("SAT","LOY")))
cat(seminr_syntax(pls))
```

- [ ] E3 The generated code includes `library(seminr)` after the
  check_installed line.
- [ ] E4 The assessment tail uses `summary(pls_model)` accessors
  (`$reliability`, `$validity$htmt`, bootstrapped paths). The old
  `reliability()`/`ave()`/`htmt()` calls are gone.
- [ ] E5 Copy-paste the whole generated block into a session with simulated
  data named `data`: it runs end to end without "could not find function".
- [ ] E6 An analysis-plan block with `method = "pls_sem"` (the model-type
  spelling) runs through `run_analysis_plan()` and returns the seminr
  syntax rather than "Test 'pls_sem' is unavailable".
- [ ] E7 The Model Builder panel in the builder still exports the same
  syntax through its Export syntax button.

---

## Part F — Google Sheets collection (9 items)

The CORS fix is the single most field-critical change: 0.3.2's exported
survey silently failed to POST from any hosted page.

- [ ] F1 Open a fresh exported survey's HTML source and find the submit
  fetch: it must use `mode:'no-cors'` and `Content-Type':'text/plain'`.
  There is no `application/json` header anywhere in the submit path.
- [ ] F2 Generate a fresh collector (`export_google_sheet()` or the
  builder): EXPECTED_COLUMNS contains no `sec_*` section-break columns.
- [ ] F3 End-to-end spot check: deploy the fresh collector to a scratch
  Google Sheet, host the exported survey anywhere (GitHub Pages or
  `python3 -m http.server`), submit one response from the HOSTED page (not
  file://), and confirm the row lands in the sheet. This proves the CORS
  fix in the field.
- [ ] F4 `read_sheet_responses(sheet, instr)` returns that row with correct
  values.
- [ ] F5 `read_sheet_responses(..., meta_cols = c("extra1"))` accepts an
  extra sheet column without the undeclared-column warning.
- [ ] F6 SurveyStudio, Upload screen, Google Sheet card: the same sheet
  imports, the app switches to the Quality Dashboard, and the completion
  time card shows a median (not "No submitted_at column available").
- [ ] F7 Live AIC-RSAM read-back (read-only): `read_sheet_responses()` on
  the live sheet returns the real responses cleanly. Do NOT submit test
  data to the live endpoint.
- [ ] F8 Decision recorded: whether to re-export and republish the live
  AIC-RSAM survey mid-collection to pick up the CORS fix and Theme B, or
  leave the hand-patched deployment as is until collection ends. Either
  answer is fine; it must be a decision, not an accident.
- [ ] F9 The deploy kit now lives in
  AI_Room_service/surveyframe_Integration/deploy_kit and its README says
  so.

---

## Part G — Visualisation foundation (12 items)

```r
library(surveyframe)
demo <- sframe_demo_data()
res  <- run_analysis_plan(demo$responses, demo$instrument, plots = TRUE)
```

- [ ] G1 `theme_surveyframe()` returns a theme; a quick
  `ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_surveyframe()`
  looks branded: ink text, quiet grids, bottom legend.
- [ ] G2 A frequency block's `$plot` is a horizontal teal bar chart with no
  bar for missing values, titled "Distribution of <variable>".
- [ ] G3 A chi-square/cross-tab block's `$plot` is a dodged bar chart whose
  series colours follow the fixed order (teal, amber, blue, pink, violet)
  with white gaps between bars and a bottom legend.
- [ ] G4 A correlation block's `$plot` is a scatter with an ink regression
  line, a shaded confidence band, and the APA string as the subtitle.
- [ ] G5 A regression block with one predictor shows predictor vs outcome;
  with several predictors it shows observed against fitted with a dashed
  identity line.
- [ ] G6 Block types outside the family (for example a t-test) have
  `$plot = NULL` and no error.
- [ ] G7 With `plots = FALSE` (the default) no block carries a plot.
- [ ] G8 `$table` on a correlation block is a one-row data frame (Statistic,
  n, df, Estimate, p, Effect size); on a regression block it is the
  coefficient table; on a t-test block a two-row group summary. All print
  cleanly through `knitr::kable()`.
- [ ] G9 Render `render_report()` on the demo data: the analysis sections
  show these tables and the plots-free sections are unchanged.
- [ ] G10 Frequency and cross-tab runners on data containing empty strings
  produce no blank/unnamed category (check a `$table` from partially
  complete responses).
- [ ] G11 Eyeball the four plot types at presentation zoom (150 percent):
  fonts legible, no clipped labels.
- [ ] G12 Optional (skip if impractical): in a session or library without
  ggplot2, `run_analysis_plan(..., plots = TRUE)` fails with the friendly
  check_installed prompt, and everything else works without ggplot2.

---

## Part H — Report checks (6 items)

Render a report from any instrument with an analysis plan including a
model-syntax block and a reliability block.

- [ ] H1 A syntax-generating block (CFA/SEM/PLS-SEM) prints its full syntax
  in a monospaced code block under the RQ heading.
- [ ] H2 A reliability block renders a compact per-scale alpha table
  instead of an empty "Result:" line.
- [ ] H3 The reliability section's "Omega h" and "Omega total" headers do
  not wrap mid-word.
- [ ] H4 View the report at 1280 x 720 (projector size): headings, tables,
  and plots are readable from presentation distance.
- [ ] H5 The report references section still shows italic journal names
  (the citation markdown renders, no literal asterisks).
- [ ] H6 The TOC navigates correctly to every section.

---

## Part I — Release safety (8 items)

```r
devtools::test()          # in the surveyframe-dev checkout
```

- [ ] I1 Full suite passes; expect 519 in the dev checkout (the AIC-RSAM
  fixture tests run there) and a lower count from the CRAN tarball.
- [ ] I2 `R CMD build .` then `R CMD check --as-cran` on the fresh tarball:
  0 errors, 0 warnings, at most the incoming-feasibility NOTE.
- [ ] I3 The tarball contains no dev files: no mas_review files, no
  dogfeed/roadmap, no AIC-RSAM fixture or its tests, no jss remnants, no
  CODE_OF_CONDUCT.md or SECURITY.md
  (`tar -tzf surveyframe_0.3.3.tar.gz | less`).
- [ ] I4 The vignette builds offline (`rmarkdown::render` or the check log's
  vignette section).
- [ ] I5 `git describe --tags` on main says v0.3.3, and the tag commit
  includes the LICENSE fix (`git show v0.3.3 --stat | grep LICENSE`).
- [ ] I6 Public and private remotes agree
  (`git ls-remote` both, compare main and the tag).
- [ ] I7 Win-builder R-release and R-devel both return Status OK (submit,
  wait for the emails).
- [ ] I8 `cran-comments.md` is updated with the local check and win-builder
  results and mentions this is a feature+fix release with no new hard
  dependencies (ggplot2 added to Suggests only).

---

## Part J — Fresh-eyes UX pass (4 items)

Thirty minutes as a first-time user, no checklist in hand.

- [ ] J1 Take a survey end to end on your phone as a respondent. Note
  anything that felt off in dogfeed.todo.md rather than fixing on the spot.
- [ ] J2 Build a five-question instrument in the builder from scratch,
  export, open the export. Anything confusing goes to dogfeed.todo.md.
- [ ] J3 Read the 0.3.3 NEWS entry once more as a stranger: would a user
  understand what changed and why it matters?
- [ ] J4 Confirm dogfeed.todo.md's "After this session" and deferred items
  still reflect reality after this review.

---

## Sign-off

Counts: Parts A-J, 88 checklist items.

**Reviewed by:**  
**Date signed off:**  
**All steps complete:**  
**Notes for the developer (if any):**

Once signed off, paste the following prompt into Claude Code to proceed:

```text
Read CLAUDE.md and mas_review_033.md. The MAS review of 0.3.3 is complete
and signed off. Rebuild the tarball if anything changed, confirm
R CMD check --as-cran is 0 errors, 0 warnings, at most 1 NOTE, update
cran-comments.md with the local and win-builder results, and give me the
text to paste on the CRAN submission form.
```
