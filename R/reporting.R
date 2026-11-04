#' Choosing a report
#'
#' The 12 report functions split into 2 shapes, and the split is what tells
#' them apart.
#'
#' # Data in, object out
#'
#' These compute and return an object you can read, coerce with
#' [as.data.frame()] and often plot.
#'
#' | Function | Answers |
#' | --- | --- |
#' | [sframe_codebook()] | what the instrument declares, as tables |
#' | [sframe_descriptives_results()] | the distribution of each variable |
#' | [sframe_missing_data_results()] | what is missing, and in what pattern |
#' | [sframe_quality_results()] | which responses the declared checks flagged |
#' | [sframe_reliability_results()] | alpha and omega per scale |
#' | [sframe_item_results()] | how each item behaves inside its scale |
#' | [sframe_efa_readiness_results()] | whether the data suit a factor analysis |
#' | [sframe_validity_results()] | convergent and discriminant validity |
#' | [sframe_assumption_results()] | whether a planned test's assumptions hold |
#' | [sframe_posthoc_results()] | which pairs differ after an omnibus test |
#'
#' Each returns its primary table through [as.data.frame()], with the rest
#' reachable through the accessors in [sframe_accessors]. A failure is carried in
#' the object as an error field, so a report keeps rendering around it.
#'
#' # Object or data in, file out
#'
#' | Function | Writes |
#' | --- | --- |
#' | [render_report()] | a whole document, computing its sections from the data |
#' | [render_results()] | a document from analysis results you already have |
#'
#' Reach for [render_results()] where [run_analysis_plan()] has already run,
#' and [render_report()] to go from responses to a document in one call.
#'
#' @name sframe_reports
#' @seealso [run_analysis_plan()], [sframe_plots]
#' @family Report functions
NULL

# codebook_report.R

# Remove the scratch directories Chrome leaves in tempdir() after a
# chrome_print() call. `before` is the listing taken immediately before the
# call, so only entries created during it are considered, and of those only
# the ones matching Chrome's own naming are removed.
sframe_clean_chrome_detritus <- function(before) {
  after <- list.files(tempdir(), all.files = TRUE, no.. = TRUE)
  new   <- setdiff(after, before)
  chrome <- grep("^(com\\.google\\.Chrome\\.|scoped_dir|\\.com\\.google\\.Chrome\\.)",
                 new, value = TRUE)
  if (length(chrome)) {
    unlink(file.path(tempdir(), chrome), recursive = TRUE, force = TRUE)
  }
  invisible(chrome)
}

#' Generate a survey codebook from an instrument object
#'
#' Produces a structured codebook listing all items, their types, choice sets,
#' scale membership, and reverse-coding status. The codebook can be rendered
#' as HTML or Markdown.
#'
#' @param instrument An `sframe` object.
#' @param format Character. Output format. Either `"html"` or `"md"`.
#'   With `"md"`, the codebook also carries itself as Markdown text, in
#'   `markdown`, and `print()` writes that text.
#'
#' @return An object of class `sframe_codebook`, a list with elements
#'   `instrument_meta`, `items_table`, `choices_table`, `scales_table`,
#'   `plan_table`, `models_table` and `format`, and with `format = "md"`,
#'   `markdown`: one character string holding the whole codebook as Markdown,
#'   with a pipe table per component. Save it with
#'   `writeLines(cb$markdown, "codebook.md")`. With `"html"`, `print()`
#'   shows a compact summary, and `render_report()` includes the codebook in a
#'   full report.
#' @export
#' @seealso [render_report()]
#'
#' @examples
#' cs    <- sframe_choice_set("ag5", 1:5,
#'            c("Strongly disagree", "Disagree", "Neutral",
#'              "Agree", "Strongly agree"))
#' i1    <- sframe_item("sat_1", "Item 1", type = "likert",
#'                  choice_set = "ag5", scale_id = "sat")
#' i2    <- sframe_item("sat_2", "Item 2", type = "likert",
#'                  choice_set = "ag5", scale_id = "sat")
#' scale <- sframe_scale("sat", "Satisfaction", items = c("sat_1", "sat_2"))
#' instr <- sframe_instrument("Demo Survey", components = list(cs, i1, i2, scale))
#'
#' cb <- sframe_codebook(instr)
#' print(cb)
#' md <- sframe_codebook(instr, format = "md")
#' cat(substr(md$markdown, 1, 200))
#' nrow(sframe_get_items(cb))
#' nrow(sframe_get_scales(cb))
#' @family Report functions
sframe_codebook <- function(instrument, format = c("html", "md")) {
  sframe_check_instrument(instrument)
  format <- rlang::arg_match(format)

  item_ids <- vapply(instrument$items, function(i) i$id, character(1))

  # Build reverse map
  reverse_map <- stats::setNames(
    vapply(instrument$items, function(i) isTRUE(i$reverse), logical(1)),
    item_ids
  )
  scale_map <- stats::setNames(
    vapply(instrument$items, function(i) i$scale_id %||% "", character(1)),
    item_ids
  )

  # The 5 tables come from the shared builders in as_data_frame.R, so the
  # codebook and as.data.frame() on the instrument cannot drift apart.
  items_table <- sframe_items_table(instrument)

  choices_table <- sframe_choices_table(instrument)

  scales_table <- sframe_scales_table(instrument)

  # The pre-declared analysis plan and the measurement models belong in the
  # codebook, so one document fully records the instrument a study used.
  plan_table <- sframe_plan_table(instrument)

  models_table <- sframe_models_table(instrument)

  out <- structure(
    list(
      instrument_meta = instrument$meta,
      items_table     = items_table,
      choices_table   = choices_table,
      scales_table    = scales_table,
      plan_table      = plan_table,
      models_table    = models_table,
      format          = format
    ),
    class = "sframe_codebook"
  )
  # format = "md" used to change nothing, so a host asking for Markdown got
  # the printed text table (Ethos request 9).
  if (identical(format, "md")) out$markdown <- sframe_codebook_markdown(out)
  out
}

# A data frame as a Markdown pipe table, cells escaped.
sframe_md_table <- function(df) {
  if (!is.data.frame(df) || nrow(df) == 0) return("None.")
  cell <- function(v) {
    v <- vapply(v, function(e) paste(as.character(unlist(e)), collapse = ", "), character(1))
    v[is.na(v)] <- ""
    gsub("\\|", "\\\\|", gsub("[\r\n]+", " ", v))
  }
  body <- vapply(seq_len(nrow(df)), function(r) {
    paste0("| ", paste(vapply(df, function(col) cell(col[r]), character(1)), collapse = " | "), " |")
  }, character(1))
  c(paste0("| ", paste(cell(names(df)), collapse = " | "), " |"),
    paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
    body)
}

sframe_codebook_markdown <- function(cb) {
  m <- cb$instrument_meta %||% list()
  meta_line <- function(label, value) {
    value <- paste(as.character(unlist(value)), collapse = ", ")
    if (length(value) && nzchar(value)) paste0("- **", label, ":** ", value)
  }
  lines <- c(
    paste0("# Codebook: ", m$title %||% "Untitled"), "",
    meta_line("Version", m$version), meta_line("Authors", m$authors),
    meta_line("Languages", m$languages), meta_line("Description", m$description), "",
    "## Items", "", sframe_md_table(cb$items_table), "",
    "## Choice sets", "", sframe_md_table(cb$choices_table), "",
    "## Scales", "", sframe_md_table(cb$scales_table), "",
    "## Analysis plan", "", sframe_md_table(cb$plan_table), "",
    "## Models", "", sframe_md_table(cb$models_table)
  )
  paste(lines, collapse = "\n")
}

#' Enrich a codebook's items table for display
#'
#' Replaces `items_table`'s `choice_set` id with the choice set's actual
#' response options ("1 = Strongly disagree; 2 = Disagree; ...") and its
#' `scale_id` with the scale's label, so each row of the printed codebook is
#' self-contained. [sframe_codebook()] itself keeps the raw ids, for joining
#' `items_table` to `choices_table`/`scales_table` programmatically. This
#' enrichment is for the rendered document, where a reader should not need
#' to cross-reference a separate table just to see what "1" means on a
#' scale shared by many items.
#'
#' @param cb An `sframe_codebook` object from [sframe_codebook()].
#' @return A data.frame, `cb$items_table` with `choice_set` and `scale_id`
#'   replaced by display text.
#' @noRd
#' @seealso [sframe_codebook()]
#' @examples
#' demo <- sframe_demo("tourism_services")
#' cb <- sframe_codebook(demo$instrument)
#' head(sframe_codebook_items_display(cb))
#' @family SurveyStudio helpers
sframe_codebook_items_display <- function(cb) {
  stopifnot(inherits(cb, "sframe_codebook"))
  items_d <- cb$items_table
  scale_label_of <- function(id) {
    if (is.null(id) || !nzchar(id)) return("")
    hit <- cb$scales_table$label[cb$scales_table$id == id]
    if (length(hit)) hit[1] else id
  }
  options_of <- function(cs_id) {
    if (is.null(cs_id) || !nzchar(cs_id)) return("")
    rows <- cb$choices_table[cb$choices_table$choice_set_id == cs_id, , drop = FALSE]
    if (nrow(rows) == 0) return(cs_id)
    paste(sprintf("%s = %s", rows$value, rows$label), collapse = "; ")
  }
  items_d$scale_id <- vapply(items_d$scale_id, scale_label_of, character(1))
  items_d$choice_set <- vapply(items_d$choice_set, options_of, character(1))
  items_d
}

#' @exportS3Method print sframe_codebook
print.sframe_codebook <- function(x, ...) {
  if (!is.null(x$markdown)) {
    cat(x$markdown, "\n", sep = "")
    return(invisible(x))
  }
  cat(sprintf("Codebook: %s v%s\n", x$instrument_meta$title,
              x$instrument_meta$version))
  cat(sprintf("  %d items  |  %d choice sets  |  %d scales\n",
              nrow(x$items_table), nrow(unique(x$choices_table["choice_set_id"])),
              nrow(x$scales_table)))
  cat("\nItems:\n")
  print(x$items_table[, c("id", "label", "type", "scale_id", "reverse")])
  invisible(x)
}


# render_report.R

