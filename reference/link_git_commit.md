# Link an instrument to its current Git commit

Records the current Git commit SHA and subject line for `repo_path`. It
is a pointer into Git history, where a reviewer reads what changed and
why.

## Usage

``` r
link_git_commit(instrument, repo_path = ".", path = NULL)
```

## Arguments

- instrument:

  An `sframe` object.

- repo_path:

  Character. Path to check for a Git repository. Defaults to the current
  working directory.

- path:

  Character or `NULL`. The instrument's `.sframe` file, relative to
  `repo_path`. When given, the instrument is compared with the file as
  committed at HEAD.

## Value

A list with `linked` (logical), and when `linked` is `TRUE`, `commit`
(the full commit SHA), `message` (the commit's subject line), `path`,
and `verified` (logical). `reason` explains an unlinked result
(`"git not found"` or `"not a git repository"`) or an unverified one.

## Details

Given `path`, the tracked `.sframe` file, it also compares the
instrument with that file as committed at HEAD, and sets
`verified = TRUE` only when their content hashes match. Without `path`,
nothing is compared and `verified` is `FALSE`. A verified link shows the
instrument matches a committed file. It does not show who wrote the
instrument or when, beyond what the commit itself records.

Git is entirely optional. When `repo_path` is not inside a Git
repository, or the `git` executable is not on the `PATH`, this returns a
clear, non-error result with `linked = FALSE` rather than aborting – the
rest of surveyframe never requires Git.

## See also

[`amend_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/amend_sframe.md),
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)

## Examples

``` r
item  <- sf_item("q1", "How satisfied are you?", type = "text")
instr <- sf_instrument("Demo", components = list(item))
link_git_commit(instr, repo_path = tempdir())
#> $linked
#> [1] FALSE
#> 
#> $reason
#> [1] "not a git repository"
#> 
```
