# surveyframe 0.4.3

It fixes what a teaching session on 0.4.2 found and what Ethos, the
research platform built on surveyframe, reported from its own use, and adds
references carried inside the `.sframe` file. It went out on GitHub on 19
October 2026 and reaches CRAN with the fixes since. SurveyBuilder no longer
changes content its user left alone, so an amended instrument saved from it
can be written again, and every plan result can be serialised by a host.

## What you need to change

* **11 helpers for SurveyStudio and the report template are internal.**
  `sframe_plot_item_chart()`, `sframe_plot_scale_chart()`,
  `sframe_draw_likert_diverging()`, `sframe_draw_mosaic()`,
  `sframe_likert_scale_groups()`, `sframe_codebook_items_display()`, the 3
  `sframe_builder_*()` state helpers, `sframe_result_supplement()` and
  `sframe_demo_branding()` were exported only because Studio and the
  template ran outside the package. `sframe_demo(name, branded = TRUE)`
  applies the demo branding.
* **`write_sframe(new_instrument = TRUE)` needs a new title or version** on an
  instrument read with `read_sframe()`. It accepted the title and version of
  the file read, so 2 different files could claim to be one instrument. Set
  `meta$version` (or `meta$title`) before writing. SurveyBuilder applies the
  same rule when it saves changed content of a file it opened.
  An instrument unchanged since it was read writes without the flag, and the
  error says so: Ethos, or any caller writing an unchanged file, drops
  `new_instrument = TRUE`.
* **`amend_sframe()` starts the log from the file as read.** It took the
  starting fingerprint from whatever `previous` held, so a file read, edited
  in memory and then amended got a log beginning at a state no file held,
  and the edit went undisclosed. `previous` must now match the file it was
  read from, or its last recorded amendment. Amend from the instrument as
  read, and put every change in `instrument`. `write_sframe()` also checks
  that the first new entry starts from the content read.
* **An instrument that failed its integrity check cannot be amended.** A file
  changed by hand and read with `verify = FALSE` is marked unverified, but one
  amendment wrote it back as a verified file with the hand edit and a clean
  log. `amend_sframe()` now refuses a `previous` that failed its integrity
  check, and `write_sframe()` refuses any entry appended to the log of an
  unverified read. Restore the original file, or write the content as a new
  instrument with `new_instrument = TRUE`.
* **A change to how a scale is scored is a design-tier amendment.** Dropping
  an item from a scale, reverse keying one, or changing its weights, method
  or minimum answered changes every score the plan analyses, so
  `amend_sframe()` now treats it as it treats a plan or model change: it
  needs a `deviation_report` and cannot be recorded as `"pipeline"`. A
  scale's label alone stays a pipeline change.
* **A frequency table now shows choice labels, with the code in its own
  column.** The table's columns are `Value` (the label), `Code`, `Frequency`
  and `Percent`. Code reading `Value` for the stored code should read `Code`.
  Rows follow the choice set's declared order, and a declared choice nobody
  picked appears with a count of 0.
* **A descriptives block counts choice items.** See
  below. Numbers for a `single_choice` or `multiple_choice` column move from
  the mean and SD table to a table of counts and percentages.
* **A plan rerun on 0.4.3 can give different numbers from the same data
  where categories were ordered or coded differently before.** A
  multinomial model's reference category is now the first category its
  choice set declares, not the first in alphabetical order: the logistic
  demo's reference moves from Keynotes to Workshops, and every coefficient
  and p value of that model changes with it. A binary model's modelled
  level, an ordinal outcome's order, a choice item entering a model as
  categories, and the McNemar table follow the same declared order. See
  "Answers coded and ordered as the instrument declares them" under
  Analysis. Report the 0.4.3 numbers, and say which category is the
  reference.
* **Every plan result serialises with `jsonlite::toJSON()`.** The classed
  report behind a descriptives, missing-data, quality, reliability, EFA or
  item-diagnostics result, and a fitted LDA or STM topic model, now sit in an
  attribute for the current R session, which `toJSON()` leaves out. Code
  reading `result$report_obj` or `result$fit$model` should stop doing so:
  `extract_quotes()` finds the model itself, and the charts
  `run_analysis_plan(plots = TRUE)` draws are unchanged. The KMO and parallel-analysis parts of an EFA readiness result
  are now plain lists holding the same numbers. A host serialising results
  failed on all of these, 20 blocks across the demos. Charts drawn with
  `plots = TRUE` stay on the result as `ggplot` objects.
* **An empty `render` is written as `{}`**, an empty object, by
  `write_sframe()` and SurveyBuilder. It was written as `[]`, which a host
  reading the JSON took for a list. A file written with `[]` still reads and
  verifies, and an amendment log recorded with `[]` still matches its
  content, so such a file takes further amendments as before.

## One prefix for every function, and the old names still work

* **Old names keep working, silently.** Set
  `options(surveyframe.warn_superseded = TRUE)` to get 1 warning per old name
  per session, naming its replacement, so a script or a host can find every
  old call before the old names start warning by default.

* **Every exported function takes the `sframe_` prefix or a stage verb.**
  The stage verbs keep their names (`read_sframe()`, `write_sframe()`,
  `validate_sframe()`, `amend_sframe()`, `read_responses()`, `score_scales()`,
  `run_analysis_plan()`, `render_report()`, `launch_builder()` and
  `launch_studio()`), and 3 change: `run_survey()`, `export_survey()` and
  `export_responses()`. The 7 listers 1 letter from a maker become
  `sframe_get_*()`, so `sframe_get_items()` lists what `sframe_item()` makes.
  Functions that return results and write no file end in `_results`, and the
  syntax generators start `sframe_syntax_`. `cfa_syntax()` and
  `cfa_lavaan_syntax()` become 1 function, `sframe_syntax_cfa()`. The R code
  SurveyStudio, the report template and `sframe_syntax_result()` write
  uses the new names. `?superseded` lists the old names:

  | Old name | New name |
  |---|---|
  | `sf_instrument()` | `sframe_instrument()` |
  | `sf_item()` | `sframe_item()` |
  | `sf_choices()` | `sframe_choice_set()` |
  | `sf_scale()` | `sframe_scale()` |
  | `sf_branch()` | `sframe_branch()` |
  | `sf_check()` | `sframe_attention_check()` |
  | `sf_conjoint_design()` | `sframe_conjoint_design()` |
  | `sf_construct()` | `sframe_construct()` |
  | `sf_path()` | `sframe_path()` |
  | `sf_covariance()` | `sframe_covariance()` |
  | `sf_indirect()` | `sframe_indirect_effect()` |
  | `sf_model()` | `sframe_model_spec()` |
  | `add_model()` | `sframe_add_model()` |
  | `validate_model()` | `sframe_validate_model()` |
  | `model_json()` | `sframe_model_json()` |
  | `model_report_template()` | `sframe_model_outline()` |
  | `sf_items()` | `sframe_get_items()` |
  | `sf_scales()` | `sframe_get_scales()` |
  | `sf_checks()` | `sframe_get_attention_checks()` |
  | `sf_models()` | `sframe_get_models()` |
  | `sf_branches()` | `sframe_get_branches()` |
  | `sf_choice_sets()` | `sframe_get_choice_sets()` |
  | `sf_meta()` | `sframe_meta()` |
  | `sf_plan()` | `sframe_plan()` |
  | `sf_id()` | `sframe_id()` |
  | `sf_label()` | `sframe_label()` |
  | `sf_apa()` | `sframe_apa()` |
  | `sf_flagged()` | `sframe_flagged()` |
  | `sf_problems()` | `sframe_problems()` |
  | `sf_is_valid()` | `sframe_is_valid()` |
  | `sf_object()` | `sframe_object()` |
  | `sf_missing_columns()` | `sframe_missing_columns()` |
  | `sample_size_plan()` | `sframe_sample_size_plan()` |
  | `sf_reference()` | `sframe_reference()` |
  | `add_references()` | `sframe_add_references()` |
  | `sframe_references()` | `sframe_get_references()` |
  | `link_git_commit()` | `sframe_link_git_commit()` |
  | `amendment_log()` | `sframe_get_amendments()` |
  | `render_survey()` | `run_survey()` |
  | `export_static_survey()` | `export_survey()` |
  | `survey_module_ui()` | `sframe_survey_ui()` |
  | `survey_module_server()` | `sframe_survey_server()` |
  | `sframe_export_labelled()` | `export_responses()` |
  | `quality_report()` | `sframe_quality_results()` |
  | `missing_data_report()` | `sframe_missing_data_results()` |
  | `outlier_report()` | `sframe_outlier_results()` |
  | `reliability_report()` | `sframe_reliability_results()` |
  | `item_report()` | `sframe_item_results()` |
  | `efa_report()` | `sframe_efa_readiness_results()` |
  | `efa_solution()` | `sframe_efa_solution()` |
  | `validity_report()` | `sframe_validity_results()` |
  | `descriptives_report()` | `sframe_descriptives_results()` |
  | `assumption_report()` | `sframe_assumption_results()` |
  | `posthoc_report()` | `sframe_posthoc_results()` |
  | `bootstrap_ci()` | `sframe_bootstrap_ci()` |
  | `cohens_d_ci()` | `sframe_cohens_d_ci()` |
  | `cramers_v_ci()` | `sframe_cramers_v_ci()` |
  | `eta_sq_ci()` | `sframe_eta_sq_ci()` |
  | `cfa_lavaan_syntax()` | `sframe_syntax_cfa()` |
  | `cfa_syntax()` | `sframe_syntax_cfa()` |
  | `sem_lavaan_syntax()` | `sframe_syntax_sem()` |
  | `seminr_syntax()` | `sframe_syntax_pls()` |
  | `efa_syntax()` | `sframe_syntax_efa()` |
  | `analysis_syntax()` | `sframe_syntax_result()` |
  | `clean_text_responses()` | `sframe_clean_text()` |
  | `term_frequency()` | `sframe_term_frequency()` |
  | `ngram_frequency()` | `sframe_ngram_frequency()` |
  | `term_context()` | `sframe_term_context()` |
  | `extract_quotes()` | `sframe_extract_quotes()` |
  | `sensitivity_analysis()` | `sframe_sensitivity_analysis()` |
  | `render_result()` | `sframe_format_result()` |
  | `codebook_report()` | `sframe_codebook()` |
  | `sframe_demos()` | `sframe_list_demos()` |
  | `sf_plan(x) <- value` | `sframe_plan(x) <- value` |

* **The 2 larger demo datasets load through `sframe_demo()`.**
  `sframe_demo("tourism_services")` replaces `sframe_demo_data()`, and
  `sframe_demo("input_types")` replaces `sframe_input_types_demo_data()`,
  with the same fields and the same reading of `submitted_at`.
  `sframe_list_demos()` lists them last, with focus `"reference"`, apart
  from the 22 teaching demos. The old names still work.

* **`launch_builder(demo =)` opens SurveyBuilder with any demo preloaded.**
  It replaces `launch_builder_demo()`, which loaded only the input-types
  demo. `launch_builder()` now always returns the path of the page it opens,
  and the old name still returns its list.

* **`launch_studio(demo =)` opens SurveyStudio with any demo loaded.** It
  replaces `launch_studio_demo()`, which loaded only the input-types demo.
  `demo` cannot be combined with `instrument` or `responses`.

* **`preview_survey()` is the Preview stage verb.** `preview_survey(x)`
  shows a survey as a respondent meets it, with the collector removed, in
  the browser or on SurveyStudio's preview screen. `x` is an instrument or a
  demo name, so it previews your own survey as well as a demo. It replaces
  `preview_demo()`, which still works and still defaults to `"two_group"`.

* **Help is organised by stage.** The reference index runs Design, Plan,
  Preview, Collect, Responses, Analyse, Report, References and Amendments,
  each saying where the stage lives in SurveyStudio or SurveyBuilder and
  which function does it in code, then the toolboxes. `?surveyframe` opens
  with "Start here" and the same stages, and every help page ends with links
  to the rest of its section.

* **Proportion columns end in `_prop`.** `sframe_item_results()` reports
  `floor_prop` and `ceiling_prop`, and `sframe_missing_data_results()`
  reports `missing_prop`, since each holds a proportion between 0 and 1.
  The `_pct` columns stay as copies for 1 release, and tables show the
  `_prop` column alone. The demo results files use the new names.

## References, cited where they are used and listed once at the end

* **5 reference styles by name.** `render_report(csl = )` takes `"apa"`
  (the default), `"chicago-author-date"`, `"harvard"`, `"ieee"` or `"mla"`,
  bundled with the package under CC BY-SA 3.0 (see `inst/COPYRIGHTS`), or
  the path to a `.csl` file. No style is fetched from the network. The
  results record and the manifest give the style's name and sha256, and a
  `.qmd` report folder holds the style as `<name>.csl`, so a rerun formats
  with that copy. An unknown name stops with the list of the 5. The
  built-in page stays APA 7 only and says so.
* **A report cites each source where it is used, in both engines.** Under
  the title for the instrument, in the codebook for an item or a scale,
  under the reliability table for a scale, in a plan block's section, beside
  the hypotheses they support, and in the model appendix, as well as once in
  the References list. The built-in page cited only what its text named.
* **Hypotheses and the study can cite sources.** `cited_by` takes
  `"hypothesis:<block id>"`, the hypotheses a plan block declares, and
  `"study"`, the study's problem, objectives and sampling.
  `validate_sframe()` reports a hypothesis target whose block is missing or
  declares no hypotheses, and a `study` target on an instrument with no
  study. The sframe-schema pattern for `cited_by` needs the same 2 targets.
An instrument can now carry the works it draws on, and every report lists
them once, in a References section at the end, in a standard bibliography
style.

* **The built-in report engine cites and lists references.** Without
  Quarto, `render_report()` printed `[@key]` raw and left out the
  instrument's references and any passed in `references`. It now writes
  each citation as (Author, Year) and ends with an APA 7 References list of
  articles, books, chapters, reports, web pages and software. An entry of
  another type shows a visible note, and a `csl` other than APA 7 gets a
  message that this engine formats APA 7 only (D8, CX-10).
* **`sf_reference()`** creates a reference as a CSL-JSON record, the format
  Zotero, Mendeley and pandoc share. **`read_bibtex()`** reads BibTeX, as
  exported by Google Scholar, Zotero, Mendeley and most journal pages, using
  base R alone. **`add_references()`** attaches references to an
  instrument, and `sf_instrument(components = )` takes them too.
  **`sframe_references()`** lists them, and **`sframe_bibliography()`**
  writes the CSL-JSON a citation processor reads.
* **Each reference says where it is cited**: the instrument as a whole, an
  item, a scale, a plan block or a model, in its `cited_by` field.
  `validate_sframe()` gains a `references` check that every target exists
  and every key is unique. A work in another language can carry `language`, which keeps a style
  from title-casing its journal name.
* **`render_report()` cites in text and lists each work once, at the end.**
  Each result used to carry its own reference list, so the same works
  repeated through the report. Results now cite their methods in text, for
  example "(Cohen, 1988)", and the codebook names the source of
  each item and scale. A written interpretation can cite a work as `[@key]`.
  The list at the end is formatted by pandoc's citation processor in APA 7,
  bundled with the package, or in any style given as `csl = `. The new
  `references =` argument adds works a host cites in the write-up.
  `render_results()` lists its references once at the end in the same way.
* **The 30 built-in method references are also held as CSL-JSON.** A test
  formats each one through pandoc in APA 7 and compares it with the APA text
  the package already shipped, which holds the 2 forms together.
* The building-survey-instrument vignette has a section on citing
  sources: `sf_reference()`, `read_bibtex()`, where a work is cited, and
  what `render_report()` does with the list.
* **SurveyBuilder has a References tab in Survey settings.** Paste BibTeX or
  type a reference in, and choose where the instrument cites it. Changes
  apply at once, ahead of Save settings.
* **SurveyBuilder cites a reference from the study and from a plan block's
  hypotheses**, as the `cited_by` targets `study` and `hypothesis:<block id>`.
  Each is offered only while it is there: the study once it is declared, and
  a block's hypotheses while it states 1. A target cited and no longer there
  still shows, ticked, so it can be taken off.
* **SurveyBuilder has a citation picker on the plan fields.** Type `@` or
  `/cite` in a research question, a hypothesis, a decision rule or an
  interpretation, or press Cite on its format toolbar, to list the instrument's
  references by key, author, year and title, filtered as you type. A pick
  asks for "Max (2000)", written `@key`, or "(Max, 2000)", written `[@key]`,
  and inside an open `[...]` adds `; @key`. A key with no reference is
  shown under the field with "No reference with this key. Add it under
  References.", and "Manage references" opens that tab. The picker is 1 file,
  `field_tools.js`, which SurveyStudio will share.
* **SurveyBuilder's long text fields have a format toolbar.** It appears
  while a research question, hypothesis, decision rule or interpretation
  has focus, with bold, italic, bulleted and numbered lists, link, cite,
  subscript, superscript and equation. Each writes Markdown around the
  selection (`**x**`, `*x*`, `- `, `1. `, `[x](url)`, `[@key]`, `~x~`,
  `^x^`, `$x$`, or `$$` on lines of their own for a display equation), and
  the `.sframe` file stores the text as typed. A preview line under the field
  shows it formatted, with an equation as its TeX. Ctrl+B and Ctrl+I work in
  the field, arrow keys move along the toolbar, and Escape returns to the
  field. The toolbar is part of `field_tools.js`.
* **`read_bibtex()` reads entries written with parentheses.** BibTeX allows
  `@article(key, ...)` as well as `@article{key, ...}`, and a file may mix the
  2. A closing bracket inside a braced or quoted value ended a parenthesised
  entry early.
* **`read_bibtex()` refuses a key used by more than 1 entry.** The later
  entry replaced the earlier without a word. It is now an error naming every
  repeated key, as `add_references()` does for an id the instrument holds.

### The file format

* **`read_sframe(text = )` reads a payload held in memory**, such as JSON a
  host keeps in a database, with no temporary file. **`verify = FALSE`**
  reads content whose hash is missing or does not match, with a warning of
  class `sframe_unverified_warning`, and marks the instrument with the
  attribute `sframe_verified = FALSE`, which `print()` shows. A host can then
  keep every field where it used to rebuild the instrument by hand. Such an
  instrument is written only as a new instrument, or when its amendment log
  names exactly its content.
* **The bundled schema is the published one.**
  `inst/schema/sframe_schema.json` is now a copy of sframe-schema's
  instrument profile, kept identical by a test. The 2 had drifted: the
  bundled copy left `sframe_format` optional and lacked `references`, so a
  file could pass one and fail the other. It now requires `sframe_format`,
  as `write_sframe()` writes it. `read_sframe()` still reads older files
  without the field. Every bundled `.sframe` file and a builder save
  validate against it.
* `references` is a new optional top-level field. It is written only when an
  instrument has at least one, so an instrument with no references keeps the
  file hash it had, the rule `designs` and `amendments` already follow.
* **Citing a source is disclosure, outside the amendment record.** The
  content hash that `amend_sframe()` records leaves `references` out, so a
  reference can be added to a published instrument directly.
* `inst/schema/sframe_schema.json` documents the field. Its description of
  the amendment content hash was also wrong: it named only the items,
  choices, scales, branching, checks, plan, models and designs, while the
  hash has always covered every field except `hash` and `amendments`,
  `meta`, `render` and `version` included. Corrected.
* `inst/csl/apa.csl`, the APA 7 style from the Zotero Style Repository, is
  bundled under CC BY-SA 3.0. See `inst/COPYRIGHTS`.
* **A block's `error` opens with the block id and the method**, as in
  "RQ3 (McNemar test): ". Code that matched the start of an error message
  needs to allow for it.

## The study an instrument serves

* **Text fields may hold Markdown and equations.** A research question,
  H0, H1, decision rule, interpretation, study problem or deviation report
  may use bold, italic, lists, links, `[@key]` citations, `~sub~`, `^sup^`,
  footnotes and equations (`$...$`, `$$...$$`, by Pandoc's rule, so
  "$5 and $10" stays prose). The `.sframe` keeps the text as typed. The
  Quarto report renders equations as MathML in HTML, so an offline report
  shows them, and as native equations in Word, OpenDocument and PDF. The
  built-in page renders the Markdown with commonmark, now in Imports, and
  prints each equation's TeX in monospace. Plain prose holding @, #, $ or *
  prints exactly as typed. Shortcodes, raw blocks, `:::` fences, heading
  lines, a `---` line and HTML tags print as typed in both engines, R code
  in a field never runs, and `@word` is a citation only for a known key, so
  an email address or a handle never becomes a missing citation. A
  deviation report is formatted below the amendments table.
* **A tested result with no hypothesis declared is labelled exploratory.**
  A block whose result gives a p value and that declared no H0 and no H1
  prints "Exploratory: no hypothesis declared before the data" before its
  result, in both engines, and its entry in the results record carries
  `exploratory: true`. The 2 placeholder sentences earlier interfaces saved
  count as not declared. Descriptive blocks print nothing extra, and a
  block with no hypothesis stays valid.
* **Every report prints the study in its plan section.** The problem
  statement, its sources, and a table tracing each objective to the
  research questions that serve it, with "none yet" for an objective no
  question serves and a note naming any question that serves none, in both
  engines.
* **A `study` field holds the problem, the objectives and the sampling plan**
  (D13). `sframe_instrument(study = list(problem = , objectives = ,
  sampling = ))`: the problem in 1 short paragraph, objectives each with an
  id such as `O1` and its text, and the sampling plan's population, method
  (from `sframe_sampling_methods()`, which groups the probability and
  non-probability methods, with `method_other` describing an "other" one)
  and planned n. A plan block names the
  objective it serves in `objective`. Read it with `sframe_get_study()`. It is
  written only when declared, so an instrument without one hashes as before.
  It is inside the content hash, never on the respondent's page, and a change
  to it after collection is a design amendment. SurveyBuilder and SurveyStudio
  carry it through a save.
* **`validate_sframe()` checks the study and notes the trace.** It refuses a
  malformed study, an objective id used twice and a plan block naming an
  objective the study does not declare. It notes, without failing, an
  objective no research question serves, a research question that names no
  objective, and a problem over 150 words. `sframe_notes()` reads the notes,
  and the diagnostic prints them.
* **`validate_sframe()` refuses what the sframe-schema instrument profile
  refuses in these fields**, so nothing surveyframe writes fails it. A plan
  block's `objective` is checked with or without a study: it is `""` or 1
  objective id such as `O1`, and an id with no study to declare it fails. A
  hypothesis that is `NA`, written as JSON null, is refused. A study,
  objectives or sampling that is present and empty is refused, with a message
  to drop it. A block with no hypotheses stays valid.
* **The bundled schema documents the study.** `inst/schema/sframe_schema.json`
  is re-synced from sframe-schema v0.3-draft, whose instrument profile gains
  `study` (problem, objectives, sampling with `method_other`), the plan block
  `objective` and the `hypotheses` shape: a text `null`, a text `alternative`
  or both, or `null`. A reference's `cited_by` may also name
  `hypothesis:<block id>` and `study`. No field became required.
* **SurveyBuilder edits the study in a Study tab of Survey settings**: the
  problem statement, the objectives with their ids, the population, the
  sampling method from the fixed list (with a description for Other) and
  the planned sample size. The study is saved only when one of its fields
  changes, in the shape `write_sframe()` writes, so a study left alone keeps
  its content hash. The builder refuses what `validate_sframe()` refuses,
  including the removal of an objective a plan block names.
