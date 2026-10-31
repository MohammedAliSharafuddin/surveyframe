# tests/testthat/test-report-offline.R
#
# A Quarto report renders with no network fetch (session 7). The cosmo
# theme's CSS imported a Google web font, so pandoc fetched it to embed,
# though the template sets a system font stack. Every report needed the
# internet and sent Google a request, and a stalled connection hung the
# render with no timeout. Here every http(s) fetch goes through a local
# proxy that records the request and closes the connection, so a fetch fails
# at once rather than hanging, and the test sees each one. pandoc drops a
# resource it cannot fetch and still writes the file, so the file alone
# would not show the fetch.

test_that("the Quarto report renders with no network fetch", {
  skip_on_cran()
  skip_if_not_slow()
  skip_if(!nzchar(Sys.which("quarto")), "Quarto is not installed")
  skip_if_not_installed("callr")
  old <- options(surveyframe.use_quarto = TRUE)
  on.exit(options(old), add = TRUE)

  # The proxy: one line per request, as "CONNECT host:443 HTTP/1.1".
  port <- httpuv::randomPort()
  log <- tempfile(fileext = ".log")
  proxy <- callr::r_bg(function(port, log) {
    srv <- serverSocket(port)
    repeat {
      con <- socketAccept(srv, blocking = TRUE, open = "r+b", timeout = 3600)
      line <- tryCatch(readLines(con, n = 1, warn = FALSE), error = function(e) "")
      cat(line, "\n", file = log, append = TRUE, sep = "")
      close(con)
    }
  }, args = list(port, log))
  on.exit(proxy$kill(), add = TRUE)
  Sys.sleep(1)

  proxy_vars <- c("http_proxy", "https_proxy", "HTTP_PROXY", "HTTPS_PROXY",
                  "no_proxy", "NO_PROXY")
  saved <- Sys.getenv(proxy_vars, unset = NA)
  on.exit({
    for (v in proxy_vars) {
      if (is.na(saved[[v]])) Sys.unsetenv(v)
      else do.call(Sys.setenv, stats::setNames(list(saved[[v]]), v))
    }
  }, add = TRUE)
  url <- paste0("http://127.0.0.1:", port)
  Sys.setenv(http_proxy = url, https_proxy = url, HTTP_PROXY = url,
             HTTPS_PROXY = url, no_proxy = "127.0.0.1,localhost",
             NO_PROXY = "127.0.0.1,localhost")

  demo <- sframe_demo("two_group")
  out <- tempfile(fileext = ".html")
  expect_message(
    render_report(demo$instrument, demo$responses, output_file = out, open = FALSE),
    "Quarto engine")
  expect_true(file.exists(out))

  fetched <- if (file.exists(log)) readLines(log, warn = FALSE) else character(0)
  expect_identical(fetched, character(0))

  # And nothing is left in the page to load from the web when it is opened.
  html <- paste(readLines(out, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  expect_false(grepl("fonts.googleapis", html, fixed = TRUE))
  expect_false(grepl("fonts.gstatic", html, fixed = TRUE))
  # Quarto's accessibility check imports axe-core from cdn.skypack.dev when
  # a document sets `axe`. The report does not, so it is not in the page.
  expect_false(grepl("skypack", html, fixed = TRUE))
  remote <- c("<link[^>]+href=[\"']https?://", "<script[^>]+src=[\"']https?://",
              "<img[^>]+src=[\"']https?://", "url\\([\"']?https?://",
              "@import[^;]*https?://")
  for (re in remote) expect_false(grepl(re, html, perl = TRUE), label = re)
  expect_false(dir.exists(sub("\\.html$", "_files", out)))
})
