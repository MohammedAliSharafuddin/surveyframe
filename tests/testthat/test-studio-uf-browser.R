# tests/testthat/test-studio-uf-browser.R
#
# Session UF: the Studio minors from Codex pass 1 (P1-06 to P1-12), checked
# at 1280 and 390 px in a real Chrome against the build under test. Studio
# and its tab come from ui1_studio() (helper-ui1-browser.R): "none" opens
# Studio with no instrument, "two_group" with that demo. The standalone
# builder (P1-11) comes from ui2_builder(). All are closed at the end of the
# file.

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

# Each visible button-styled control on a screen: its text, its level by
# class, and whether it is filled with the primary colour.
uf_buttons_js <- "(function(screen){
  var root = document.getElementById('screen-' + screen), out = [];
  var probe = document.createElement('span'); probe.style.color = getComputedStyle(document.documentElement).getPropertyValue('--sf-primary');
  document.body.appendChild(probe); var primary = getComputedStyle(probe).color; probe.remove();
  root.querySelectorAll('button, a.btn, .btn').forEach(function(el){
    var r = el.getBoundingClientRect();
    if (!r.width || !r.height || el.offsetParent === null) return;
    out.push({text: (el.innerText || '').trim(), card: !!el.closest('.next-stage'),
      primary: el.classList.contains('sf-primary'), secondary: el.classList.contains('sf-secondary'),
      filled: getComputedStyle(el).backgroundColor === primary});
  });
  return JSON.stringify(out);
})('%s')"

test_that("with no instrument, the 9 empty screens offer Open Instrument filled and Design secondary (P1-10)", {
  empty <- c("collect", "responses", "quality", "dashboard", "reliability",
             "analysis", "export", "references", "amendments")
  for (w in uf_widths) {
    b <- ui1_studio("none", width = w, height = 900)
    for (screen in empty) {
      expect_true(ui1_screen(b, screen), info = screen)
      expect_true(ui2_wait(b, sprintf("$('#screen-%s .next-stage:visible').length > 0", screen), 20), info = screen)
      bt <- jsonlite::fromJSON(ui2_js(b, sprintf(uf_buttons_js, screen)))
      card <- bt[bt$card, ]
      expect_identical(card$text, c("Open Instrument", "Design"), info = paste(w, screen))
      expect_identical(card$primary, c(TRUE, FALSE), info = paste(w, screen))
      expect_identical(card$filled, c(TRUE, FALSE), info = paste(w, screen))
      expect_true(card$secondary[2], info = paste(w, screen))
      # 1 filled primary on the screen, the card's (UI-3).
      expect_identical(sum(bt$filled), 1L, info = paste(w, screen))
    }
  }
})

# Elements in Studio's document that scroll sideways (wider content than
# box, overflow-x auto or scroll) with neither a tabindex of their own nor a
# focusable child, so a keyboard cannot scroll them: axe's
# scrollable-region-focusable rule (WCAG 2.1.1). A region that can be
# focused must also have a role and a name.
uf_scroll_js <- "(function(){
  var out = [], foc = 'a[href], button, input, select, textarea, [tabindex]:not([tabindex=\\'-1\\'])';
  document.querySelectorAll('#studio-main *, .studio-main *').forEach(function(el){
    var cs = getComputedStyle(el);
    if (el.offsetParent === null || !/(auto|scroll)/.test(cs.overflowX)) return;
    if (el.scrollWidth <= el.clientWidth + 1) return;
    var id = el.tagName.toLowerCase() + (el.id ? '#' + el.id : '') + '.' + String(el.className).trim().split(/\\s+/).join('.');
    if (el.getAttribute('tabindex') === '0') {
      if (el.getAttribute('role') !== 'region' || !el.getAttribute('aria-label')) out.push('unnamed ' + id);
    } else if (!el.querySelector(foc)) out.push(id);
  });
  return Array.from(new Set(out)).join('|');
})()"

test_that("every sideways-scrolling region in Studio can take keyboard focus and is named, at 1280 and 390 px (P1-12)", {
  for (w in uf_widths) {
    b <- ui1_studio("two_group", width = w, height = 900)
    for (screen in setdiff(sframe_studio_screens(), "design")) {
      expect_true(ui1_screen(b, screen), info = screen)
      Sys.sleep(if (screen == "analysis") 6 else 1)
      expect_identical(ui2_js(b, uf_scroll_js), "", info = paste(w, screen))
    }
  }
})

test_that("the builder's question rows are listitems in a list, the open one aria-current, and the keys work as before, at 1280 and 390 px (P1-11)", {
  instr <- sframe_demo("two_group")$instrument
  for (w in uf_widths) {
    s <- ui2_builder(instr, width = w, height = 900)
    expect_true(ui2_wait(s, "document.querySelectorAll('#itemList .ic').length > 2", 20))
    expect_identical(ui2_js(s, "document.getElementById('itemList').getAttribute('role')"), "list")
    roles <- ui2_js(s, "Array.from(document.querySelectorAll('#itemList > *')).map(function(e){ return e.getAttribute('role') || e.className; }).join('|')")
    expect_false(grepl("option", roles), info = roles)
    expect_true(all(strsplit(roles, "|", fixed = TRUE)[[1]] %in% c("listitem", "pg-div")), info = roles)
    # No focusable widget whose children are presentational holds a control.
    expect_identical(ui2_js(s, "document.querySelectorAll('[role=option] button, [role=button] button, button button').length"), 0L)
    expect_identical(ui2_js(s, "document.querySelectorAll('#itemList [aria-selected]').length"), 0L)
    # A bare arrow moves focus to the next row. Checked before Enter, since
    # at 390 px an open question takes the screen and hides the list.
    id <- ui2_js(s, "document.querySelectorAll('#itemList .ic')[1].getAttribute('data-id')")
    ui2_js(s, sprintf("document.querySelector('#itemList .ic[data-id=\"%s\"]').focus(); 1", id))
    ui2_key(s, "", "ArrowDown")
    expect_identical(ui2_js(s, "document.activeElement.getAttribute('role')"), "listitem", info = w)
    expect_false(identical(ui2_js(s, "document.activeElement.getAttribute('data-id')"), id))
    # Enter opens a row for editing, which takes aria-current alone.
    ui2_key(s, sprintf("#itemList .ic[data-id='%s']", id), "Enter")
    expect_true(ui2_wait(s, sprintf("document.querySelector('#itemList .ic[data-id=\"%s\"]').getAttribute('aria-current') === 'true'", id), 5))
    expect_identical(ui2_js(s, "document.querySelectorAll('#itemList [aria-current]').length"), 1L)
  }
})

ui2_close()
ui1_close()
