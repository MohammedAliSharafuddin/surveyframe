# tests/testthat/test-studio-ui3-browser.R
#
# Session UI-3: 1 design system for Studio and the builder. Studio and its
# Chrome tab come from ui1_studio() (helper-ui1-browser.R), shared across the
# tests here and closed at the end of the file.

skip_if_not_slow()
skip_on_cran()
skip_if_not_installed("chromote")
skip_if_not_installed("callr")
skip_if_not_installed("httpuv")

# The button levels in a document, from computed styles. For each visible
# button or button-styled link: its level (by class), whether it is filled
# with the primary colour, its height, and how much wider it is than its
# label plus padding and border.
ui3_levels_js <- "(function(root){
  var doc = root.ownerDocument || root, win = doc.defaultView;
  var probe = doc.createElement('span'); probe.style.color = win.getComputedStyle(doc.documentElement).getPropertyValue('--sf-primary');
  doc.body.appendChild(probe); var primary = win.getComputedStyle(probe).color; probe.remove();
  var out = [];
  root.querySelectorAll('button, a.btn, .btn, [role=button]').forEach(function(el){
    var r = el.getBoundingClientRect(), cs = win.getComputedStyle(el);
    if (!r.width || !r.height || cs.visibility === 'hidden' || el.closest('[hidden]')) return;
    var range = doc.createRange(); range.selectNodeContents(el);
    var inner = range.getBoundingClientRect().width;
    var pad = parseFloat(cs.paddingLeft) + parseFloat(cs.paddingRight) + parseFloat(cs.borderLeftWidth) + parseFloat(cs.borderRightWidth);
    out.push({id: el.id || '', text: (el.innerText || '').trim().slice(0, 40),
      level: el.classList.contains('sf-primary') ? 'primary' : el.classList.contains('sf-secondary') ? 'secondary' : el.classList.contains('sf-tertiary') ? 'tertiary' : 'other',
      filled: cs.backgroundColor === primary, height: Math.round(r.height),
      slack: Math.round(r.width - inner - pad)});
  });
  return JSON.stringify(out);
})(%s)"

ui3_levels <- function(b, root) {
  jsonlite::fromJSON(ui2_js(b, sprintf(ui3_levels_js, root)))
}

test_that("every Studio screen has exactly 1 filled primary, 40 px high and sized to its label (UI-3 item 2)", {
  b <- ui1_studio("factor_structure", width = 1280, height = 900)
  for (screen in setdiff(sframe_studio_screens(), "design")) {
    expect_true(ui1_screen(b, screen), info = screen)
    Sys.sleep(1.5)
    lv <- ui3_levels(b, sprintf("document.getElementById('screen-%s')", screen))
    expect_identical(sum(lv$level == "primary"), 1L, info = screen)
    # Nothing else on the screen is filled with the primary colour.
    expect_identical(sum(lv$filled & lv$level != "primary"), 0L, info = screen)
    p <- lv[lv$level == "primary", ]
    expect_true(all(p$filled), info = screen)
    expect_true(all(p$height >= 40), info = screen)
    expect_true(all(p$slack <= 2), info = paste(screen, paste(p$slack, collapse = ",")))
    s <- lv[lv$level == "secondary", ]
    if (nrow(s)) expect_true(all(s$height >= 36), info = paste(screen, paste(s$text[s$height < 36], collapse = "|")))
  }
})

test_that("the hosted builder's top bar has 1 primary, Save to Studio, 40 px high (UI-3 item 2)", {
  b <- ui1_studio("factor_structure", width = 1280, height = 900)
  expect_true(ui1_screen(b, "design"))
  doc <- "document.getElementById('design_frame').contentWindow.document"
  expect_true(ui2_wait(b, paste0("(function(){ try { return !!", doc, ".querySelector('#saveBtn.sf-primary'); } catch (e) { return false; } })()"), 60))
  lv <- ui3_levels(b, paste0(doc, ".querySelector('.topbar')"))
  p <- lv[lv$level == "primary", ]
  expect_identical(p$id, "saveBtn")
  expect_true(p$filled)
  expect_gte(p$height, 40)
  expect_lte(p$slack, 2)
  # The builder's old ad hoc classes are gone from its markup.
  expect_identical(ui2_js(b, paste0(doc, ".querySelectorAll('.btn-p, .btn-s, .btn-g, .btn-d, .btn-sm').length")), 0L)
})

ui1_close()