* **The exported survey honours a choice set's `randomise`.** It was set in R
  and the builder, and the page never read it. A single choice, multiple
  choice or ranking item now shows its options in an order shuffled once per
  respondent and kept in a draft, and each option still submits its own
  value (UX-11).
* **SurveyBuilder works on a narrow screen.** Below 760 px Design shows 1
  pane at a time, the question list, then the editor with its live preview
  and a Back control, in the standalone builder and inside SurveyStudio.
  Preview and Plan take the whole width, and at 390 x 844 no page is wider
  than the viewport (UX-01, UX-08).
* **SurveyBuilder's Survey settings sections are a tablist**: buttons with
  `aria-selected` and `aria-controls`, 1 of them in the Tab order, and the
  arrow keys, Home and End move between them. They were divs that answered a
  click alone (UX-15).
* **SurveyBuilder's 7 dialogs are labelled modal dialogs** with
  `aria-modal` and `aria-labelledby`, and their close buttons have a name.
  Tab stays inside the open dialog, and Escape closes the top one through
  the same route as its close button, so focus returns to what opened it.
  Escape used to drop every open dialog at once and leave focus behind
  (UX-14).
* **The exported survey honours a choice set's `allow_other`.** A single or
  multiple choice item adds "Other, please specify" last, with a text box,
  and typing in the box chooses it. A single choice submits the code
  `other` in its column, a multiple choice submits `<id>__other` as 1 or 0,
  and both submit the text in `<id>__other_text`. Other chosen with nothing
  typed blocks the page. SurveyBuilder turns the option off for an ordered
  set (UX-11).
* **The "Other, please specify" columns are known to R.** A choice set with
  `allow_other` gives a single choice item `<id>__other_text` and a multiple
  choice item `<id>__other` and `<id>__other_text`, so validation, the
  Google Sheets header, the Shiny row and the quality report all list them.
  The Shiny survey fills them as the static survey does, and the text of an
  Other does not count as a missing answer.
* **The Shiny survey draws "Other, please specify"** for a choice set with
  `allow_other`, as the exported survey does: the option last, a text box
  under it, and typing in the box chooses it. `run_survey()` and
  `sframe_survey_server()` submit the same columns as the exported survey,
  and Other chosen with nothing typed stops the page or the submission.
* **`read_responses()` reads an Other answer.** A single choice item whose set
  allows Other accepts the code `other`, and its column stays text whatever
  the set's codes look like, since a numeric set with Other would otherwise
  turn on whether anyone chose Other. Every `<id>__other_text` column is read
  as text, and `<id>__other` as a number like the other option columns.
* **`allow_other` is refused where it cannot work.** `sframe_choice_set()` and
  `validate_sframe()` refuse it on a set holding the value `other` or
  `other_text`, which would share a code or a column with Other, and on an
  ordered set, where Other has no place on the scale.
* **The codebook, the frequency tables and the report charts name Other.**
  The choices table of `sframe_codebook()` and `as.data.frame()` lists
  `other` with the label "Other" for a set with `allow_other`, and a frequency
  table or chart shows "Other" for the code. The text typed for Other goes to
  the text-analysis path: `sframe_clean_text()` and the text plans take
  `<id>__other_text` as a text item, and the dashboard offers no filter on it.
* **SurveyBuilder's welcome and thank-you pages are entries in the question
  list**, "Welcome page" first and "Thank-you page" last. Selecting one opens
  its editor on the right and its preview in the centre, and the Survey
  settings dialog loses its Welcome and Thank You tabs (UX-10). A page left
  alone keeps the content hash. Inside SurveyStudio, the dialog's Google
  Sheets and References tabs link to Studio's Collect and References
  screens, and the standalone builder keeps both tabs.
* **SurveyBuilder shows the selected question in its centre pane** as a
  respondent sees it, drawn by the survey template itself through a
  preview-only "show only this item" mode, so there is 1 renderer. It is
  redrawn a moment after each edit, has a desktop and a mobile width, and is
  read-only: the editor stays on the right (UX-09). Section breaks and text
  blocks show as on their page.
* **SurveyBuilder's Plan tabs are "Declared analyses" and "Expected
  outputs"**, where they were "Run preview" and "Report outline", so Preview
  in the builder means the respondent's survey alone (UX-17).
* **SurveyBuilder sets a cross-tab's percentages.** A cross-tab or
  chi-square plan has a "Percentages in the table" choice: counts only, row,
  column or percent of the total, saved as `options$percent` (UX-02).
* **SurveyBuilder drops an empty study on save.** A file holding
  `"study": {}` was saved with `{}` again, which `validate_sframe()` and the
  sframe-schema profile refuse. Empty objectives and an empty sampling plan
  are left out the same way, as `write_sframe()` does.
* **SurveyBuilder keeps the objective a plan block serves.** Saving the plan
  dialog built the block afresh, so any edit there dropped an `objective` set
  in R. The dialog now has an "Objective served" choice listing the study's
  objectives, and keeps the block's own objective even when the study no
  longer declares it.

## Amendments and versions

* `?amend_sframe` says the amendment is sealed when the file is written:
  `write_sframe()` hashes the object as it stands then, so a change made to
  it before writing is part of the author's new version (Codex U-1).

* **`amend_sframe(version = )` sets the version an amendment writes.** `NULL`,
  the default, keeps the version, and when it is unchanged a message
  suggests the next: the minor number for a design amendment (1.0.0 to
  1.1.0), the patch number for a pipeline amendment (1.0.0 to 1.0.1), with
  the reason. The version set is inside the recorded content.
* **`sframe_drop_items(instrument, items, from)` drops items from scales or
  models.** It takes them out of the named scales (with their reverse keys
  and weights) or every construct of a named model, and out of any plan
  block role that lists them with other variables. A role naming only that
  item keeps it. The questions and their answers stay, and nothing is
  recorded: `amend_sframe()` records the drop as a design amendment.
* **`sframe_item_flags(result)` lists the items past the usual cut-offs.**
  For a reliability, item, EFA readiness, EFA or validity result, a plan
  result for one of them, a lavaan CFA or a seminr PLS model, it gives each
  statistic, its cut-off and source in APA 7 form, and a ready reason such as
  "org_4: loading .21 in RQ3, below .40". EFA low loading and cross-loading
  are 2 reasons, alpha if deleted asks for the item-total correlation and
  wording to be checked, HTMT takes .85 or .90 and keeps the value applied,
  and PLS keeps .708. Checked against psych, lavaan and seminr. A reliability
  result now carries `alpha_if_deleted` for each item.
* **The report gives the instrument version and its amendment list.** Under
  Reproducibility, both engines print the version beside the hash, then
  every recorded amendment, oldest first: date, tier, reason, what changed,
  deviation report, author and sign-off. An instrument with no log says "No
  amendments are recorded."

## Analysis

* **Cross-tab percentages and totals.** A `crosstab` or `chi_square`
  result carries `$totals`, the counts with a Total row and column. With
  `options$percent = "row"`, `"column"` or `"total"` it also carries
  `$percent_table`, the percentages over that denominator, the report shows
  each count with its percentage beside it, and `sframe_plot_crosstab()`
  draws the percentages. Checked against `prop.table()` and `addmargins()`
  on 3 demo pairs, a zero cell among them.
* **Multinomial logistic regression has a full table.** It gives b, SE, z,
  p, the odds ratio and its 95% interval for each outcome category against
  a named reference category, and the result text names the reference.
  `render_result()` also returns a result's `syntax` where it has one. The
  logistic demo results are regenerated (CX-14).
* **Model outlines give the notes for their own model type.**
  `model_report_template()` gave every model the same notes, asking an EFA
  for structural paths and a PLS-SEM model for fit indices. EFA, CFA, CB-SEM
  and PLS-SEM now each get their own list. PLS-SEM follows Hair, Hult,
  Ringle, Sarstedt, Danks and Ray (2021), doi:10.1007/978-3-030-80519-7, and
  checks each construct by its mode (reflective, formative or single item)
  with the thresholds the book gives, then the structural model. The seminr
  script's assessment section follows the same checks.

* **The seminr script tests every declared indirect effect.**
  `seminr_syntax()` writes one `specific_effect_significance()` call per
  `sf_indirect()`, as the lavaan syntax already defined each one.

* **EFA reads factor item columns by their labels.** `efa_report()` and
  `efa_solution()` read item columns with the same rule as every other
  numeric method, so a factor holding 10 to 50 counts as those values, where
  its level positions had been used (CX-06).

* **Regression syntax codes predictors as the analysis does.** The code
  `analysis_syntax()` writes for linear, binary, ordinal and multinomial
  logistic regression and ANCOVA codes each predictor the way the package
  does: a number when every value reads as a number, a category otherwise.
  "1" to "5" stored as text had entered the code as a factor, so it fitted a
  different model. The ordinal, multinomial and ANCOVA runners now code
  predictors and covariates by the same rule, so a text covariate that is
  not a number enters as a category, where it had become missing.
  `analysis_syntax()` now covers ordinal and multinomial logistic
  regression.

* **Choice descriptives honour `split_by` and weights.** A descriptives
  block counted choice items raw and pooled whatever its grouping and
  weights. Counts and percentages now come per group, in the order the
  choice set declares, and weighted when a weight column is named (D5,
  CX-07).

* **One check for every weight column.** Frequency, cross-tabulation and
  descriptives blocks stop with an error naming the weight column when a
  weight is negative, infinite or not a number, or when the weights sum to
  zero. A row with a missing weight is dropped, and the result says how many
  were (D6, CX-09).

* **Kendall's tau reports N, with no degrees of freedom.** `cor.test()`
  gives Kendall no df, yet the line read `tau(58)` and the table carried a
  df column. It now reads `tau = 0.39, 95% CI [...], p < .001, N = 60`.
  Pearson and Spearman keep `r(df)` and `r_s(df)` (D9, CX-17).

* **The paired t test names the higher measure.** Its APA line and prompt
  end with ", higher in <measure>", as the Wilcoxon signed-rank line already
  did (D1 follow-up).

* **Named weights in `sensitivity_analysis()` match criteria by name.**
  Named weights are matched to the criteria in any order, as the ranking
  blocks already do, and a name that is not a criterion or a criterion with
  no weight is an error. Unnamed weights keep the order of the criteria.

* **Logistic syntax codes the outcome as the analysis does.** The code
  `analysis_syntax()` writes for a binary logistic regression recodes the
  outcome to 0 and 1 the way the runner does before `glm()`, so a text
  outcome runs and the coefficients match the result.

* **ANCOVA syntax writes every covariate.** `analysis_syntax()` for an
  ANCOVA wrote only the first declared covariate, so its F differed from
  the result. It now writes each one (CX-02).

* **Two-group effect sizes keep their direction.** Cohen's d for the
  independent t test, and r for Mann-Whitney and the Wilcoxon signed-rank
  test, were magnitudes, and their bootstrap intervals were intervals of a
  magnitude, so they could never include zero. Each is now signed, first
  group minus second in the declared order, as the paired d_z already was.
  Size labels read the magnitude, and the APA line and prompt name the higher
  group. `cohens_d_ci()` returns the signed interval. The `two_group`,
  `paired` and `small_sample` demo results are regenerated: their r values
  can print with a minus sign, and the `small_sample` r interval now starts at
  0.12.
* **A two-group test takes its groups in the declared order.** The
  independent t test and Mann-Whitney ordered the 2 groups by first
  appearance in the data, so re-sorting the responses flipped the sign of t
  and z. The order is now the grouping item's choice set as the instrument
  lists it, then factor levels, then sorted values. The code
  `analysis_syntax()` writes names the same order.
* **A statistic is never replaced by a choice label.** A result table read
  every text cell through the instrument's labels, so a statistic equal to a
  choice code took that code's label: the `factor_structure` demo's "Suggested
  factors" read "Disagree" in place of 2. Choice codes are now relabelled only
  in a column of response values, and never in a Statistic and Value table.
  Item and scale ids still read as their labels everywhere.
* **A descriptives plan table has reader headings**: Variable, N, Valid N,
  Missing, Mean, SD, the confidence interval's bounds and the rest, as the
  other plan tables have. It showed `valid_n`, `missing_n` and `sd`. The
  group column is left out when there is no split, and the weighted mean
  when there are no weights. `descriptives_report()` keeps its own column
  names, and the demo reference results keep theirs.
* Report sentences agree in number: "computed for 1 variable" in place of
  "1 variable(s)".
* A `frequency` block gives one frequency table per variable. It reads the
  `variable` role, or `variables`, and either may name more than one item. With
  more than one, `$tables` holds each variable's own result and `$table`
  stacks them with a `Variable` column, and the chart shows one panel per
  variable. The `variables` role was ignored before, so a block written that
  way reported "Frequency distribution for NA (N = 0)". SurveyBuilder and
  SurveyStudio both let the role take more than one variable.
* A frequency table labels each code from the item's own choice set. A code
  that means different things in 2 choice sets (1 for Male in one, 1 for
  North in another) used to print as the bare code.
* **Text codes such as "01" keep their leading zero when responses are read.**
  `read_responses()` converted every choice column whose codes looked like
  numbers, so "01" and "02" became 1 and 2, and a frequency table showed the
  declared options First and Second with a count of 0 beside unlabelled rows
  1 and 2. Only codes that survive a numeric round trip, such as 1 and 2, are
  now read as numbers. The rest stay as written.
* **Result text names variables and groups by their labels.** The tables
  and charts used the instrument's labels, while the text beside them said
  `attendee_type`, "higher in in_person" and "reference category keynote".
  A variable now appears as its label in double quotes, since a label is
  often a question, with any double quotes inside it turned to single ones.
  A group or category appears as its choice label. An interaction term in a
  table, such as `attendee_role:format`, reads as its 2 labels joined by
  a times sign. A runner called outside `run_analysis_plan()` keeps the
  ids (CX-20).
* **A block that cannot run says which block, what is wrong and what to do.**
  McNemar, Friedman, ANCOVA, Fisher's exact test, partial correlation, the
  ordinal, multinomial and Firth logistic models and moderation said only
  "X failed.", and EFA readiness passed on "'x' is empty". Each now names
  the data problem, suggests a remedy and keeps R's own message. An infinite
  value in a variable is named as the cause, where R's message did not say
  it (CX-13).
* **`read_responses()` reads semicolon and tab files.** It detects a comma,
  semicolon or tab separator from the header line, and a new `delim`
  argument overrides the detection. A semicolon file is read as Excel writes
  it in a comma decimal locale, so `3,5` in a numeric column reads as 3.5,
  and a message says so. A byte order mark no longer joins the first column
  name.
* A `descriptives` block counts `single_choice` items and the option columns
  of a `multiple_choice` item, giving each category's count and percentage,
  and keeps the mean and SD for numeric items. A nominal code has no
  meaningful mean, and a mean gender of 1.59 was being reported. The result
  carries the counts in `$categorical`, the APA line names the items counted,
  and `sframe_result_supplement()` returns the counts so both report engines
  show them beside the numeric table. `render_results()` now shows that
  second table for every result that has one.
* The printed quality report has a Duplicates section, so a reader can see
  why a respondent counted as flagged. It also says when the check needs a
  respondent id to run.
* A scale shorter than `straightline_min_items` is still left unchecked for
  straight-lining by default, since identical answers to 3 items are common
  among attentive respondents. The printed report now names the threshold and
  the setting that would check the scale, and the analysis-plan quality table
  names the threshold too. The argument's help says how to check 3-item
  scales, in a call or in a plan.

* **An `efa_solution` block that names a missing item says which.** Its
  `items` and `variables` roles went unchecked, so a block naming an item the
  instrument or the responses lack failed with "EFA solution requires at least
  two available item columns." and never named the item. It now fails the
  standard check, as other methods do, naming the item.

### Answers coded and ordered as the instrument declares them

Every statistic in a review of the runners against base R and reference
packages matched (Fable sitting 2, Codex passes 2 and 3). These are defects
in how answers were coded, ordered and labelled before and after the
arithmetic.

* **McNemar's test pairs each category with itself.** The table was
  `table()` of the 2 columns as they came, so the first row level was paired
  with the first column level whatever they were. 2 factors holding yes and
  no in opposite level order gave chi-square 0.80 and p = .371 where the
  test on the aligned table gives 0 and p = 1, and 2 items whose observed
  categories differed (a and b at the first time, b and c at the second)
  were tested as a 2 by 2 table pairing a with b. The table is now laid out
  on 1 order for both items, the declared choice set and then any other
  value, 2 items with different choice sets are refused with both named,
  and a pair of categories nobody moved between gives an error in place of
  a statistic of NaN (FR-22, P2-03).
* **An ordinal outcome is ordered as its choice set declares.**
  `regression_logistic_ordinal` ordered a text-coded outcome
  alphabetically, so low, medium, high became high < low < medium and the
  slope's sign was reversed (0.85 became -0.60 on Fable's data). The order
  is now the declared choice set, then other values, numbers by value (an
  outcome coded "2", "9", "10" in that order, not "10" first). The result
  carries `$outcome_levels`, and the sentence names the order: "Ordinal
  logistic regression of "Rating", ordered Low < Medium < High, was
  estimated with 90 complete cases." (FR-19).
* **A nominal choice item enters a model as a category.** A
  `single_choice` item coded 1, 2, 3 for North, South and East entered
  linear regression as 1 slope, as if East were 3 times North (R squared
  .09 where the categorical model gives .23). A `single_choice` or
  `multiple_choice` item now enters every model as a category, whatever its
  codes look like: linear, binary, ordinal, multinomial and Firth logistic
  regression, and the ANCOVA covariates. Firth regression had read every
  predictor as a number, so a text category became missing and its rows
  were dropped. The first declared category with answers is the reference,
  unused categories are dropped before fitting, the result carries
  `$predictor_coding`, and the sentence names the reference: ""Region"
  enters as 2 indicator terms against the reference category North." See
  "How answers are coded" in `?run_analysis_plan` (FR-20).
* **A binary model names the level it models, in every locale.** Binary
  logistic regression modelled the level that sorted last in the session's
  collation: an outcome of "Yes" and "no" gave a slope of 1.238 under
  en_GB.UTF-8 and -1.238 under C, and nothing said which level the odds
  ratios described. A factor outcome with an unused level stopped with "y
  values must be 0 <= y <= 1". The modelled level (the event) is now the
  last declared code of the outcome's choice set with answers, or with no
  choice set the last in 1 locale-free order (numbers by value, text in
  code point order), and `options$event` names another. Binary and Firth
  logistic results carry `$event` and `$reference_level`, and the sentence
  says "The odds are of "Outcome" being Yes, against No." The multinomial
  reference category and the order of a t test's or Mann-Whitney test's 2
  groups with no choice set follow the same locale-free order (FR-21,
  P2-08).
* **A "do not know" code in a scale's choice set is not scored.** Every
  numeric code was a score, so a set of 1 to 5 with 99 for "do not know"
  gave the item bounds 1 to 99: a reversed 1 became 99 and a respondent
  answering 4, 4, 2, 1 scored 27.25 where 3.75 is right, with nobody
  choosing 99. A 99 that was chosen entered the mean, and alpha fell from
  .78 to .04 on Fable's data. `score_scales()`, the reliability and item
  results now score the longest run of codes at 1 even step and read other
  codes as missing, with a message ("99 is not scored"), and
  `validate_sframe()` notes such a set, naming its codes. A set with 2
  equally long runs, such as 1, 2, 4, 5, has no clear run, so its scale is
  refused with an error and the note says so. See "Codes that are not scores" in
  `?score_scales`. A declared "not a score" code in the schema is planned
  for 0.4.4 (FR-18).
* **The R code shown beside a result codes answers as the result did.**
  `sframe_syntax_result()` and the report's code chunks wrote their own
  coding (`ordered()`, `as.factor()`, `table()` of the 2 McNemar columns,
  any column of numbers as a number), so after the 4 fixes above they would
  have fitted a different model from the result. Each runner now records
  the coding it used (`$outcome_levels`, `$predictor_coding`, `$event`,
  McNemar's `$category_levels`) and the code writes it out: a choice
  predictor as `factor(x, levels = c("1", "2", "3"))`, the ordinal outcome in declared
  order, the binary event as `== "Yes"`, and McNemar's 2 items on 1 set of
  levels. The tests run the code and compare its estimates with the result.
* **A CSV row wider than its header is refused, not shifted.** A file
  whose data rows had 1 field more than the header, as a trailing separator
  gives, was read with its first column as row names: every answer and the
  respondent id moved 1 column to the left, with no warning. `read_responses()`
  now counts each record's fields first. When every data row has exactly 1
  extra field and it is empty in all of them, the field is dropped with a
  message. Any other row whose width differs from the header's is refused,
  naming the first 3 lines and their field counts (P3-01).
* **A blank answer is missing in every column `read_responses()` returns.**
  Only text columns were cleaned, so a factor column of a data frame kept
  its "" as an answer, and a declared numeric column with 1 value that did
  not read as a number stayed text with its "" and no message. Every text
  or factor column now has its blank answers (empty, or only spaces) made
  missing first, factors become text, and a declared numeric column that
  stays text gives a warning naming the column and up to 3 of its values
  (P3-05).
* **A file of 1 column keeps an unanswered respondent.** In a CSV file
  with a single column, a respondent who left the question blank is a blank
  line, which was skipped, so the respondent was lost and every later row
  moved up. Blank lines are now kept as missing answers in a 1-column file,
  except those after the last line that holds anything. No surveyframe
  collector writes such a file (P3-02).
* **A choice code with white space at either end is refused.** The reader
  trimmed a set's codes before deciding whether they were numbers, so a set
  declared as " 1" and "2" read as numeric and the answer " 1" became 1, a
  code the set does not hold: the frequency table gained an unlabelled
  category. `validate_sframe()` now reports such a code as a problem, naming
  the set and the code, and the reader compares codes as declared.
  SurveyBuilder already trims a code as it is typed, so only a set written
  in R or edited by hand can hold one (P3-04).
* **`export_responses()` keeps codes such as "01" as text.** It decided
  that a choice set's codes were numbers with `as.numeric()` alone, so codes
  "01" and "02" left as 1 and 2 in .sav and .dta files: the labels survived
  but the codes no longer matched the instrument, and analysis of the
  re-read file stopped. The export and `read_responses()` now share 1 test,
  the numeric round trip, so such codes take the text route already there:
  labelled text in a .sav, positions 1, 2, 3 with their labels in a .dta
  (P3-03).
* **Every analysis treats a blank answer as missing and ignores unused
  factor levels.** `read_responses()` made blanks missing, but data built in
  R or passed from a host application reached the runners with "" as an
  answer. It was a valid answer in the missing data report (2 valid of
  "", "a" and NA), a category in Fisher's test (N = 6 and a 3 by 2 table
  where 4 answered a 2 by 2), a fourth group in a 3-group ANOVA (df1 = 3)
  and Kruskal-Wallis, a third group that stopped the t test, and a numeric
  column held as text with blanks had no descriptives (valid 5, mean NA).
  A factor with a level nobody chose stopped the cross-tab and chi-square
  with "missing value where TRUE/FALSE needed". Every runner, the
  descriptives and the missing data report now start from 1 cleaning, the
  blank rule `read_responses()` uses (empty, or only spaces) and only the
  factor levels that have answers (P2-04, P2-05, P2-07, FR-28, FR-29,
  FR-31).
