# JSS paper: surveyframe

**Target:** Journal of Statistical Software
**Submission date:** 2026-05-22

---

## Files

| File | Description |
|---|---|
| `surveyframe.Rnw` | Full manuscript — knitr/Sweave + JSS LaTeX template |
| `surveyframe.bib` | BibTeX references |
| `replicate.R` | Self-contained replication script for all results |
| `figures/` | Generated figures (populated on compile) |

---

## How to compile

Requires: R >= 4.1, pdflatex, surveyframe >= 0.3.0, knitr.

```bash
# In this folder:
R -e "knitr::knit('surveyframe.Rnw')"
pdflatex surveyframe
bibtex surveyframe
pdflatex surveyframe
pdflatex surveyframe
```

Or using the `knitr` one-liner:

```r
knitr::knit2pdf("surveyframe.Rnw")
```

---

## Replication (without compiling the PDF)

```bash
Rscript replicate.R
```

Runs all code examples from the manuscript and prints output to the
console. No external data or network access required.

---

## JSS submission checklist

- [ ] Final proofread
- [ ] `pdflatex surveyframe` compiles with zero errors
- [ ] `replicate.R` runs to completion with zero errors
- [ ] Download JSS LaTeX style files (`jss.cls`, `jss.bst`) from
      https://www.jstatsoft.org/style and place in this folder
- [ ] Three submission attachments:
  1. `surveyframe.pdf` — the compiled manuscript
  2. Source code archive — surveyframe package tarball from CRAN or
     `R CMD build` output
  3. `replicate.R` — replication materials
- [ ] After acceptance: add `inst/CITATION` pointing to the JSS DOI
- [ ] After acceptance: convert to vignette with
      `\documentclass[nojss]{jss}` at `vignettes/surveyframe-jss.Rnw`

---

## Positioning note

The core contribution claim is the **proactive workflow architecture**.
The `sframe` object is a methodological contract declared before data
collection. Every competitor tool (SPSS, SmartPLS, lavaan, jamovi) is
reactive: the analysis plan is constructed after data exist. This is
the argument to lead with in the introduction and the comparison table.
