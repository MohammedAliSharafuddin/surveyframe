# Create a reference

Builds one bibliographic reference as a CSL-JSON record, the format that
Zotero, Mendeley and pandoc share. Attach references to an instrument
with
[`add_references()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/add_references.md)
or through `sf_instrument(components = )`, cite them in text as `[@id]`,
and
[`render_report()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/render_report.md)
lists every cited reference once, at the end of the report.

## Usage

``` r
sf_reference(
  id,
  title,
  author = NULL,
  year = NULL,
  type = "article-journal",
  container = NULL,
  volume = NULL,
  issue = NULL,
  pages = NULL,
  publisher = NULL,
  edition = NULL,
  editor = NULL,
  doi = NULL,
  url = NULL,
  version = NULL,
  language = NULL,
  cited_by = NULL
)
```

## Arguments

- id:

  Character. The citation key, for example `"cohen_1988"`. Starts with a
  letter, digit or underscore, as pandoc requires.

- title:

  Character. The work's title.

- author:

  Character vector of names written `"Family, Given"`, or a single
  organisation name written `"{R Core Team}"` in braces. `NULL` when the
  work has no named author.

- year:

  Integer or character. Year of publication.

- type:

  Character. A CSL item type: `"article-journal"` (default), `"book"`,
  `"chapter"`, `"paper-conference"`, `"report"`, `"thesis"`,
  `"webpage"`, `"software"`, `"dataset"`, `"manuscript"` or
  `"document"`.

- container:

  Character. The journal, or the book a chapter is in.

- volume, issue, pages:

  Character. Volume, issue and page range, for example `"591-611"`, or
  an article number.

- publisher:

  Character. Publisher, or for a thesis the institution.

- edition:

  Character. Edition, for example `"2"`.

- editor:

  Character vector of editor names, written as for `author`.

- doi:

  Character. The bare DOI, leaving off the `https://doi.org/` prefix.

- url:

  Character. A web address.

- version:

  Character. A software version.

- language:

  Character. The work's language as a code, for example `"fr"`. Set it
  for a work in another language: a citation style title-cases English
  titles only, and would otherwise capitalise "et" or "ir" in a French
  or Lithuanian journal name.

- cited_by:

  Character vector. Where the instrument cites this reference:
  `"instrument"`, `"item:<id>"`, `"scale:<id>"`, `"plan:<block id>"` or
  `"model:<id>"`. Optional.

## Value

An object of class `sf_reference`.

## See also

[`read_bibtex()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/read_bibtex.md),
[`add_references()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/add_references.md),
[`sframe_references()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sframe_references.md)

## Examples

``` r
ref <- sf_reference(
  id = "cronbach_1951", type = "article-journal",
  author = "Cronbach, L. J.", year = 1951,
  title = "Coefficient alpha and the internal structure of tests",
  container = "Psychometrika", volume = "16", issue = "3",
  pages = "297-334", cited_by = "scale:satisfaction"
)
ref$id
#> [1] "cronbach_1951"
```