#' Render a reproducible survey report
#'
#' Generates an HTML report that includes the instrument codebook, data
#' quality summary, reliability diagnostics, and analysis-plan content.
#' Quarto is the report engine. Without Quarto, surveyframe writes a short
#' plain results page with the numbers, tables, charts and APA result lines,
#' under a banner that links to the Quarto installation page. That page gets
#' no new features and is not promised to match the Quarto report.
#'
#' @section Which Quarto:
#' The first copy of Quarto that runs `quarto --version` is used, searched in
#' this order: the executable named by the `QUARTO_PATH` environment
#' variable, `quarto` on the PATH, `RSTUDIO_QUARTO` (set inside RStudio), the
#' copy bundled with RStudio, then the copy bundled with Positron. RStudio and
#' Positron do not put their copies on the PATH, so a report rendered outside
#' them found none before 0.4.3. `QUARTO_PATH` takes the path of the
#' executable itself, as in the quarto package. The Quarto report gives the
#' version used and where it was found, and the returned path carries the
#' executable as its `"quarto"` attribute. `options(surveyframe.use_quarto =
#' FALSE)` uses the built-in engine whatever is installed.
#'
#' @param instrument An `sframe` object.
#' @param data A `tibble` or `data.frame` of responses, or NULL to generate a
#'   codebook-only report.
#' @param output_file Character or NULL. The output file path. When NULL, a
#'   temporary file is written and its path returned.
#' @param output_path Character or NULL. Alias for `output_file`. If both are
#'   supplied, `output_file` takes precedence.
#' @param format Character. Output format: `"html"` (default), `"pdf"`,
#'   `"docx"` (Word), `"odt"` (OpenDocument) or `"qmd"` (the Quarto source). Word and OpenDocument go
#'   through Quarto, styled by bundled APA 7 reference documents (Times New
#'   Roman 12, double spacing, APA headings), and stop with a message when
#'   Quarto is not found. PDF goes through Quarto and LaTeX when a LaTeX
#'   engine is found (TinyTeX, or xelatex, lualatex or pdflatex on the PATH),
#'   through the Typst Quarto bundles otherwise, and without Quarto prints the
#'   built-in HTML page through [pagedown::chrome_print()], which needs the
#'   pagedown package (in Suggests) and a local Chrome or Chromium. The
#'   returned path's `"converter"` attribute names the route:
#'   `"quarto-latex"`, `"quarto-typst"`, `"pagedown"`, or `"quarto"` for
#'   Word and OpenDocument. Every route renders offline.
#'   `"qmd"` writes the Quarto source of the report as a folder, named by
#'   `output_file` (a trailing `.qmd` is dropped), which must be new or empty:
#'   `report.qmd`, the `.sframe`, `responses.csv`, the bibliography and its
#'   style, the results record and `manifest.json`, and no `_quarto.yml`. Open
#'   `report.qmd` in RStudio or Positron and render it. It recomputes every
#'   number from the folder's files and checks them, through
#'   [sframe_report_source()]. Writing the folder needs no Quarto.
#' @param include_quality Logical. Whether to include the data quality report.
#'   Requires `data`. Defaults to `TRUE`.
#' @param include_reliability Logical. Whether to include reliability
#'   diagnostics. Requires `data`. Defaults to `TRUE`.
#' @param include_codebook Logical. Whether to include the instrument codebook.
#'   Defaults to `TRUE`.
#' @param include_missing Logical. Whether to include the missing-data report.
#'   Requires `data`. Defaults to `TRUE`.
#' @param include_descriptives Logical. Whether to include descriptive
#'   statistics. Requires `data`. Defaults to `TRUE`.
#' @param include_analysis Logical. Whether to include analysis-plan results
#'   when `data` are supplied and the instrument has an `analysis_plan`.
#' @param include_models Logical. Whether to include saved model JSON and
#'   generated syntax blocks. Defaults to `TRUE`.
#' @param plot_palette One of `"web"` (brand colours, for on-screen reading)
#'   or `"print"` (black, grey, and white, for a journal-ready or
#'   print-friendly report). Applied to every chart the report embeds.
#'   See `sframe_brand()`.
#' @param show_code Logical. Whether each result carries a folded "Show R code"
#'   block with the statistical call that produced it, built by
#'   [sframe_syntax_result()] from the same resolved specification the analysis ran.
#'   Defaults to `TRUE`. A method [sframe_syntax_result()] does not cover shows no
#'   block, rather than a guess at the call.
#' @param references Optional further [sframe_reference()] records, for example
#'   the works a host cites in the written interpretations, which are cited
#'   in text as `[@id]`. The instrument's own references
#'   ([sframe_add_references()]) and the methods' references are always included.
#' @param title Character or `NULL`. The report's title. Defaults to the
#'   instrument's title.
#' @param authors Character vector or `NULL`. The report's authors, shown under
#'   the title. Defaults to the instrument's authors, and is left out when
#'   there are none.
#' @param figures List or `NULL`. Size, resolution and format for every figure
#'   in the report: any of `width` and `height` in inches, `dpi`, and `format`,
#'   `"png"` or `"svg"` inside the report. For example
#'   `list(width = 6.5, height = 4, dpi = 300)`. Absent entries keep each
#'   engine's own default. Defaults to the `surveyframe.figures` option, so a
#'   host can set it once with `options(surveyframe.figures = list(dpi = 300))`.
#' @param figure_dir Character or `NULL`. A directory to write each analysis
#'   plan chart into as its own file, through [sframe_save_figures()], at the
#'   size, resolution and format in `figures`, where `format` may also be
#'   `"tiff"`, `"jpeg"` or `"pdf"`. Needs `data`. Defaults to 300 dpi at
#'   7 by 4.5 inches where `figures` names none.
#' @param open Logical. Whether to show the finished report: in the viewer
#'   pane of RStudio, Positron or VS Code, and in the web browser otherwise.
#'   Defaults to `TRUE` in an interactive session and `FALSE` in a script.
#'   Nothing opens during a knitr or Quarto render.
#' @param csl The citation style of the references: a bundled style name,
#'   `"apa"` (APA 7, the default), `"chicago-author-date"`, `"harvard"`
#'   (Cite Them Right), `"ieee"` or `"mla"`, or the path to a Citation
#'   Style Language (`.csl`) file, such as one saved from
#'   https://www.zotero.org/styles. Styles are never fetched from the network.
#'   The style's name and sha256 go into the results record and the
#'   manifest, and a `.qmd` report folder holds a copy named for it, so a
#'   rerun uses that copy. The built-in engine formats APA 7 only and says so
#'   when another style is asked for. An unknown name stops with the list of
#'   the 5.
#'
#' @section Results record, manifest and provenance:
#' Beside every report `render_report()` writes 2 files named after it. For
#' `report.html` they are `report_results.json`, the plan results as
#' canonical JSON (sorted keys, full precision, no timestamp, so the same
#' instrument and responses give the same file), and `report_manifest.json`,
#' the sha256 of the instrument content, the responses, the results record and
#' the report as generated, with the surveyframe and R versions and the time.
#' A report edited later, as a Word copy is meant to be, no longer matches
#' its recorded hash, while the results record still does. The Provenance
#' section at the top of the report gives the instrument hash and whether
#' [read_sframe()] verified it, the number of amendments, the responses sha256
#' and the results record's sha256. The responses are hashed as JSON by
#' column, so the hash belongs to the values, not to a file.
#'
#' @section References:
#' The Quarto report cites in text, author and year, and lists every work it
#' cites once, in a References section at the end, formatted by pandoc's
#' citation processor in the chosen style. That covers the methods' own
#' references, the sources the instrument cites for its items, scales, plan
#' blocks and models, and `references`. The built-in HTML engine, used when
#' Quarto is unavailable, lists the methods' references the same way.
#' @param interpretations Named list or NULL. Written interpretations keyed
#'   by analysis-plan block id, added after the results are known. Each
#'   block's section prints the hypotheses and planned decision rule it
#'   declared before its result, with or without an entry. An entry prints
#'   after the result under "Interpretation (written after the results)",
#'   in place of any interpretation the block holds. Interpretations are
#'   report content only and are never written into the instrument.
#'
#' @return The output file path, invisibly.
#' @export
#' @seealso [sframe_codebook()], [sframe_quality_results()], [sframe_reliability_results()]
#'
#' @examples
#' instr <- read_sframe(
#'   system.file("extdata", "tourism_services_demo.sframe",
#'               package = "surveyframe")
#' )
#' responses <- read_responses(
#'   system.file("extdata", "tourism_services_responses.csv",
#'               package = "surveyframe"),
#'   instr,
#'   respondent_id = "respondent_id",
#'   submitted_at = "submitted_at",
#'   meta_cols = "started_at"
#' )
#' \donttest{
#' old <- options(surveyframe.use_quarto = FALSE)
#' out <- tryCatch(
#'   render_report(
#'     instr,
#'     data = responses,
#'     output_file = tempfile(fileext = ".html"),
#'     include_reliability = FALSE,
#'     include_analysis = FALSE
#'   ),
#'   finally = options(old)
#' )
#' file.exists(out)
#' }
#' @family Report functions
render_report <- function(
    instrument,
    data              = NULL,
    output_file       = NULL,
    output_path       = NULL,
    format            = c("html", "pdf", "docx", "odt", "qmd"),
    include_quality   = TRUE,
    include_reliability = TRUE,
    include_codebook  = TRUE,
    include_missing   = TRUE,
    include_descriptives = TRUE,
    include_analysis  = TRUE,
    include_models    = TRUE,
    plot_palette      = c("web", "print"),
    interpretations   = NULL,
    show_code         = TRUE,
    references        = NULL,
    csl               = NULL,
    title             = NULL,
    authors           = NULL,
    figures           = getOption("surveyframe.figures"),
    figure_dir        = NULL,
    open              = interactive()
) {
  sframe_check_instrument(instrument)
  # Figure size, resolution and format (Ethos request 19). The built-in engine
  # reads them from .sframe_figure_env, the Quarto template from its params.
  figures <- sframe_figure_settings(figures)
  old_figures <- .sframe_figure_env$settings
  .sframe_figure_env$settings <- figures
  on.exit(.sframe_figure_env$settings <- old_figures, add = TRUE)
  # The study's own title and authors, where every report read "Survey
  # Research Report" whatever the study (Ethos request 23).
  report_title <- as.character(title %||% instrument$meta$title %||% "Survey report")[1]
  report_authors <- as.character(authors %||% instrument$meta$authors %||% character(0))
  report_authors <- report_authors[!is.na(report_authors) & nzchar(trimws(report_authors))]
  plot_palette <- rlang::arg_match(plot_palette)
  interpretations <- sframe_clean_interpretations(interpretations)

  # Each plan chart as its own file, for a journal submission.
  if (!is.null(figure_dir)) {
    if (is.null(data)) {
      rlang::abort("`figure_dir` needs `data`, since the charts are drawn from the responses.",
                   class = "sframe_error")
    }
    chart_results <- run_analysis_plan(data, instrument, plots = TRUE,
                                       plot_palette = plot_palette)
    saved <- sframe_save_figures(chart_results, figure_dir,
                        width = figures$width %||% 7, height = figures$height %||% 4.5,
                        dpi = figures$dpi %||% 300, format = figures$format %||% "png")
    rlang::inform(paste0("Saved ", length(saved), " chart file",
                         if (length(saved) == 1) "" else "s", " in ",
                         normalizePath(figure_dir, mustWork = FALSE), "."),
                  class = "sframe_report_progress")
  }

  format <- rlang::arg_match(format)
  dest <- output_file %||% output_path %||%
    tempfile(fileext = paste0(".", format))
  dest <- path.expand(dest)
  # The citation style: a bundled name or a .csl file, never fetched (8b-R).
  csl_style <- sframe_resolve_csl(csl)
  style_obj <- list(sframe_style_manifest_object(csl_style))

  # QUARTO_PATH, the PATH, then RStudio's and Positron's bundled copies (T3).
  use_quarto <- isTRUE(getOption("surveyframe.use_quarto", TRUE))
  quarto <- if (use_quarto) sframe_quarto_find() else list(path = NA_character_)
  quarto_bin <- quarto$path
  template <- system.file("templates", "report.qmd", package = "surveyframe")
  has_quarto <- use_quarto && !is.na(quarto_bin) && file.exists(template)
  # Word and OpenDocument are written by pandoc inside Quarto, so they need it.
  if (format %in% c("docx", "odt") && !has_quarto) {
    rlang::abort(
      paste0(if (identical(format, "docx")) "A Word" else "An OpenDocument",
             " report needs Quarto, which was not found. Install it from ",
             "https://quarto.org/docs/get-started/ or use format = 'html'."),
      class = c("sframe_missing_quarto", "sframe_error"))
  }
  # PDF (owner 2026-10-31, coordinator 2026-11-04): Quarto through LaTeX when
  # a LaTeX engine is found, else through the Typst Quarto bundles, and
  # without Quarto the built-in page printed by pagedown.
  quarto_to <- format
  converter <- if (format %in% c("docx", "odt")) "quarto" else NULL
  if (identical(format, "pdf") && has_quarto) {
    if (sframe_latex_available()) {
      converter <- "quarto-latex"
    } else {
      quarto_to <- "typst"
      converter <- "quarto-typst"
    }
  }

  # Without Quarto, PDF builds the built-in HTML page exactly as the html
  # path does, then prints it through Chrome. Requires pagedown (Suggests)
  # and a local Chrome or Chromium.
  if (identical(format, "pdf") && !has_quarto) {
    if (!requireNamespace("pagedown", quietly = TRUE)) {
      rlang::abort(
        "Package 'pagedown' is needed for PDF output. Install it, or use format = 'html'.",
        class = c("sframe_missing_package", "sframe_error")
      )
    }
    html_tmp <- tempfile(fileext = ".html")
    on.exit(unlink(c(html_tmp, unlist(sframe_record_paths(html_tmp))), force = TRUE), add = TRUE)
    # The HTML render's return carries which engine built the content, and it
    # used to be discarded, so a PDF said nothing about how it was produced.
    # Its own message named the intermediate HTML file too, which is a path the
    # caller never asked for and which is deleted on the way out.
    html_res <- withCallingHandlers(
      render_report(
        instrument, data = data, output_file = html_tmp, format = "html",
        include_quality = include_quality,
        include_reliability = include_reliability,
        include_codebook = include_codebook,
        include_missing = include_missing,
        include_descriptives = include_descriptives,
        include_analysis = include_analysis, open = FALSE,
        include_models = include_models,
        plot_palette = plot_palette,
        interpretations = interpretations,
        show_code = show_code,
        references = references, csl = csl,
        title = title, authors = authors, figures = figures
      ),
      sframe_report_engine = function(m) invokeRestart("muffleMessage")
    )
    content_engine <- attr(html_res, "engine") %||% "html"
    # Chrome writes its own scratch directories into tempdir() and does not
    # remove them, which R CMD check reports as detritus in the temp
    # directory. Only entries that appear during this call and match Chrome's
    # own naming are removed, so nothing else in tempdir() is touched.
    before <- list.files(tempdir(), all.files = TRUE, no.. = TRUE)
    on.exit(sframe_clean_chrome_detritus(before), add = TRUE)

    printed <- tryCatch(
      pagedown::chrome_print(input = html_tmp, output = dest),
      error = function(e) {
        rlang::abort(
          paste0("PDF printing failed: ", conditionMessage(e),
                 ". pagedown::chrome_print() needs a local Chrome or Chromium; use format = 'html' if none is available."),
          class = "sframe_error"
        )
      }
    )
    # The results record the HTML render wrote goes beside the PDF, and the
    # manifest records the PDF as generated.
    record_paths <- sframe_record_paths(dest)
    file.copy(sframe_record_paths(html_tmp)$results, record_paths$results, overwrite = TRUE)
    sframe_write_manifest(dest, instrument, data, record_paths$results, extra = style_obj,
                          rendering = list(engine = content_engine, converter = "pagedown"))
    attr(dest, "engine") <- content_engine
    attr(dest, "converter") <- "pagedown"
    rlang::inform(
      paste0("Report rendered with the ",
             if (identical(content_engine, "quarto")) "Quarto" else "built-in HTML",
             " engine and printed to PDF with pagedown: ",
             normalizePath(dest, mustWork = FALSE)),
      class = "sframe_report_engine"
    )
    return(invisible(dest))
  }

  output_dir <- dirname(dest)
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  }
  output_dir <- normalizePath(output_dir, mustWork = FALSE)
  output_name <- basename(dest)

  # The plan results, computed once for both engines and the results record
  # (8b-R, NAMING decision 6). The record holds the numbers a reviewer
  # verifies, and the provenance block in the report gives its sha256.
  plan_results <- NULL
  if (!is.null(data) && isTRUE(include_analysis) &&
      length(instrument$analysis_plan %||% list()) > 0) {
    plan_results <- tryCatch(
      run_analysis_plan(data, instrument,
                        plots = requireNamespace("ggplot2", quietly = TRUE),
                        plot_palette = plot_palette),
      error = function(e) e)
  }
  record_json <- sframe_results_record_json(
    if (is.list(plan_results) && !inherits(plan_results, "error")) plan_results else list(),
    instrument, sframe_report_seed(data, instrument, include_analysis), style = csl_style)
  style <- csl_style$path
  bibliography_extra <- c(sframe_flatten_references(list(references %||% list())),
                          Filter(Negate(is.null), lapply(names(.sframe_citation_csl),
                                                         sframe_builtin_reference)))

  # The Quarto source (NAMING decision 6): a folder that renders the report
  # again from its own .sframe and responses, and checks its numbers.
  if (identical(format, "qmd")) {
    folder <- sub("\\.qmd$", "", dest)
    sframe_write_report_source(
      folder, instrument, data, record_json,
      front = sframe_report_front(report_title, report_authors, use_citations = TRUE,
                                  csl_file = paste0(csl_style$name, ".csl")),
      params = list(
        include_quality = include_quality && !is.null(data),
        include_reliability = include_reliability && !is.null(data),
        include_codebook = include_codebook,
        include_missing = include_missing && !is.null(data),
        include_descriptives = include_descriptives && !is.null(data),
        include_analysis = include_analysis, include_models = include_models,
        show_code = show_code, plot_palette = plot_palette, use_citations = TRUE,
        fig_width = as.character(figures$width %||% ""),
        fig_height = as.character(figures$height %||% ""),
        fig_dpi = as.character(figures$dpi %||% ""),
        fig_format = if (identical(figures$format, "svg")) "svg" else ""),
      style = csl_style, bibliography_extra = bibliography_extra,
      interpretations = interpretations)
    folder <- normalizePath(folder, mustWork = FALSE)
    rlang::inform(paste0("Report source written to ", folder,
                         ". Open report.qmd in RStudio or Positron and render it."),
                  class = "sframe_report_engine")
    attr(folder, "engine") <- "qmd"
    return(invisible(folder))
  }

  record_paths <- sframe_record_paths(dest)
  sframe_write_text(record_json, record_paths$results)
  provenance <- sframe_report_provenance(instrument, data,
                                         sframe_sha256_file(record_paths$results))

  if (has_quarto) {
    render_dir <- tempfile("surveyframe-report-")
    dir.create(render_dir, recursive = TRUE, showWarnings = FALSE)
    on.exit(unlink(render_dir, recursive = TRUE, force = TRUE), add = TRUE)
    render_input <- file.path(render_dir, "report.qmd")
    # report.scss turns off the theme's web font, so the render fetches
    # nothing from the network.
    theme_scss <- file.path(dirname(template), "report.scss")
    # The APA 7 reference documents style the Word and OpenDocument reports.
    ref_docs <- file.path(dirname(template), c("apa-reference.docx", "apa-reference.odt"))
    if (!file.copy(template, render_input, overwrite = TRUE) ||
        !file.copy(theme_scss, file.path(render_dir, "report.scss"), overwrite = TRUE) ||
        !all(file.copy(ref_docs, render_dir, overwrite = TRUE))) {
      rlang::abort(
        "Could not prepare the Quarto report template for rendering.",
        class = "sframe_error"
      )
    }

    # Write instrument and data to temp RDS for the template to read
    tmp_instr <- tempfile(fileext = ".rds")
    tmp_data  <- tempfile(fileext = ".rds")
    tmp_interp <- tempfile(fileext = ".rds")
    temp_rds <- tmp_instr
    saveRDS(instrument, tmp_instr)
    if (!is.null(data)) {
      saveRDS(data, tmp_data)
      temp_rds <- c(temp_rds, tmp_data)
    } else {
      tmp_data <- ""
    }
    if (length(interpretations) > 0) {
      saveRDS(interpretations, tmp_interp)
      temp_rds <- c(temp_rds, tmp_interp)
    } else {
      tmp_interp <- ""
    }
    # What each block declared, and its written interpretation, computed here
    # (D12). Quarto renders against the installed package, so the template
    # calls exported functions only and reads these as data.
    tmp_decl <- tempfile(fileext = ".rds")
    saveRDS(sframe_plan_declarations(instrument, interpretations), tmp_decl)
    temp_rds <- c(temp_rds, tmp_decl)
    # The codebook table, charts and plan results, computed once here so the
    # template only prints them (naming decision 6).
    tmp_content <- tempfile(fileext = ".rds")
    saveRDS(sframe_report_content(instrument, data, plot_palette,
                                  include_analysis = include_analysis,
                                  results = plan_results), tmp_content)
    temp_rds <- c(temp_rds, tmp_content)
    tmp_prov <- tempfile(fileext = ".rds")
    saveRDS(provenance, tmp_prov)
    temp_rds <- c(temp_rds, tmp_prov)
    on.exit(unlink(temp_rds, force = TRUE), add = TRUE)

    params <- list(
      instrument_path     = tmp_instr,
      data_path           = tmp_data,
      interpretations_path = tmp_interp,
      declarations_path   = tmp_decl,
      content_path        = tmp_content,
      provenance_path     = tmp_prov,
      include_quality     = include_quality && !is.null(data),
      include_reliability = include_reliability && !is.null(data),
      include_codebook    = include_codebook,
      include_missing     = include_missing && !is.null(data),
      include_descriptives = include_descriptives && !is.null(data),
      include_analysis    = include_analysis,
      include_models      = include_models,
      show_code           = show_code,
      plot_palette        = plot_palette,
      instrument_hash     = sframe_hash_value(instrument),
      # Passed rather than looked up inside the template: Quarto renders in a
      # separate R session against the installed package, which is not
      # necessarily the build doing the rendering.
      analysis_seed       = as.character(
        sframe_report_seed(data, instrument, include_analysis)),
      # Empty means the template's own default.
      fig_width           = as.character(figures$width %||% ""),
      fig_height          = as.character(figures$height %||% ""),
      fig_dpi             = as.character(figures$dpi %||% ""),
      fig_format          = if (identical(figures$format, "svg")) "svg" else "",
      # Which Quarto rendered the report, and where it was found (T3).
      quarto_found        = sframe_quarto_label(quarto)
    )

    # The bibliography (0.4.3): every reference the instrument carries, the
    # host's, and all built-in method references. pandoc lists only those
    # actually cited, so carrying the full method set costs nothing.
    if (nzchar(style) && file.exists(style)) {
      sframe_bibliography(instrument, extra = bibliography_extra,
                          file = file.path(render_dir, "references.json"))
      file.copy(style, file.path(render_dir, "style.csl"), overwrite = TRUE)
      params$use_citations <- TRUE
    }

    param_args <- sframe_quarto_param_args(params)
    # Title, authors and the date label go in the front matter of the render
    # copy, as the bibliography does: Quarto 1.8 ignores a bibliography given
    # as -M metadata on the command line. Quarto labels the date "Published"
    # by default, which a report that has not been published should not say.
    # JSON strings are valid YAML, so toJSON() quotes each value safely.
    front <- sframe_report_front(report_title, report_authors, isTRUE(params$use_citations))
    qmd <- readLines(render_input, warn = FALSE)
    qmd <- qmd[!grepl("^title:", qmd) | seq_along(qmd) > grep("^---", qmd)[2]]
    qmd <- append(qmd, front, after = 1L)
    writeLines(qmd, render_input)
    # Render with the working directory set to the render dir so Quarto creates
    # its intermediate `*_files/libs` there and can inline them for
    # embed-resources. Output next to the input, then copy to the destination.
    # Using --output-dir elsewhere makes the self-contained bundling fail to
    # find quarto.js (it is created relative to the working directory).
    out_ext <- if (identical(format, "html")) "html" else format
    rendered <- file.path(render_dir, paste0("report.", out_ext))
    # Quarto prints nothing while it works, which for a minute looks like a hang.
    rlang::inform("Rendering the report with Quarto. This usually takes under a minute.",
                  class = "sframe_report_progress")
    quarto_log <- character(0)
    quarto_ok <- tryCatch({
      old_wd <- getwd()
      on.exit(setwd(old_wd), add = TRUE)
      setwd(render_dir)
      status <- suppressWarnings(system2(
        quarto_bin,
        args = c(
          "render", "report.qmd",
          "--to", quarto_to,
          "--output", basename(rendered),
          param_args
        ),
        stdout = TRUE,
        stderr = TRUE
      ))
      setwd(old_wd)
      quarto_log <- status
      (is.null(attr(status, "status")) || identical(attr(status, "status"), 0L)) &&
        file.exists(rendered)
    }, error = function(e) FALSE)

    if (isTRUE(quarto_ok)) {
      # Numbered tables and figures with titles and alt text, as the
      # built-in engine writes them (CX-22).
      if (identical(format, "html")) {
        html <- readLines(rendered, warn = FALSE, encoding = "UTF-8")
        writeLines(sframe_quarto_apa_floats(html), rendered, useBytes = TRUE)
      }
      if (file.copy(rendered, dest, overwrite = TRUE)) {
        sframe_write_manifest(dest, instrument, data, record_paths$results, extra = style_obj,
                              rendering = list(engine = "quarto", converter = converter,
                                               quarto = quarto$version))
        res <- sframe_report_result(dest, "quarto", open)
        attr(res, "quarto") <- quarto_bin
        if (!is.null(converter)) attr(res, "converter") <- converter
        return(invisible(res))
      }
    }
    # The built-in engine writes HTML only, so a failed Word, OpenDocument or
    # PDF render stops with what Quarto said.
    if (!identical(format, "html")) {
      tail_log <- utils::tail(as.character(quarto_log), 40)
      rlang::abort(
        c(paste0("Quarto could not render the ", format, " report."),
          i = paste(tail_log, collapse = "\n")),
        class = c("sframe_quarto_failed", "sframe_error"))
    }
  }

  .render_report_html(
    instrument          = instrument,
    data                = data,
    output_path         = dest,
    include_quality     = include_quality && !is.null(data),
    include_reliability = include_reliability && !is.null(data),
    include_codebook    = include_codebook,
    include_missing     = include_missing && !is.null(data),
    include_descriptives = include_descriptives && !is.null(data),
    include_analysis    = include_analysis,
    include_models      = include_models,
    plot_palette        = plot_palette,
    interpretations     = interpretations,
    show_code           = show_code,
    title               = report_title,
    authors             = report_authors,
    references          = references,
    csl                 = csl_style$path,
    plan_results        = plan_results,
    provenance          = provenance
  )
  sframe_write_manifest(dest, instrument, data, record_paths$results, extra = style_obj,
                        rendering = list(engine = "html", converter = NULL))

  sframe_report_result(dest, "html", open)
}

