# tests/testthat/test-studio-design-responses.R
#
# A save on SurveyStudio's Design screen keeps the loaded responses while
# they still fit the instrument: the same item ids and the same choice codes.
# A label, wording, help text or branding edit keeps them. An item or a
# choice code added, removed or renamed clears them, with a message saying
# what changed (session 7, the owner's decision).

test_that("a label edit leaves the responses fitting the instrument", {
  old <- sframe_demo("likert_scale")$instrument
  new <- old
  new$items[[1]]$label <- "Reworded in Design"
  new$meta$title <- "Retitled in Design"
  expect_null(sframe_studio_response_change(old, new))
})

test_that("a removed item or a renamed choice code is named in the message", {
  old <- sframe_demo("likert_scale")$instrument
  gone <- old$items[[2]]$id
  new <- old
  new$items[[2]] <- NULL
  msg <- sframe_studio_response_change(old, new)
  expect_match(msg, "^Responses cleared: ")
  expect_match(msg, paste0("item ", gone, " was removed"), fixed = TRUE)
  expect_match(msg, "Load the responses again.", fixed = TRUE)

  new <- old
  new$choices[[1]]$values[3] <- 9L
  msg <- sframe_studio_response_change(old, new)
  expect_match(msg, paste0("choice 3 of ", old$items[[1]]$id, " was renamed 9"), fixed = TRUE)

  # A code only added, or only removed, with no rename paired with it.
  new <- old
  new$choices[[1]]$values <- c(new$choices[[1]]$values, 6L)
  new$choices[[1]]$labels <- c(new$choices[[1]]$labels, "Extra")
  msg <- sframe_studio_response_change(old, new)
  expect_match(msg, paste0("choice 6 of ", old$items[[1]]$id, " was added"), fixed = TRUE)
  new <- old
  new$choices[[1]]$values <- new$choices[[1]]$values[-5]
  new$choices[[1]]$labels <- new$choices[[1]]$labels[-5]
  msg <- sframe_studio_response_change(old, new)
  expect_match(msg, paste0("choice 5 of ", old$items[[1]]$id, " was removed"), fixed = TRUE)

  new <- old
  new$items[[length(new$items) + 1]] <- sframe_item("extra_q", "Added in Design", type = "text")
  expect_match(sframe_studio_response_change(old, new), "item extra_q was added", fixed = TRUE)
})

test_that("a changed item type or matrix row on the same id clears the responses", {
  old <- sframe_demo("likert_scale")$instrument
  id <- old$items[[1]]$id
  new <- old
  new$items[[1]]$type <- "text"
  new$items[[1]]$choice_set <- NULL
  msg <- sframe_studio_response_change(old, new)
  expect_match(msg, paste0("item ", id, " changed from likert to text"), fixed = TRUE)

  grid <- function(rows) sframe_instrument("Grid", components = list(
    sframe_choice_set("agree3", values = 1:3, labels = c("No", "Maybe", "Yes")),
    sframe_item("g1", "Rate each", type = "matrix", choice_set = "agree3",
                matrix_items = rows)))
  msg <- sframe_studio_response_change(grid(c("a", "b")), grid(c("a", "c")))
  expect_match(msg, "row b of g1 was renamed c", fixed = TRUE)
  msg <- sframe_studio_response_change(grid(c("a", "b")), grid(c("a", "b", "d")))
  expect_match(msg, "row d of g1 was added", fixed = TRUE)
  msg <- sframe_studio_response_change(grid(c("a", "b")), grid("a"))
  expect_match(msg, "row b of g1 was removed", fixed = TRUE)
})

test_that("a Design save keeps or clears the loaded responses in Studio", {
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
    launch_studio(demo = "likert_scale", screen = "design", port = port,
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
  b <- chromote::ChromoteSession$new(width = 1280, height = 900)
  on.exit(b$close(), add = TRUE)
  b$Page$navigate(url)
  js <- function(code) b$Runtime$evaluate(code, returnByValue = TRUE)$result$value
  wait <- function(cond) {
    for (i in 1:300) {
      if (isTRUE(tryCatch(js(cond), error = function(e) FALSE))) return(TRUE)
      Sys.sleep(0.5)
    }
    FALSE
  }
  frame <- "document.getElementById('design_frame').contentWindow"
  status <- "((document.getElementById('design_status')||{}).innerText||'')"
  side <- "((document.getElementById('sidebar_status')||{}).innerText||'')"
  expect_true(wait(paste0(frame, ".S && ", frame, ".S.items.length > 1")))
  expect_true(wait(paste0(side, ".indexOf('Responses loaded') >= 0")))

  # A label edit: the responses stay.
  js(paste0("var w=", frame, "; w.S._origin = null; w.S.meta.title = 'Label edit';",
            "w.S.items[0].label = 'Reworded in Design'; w.saveSframe(); true"))
  expect_true(wait(paste0(status, ".indexOf('Label edit') >= 0")))
  Sys.sleep(1)
  expect_match(js(side), "Responses loaded", fixed = TRUE)

  # A removed item: the responses go, and the message names the item.
  gone <- js(paste0(frame, ".S.items[1].id"))
  js(paste0("var w=", frame, "; w.S._origin = null; w.S.meta.title = 'Item removed';",
            "var id = w.S.items[1].id; w.S.items.splice(1, 1);",
            "(w.S.scales || []).forEach(function(s) {",
            "  s.items = s.items.filter(function(i) { return i !== id; });",
            "  s.reverse_items = (s.reverse_items || []).filter(function(i) { return i !== id; }); });",
            "w.saveSframe(); true"))
  expect_true(wait(paste0(status, ".indexOf('Item removed') >= 0")))
  expect_true(wait(paste0(side, ".indexOf('No responses') >= 0")))
  expect_true(wait(paste0("$('.shiny-notification').text().indexOf('item ", gone,
                          " was removed') >= 0")))
})
