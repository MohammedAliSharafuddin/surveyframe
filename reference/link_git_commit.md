# Link an instrument to its current Git commit

Records the current Git commit SHA and subject line for `repo_path`
alongside the instrument. This does not replace Git history – it is a
pointer into it. The SHA-256 hash
[`write_sframe()`](https://mohammedalisharafuddin.github.io/surveyframe/reference/write_sframe.md)
embeds in the `.sframe` file confirms the file on disk matches what this
specific, already-explained commit produced; a reviewer reads the commit
itself for the "what changed and why."

## Usage

``` r
link_git_commit(instrument, repo_path = ".")
```

## Arguments

- instrument:

  An `sframe` object.

- repo_path:

  Character. Path to check for a Git repository. Defaults to the current
  working directory.

## Value

A list with `linked` (logical), and when `linked` is `TRUE`, `commit`
(the full commit SHA) and `message` (the commit's subject line); when
`linked` is `FALSE`, `reason` (a human-readable explanation:
`"git not found"` or `"not a git repository"`).

## Details

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