* **A chi-square cross-tab names both axes by their choice labels.** The
  table carried the codes, and only a code meaning the same in every
  choice set of the instrument was relabelled, so a channel item coded 1 to
  3 showed rows "1", "2", "3", and a 0:1 item showed columns "No" and "1".
  Each axis is now labelled from its own item's choice set, in declared
  order, in the counts, the totals, the percentages and the weighted table
  (FR-37).
* **A frequency table's percentages are of those who answered.** Its
  Percent column was of every row, missing included, while the weighted
  table beside it and a descriptives block's counts were of those who
  answered: North was 28.9% in 1 table and 36.1% in the other with every
  weight 1, and the sentence gave N = 90 where 72 answered. Percent is now
  the valid percent everywhere, the missing row keeps its count with no
  percentage, and the sentence gives the number who answered and the number
  missing: "Frequency distribution for "Region" (N = 72, 18 missing)."
  (FR-23).
* **The intervals for Cramer's V and eta squared can reach 0.**
  `sframe_cramers_v_ci()` and `sframe_eta_sq_ci()` were percentile
  bootstraps, and a resampled V or eta squared is never below 0, so the
  interval sat above the estimate when the effect was small: an exactly
  independent table read "V = 0.00, 95% CI [0.05, 0.50]", and of 40 samples
  with no group difference the eta squared interval reached 0 in none.
  Both are now the 2-sided noncentrality intervals effectsize computes
  (`cramers_v(adjust = FALSE, alternative = "two.sided")` and
  `eta_squared(partial = FALSE, alternative = "two.sided")`), from the
  chi-square and the F statistic, and match it to 6 decimals on 7 tables
  and ANOVAs. They involve no resampling, so `R` and `seed` are kept but
  not used, and the result carries `method`. The chi-square, phi and
  one-way ANOVA results change their intervals. The Kruskal-Wallis eta
  squared keeps its bootstrap interval (FR-24).
* **Every result sentence uses the block's alpha.** A block's `alpha`
  reached the independent t test and the one-way ANOVA only, and the other
  sentences compared p with a fixed .05: with alpha .001, a Pearson
  correlation at p = .014 read "a positive, medium significant
  correlation". The chi-square, Mann-Whitney, paired t, Wilcoxon,
  Kruskal-Wallis, correlation, linear and binary logistic sentences now
  compare p with the block's alpha too (FR-25).
* **A sum score with unanswered items is prorated.** With `method =
  "sum"` and `min_valid` below the number of items, an unanswered item
  counted as 0: a respondent answering 5 and 5 on 2 of 4 items scored 10,
  the middle of the 4 to 20 range, where the mean method gave the top. The
  sum is now the mean of the answered items times the number of items (with
  weights, the weighted mean times the sum of the weights), 20 here. A
  respondent who answered every item gets the plain sum, as before. The
  help for `min_valid` and `?score_scales` say so (FR-26).
* **A chi-square block with a constant variable is refused.** A variable
  with 1 category made a 1 by k table, which `chisq.test()` tests against
  equal shares: a goodness-of-fit test reported as "chi-square(2, N = 90) =
  6.67, p = .036, V = NA" and "a significant association". The block now
  stops, naming the variable with 1 category (FR-27).
* A chi-square with `options$simulate_p_value` on a sparse table printed
  "chi-square(NA, N = 4)", since a simulated p value has no degrees of
  freedom. The line now omits them and says how the p value was found:
  "chi-square(N = 4) = 0.00, p = .52 (simulated from 2000 tables)", for
  example (P2-09).
* **`score_scales()` names the answers it cannot score.** A value outside
  the item's choice set was scored: 7 on a 1 to 5 item counted as 7 and a
  reversed 0 became 6. An answer that is not a number, such as "4,5",
  became missing without a word and counted as unanswered toward
  `min_valid`. Both are now missing with a message naming them (FR-30).
* **APA 7 numbers.** A p value above .999 is written p > .999 (it was p =
  1.000), and one just below the alpha in force keeps the decimals that
  show it, p = .04996 where ".050" sat beside "significant". Cramer's V,
  written V by the chi-square block, drops its leading zero as phi does (V
  = .23, 95% CI [.07, .45]). A value that rounds to 0 prints 0.00, never
  -0.00. A model coefficient or standard error below .01 in size shows 3
  decimals, so a slope of 0.004 with p < .001 no longer prints as 0.00. A
  table column prints whole numbers with no decimals only when it holds
  counts or percentages: F values of 4 and 9 printed "4" and "9" (FR-32).
* **A block's bootstrap interval no longer depends on the blocks before
  it.** The plan seed started 1 random stream for the whole plan, so adding
  a Spearman block before a t test moved its d interval from [0.097, 1.221]
  to [0.079, 1.180]. Each block now starts its own stream from the plan
  seed and its id, so amending the plan leaves every other block's interval
  as it was. Every bootstrap interval in a plan therefore differs from
  0.4.2's for the same seed (FR-33).
* An interval prints its own level. Every bootstrap interval and the
  Fisher z interval printed "95% CI" whatever their `conf.level`, so a 90%
  interval read as 95%. The level now travels on each interval the package
  builds (B-04).
* A chi-square block with a weights role tests the unweighted counts, as
  before, and now says so in its sentence and note, naming the weight whose
  counts are in the weighted table beside it (FR-34).
* The ordinal logistic table gives each slope's standard error, p value,
  odds ratio and 95% interval. The thresholds (the cut points between
  outcome levels, such as low|medium) keep their estimate and standard
  error and no longer print an odds ratio. The result's `$coefficients`
  gains `p` and `threshold` (FR-35).
* A Firth logistic block reads `options$conf_level` as well as
  `options$conf.level`. Both were accepted, and `conf_level` gave a 95%
  interval and was not listed as ignored (FR-36).
* **`sframe_assumption_results()` says which checks ran.** Its sentence was
  always "Assumption checks were computed.", even when no check ran, as
  with an outcome and a group and no `variables`. It now names the checks
  that ran, or says none ran and which arguments each check needs, naming
  an `outcome` given without `predictors` or a `group` without `variables`
  (review_040 defect 3).
* **`render_results()` refuses a citation format it does not write.** Its
  `citation_format` accepted "apa", "ama" and "vancouver" and never used the
  argument: all 3 gave the same APA 7 document, so a methods section could
  name a style the report never applied. "ama" and "vancouver" were never
  applied in any release. `citation_format` now defaults to "apa" and
  refuses anything else with a message (review_040 defect 7).