# The sources of the scales in a table, under it, or "" when none cites any.
sframe_scale_sources_html <- function(instrument, scale_ids) {
  scales <- instrument$scales %||% list()
  parts <- vapply(scale_ids, function(id) {
    sc <- Filter(function(s) identical(s$id, id), scales)
    cite <- sframe_cite_text(sframe_cited_keys(instrument, paste0("scale:", id)))
    if (!nzchar(cite)) return("")
    label <- if (length(sc)) sc[[1]]$label %||% id else id
    paste0(htmltools_escape(label), " ", cite)
  }, character(1))
  parts <- parts[nzchar(parts)]
  if (!length(parts)) return("")
  sprintf("<p class=\"tbl-note\"><em>Sources.</em> %s.</p>", paste(parts, collapse = "; "))
}

# The banner at the top of a built-in report (owner 2026-10-31). Quarto is the
# report engine, and the built-in engine writes a short plain results page
# with no parity promise, so the page says so and where to get Quarto.
sframe_builtin_banner <- function() {
  paste0("<div class=\"sf-banner\" role=\"note\">This is the short results page ",
         "surveyframe writes without Quarto. ",
         "<a href=\"https://quarto.org/docs/get-started/\" target=\"_blank\" rel=\"noopener\">",
         "Install Quarto for the full formatted report</a>.</div>")
}

