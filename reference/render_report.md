# Render a reproducible survey report

Generates an HTML report that includes the instrument codebook, data
quality summary, reliability diagnostics, and analysis-plan content.
Quarto is the report engine. Without Quarto, surveyframe writes a short
plain results page with the numbers, tables, charts and APA result
lines, under a banner that links to the Quarto installation page. That
page gets no new features and is not promised to match the Quarto
report.

## Usage

``` r
render_report(
  instrument,
  data = NULL,
  output_file = NULL,
  output_path = NULL,
  format = c("html", "pdf", "docx", "odt", "qmd"),
  include_quality = TRUE,
  include_reliability = TRUE,
  include_codebook = TRUE,
  include_missing = TRUE,
  include_descriptives = TRUE,
  include_analysis = TRUE,
  include_models = TRUE,
  plot_palette = c("web", "print"),
  interpretations = NULL,
  show_code = TRUE,
  references = NULL,
  csl = NULL,
  title = NULL,
  authors = NULL,
  figures = getOption("surveyframe.figures"),
  figure_dir = NULL,
  open = interactive()
)
```

## Arguments

- instrument:

  An `sframe` object.

- data:

  A `tibble` or `data.frame` of responses, or NULL to generate a
  codebook-only report.

- output_file:

  Character or NULL. The output file path. When NULL, a temporary file
  is written and its path returned.

- output_path:

  Character or NULL. Alias for `output_file`. If both are supplied,
  `output_file` takes precedence.