* **9 demos' stored results are regenerated** for the fixes above:
  `categorical` (V's interval and leading zero, rows in declared order),
  `correlation_regression`, `paired`, `two_group`, `small_sample` and
  `sem_pls` (bootstrap intervals from the per-block seed, p > .999, the
  Firth event), `logistic` (the binary event, the ordinal order, the
  multinomial reference Workshops and its p values), `matrix_likert` (V's
  interval now reaches 0 beside p = .407) and `multi_group` (eta squared's
  noncentrality interval, the Kruskal-Wallis bootstrap interval).

## Reports

* **The missing-data patterns table gives a percentage under "Percent".**
  `sframe_missing_data_results()` stored each pattern's share as a
  proportion in `patterns$percent`, so both report engines printed "Complete
  case | 60 | 1" under "Percent" for 60 complete cases. `percent` now runs
  from 0 to 100 and a new `prop` column holds the proportion. The
  `missing_pct` columns kept for 1 release hold a proportion, as their help
  now says (Codex P1-01).

* **Descriptives count a categorical item's answers as valid.**
  `sframe_descriptives_results()` turned every value into a number before
  counting, so category codes such as "online" counted as missing and the
  report gave a choice item 60 missing and 0 valid beside a missing-data
  table that said 0 missing. `valid_n` and `missing_n` now count the
  responses as given. An item whose responses are not all numbers keeps
  its counts with `NA` in every numeric column, and both report engines
  print a dash there with a table note. The Quarto report now lists the
  instrument's items, as the built-in report does, where it had listed
  every column that held a number (Codex P1-02).

* **Every report table heading is set as APA 7 sets it, in every format.**
  The Quarto report printed raw column names (`missing_n`, `ci_low`,
  `weighted_mean`) and, in HTML, an unlabelled column of row names. 1 label
  map now gives both engines their headings: words for counts ("Valid
  *n*", "Missing proportion"), statistic symbols in italics (*M*, *SD*,
  *Mdn*, *SE*) and the confidence level in an interval heading ("95% CI
  lower"). Row names are left out in every format.
  `sframe_apa_col_labels()`, on the `sframe_apa_cells()` help page, gives
  those headings for HTML or Markdown. The `n_items` heading reads "Items"
  (Codex P1-03).

* Quarto reports in Word, OpenDocument and PDF number tables and figures as
  APA 7 does: "Table 1" or "Figure 1" in bold on its own line, and the title
  in italics on the next, both above the table or figure. Tables printed
  "Table 1: Provenance" on 1 line, and figures had a bold title with no
  number (Codex P1-04).

* In the Typst and LaTeX PDFs a table's or figure's number and title stay
  on the page of the table or figure, where they could land at a page foot
  with the float on the next page (Figure 2 in Typst, Table 2 in LaTeX). A
  figure goes with its 2 lines in 1 block that does not break. A table
  starts a new page in LaTeX when fewer than 5 lines are left, and in Typst
  its 2 lines stick to it (Typst 0.12 or later; with an older Typst a table
  of up to 12 rows is kept whole).

* The report's descriptives come in 2 tables in every format, centre and
  spread (*n*, valid and missing *n*, *M*, *SD*, *Mdn*, IQR, minimum and
  maximum), then shape and interval (skewness, kurtosis, *SE*, the CI and,
  when weights are given, the weighted mean), where 1 table of 17 columns
  ran together in the Typst PDF. In Typst and LaTeX, tables are set
  single-spaced at 10 points, and each column is at least as wide as its
  longest word, since item IDs such as `sessions_attended` ran into the next
  column of the codebook and plan tables. Outside HTML the instrument hash
  takes a line of its own, which it ran past the LaTeX margin (Codex P1-05).

* **Quarto is the report engine, and `render_report()` finds the copy
  RStudio or Positron bundles.** It looked only for `quarto` on the PATH,
  where neither IDE puts its copy, so a machine with RStudio and no separate
  Quarto got the built-in page. It now tries, in order, `QUARTO_PATH` (the
  path of the executable), the PATH, `RSTUDIO_QUARTO`, RStudio's bundled
  copy and Positron's, and uses the first that runs `quarto --version`. The
  report names the version used and where it was found. Without Quarto the
  built-in engine writes a short plain results page under the banner
  "Install Quarto for the full formatted report", with a link. That page
  gets no new features and is not promised to match the Quarto report.
  The Quality summary table and Respondent-wise missingness, which only
  the built-in page had, are in the Quarto report too.
* **Word, OpenDocument and a Quarto PDF.** `render_report(format =)` takes
  `"docx"` and `"odt"`, written by Quarto and styled by 2 bundled APA 7
  reference documents: Times New Roman 12, double spacing, a half-inch
  first-line indent, level 1 headings centred and bold. Without Quarto they
  stop with a message that names it. A PDF now goes through Quarto and
  LaTeX where a LaTeX engine is found, through the Typst Quarto bundles
  where none is, and only without Quarto through the built-in page printed
  by pagedown. The `"converter"` attribute and the manifest name the route.
  Outside HTML every table is numbered, and its title kept, in each format.
* **On a Mac without XQuartz, a PDF report through Typst had no figures.**
  Quarto stopped with "file not found" and no PDF was written. R's own
  `svg()` device needs the Cairo that XQuartz installs, and without it R
  still reports Cairo as present but draws nothing. `render_report()` now
  checks that `svg()` opens, and where it does not, draws the figures with
  svglite when installed, else as PNG, and says which. The same check makes
  `figures = list(format = "svg")` work there, and runs in the `report.qmd`
  that `render_report(format = "qmd")` writes, for a Mac user rendering it.
  Charts saved as SVG with `sframe_save_figures()` or
  `sframe_format_result()` need svglite, and now say so before drawing, also
  where Cairo is present.
* **A PDF printed without Quarto left Chrome's scratch folders behind.**
  Each `render_report(format = "pdf")` through `pagedown::chrome_print()`
  left `com.google.Chrome.*` and `scoped_dir*` folders in the temp folder,
  since the cleanup looked in R's session folder and Chrome writes beside
  it. Chrome now runs with a temp folder of its own, removed afterwards.
* **A report source could say its numbers differ when they did not.** The
  canonical JSON behind the results record, the instrument hash and the
  amendment fingerprints sorted its keys in the session's collation order,
  so a session in an English locale and one in the C locale put "Scale"
  and "ceiling_pct" in opposite orders and hashed the same numbers
  differently. Keys now sort by code point in every locale, as
  SurveyBuilder does. A
  file, results record or committed instrument hashed in the old order is
  still accepted, with a message that it was hashed in the order used
  before 0.4.3 and should be saved again to update the hash. New hashes
  are always written in code point order, and a changed file still fails.
* **R, SurveyBuilder and the verifier page hash 1 canonical form, RFC 8785,
  the JSON Canonicalization Scheme** (Codex pass 2 P2-01 and P2-06, Fable
  FR-01 to FR-03, FR-09, FR-10 and FR-12). A null was hashed as `{}`, so a
  null changed to `{}` kept its hash, and an `NA` in a text field such as an
  item's `help` wrote a file its own check refused. Numbers below 0.0001,
  from 1e15 up or with 16 or 17 digits, and any text holding `</`, hashed
  differently in R and in JavaScript, so a file one side wrote failed on the
  other. Keys that are all digits, the empty key and `__proto__` hashed
  differently in JavaScript. In all 3, keys now sort by UTF-16 code units,
  numbers take ECMAScript's shortest form that reads back to the same value,
  strings are escaped as `JSON.stringify()` escapes them and null stays
  null, and the file holds every number in the digits its hash covers. A
  file that gives a key twice is refused, since R kept the first and
  JavaScript the last. A number JSON cannot hold, such as `Inf`, is refused
  at write with its field named. An `NA` is written as null where the
  published schema allows null for that field, such as an item's `help`, and
  refused with the field named anywhere else, such as inside
  `meta$authors`. A file hashed in
  the 0.4.3 development form is accepted with a message to save it again.
  The 26 bundled `.sframe` files were written again, and only their hash
  object changed. `tests/testthat/fixtures/canonical/` holds
  the payloads all 3 hash alike, checked through node.
* **A file holding an escaped U+0000 or a lone surrogate is refused** by
  `read_sframe()`, SurveyBuilder and the verifier page. jsonlite cut a
  string at an escaped U+0000 and turned a lone surrogate escape into "?",
  so in R a text changed after the U+0000 kept its hash, and 2 different
  files could read as 1. The check reads the raw text before it is parsed,
  and an escaped backslash before `u0000` is plain text and passes. The
  shared fixture holds 53 cases with these.
* **The hash names its canonical form, `hash$canonical = "rfc8785"`**
  (owner, 2026-11-11). `write_sframe()` and SurveyBuilder write it inside
  the hashed content, with only `hash$value` emptied, so changing it breaks
  the hash. `read_sframe()`, SurveyBuilder and the verifier page apply 1
  rule. A file naming `"rfc8785"` is checked in RFC 8785 alone, with no
  fallback to an earlier form. A file naming no form was written before the
  field existed, so it is checked in RFC 8785 and then the earlier forms,
  and any match is accepted with a message to save it again, a legacy match
  among them, which was accepted silently before. A file naming any other
  form is refused, since it needs a newer surveyframe. 25 bundled `.sframe`
  files were written again, and `verification_tampered.sframe` was rebuilt
  from `verification.sframe` with the same 1-word edit. `tests/testthat/fixtures/canonical/hash_canonical/` holds 8 files
  that all 3 judge alike: the field present, absent, set to an unknown value
  or to null, deleted or added after sealing, and content edited.
* **A file hashed before 0.4.3 is recognised in any session** (Fable FR-08
  and FR-11). The old key order followed the collation of the session that
  hashed, so a file hashed in an English session was refused as modified in
  a C session, such as a container or `R CMD check`. The old form is now
  tried in the session's, the C and the en_US collation. The legacy hash,
  for files written before canonical serialisation, is read only and never
  written. It keeps numbers to 4 decimals, as jsonlite's default did, so 2
  numbers that agree to 4 decimals hash the same in it. The verifier page
  hashed such numbers in full and now takes the legacy hash as R does.
* **The Quarto source of a report, which checks itself.**
  `render_report(format = "qmd")` writes a folder: `report.qmd`, the
  `.sframe`, `responses.csv`, the bibliography and its style, the results
  record and `manifest.json`, with no `_quarto.yml`. Opened in RStudio or
  Positron, `report.qmd` recomputes every number from the folder's own files
  through the new `sframe_report_source()`, and its Provenance section says
  "The analysis plan results match the recorded results" or "differ" with
  both hashes, whether each file it reads is the one exported, and whether
  `report.qmd` was edited after surveyframe wrote it. Editing stays allowed and is disclosed. The
  instrument's text reaches the `.qmd` only as its JSON-quoted title and
  authors, so a title holding quotes, a colon or a `---` line leaves the
  front matter whole.
* **An untouched report source says its numbers match.** The source folder
  of an instrument built in memory and never saved, or of responses given
  as a plain data frame, said "Numbers differ from the recorded results"
  before anything was changed. The record was computed from the objects in
  memory and the check from the folder's files, and the 2 differ: the
  written instrument gains its normalised fields, so its hash changes, and
  `responses.csv` keeps 15 significant digits, so a statistic moves in its
  last digit. Export now writes the files, reads them back and computes the
  record from those, as the check does. A changed response still turns the
  check `FALSE`.
* **The report source checks every file it reads** (Codex pass 2 P2-02,
  Fable FR-04, FR-07, FR-15 and FR-17). The check recomputed the plan
  results and compared them with the record's hash in the manifest, but
  never opened `report_results.json`, so an edited or deleted record still
  passed. The record file is now hashed against the manifest, as its own
  verdict (`results_file_match`) and its own Provenance line, "Results
  record". `references.json` and `interpretations.json` join the manifest
  and the check (`references_match`, `interpretations_match`), with the
  Provenance lines "Bibliography" and "Interpretations", so an emptied
  bibliography or an interpretation added after export is reported. The
  results line now says what it covers: "The analysis plan results match
  the recorded results". The responses sha256 of a report hashed the data
  as JSON with 15 significant digits, so NA, NaN and Inf hashed alike, as
  did 0.3 and 0.1 + 0.2, and a time was written in the session's zone. Each
  column is now hashed with its name and type, doubles in 17 significant
  digits with NA, NaN, Inf and -Inf by name, and a POSIXct as its seconds
  in UTC, so the same instant hashes alike in any time zone.
* **An instrument read unverified is written only as a new instrument**
  (Fable FR-05). `write_sframe()` let one read with `verify = FALSE` be
  written back unchanged with the amendment log it was read with, but that
  log was read unchecked too, so a sign-off, a tier or a timestamp edited as
  text, or an entry deleted, was written back and read verified. It is now
  refused, and `new_instrument = TRUE` writes it with a new log, once the old
  one is cleared with `instrument$amendments <- list()`.
* **More changes that move a score are design tier** (Fable FR-06).
  `amend_sframe()` forced the design tier for a change to how a scale is
  scored, but not for an item's own `reverse = TRUE`, which
  `score_scales()` applies all the same, so reverse keying an item passed as
  a pipeline amendment and moved its scale scores. A change to an item's
  `reverse` or `scale_id`, to the choice codes of an item a scale scores, or
  to the item an attention check tests or its pass values is now design
  tier, and needs a deviation report.
* **The help says what the write boundary rests on** (Fable FR-16).
  `?write_sframe` and `?amend_sframe` say that the link to the file read is
  the attribute `sframe_origin`, which the package's functions keep and base
  R that rebuilds the list, such as `x[names(x)]`, `c(x)` or `lapply()`,
  drops, after which a change is written with no amendment asked for.
* **`validate_sframe()` reports 4 more malformed fields** (Fable FR-13).
  An item whose `choice_set` or `scale_id` holds more than 1 id, a
  branching rule with no `item_id` or `depends_on`, and a check with no
  `item_id` stopped it with "argument is of length zero", so
  `strict = FALSE` returned nothing and `read_sframe()` failed the same way.
  Each is now a problem naming the component and the field, such as
  "Branching rule 1's item_id is missing".
* **`validate_sframe()` checks what scores and shows** (Fable FR-14). A
  scale `method` other than "mean" or "sum" (it was scored as the mean), a
  plan `alpha` or `options$alpha` that is not a number between 0 and 1 (it
  changed nothing), a choice set whose values and labels differ in length,
  a branching rule with an unknown or no operator, and a rule on its own item
  are problems. Rules that depend on each other in a cycle, a check pass
  value that is no code of its item's choice set, and an item whose
  `scale_id` names a scale that does not list it are notes, read by
  `sframe_notes()`, since SurveyBuilder saved them before, so those files
  still open. SurveyBuilder now refuses a rule that would close a cycle and
  a pass value outside the item's codes, and choosing a scale for an item
  in its editor adds the item to that scale. A rule on an item asked later
  stays allowed, since on 1 page the answer arrives as it is given.
* **A field with an empty name is refused at write.** JSON allows an empty
  key, but `write_sframe()` wrote an R list element with an empty name under
  its position, so `{"a":1,"":3}` read from a file was written back as
  `{"a":1,"2":3}`, a changed instrument with no amendment, and `{"":3}`
  alone became an array. Such a file still reads, and writing it is refused
  with the field named, such as "The field at $.meta.custom[1] has an empty
  name".
* **Messages count in words.** Every message, warning, error and printed
  summary from the R functions says "1 item" and "2 items", "There is 1
  weight" and "There are 3 weights", where 68 places wrote "item(s)" or
  "criterion/criteria". A list of ids takes the noun its length needs:
  "Plan block P1 names objective 'O1'" and "Plan blocks P1, P2 name
  objective 'O1'". A test walks every string in the package's functions and
  fails on a new "(s)".
* **Every report has a results record and a manifest beside it.**
  `render_report()` writes `<name>_results.json`, the plan results as
  canonical JSON, and `<name>_manifest.json`, the sha256 of the instrument
  content, the responses, the results record and the output as generated,
  with the surveyframe version and the time. The field names follow the SSR
  6.0 hash manifest. A Provenance section at the top of the report, in both
  engines and every format, gives the instrument hash and whether
  `read_sframe()` verified it, the amendment count, the responses sha256 and
  the results record's sha256. An edited copy of a report then no longer
  matches its recorded hash, while the numbers it presents still verify.
  The plan runs once per report and feeds both engines and the record.
* **A Quarto report renders offline.** The report theme imported a Google
  web font the report never used, so every render needed the internet, sent
  Google a request, and hung with no timeout when the connection stalled.
  The theme's web font is off, and a render fetches nothing.
* **One computation feeds both report engines.** `render_report()` now
  computes the codebook table, every distribution chart and the plan
  results inside the package and hands them to the Quarto template, which
  only prints them. The template used to run the analysis plan and draw
  the charts itself, so the 2 engines could disagree.

* **A statistic that cannot exceed 1 has no leading zero.** Result text and
  prompts write r, r_s, tau, phi, Cramer's V, R squared, eta squared and
  their intervals as APA 7 does, `r(58) = .53, 95% CI [.33, .69]`, as p
  values already were. d, t, z, means and other values keep the zero. Done
  once for every analysis, and the demo results are regenerated (D9, CX-24).
* **Every report engine prints a table's cells the same way.** The built-in
  engine and the Quarto template rounded every number to 2 decimals, so a p
  of .004 showed as 0. A p column now shows 3 decimals with no leading zero,
  or `<.001`, a column that cannot exceed 1 drops its leading zero, other
  numbers show 2 decimals, and a missing value is a blank cell, in
  `render_report()`, `render_results()` and `render_result()` alike. The new
  `sframe_apa_cells()` does it (CX-15).
* **Result text in an HTML report sets its symbols as APA 7 does.** t, F,
  p, r, d, N and the other Latin symbols are italic, `r_s` and `d_z` print
  with a subscript, tau and phi as Greek letters and chi-square as its
  symbol. The text was plain in all 3 HTML renderers (CX-24).
* **Table headings set symbols as APA 7 does.** A `p` column was headed
  "P", `t` "T" and `df` "Df", and `render_results()` printed raw names such
  as `missing_pct`. Symbols are now italic, `r_s` has its subscript, a
  proportion column such as `missing_prop` reads "Missing proportion" and
  drops its leading zero, and other names read as words, in both report engines (CX-24).
* **Result text counts with real plurals.** "7 power-iteration step(s)",
  "5 choice column(s)" and the decision methods' notes and errors now read
  "7 power-iteration steps" and "1 respondent". The demo results are
  regenerated (CX-24).
* **A PDF report matches the HTML report from the same call.**
  `render_report(format = "pdf")` dropped `title`, `authors`, `references`,
  `csl` and `figures` on the way to the HTML report it prints. It now passes
  all 5 (CX-04).
* **Tables and figures are numbered, titled and described.** The built-in
  report, `render_results()` and `render_result()` number every table and
  figure in reading order as APA 7 does, with the number in bold and an
  italic title below it. A result's table and chart are titled by the block
  and its research question instead of "Results table", each chart sits in a
  figure with a caption, and base graphics charts carry real alt text where
  every one read "distribution" (CX-22).
* **The Quarto report numbers its tables and figures too.** Its tables
  and figures take the same numbers and titles as the built-in report's,
  every chart image carries alt text where it had none, and a reliability
  result no longer prints a second table under the same title (CX-22).
* **The built-in report prints each research question's hypotheses and
  decision rule before its result.** H0 and H1 print where written, then
  the planned decision rule, then the result, then the interpretation,
  labelled "Interpretation (written after the results)". The decision rule
  printed only beside a written interpretation, and an interpretation stood
  in for an empty decision rule. The 2 fixed sentences earlier versions of
  SurveyBuilder and SurveyStudio saved as hypotheses, and an interpretation
  copied from the decision rule, are not printed.
* **`render_results()` and `render_result()` print the same declaration.**
  H0, H1 and the decision rule print above the result, and the
  interpretation below it under the same label. `render_results()` showed
  the decision rule as the interpretation when none was written, and a
  result from `run_analysis_plan()` carried its decision rule as its
  interpretation. A result's `interpretation` is now only what was written.
* **The Quarto report prints the same declaration as the built-in one.** It
  printed the block's interpretation as an "Interpretation prompt" before
  the data existed, and no hypotheses. `render_report()` now computes each
  block's declaration and interpretation with the built-in engine's helpers
  and hands them to the template, and the `interpretations` help for
  `render_report()` and `render_results()` says what prints where.
* **A Quarto report records the surveyframe that rendered it.** Its
  Reproducibility section gives the version, and the commit where the
  install carries one (`RemoteSha`, written by remotes and pak). Quarto
  renders in its own R process, which loads the installed package, so this
  names the code that produced the numbers.

* **The tests render Quarto reports with the build under test.** A test
  setup file installs the source once per run and puts it first on
  `R_LIBS`, so every child R process, Quarto included, loads it. The
  earlier `render_report()` shadow never ran under `devtools::test()`, so
  Quarto tests had rendered with the installed copy.
* **The Quarto build guard fails when a git source tree gives no commit.**
  It skipped the commit comparison on an empty commit, so a failed lookup
  let a report from a stale install pass on its version alone.
* **The tests have a fast tier and a slow tier.** In a source tree, the 18
  tests that render through Quarto or drive Chrome run only when
  `SURVEYFRAME_SLOW_TESTS=true`, and the source install they need is made
  only then. The skip message names the variable. The fast tier renders
  every report with the built-in engine from the source under test. Under
  `R CMD check` nothing changes.

* **`render_report()` shows the report it writes.** In an interactive
  session the new `open = TRUE` default opens it in the viewer pane of
  RStudio, Positron or VS Code, or in the web browser elsewhere, and
  `open = FALSE` keeps it closed. A knitr or Quarto render opens nothing. The
  completion message gives the full path, where it gave the path as written,
  often a bare file name. A line says when Quarto starts, since it works in
  silence for up to a minute, and `figure_dir =` reports where the chart
  files went.
* **New `render_result()` renders one analysis result as the report does**:
  the formatted table with its caption and note, any second table, the APA
  line, and the chart the report picks for that method, with the
  instrument's labels, as an HTML fragment or with the chart written as PNG
  or SVG. It uses the report's own code, so a host showing results one at a
  time and the report agree. A host had to keep its own map from method to
  chart, which drifted with each release.
* **Figures at the size, resolution and format a journal asks for.**
  `render_report(figures = list(width =, height =, dpi =, format =))` applies
  to every figure in both engines, and defaults to the `surveyframe.figures`
  option, so a host can set it once. `figure_dir =` also writes each plan
  chart as its own file, PNG, TIFF, JPEG, PDF or SVG. New
  `sframe_save_figures()` does the same for the results of
  `run_analysis_plan(plots = TRUE)`. The report fixed its own figure size,
  and the built-in engine saved charts at 110 dpi.
  SVG uses svglite where it is installed, now in Suggests, and R's own
  Cairo device otherwise. Where neither is available the report draws PNG,
  and a request to write SVG files says to install svglite.
* **`codebook_report(format = "md")` gives Markdown.** The codebook carries
  itself as Markdown text in `markdown`, a heading and a pipe table for the
  items, choice sets, scales, plan and models, and `print()` writes it. Save
  it with `writeLines(cb$markdown, "codebook.md")`. The format argument
  changed nothing before, so a host received the printed text table.
* **`render_report()` takes `title` and `authors`**, which default to the
  instrument's title and authors. Every Quarto report was titled "Survey
  Research Report" whatever the study. The date under the title is labelled
  "Rendered" in place of Quarto's "Published", since a rendered report
  has not been published. The built-in HTML engine shows the authors too.

## Validation

* **A plan block's hypotheses must hold text fields named `null` and
  `alternative`.** `validate_sframe()` accepted any shape there, and a report
  has nothing to print from a hypothesis that is no text.
* **A plan block whose roles its method never reads is refused.** A
  frequency block naming its item under `items` ran on nothing and reported
  "Frequency distribution for NA (N = 0)" with an empty table.
  `validate_sframe()` now says which roles the method reads and which the
  block names, and `run_analysis_plan()` gives such a block an `error` in
  place of a result. The roles a method reads are found from the same
  resolver the analysis uses, so the 2 stay in step. `partial_correlation`
  and `mediation` also accept every role alias their runners read.
* **A block's error names its cause.** A block whose role named an item the
  instrument lacked reported "Test failed.", and 8 other runners gave
  errors as bare as "ANOVA failed.". `run_analysis_plan()` now names a
  variable the responses lack, saying whether it is an unknown name, an item
  with no column or a scale with no scored column, and a test that fails
  says which variable holds no numbers, or that too few responses had a
  value, or else passes on R's own reason.
* **A choice set whose codes read as the same number is refused**, by
  `sf_choices()` and by `validate_sframe()`. Responses to a set whose codes
  are all numbers are read as numbers, so the codes 1 and 1.0, or 2 and 02,
  became one option, and `sframe_export_labelled()` then failed on duplicate
  labels.
* **`print()`, `format()` and `summary()` of an instrument check it before
  they give its status**, as Studio's Open Instrument does. They read the
  stored `validated` flag, which an edit after validation can leave stale,
  so a valid instrument could print "not validated" and a broken one
  "valid". The status is now "valid", or "invalid" with the number of
  problems and a pointer to `validate_sframe(x, strict = FALSE)`. Counts are
  in words, "1 block" and "2 analysis blocks", never "block(s)"
  (coordinator, UF follow-up 1).

## Documentation

* The visual-workflow vignette shows the tools it describes: SurveyBuilder's
  Analyse mode with a plan open, SurveyStudio's Upload Responses screen and
  a result on its Run preview tab, the dashboard, and the RStudio Addins
  menu with the 4 surveyframe commands, each with alt text.
  The images are generated from the demo launchers.
* `amend_sframe()`'s help says how to change the wording on the welcome,
  consent and thank-you screens. That wording is inside both hashes, so on
  a published instrument it goes through a pipeline-tier amendment with
  `reason_code = "other"` and then `write_sframe()`. A host editing the
  JSON directly leaves a file `read_sframe()` refuses. The help also lists
  `references` among the fields the content hash leaves out.

## Export

* **Text-coded choices keep their labels in Stata.** Stata attaches value
  labels to numbers alone, so a choice set coded `a` and `b` with labels A
  and B read back from `sframe_export_labelled()` as A = 0 and B = 0. A
  `.dta` now holds such codes as 1, 2, 3 in the set's order, each with its
  label. A `.sav` keeps the text codes, which SPSS labels directly.
* **Names and labels fit SPSS and Stata.** `sframe_export_labelled()` failed
  on matrix row columns such as `session__Opening keynote` and on long MCDA
  pair names, and sent long labels to Stata uncut. Such names are now made
  valid for the format, with a number where 2 would match, and labels over
  the format's limit are cut. One message lists every change as old -> new,
  and the table is attached to the returned path as `attr(path, "renamed")`
  (D10, CX-18).

## The exported survey

* **A shared survey no longer carries the instrument's references, analysis
  plan or amendment history, or the answers to its attention checks.**
  `export_survey()` embedded the whole instrument in the page, so anyone given
  the link could read the research questions, hypotheses, references,
  amendment notes and authors from the page source. A bot or a respondent who
  opened the source could read every check's passing answer, and which items
  are reverse-keyed in which scale. The page now carries the title,
  description, choice sets, branching, the 7 display settings it reads, the
  item fields it draws and which items are checks. SurveyBuilder's Preview
  embeds the same fields.

* **The thank-you screen states delivery, and the message is only thanks.**
  The screen now opens with a status line the package writes, one for each
  outcome: recorded, sent but unconfirmed, not sent, or failed. The study's
  `render$thankyou$message` sits below it in every case except a failed send,
  so a debrief or contact details reach a Google Sheets respondent too. Before,
  the package's own text replaced the message there. The default message is now
  "Thank you for participating." because the old default said "recorded" over
  a survey with no collector. The `branded_survey` demo no longer claims its
  feedback was recorded. A preview export keeps the study's message too, so
  a researcher sees the text respondents will read, under the status line
  that says nothing was sent.
* **The Shiny surveys state delivery on their thank-you screen too.**
  `survey_module_server()` said "Your response has been recorded." and
  `render_survey()` said "Submitted successfully" whether or not anything
  stored the answers. A module with no `on_submit`, or `render_survey()` with
  `save_responses = "none"`, stores nothing. A status line now says what
  happened: recorded to the CSV, submitted to `on_submit`, or not saved. The
  study's message sits below it, and the module's default message is
  "Thank you for participating."
* **A sending screen while the answers are in flight.** The thank-you screen
  said the response had been recorded while it was still being sent.
* **Confirmed delivery for a host.** A page that defines
  `window.sframeSendResponse(row)`, returning a Promise, takes over the send.
  Resolving to `true` or `{confirmed: true}` shows the response as recorded,
  in place of the note that the page cannot confirm storage, which every
  respondent saw, even on a host that confirms.
* `render$thankyou$show_restart = FALSE` hides "Submit another response".
* **Drafts.** `render$save_draft = TRUE` keeps the answers in the browser as
  the respondent goes, so a closed tab can be resumed from the welcome screen.
  The draft is cleared once the response is submitted, and kept when delivery
  fails. SurveyBuilder's exported survey carries the same template.
* **A draft belongs to the whole instrument, and to a given consent.** The
  draft's key covers the instrument as exported, less its hash, so a changed
  choice set or consent text starts afresh. It covered the title, version and
  items alone. A draft records that consent was given, and resuming goes
  straight to the questions only then. Otherwise the welcome screen asks for
  consent first. Drafts held in browsers for a survey already in the field are
  dropped once it is exported again with this template.
* **A preview sends nothing to a host either.** `export_static_survey(preview
  = TRUE)` removed the endpoint and the redirect, but a page defining
  `window.sframeSendResponse()` still received the preview's answers while the
  screen said nothing was sent. A preview flag in the page now blocks every
  delivery path, the host's included.

## Charts

* **`render_result()` draws the chart in the palette you ask for.** It
  used the chart attached to the result whatever `palette` said. A palette
  given explicitly now rebuilds the chart with it. Left out, the attached
  chart is used as before (CX-19).
* **Charts fit the default 6.5 by 4 inch export.** Titles, subtitles,
  captions, long category labels and legends were clipped at the edges.
  A chart from the analysis plan now wraps them to the figure width, lays a
  long legend over as many rows as it needs and keeps a margin at every
  edge. A legend the chart hides stays hidden. The 4 regression diagnostic
  panels are fitted the same way, and each names the outcome by its label
  (CX-23).
* A chart from the analysis plan names each variable by its label in the
  instrument, as the tables beside it do. A regression on the scale `sat` was
  titled "Observed against fitted values for Sat" while its table read
  "Satisfaction". This covers the correlation, regression, group comparison,
  partial correlation and moderation charts, in `render_report()` and in
  SurveyStudio.
* **A group comparison chart labels its groups**, in the choice set's
  order, where it showed the stored codes ("in_person" beside a table
  reading "In person"). This covers the t-test, Mann-Whitney, one-way
  ANOVA, Kruskal-Wallis and ANCOVA charts. **A crosstab or Fisher chart
  titles its axes and legend with the items' labels**, where it used their
  ids. A sweep of every demo chart now finds no id or code where the
  instrument gives a label.

## SurveyBuilder

* **One preview.** The builder's Preview shows the deployable survey,
  the page `export_survey(preview = TRUE)` writes and SurveyStudio's
  Preview Survey screen shows. Answering, required checks and branching
  run as a respondent sees them, and nothing is collected. The builder drew
  its own copy of the layout, which ran none of them and could drift from
  the survey. Its Welcome, Survey and Thank You tabs go, since the survey
  shows its own welcome and thank-you pages.
* **The Plan editor has fields for the hypotheses.** Methods that test a
  hypothesis show optional "Null hypothesis (H0)" and "Alternative
  hypothesis (H1)" fields, with a method-appropriate example as placeholder
  text. Only what you write is saved, and the plan card shows it. The
  builder saved 2 fixed sentences, "No effect or association is present."
  and "An effect or association is present.", for every such block, and
  those load back as empty.
* **The decision rule and the interpretation are separate text boxes.**
  One box filled both fields. The Plan editor's box is labelled "Decision
  rule (declared now)" and saves the decision rule only. The report outline
  shows the rule read-only, with an "Interpretation" box that saves the
  interpretation only once results exist. An interpretation identical to
  the rule counts as unwritten, and a file holding only `interpretation`
  still opens with it as the rule.

* **Changed content of an opened file is recorded as an amendment, or saved
  as a new instrument.** The builder checked a file's hash when it opened
  and then forgot it, so an edited instrument saved as verified, with no
  amendment. It now keeps the title, version and content it opened. Saving
  changed content of a file that had a hash opens 1 dialog: record an
  amendment (reason, tier, deviation report for a design change, author,
  second sign-off and the version, with the next one suggested), save as a
  new instrument (a new title or version, the amendment log staying with the
  original), or cancel. The entry is built as `amend_sframe()` builds it,
  with the same content fingerprints, changed fields and tier rule, so the
  file reads back in R with its log verified and writes again with no flag.
  A file opened without a matching hash can only be saved as a new
  instrument.
* **`read_sframe()` checks an amendment log against the content.** A file's
  hash vouches for the file, not for whether its log describes the content.
  A log whose entries do not follow one another, or whose last entry ends at
  a different state, now reads with a warning of class
  `sframe_amendment_warning`.
* **A choice set can be declared ordered.** `sf_choices(ordered = TRUE)`
  marks options that run in a meaningful order, such as a frequency or an
  education level, and SurveyBuilder has the same switch in the choice set
  dialog and beside an item's choice set. A `single_choice` item on an
  ordered set is tagged ORD, ordinal, in SurveyBuilder and SurveyStudio, so
  it reaches the methods for ordered categories. Every `single_choice` item
  was tagged NOM before, the known limitation 0.4.3 shipped with. The field
  is written only when `TRUE`, so existing files keep their hashes.
* A plan block saved with the `outcome` role, which R accepts beside
  `dependent`, opens with that variable selected. Regression blocks opened
  with the first listed variable in its place. The builder reads every role
  alias R reads, and saves under its own role names.
* A mediation block written in R with `x`, `mediator` and `y` opens in the
  plan editor with those variables selected. The editor replaced `x` and `y`
  with the first listed variable and left Save disabled. R now holds one role
  alias table by method, inlined into the builder, and a test fails if the two
  differ. A required role with no variable chosen shows "Choose a variable"
  and keeps Save disabled, where it showed the first variable.
* The sidebar shows the instrument's title on first load. A title set by
  `launch_builder_demo()` read "Untitled Survey" until the first edit.
* The Outcome and other role dropdowns stay inside the Add or Edit Analysis
  Plan dialog when an item label is long. The role grid columns can now
  shrink, and each select fills its column.
* **SurveyBuilder keeps the amendment log.** Opening an amended `.sframe`
  file in the builder and saving it dropped its `amendments`, `designs` and
  `sframe_format` fields, so a disclosed revision vanished silently. The
  builder now carries every field it leaves unedited through to the next
  save.
* **Every file saved from SurveyBuilder carries `sframe_format`**, as
  `write_sframe()` writes it. sframe-schema's instrument profile requires
  the field, so each new file saved from the builder failed that schema.
* **Save settings writes only the fields you changed.** It wrote every
  General, Welcome and Thank You field from its input, so an absent author
  list became an empty string and absent screens took their default
  wording. On an amended instrument that was a content change nobody had
  made, and `write_sframe()` refused the file. Opening a file also added
  empty screen objects to it. An emptied author list or description is now
  saved as absent, as R writes it.
* **Settings saved on an instrument with an empty `render` are kept.** R
  writes an empty `render` as a JSON array, and the builder held it as one,
  so a theme or welcome screen saved there vanished from the saved file.
  All 19 demos with an empty `render` were affected.
* **Open asks before replacing unsaved changes**, and opens the file
  chooser at once when there are none. It replaced them silently. Opening
  a file also closes the inspector, which kept showing an item from the
  survey being replaced, and the status reads "Opened" until the next
  save. It read "Saved just now", which inside a host such as Ethos reads
  as saved in the host.
* The question editing area is a named, focusable region, so a keyboard
  user can reach and scroll it. At narrow widths it was a scroll region
  reachable by pointer alone.
* **SurveyBuilder's Survey settings dialog scrolls.** A tab taller than the
  dialog ran past its bottom edge, with its last controls out of reach. The
  dialog body now shrinks to fit and scrolls.

## SurveyStudio

* **1 design system for Studio and the builder.** Both apps take every
  colour, size and radius from 1 shared stylesheet of design tokens,
  `inst/builder/design_tokens.css`, which Studio links and the builder
  carries inline, so a builder copied on its own still opens. Studio's teal
  and the builder's blue become 1 primary colour, and the 2 dark sidebars
  1 navigation colour. The Explore charts take their colours from the same
  file.
* **3 button levels in both apps**: a filled primary, 40 px high and sized
  to its label, at most 1 per screen, panel or dialog, an outline
  secondary, 36 px high, and a text link for small actions. Shiny's own
  buttons and the builder's dialogs take the same levels. In the builder,
  the 2 add buttons on Settings' References tab and Export syntax become
  secondary, and the Open Collect and Open References links in Studio text
  links.
* **1 header row on Design and Plan.** The title (Design or Plan), the
  instrument's title and version and the save state ("Saved", "Unsaved
  changes") sit on the left, and undo, redo and Save to Studio at the far
  right. Inside Studio the builder's own bar is merged into this row. The
  standalone builder has the same row, with its title, version and save
  state on the left, its Build, Preview and Plan switch in the centre, and
  Save .sframe last on the right.
* **The builder's left panel has 1 filled button.** Until the survey's
  settings are saved once, it is Survey settings, then "+ Add question",
  whose menu now also holds Section break and Branching rule. An opened
  instrument counts as set up, and the empty question list points to
  Survey settings first until then. Survey settings is always a strong row at
  the top of the panel, with the line "Title, welcome and thank-you
  pages". Configure is a text link named "Answer sets, scales and
  checks". Both menus follow the menu button pattern: the arrow keys, Home
  and End move through them, and Escape closes them back to their button.
* **A guided start in the builder.** With no questions, the canvas shows 3
  steps, Survey settings, Add your first question and Save to Studio (Save
  .sframe on its own), each ticked once done, with the next step's button
  in its row. Once all 3 are done, the canvas names the next useful step:
  Plan when the survey has no analysis plan, otherwise another question.
  The empty question list no longer repeats the Survey settings and Open
  buttons.
* **The same rules on every Studio screen.** Explore's Overview, Items,
  Scales and Data tabs look like the Report screen's tabs, the open one
  underlined. A long value in a summary tile, such as the version or a
  date range, takes a smaller size and stays inside its tile. A disabled
  download keeps its button level and the hint beside it says why. The
  builder's Plan tabs take the same underlined style, in Plan the panel's
  Add question steps down to an outline beside + Add plan, and with no
  instrument open Design's head says "No changes" in place of "Saved".
* **Contrast on the final colours.** Every Studio screen, the builder in
  Studio and on its own, with its menus open, meets WCAG 2.2 AA. The
  builder's menu group headings were white at 30 percent, 2.41 to 1, and
  now take the panel's text colour.
* **Responses starts with the Google Sheet**, the planned route: the sheet
  card comes first with Read from Google Sheet as the screen's primary
  action, then the CSV file, then help for files from other tools. Without
  googlesheets4 the card stays first and says how to install it.
* **1 primary action per screen**, a full-size filled button from 1 shared
  level in `inst/builder/design_tokens.css`: Save to Studio on Design,
  now first in the builder's bar, Download survey on Collect, Load
  responses, Export report beside the Report title, Edit in Design, Add
  from BibTeX, and the next step on the screens that only show results.
  Every other action is an outline button or a link, and a disabled
  primary says why in a visible hint.
* **1 control per destination on each screen.** The Open card no longer
  links its version label and its status line to Amendments both, and the
  embedded builder shows none of the Open, Export survey, Build/Plan,
  Google Sheets or References controls that Studio's own screens hold.
* **Each screen is 1 panel with its title inside.** The title and its
  context line, such as Design's "Editing: <title> (<version>)", are 1
  compact row at the top of the screen, in place of a band above its cards.
* **1 Build and Plan control in Studio.** The sidebar's Design and Plan
  entries pick the builder's mode, and the builder inside Studio hides its
  own Build/Plan switch. The standalone SurveyBuilder keeps it.
* **The sidebar's groups fold.** Build, Collect, Analyse, Report and Record
  are buttons that fold their entries, all open at first. Studio remembers
  each choice in the browser, and the group holding the open screen always
  stays open, including when a link or the address opens a screen in a
  folded group.
* **Plain words first** in Studio and SurveyBuilder (UX-18). A label says
  what a control does, and the technical term follows as help: "Type of
  change" with the pipeline and design tiers explained, "Where is this
  source used?" for cited by, "R package that fits the model" for the
  output engine, "Web app address that receives the responses" for the
  collector endpoint, "Refuse a file with missing or unexpected columns" for
  the strict column check, and the manifest described as a list of every
  file with its checksum.
* **SurveyBuilder's Open Collect, Open References and Manage references open
  Studio's screens** when the builder runs inside Studio. Studio handles the
  builder's `goto` message for Collect and References.
* **Studio's long text fields take SurveyBuilder's format toolbar**: the
  Report's interpretation boxes and the amendment dialog's deviation report
  show it on focus and hide it on blur, insert Markdown, and cite through
  the same picker.
* **Studio fits a phone** (UX-01, UX-08). Below 800 px the sidebar becomes a
  drawer behind a labelled Menu button, which closes after a choice or on
  Escape, cards stack, and a wide table or code block scrolls inside its
  own region. At 390 px the sidebar took 240 px and pages ran to 1233 px.
* **The sidebar is a labelled navigation** (UX-16): a `nav` named "Studio
  screens", `aria-current="page"` on the open screen, and a fragment link
  for each screen, Plan included, so the browser's Back and Forward move
  between screens and an address ending `#quality` opens Quality.
* **The Open card's status says what it means** (UX-12). "Valid" is
  "Schema valid", the version and amendment count sit beside the integrity
  badge and link to Amendments, Draft links to Design, and a failed check
  names its remedy.
* **A gate replaces the screen it guards** (UX-13). When a screen's
  prerequisite is missing, such as an open instrument, its next-stage card
  takes the place of the screen's body, so References, Amendments and
  Report no longer show live editors under it. A gate that only warns, such
  as Preview's validation list, leaves the screen shown.
* **References are added in 1 place** (UX-03). The Report screen's Further
  references (BibTeX) box is gone. The interpretation boxes take the shared
  citation picker, which lists the instrument's references and the
  built-in method references as you type @, and the Configure tab links to
  References with "Manage references". The References screen offers a plan
  block's hypotheses and the study as targets once they are written.
* **A Reference style select on the Report screen's Configure tab**: APA 7,
  Chicago author-date, Harvard, IEEE and MLA, then "Other style (.csl
  file)", which shows the upload and a link to zotero.org/styles. The
  choice reaches `render_report(csl = )`, so the source folder holds the
  style's file, such as `harvard.csl`. Without Quarto the select offers
  APA 7 only and says why. The citation style upload left More options.
* **The Report screen makes 2 products** (UX-20). Export report writes the
  finished report in HTML or PDF, and in Word or OpenDocument when Quarto is
  found. Reproduce downloads the reproducible source, the `.qmd` folder of
  `render_report(format = "qmd")` as 1 zip, for RStudio or Positron. The
  separate analysis notebook card is gone, and without Quarto the engine
  line names the remedy instead of offering a third engine.
* **The Report screen has 4 tabs**, Interpret, Configure, Export report and
  Reproduce, in place of 1 long page of 5 jobs (UX-07). A choice made in 1
  tab stays when you switch, the arrow keys move along the tabs, and the
  `.sframe` download is "Download copy" beside the screen title.
* **Analyse runs the declared plan** (UX-02). It shows the plan read-only,
  with the method, variables, declared hypotheses and a cross-tab's
  percentages, and runs it. Its Plan and Report outline tabs, its plan
  editor and its model builder are gone: "Change plan" opens Plan, the only
  plan editor. A plan changed once responses are loaded opens the amendment
  dialog as a design amendment, with the changed blocks in the deviation
  report, so the report's amendment list discloses them.
* **Studio finds Quarto where `render_report()` does**, including the copy
  bundled with RStudio or Positron, and its status line gives the version
  and where it was found, such as "Quarto 1.8.24, found on the PATH".
  Without Quarto the line names the remedy. It asked `Sys.which("quarto")`
  and said Quarto was not found where the report would use it.
* **Drop from scale and Put back under a result.** Under a reliability,
  item, EFA readiness, EFA, CFA or PLS result, each item past the usual
  cut-offs has "Drop from scale", which opens the amendment dialog with the
  reason from `sframe_item_flags()` filled in, records the drop and runs the
  plan again. An item dropped in the session has "Put back", a second
  amendment that restores the item's place in its scales and models with its
  reverse key, so the history keeps both. After the file is opened again the
  item goes back through Design.
* **Quality and Responses record a change to the data.** "Record as
  amendment" opens the same dialog for a bot removal or a data correction,
  as a pipeline amendment.
* **The Amendments screen gives the whole history**, oldest first: date,
  tier, reason, what changed, the deviation report and the content hashes
  before and after. The status line, the Amendments screen and the Open
  card give the version and the count, such as "1.1.0, 2 amendments".
* **1 amendment dialog, and "Edit in Design" on Amendments.** A Design save
  that changes an instrument with a history (read from a file, or amended)
  opens 1 dialog. It shows what the change touches (the fields, the scales
  whose scoring changes, the models and plan blocks), the reason, the tier,
  a deviation report for a design change, and the version suggested for each
  tier with the reason, then records the amendment with `amend_sframe()`,
  saves a new instrument, or cancels. The builder gets the recorded log and
  version back. The Amendments screen says "Edit in Design" in place of
  "edit it in SurveyBuilder and upload the after file", and the upload is
  folded under "Import an externally revised version", which opens the same
  dialog. Its own reason and tier form is gone.
* **The sidebar follows the study.** Open Instrument comes first, then 5
  groups under headings: Build (Design, Plan, Preview), Collect (Collect,
  Responses), Analyse (Quality, Explore, Reliability, Analyse), Report, and
  Record (References, Amendments). Plan opens Design with SurveyBuilder in its
  Plan mode, and Design opens it in Build mode. 6 screens have shorter names:
  Preview Survey is Preview, Upload Responses is Responses, Quality Dashboard
  is Quality, Dashboard is Explore, Analysis Plan is Analyse and Export is
  Report. The screen names `launch_studio(screen =)` takes are unchanged.

* **Studio runs inside the package.** `launch_studio()` now sources the
  app into an environment under the surveyframe namespace, as
  `launch_dashboard()` does, so the app calls internal helpers directly.
  The 2 helpers copied into the app when the installed Studio failed to
  start are gone.

* **A screen picked during start-up stays open.** Studio switched to its
  launch screen after the first page update, so a click made before that
  was undone. The launch screen now applies only if nothing was picked.

* **The Dashboard screen has filters.** Every text, factor or logical
  question with 2 to 12 values gets a filter named by its question, with
  its choice labels, plus a date range on `submitted_at` or `started_at`.
  The 4 views and the CSV download use the filtered rows, and the Overview
  shows a "Filtered responses" tile. The Quality screen still describes
  every response.

* **Studio has a Design screen.** It holds the SurveyBuilder, which opens
  the instrument Studio has open. Its Save button reads "Save to Studio",
  and a save becomes Studio's open instrument, read and checked as an
  opened file is. Studio and the builder each take a message only from the
  other window, on the same origin. With no instrument, `launch_studio()`
  and the Addin open on Design. `screen = "build"` names `"design"` in its
  error.
  An instrument changed with no amendment recorded does not open in
  Design, and the screen says why. Rewriting it as a new instrument would
  have dropped its amendment log, and a save would have replaced Studio's
  instrument with one that has no history.
  A save keeps the loaded responses while each item keeps its id, its
  type, its choice codes and, for a matrix, its rows, as after a label,
  wording, help text or branding edit. When one of those changes, the
  responses are cleared, and a message names what changed.

* **The builder on the Design screen is part of Studio.** It drops its
  SurveyBuilder name, its Preview mode and its Export survey button, which
  Studio's Preview Survey and Collect screens do. Its save state reads
  "Saved" or "Unsaved changes", and Studio's line above it reads
  "Editing: <title> (<version>)", with a reminder to save only while there
  are unsaved changes. The builder's Analyse mode is now Plan, in Studio
  and on its own, after the stages Design, Plan, Preview and Collect.

* **The Open Instrument screen says where the instrument came from.** It
  reads "Loaded from R", "File checked: hash verified" or "Saved from
  Design: hash verified", or names the failed check. A Design save showed
  "Not verified", though its hash was checked. The screen no longer sends
  you to the SurveyBuilder to design, and the plan's count is labelled
  "Research questions" on the Open and Analysis screens.

* **The sidebar shows 1 selected screen.** The entry under the mouse took
  the selected look, so with Design open, Design and the entry the mouse
  rested on both looked selected. Hover is now a lighter tint.

* **Every empty Studio screen names the next stage.** With no instrument,
  each screen past Design and Open Instrument links to those 2. With no
  responses, Quality, Reliability and the Dashboard link to Collect and
  Upload Responses. Preview with no questions sent you to
  `launch_builder()` and back through a file, where Design now does it.

* **Studio has a Collect screen.** It downloads the Google Sheets Apps
  Script collector for a sheet you name, with the steps to deploy it, and
  the survey file, sending to the collector URL you give. The last step
  opens the Upload Responses screen, with that sheet ready to read. The
  Export screen pointed to the SurveyBuilder for both files.

* **The Export screen takes the report options, and is shorter.** It sets
  the report's title, authors, format (HTML or PDF), whether each result
  shows its R code, figure size, resolution and format, a citation style,
  and further references as BibTeX, as `render_report()` takes them. A line
  says whether Quarto or the built-in engine will write the report, and
  what the built-in one cannot do. Each research question folds to its
  heading and question, so the screen for the `input_types` demo is 5,302
  px tall in place of 43,730. The analysis notebook downloads as 1 zip in
  place of 3 files.

* **A free-text question no longer becomes a Dashboard filter.** A text or
  textarea question with 12 or fewer distinct answers was offered as a
  filter, as `open_comment` in the `input_types` demo was.

* **The SurveyStudio guide shows Studio's Dashboard screen**, with its
  filters, in place of the retired dashboard app.

* **`data-raw/rename_0.4.3.R` writes the 2 dashboard wrappers.**
  `launch_dashboard()` and `launch_dashboard_demo()` were added to
  `R/superseded.R` by hand, so a rerun of the generator dropped them. A test
  reruns it on a copy of the source and expects no file to change.

* **`launch_dashboard()` opens Studio's Dashboard screen.** It and
  `launch_dashboard_demo()` are superseded by `launch_studio(screen =
  "dashboard")`, and the separate dashboard app is removed.

* **Each screen draws when it is opened.** Studio kept 28 outputs on every
  screen computing from start-up, because its screens are hidden with CSS
  and Shiny was not told when one became visible. The screen switch now
  tells Shiny, so only the open screen's outputs are computed. A browser
  test opens every screen and checks that it draws.
* **The Analysis Plan screen has fields for the hypotheses.** Methods that
  test a hypothesis show optional "Null hypothesis (H0)" and "Alternative
  hypothesis (H1)" fields, with a method-appropriate example as placeholder
  text. Only what you write is saved. Studio saved 2 fixed sentences, "No
  effect or association is present." and "An effect or association is
  present.", for every such block, and those load back as empty.
* **The decision rule is no longer copied into the interpretation.** The
  plan editor box is labelled "Decision rule (declared now)" and saves the
  decision rule only. Saving an edited block keeps the interpretation it
  already had, and an interpretation identical to the decision rule counts
  as unwritten.
* **Saving an opened file untouched keeps its content hash.** Studio rebuilt
  the instrument metadata without the file's creation time, so the saved
  draft carried the time of the save. Any file opened and saved unchanged
  then failed its hash check and Studio asked to save it as a new
  instrument. The creation time now carries over from the file.

* **SurveyStudio has a References screen.** It lists the works the open
  instrument cites, adds more from pasted BibTeX with where the instrument
  cites each one, and removes them. Changes apply to the open instrument at
  once, need no amendment, and travel in the exported `.sframe` file.
  `launch_studio(screen = "references")` opens on it.
* **SurveyStudio keeps an instrument's references.** Its rebuild of the
  open instrument had no place for them, so they were dropped as soon as a
  file opened, and lost from anything exported.
* **The dashboard's filters are named by their questions** and offer the
  choice labels. They showed the item id, such as `visit_type`, and the
  stored codes. Each label is now tied to its control.
* **Run results on the Analysis Plan screen take the full width.** Each
  result card sat inside the middle third of the screen, about 230 px wide,
  so a result table printed "120" one digit per line and cut off its p
  column. The cards now sit in a full-width row below the 3 columns on the
  Run preview tab.
* The Quality Dashboard says when the duplicate check needs an id column, where it
  printed "NA duplicate response row(s) detected". It now uses a
  `respondent_id` column for the check by default.
* The Saved analysis plans table keeps short ids such as "RQ1" on one line
  and scrolls sideways on a narrow screen.
* A result card is headed "RQ 4" when its block id only repeats the number.
  It read "RQ 4: RQ4". A block id that says something more, such as "H2a",
  still shows beside the number.
* Studio's page declares its language as English (`lang="en"`), so a
  screen reader reads it with English pronunciation (WCAG 3.1.1, Codex
  P1-06).
* The sidebar's 5 group headings (Build, Collect, Analyse, Report,
  Record) and every fold, such as Amendments' "Import an externally
  revised version", are at least 24 px tall, the WCAG 2.5.8 target size.
  The headings were 15.7 px and the import fold 20 px (Codex P1-07).