# The front matter render_report() adds to a report.qmd: title, authors, the
# date label and the bibliography. Quarto 1.8 ignores a bibliography given as
# -M metadata on the command line, so it goes here. Quarto labels the date
# "Published" by default, which a report that has not been published should
# not say. JSON strings are valid YAML, so toJSON() quotes each value safely,
# and a title holding a quote, a colon, a hash or a newline then --- stays a
# single string and leaves the front matter whole.
sframe_report_front <- function(title, authors, use_citations, csl_file = "style.csl") {
  yaml_str <- function(s) as.character(jsonlite::toJSON(s, auto_unbox = TRUE))
  c(
    paste0("title: ", yaml_str(title)),
    if (length(authors)) c("author:", paste0("  - ", vapply(authors, yaml_str, character(1)))),
    "language:", "  title-block-published: \"Rendered\"",
    if (isTRUE(use_citations)) c("bibliography: references.json", paste0("csl: ", yaml_str(csl_file)),
                                 "link-citations: true")
  )
}

# The "-P name:value" arguments for a Quarto render.
#
# system2() joins its args into one command line, so a value containing a space
# used to split into several shell arguments. Each value is quoted here, which
# keeps it whole whatever it holds.
#
# Only the parameters that name a file are normalised. normalizePath() used to
# run over every character value, so the seed text "not applicable, no analysis
# plan run" was rewritten as an absolute path under the working directory.
sframe_quarto_param_names_path <- c("instrument_path", "data_path",
                                    "interpretations_path", "declarations_path",
                                    "content_path", "provenance_path")

sframe_quarto_param_args <- function(params) {
  unlist(lapply(names(params), function(name) {
    value <- params[[name]]
    if (is.logical(value)) {
      value <- tolower(as.character(value))
    }
    if (is.character(value) && name %in% sframe_quarto_param_names_path &&
        nzchar(value)) {
      value <- normalizePath(value, winslash = "/", mustWork = FALSE)
    }
    c("-P", shQuote(paste0(name, ":", value)))
  }), use.names = FALSE)
}

# The 2 engines produce different documents from identical inputs, so a caller
# needs to know which one ran. It is announced 3 ways: a message for the
# console, an attribute for a script, and a line in the report for whoever
# opens the file later.
# The seed a report's numbers were produced under. run_analysis_plan() records
# it on its result; when there is no plan to run there is nothing random to
# reproduce, so the field says so rather than printing a seed that governed
# nothing.
# The seed the report's analysis ran under, or a statement that none did.
# Asking only whether data and a plan existed meant a report rendered with
# include_analysis = FALSE printed a seed beside the instrument hash, which
# reads as provenance for an analysis that never ran.
sframe_report_seed <- function(data, instrument, include_analysis = TRUE) {
  if (!isTRUE(include_analysis) || is.null(data) ||
      length(instrument$analysis_plan %||% list()) == 0) {
    return("not applicable, no analysis plan run")
  }
  formals(run_analysis_plan)$seed %||% "unseeded"
}

sframe_report_result <- function(dest, engine, open = FALSE) {
  # The full path: a relative output_file named only its basename, and a
  # reader could not tell where the report had gone.
  rlang::inform(
    paste0("Report rendered with the ",
           if (identical(engine, "quarto")) "Quarto" else "built-in HTML",
           " engine: ", normalizePath(dest, mustWork = FALSE)),
    class = "sframe_report_engine"
  )
  if (isTRUE(open)) sframe_show(dest)
  attr(dest, "engine") <- engine
  invisible(dest)
}

# Drop entries that cannot be rendered: unnamed values, non-character
# values, and empty strings. Returns a named list of single strings, or an
# empty list, so downstream code can index it without further checks.
sframe_clean_interpretations <- function(interpretations) {
  if (is.null(interpretations)) return(list())
  if (!is.list(interpretations) && !is.character(interpretations)) {
    rlang::abort(
      "`interpretations` must be a named list or named character vector keyed by analysis-plan block id.",
      class = "sframe_error"
    )
  }
  interpretations <- as.list(interpretations)
  keys <- names(interpretations) %||% character(0)
  out <- list()
  for (i in seq_along(interpretations)) {
    key <- if (i <= length(keys)) keys[[i]] else ""
    value <- interpretations[[i]]
    if (!nzchar(key %||% "")) next
    if (!is.character(value) || length(value) != 1 || is.na(value)) next
    value <- trimws(value)
    if (!nzchar(value)) next
    out[[key]] <- value
  }
  out
}