- format:

  Character. Output format: `"html"` (default), `"pdf"`, `"docx"`
  (Word), `"odt"` (OpenDocument) or `"qmd"` (the Quarto source). Word
  and OpenDocument go through Quarto, styled by bundled APA 7 reference
  documents (Times New Roman 12, double spacing, APA headings), and stop
  with a message when Quarto is not found. PDF goes through Quarto and
  LaTeX when a LaTeX engine is found (TinyTeX, or xelatex, lualatex or
  pdflatex on the PATH), through the Typst Quarto bundles otherwise, and
  without Quarto prints the built-in HTML page through
  [`pagedown::chrome_print()`](https://rdrr.io/pkg/pagedown/man/chrome_print.html),
  which needs the pagedown package (in Suggests) and a local Chrome or
  Chromium. The returned path's `"converter"` attribute names the route:
  `"quarto-latex"`, `"quarto-typst"`, `"pagedown"`, or `"quarto"` for
  Word and OpenDocument. Every route renders offline. `"qmd"` writes the
  Quarto source of the report as a folder, named by `output_file` (a
  trailing `.qmd` is dropped), which must be new or empty: `report.qmd`,
  the `.sframe`, `responses.csv`, the bibliography and its style, the
  results record and `manifest.json`, and no `_quarto.yml`. Open
  `report.qmd` in RStudio or Positron and render it. It recomputes every
  number from the folder's files and checks them, through
  [`sframe_report_source()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_report_source.md).
  Writing the folder needs no Quarto.

- include_quality:

  Logical. Whether to include the data quality report. Requires `data`.
  Defaults to `TRUE`.

- include_reliability:

  Logical. Whether to include reliability diagnostics. Requires `data`.
  Defaults to `TRUE`.

- include_codebook:

  Logical. Whether to include the instrument codebook. Defaults to
  `TRUE`.

- include_missing:

  Logical. Whether to include the missing-data report. Requires `data`.
  Defaults to `TRUE`.

- include_descriptives:

  Logical. Whether to include descriptive statistics. Requires `data`.
  Defaults to `TRUE`.

- include_analysis:

  Logical. Whether to include analysis-plan results when `data` are
  supplied and the instrument has an `analysis_plan`.

- include_models:

  Logical. Whether to include saved model JSON and generated syntax
  blocks. Defaults to `TRUE`.

- plot_palette:

  One of `"web"` (brand colours, for on-screen reading) or `"print"`
  (black, grey, and white, for a journal-ready or print-friendly
  report). Applied to every chart the report embeds. See
  `sframe_brand()`.

- interpretations:

  Named list or NULL. Written interpretations keyed by analysis-plan
  block id, added after the results are known. Each block's section
  prints the hypotheses and planned decision rule it declared before its
  result, with or without an entry. An entry prints after the result
  under "Interpretation (written after the results)", in place of any
  interpretation the block holds. Interpretations are report content
  only and are never written into the instrument.

- show_code:

  Logical. Whether each result carries a folded "Show R code" block with
  the statistical call that produced it, built by
  [`sframe_syntax_result()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_result.md)
  from the same resolved specification the analysis ran. Defaults to
  `TRUE`. A method
  [`sframe_syntax_result()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_syntax_result.md)
  does not cover shows no block, rather than a guess at the call.

- references:

  Optional further
  [`sframe_reference()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reference.md)
  records, for example the works a host cites in the written
  interpretations, which are cited in text as `[@id]`. The instrument's
  own references
  ([`sframe_add_references()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_add_references.md))
  and the methods' references are always included.

- csl:

  The citation style of the references: a bundled style name, `"apa"`
  (APA 7, the default), `"chicago-author-date"`, `"harvard"` (Cite Them
  Right), `"ieee"` or `"mla"`, or the path to a Citation Style Language
  (`.csl`) file, such as one saved from https://www.zotero.org/styles.
  Styles are never fetched from the network. The style's name and sha256
  go into the results record and the manifest, and a `.qmd` report
  folder holds a copy named for it, so a rerun uses that copy. The
  built-in engine formats APA 7 only and says so when another style is
  asked for. An unknown name stops with the list of the 5.

- title:

  Character or `NULL`. The report's title. Defaults to the instrument's
  title.

- authors:

  Character vector or `NULL`. The report's authors, shown under the
  title. Defaults to the instrument's authors, and is left out when
  there are none.

- figures:

  List or `NULL`. Size, resolution and format for every figure in the
  report: any of `width` and `height` in inches, `dpi`, and `format`,
  `"png"` or `"svg"` inside the report. For example
  `list(width = 6.5, height = 4, dpi = 300)`. Absent entries keep each
  engine's own default. Defaults to the `surveyframe.figures` option, so
  a host can set it once with
  `options(surveyframe.figures = list(dpi = 300))`.

- figure_dir:

  Character or `NULL`. A directory to write each analysis plan chart
  into as its own file, through
  [`sframe_save_figures()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_save_figures.md),
  at the size, resolution and format in `figures`, where `format` may
  also be `"tiff"`, `"jpeg"` or `"pdf"`. Needs `data`. Defaults to 300
  dpi at 7 by 4.5 inches where `figures` names none.

- open:

  Logical. Whether to show the finished report: in the viewer pane of
  RStudio, Positron or VS Code, and in the web browser otherwise.
  Defaults to `TRUE` in an interactive session and `FALSE` in a script.
  Nothing opens during a knitr or Quarto render.

## Value

The output file path, invisibly.

## Which Quarto

The first copy of Quarto that runs `quarto --version` is used, searched
in this order: the executable named by the `QUARTO_PATH` environment
variable, `quarto` on the PATH, `RSTUDIO_QUARTO` (set inside RStudio),
the copy bundled with RStudio, then the copy bundled with Positron.
RStudio and Positron do not put their copies on the PATH, so a report
rendered outside them found none before 0.4.3. `QUARTO_PATH` takes the
path of the executable itself, as in the quarto package. The Quarto
report gives the version used and where it was found, and the returned
path carries the executable as its `"quarto"` attribute.
`options(surveyframe.use_quarto = FALSE)` uses the built-in engine
whatever is installed.

## Markdown in text fields

A research question, H0, H1, decision rule, interpretation, study
problem or deviation report may hold Markdown: bold, italic, bulleted
and numbered lists, links, `[@key]` citations, `~sub~`, `^sup^`,
footnotes `^[...]` and equations, `$...$` inline and `$$...$$` display
(an opening `$` needs a non-space on its right and a closing `$` a
non-space on its left and no digit after it, so "costs \$5 and \$10"
stays prose). The `.sframe` keeps the text as typed. The Quarto report
renders it, with equations as MathML, which needs no script or network.
The built-in page renders it with commonmark and prints each equation's
TeX in monospace. Shortcodes, raw blocks, `:::` fences, heading lines, a
`---` line and HTML tags print as typed, R code in a field is never run,
and `@word` is a citation only when `word` is the key of a reference the
report holds.

## Results record, manifest and provenance

Beside every report `render_report()` writes 2 files named after it. For
`report.html` they are `report_results.json`, the plan results as
canonical JSON (sorted keys, full precision, no timestamp, so the same
instrument and responses give the same file), and
`report_manifest.json`, the sha256 of the instrument content, the
responses, the results record and the report as generated, with the
surveyframe and R versions and the time. A report edited later, as a
Word copy is meant to be, no longer matches its recorded hash, while the
results record still does. The Provenance section at the top of the
report gives the instrument hash and whether
[`read_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_sframe.md)
verified it, the number of amendments, the responses sha256 and the
results record's sha256. The responses are hashed as JSON by column, so
the hash belongs to the values, not to a file.

## References

The Quarto report cites in text, author and year, and lists every work
it cites once, in a References section at the end, formatted by pandoc's
citation processor in the chosen style. That covers the methods' own
references, the sources the instrument cites for its items, scales, plan
blocks and models, and `references`. The built-in HTML engine, used when
Quarto is unavailable, lists the methods' references the same way.

## See also

[`sframe_codebook()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_codebook.md),
[`sframe_quality_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_quality_results.md),
[`sframe_reliability_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reliability_results.md)

Other Report functions:
[`render_results()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_results.md),
[`sframe_analysis_qmd()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_analysis_qmd.md),
[`sframe_codebook()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_codebook.md),
[`sframe_format_result()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_format_result.md),
[`sframe_report_source()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_report_source.md),
[`sframe_reports`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_reports.md),
[`sframe_save_figures()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_save_figures.md)

## Examples

``` r
instr <- read_sframe(
  system.file("extdata", "tourism_services_demo.sframe",
              package = "surveyframe")
)
responses <- read_responses(
  system.file("extdata", "tourism_services_responses.csv",
              package = "surveyframe"),
  instr,
  respondent_id = "respondent_id",
  submitted_at = "submitted_at",
  meta_cols = "started_at"
)
# \donttest{
old <- options(surveyframe.use_quarto = FALSE)
out <- tryCatch(
  render_report(
    instr,
    data = responses,
    output_file = tempfile(fileext = ".html"),
    include_reliability = FALSE,
    include_analysis = FALSE
  ),
  finally = options(old)
)
#> Report rendered with the built-in HTML engine: /tmp/RtmppFIGkv/file20984a813dd3.html
file.exists(out)
#> [1] TRUE
# }
```
