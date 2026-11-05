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

test_that("Design and Plan have 1 header row, with undo, redo and Save to Studio at the far right (UI-3 item 3)", {
  b <- ui1_studio("factor_structure", width = 1280, height = 900)
  expect_true(ui1_screen(b, "design"))
  frame <- "document.getElementById('design_frame').contentWindow"
  doc <- paste0(frame, ".document")
  expect_true(ui2_wait(b, paste0("(function(){ try { return !!", frame, ".S && ", frame, ".S.items.length > 0; } catch (e) { return false; } })()"), 60))
  # The builder's own bar is merged into Studio's head, so it hides.
  expect_true(ui2_js(b, paste0(doc, ".querySelector('.topbar').offsetParent === null")))
  # Left: the title, the instrument and version, the save state. Right: undo,
  # redo and the primary Save to Studio, last.
  order <- ui2_js(b, "$('#screen-design > .screen-head').children(':visible').map(function(){ return this.id || this.className; }).get().join('|')")
  expect_match(order, "^design_title\\|design_status\\|design_saved\\|design-actions$")
  expect_identical(ui2_js(b, "$('#screen-design .design-actions').children().map(function(){ return this.id; }).get().join('|')"), "design_undo|design_redo|design_save")
  expect_true(ui2_js(b, "(function(){ var h = $('#screen-design > .screen-head')[0].getBoundingClientRect(), s = document.getElementById('design_save').getBoundingClientRect(), t = document.getElementById('design_title').getBoundingClientRect(); return Math.abs(s.top + s.height / 2 - (t.top + t.height / 2)) < 12 && h.right - s.right < 24; })()"))
  lv <- ui3_levels(b, "document.querySelector('#screen-design > .screen-head')")
  p <- lv[lv$level == "primary", ]
  expect_identical(p$id, "design_save")
  expect_true(p$filled)
  expect_gte(p$height, 40)
  expect_lte(p$slack, 2)
  expect_identical(ui2_js(b, "$('#design_saved').text()"), "Saved")
  # An edit in the builder: undo turns on and the state reads Unsaved changes.
  ui2_js(b, paste0("var w=", frame, "; w.snap(); w.S.meta.description = 'UI-3 header test'; true"))
  expect_true(ui2_wait(b, "!$('#design_undo').prop('disabled') && $('#design_unsaved').is(':visible') && !$('#design_saved').is(':visible')", 10))
  # Studio's Undo reaches the builder, and Redo turns on.
  ui2_js(b, "$('#design_undo').click(); true")
  expect_true(ui2_wait(b, paste0("(", frame, ".S.meta.description || '') !== 'UI-3 header test' && !$('#design_redo').prop('disabled')"), 10))
  ui2_js(b, "$('#design_redo').click(); true")
  expect_true(ui2_wait(b, paste0(frame, ".S.meta.description === 'UI-3 header test'"), 10))
  ui2_js(b, "$('#design_undo').click(); true")
  # Plan: the same row, titled Plan.
  ui2_js(b, "$('.studio-nav a[data-nav=\"plan\"]').click(); true")
  expect_true(ui2_wait(b, "$('#design_title').text() === 'Plan' && $('#design_save').is(':visible')", 20))
  expect_true(ui1_screen(b, "design"))
  expect_true(ui2_wait(b, "$('#design_title').text() === 'Design'", 20))
})

test_that("the standalone builder keeps its switch and has the same row, Save .sframe at the far right (UI-3 item 3)", {
  s <- ui2_builder()
  order <- ui2_js(s, "Array.prototype.map.call(document.querySelector('.topbar').children, function(e){ return e.className; }).join('|')")
  expect_identical(order, "tb-l|tb-modes|tb-r")
  expect_identical(ui2_js(s, "Array.prototype.map.call(document.querySelector('.tb-l').children, function(e){ return e.id || e.className; }).join('|')"), "tb-brand|tbDoc|saveSt")
  expect_identical(ui2_js(s, "document.querySelector('.tb-r').lastElementChild.id"), "saveBtn")
  expect_true(ui2_js(s, "document.querySelector('.tb-modes').offsetParent !== null"))
  expect_match(ui2_js(s, "document.getElementById('tbDoc').textContent"), "\\(1\\.0\\.0\\)$")
  lv <- ui3_levels(s, "document.querySelector('.topbar')")
  expect_identical(lv$id[lv$level == "primary"], "saveBtn")
  expect_true(all(lv$filled == (lv$level == "primary")))
})

ui2_close()
ui1_close()
