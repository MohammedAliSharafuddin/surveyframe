# tests/testthat/test-studio-uf-browser.R
#
# Session UF: the Studio minors from Codex pass 1 (P1-06 to P1-12), checked
# at 1280 and 390 px in a real Chrome against the build under test. Studio
# and its tab come from ui1_studio() (helper-ui1-browser.R): "none" opens
# Studio with no instrument, "two_group" with that demo. Both are closed at
# the end of the file.

skip_if_not_slow()
skip_on_cran()
skip_if_not_installed("chromote")
skip_if_not_installed("callr")
skip_if_not_installed("httpuv")

uf_widths <- c(1280, 390)

test_that("Studio's page declares its language as English (P1-06, WCAG 3.1.1)", {
  b <- ui1_studio("two_group", width = 1280, height = 900)
  expect_identical(ui2_js(b, "document.documentElement.getAttribute('lang')"), "en")
})

# The visible fold controls in a document under 24 px tall: the sidebar's
# group buttons and every <summary> (WCAG 2.5.8 at AA wants 24 by 24 px, or
# that much space round a smaller one).
uf_small_js <- "(function(){
  var out = [];
  document.querySelectorAll('.studio-nav-fold, summary').forEach(function(el){
    var r = el.getBoundingClientRect(), cs = getComputedStyle(el);
    if (!r.width || !r.height || cs.visibility === 'hidden' || el.offsetParent === null) return;
    if (r.height < 24 || r.width < 24) out.push((el.innerText || '').trim().slice(0, 40) + ' ' + Math.round(r.width) + 'x' + (Math.round(r.height * 10) / 10));
  });
  return out.join('|');
})()"

test_that("the sidebar's fold buttons and every fold summary are at least 24 px tall, at 1280 and 390 px (P1-07, WCAG 2.5.8)", {
  for (w in uf_widths) {
    b <- ui1_studio("two_group", width = w, height = 900)
    for (screen in sframe_studio_screens()) {
      expect_true(ui1_screen(b, screen), info = screen)
      Sys.sleep(0.5)
      expect_identical(ui2_js(b, uf_small_js), "", info = paste(w, screen))
    }
  }
})

test_that("Quality counts respondents and rows in words, and no screen shows '(s)' (P1-08)", {
  b <- ui1_studio("two_group", width = 1280, height = 900)
  expect_true(ui1_screen(b, "quality"))
  expect_true(ui2_wait(b, "$('#screen-quality').text().indexOf('flagged as too fast') >= 0", 30))
  q <- ui2_js(b, "document.getElementById('screen-quality').innerText")
  expect_match(q, "\\d+ respondents? \\([0-9.]+%\\) flagged as too fast")
  expect_match(q, "\\d+ duplicate response rows? detected")
  for (screen in sframe_studio_screens()) {
    expect_true(ui1_screen(b, screen), info = screen)
    Sys.sleep(0.5)
    expect_false(grepl("[a-z]\\(s\\)", ui2_js(b, "document.body.innerText")), info = screen)
  }
})

test_that("Open Instrument says Schema valid for the two_group demo, from a validation run (P1-09)", {
  for (w in uf_widths) {
    b <- ui1_studio("two_group", width = w, height = 900)
    expect_true(ui1_screen(b, "open"))
    expect_true(ui2_wait(b, "!!document.getElementById('open_schema_status')", 20))
    expect_identical(ui1_text(b, "open_schema_status"), "Schema valid")
    expect_false(grepl("Draft|fix in Design", ui2_js(b, "document.getElementById('screen-open').innerText")))
  }
})

test_that("with no instrument the sidebar says No instrument open, not a draft needing fixes (P1-09)", {
  b <- ui1_studio("none", width = 1280, height = 900)
  expect_true(ui2_wait(b, "$('.studio-status').text().indexOf('No instrument open') >= 0", 20))
  expect_false(grepl("Draft needs fixes|No valid instrument", ui2_js(b, "$('.studio-status').text()")))
})

ui1_close()
