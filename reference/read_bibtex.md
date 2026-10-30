# Read references from BibTeX

Parses BibTeX, the format Google Scholar, Zotero, Mendeley and most
journal pages export, into
[`sf_reference()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_reference.md)
records. Covers the common entry types (`@article`, `@book`,
`@incollection`, `@inbook`, `@inproceedings`, `@techreport`,
`@phdthesis`, `@mastersthesis`, `@misc`, `@online`, `@software`,
`@dataset`, `@unpublished`) and the common fields. Accented letters
written as LaTeX commands are converted. Base R alone.

## Usage

``` r
read_bibtex(file = NULL, text = NULL, cited_by = NULL)
```

## Arguments

- file:

  Path to a `.bib` file.

- text:

  BibTeX as a character string, used instead of `file`, for example an
  entry pasted from Google Scholar.

- cited_by:

  Optional `cited_by` targets given to every entry read, see
  [`sf_reference()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/sf_reference.md).

## Value

A list of `sf_reference` objects, named by citation key. An entry that
fails to parse is skipped with a warning naming it. A key used by more
than one entry is an error that names every repeated key. Entries may be
written `@article{key, ...}` or `@article(key, ...)`.

## Examples

``` r
refs <- read_bibtex(text = "@article{cronbach_1951,
  author  = {Cronbach, Lee J.},
  title   = {Coefficient alpha and the internal structure of tests},
  journal = {Psychometrika},
  year    = {1951},
  volume  = {16},
  number  = {3},
  pages   = {297--334}
}")
names(refs)
#> [1] "cronbach_1951"
```