* Studio and the builder count in words, "1 respondent" and "0
  respondents", where Quality printed "0 respondent(s) (0.0%) flagged as
  too fast" and "0 duplicate response row(s) detected". The same holds for
  a role's maximum on the Plan screens and the builder's counts of scales,
  constructs, paths, research questions and report sections (Codex P1-08).
* **Open Instrument's status comes from `validate_sframe()` run on the open
  instrument.** It read the stored `meta$validated`, so the valid
  `two_group` demo showed "Draft" and "Status: fix in Design" with no
  reason. The stored flag is a cache that Studio never trusts. The status
  reads "Schema valid", or "Fix in Design" with the number of problems and
  the first one named. With nothing open, the sidebar says "No instrument
  open", where it said "Draft needs fixes" (Codex P1-09).
* With no instrument open, the 9 screens from Collect to Amendments offer
  Open Instrument as the filled primary button and Design as the secondary
  one beside it, where both were outlined and neither stood out as the next
  step (Codex P1-10).
* With an instrument open and no responses, Quality, Reliability and the
  Dashboard offer Collect as the filled primary button and Responses as the
  secondary one beside it, where both were outlined (UF follow-up 2).
* A table wider than its card, such as Analyse's declared plan at 390 px,
  scrolls inside a region a keyboard can focus and a screen reader names,
  "Declared plan" or "RQ 1 result table". The table itself was the scroll
  box, with nothing in it to focus, so a keyboard could not scroll it
  (WCAG 2.1.1, Codex P1-12).
* The builder's question rows are list items in a list, and the question
  open for editing is marked `aria-current`. Each row was a focusable
  listbox option holding its own Move, Duplicate and Delete buttons, which
  an option hides from assistive technology (WCAG 4.1.2, Codex P1-11).
  Enter, Space, the arrow keys and Alt with an arrow work as before.

## Demos

* **Every demo has welcome, consent and thank-you screens.** 19 of the 22
  shipped with none, so a respondent met the questions with no consent step.
  They now carry plain screens in the default look, consent required, and
  `branded = TRUE` still replaces the whole block. `instrument_revision` is
  rebuilt on the updated `first_survey`, and the learn-by-example screenshots
  are recaptured.
* `sframe_demo_branding()` prints each setting as a respondent meets it,
  with a pointer to `preview_demo()`. It printed a raw nested list, which
  read as a failed demo. It returns a list of class `sframe_branding`, and
  `sf_instrument()` stores it as a plain list.
* `sframe_demo("instrument_revision")` takes a further amendment. Its
  amendment log recorded hashes from code that predates the settled content
  hash, so `amend_sframe()` on it failed with "The amendment log is out of
  sequence at entry 2", and so did `write_sframe()` after any change. The
  demo is regenerated, its content unchanged, and a test now amends and
  writes every shipped demo.
* `preview_demo()` opens a branded demo as a respondent sees it in one line,
  in the browser or on SurveyStudio's preview screen. The start-up note now
  shows it.
* The reference results shipped with 6 demos are regenerated for the changes
  above: `first_survey`, `instrument_revision`, `verification`, `branching`,
  `conversational_branching` and `multi_response`.


# surveyframe 0.4.2

A defect-fix release. An external review of 0.4.1 found defects that
silently alter or lose data, and this release corrects them. Collection
defects come first, because an answer recorded wrongly is lost for good.
This section grows as each group of fixes lands.

## What you need to change

* **A Shiny-collected response now carries a `respondent_id`**, as the first
  column, holding a generated identifier such as `RK3P8QX2A`. The static
  survey has written one since the first release, so the two collection
  routes produced different column sets for the same instrument, leaving the
  duplicate check and a retry to work from whatever they could find.
  **If you are collecting to a CSV written by 0.4.1 or earlier**, that file
  predates the column: `render_survey()` keeps appending to it and says once
  that the response went in unidentified. Collect into a new file to record an
  identifier for every response. Anything reading these files by column
  position needs updating to read by name.
* **`survey_module_server()` returns a different response shape.** The
  response is now the collection row, as a list: `response_id`,
  `started_at`, `submitted_at`, then one element per response column, named
  as `read_responses()` expects. A multiple-choice question becomes one
  element per option holding `"1"` or `"0"`, and a matrix, ranking or
  decision question becomes one element per row, option, pair or criterion.
  Values are character. An item hidden by branching, or left unanswered, is
  `NA`. The module previously returned one raw input value per item, and
  lacked controls for matrix, ranking, rating and decision questions.
* **Untouched sliders, rankings and dates are now unanswered** in
  `render_survey()` and the survey module. A slider counts once the
  respondent moves it, and a ranking once it is reordered or confirmed with
  "Keep this order". Previously a slider stored its starting position, a
  ranking stored the declared order, and a date question in the module
  stored today's date, for anyone who moved past them.
* **`render_survey(save_responses = "csv")` refuses a response file written
  for different questions**, when the app starts and on each submission.
  Collect a changed instrument into a new file. A file with the same columns
  in another order is still accepted, and rows are aligned by column name.
* **Google Sheets collection now needs the Sheets advanced service.** The
  generated collector stores an answer through the Sheets API's `RAW` option,
  which is the documented way to store a value without the spreadsheet parsing
  it. Regenerate and redeploy the collector with `export_google_sheet()`, and
  in the Apps Script editor add Services > Google Sheets API with the
  identifier `Sheets`. **A collector lacking it refuses each response** and
  replies with an error, in place of storing an answer it would have to alter.
  Code that reads the sheet directly, bypassing `read_sheet_responses()`,
  should expect text cells where numbers appeared before.

* **Scale scores and reliability can change.** Re-run analyses of scales
  that reverse-code items, share items with other scales, or had an absent
  item column. Reverse coding now applies within the scale that declares it,
  a scale with an absent item column counts that item as unanswered, and
  report figures now show the scores `score_scales()` computes.
* **Some instruments that validated before are now rejected.** An item and a
  scale sharing an ID, an ID equal to a response column or to `respondent_id`,
  `response_id`, `started_at` or `submitted_at`, reverse coding for an item
  outside the scale declaring it, repeated scale items, a `min_valid` outside
  1 to the number of items, and weights that are zero, negative or infinite
  are all reported by `validate_sframe()`, and `sf_scale()` refuses the scale
  parameters directly. Rename or correct the declaration.
* **A reverse-coded item needs declared response bounds**: a numeric choice
  set, `slider_min` and `slider_max`, or a rating maximum. Scoring reports an
  error for a reversed item that has none.
* **A factor column is scored through its labels.** A factor whose labels are
  text is an error. Convert it to numeric codes first.

* **Some statistics change.** Re-run analyses using Cochran's Q with missing
  answers, ANCOVA, partial correlation, a Firth likelihood ratio, PLS-SEM
  constructs with non-consecutive indicators, or a Mann-Whitney or Wilcoxon
  signed-rank test. The rank tests now use the normal approximation without
  continuity correction for z, p, r and its interval alike, so their p
  values move slightly, and z is now signed by the direction of the
  difference.
* **Repeated-measures ANOVA now uses complete respondents.** A respondent
  missing any repeated measure is excluded as a unit before fitting the
  classical balanced model. Results report the retained `n` and
  `n_excluded_incomplete`. This replaces a singular fit on incomplete rows.
* **ANCOVA tables hold adjusted tests**, each term tested after all others,
  with columns `effect`, `df`, `sum_sq`, `mean_sq`, `F` and `p`.
* **`sample_size_plan()` now calculates power** for t tests, ANOVA and, with
  the new `f2`, regression. The new `d` and `f` arguments give the expected
  effect, and a medium effect is assumed, with a warning, when they are
  left out. Estimates now depend on `alpha` and `power`.
* **`run_analysis_plan()` refuses repeated block IDs** and gains `strict`.
  Its results carry a `status` attribute counting failed blocks, so check
  it, or set `strict = TRUE`, before treating a returned object as success.
* **Bootstrap intervals can be withheld.** `bootstrap_ci()`, `cohens_d_ci()`,
  `cramers_v_ci()` and `eta_sq_ci()` return `NA` bounds with a `reason`
  attribute when fewer than 90% of resamples give a value or all give the
  same value, and every result records its resample counts.

* **Decision rankings can change.** Re-run TOPSIS, VIKOR, MOORA, SMART,
  WASPAS, PROMETHEE and ELECTRE analyses whose weights or criterion types
  were named in a different order from the performance matrix, AHP and ANP
  analyses given a data frame, and aggregations of judgement matrices named
  in different orders. Weights, criterion types and judgement matrices are
  now matched by criterion name.
* **Some decision inputs that ran before are now refused**: weights naming
  different criteria from the matrix, supplied AHP matrices that are not
  positive, unit-diagonal and reciprocal, WASPAS values of zero or below,
  infinite values, a VIKOR `v` or WASPAS `lambda` outside 0 to 1, ELECTRE
  cutoffs outside 0 to 1, and PROMETHEE thresholds that are negative or out
  of order. ANP refuses a reducible network, and DEMATEL a matrix whose total
  relation does not exist.
* **ELECTRE's kernel follows Roy's definition**, so it can hold more
  alternatives than before, and is reported as undefined when the
  outranking relation has a cycle.
* **`sensitivity_analysis()` results gain `n_perturbations`, `n_effective`
  and `n_failed`**, and `stable` is `FALSE` when no perturbation moved the
  weights. A requested sensitivity run that could not be made is recorded
  in the result's `sensitivity_error`.

