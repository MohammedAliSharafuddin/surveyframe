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

test_that("the builder panel has 1 filled button, + Add question, a menu holding Section and Branch (UI-3 item 4)", {
  s <- ui2_builder()
  lv <- ui3_levels(s, "document.querySelector('.sidebar')")
  expect_identical(lv$id[lv$level == "primary"], "fabMoreBtn")
  # Survey settings is a secondary row at the top: outlined, not filled.
  expect_identical(ui2_js(s, "getComputedStyle(document.querySelector('.sb-settings-cta')).backgroundColor"), "rgba(0, 0, 0, 0)")
  expect_identical(ui2_js(s, "document.querySelector('.sb-top').children[1].className"), "sb-settings-cta")
  # Nothing in the panel is filled with the primary colour but Add question.
  filled <- ui2_js(s, paste0("(function(){ var p = getComputedStyle(document.getElementById('fabMoreBtn')).backgroundColor, n = 0;",
    " document.querySelectorAll('.sidebar button, .sidebar .btn').forEach(function(e){ if (e.offsetParent && getComputedStyle(e).backgroundColor === p) n++; }); return n; })()"))
  expect_identical(filled, 1L)
  expect_identical(ui2_js(s, "document.querySelectorAll('.fab-mini').length"), 0L)
  items <- ui2_js(s, "Array.prototype.map.call(document.querySelectorAll('#fabMenu [role=menuitem]'), function(e){ return e.textContent; }).join('|')")
  expect_match(items, "Section break\\|Branching rule$")
  # The menu button pattern: Down opens on the first item, Up from it wraps
  # to the last, Escape closes back to the button.
  ui2_js(s, "document.getElementById('fabMoreBtn').focus(); 1")
  ui2_key(s, "", "ArrowDown")
  expect_identical(ui2_js(s, "document.getElementById('fabMoreBtn').getAttribute('aria-expanded')"), "true")
  expect_identical(ui2_js(s, "document.activeElement.textContent"), "Likert scale")
  ui2_key(s, "", "ArrowUp")
  expect_identical(ui2_js(s, "document.activeElement.textContent"), "Branching rule")
  ui2_key(s, "", "Home")
  expect_identical(ui2_js(s, "document.activeElement.textContent"), "Likert scale")
  ui2_key(s, "", "Escape")
  expect_false(ui2_js(s, "document.getElementById('fabMenu').classList.contains('open')"))
  expect_identical(ui2_js(s, "document.activeElement.id"), "fabMoreBtn")
  expect_identical(ui2_js(s, "document.getElementById('fabMoreBtn').getAttribute('aria-expanded')"), "false")
  # Section break from the menu adds one.
  ui2_js(s, "document.getElementById('fabMoreBtn').click(); 1")
  ui2_js(s, "Array.prototype.filter.call(document.querySelectorAll('#fabMenu [role=menuitem]'), function(e){ return e.textContent === 'Section break'; })[0].click(); 1")
  expect_true(ui2_js(s, "S.items.some(function(i){ return i.type === 'section_break'; })"))
  # Configure is a text link with a plain name, and its menu opens the same way.
  expect_identical(ui2_js(s, "document.getElementById('cfgMoreBtn').textContent"), "Answer sets, scales and checks")
  expect_true(ui2_js(s, "document.getElementById('cfgMoreBtn').classList.contains('sf-tertiary')"))
  ui2_js(s, "document.getElementById('cfgMoreBtn').focus(); 1")
  ui2_key(s, "", "ArrowDown")
  expect_identical(ui2_js(s, "document.querySelectorAll('#cfgMenu [role=menuitem]').length"), 3L)
  expect_true(ui2_js(s, "document.getElementById('cfgMenu').contains(document.activeElement)"))
  ui2_key(s, "", "Escape")
  expect_identical(ui2_js(s, "document.activeElement.id"), "cfgMoreBtn")
})

