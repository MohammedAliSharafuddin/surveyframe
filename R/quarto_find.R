# R/quarto_find.R
#
# Where Quarto lives (session 8b-R, PREP-01, Codex T3). render_report() looked
# only at Sys.which("quarto"), so the copies RStudio and Positron bundle, which
# neither puts on the PATH, went unused, and QUARTO_PATH was ignored. The
# search order:
#   1. QUARTO_PATH, an executable path, as the quarto R package reads it
#   2. the PATH
#   3. RSTUDIO_QUARTO, which an RStudio session sets
#   4. RStudio's bundled copy for the operating system
#   5. Positron's bundled copy for the operating system
# A candidate counts only when `quarto --version` exits 0, never because its
# directory exists. The result names the executable chosen, its version and
# where it was found, and lists every path checked.

.sframe_quarto_env <- new.env(parent = emptyenv())

# The candidate executables, in search order, as a data frame of source and
# path. Duplicates are kept out, so a PATH copy that is also QUARTO_PATH is
# checked once.
sframe_quarto_candidates <- function(sysname = Sys.info()[["sysname"]]) {
  env_path <- function(name) {
    v <- Sys.getenv(name, unset = "")
    if (nzchar(v)) v else character(0)
  }
  on_path <- unname(Sys.which("quarto"))
  on_path <- on_path[nzchar(on_path)]
  home <- path.expand("~")
  ide <- switch(
    sysname,
    Windows = {
      roots <- unique(c(Sys.getenv("ProgramFiles", "C:/Program Files"),
                        file.path(Sys.getenv("LOCALAPPDATA", ""), "Programs")))
      roots <- gsub("\\\\", "/", roots[nzchar(roots)])
      rbind(
        data.frame(source = "RStudio",
                   path = file.path(roots, "RStudio/resources/app/bin/quarto/bin/quarto.exe")),
        data.frame(source = "Positron",
                   path = file.path(roots, "Positron/resources/app/quarto/bin/quarto.exe"))
      )
    },
    Darwin = {
      apps <- c("/Applications", file.path(home, "Applications"))
      rbind(
        data.frame(source = "RStudio",
                   path = file.path(apps, "RStudio.app/Contents/Resources/app/quarto/bin/quarto")),
        data.frame(source = "Positron",
                   path = file.path(apps, "Positron.app/Contents/Resources/app/quarto/bin/quarto"))
      )
    },
    data.frame(
      source = c(rep("RStudio", 3), rep("Positron", 2)),
      path = c("/usr/lib/rstudio/resources/app/bin/quarto/bin/quarto",
               "/usr/lib/rstudio/bin/quarto/bin/quarto",
               "/usr/lib/rstudio-server/bin/quarto/bin/quarto",
               "/usr/share/positron/resources/app/quarto/bin/quarto",
               "/opt/Positron/resources/app/quarto/bin/quarto")
    )
  )
  out <- rbind(
    data.frame(source = rep("QUARTO_PATH", length(env_path("QUARTO_PATH"))),
               path = env_path("QUARTO_PATH")),
    data.frame(source = rep("PATH", length(on_path)), path = on_path),
    data.frame(source = rep("RSTUDIO_QUARTO", length(env_path("RSTUDIO_QUARTO"))),
               path = env_path("RSTUDIO_QUARTO")),
    ide
  )
  out$source <- as.character(out$source)
  out$path <- as.character(out$path)
  out[!duplicated(out$path), , drop = FALSE]
}

# The version a candidate reports, or NA when it is missing, not executable,
# or does not exit 0.
sframe_quarto_version <- function(path) {
  if (!nzchar(path) || !file.exists(path) || dir.exists(path)) return(NA_character_)
  if (file.access(path, 1L) != 0L) return(NA_character_)
  out <- tryCatch(
    suppressWarnings(system2(path, "--version", stdout = TRUE, stderr = FALSE,
                             timeout = 30)),
    error = function(e) structure(character(0), status = 1L)
  )
  status <- attr(out, "status") %||% 0L
  out <- trimws(out[nzchar(trimws(out))])
  if (!identical(as.integer(status), 0L) || length(out) == 0) return(NA_character_)
  out[length(out)]
}

# The Quarto to render with: a list of path (NA when none runs), version,
# source and checked, a data frame of every path tried with its version or
# why it was passed over. Cached for the session against the environment
# variables and PATH it read, so a changed QUARTO_PATH is seen at once.
sframe_quarto_find <- function(candidates = NULL, refresh = FALSE) {
  key <- NULL
  if (is.null(candidates)) {
    key <- paste(Sys.getenv(c("QUARTO_PATH", "PATH", "RSTUDIO_QUARTO")), collapse = "\n")
    hit <- .sframe_quarto_env$found
    if (!isTRUE(refresh) && !is.null(hit) && identical(hit$key, key)) return(hit$value)
    candidates <- sframe_quarto_candidates()
  }
  checked <- data.frame(source = candidates$source, path = candidates$path,
                        state = "not checked", stringsAsFactors = FALSE)
  found <- list(path = NA_character_, version = NA_character_, source = NA_character_)
  for (i in seq_len(nrow(candidates))) {
    p <- candidates$path[i]
    if (!file.exists(p) || dir.exists(p)) {
      checked$state[i] <- "not found"
      next
    }
    v <- sframe_quarto_version(p)
    if (is.na(v)) {
      checked$state[i] <- "did not run"
      next
    }
    checked$state[i] <- v
    found <- list(path = p, version = v, source = candidates$source[i])
    break
  }
  found$checked <- checked
  if (!is.null(key)) .sframe_quarto_env$found <- list(key = key, value = found)
  found
}

# Where the selected Quarto came from, in words, for the report and messages.
sframe_quarto_label <- function(found) {
  if (is.na(found$path %||% NA_character_)) return("not found")
  where <- switch(found$source,
                  QUARTO_PATH = "set by QUARTO_PATH",
                  PATH = "found on the PATH",
                  RSTUDIO_QUARTO = "set by RSTUDIO_QUARTO",
                  RStudio = "bundled with RStudio",
                  Positron = "bundled with Positron",
                  found$source)
  paste0(found$version, ", ", where)
}

# Whether a LaTeX engine is at hand for a Quarto PDF: xelatex, lualatex or
# pdflatex on the PATH, or a TinyTeX install, where Quarto looks for one.
# options(surveyframe.latex = FALSE) hides LaTeX, so the Typst route can be
# tested on a machine that has it.
sframe_latex_available <- function() {
  if (identical(getOption("surveyframe.latex"), FALSE)) return(FALSE)
  if (any(nzchar(Sys.which(c("xelatex", "lualatex", "pdflatex"))))) return(TRUE)
  tinytex <- c(file.path(path.expand("~"), ".TinyTeX", "bin"),
               file.path(path.expand("~"), "Library", "TinyTeX", "bin"),
               file.path(Sys.getenv("APPDATA", ""), "TinyTeX", "bin"))
  any(dir.exists(tinytex[nzchar(tinytex)]))
}