* **`write_sframe()` refuses an undisclosed revision.** An instrument read
  with `read_sframe()` and then changed must record the change with
  `amend_sframe()` before it is written, and its amendment log must stay
  complete and in order. To publish changed content as a separate instrument,
  clear its amendment log and pass `new_instrument = TRUE`. SurveyStudio
  offers the same choice when exporting an edited file.
* **`amend_sframe()` sets the tier from what changed.** An amendment that
  changes the analysis plan, a model or a conjoint design is design tier and
  needs a `deviation_report`, whatever `reason_code` or `tier` says.
* **`.sframe` files write one-member collections as arrays**, as the
  published instrument profile and the builder already did. Reading an older
  file and writing it again gives it a new hash where it held such a
  collection. Older files still read and verify as they are.
* **`read_responses()` reads a CSV file as text** and converts only columns
  of items with numeric responses. Identifiers such as `001` and metadata
  columns now arrive as text, and numeric answers as doubles. A response file
  with 2 columns of the same name is refused.
* **`link_git_commit()` gains `path` and returns `verified`**, which is `TRUE`
  only when the instrument matches that file as committed. `linked` alone
  confirms a repository and a commit.
* **Some shipped demo results changed** to match the corrected statistics:
  `likert_scale`, `two_group`, `paired`, `multi_group`, `sem_pls`,
  `mcdm_choice` and `small_sample`.

## Collection fixes

* **The Shiny survey erased every answer.** In `render_survey()`, each answer
  re-drew the survey page, and the re-drawn questions reported themselves
  empty, so every answer was wiped about a second after it was given. A
  submitted response came back blank. This affected every standard-mode
  survey run with `render_survey()` in 0.4.1 and earlier. Answers now stay
  put, and the page stays as it is when a question is
  answered.
* **The Google Sheets collector could turn an answer into a formula.** An
  answer beginning with `=` was evaluated by the spreadsheet, so `=1+1` was
  stored as `2`, and a code such as `007` lost its leading zeros. A stored
  answer is now written through the Sheets API's `RAW` option, which stores it
  as submitted. A deployment lacking that option refuses the response and says
  so, in place of altering it. The same fix applies to collectors generated
  from the survey builder. See the setup note above.
* **The exported survey said a response had been recorded when it could not
  know.** The page posts with `no-cors`, which leaves the collector's reply
  unreadable, so the browser can establish that a request left and nothing
  further. The thank-you screen claimed the response had been recorded, hid the
  download, offered a restart that discarded the page's only copy, and could
  auto-redirect away from it. It now reports that the answers were sent and
  that receipt is unconfirmed, keeps the download available, withholds the
  restart that would clear the response, and leaves any redirect for the
  participant to choose.
* **A custom thank-you message no longer shows on a survey with a collector.**
  A message set through `render$thankyou$message` is fixed text, written before
  anyone knew how delivery would go, so a wording such as "your response has
  been recorded" put a claim on screen beside the page's own statement that
  receipt was unconfirmed. The package's own status is shown instead. A custom message still
  shows on a download-only survey, where nothing is being claimed about a
  collector. Put debrief text, contact details or payment instructions on a
  final display item or in the redirect target, where they always reach the
  participant.
* **The exported survey changed typed numbers.** Clearing a number field with
  a minimum wrote the minimum in, a number outside the range was replaced
  with the nearest limit, and in a points allocation `2.5` became `25`. What
  the respondent types is now kept, and the survey asks for a correction.
* **An option coded 0 was recorded as a blank** in the exported survey, so
  a respondent choosing it on a required question was blocked from
  continuing, and 0 looked identical to a blank. Affected 0/1 codings and 0 to 10
  scales.
* **A ranking could show one order and submit another** in the exported
  survey after dragging, and an untouched ranking was submitted as if the
  respondent had chosen the order shown.
* **Shiny matrix and ranking questions showed codes in place of labels.** A
  five-point agreement scale appeared as `1 2 3 4 5`. Shiny rankings also
  stored labels, so every rank came out empty wherever labels and codes
  differed.
* **Shiny rankings needed a mouse.** Each option now
  has move up and move down buttons, and the new position is announced.
* **Shiny decision questions started with an answer selected**, "Equally
  important" or "No influence", and points allocations started at 0, so an
  untouched question submitted an invented judgement. They
  now start empty. Every Shiny date question was also pre-filled with
  today's date, and now starts empty.
* **Appending to a Shiny response file ignored its header**, so a changed
  instrument wrote answers under another question's heading. An existing
  empty file also received headerless rows.
* **The survey module lacked 5 item types.** Matrix, rating,
  ranking, pairwise comparison and criteria weight showed only a
  placeholder, and a required one made the survey impossible to finish. The
  module now uses the same questions as `render_survey()`.
* **The survey module submitted answers the respondent had removed.** A
  cleared answer, and an answer to a question branching later hid, were both
  submitted. A multiple-choice answer lost all but its first selection when
  the page was revisited.
* **A failed save in the survey module showed the thank-you screen.** The
  survey was marked complete before `on_submit` ran, and an error there
  ended the session. The respondent now sees a message, stays on the page
  and can try again.
* Changing a reactive instrument now resets the survey module, as its help
  said it did, and starts every answer blank. Moving between pages
  scrolls the module into view, where it scrolled the whole host page.
* **The static survey said a response had been recorded before it knew.** A
  failed send was discarded and the thank-you screen appeared anyway, and a
  configured redirect then carried the participant away with the answers in
  nobody's hands. A failure now says so, keeps the CSV download reachable,
  offers a retry, and withholds the redirect. The submission is a `no-cors`
  POST, so the collector's reply is unreadable and acceptance cannot be
  confirmed from the page. The screen claims only that the request was sent.
* **A completed comparison or points allocation counted as unanswered** in
  the progress display, because progress read the question's own answer
  where these types store one answer per pair or per criterion. Progress and
  the required-question check now share one rule.
* **A rating left the question that depends on it hidden** until another
  control was touched, while the required check still demanded an answer to
  it.
* **A comparison answered on a phone could show the wrong selection on a
  wider screen**, and the reverse. Each question renders a button strip and
  a dropdown, shown by screen width, and each recorded the answer while
  leaving the other as it was. The stored judgement was always the one given.
* **Long rating scales now stack on a phone.** An 11-point scale needed 550
  pixels, so a participant on a 390-pixel screen saw part of it with both
  ends off screen. Below 600 pixels each point becomes a full-width row.
* **Choice groups, rating scales and validation errors now read correctly to
  a screen reader.** A group carries its question as its name, each rating
  star reports whether it is the one chosen, and an error is announced with
  the control that has it. Validation and a page change move focus to the
  task instead of only scrolling.

* **A multi-select answer failed a branching rule that allowed any of its
  options.** Selecting two options stored them together, and the static
  survey compared the pair as one value, so a rule showing a follow-up for
  either option stayed closed. Any selected option the rule allows now
  satisfies it, which is what the Shiny survey already did.
* **A second branching rule on the same question replaced the first** in the
  Shiny survey, so a question gated on two conditions ran on one. Every rule
  is kept and they combine, and a question controlled by one that is itself
  hidden now counts as unanswered, so a stale answer behind a closed branch
  keeps the questions below it closed too. The static survey already worked this way.
* **One-question-at-a-time mode ignored branching**, so a participant could
  be required to answer a question the rules exclude, which was then blanked
  on submission. Navigation follows the same visible sequence the rest of
  the survey uses.
* **A failed callback after a saved response invited a duplicate.** The save
  and the `on_submit` callback shared one error handler, so a callback
  failure reported that nothing was saved and submitting again wrote the
  answers a second time. The two steps are tracked separately, a retry
  repeats only what failed, and the two failures now read differently.

## Researcher interface fixes

* **SurveyStudio's preview could send test answers to the live collector.**
  It exported the real instrument and the export fell back to the
  instrument's configured Google Sheets endpoint, so a test response could
  land in a running study's sheet beside real participants'. The preview now
  exports with `preview = TRUE`, a new `export_static_survey()` argument that
  removes the collector and the completion redirect. **If you previewed a
  configured instrument in Studio on 0.4.1 or earlier, check the collecting
  sheet for test rows.**
* **The SurveyBuilder question list can be worked from the keyboard.**
  A question row takes focus, opens on Enter or Space, and moves with Alt and
  an arrow key, and named move-up and move-down buttons sit beside duplicate
  and delete. Ordering was previously drag-only.
* **An autosaved builder session is offered however old it is.** Recovery
  refused anything older than two hours while the session sat in storage, so
  returning the next day showed an empty builder. The banner reports the age
  and clears the session only when dismissed. Where the browser refuses to
  store anything, the builder now says so, where it used to appear to save.
* Opening a builder dialog moves focus into it, and closing one returns focus
  where it was.
* **The builder's Preview is labelled a layout preview**, which is what it
  is: it shows wording, order and branding and leaves out answering, required
  checks and branching. Export the survey, or use Studio's preview, to test
  the respondent's path.
* **The RStudio add-ins are renamed after what they do**, all under a
  `surveyframe:` prefix: Design an instrument, Open analysis workspace,
  Analyse an existing instrument, and Insert starter instrument.
  SurveyBuilder was described as a Shiny app, and it is a client-side HTML
  page.
* **"Analyse an existing instrument", formerly "Open Dashboard", opens
  SurveyStudio on Upload Responses** with the chosen instrument loaded, ready
  for a response file. It used to open an empty dashboard.
* **Every add-in stops with one message saying what to do** when RStudio is
  closed, the console has focus during an insert, the file dialog fails, or
  the chosen `.sframe` fails to load. It used to handle a missing rstudioapi
  alone. The exported launchers keep raising their errors.
* The starter instrument keeps its validation result as `validation`, and
  ends with a commented `write_sframe()` line for saving it.
* **`library(surveyframe)` now says where to start.** In an interactive
  session it prints a short note: 3 commands that load a branded demo and
  show it as a respondent sees it and inside SurveyStudio, the functions to
  start your own study with, `citation("surveyframe")`, and the website.
  Scripts, Quarto renders and `R CMD check` stay silent, and
  `suppressPackageStartupMessages()` removes it.
* SurveyStudio's preview points at the builder, where it used to name a
  "Build Survey" screen of its own.

## Scoring fixes

* **A scale could overwrite a question's answers.** A scale's score is stored
  in a column named by its ID, and an item and a scale were allowed the same
  ID, so `score_scales()` replaced the item's answers with the score, and an
  analysis of that item read the score. Shared names are now rejected at
  validation, and `score_scales()` refuses to overwrite data.
* **One scale could reverse another scale's item.** A scale listing an item in
  `reverse_items` reversed it everywhere, which changed the scores and the
  alpha of any other scale using that item.
* **Reports published a different scale score from the instrument's.** The
  report figures and the Quarto report template took a plain row mean,
  ignoring the declared method, reverse coding, weights and `min_valid`, so a
  declared sum of 2 and 4 was shown as 3.
* **A missing item column lowered the scoring threshold.** With `min_valid =
  NULL`, meaning every item, a 3-item scale with 1 absent column was scored on
  2 items. The absent item now counts as unanswered, with a warning.
* **Reversal used the sample's own range** for an item with no numeric choice
  set, so the same answer received a different reversed value as respondents
  were added. Slider and rating items now reverse on their declared limits.
* **A factor was scored on its level positions**, so a factor holding 10 and
  20 was scored as 1 and 2.
* **`item_report()` diagnostics now match the scale's scoring.** Item-rest
  correlations use the reversed orientation, where a reverse-keyed item used
  to come out strongly negative beside a high alpha. They use respondents who
  answered every item, where a missing item counted as 0. Floor and ceiling
  use the item's declared lowest and highest response, where they used the
  sample's extremes, and are `NA` for an item that declares no bounds.
* `sf_scale()` now checks its parameters, and refuses a constructed item
  passed inside a scale's `items`, which was silently dropped from the
  instrument.

## Statistics fixes

* **Cochran's Q counted a missing answer as an observed 0**, changing both Q
  and the analysed N, and read any unrecognised code as 0. Missing answers
  now remove the respondent, and codes other than 1/0, TRUE/FALSE and yes/no
  are reported.
* **PLS-SEM syntax could add an indicator the model left out.** A construct
  over `Q1` and `Q3` was written as the range `Q1` to `Q3`, adding `Q2`.
* **Indirect effects could use a path the model never declared**, and a
  model with parallel mediators wrote its total effect twice, each copy
  holding one route. Both are now caught or corrected.
* **ANCOVA reported an unadjusted group test as adjusted.** The group was
  tested before the covariates. The slope check also left out every
  covariate after the first.
* **Partial correlation p values used the wrong degrees of freedom**, and
  partial Spearman ranked the residuals where it must rank the variables.
* **`sample_size_plan()` returned 64 or 50 per group for t tests and ANOVA**
  whatever alpha and power were requested, while printing both.
* **The Firth likelihood-ratio statistic was half its true value.**
* **Two-way ANOVA gave the residual row a partial eta squared of 0.5.**
* **Results tables rounded p values to 2 decimals**, showing .004 as 0.
  They now show 3 decimals, or <.001.
* **Every `render_results()` table put a whole row in a single cell**,
  headers included. Each value now has its own cell.
* **Rank-test effect sizes and their intervals described different
  statistics.** A signed-rank r also divided by pairs the test had dropped.
* **Bootstrap intervals hid failed resamples**, and a collapsed distribution
  gave a zero-width interval. A Kruskal-Wallis resample with every value
  tied gave an effect of 0.
* **An analysis plan whose blocks all failed returned as if it had
  succeeded**, and a scale-scoring failure before analysis went unrecorded.
* **The t test ignored `var_equal`**, and t tests and one-way ANOVA judged
  significance at .05 whatever `alpha` the block declared. Options a method
  never reads are now listed in `options_ignored`.
* **Reliability, item and EFA blocks analysed every scale** whatever the
  block selected. The quality block ran its duplicate check only when given
  a respondent ID it was never passed, and reported 0 duplicates. It now
  reads the collected ID column, and says when a check did not run.
* **Statistics read a factor on its level positions**, and linear regression
  turned a text predictor into a number. Factors are read through their
  labels, and text predictors stay categorical.

## Decision analysis fixes

* **Weights could be applied to the wrong criteria.** They were matched to
  the performance matrix by count and applied by position, so a weight item
  listing quality before price gave price the weight meant for quality.
  Rated items paired with a differently named weight item still pair in
  declared order, and the result now lists each pairing.
* **Aggregating judgements combined them by position**, so the same
  judgement from 2 respondents whose matrices listed criteria in different
  orders averaged to indifference.
* **AHP and ANP read a data-frame matrix transposed**, reversing every
  judgement while keeping perfect consistency.
* **Factor judgements were read as level positions**, so a judgement of -9
  became 1.
* **A supplied AHP matrix got a consistency verdict without being
  reciprocal**, so rows (1, 9) and (9, 1) received a consistency ratio of 0.
* **Unavailable consistency ratios**, past 10 criteria, produced infinite
  and undefined summaries, and filtering called them too inconsistent.
* **ANP could report a limit that does not exist.** A periodic network now
  gets its stationary priorities, and a reducible one is refused.
* **DEMATEL could fail on an undefined inverse**, and named the first
  criterion the strongest cause when every net relation was 0. It now
  explains the undefined case and names a cause only when one exists.
* **WASPAS reversed its normalisation for negative values.**
* **ELECTRE's kernel could exclude an alternative nothing in it outranked.**
* **ELECTRE sensitivity re-ranked at the default cutoffs** in place of the
  cutoffs the result used.
* **Sensitivity called a ranking stable when no weight had moved**, as
  happens with weights such as (1, 0).
* **Conjoint balance rewarded leaving out an attribute level**, scoring a
  design that never showed one as perfectly balanced. Balance now counts
  every declared level, and the design lists any level it never shows.

## Text analysis fixes

* **Words with accents and text in other scripts were being cut up.** The
  tokeniser kept ASCII letters alone, so "café" was counted as "caf",
  "naïve" became two fragments, and a response written in a non-Latin script
  could come out empty. Every Unicode letter and digit is now kept, in term
  frequency, n-grams, co-occurrence, topic models and sentiment.
  **Term counts and topic models over non-English text will change.**
* **N-grams reported phrases nobody wrote.** Stop words were removed before
  the window slid over what was left, so "clean but not comfortable" produced
  the bigram "clean comfortable". An n-gram is now built only from words that
  were next to each other, which is what makes it a phrase a respondent used.
  **Bigram and trigram tables will change, and some will be smaller.**
* **A respondent with no group value was counted into every group** in
  grouped sentiment. With twelve responses per group, both groups reported
  thirteen, the extra one scored as neutral. Grouped term frequency had the
  same mismatch between the text and the rows it came from.
* **A response of punctuation alone counted as a usable response.** Rows were
  chosen before punctuation and numbers were stripped, so such a response
  survived as an empty string, counted towards the minimum corpus, and scored
  as a neutral observation in sentiment.
* **`term_context(window = 0)` copied the match into its own context.** A zero
  window now gives empty context, and a negative one is refused, as is
  `max_matches` below 1 and an n-gram size below 2.

## New: the R code behind each result

* **A report now shows the statistical call that produced each number.** Every
  result carries a folded "Show R code" block with the call, the variables and
  the options resolved, so a reader sees `cor.test(x, y, method = "pearson")`
  where the wrapper call was all that showed before. Both
  report engines show it, and `render_report(show_code = FALSE)` leaves it
  out.
* **`analysis_syntax()` returns that code**, for one result or a whole set.
  `header = TRUE` prepends the lines that load the instrument, read the
  responses and score the scales, giving a script that runs on its own.
* The code is built from the same resolved specification the analysis ran, and
  the package's tests run the generated code and compare its statistic and p
  against the package's own result. Where a method falls outside its coverage
  the block is omitted, which keeps the report honest about what it can show. The model families already carried their
  syntax, through `cfa_syntax()` and its neighbours.

## Figure fixes

* **Grouped rating charts drew two segments over each other.** The negative
  block started at zero while the neutral block straddled zero, so with five
  equally frequent options ten percentage points of the bar were drawn twice
  and the bar was ten points short. This affected the matrix and scale charts
  in every report. The single-item chart was always correct.
* **A repeated-measures figure described more respondents than its test.** The
  test drops anyone missing a measure, where the figure dropped missing
  values measure by measure, so an excluded respondent could move the plotted
  medians. The figure now uses the same respondents and says how many.
* **A Q-Q plot compared raw values against the wrong line.** The reference was
  y = x, so a normal variable with a mean of 100 looked severely non-normal.
  The line now follows the sample's own quartiles.
* **A network figure renumbered its clusters.** Clusters were relabelled by
  size while the legend said "Cluster", so the cluster a table called 2 could
  appear as Cluster 1. The figure now uses the same numbers as the table.

## Report fixes

* **A report could not render into a folder whose name contains a space.**
  The Quarto renderer's arguments were passed to the shell unquoted, so such
  a path split into several arguments and the render failed, falling back to
  the built-in HTML engine with no explanation. Each argument is now quoted.
* **Distributions disappeared when ggplot2 was absent.** A scale's rating
  items are grouped into one chart, and every item in such a scale was skipped
  whether or not that chart could be drawn, though the built-in charts draw
  each one. A missing optional package now costs the grouping and keeps the
  information.
* **A print-palette report mixed monochrome and colour figures**, because the
  single-item diverging chart was drawn with the default palette.
* **Collected multiple-choice answers were missing from the distributions.**
  A multiple-choice question is collected as one column per option, and the
  section looked for a single column under the question's own name, so every
  such question was skipped. Both report engines now count the options, label
  them from the choice set, and state how many respondents answered, since one
  respondent can pick several.
* **A quanteda result's leading features never reached the report**, though its
  own prompt asked a reader to review them. A moderation's conditional slopes
  at the moderator's own values were missing in the same way. Both now render
  as a second table under the result.
* **A mediation table did not say which model produced it.** It gave Direct,
  Indirect and Total with no variable names and no a or b path, so two
  negative paths looked the same as two positive ones: both give a positive
  indirect effect. The table now names the predictor, mediator and outcome and
  reports a and b with their signs.
* **APA numbers follow APA 7 more closely.** `p` loses its leading zero,
  as `p = .032`, and an interval says its level, as `95% CI [0.12, 0.48]`.
  The sentence is plain text, so italicising the symbols stays the author's
  step, and `?sf_apa` now says so.
* **A report claimed an analysis seed when analysis was switched off.**
  `render_report(include_analysis = FALSE)` still printed a seed beside the
  instrument hash, which reads as provenance for an analysis that never ran.

## Provenance and file fixes

* **A revised instrument could be written with its change undisclosed.**
  Reading a file, editing it in memory and writing it produced a consistent
  file with nothing in its amendment log, and a log with entries removed or
  reordered was written as readily.
* **An amendment could record a fingerprint of content that was never
  written**, because the fingerprint was taken before validation updated the
  instrument.
* **A plan or model change could be recorded as a routine pipeline
  amendment**, skipping its deviation report.
* **A one-item scale was written as a single value** where the published
  instrument profile requires an array, so a valid instrument failed the
  profile, and the builder and R hashed the same instrument differently.
* **The file reader, the bundled schema and the published profile disagreed**
  on required fields. They now share one core, `hash`, `meta` and `items`, and
  the reader refuses a file from a newer major format version.
* **`read_responses()` changed values on the way in.** A respondent ID of `001`
  became `1`, a text answer of `NA` became missing, a matrix missing a row
  column raised no warning, and a duplicated column was silently dropped.
* **The Google Sheets collector could mis-file answers under a duplicate or
  blank heading**, and 2 submissions could interleave while the header was
  being extended. Submissions now run inside a lock, and an ambiguous header
  sends the raw submission to an "Unmapped submissions" sheet.
* **`sframe_export_labelled()` left matrix cells, option columns and text-held
  codes unlabelled.** Every response column now carries its row, option or
  criterion wording, and every column of choice codes carries value labels.
* **Generated notebooks hid failed analyses**, never ran their report step,
  and broke on a title containing a quote. Each failed block now shows its
  error, the report renders when at least one analysis succeeded, and titles
  are escaped.
* **Shipped demo results could fall out of step with the package.** A test
  now holds every demo's results file equal to what the package computes.

## SurveyStudio round-trip fixes

* **A rebuild in SurveyStudio dropped item-level reverse coding.** Studio
  replaces the instrument it holds with a rebuild from its editor whenever
  the draft is valid, and that rebuild cleared every item's `reverse` flag,
  keeping only the reversal declared on a scale. An item marked
  `reverse = TRUE` was scored as though answered in the same direction as
  the rest, moving every composite and alpha built on it.
* **A rebuild dropped conjoint designs**, so a declared design was lost as
  soon as the instrument passed through Studio.
* **An item held as a plain list lost its settings**: date limits, matrix
  rows, slider and rating settings, comparison items and the comparison
  scale. Every field the item constructor accepts is now carried.
* **Studio's item-save handler replaced an item wholesale**, which would
  have cleared reverse coding, scale membership, page and type settings on
  any edit. Studio ships no item form, so the handler is unreachable from
  the interface today and no released version could reach it. It now applies
  an edit to the item already there, and drops settings belonging to the
  previous type only when the type itself changes.
* Reverse coding stays where it was declared. A scale's `reverse_items` stay
  on the scale, where a rebuild used to copy them onto each item, which
  changed a loaded instrument's content simply by opening it.