.render_report_html <- function(
    instrument,
    data = NULL,
    output_path,
    include_quality = TRUE,
    include_reliability = TRUE,
    include_codebook = TRUE,
    include_missing = TRUE,
    include_descriptives = TRUE,
    include_analysis = TRUE,
    include_models = TRUE,
    plot_palette = "web",
    interpretations = list(),
    show_code = TRUE,
    title = NULL,
    authors = character(0),
    references = NULL,
    csl = NULL,
    plan_results = NULL,
    provenance = NULL
) {
  meta <- instrument$meta %||% list()
  sections <- character(0)

  # What the report was built from, first (NAMING decision 6).
  if (!is.null(provenance)) {
    sections <- c(sections, sprintf("<section><h2>Provenance</h2>%s</section>",
                                    .render_report_table(provenance, "Provenance")))
  }

  if (isTRUE(include_codebook)) {
    cb <- sframe_codebook(instrument)
    codebook_parts <- c(
      "<h2>Codebook</h2>",
      .render_report_table(sframe_codebook_items_display(cb), "Survey items",
        col.names = c("ID", "Label", "Type", "Response options", "Scale",
                      "Reverse", "Required"))
    )
    if (nrow(cb$scales_table) > 0) {
      codebook_parts <- c(
        codebook_parts,
        .render_report_table(cb$scales_table, "Scale definitions",
          col.names = c("ID", "Label", "Method", "Items (n)", "Item IDs"))
      )
    }
    if (!is.null(cb$plan_table) && nrow(cb$plan_table) > 0) {
      codebook_parts <- c(
        codebook_parts,
        .render_report_table(cb$plan_table, "Pre-declared analysis plan",
          col.names = c("ID", "Research question", "Method", "Variables",
                        "Decision rule"))
      )
    }
    if (!is.null(cb$models_table) && nrow(cb$models_table) > 0) {
      codebook_parts <- c(
        codebook_parts,
        .render_report_table(cb$models_table, "Measurement and structural models",
          col.names = c("ID", "Label", "Type", "Engine", "Constructs", "Paths"))
      )
    }
    # Where each scale and item comes from, cited in text, as the Quarto
    # report lists them (8b-R).
    sources <- c(
      vapply(instrument$scales %||% list(), function(sc) {
        cite <- sframe_cite_text(sframe_cited_keys(instrument, paste0("scale:", sc$id)))
        if (nzchar(cite)) sprintf("<li>Scale <em>%s</em>: %s</li>",
                                  htmltools_escape(sc$label %||% sc$id), cite) else ""
      }, character(1)),
      vapply(instrument$items %||% list(), function(it) {
        cite <- sframe_cite_text(sframe_cited_keys(instrument, paste0("item:", it$id)))
        if (nzchar(cite)) sprintf("<li>Item <code>%s</code>: %s</li>",
                                  htmltools_escape(it$id), cite) else ""
      }, character(1)))
    sources <- sources[nzchar(sources)]
    if (length(sources)) {
      codebook_parts <- c(codebook_parts, "<p><strong>Sources</strong></p>",
                          paste0("<ul>", paste(sources, collapse = ""), "</ul>"))
    }
    sections <- c(sections, sprintf("<section>%s</section>", paste(codebook_parts, collapse = "\n")))
  }

  if (isTRUE(include_quality)) {
    qr <- tryCatch(sframe_quality_results(data, instrument), error = function(e) e)
    quality_html <- if (inherits(qr, "error")) {
      sprintf("<p>%s</p>", htmltools_escape(conditionMessage(qr)))
    } else {
      summary_tbl <- data.frame(
        Metric = c("Respondents", "Items", "Flagged", "Flag rate"),
        Value = c(
          qr$summary$n_respondents,
          qr$summary$n_items,
          qr$summary$n_flagged,
          sprintf("%.1f%%", qr$summary$flag_rate * 100)
        ),
        stringsAsFactors = FALSE
      )
      # When there is no straight-lining chart, say why rather than leaving a
      # gap. An absent chart otherwise reads as "nothing was flagged" when it
      # can equally mean "no scale was long enough to check".
      note <- sframe_quality_plot_note(qr)
      paste(
        "<h2>Data Quality</h2>",
        .render_report_table(summary_tbl, "Quality summary"),
        if (!is.null(note)) sprintf("<p class=\"sf-note\">%s</p>",
                                    htmltools_escape(note)) else NULL,
        collapse = "\n"
      )
    }
    sections <- c(sections, sprintf("<section>%s</section>", quality_html))
  }

  if (isTRUE(include_missing)) {
    mr <- tryCatch(sframe_missing_data_results(data, instrument), error = function(e) e)
    missing_html <- if (inherits(mr, "error")) {
      sprintf("<h2>Missing Data</h2><p>%s</p>", htmltools_escape(conditionMessage(mr)))
    } else {
      patterns_display <- mr$patterns[, intersect(c("description", "n", "percent"), names(mr$patterns)), drop = FALSE]
      paste(
        "<h2>Missing Data</h2>",
        .render_report_table(mr$item_missing, "Item-wise missingness"),
        .render_report_table(mr$respondent_missing, "Respondent-wise missingness"),
        .render_report_table(patterns_display, "Missing-data patterns",
                             col.names = c("Pattern", "n", "Percent")),
        .render_report_table(mr$scale_missing_rules, "Scale missing rules"),
        collapse = "\n"
      )
    }
    sections <- c(sections, sprintf("<section>%s</section>", missing_html))
  }

  if (isTRUE(include_descriptives)) {
    dr <- tryCatch(
      sframe_descriptives_results(data, variables = intersect(vapply(instrument$items, function(i) i$id, character(1)), colnames(data))),
      error = function(e) e
    )
    descriptives_html <- if (inherits(dr, "error")) {
      sprintf("<h2>Descriptives</h2><p>%s</p>", htmltools_escape(conditionMessage(dr)))
    } else {
      paste(
        "<h2>Descriptives</h2>",
        .render_report_table(dr$table, "Descriptive statistics"),
        collapse = "\n"
      )
    }
    sections <- c(sections, sprintf("<section>%s</section>", descriptives_html))

    dist_html <- tryCatch(
      .render_report_distributions(instrument, data, plot_palette = plot_palette),
      error = function(e) ""
    )
    if (nzchar(dist_html)) sections <- c(sections, dist_html)
  }

  if (isTRUE(include_reliability)) {
    rr <- tryCatch(sframe_reliability_results(data, instrument), error = function(e) e)
    reliability_html <- if (inherits(rr, "error")) {
      sprintf(
        "<h2>Reliability</h2><p>%s</p>",
        htmltools_escape(conditionMessage(rr))
      )
    } else if (length(rr) == 0) {
      "<h2>Reliability</h2><p>No scales with enough data were available for reliability analysis.</p>"
    } else {
      rel_tbl <- do.call(
        rbind,
        lapply(rr, function(scale) {
          data.frame(
            Scale = paste0(scale$label, " (", scale$scale_id, ")"),
            Items = scale$n_items,
            N = scale$n,
            Alpha = if (!is.null(scale$alpha)) sprintf("%.3f", scale$alpha) else "n/a",
            Omega_h = if (!is.null(scale$omega_h)) sprintf("%.3f", scale$omega_h) else "n/a",
            Omega_t = if (!is.null(scale$omega_t)) sprintf("%.3f", scale$omega_t) else "n/a",
            stringsAsFactors = FALSE
          )
        })
      )
      paste(
        "<h2>Reliability</h2>",
        "<p>Cronbach alpha and McDonald's omega by scale.</p>",
        .render_report_table(rel_tbl, "Scale reliability"),
        sframe_scale_sources_html(instrument, vapply(rr, function(s) s$scale_id, character(1))),
        collapse = "\n"
      )
    }
    sections <- c(sections, sprintf("<section>%s</section>", reliability_html))
  }

  if (isTRUE(include_analysis) && length(instrument$analysis_plan %||% list()) > 0) {
    analysis_html <- .render_report_analysis_section(instrument, data,
                                                     plot_palette = plot_palette,
                                                     interpretations = interpretations,
                                                     show_code = show_code,
                                                     results = plan_results)
    sections <- c(sections, sprintf("<section>%s</section>", analysis_html))
  }

  if (isTRUE(include_models) && length(instrument$models %||% list()) > 0) {
    sections <- c(
      sections,
      sprintf("<section>%s</section>", .render_report_model_section(instrument))
    )
  }

  # The engine and the analysis seed sit next to the hash deliberately. The
  # hash says which instrument this report describes. The engine says which of
  # the 2 renderers produced it, since they produce different documents. The
  # seed says what would be needed to get the same numbers again, because
  # every bootstrap interval in the report depends on it.
  repro_tbl <- data.frame(
    Field = c("Instrument version", "Instrument hash", "Rendering engine", "Analysis seed", "Generated"),
    Value = c(
      instrument$meta$version %||% "",
      sframe_hash_value(instrument),
      "built-in HTML",
      as.character(sframe_report_seed(data, instrument, include_analysis)),
      format(Sys.time(), "%Y-%m-%d %H:%M %Z")
    ),
    stringsAsFactors = FALSE
  )
  sections <- c(
    sections,
    sprintf(
      "<section><h2>Reproducibility</h2>%s%s</section>",
      .render_report_table(repro_tbl, "Reproducibility details"),
      .render_report_amendments(instrument)
    )
  )

  # Citations and the References list (D8). The built-in engine has no
  # citation processor, so [@key] is resolved here and the list is APA 7.
  ref_index <- sframe_reference_index(instrument, references)
  body_text <- paste(sections, collapse = "\n")
  sections <- sframe_resolve_citations_html(body_text, ref_index)
  refs_html <- sframe_references_section_html(ref_index, body_text)
  sections <- c(sections, if (nzchar(refs_html)) refs_html)
  if (!is.null(csl) && nzchar(csl) && !identical(basename(csl), "apa.csl")) {
    rlang::inform("The built-in HTML engine formats references in APA 7 only. Use Quarto for another citation style.",
                  class = "sframe_report_progress")
  }

  title <- htmltools_escape(title %||% meta$title %||% "Survey report")
  subtitle <- paste(c(
    if (length(authors)) htmltools_escape(paste(authors, collapse = ", ")),
    sprintf("Version %s", htmltools_escape(meta$version %||% ""))
  ), collapse = " &middot; ")

  html <- sprintf(
    paste(
      "<!DOCTYPE html>",
      "<html lang=\"en\">",
      "<head>",
      "<meta charset=\"UTF-8\">",
      "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">",
      "<title>%s</title>",
      "<style>",
      "/* Brand palette as CSS variables: a theme is a one-line change here.",
      "   --sf-accent is the AA-safe teal (>= 4.5:1 on white). */",
      ":root {",
      "  --sf-ink: #1a1a2e;",
      "  --sf-accent: #0e7c7a;",
      "  --sf-muted: #52606d;",
      "  --sf-faint: #5b6b80;",
      "  --sf-line: #d9e2ec;",
      "  --sf-panel: #f8fafc;",
      "  --sf-rule: #000;",
      "}",
      "body { font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif; max-width: 900px; margin: 0 auto; padding: 32px 20px; color: var(--sf-ink); line-height: 1.6; }",
      "h1, h2, h3 { color: var(--sf-ink); }",
      "a { color: var(--sf-accent); }",
      "section { margin: 0 0 28px; padding-bottom: 12px; border-bottom: 1px solid var(--sf-line); }",
      "table { display: block; overflow-x: auto; max-width: 100%%; border-collapse: collapse; margin: 16px 0 2px; font-size: .93em; }",
      "caption { text-align: left; font-size: .95em; margin-bottom: 4px; }",
      "figure { margin: 16px 0; } figcaption { font-size: .95em; margin-bottom: 4px; }",
      "thead tr { border-top: 2px solid var(--sf-rule); border-bottom: 1px solid var(--sf-rule); }",
      "tbody tr:last-child td { border-bottom: 2px solid var(--sf-rule); }",
      "th, td { border: none; padding: 5px 12px; text-align: left; vertical-align: top; }",
      "th { font-weight: 700; background: none; }",
      ".tbl-note { font-size: .85em; font-style: italic; color: #333; margin-top: 3px; margin-bottom: 16px; }",
      ".meta { color: var(--sf-muted); margin-bottom: 24px; }",
      ".rq-block { margin: 18px 0; padding: 14px; background: var(--sf-panel); border: 1px solid var(--sf-line); border-radius: 6px; }",
      ".apa { color: var(--sf-ink); }",
      ".references .csl-entry { padding-left: 2em; text-indent: -2em; margin-bottom: 8px; }",
      ".csl-entry.sf-note { color: var(--sf-muted); font-style: italic; }",
      ".sf-banner { margin: 0 0 24px; padding: 10px 14px; border: 1px solid var(--sf-line); border-left: 4px solid var(--sf-accent); background: var(--sf-panel); }",
      ".sf-foot { text-align: center; font-size: 12px; color: var(--sf-faint); margin-top: 48px; padding-top: 16px; border-top: 1px solid #eee; }",
      ".sf-foot a { color: var(--sf-accent); font-weight: 600; text-decoration: none; }",
      "/* Print (and PDF via pagedown): paginate cleanly, keep a result",
      "   block and a table's header with its rows, drop the panel tint. */",
      "@media print {",
      "  body { max-width: none; padding: 0; }",
      "  section { border-bottom: none; }",
      "  .rq-block { break-inside: avoid; background: none; border: 1px solid var(--sf-line); }",
      "  table { display: table; overflow-x: visible; }",
      "  thead { display: table-header-group; }",
      "  tr, img { break-inside: avoid; }",
      "  h2, h3 { break-after: avoid; }",
      "  a { color: var(--sf-ink); text-decoration: none; }",
      "}",
      "</style>",
      "</head>",
      "<body>",
      "<h1>%s</h1>",
      "<p class=\"meta\">%s</p>",
      "%s",
      "%s",
      "<div class=\"sf-foot\">Built with <a href=\"https://cran.r-project.org/package=surveyframe\" target=\"_blank\" rel=\"noopener\">surveyframe</a></div>",
      "</body>",
      "</html>",
      sep = "\n"
    ),
    title,
    title,
    subtitle,
    paste0(sframe_resolve_citations(
      sframe_sources_html(instrument, "instrument", "Draws on") |>
        sub(pattern = "^<p>", replacement = "<p class=\"meta\">"), ref_index),
      sframe_builtin_banner()),
    paste(sections, collapse = "\n")
  )

  # Every table and figure numbered in reading order (CX-22).
  writeLines(sframe_apa_number_floats(html), output_path)
  invisible(output_path)
}

