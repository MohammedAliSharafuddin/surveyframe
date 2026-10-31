# tests/testthat/test-help-by-stage.R
# Naming decision 8. One map of the package, with the stage names Studio and
# the builder use, in 3 places: the reference index, ?surveyframe, and the
# "Other ... functions" links at the foot of each help page.

stage_sections <- c("Design", "Plan", "Preview", "Collect", "Responses",
                    "Analyse", "Report", "References", "Amendments")
toolbox_sections <- c("Inspect", "Models and syntax", "Charts",
                      "Decision analysis", "Text analysis",
                      "Confidence intervals", "Demos", "Methods")

reference_index <- function() {
  path <- sframe_source_path("_pkgdown.yml")
  skip_if(is.na(path), "no source tree here: _pkgdown.yml")
  yaml::read_yaml(path)$reference
}

# Each Rd file's topic name and aliases, read from man/*.Rd
rd_topics <- function() {
  man <- sframe_source_path("man")
  skip_if(is.na(man), "no source tree here: man")
  lapply(setNames(nm = list.files(man, pattern = "\\.Rd$", full.names = TRUE)), function(f) {
    rd <- readLines(f, warn = FALSE)
    list(
      topic = sub("^\\\\name\\{(.*)\\}$", "\\1", grep("^\\\\name\\{", rd, value = TRUE)),
      aliases = gsub("\\\\%", "%", sub("^\\\\alias\\{(.*)\\}$", "\\1", grep("^\\\\alias\\{", rd, value = TRUE))))
  })
}

# Topic name for each alias
rd_aliases <- function() {
  out <- character()
  for (r in rd_topics()) out[r$aliases] <- r$topic
  out
}

# Rd file for each topic name
rd_files <- function() {
  rd <- rd_topics()
  setNames(names(rd), vapply(rd, function(r) r$topic, character(1)))
}

test_that("the reference index runs in stage order, then the toolboxes", {
  titles <- vapply(reference_index(), function(s) s$title, character(1))
  expect_identical(titles[1], "Start here")
  expect_identical(titles[titles %in% stage_sections], stage_sections)
  expect_identical(titles[titles %in% toolbox_sections], toolbox_sections)
  expect_true(max(match(stage_sections, titles)) <
                min(match(toolbox_sections, titles)))
  expect_identical(utils::tail(titles, 1), "Old names (superseded)")
})

test_that("each stage section says where the stage lives in each route", {
  for (s in reference_index()) {
    if (!s$title %in% stage_sections) next
    expect_match(s$desc, "In code:", fixed = TRUE, info = s$title)
    expect_match(s$desc, "In Survey(Studio|Builder):", info = s$title)
  }
})

test_that("every export sits in exactly 1 section of the index", {
  topic_of <- rd_aliases()
  listed <- unlist(lapply(reference_index(), function(s) unlist(s$contents)))
  expect_false(any(duplicated(listed)), info = paste(listed[duplicated(listed)], collapse = ", "))
  exports <- sframe_exports()
  missing_topic <- setdiff(exports, names(topic_of))
  expect_length(missing_topic, 0)
  unlisted <- exports[!topic_of[exports] %in% listed]
  expect_identical(unlisted, character(0))
})

test_that("every help page in a section links to the rest of its section", {
  file_of <- rd_files()
  for (s in reference_index()) {
    topics <- unlist(s$contents)
    if (length(topics) < 2) next
    for (t in topics) {
      rd <- paste(readLines(file_of[[t]], warn = FALSE),
                  collapse = "\n")
      expect_match(rd, "Other [^:]+:", info = paste(s$title, t))
    }
  }
})

test_that("?surveyframe opens with Start here, then the stages in order", {
  rd <- paste(readLines(sframe_source_path("man", "surveyframe-package.Rd"),
                        warn = FALSE), collapse = "\n")
  at <- function(x) regexpr(x, rd, fixed = TRUE)[[1]]
  expect_gt(at("Start here"), 0)
  pos <- vapply(c("Start here", stage_sections), function(s)
    at(paste0("\\subsection{", s)), numeric(1))
  expect_true(all(pos > 0), info = paste(names(pos)[pos <= 0], collapse = ", "))
  expect_false(is.unsorted(pos))
})