test_that("the empty canvas is a 3-step checklist, then names the next useful step (UI-3 item 5)", {
  s <- ui2_builder()
  steps <- function() ui2_js(s, "Array.prototype.map.call(document.querySelectorAll('#cPrompt .c-step'), function(e){ return e.className.replace('c-step', '').trim() || 'todo'; }).join('|')")
  go <- function() ui2_js(s, "(document.getElementById('cStepGo') || {}).textContent || ''")
  expect_identical(steps(), "next|todo|todo")
  expect_identical(go(), "Open survey settings")
  # The step button is secondary: the panel and the head keep the only primaries.
  expect_true(ui2_js(s, "document.getElementById('cStepGo').classList.contains('sf-secondary')"))
  expect_identical(ui2_js(s, "document.querySelectorAll('.sb-empty-cta').length"), 0L)
  ui2_js(s, "S.meta.title = 'Visitor survey'; ra(); 1")
  expect_identical(steps(), "done|next|todo")
  expect_identical(go(), "Add a question")
  ui2_js(s, "document.getElementById('cStepGo').click(); 1")
  expect_true(ui2_js(s, "document.getElementById('fabMenu').classList.contains('open')"))
  ui2_js(s, "closeFabMenu(); qAdd('likert'); closeInsp(); 1")
  expect_identical(steps(), "done|done|next")
  expect_identical(go(), "Save .sframe")
  # Once saved: no checklist, and with no analysis plan the next step is Plan.
  ui2_js(s, "dirty = false; lastSaved = Date.now(); updSave(); 1")
  expect_identical(steps(), "")
  expect_match(ui2_js(s, "document.getElementById('cPrompt').textContent"), "Select a question to edit")
  expect_identical(go(), "Open Plan")
  ui2_js(s, "document.getElementById('cStepGo').click(); 1")
  expect_identical(ui2_js(s, "document.querySelector('.m-btn[data-mode=analyse]').getAttribute('aria-pressed')"), "true")
  ui2_js(s, "setMode('build'); S.analysis_plan = [{id: 'RQ1'}]; renderPrompt(); 1")
  expect_identical(go(), "Add a question")
})

test_that("in Studio the canvas step Open Plan opens Plan through the sidebar (UI-3 item 5)", {
  b <- ui1_studio("factor_structure", width = 1280, height = 900)
  expect_true(ui1_screen(b, "design"))
  frame <- "document.getElementById('design_frame').contentWindow"
  expect_true(ui2_wait(b, paste0("(function(){ try { return ", frame, ".S.items.length > 0 && !!", frame, ".document.getElementById('cStepGo'); } catch (e) { return false; } })()"), 60))
  ui2_js(b, paste0("var w = ", frame, "; w.__plan = w.S.analysis_plan; w.S.analysis_plan = []; w.renderPrompt(); true"))
  expect_identical(ui2_js(b, paste0(frame, ".document.getElementById('cStepGo').textContent")), "Open Plan")
  ui2_js(b, paste0(frame, ".document.getElementById('cStepGo').click(); true"))
  expect_true(ui2_wait(b, "$('#design_title').text() === 'Plan' && $('.studio-nav a[data-nav=\"plan\"]').attr('aria-current') === 'page'", 20))
  ui2_js(b, paste0("var w = ", frame, "; w.S.analysis_plan = w.__plan; w.renderPrompt(); true"))
  expect_true(ui1_screen(b, "design"))
})

test_that("every Studio screen follows the same rules: 1 tab style, tiles that fit, a disabled primary with a visible reason (UI-3 item 6)", {
  b <- ui1_studio("factor_structure", width = 1280, height = 900)
  # Explore's view tabs are underlined as the Report's are, not filled.
  expect_true(ui1_screen(b, "dashboard"))
  tab <- "$('#screen-dashboard .studio-tabs input:checked + span')[0]"
  expect_true(ui2_wait(b, paste0("!!", tab), 20))
  expect_identical(ui2_js(b, paste0("getComputedStyle(", tab, ").borderBottomWidth")), "3px")
  expect_identical(ui2_js(b, paste0("getComputedStyle(", tab, ").backgroundColor")), "rgba(0, 0, 0, 0)")
  for (screen in sframe_studio_screens()) {
    expect_true(ui1_screen(b, screen), info = screen)
    Sys.sleep(1)
    # Every tile value stays inside its tile.
    over <- ui2_js(b, sprintf("$('#screen-%s .stat-val:visible').filter(function(){ return this.scrollWidth > this.clientWidth + 1; }).map(function(){ return this.innerText; }).get().join('|')", screen))
    expect_identical(over, "", info = screen)
    # A disabled primary has a visible hint beside it.
    bare <- ui2_js(b, sprintf("$('#screen-%s .sf-primary:disabled:visible, #screen-%s .sf-primary.disabled:visible').filter(function(){ var h = $(this).nextAll('.hint:visible').add($(this).parent().nextAll('.hint:visible')); return !h.length && !$('#screen-%s .plan-msg:visible').length; }).length", screen, screen, screen))
    expect_identical(bare, 0L, info = screen)
  }
})

ui2_close()
ui1_close()