.render_report_analysis_section <- function(instrument, data = NULL,
                                            plot_palette = "web",
                                            interpretations = list(),
                                            show_code = TRUE,
                                            results = NULL) {
  plan <- instrument$analysis_plan %||% list()
  if (length(plan) == 0) {
    return("")
  }

  # What the block declared before the data prints above its result, and
  # the interpretation below it, labelled as written after the results. An
  # interpretation never stands in for an empty decision rule (D12).
  # The sources of the hypotheses beside them, then the block's own (8b-R).
  declaration_html <- function(b) {
    id <- as.character(b$block_id %||% b$id %||% "")[1]
    paste0(sframe_declaration_html(b),
           sframe_sources_html(instrument, paste0("hypothesis:", id), "Sources for the hypotheses"),
           sframe_sources_html(instrument, paste0("plan:", id)))
  }
  interp_html <- function(block) {
    text <- sframe_written_interpretation(block, interpretations)
    if (!nzchar(text)) return("")
    sprintf("<p><strong>%s:</strong> %s</p>", sframe_interpretation_label,
            htmltools_escape(text))
  }

  blocks <- if (is.null(data)) {
    vapply(seq_along(plan), function(i) {
      rq <- plan[[i]]
      declared <- declaration_html(rq)
      extra <- interp_html(rq)
      paste(
        c(
          "<div class=\"rq-block\">",
          sprintf("<h3>RQ %d: %s</h3>", i,
                  htmltools_escape(rq$research_question %||% paste("Research Question", i))),
          sprintf("<p><strong>Planned test:</strong> %s</p>",
                  htmltools_escape(sframe_analysis_method(rq))),
          sprintf("<p><strong>Variables:</strong> %s</p>",
                  htmltools_escape(paste(sframe_analysis_vars(rq), collapse = ", "))),
          if (nzchar(declared)) declared,
          if (nzchar(extra)) extra,
          "</div>"
        ),
        collapse = "\n"
      )
    }, character(1))
  } else {
    # render_report() passes the results it computed once for both engines.
    if (is.null(results)) {
      results <- tryCatch(
        run_analysis_plan(data, instrument,
                          plots = requireNamespace("ggplot2", quietly = TRUE),
                          plot_palette = plot_palette),
        error = function(e) e
      )
    }
    if (inherits(results, "error")) {
      return(sprintf(
        "<h2>Analysis Plan</h2><p>%s</p>",
        htmltools_escape(conditionMessage(results))
      ))
    }

    vapply(seq_along(results), function(i) {
      result <- results[[i]]
      # The table and chart are titled by the block and its question, as
      # sframe_format_result() titles them, not by a generic "Results table" (CX-22).
      rq_label <- sframe_result_float_title(result, i)
      table_html <- ""
      if (is.data.frame(result$table)) {
        table_html <- .render_report_table(result$table, rq_label)
      }
      # The chart for this result renders directly under its table, as one
      # unit per research question, rather than in a separate section.
      plot_html <- ""
      if (!is.null(result$plot)) {
        img <- tryCatch(
          .render_report_ggplot_png(result$plot,
                                    alt = paste("Chart of the result for", rq_label)),
          error = function(e) NULL
        )
        if (!is.null(img)) plot_html <- sframe_apa_figure(img, rq_label)
      }
      # Regression diagnostics are four separate panels, not one plot, so
      # they render as four stacked images beneath the main chart rather
      # than forcing a combined-grob dependency just to arrange them.
      if (is.list(result$diagnostic_plots)) {
        diag_imgs <- vapply(seq_along(result$diagnostic_plots), function(di) {
          img <- tryCatch(
            .render_report_ggplot_png(
              result$diagnostic_plots[[di]],
              alt = sprintf("Regression diagnostic panel %d for %s", di, rq_label)),
            error = function(e) NULL
          )
          sframe_apa_figure(img, sprintf("Regression diagnostic panel %d for %s",
                                         di, rq_label)) %||% ""
        }, character(1))
        plot_html <- paste(c(plot_html, diag_imgs[diag_imgs != ""]), collapse = "\n")
      }
      declared <- declaration_html(result)
      extra <- interp_html(result)
      # A CFA/SEM/PLS-SEM syntax block has no table or chart to show: its
      # entire output is the generated syntax text, so that goes where a
      # table or chart normally would rather than leaving the block blank.
      syntax_html <- if (!is.null(result$syntax)) {
        sprintf("<pre><code>%s</code></pre>", htmltools_escape(result$syntax))
      } else ""
      # sframe_extract_quotes() attaches $quotes (topic, rank, respondent, quote) to
      # a topic-model result: a second, separate table alongside the main
      # $table rather than a substitute for it, so it renders through the
      # same generic table builder under its own heading (todo_text_analysis.md's
      # ground-truth note: mirror the $syntax pattern, don't build a new
      # render_text_section()).
      quotes_html <- if (is.data.frame(result$quotes) && nrow(result$quotes) > 0) {
        .render_report_table(result$quotes, "Representative quotes")
      } else ""
      # A second table the result carries: the quanteda runner's leading
      # features, or a moderation's conditional slopes at the moderator's own
      # values. Both were retained by their runner, asked for by its prompt,
      # and rendered by neither engine. Same pattern as $quotes and $syntax.
      supplement <- sframe_result_supplement(result)
      features_html <- if (!is.null(supplement)) {
        .render_report_table(supplement$table, supplement$caption)
      } else ""
      # The statistical call behind the numbers, folded away so it is there for
      # a reader who wants it and out of the way for one who does not. Showing
      # the run_analysis_plan() wrapper instead would say nothing about which
      # test ran with which options.
      code_html <- if (isTRUE(show_code)) {
        code <- sframe_syntax_result(result)
        if (is.null(code)) "" else sprintf(
          "<details class=\"sf-code\"><summary>Show R code</summary><pre><code>%s</code></pre></details>",
          htmltools_escape(paste(code, collapse = "\n")))
      } else ""
      paste(
        c(
          "<div class=\"rq-block\">",
          sprintf("<h3>RQ %d: %s</h3>", i,
                  htmltools_escape(result$research_question %||% paste("Research Question", i))),
          if (nzchar(declared)) declared,
          if (sframe_result_exploratory(result))
            sprintf("<p class=\"sf-exploratory\"><strong>%s</strong></p>", sframe_exploratory_label),
          sprintf("<p class=\"apa\"><strong>Result:</strong> %s</p>",
                  if (!is.null(result$apa)) sframe_apa_html(result$apa)
                  else htmltools_escape(result$error %||% "")),
          table_html,
          plot_html,
          syntax_html,
          features_html,
          quotes_html,
          code_html,
          if (nzchar(extra)) extra,
          "</div>"
        ),
        collapse = "\n"
      )
    }, character(1))
  }

  paste(c("<h2>Analysis Plan</h2>", sframe_study_html(instrument), blocks), collapse = "\n")
}