## Documentation

* **`export_google_sheet()` told researchers to let anyone with the link edit
  the response sheet**, which exposes participant data to anyone holding the
  URL. The collector writes through the sheet it is attached to, so link
  sharing was always unnecessary. The help now says to keep the sheet private. If you
  followed the old advice, review the sheet's sharing settings.
* **The cross-check claim made for the decision methods is narrowed to what
  the suite holds.** 0.4.0 said an independent computation had to agree
  before a method was accepted. The suite calls RMCDA for 5 of the 10
  methods, and 4 of those compare numbers: AHP weights, VIKOR's S, R and Q,
  MOORA's ratio system and WASPAS scores. The ELECTRE call compares the
  ordering of one concordance pair. ANP, DEMATEL, SMART, PROMETHEE and
  TOPSIS are checked against hand-derived values and published worked
  examples, with no second implementation. Both kinds of evidence are
  recorded per method in `vignette("mcdm-analysis")`.
* The `survey_module_ui()` and `survey_module_server()` help is rewritten,
  covering supported item types, what is submitted, a failed save, and
  changing the instrument, with a complete example that stores responses.
* The `item_report()` help describes item-rest correlations, where it said
  item-total, and the nested result it returns, with both ways to extract it.
  The `sf_scale()` help states the rules for `min_valid`, `weights` and
  `reverse_items`.
* The `sample_size_plan()` help separates power calculations from precision
  targets and rules of thumb, and states which arguments each one uses.
* The `sensitivity_analysis()`, `sframe_dematel_compute()` and
  `sframe_rated_matrix()` help describe the new counts, the undefined
  total relation, and how rated items pair with a weight item.
* The provenance help for `amend_sframe()`, `link_git_commit()`,
  `read_sframe()` and `write_sframe()` states what the hashes establish: a
  canonical content check, local and unsigned. They identify content, and
  who wrote an instrument or when needs other evidence. The bundled schema
  says the same.
* The `read_responses()` help describes one contract for undeclared columns
  and documents expansion columns and value conversion.
* **`vignette("scale-reliability-validity")` said that supplying construct
  scores returns the HTMT matrix.** It returns the absolute inter-construct
  correlations, and records `htmt_method = "correlation_fallback"` to say which
  it computed. The Henseler heterotrait-monotrait ratio needs
  `items_by_construct`, which records `htmt_method = "henseler"`.
  `validity_report()`'s own help was already accurate, and the vignette
  overstated it in an unevaluated chunk. The section now names what each
  argument gives, and its examples run, so a build would contradict the claim
  if it drifted again.
* **`citation("surveyframe")` abbreviated the author as "Sharafuddin M".**
  The given names Mohammed Ali were passed to `person()` as one string, which
  R shortens to a single initial. They are now 2 given names, so the text
  citation reads "Sharafuddin MA". The BibTeX entry keeps its correct form. The citation year now comes from the release date, where it
  followed the date the citation was run.
* **The PDF reference manual kept its text inside the page margins.** Long
  function names in running text, 2 tables in `?sframe_plots` and
  `?sframe_as_data_frame`, and the Usage of `sf_item()` and
  `sample_size_plan()` ran past the right margin in 83 places. The tables are
  now lists, the Usage lines wrap, and the manual lets a line stretch
  its spaces before letting a name overflow.
* **The APA citations attached to results carried a fixed year of 2026.**
  surveyframe's own citation now takes its year from the installed release,
  and R Core Team's from the running version of R.

## Dependencies

`callr`, `chromote`, `httpuv` and `pkgload` join Suggests. They are used only
by tests that drive a survey in a real browser, which are skipped on CRAN.

# surveyframe 0.4.1

## New

* **A demo library.** Twenty-two small demos, each showing one thing, in
  `sframe_demos()`. Load one with `sframe_demo("two_group")`, or get a
  Quarto notebook to edit with `sframe_demo_qmd("two_group")`. Together they
  cover every analysis method and every question type.
* **`vignette("learn-by-example")`.** Pick the demo that matches the data you
  have, and follow it from questionnaire to report.
* **`sframe_export_labelled()`** writes SPSS `.sav` or Stata `.dta` with the
  question wording and response options attached, so variables arrive
  labelled rather than as codes.
* Each demo also ships a codebook of variable and value labels, and the
  results surveyframe produced, so you can check the numbers in other
  software.

## Reports are now reproducible

`run_analysis_plan()` gains a `seed` argument, set by default. Bootstrap
confidence intervals and the EFA parallel analysis previously drew from the
random stream unseeded, so the same data gave a slightly different interval
on every run.

**Confidence intervals will move once** when you re-run an older analysis.
Test statistics and p values are unaffected. Use `seed = NULL` for the
previous behaviour.

`render_report()` now says which engine produced the file, Quarto or the
built-in writer, in a message, in an `engine` attribute, and in the report
itself beside the instrument hash and the seed.

## Bug fixes

* **The Google Sheets collector could corrupt collected data.** Adding a
  question mid-study left the sheet's header stale while new rows used the
  new order, so values landed under the wrong headings with no error. The
  collector now matches columns by name.
* **Branching rules using `%in%` with more than one value never worked in an
  exported survey.** The question stayed hidden whatever the respondent
  answered. Present since 0.3.0.
* **`sem_lavaan_syntax()` produced a mediation model lavaan could not fit.**
  Indirect effects referred to path labels that were never written.
* Straight-lining no longer flags scales shorter than four items, where
  identical answers are normal rather than careless. `quality_report()` gains
  `straightline_min_items`. When no scale is long enough to check, the report
  now says so instead of omitting the chart silently.
* Reading a response file with `read.csv()` no longer mangles matrix columns
  whose labels contain spaces. Use `check.names = FALSE`.

## Dependencies

`haven` and `V8` join Suggests, both optional.

# surveyframe 0.4.0

A major release. It adds multi-criteria decision analysis (10 methods),
small-sample statistics, text and open-ended response analysis (9 methods),
and a disclosed-amendment and Git-linked provenance trail for `.sframe`
files, alongside 4 corrected results and 2 breaking changes. See below for
full detail on each.

## New: multi-criteria decision analysis (MCDA)

surveyframe's decision-family extension links survey collection directly to
10 MCDA methods, closing the gap between MCDA computation packages, which
assume a clean matrix already exists, and survey software, which has no
concept of a decision method at all.

* 10 decision methods: the Analytic Hierarchy Process (AHP), the Analytic
  Network Process (ANP), the Decision Making Trial and Evaluation Laboratory
  method (DEMATEL), VIKOR, MOORA, SMART, WASPAS, PROMETHEE, ELECTRE, and
  TOPSIS. Every method carries a verified literature citation.
* 2 new item types collect judgement data directly inside the survey
  instrument: `pairwise_comparison` (Saaty's 1-to-9 ratio scale for AHP and
  ANP, or a 0-to-4 directed influence scale for DEMATEL) and
  `criteria_weight` (a constant-sum allocation across criteria).
* A documented aggregation layer (`R/decision_data.R`) turns per-respondent
  answers into the matrices the methods consume: `sframe_assemble_pairwise()`
  builds one matrix per respondent and validates every pair was answered,
  `sframe_aggregate_judgements()` combines them (geometric mean for AHP/ANP,
  which preserves reciprocity, or arithmetic mean for DEMATEL), and
  `sframe_rated_matrix()` builds a performance matrix from ordinary matrix
  items. AHP judgements are additionally screened for consistency against
  Saaty's random-index table, with the CR distribution reported whether or
  not a study has pre-declared a filtering threshold.
* Every ranking method resolves its matrix and weight inputs in the same
  order (a researcher-supplied override, then a collected item, then a
  typed error naming what is missing) and records where each input came
  from, so a results table states the provenance of every number.
* `sensitivity_analysis()` reports how far a ranking moves under a declared
  perturbation of the weights, and carries a `degenerate` flag so a
  ranking that never separated its alternatives cannot report false
  stability (see "Decision analysis: non-results now say so" below).
* Both the visual builder and SurveyStudio support the 2 new item types,
  and the static HTML survey, the Shiny module, and the builder preview
  render all 3 judgement-collection structures identically.
* RMCDA joins Suggests as a test-time cross-check oracle: an independent
  computation of the same method on the same matrix is compared with the
  package's own result. This practice caught a real defect during
  development, a WASPAS runner that had inherited SMART's normalisation
  step by mistake. (Corrected in 0.4.2: this bullet first said independent
  agreement was required before any method was accepted, which was wider
  than the suite. See 0.4.2's note for the coverage each method has.)

## New: small-sample statistics

A track of corrections for comparisons run on small samples, where the
ordinary versions of these tests can flip significance on repeated draws
from data whose true difference never changed.

* The Hodges-Lehmann shift estimator as an alternative to the independent
  two-group Mann-Whitney comparison.
* The paired Wilcoxon pseudomedian confidence interval as an alternative to
  the paired t-test.
* The exact odds-ratio confidence interval on Fisher's test for small
  2x2 tables, avoiding the ad hoc continuity correction a conventional
  Wald interval needs when a cell is zero.
* Firth's bias-reduced logistic regression (`logistf` in Suggests) for
  regression prone to separation at small n.
* A small-sample advisory surfaced on `assumption_report()` and
  `sample_size_plan()`, flagging when a study's sample size falls in the
  range where these corrections are worth considering.
* `vignettes/small-sample.Rmd` walks through when to prefer each
  correction over its conventional counterpart.

## New: text and open-ended response analysis

A 9-method text-analysis family for open-ended survey items, from term
frequency through topic modelling, sharing the same analysis-plan,
role-resolution, and reporting pipeline every other method family uses.

* `term_freq`: top terms by frequency, optionally split by a group
  variable, rendered as a bar chart or a word cloud.
* `ngram_freq`: top bigrams or trigrams by frequency.
* `term_context`: a keyword-in-context concordance table (before/match/
  after) for a chosen keyword.
* `co_occurrence`: pairwise within-response co-occurrence counts on the
  top terms, rendered as a heatmap.
* `co_occurrence_network`: a Louvain-clustered (Blondel et al. 2008),
  force-directed (Fruchterman & Reingold 1991) term co-occurrence
  network; requires the optional igraph package.
* `tidy_sentiment`: positive/negative sentiment counts and proportion
  positive using the bing lexicon, optionally split by a group variable,
  rendered as a diverging bar chart or a positive/negative comparison
  word cloud; requires the optional tidytext package.
* `quanteda_dfm`: a document-feature matrix summary (feature count,
  sparsity, top features); requires the optional quanteda package.
* `topic_model_lda`: Latent Dirichlet Allocation topic modelling, top
  terms per topic as a ranked table and a faceted bar chart; requires
  the optional tidytext and topicmodels packages.
* `stm_topics`: structural topic modelling, the same top-terms-per-topic
  output; requires the optional stm and tidytext packages.
* A shared cleaning step (`clean_text_responses()`) and a 174-word
  Snowball-based English stopword list, both exported so a study can
  reuse or override them outside a runner.
* Both the visual builder and SurveyStudio support all 9 methods,
  including the word-cloud, top-N, seed, and topic-count (`k`) options
  that steer their plots and models.
* `vignettes/text-analysis.Rmd` walks through cleaning, each method, and
  what the family deliberately does not attempt (stemming/lemmatisation,
  tf-idf, and keyness comparison are not yet implemented).

## New: disclosed amendments and a Git-linked provenance trail

`write_sframe()`'s SHA-256 hash proves a `.sframe` file is unchanged since
it was written, but gives no way to distinguish a legitimate revision
(a data-entry correction, bot-response removal, a documented model
respecification) from an undisclosed edit -- both break the hash
identically. This release adds a disclosed-revision path alongside the
existing hash check, without weakening it.

* `amend_sframe()` compares an instrument before and after a change and
  appends a structured, timestamped entry to an ordered amendment log --
  never overwrites -- recording the reason (a controlled vocabulary:
  `data_correction`, `bot_removal`, `model_respecification`,
  `instrument_revision`, `other`), a free-text explanation, and which
  top-level fields changed.
* Two tiers, by default inferred from the reason: `"pipeline"` amendments
  (data corrections, bot removal) need only a reason. `"design"`
  amendments (anything touching the analysis plan or a model) require a
  `deviation_report` describing what changed in the research question,
  method, or model and why, matching how a formal preregistration
  deviation is normally handled. `signoff` is never left blank -- it
  records a reviewer's name or the literal `"none"`, so an unreviewed
  design change stays visible to an auditor.
* `amendment_log()` returns the full history as a data frame, one row per
  disclosed amendment, exportable with `write.csv()`.
* An edit made directly to a `.sframe` file, bypassing `amend_sframe()`,
  still fails `read_sframe()`'s integrity check exactly as before. The
  amendment log adds a disclosed path alongside the existing hash check.
* `link_git_commit()` records the current Git commit SHA and subject line
  alongside an instrument. This ties the SHA-256 hash to a specific,
  already-explained commit. It returns an informative message when Git
  isn't installed or the path isn't a repository. Git is optional.
* `inst/schema/sframe_schema.json` documents the `.sframe` format (every
  top-level field, including the new `amendments` log) as a standalone
  JSON Schema, so a reviewer or a second tool can read and validate a
  `.sframe` file without installing the package. `.sframe` was already
  plain, git-diffable JSON before this release; the schema makes that
  format explicit and independently checkable.
* `vignettes/surveyframe.Rmd` gains a "What the SHA-256 hash proves, and
  what it does not" section, stating plainly that the hash proves file
  identity, not methodological validity, and pointing to the
  design-time `analysis_plan` binding and `run_analysis_plan()`'s
  single-pass execution as the package's separate, complementary defence
  against HARKing and p-hacking.

## Corrected results (read before comparing against earlier output)

Four defects found by independent cross-validation are fixed. Each
produced normal-looking numbers with no error or warning, so re-run any
results computed with an earlier version.

* `item_report()` returned the wrong item-rest correlation. It subtracted
  each item from a `rowMeans()` total, which leaves roughly noise carrying
  the item negatively, so a highly reliable scale reported strong negative
  values. On simulated data with alpha 0.947 every item came back at about
  -0.46. The statistic is now the item against the sum of the other items
  in its scale, and matches `psych::alpha()`'s `item.stats$r.drop` to
  1e-10.
* Repeated-measures ANOVA tested the condition effect against the wrong
  error term, because the subject identifier was left as an integer and
  `aov()` treated it as a continuous covariate. On a fixture where
  `jmv::anovaRM()` gives F(2, 78) = 86.93, surveyframe reported F = 1.45,
  p = 0.24. Correcting the identifier alone was not sufficient: the
  corrected design produces no `Error: Within` stratum, so the effect is
  now located by searching the strata directly.
* `validate_sframe()` rejected valid instruments. Its known-variable list
  held only base item and scale ids, so an analysis plan naming an
  expansion column (`item__sub`, `item__option`, `item__a__vs__b`,
  `item__crit`) failed validation for variables that do exist, including
  real exports from the visual builder. `read_responses()` already
  accepted those columns. Both now derive the list from one shared helper.
* The SEM syntax generators ignored the model type. `seminr_syntax()`,
  `sem_lavaan_syntax()`, and `cfa_lavaan_syntax()` never checked
  `model$type`, and the builder offered every saved model to all 3
  generators, so a covariance-based model produced PLS-SEM syntax with no
  complaint. That is a runnable script estimating a model the researcher
  never declared. All 3 now refuse a mismatched estimation family, and the
  builder filters each model role to the types its generator can produce.

## Breaking: `validate_sframe()` and `validate_model()` return a diagnostic

Both validators previously returned two different things depending on
`strict`: the object itself, invisibly, when `strict = TRUE`, and a bare
unclassed list when `strict = FALSE`. Neither was a diagnostic, the
success path printed nothing at all, and the `strict = FALSE` return had
no methods. Both now return an `sframe_validation` object, and they
return it visibly, so `validate_sframe(instrument)` typed at the console
shows the user what it found.

* The object records `valid`, every `problems` message, and a `checks`
  table listing all 18 instrument checks (10 for a model) whether or not
  each found anything. A diagnostic that lists only failures cannot tell
  a user that a check passed from one that was never reached.
* Read it with `print()`, `summary()` for the check roster,
  `as.data.frame()` for one row per problem, `sf_is_valid()`, and
  `sf_problems()`.
* `strict = TRUE` still aborts with `sframe_validation_error` when
  anything is wrong. That has not changed.
* **`$valid` and `$problems` keep working**, so the common reading
  pattern needs no migration.
* **What breaks**: code using the `strict = TRUE` return as an
  instrument, as in `instrument <- validate_sframe(instrument)`. Wrap it
  in `as_sframe()`. Passing a validation result where an instrument is
  expected now raises a directed error naming `as_sframe()` immediately.

Raised by a Journal of Statistical Software editor reviewing the code:
"we would at least expect that the object is not silently returned and
that the print method is adapted to allow the user to read directly the
diagnostic".

## New: accessor and exploration methods for every class

The same review found that the classes carried `print`, `summary` and
`format` only, so user code had no route to their contents except `$` on
the underlying list, which makes the internal layout part of the public
contract. Two facts made that concrete: `as.data.frame()` failed on all
14 result classes with "cannot coerce class ... to a data.frame", and `[`
dropped the class on the list-backed reports, so `results[1:2]` silently
degraded to a bare list and lost its print method.

* `as.data.frame()` now works on the instrument and on every report
  class, returning that object's primary table.
* `[` keeps the class on `sframe_analysis_results`,
  `sframe_reliability_report` and `sframe_item_report`.
* Instrument accessors: `sf_meta()`, `sf_items()`, `sf_scales()`,
  `sf_choice_sets()`, `sf_branches()`, `sf_checks()`, `sf_models()` and
  `sf_plan()`, with `sf_plan<-` for declaring the plan. The component
  accessors return an `sf_component_list` named by ID, so
  `sf_items(instrument)[["sat_1"]]` reaches one item.
* Component accessors: `sf_id()` and `sf_label()`.
* Report accessors: `sf_apa()` and `sf_flagged()`.
* Coercion: `as_sframe()`.

The vignettes and the examples are rewritten to use these accessors. The
registered S3 method count goes from 41 to 103.

## Breaking: the Shiny collector now emits expansion columns

* `render_survey()` pipe-joined a matrix item's cells into a single column,
  so a matrix question answered in the Shiny survey arrived as
  `mx = "4|5"` where `read_responses()` and the whole analysis layer expect
  `mx__r1` and `mx__r2`. Data collected that way could not be read back by
  the package at all, and nothing said so at collection time. Ranking and
  multiple-choice items had the same shape problem.
* All 3 now emit the expansion columns that the static template and the
  Google Sheets collector already emitted: one column per matrix sub-item
  carrying its value, one per ranking option carrying its rank position, and
  one per multi-select option carrying 0 or 1.
* **This changes the output shape of the Shiny collector.** A study
  mid-collection through `render_survey()` will see its matrix, ranking, and
  multi-select columns change name and layout between versions. Responses
  already gathered under the old shape need re-shaping before they can be
  read, and the decision item types are unaffected because they emitted the
  correct columns from the start.

## The rated performance matrix can now be wired in both GUIs

* SurveyStudio and the visual builder both offered an empty "Performance
  matrix items" dropdown for all 7 ranking methods (TOPSIS, VIKOR, MOORA,
  SMART, WASPAS, PROMETHEE, ELECTRE). That role matches on a `"matrix"`
  level, and neither surface gave matrix items one: the studio classified
  them as `"identifier"` and the builder grouped them under `"expanded"`,
  which no role accepts. The effect was that the rated-matrix path, where
  respondents rate every alternative on every criterion, could only be built
  by writing R directly, even though it is one of the 3 declared ways to
  supply a decision matrix. Matrix items now carry their own `"matrix"`
  level in both surfaces.

## Decision analysis: non-results now say so

* ELECTRE I reports when it establishes no outranking relation at all. On a
  9-criterion problem at the default 0.70 and 0.30 thresholds no alternative
  clears concordance against any other, so every score is 0 and every
  alternative ranks 1. That is legitimate behaviour for the method, but the
  results table read as "all 9 alternatives are jointly best" and the APA
  sentence reported a kernel containing every alternative. A note now
  explains the equal ranks as an absence of evidence.
* `sensitivity_analysis()` gains a `degenerate` flag for the same reason. A
  ranking that never separated the alternatives cannot be changed by
  perturbing a weight, so every check passed and `stable` came back `TRUE`:
  the strongest robustness signal the function can give, produced by the
  weakest result it can be handed. `print()` now leads with "No result to
  test" instead of "Stable" in that case.

## Data quality

* `quality_report()` counted only columns matching a bare item id, and
  multi-column items never post under those, so every expansion column was
  invisible to the missingness check. A respondent who skipped an entire
  pairwise battery was reported at 0 percent missing. Expansion columns now
  count as item data, which brings matrix, ranking, multi-select, and the 2
  decision item types into the missingness figures for the first time.
  **Reported missingness rates will change for any instrument using those
  item types**, because columns that were silently excluded are now counted.
  Straight-lining and timing are unaffected: straight-lining runs over
  declared scales, and timing is measured on the clock.

## Bundled demo data

* Both bundled demo instruments wired their seminr block to a `cb_sem`
  model, so `sframe_demo_data()` generated PLS-SEM syntax from a
  covariance-based model, and every vignette and example loading it
  inherited the same mismatch. Each demo now carries a real `pls_sem`
  model with composite constructs. The instrument hashes changed with it.

## Decision analysis

* All 10 MCDM methods now return a citation. Previously only TOPSIS and
  AHP had one. Every reference was checked against the publication record.
* `sframe_decision_options()` documents PROMETHEE's preference functions
  and records why the default is `"usual"`, Brans and Vincke's type I step
  function, chosen over the linear function several other implementations
  default to. Net flows differ between the 2 functions, and the ranking
  changed in 226 of 400 randomly drawn 4-alternative by 3-criterion
  matrices.

# surveyframe 0.3.4

This release completes the plotting, interface, statistics, and reporting
work started in 0.3.3. Every analysis family now has a chart, every effect
size ships with a confidence interval, reports accept written
interpretations and print to PDF, both dashboards gain quality and
correlation panels, date questions gain bounds, and the builder and
vignettes pass a WCAG 2.2 AA accessibility audit. Hard dependencies are
unchanged. naniar and pagedown join Suggests.

## Effect sizes and intervals

* Four new exported helpers, all base R: `bootstrap_ci()` (percentile
  bootstrap for any statistic), `cohens_d_ci()`, `cramers_v_ci()`, and
  `eta_sq_ci()`.
* Analysis-plan runners attach a confidence interval to their effect size
  as a new result key: `d_ci` on the t-tests, `r_ci` on Mann-Whitney and
  Wilcoxon, `eta_ci` on ANOVA and Kruskal-Wallis, `ci` on the correlations
  (analytic Fisher z for Pearson, bootstrap for the rank methods), and
  `v_ci` on chi-square and cross-tabulation.
* APA strings and writing prompts now carry the interval, for example
  `d = 0.62 [0.18, 1.05]`. Data too small for an interval keeps the
  previous string.

## Psychometrics

* `validity_report()` computes the Henseler heterotrait-monotrait ratio
  when item-level data is supplied through the new `items_by_construct`
  argument. Without it, the previous correlation-based fallback applies
  and the `htmt_method` element records which was used.
