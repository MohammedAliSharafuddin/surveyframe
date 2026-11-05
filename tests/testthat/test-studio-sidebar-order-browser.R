# tests/testthat/test-studio-sidebar-order-browser.R
#
# The SurveyStudio sidebar follows the study's order (session 7, owner
# approved): Open Instrument, then Build, Collect, Analyse, Report and Record
# groups under headings that cannot be clicked. Plan is an entry, not a
# screen: it opens Design with the builder in its Plan mode and is the entry
# marked active. The screen ids are kept, so launch_studio(screen =) works.

studio_sidebar <- list(
  list(heading = NULL,      entries = c("Open Instrument" = "open")),
  list(heading = "Build",   entries = c(Design = "design", Plan = "design", Preview = "preview")),
  list(heading = "Collect", entries = c(Collect = "collect", Responses = "responses")),
  list(heading = "Analyse", entries = c(Quality = "quality", Explore = "dashboard",
                                        Reliability = "reliability", Analyse = "analysis")),
  list(heading = "Report",  entries = c(Report = "export")),
  list(heading = "Record",  entries = c(References = "references", Amendments = "amendments"))
)

test_that("sframe_studio_screens() lists the screens in sidebar order", {
  expect_identical(sframe_studio_screens(),
                   c("open", "design", "preview", "collect", "responses", "quality",
                     "dashboard", "reliability", "analysis", "export", "references",
                     "amendments"))
})

test_that("the sidebar's groups, labels and screens follow the study's order", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if_not_installed("shiny")
  skip_if_not_installed("chromote")
  skip_if_not_installed("callr")
  chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
  skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")

  # The child loads the build under test with library(), never load_all().
  libpath <- sframe_build_libpath()
  port <- httpuv::randomPort()
  proc <- callr::r_bg(function(port) {
    library(surveyframe)
    launch_studio(demo = "likert_scale", screen = "open", port = port,
                  launch.browser = FALSE)
  }, args = list(port), libpath = libpath)
  on.exit(proc$kill(), add = TRUE)
  url <- paste0("http://127.0.0.1:", port)
  for (i in 1:180) {
    up <- tryCatch({ suppressWarnings(readLines(url, n = 1)); TRUE }, error = function(e) FALSE)
    if (up) break
    Sys.sleep(0.5)
  }
  skip_if(!up, "Studio did not start")
  b <- sframe_chrome_session(width = 1280, height = 900)
  on.exit(b$close(), add = TRUE)
  b$Page$navigate(url)
  js <- function(code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
  wait <- function(cond, n = 120) {
    for (i in 1:n) {
      if (isTRUE(tryCatch(js(cond), error = function(e) FALSE))) return(TRUE)
      Sys.sleep(0.5)
    }
    FALSE
  }
  expect_true(wait("$('#screen-open').hasClass('active')"))

  # Headings and entries, top to bottom. A heading has no link to click.
  shown <- unlist(js(paste0(
    "$('.studio-nav > li').map(function() {",
    "  var a = $(this).children('a');",
    "  return (a.length ? 'entry:' + a.text() : 'heading:' + $(this).text()).trim();",
    "}).get()")))
  expected <- unlist(lapply(studio_sidebar, function(g) {
    c(if (!is.null(g$heading)) paste0("heading:", g$heading),
      paste0("entry:", names(g$entries)))
  }))
  expect_identical(shown, expected)
  # A heading links nowhere. Since UI-1 item 12a it is 1 fold button with
  # aria-expanded, so it no longer has nothing to click.
  expect_identical(js("$('.studio-nav > li:not(:has(a))').filter(function() { return $(this).find('a').length > 0 || $(this).find('button[aria-expanded]').length !== 1; }).length"), 0L)

  # Each label opens its screen, titled with the label, and is the only
  # entry marked active.
  entries <- unlist(lapply(studio_sidebar, `[[`, "entries"))
  builder_mode <- paste0(
    "(function() { var d = document.getElementById('design_frame').contentWindow.document;",
    "  var m = d.querySelector('.m-btn[aria-pressed=\"true\"]'); return m ? m.dataset.mode : ''; })()")
  for (label in names(entries)) {
    screen <- entries[[label]]
    js(paste0("$('.studio-nav a').filter(function() { return $(this).text().trim() === '",
              label, "'; }).click(); true"))
    expect_true(wait(paste0("$('#screen-", screen, "').hasClass('active')"), n = 20), info = label)
    expect_identical(js("$('.studio-nav a.active').length"), 1L, info = label)
    expect_identical(js("$('.studio-nav a.active').text().trim()"), label, info = label)
    # Since UI-3 item 3 the head is titled by the mode, so Plan reads Plan.
    title <- label
    expect_identical(js(paste0("$('#screen-", screen, " h2.screen-title').text().trim()")),
                     title, info = label)
    if (label == "Design") {
      expect_true(wait(paste0(builder_mode, " === 'build'"), n = 60), info = label)
    }
    if (label == "Plan") {
      expect_true(wait(paste0(builder_mode, " === 'analyse'"), n = 60), info = label)
    }
  }
  # Design after Plan puts the builder back in Build mode.
  js("$('.studio-nav a').filter(function() { return $(this).text().trim() === 'Design'; }).click(); true")
  expect_true(wait(paste0(builder_mode, " === 'build'"), n = 20))
  expect_identical(js("$('.studio-nav a.active').text().trim()"), "Design")
})