# The study at the head of the plan section (D13 in the report, 8b-R): the
# problem, its sources, and the trace from objectives to research questions.
sframe_study_html <- function(instrument) {
  s <- sframe_report_study(instrument)
  if (is.null(s)) return("")
  paste(c(
    "<div class=\"sf-study\">", "<h3>Study</h3>",
    if (length(s$problem)) sprintf("<p><strong>Problem:</strong> %s</p>", htmltools_escape(s$problem)),
    sframe_sources_html(instrument, "study"),
    if (!is.null(s$trace)) .render_report_table(s$trace, "Objectives and the research questions that serve them"),
    if (length(s$unlinked)) sprintf("<p class=\"tbl-note\">Research questions that name no objective: %s.</p>",
                                    htmltools_escape(s$unlinked)),
    "</div>"), collapse = "\n")
}

.render_report_model_section <- function(instrument) {
  models <- instrument$models %||% list()
  blocks <- vapply(models, function(model) {
    json <- htmltools_escape(sframe_model_json(model, pretty = TRUE))
    syntax <- tryCatch(
      switch(
        model$type,
        cfa = sframe_syntax_cfa(instrument = instrument, model = model),
        cb_sem = sframe_syntax_sem(model, instrument = instrument),
        pls_sem = sframe_syntax_pls(model),
        efa = sframe_syntax_efa(unlist(lapply(sframe_model_constructs(model), function(con) con$items))),
        ""
      ),
      error = function(e) paste0("Model syntax could not be generated: ", conditionMessage(e))
    )
    sprintf(
      paste(
        "<div class=\"rq-block\">",
        "<h3>%s</h3>",
        "<p><strong>Type:</strong> %s &nbsp; <strong>Engine:</strong> %s</p>%s",
        "<h4>Syntax</h4><pre>%s</pre>",
        "<h4>Model JSON</h4><pre>%s</pre>",
        "</div>",
        sep = "\n"
      ),
      htmltools_escape(model$label %||% model$id),
      htmltools_escape(model$type %||% ""),
      htmltools_escape(model$engine %||% ""),
      sframe_sources_html(instrument, paste0("model:", model$id %||% "")),
      htmltools_escape(syntax),
      json
    )
  }, character(1))

  paste(c("<h2>Model Appendix</h2>", blocks), collapse = "\n")
}

# Render a base-R plot to a base64-embedded PNG <img> for the HTML fallback.
.render_report_plot_png <- function(draw, height = 320, alt = "chart") {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  s <- .sframe_figure_env$settings %||% list()
  res <- s$dpi %||% 96
  grDevices::png(tmp, width = (s$width %||% 7.5) * res,
                 height = (s$height %||% (height / 96)) * res, res = res, bg = "white")
  ok <- tryCatch({ draw(); TRUE }, error = function(e) FALSE)
  grDevices::dev.off()
  if (!isTRUE(ok) || !file.exists(tmp)) return(NULL)
  raw <- readBin(tmp, "raw", file.info(tmp)$size)
  sprintf(
    "<img alt=\"%s\" style=\"max-width:100%%;height:auto\" src=\"data:image/png;base64,%s\">",
    htmltools_escape(alt), openssl::base64_encode(raw)
  )
}

# Render a ggplot object to a base64-embedded PNG <img> for the HTML
# fallback, same embedding pattern as .render_report_plot_png() above but
# for the ggplot2 objects run_analysis_plan(plots = TRUE) attaches.
.render_report_ggplot_png <- function(gg, alt = "result chart") {
  if (!requireNamespace("ggplot2", quietly = TRUE)) return(NULL)
  s <- .sframe_figure_env$settings %||% list()
  # An SVG request falls back to PNG where this R cannot write SVG.
  svg <- identical(s$format, "svg") && sframe_svg_available()
  tmp <- tempfile(fileext = if (svg) ".svg" else ".png")
  on.exit(unlink(tmp), add = TRUE)
  ok <- tryCatch({
    ggplot2::ggsave(tmp, gg, width = s$width %||% 7.2, height = s$height %||% 4.2,
                    dpi = s$dpi %||% 110, bg = "white")
    TRUE
  }, error = function(e) FALSE)
  if (!isTRUE(ok) || !file.exists(tmp)) return(NULL)
  raw <- readBin(tmp, "raw", file.info(tmp)$size)
  sprintf(
    "<img alt=\"%s\" style=\"max-width:100%%;height:auto\" src=\"data:image/%s;base64,%s\">",
    htmltools_escape(alt), if (svg) "svg+xml" else "png", openssl::base64_encode(raw)
  )
}

# What the Quarto template prints, computed here inside the namespace
# (naming decision 6): the codebook's display table, the distribution
# charts, and the plan results, each with its supplement table. The
# built-in engine computes the same things with the same functions, so the
# 2 engines report the same numbers. `results` is a character string when
# the plan could not run, and NULL when there is no data or no plan.
sframe_report_content <- function(instrument, data = NULL, plot_palette = "web",
                                  include_analysis = TRUE, results = NULL) {
  items_d <- sframe_codebook_items_display(sframe_codebook(instrument))
  items_d$reverse  <- ifelse(items_d$reverse,  "Yes", "")
  items_d$required <- ifelse(items_d$required, "Yes", "")
  names(items_d) <- c("ID", "Label", "Type", "Response options", "Scale",
                      "Reverse", "Required")
  # render_report() passes the results it computed once for both engines.
  if (inherits(results, "error")) results <- conditionMessage(results)
  if (is.null(results) && !is.null(data) && isTRUE(include_analysis) &&
      length(instrument$analysis_plan) > 0) {
    results <- tryCatch(
      run_analysis_plan(data, instrument,
                        plots = requireNamespace("ggplot2", quietly = TRUE),
                        plot_palette = plot_palette),
      error = function(e) conditionMessage(e))
  }
  if (is.list(results)) {
    # The table and chart titles, escaped for the template's HTML, as
    # the built-in engine titles them (CX-22).
    results <- Map(function(r, i) {
      sup <- sframe_result_supplement(r)
      if (!is.null(sup)) sup$caption_html <- htmltools_escape(sup$caption)
      r["supplement"] <- list(sup)
      title <- sframe_result_float_title(r, i)
      r$caption_html <- htmltools_escape(title)
      r$caption_text <- title
      r$exploratory <- sframe_result_exploratory(r)
      r$exploratory_label <- sframe_exploratory_label
      r$figure_open <- sframe_apa_figure_open(title, paste("Chart of the result for", title))
      r
    }, results, seq_along(results))
  }
  charts <- sframe_report_charts(instrument, data, plot_palette)
  for (k in seq_along(charts)) {
    charts[[k]]$figure_open <- sframe_apa_figure_open(charts[[k]]$title, charts[[k]]$alt)
  }
  # Why a straight-lining chart is absent, escaped for the template (8b-R).
  quality_note <- NULL
  if (!is.null(data)) {
    qr <- tryCatch(sframe_quality_results(data, instrument), error = function(e) NULL)
    note <- if (!is.null(qr)) sframe_quality_plot_note(qr)
    if (!is.null(note)) quality_note <- htmltools_escape(note)
  }
  list(codebook_items = items_d, charts = charts, results = results,
       study = sframe_report_study(instrument),
       amendments = sframe_report_amendments(instrument),
       quality_note = quality_note)
}

# The amendment list in the built-in report, under Reproducibility: the
# version a reader holds and how it got there.
.render_report_amendments <- function(instrument) {
  tab <- sframe_report_amendments(instrument)
  if (is.null(tab)) return("<p>No amendments are recorded.</p>")
  paste0(sprintf("<h3>Amendments (%d)</h3>", nrow(tab)),
         .render_report_table(tab, "Amendments, oldest first"))
}