* `missing_data_report()` runs Little's MCAR test when naniar is
  installed. Without naniar the result is unchanged.
* `reliability_report()` records why omega is unavailable for a scale in
  an `omega_note`, and the reliability chart names those scales in its
  subtitle.
* `efa_solution()` adds three tidy data frames ready for plotting and
  reporting: `loadings_long`, `communalities_table`, and
  `variance_table`.

## Reports and codebook

* `render_report(format = "pdf")` prints the HTML report to PDF through
  pagedown, which requires a local Chrome or Chromium. HTML output is
  unchanged and remains the default.
* The report's built-in styling now uses a small set of CSS variables, so
  a re-theme is a one-line change, and a print stylesheet paginates the
  report cleanly. Tables carry captions and header scopes, and every
  embedded chart has descriptive alternative text.
* The codebook now includes the pre-declared analysis plan and the saved
  measurement and structural models, so one document fully records the
  instrument a study used.
* The codebook's items table shows each item's actual response options and
  scale label directly, instead of an id that needed a separate choice-sets
  table to decode.
* Analysis-result tables (frequency, cross-tabulation, group comparisons,
  regression coefficients, and the rest) show item, scale, and
  response-option labels instead of the underlying ids and coded values.
* Report tables render as properly split HTML tables in both the Quarto and
  internal HTML report paths.

## Written interpretations in reports

* New `interpretations` argument on `render_report()` and
  `render_results()`. Pass a named list keyed by analysis-plan block id to
  add a written interpretation to each research question after the results
  are known. The report shows it beside the pre-declared decision rule, so
  the prospective plan stays visible next to the post-hoc narrative.
  Interpretations are report content only and are never written into the
  instrument file.
* SurveyStudio's Export screen gains an Interpretations card: one block per
  research question, in reading order (result table, chart, planned
  decision rule, then the interpretation), shown with the live result once
  responses are loaded. The generated report includes whatever you write
  there.
* A "Copy result" button on each Interpretations block copies the whole
  result, table, chart, and the interpretation as written, as one block,
  for pasting into a document.
* The SurveyBuilder Report outline now edits the planned decision rule
  inline, in sync with the research-question dialogue.

## Charts

* `run_analysis_plan(plots = TRUE)` now attaches a chart to every
  supported family: regression diagnostics (4 panels), EFA scree and
  loadings heatmap, reliability bars, mosaic and crosstab, correlation
  heatmap, quality flag rates, group-comparison boxplots, paired slope
  charts, raw-variable distributions, repeated-measures profiles, a
  partial-correlation residual scatter, logistic-regression odds-ratio
  forest plots, a moderation interaction plot, and a mediation effect
  chart. Every analysis-plan block now returns a table, a chart, or
  generated syntax.
* Distribution shape by variable draws as a violin per variable, instead
  of a bar chart of the skewness and kurtosis summary statistics.
* A scale's separate Likert items, and a matrix question's rows, draw as
  one grouped diverging chart, instead of one chart per item.
* New `plot()` methods for descriptives, EFA, quality, reliability,
  validity, missing-data, and analysis-results objects. `plot(results)`
  draws every attached chart, and `plot(results, which = "rq_id")` returns
  one.
* New `plot_palette` argument on `run_analysis_plan()` and
  `render_report()`: `"web"` for brand colour on screen, `"print"` for
  black and white suitable for print and journal submission. SurveyStudio
  exposes the choice as a Chart theme option on the Export screen.
* SurveyStudio's Analyse screen shows one result card per research
  question with its chart beneath the statistic.
* Both dashboards (the standalone response dashboard and the SurveyStudio
  Dashboard tab) gain a straight-lining flag-rate chart, a missing-data
  chart, and a scale-score correlation heatmap. All dashboard charts keep
  a base-graphics fallback, so ggplot2 remains optional.

## Survey design

* Date questions accept `date_min` and `date_max` bounds in `sf_item()`,
  the SurveyBuilder, and the exported survey. The date picker enforces the
  bounds and typed dates outside them show a clear message.
* The SurveyBuilder ships a library of 14 preset choice sets, regenerates
  item ids safely when the response type changes, and expands matrix,
  ranking, and multiple-choice items into the same per-option variables
  that `read_responses()` produces.
* The survey thank-you page no longer forces a CSV download. It offers a
  "Download my response" button and honours a configured redirect.

## Accessibility

* The SurveyBuilder interface passes an instrumented WCAG 2.2 AA audit
  with zero findings across its build, preview, and analyse screens and
  dialogues.
* All 7 vignettes pass the same audit: language metadata, AA contrast for
  links and code highlighting, wrapped code blocks, keyboard-reachable
  content, and alternative text on every chart.

## Bug fixes

* `sf_item()`'s `date_min` and `date_max` accept only `"YYYY-MM-DD"` or a
  `Date` object now (an ambiguous string such as `"01/02/2024"` used to
  parse silently into a specific date depending on locale). Anything
  else raises a validation error.
* `bootstrap_ci()`, `cohens_d_ci()`, `cramers_v_ci()`, and `eta_sq_ci()`
  no longer alter the random-number seed for code that runs after a
  reproducible, seeded call.

# surveyframe 0.3.3

This release adds an opt-in plotting layer, fixes bugs surfaced by the
package's first field deployment, and redesigns the survey-taking
experience. ggplot2 joins Suggests; hard dependencies are unchanged.

## Analysis and plotting

* New `plots` argument on `run_analysis_plan()` (default `FALSE`). When
  `TRUE`, supported analysis blocks return a ggplot object in `$plot`: bar
  charts for frequency and chi-square blocks, and scatter plots with a
  regression overlay for correlation and regression blocks.
* New exported `theme_surveyframe()`, a publication-oriented ggplot2 theme
  with an accessible fixed-order series palette. All plots use it.
* Inferential runners return a `$table` data frame ready for
  `knitr::kable()`; the HTML report shows these tables automatically.
* Frequency and cross-tab runners treat empty strings as missing values, so
  partially completed responses no longer form a blank category.
* Ranking items now export one column per option holding its rank
  (`item__option = 1` for the top choice), so ranks are directly analysable.
  Multiple-choice items likewise export one 0/1 column per option instead
  of a single comma-joined column. `read_responses()` accepts the expanded
  columns for ranking, matrix, and multiple-choice items without warnings.
* `render_report()` now attaches each analysis block's chart directly under
  its result table, in both the Quarto and internal HTML report paths,
  instead of tables and plots appearing in separate places.
* Likert items in the report's response-distributions section get a
  diverging stacked bar chart (darkest at each pole, lightest next to
  neutral) instead of a plain frequency bar, so the direction and strength
  of opinion is visible at a glance.

## Survey experience

* A full redesign of the exported survey: larger serif question typography,
  bordered option cards with selection ticks, numbered Likert squares,
  restyled matrix, slider, and ranking blocks, and a slim top progress bar.
  Every colour derives from the instrument's single theme colour, so one
  colour choice re-skins the whole survey. Touch targets meet a 44 pixel
  minimum on phones.
* Branching rules on one question now combine with AND, and hiding a
  controlling question also hides everything that depends on it, so
  screening logic behaves as declared even when answers change.
* Single-page surveys show answered-questions progress (for example
  "12 of 44 answered"); numeric questions respect declared minimum and
  maximum bounds.
* Branching rules can now show and hide section breaks and text blocks, so
  a branched text block works as a screen-out message ("Sorry, you are not
  eligible") and section headings disappear with their questions.
* A matrix question reflows into stacked, labelled row-cards below 600
  pixels instead of a table that needs horizontal scrolling to complete.
* The exported survey meets WCAG 2.2 AA on an instrumented audit: every
  input carries an accessible name, keyboard focus is visible on option
  cards, errors are announced to assistive technology, required questions
  are marked beyond colour, ranking items gain keyboard reorder buttons,
  headings are real headings, and all touch targets and text contrast meet
  the standard.

## Data collection

* Fixed a bug that silently blocked submissions from hosted surveys: the
  Google Apps Script POST now avoids the CORS preflight that Apps Script
  never answers. Collectors no longer emit columns for section breaks or
  text blocks.
* `read_sheet_responses()` gains a `meta_cols` argument for extra sheet
  columns a host application appends, and SurveyStudio's dashboard now
  computes completion times from imported sheet responses.

## Model syntax

* `sem_lavaan_syntax()` turns free-text path labels into valid lavaan
  parameter names (a label starting "H1:" becomes the parameter `H1`).
* `seminr_syntax()` output loads seminr and uses `summary()` accessors, so
  the generated code runs as pasted.
* `run_analysis_plan()` accepts `pls_sem` as an alias for `seminr_syntax`.

## SurveyBuilder and report

* Opening a `.sframe` verifies and reports its SHA-256 integrity status.
* New choice questions start with a fresh option set, and editing shared
  options forks the set first, so options never leak between questions.
* The analysis-plan modal blocks using one variable in two roles, and the
  test suggester handles Likert items and multi-group comparisons sensibly.
* Reports print generated model syntax in code blocks and show reliability
  results as a table.
* "+ Add question" now opens the question-type picker instead of silently
  adding a Likert item, and the redundant icon-only button next to it is
  gone. Survey settings live only in the sidebar; the top bar no longer
  duplicates that entry point.

# surveyframe 0.3.2

This release corrects the package citation, completes the S3 method surface for
the component classes, and improves the graphical tools and the HTML report. It
adds no new exported functions, no new statistical methods, and no new bundled
datasets.

## Citation and methods

* `inst/CITATION` now reports the correct package title and reads the version
  dynamically from the package metadata, so the citation no longer pins an old
  version or an outdated title.
* Added `print()`, `format()`, and `summary()` methods for the component
  classes `sf_choices`, `sf_item`, `sf_scale`, `sf_branch`, `sf_check`, and
  `sf_model`, so each class now has a visible, documented S3 surface.
* `lavaan` is declared in `Suggests`. It is used only to fit the syntax produced
  by `cfa_syntax()`. The package itself generates syntax and never requires
  `lavaan` to be installed.

## Graphical tools

* SurveyBuilder exports a deployable survey in the browser through a new Export
  survey button, and generates the Google Sheets Apps Script collector through a
  Generate collector button. Both reuse the same templates the R functions use,
  so the output matches `export_static_survey()` and `export_google_sheet()`.
* The builder Analyse tab shows three distinct stages: Plan, Run preview (the
  methods that need response data), and Report outline (analyses plus
  measurement models). Analysis plans can be reordered by dragging.
* The exported survey carries a "Built with surveyframe" footer, sizes a header
  logo consistently across aspect ratios, shows a page progress indicator only
  on multi-page surveys, and gains a mobile layout.
* SurveyStudio opens an instrument designed in the builder, previews the exact
  deployable survey in a frame, and analyses uploaded responses. The response
  dashboard, with an overview, item and scale distributions, and a raw-data
  table, is now built into the studio. A button loads the bundled sample survey
  and 120 responses. Survey design moved entirely to the builder.

## HTML report

* `render_report()` renders reliably through Quarto when it is installed. A path
  defect that made the Quarto render fail and fall back to the plain internal
  output is fixed.
* Reports include a response distributions section, with one chart per item and
  one per scale, in both the Quarto output and the built-in HTML fallback.
* Tables are formatted, wide tables scroll within the page, the table of
  contents sits on the left, and numeric values are rounded to two decimal
  places.

## Documentation

* Added the "Deploying a survey and collecting responses on free hosting"
  vignette, covering the Apps Script collector, GitHub Pages and Blogger
  hosting, and reading the responses back into R.

# surveyframe 0.3.1

This is a patch release. It fixes the static-survey to Google Sheets to R
collection loop, repairs a serialisation defect, and improves the first-time
user experience. There are no new exported functions, no new statistical
methods, and no new bundled datasets.

## Bug fixes

### Data collection round-trip

* `export_static_survey()` now renders the header logo and institution name
  from `render$header`, so exported surveys match the Shiny renderer and
  the builder preview.
* `export_static_survey()` now falls back to the instrument's
  `render$google_sheets_endpoint` when `endpoint_url` is not supplied, so
  a Google Sheets endpoint set in the builder is honoured on export.
* The static survey now posts the respondent identifier under the column name
  `respondent_id`, matching the Google Apps Script collector and
  `read_responses()`. The collection round-trip now preserves the identifier.
* `export_google_sheet()` now includes matrix sub-item columns
  (`item_id__sub`) in the Apps Script header row, so matrix answers are
  stored in the Sheet.
* `read_sheet_responses()` now declares `started_at` as a meta column and
  no longer raises a warning on every read.
* Survey logos now keep their original MIME type (`image/png`, `image/jpeg`,
  `image/gif`), so JPEG and GIF logos display correctly in the builder,
  the Shiny renderer, and the static export.

### Serialisation

* `write_sframe()` now strips list-level names from the item, choice, scale,
  branching, check, and model collections before serialisation. Instruments
  built with `Map()` or other helpers that attach element names (for example,
  using item IDs as names) previously serialised those collections as
  keyed JSON objects, producing a hash mismatch and an integrity error
  on `read_sframe()`. Saved instruments now round-trip correctly
  regardless of how the component lists were constructed.

## User experience

* Every exported function that takes an instrument now reports a clear,
  actionable message when passed something that is not an `sframe` object.
  The message points the user to `sf_instrument()` and `read_sframe()`
  instead of showing a raw `inherits()` assertion failure.
* `reliability_report()` no longer prints `psych` internal warnings to the
  console. McDonald's omega is skipped silently for scales with fewer than
  three items, where the statistic is not meaningful.
* The error message from `run_analysis_plan()` when no analysis plan is
  present now describes both the programmatic route
  (`instrument$analysis_plan`) and the visual SurveyBuilder route.

## Documentation

* Rewrote the main vignette (`surveyframe.Rmd`) as an end-to-end worked
  example: design the questionnaire, export it as a hosted survey with a
  Google Sheets backend, collect responses, score them, run the analysis
  plan, and render a report. The results section uses simulated responses so
  the vignette builds offline; a single `read_sheet_responses()` call
  connects the same workflow to live responses. The questionnaire and concept
  are adopted from Sharafuddin, Madhavan, and Wangtueai (2024,
  *Administrative Sciences*, 14(11), 273,
  <doi:10.3390/admsci14110273>), with generic destination wording so the
  example transfers to any tourism services context.
* Updated the supporting vignettes to reflect the research-design-first
  workflow where the instrument holds the questions, the analysis plan, and
  the measurement model.
* `sf_instrument()` examples now include a complete `analysis_plan` block.
* The README now leads with `install.packages("surveyframe")`, adds a short
  path for users who already have a response CSV, and points to
  `browseVignettes("surveyframe")`.

# surveyframe 0.3.0

The first CRAN release of the full workflow: a typed instrument object
carrying the questions, the analysis plan, and the measurement model, with
deployment, collection, analysis, and reporting built around it.

## New features

### Analysis planning, survey statistics, and model syntax

* Added a role-based analysis-plan structure while preserving old
  `variables`/`test` analysis blocks. New plans can store `family`, `method`,
  `roles`, `options`, `hypotheses`, `decision_rule`,
  `reporting_references`, `status`, and `requires_data`.
* Added common survey analysis helpers: `descriptives_report()`,
  `missing_data_report()`, `assumption_report()`, `posthoc_report()`,
  `validity_report()`, and `sample_size_plan()`.
* Expanded `run_analysis_plan()` to dispatch the v0.3 method registry,
  including descriptives, missing data, sparse-table tests, related-sample
  tests, Kendall and partial correlations, two-way ANOVA, ANCOVA, repeated
  ANOVA, ordinal and multinomial logistic regression, mediation, moderation,
  and model-syntax output.
* Added a model specification layer: `sf_construct()`, `sf_path()`,
  `sf_covariance()`, `sf_indirect()`, `sf_model()`, `validate_model()`,
  `model_json()`, `add_model()`, `efa_solution()`, `efa_syntax()`,
  `cfa_lavaan_syntax()`, `sem_lavaan_syntax()`, `seminr_syntax()`, and
  `model_report_template()`. Syntax generation does not require `lavaan` or
  `seminr`.
* `cfa_syntax()` remains available as a backward-compatible wrapper around
  `cfa_lavaan_syntax()`.
* SurveyBuilder Analyse mode now uses a three-panel Plan/Run/Report workspace
  with variable metadata badges, role-based variable assignment, method
  options, output preview, reporting references, and a table-based model
  builder. Significance level is shown only for inferential methods.

### Static HTML survey export

* Added `export_static_survey()`. This produces a single, self-contained
  HTML file that runs the survey in any modern browser without a Shiny
  server or an internet connection. All thirteen item types are fully
  rendered (Likert, single choice, multiple choice, matrix, numeric, text,
  long text, date, slider, rating, ranking, section break, text block).
  Branching logic, required-field validation, a progress bar, welcome and
  thank-you pages are all handled in client-side JavaScript. On submission
  the browser downloads a per-respondent CSV file. An optional
  `endpoint_url` argument adds a parallel JSON POST to any serverless
  endpoint (Google Apps Script, Netlify function, etc.).

  The exported file is suitable for hosting on GitHub Pages, Netlify, or
  any static file server, and can also be shared directly as an e-mail
  attachment and opened from disk.

  The SHA-256 hash written into `.sframe` files by `write_sframe()` and by
  the SurveyBuilder HTML is computed using the same canonicalisation
  algorithm, so instruments round-trip correctly between the browser and R.

### Interactive response dashboard

* Added `launch_dashboard()`. Opens a five-panel Shiny dashboard for
  exploring collected response data alongside the instrument definition,
  without modifying either. The panels are: Overview (response count, date
  range, instrument metadata), Items (per-item bar charts, histograms, and
  frequency tables), Scales (scale score distributions with mean overlay),
  Quality (attention-check pass rates), and Raw data (a scrollable response
  table with CSV download).

  When called without arguments the dashboard loads the bundled tourism
  services demo. When called with a user-supplied instrument and no
  `responses` argument, it opens in metadata-only mode showing instrument
  structure.

* Added `sframe_demo_data()`, `sframe_input_types_demo_data()`,
  `launch_builder_demo()`, `launch_studio_demo()`, and
  `launch_dashboard_demo()` for CRAN-safe examples, training, and local GUI
  testing.

* Added a bundled input-types demo instrument and simulated response dataset
  for testing SurveyBuilder, SurveyStudio, the dashboard, and all supported
  item controls.

* `launch_studio()` now accepts preloaded instruments, response data frames,
  CSV response paths, initial screen selection, host, port, and browser
  control. SurveyStudio reads these preloaded values during startup.

### Shiny survey module

* Added `survey_module_ui()` and `survey_module_server()`. These allow a
  survey to be embedded inside a larger Shiny application as a first-class
  module. `survey_module_server()` returns a `reactive` that holds `NULL`
  until the form is submitted, then returns the response as a named list
  keyed by item ID.

  ```r
  ui <- fluidPage(survey_module_ui("s1"))
  server <- function(input, output, session) {
    resp <- survey_module_server("s1", instrument = instr)
    observeEvent(resp(), { saveRDS(resp(), "response.rds") })
  }
  ```

  An optional `on_submit` callback fires immediately on submission, before
  any `observeEvent()` elsewhere in the app.

### Extended analysis plan tests

`run_analysis_plan()` now implements four additional tests used by the
SurveyBuilder's test dropdown:

* `anova_one`: One-way ANOVA with eta-squared effect size. When the
  result is significant and there are more than two groups, Tukey HSD
  post-hoc output is included in the result object.
* `t_test_pair`: Paired-samples t-test with Cohen's d_z.
* `wilcoxon_pair`: Wilcoxon signed-rank test with r effect size.
* `regression_logistic_binary`: Binary logistic regression with
  McFadden R-squared and an overall model chi-square test. The full
  coefficient table is returned for interpretation.

All four runners produce an APA-formatted summary string and an
interpretation `prompt` field to guide write-up.

## Bug fixes

* `write_sframe()` validates the instrument and writes the validated object,
  preserving `meta$validated = TRUE` in the saved `.sframe` file.
* `.sframe` serialisation now includes a `models` field and continues to read
  older `.sframe` files where `models` is absent.
* `read_responses()` no longer requires display-only items such as
  `section_break` and `text_block` to appear as response columns.
* `validate_sframe()` now checks model references, analysis-plan roles,
  invalid model IDs, duplicate model IDs, and model indicator/path integrity.

* `launch_builder(open = TRUE)` opens the SurveyBuilder HTML in the system's
  default browser via `utils::browseURL()`.
* `R/studio_builder.R` contains three fully implemented internal
  functions (`sframe_builder_empty_state`, `sframe_builder_state_from_instrument`,
  `sframe_builder_validate_draft`) used by SurveyStudio startup and draft
  validation.
* SHA-256 hashing in the SurveyBuilder HTML includes a pure-JavaScript
  fallback for environments where `crypto.subtle` is unavailable on
  `file://` origins, including common Firefox `file://` configurations.
  Saving a `.sframe` file from the builder now always succeeds.
* The SurveyBuilder's `rqSuggest` box now appears with an icon and a
  plain-language recommendation when two or more variables are selected in
  the RQ modal.
* The undo and redo buttons in the SurveyBuilder topbar are now correctly
  disabled when their respective history stacks are empty.

## Security hardening

* `export_google_sheet()` now writes Google Apps Script using JSON-encoded
  JavaScript literals instead of interpolating instrument metadata directly
  into executable code. The generated endpoint also rejects missing,
  over-large, and non-object JSON POST bodies.
* SurveyStudio upload handlers now validate uploaded `.sframe` and `.csv`
  files by extension, size, and text-content checks before passing them to
  import functions.
* `read_sframe()` now validates the top-level `.sframe` payload structure
  before hash verification and object reconstruction.
* Internal HTML report generation now applies escaping consistently to
  report titles, instrument metadata, citations, and effect labels.
* Quarto report rendering now cleans temporary render directories and RDS
  files with `on.exit()` even when rendering fails.

## Documentation

* `validate_sframe()`, `score_scales()`, `codebook_report()`, `cfa_syntax()`,
  and `launch_builder(open = FALSE)` have fully runnable examples.
* Reworked the vignette set into a coherent workflow covering instrument
  building, response analysis, reliability and validity, EFA/CFA/SEM/PLS
  syntax generation, and GUI usage.
* The demo launchers (`launch_builder_demo()`, `launch_studio_demo()`, and
  `launch_dashboard_demo()`) open in the browser with the demo instrument,
  scales, and analysis plan preloaded, so no manual file loading is needed.
* The interactive package demo (`demo("survey")`) walks through the whole
  workflow with step-by-step prompts.

## Dashboard and report polish

* The dashboard parses response dates in the common formats (ISO 8601,
  date-only, UK and US day orders) instead of erroring on non-standard
  strings, colour-codes quality rows by flag status, matches the download
  button to the active theme, and draws the Items and Scales charts as soon
  as their tabs open.
* HTML report tables use APA formatting, with horizontal rules only and a
  significance footnote added automatically when a p-value column is
  present.

# surveyframe 0.1.0

* Initial release.
* Core S3 object system: `sf_instrument()`, `sf_item()`, `sf_choices()`,
  `sf_scale()`.
* Serialisation: `write_sframe()`, `read_sframe()` with SHA-256 integrity
  checking.
* Shiny survey renderer: `render_survey()`.
* Static SurveyBuilder HTML: `launch_builder()`.
* Response reader: `read_responses()`.