# Distribution charts (item bars, grouped Likert scales, matrix questions,
# multi-selects and scale scores), one spec per chart. Both report engines
# draw from these specs: the built-in engine embeds each as an image, and
# render_report() hands them to the Quarto template, which only prints them
# (naming decision 6). Each spec has a heading, a figure title, alt text, an
# optional note, and either `plot` (a ggplot) or `draw` (a function drawing
# with base graphics, with `height` in pixels where it needs more room).
sframe_report_charts <- function(instrument, data, plot_palette = "web") {
  if (is.null(data)) return(list())
  theme <- instrument$render$theme %||% "#16B3B1"
  if (!grepl("^#[0-9A-Fa-f]{3,6}$", theme)) theme <- "#16B3B1"
  has_ggplot <- requireNamespace("ggplot2", quietly = TRUE)
  choice_by <- function(id) {
    for (c in instrument$choices %||% list()) if (identical(c$id, id)) return(c)
    NULL
  }
  q_items <- Filter(
    function(i) !(i$type %in% c("section_break", "text_block")),
    instrument$items %||% list()
  )
  specs <- list()
  add <- function(heading, title, alt = title, plot = NULL, draw = NULL,
                  height = NULL, note = NULL) {
    if (is.null(plot) && is.null(draw)) return(invisible())
    specs[[length(specs) + 1L]] <<- list(
      heading = heading, title = title, alt = alt, note = note,
      plot = plot, draw = draw, height = height)
  }
  item_spec <- function(item, plot = NULL, draw = NULL, height = NULL, note = NULL) {
    label <- item$label %||% item$id
    add(label, paste("Distribution of", label), plot = plot, draw = draw,
        height = height, note = note)
  }

  # A scale's separate Likert items get one grouped diverging chart, the
  # same way a matrix question's rows do, instead of scattering a related
  # batch of items across several single-item charts. group_of[[item_id]]
  # points back to which scale's group it belongs to, and rendered_groups
  # tracks which groups have already produced their one chart.
  scale_groups <- sframe_likert_scale_groups(instrument)
  group_of <- character(0)
  for (g in scale_groups) {
    ids <- vapply(g$items, function(i) i$id, character(1))
    group_of[ids] <- g$scale_id
  }
  rendered_groups <- character(0)

  for (item in q_items) {
    t <- item$type
    if (item$id %in% names(group_of)) {
      gid <- group_of[[item$id]]
      if (has_ggplot) {
        if (!gid %in% rendered_groups) {
          rendered_groups <- c(rendered_groups, gid)
          g <- scale_groups[[gid]]
          gg <- sframe_plot_likert_scale(g$items, data, g$choice_set, g$title,
                                         palette = plot_palette)
          add(g$title, paste("Distribution of", g$title), plot = gg)
        }
        # The group's one chart covers every member item.
        next
      }
      # Without ggplot2 there is no grouped chart, and skipping here removed
      # these items' distributions altogether, though the base-graphics
      # single-item chart below can draw every one of them. A missing optional
      # package should cost the grouping, not the information.
    }
    if (identical(t, "matrix")) {
      # A matrix question has no base response column, only one expanded
      # <id>__<row> column per row, so it needs its own existence check and
      # its own chart: every row grouped together, not one chart per row.
      if (has_ggplot) {
        cs <- choice_by(item$choice_set %||% "")
        item_spec(item, plot = sframe_plot_likert_matrix(item, data, cs,
                                                         palette = plot_palette))
      }
      next
    }
    # A multiple-choice question posts one indicator column per option, named
    # item__option, and never a column of its own, so requiring the parent
    # column dropped every collected multi-select from this section. The
    # indicators are counted here and the denominator is stated, since each
    # respondent may pick more than one.
    if (identical(t, "multiple_choice") && !item$id %in% names(data)) {
      cs <- choice_by(item$choice_set %||% "")
      cols <- sframe_item_expansion_columns(instrument, list(item))
      present <- intersect(cols, names(data))
      if (length(present) == 0) next
      picked <- vapply(present, function(cn) {
        sum(as.character(data[[cn]]) %in% c("1", "TRUE", "true", "yes"),
            na.rm = TRUE)
      }, numeric(1))
      labels <- sub(paste0("^", item$id, "__"), "", present)
      if (!is.null(cs)) {
        hit <- match(labels, as.character(cs$values))
        labels[!is.na(hit)] <- cs$labels[hit[!is.na(hit)]]
      }
      names(picked) <- labels
      if (!sum(picked)) next
      item_spec(item, draw = local({
        picked <- picked
        function() {
          op <- graphics::par(mar = c(4, 9, 1, 1)); on.exit(graphics::par(op))
          graphics::barplot(rev(picked), horiz = TRUE, las = 1, col = theme,
                            border = "white", xlab = "Respondents")
        }
      }), note = sprintf("%d respondents, who could pick more than one.", nrow(data)))
      next
    }
    if (!item$id %in% names(data)) next
    col <- data[[item$id]]
    if (t %in% c("likert", "single_choice", "multiple_choice")) {
      cs <- choice_by(item$choice_set %||% "")
      freq <- if (!is.null(cs)) {
        f <- table(factor(col, levels = as.character(cs$values)))
        names(f) <- cs$labels
        f
      } else {
        table(col)
      }
      if (!sum(freq)) next
      if (identical(t, "likert") && length(freq) >= 2) {
        # A Likert item is an ordered agree/disagree scale: a diverging bar
        # shows which way opinion leans, unlike a plain frequency bar.
        item_spec(item, draw = local({
          freq <- freq
          function() sframe_draw_likert_diverging(freq, theme, palette = plot_palette)
        }), height = if (length(freq) <= 5) 320 else 320 + 22 * length(freq))
      } else if (has_ggplot) {
        # Shares theme_surveyframe() (theme_classic()-based) with every
        # other chart in the report.
        item_spec(item, plot = sframe_plot_item_chart(item, col, cs, palette = plot_palette))
      } else {
        item_spec(item, draw = local({
          freq <- freq
          function() {
            op <- graphics::par(mar = c(4, 11, 1, 1)); on.exit(graphics::par(op))
            graphics::barplot(freq, horiz = TRUE, las = 1, col = theme,
                              border = NA, xlab = "Frequency", cex.names = .8)
          }
        }))
      }
    } else if (t %in% c("numeric", "slider", "rating")) {
      num <- suppressWarnings(as.numeric(col)); num <- num[!is.na(num)]
      if (!length(num)) next
      if (has_ggplot) {
        item_spec(item, plot = sframe_plot_item_chart(item, col, NULL, palette = plot_palette))
      } else {
        item_spec(item, draw = local({
          num <- num
          label <- item$label
          function() {
            op <- graphics::par(mar = c(4, 4, 1, 1)); on.exit(graphics::par(op))
            graphics::hist(num, col = theme, border = "white", main = NULL,
                           xlab = label, ylab = "Count", las = 1)
          }
        }))
      }
    }
  }

  # Scale figures plot the scores score_scales() computes, so the method,
  # reversal, weights and min_valid the instrument declares all apply. A row
  # mean of the item columns ignored every one of them, so a declared sum of
  # 2 and 4 was published as 3.
  scale_scores <- NULL
  scale_error <- NULL
  if (length(instrument$scales %||% list()) > 0) {
    scale_scores <- tryCatch(
      score_scales(data, instrument, keep_items = FALSE, keep_meta = FALSE),
      error = function(e) {
        scale_error <<- conditionMessage(e)
        NULL
      })
  }
  for (sc in instrument$scales %||% list()) {
    if (is.null(scale_scores) || !sc$id %in% names(scale_scores)) next
    scores <- scale_scores[[sc$id]]
    scores <- scores[!is.na(scores)]
    if (!length(scores)) next
    label <- sc$label %||% sc$id
    heading <- paste0(label, " (scale score)")
    title <- paste("Distribution of", label, "scale scores")
    alt <- paste(label, "scale score distribution")
    if (has_ggplot) {
      add(heading, title, alt, plot = sframe_plot_scale_chart(scores, label,
                                                              palette = plot_palette))
    } else {
      add(heading, title, alt, draw = local({
        scores <- scores
        function() {
          op <- graphics::par(mar = c(4, 4, 1, 1)); on.exit(graphics::par(op))
          graphics::hist(scores, col = theme, border = "white", main = NULL,
            xlab = paste0(label, " score"), ylab = "Count", las = 1)
          graphics::abline(v = mean(scores), col = "#dc2626", lwd = 2, lty = 2)
        }
      }))
    }
  }
  attr(specs, "scale_error") <- scale_error
  specs
}

# Distribution plots for the built-in HTML engine, each spec embedded as an
# image under its heading.
.render_report_distributions <- function(instrument, data, plot_palette = "web") {
  if (is.null(data)) return("")
  specs <- sframe_report_charts(instrument, data, plot_palette)
  blocks <- character(0)
  if (!is.null(attr(specs, "scale_error"))) {
    blocks <- sprintf("<p><em>Scale scores could not be computed: %s</em></p>",
                      htmltools_escape(attr(specs, "scale_error")))
  }
  for (s in specs) {
    img <- if (!is.null(s$plot)) {
      .render_report_ggplot_png(s$plot, alt = s$alt)
    } else if (!is.null(s$height)) {
      .render_report_plot_png(s$draw, height = s$height, alt = s$alt)
    } else {
      .render_report_plot_png(s$draw, alt = s$alt)
    }
    if (is.null(img)) next
    note <- if (!is.null(s$note)) sprintf("<p class=\"hint\">%s</p>", htmltools_escape(s$note)) else ""
    blocks <- c(blocks, sprintf("<h3>%s</h3>%s%s", htmltools_escape(s$heading), note,
                                sframe_apa_figure(img, s$title)))
  }
  if (!length(blocks)) return("")
  sprintf("<section><h2>Response distributions</h2>%s</section>",
          paste(blocks, collapse = "\n"))
}

# Turn snake_case data-frame names into "Title Case" table headings, e.g.
# "research_question" -> "Research question", "n_items" -> "N items".
# Labels for variable ids while run_analysis_plan() draws its charts, so a
# chart names "Satisfaction" where the instrument says so, and never the bare
# id "sat". Set only for the duration of a plot call, by
# .sframe_with_plot_labels().
.sframe_plot_label_env <- new.env(parent = emptyenv())

.sframe_with_plot_labels <- function(lookup, code, instrument = NULL) {
  old <- .sframe_plot_label_env$lookup
  old_instrument <- .sframe_plot_label_env$instrument
  .sframe_plot_label_env$lookup <- lookup
  .sframe_plot_label_env$instrument <- instrument
  on.exit({
    .sframe_plot_label_env$lookup <- old
    .sframe_plot_label_env$instrument <- old_instrument
  }, add = TRUE)
  force(code)
}

# An item's coded values as its choice labels, in the choice set's order, so
# a chart shows "In person" where the data hold "in_person" (Ethos request
# 20). Codes the set lacks, and every code outside a labelled plot call, stay
# as they are.
.sframe_plot_value_labels <- function(item_id, codes) {
  labs <- sframe_item_value_labels(.sframe_plot_label_env$instrument, item_id)
  codes <- as.character(codes)
  if (!length(labs)) return(factor(codes))
  shown <- ifelse(codes %in% names(labs), unname(labs[codes]), codes)
  factor(shown, levels = unique(c(unname(labs), shown)))
}

.sframe_title_case_names <- function(names) {
  lookup <- .sframe_plot_label_env$lookup
  vapply(names, function(nm) {
    if (length(lookup) && !is.na(nm) && nm %in% names(lookup)) {
      return(unname(lookup[[nm]]))
    }
    words <- strsplit(gsub("_", " ", nm), " ")[[1]]
    if (!length(words)) return(nm)
    words[words == "prop"] <- "proportion"
    words[1] <- paste0(toupper(substring(words[1], 1, 1)), substring(words[1], 2))
    paste(words, collapse = " ")
  }, character(1), USE.NAMES = FALSE)
}

.render_report_table <- function(x, caption = NULL, note = NULL, col.names = NULL) {
  if (!is.data.frame(x) || nrow(x) == 0) {
    return("")
  }

  # Cells as every report engine prints them: p by its own rules, the rest to
  # 2 decimals, blanks for missing values (CX-15).
  x <- sframe_apa_cells(x)

  has_pval <- any(grepl(
    "^p$|^p\\.value$|^p_value$|^Pr\\(>",
    colnames(x),
    ignore.case = TRUE
  ))

  # Headings from the APA layer: symbols set as APA 7 sets them, other names
  # in words, unless the caller supplies its own (CX-24).
  display_names <- if (is.null(col.names)) sframe_apa_headings(colnames(x)) else
    htmltools_escape_each(col.names)

  header <- paste(
    sprintf("<th scope=\"col\">%s</th>", display_names),
    collapse = ""
  )
  rows <- paste(
    apply(x, 1, function(row) {
      cells <- paste(
        sprintf("<td>%s</td>", htmltools_escape_each(as.character(row))),
        collapse = ""
      )
      sprintf("<tr>%s</tr>", cells)
    }),
    collapse = "\n"
  )

  # Numbered with the rest of the document's tables (CX-22).
  cap_html <- if (!is.null(caption) && nzchar(caption)) sframe_apa_caption(caption) else ""

  tbl_html <- sprintf(
    "<table>%s<thead><tr>%s</tr></thead><tbody>%s</tbody></table>",
    cap_html, header, rows
  )

  note_text <- note %||% if (has_pval) {
    "* p < .05, ** p < .01, *** p < .001"
  } else NULL

  note_html <- if (!is.null(note_text) && nzchar(note_text)) {
    sprintf('<p class="tbl-note"><em>Note.</em> %s</p>',
            htmltools_escape(note_text))
  } else ""

  paste0(tbl_html, note_html)
}
