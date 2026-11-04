# tests/testthat/test-studio-ui1-browser.R
#
# Session UI-1's SurveyStudio screens in a real Chrome, against the build
# under test. The tests share 1 Studio per demo (helper-ui1-browser.R) and run
# in order, so a later test starts from the state an earlier one left, and
# each says what it expects to find.

skip_on_cran()
skip_if_not_slow()
skip_if_not_installed("shiny")
skip_if_not_installed("chromote")
skip_if_not_installed("callr")
skip_if_not_installed("psych")
chrome <- tryCatch(chromote::find_chrome(), error = function(e) NULL)
skip_if(length(chrome) != 1L || is.na(chrome) || !nzchar(chrome), "Chrome not found")

test_that("Drop from scale and Put back go through the 1 amendment dialog", {
  b <- ui1_studio("factor_structure", "analysis")
  expect_true(ui1_screen(b, "analysis"))
  ui2_js(b, "if ($('input[name=analysis_stage]').length) Shiny.setInputValue('analysis_stage', 'Run'); true")
  drop_btn <- "$('#screen-analysis .flag-list[data-block=\"RQ2\"] button:contains(\"Drop from scale\")')"
  expect_true(ui2_wait(b, paste0(drop_btn, ".length === 1"), 90))
  expect_match(ui1_text(b, "screen-analysis"), "con_4: loading .39 in RQ2, below .40",
               fixed = TRUE)

  ui2_js(b, paste0(drop_btn, ".click(); true"))
  expect_true(ui2_wait(b, ui1_modal_open, 20))
  expect_match(ui1_text(b, "shiny-modal"), "Drop con_4 from content", fixed = TRUE)
  expect_match(ui2_js(b, "$('#amend_dlg-reason_text').val()"), "loading .39", fixed = TRUE)
  expect_match(ui1_text(b, "shiny-modal"), "Scales whose scoring changes: content", fixed = TRUE)
  ui2_js(b, "$('#amend_dlg-record').click(); true")
  expect_true(ui2_wait(b, paste0("!", ui1_modal_open), 20))

  # The rerun shows the drop with Put back, and the status counts it.
  put_btn <- "$('#screen-analysis .flag-list[data-block=\"RQ2\"] button:contains(\"Put back\")')"
  expect_true(ui2_wait(b, paste0(put_btn, ".length === 1"), 90))
  expect_true(ui2_wait(b, "document.getElementById('status_instrument').innerText.indexOf('1 amendment') >= 0", 20))

  ui2_js(b, paste0(put_btn, ".click(); true"))
  expect_true(ui2_wait(b, ui1_modal_open, 20))
  expect_match(ui1_text(b, "shiny-modal"), "Put con_4 back in content", fixed = TRUE)
  ui2_js(b, "$('#amend_dlg-record').click(); true")
  expect_true(ui2_wait(b, paste0("!", ui1_modal_open), 20))
  expect_true(ui2_wait(b, "document.getElementById('status_instrument').innerText.indexOf('2 amendments') >= 0", 20))

  # The Amendments screen holds the whole history, with the hashes.
  expect_true(ui1_screen(b, "amendments"))
  expect_true(ui2_wait(b, "(document.getElementById('amendment_log_table')||{innerText:''}).innerText.indexOf('Put con_4 back') >= 0", 20))
  log <- ui1_text(b, "amendment_log_table")
  expect_match(log, "Hash before", fixed = TRUE)
  expect_match(log, "Model respecification: con_4: loading", fixed = TRUE)
  expect_match(ui1_text(b, "amend_version_line"), "2 amendments", fixed = TRUE)
  expect_match(ui1_text(b, "amend_put_back_note"), "put the item back in Design", fixed = TRUE)
})

test_that("Quality records a bot removal as a pipeline amendment", {
  b <- ui1_studio("factor_structure")
  expect_true(ui1_screen(b, "quality"))
  expect_true(ui2_wait(b, "!!document.getElementById('quality_amend_btn')", 30))
  ui2_js(b, "$('#quality_amend_btn').click(); true")
  expect_true(ui2_wait(b, ui1_modal_open, 20))
  expect_true(ui2_wait(b, "$('#amend_dlg-tier').val() === 'pipeline'", 10))
  ui1_set(b, "amend_dlg-reason_text", "Removed 2 bot responses.")
  Sys.sleep(1)
  ui2_js(b, "$('#amend_dlg-record').click(); true")
  expect_true(ui2_wait(b, paste0("!", ui1_modal_open), 20))
  expect_true(ui2_wait(b, "document.getElementById('status_instrument').innerText.indexOf('3 amendments') >= 0", 20))
})

test_that("Analyse shows the declared plan, and a plan change after the data is a design amendment", {
  b <- ui1_studio("factor_structure")
  expect_true(ui1_screen(b, "analysis"))
  expect_true(ui2_wait(b, "!!document.querySelector('#declared_plan_card table')", 30))
  plan <- ui1_text(b, "declared_plan_card")
  expect_match(plan, "RQ2", fixed = TRUE)
  expect_match(plan, "Research question", fixed = TRUE)
  expect_false(ui2_js(b, "!!document.querySelector('input[name=analysis_stage]')"))
  expect_false(ui2_js(b, "!!document.getElementById('analysis_method')"))

  ui2_js(b, "$('#analysis_change_plan').click(); true")
  expect_true(ui2_wait(b, "$('#screen-plan').hasClass('active') || $('#screen-design').hasClass('active')", 20))
  frame <- "document.getElementById('design_frame').contentWindow"
  expect_true(ui2_wait(b, paste0(frame, ".S && ", frame, ".S.analysis_plan.length > 1"), 60))
  ui2_js(b, paste0("var w=", frame, "; w.S.analysis_plan[1].research_question = 'A narrower question.'; w.setDirty(); w.saveSframe(); true"))
  expect_true(ui2_wait(b, ui1_modal_open, 30))
  expect_match(ui1_text(b, "shiny-modal"), "The plan changed after the responses were loaded", fixed = TRUE)
  expect_match(ui2_js(b, "$('#amend_dlg-deviation_report').val()"),
               "Plan changed after the responses were loaded: RQ2 changed. Reason: ", fixed = TRUE)
  ui2_js(b, "$('#amend_dlg-cancel').click(); true")
  expect_true(ui2_wait(b, paste0("!", ui1_modal_open), 20))
})

test_that("Report has 4 local tabs, a choice survives a switch, and Download copy sits by the title", {
  b <- ui1_studio("factor_structure")
  expect_true(ui1_screen(b, "export"))
  expect_identical(ui2_js(b, "$('#screen-export .report-tab').map(function(){ return $(this).text(); }).get().join('|')"),
                   "Interpret|Configure|Export report|Reproduce")
  expect_true(ui2_wait(b, "$('.screen-head #download_sframe_btn').text().indexOf('Download copy') >= 0", 30))
  expect_identical(ui2_js(b, "$('#rtab-interpret').attr('aria-selected')"), "true")

  ui2_js(b, "$('#rtab-configure').click(); true")
  expect_true(ui2_wait(b, "$('#rpane-configure').is(':visible') && !$('#rpane-interpret').is(':visible')"))
  ui1_set(b, "rpt_title", "Kept across tabs")
  ui2_js(b, "$('#rpt_codebook').prop('checked', false).trigger('change'); true")
  ui2_js(b, "$('#rtab-interpret').click(); true")
  expect_true(ui2_wait(b, "$('#rpane-interpret').is(':visible')"))
  ui2_js(b, "$('#rtab-configure').click(); true")
  expect_true(ui2_wait(b, "$('#rpane-configure').is(':visible')"))
  expect_identical(ui2_js(b, "$('#rpt_title').val()"), "Kept across tabs")
  expect_false(ui2_js(b, "$('#rpt_codebook').prop('checked')"))

  # Arrow keys move along the tabs.
  ui2_js(b, "$('#rtab-configure').focus(); true")
  ui2_key(b, "#rtab-configure", "ArrowRight")
  expect_true(ui2_wait(b, "$('#rpane-export').is(':visible') && document.activeElement.id === 'rtab-export'"))

  # Item 5: the Quarto line comes from sframe_quarto_find().
  expect_true(ui2_wait(b, "/^Quarto (was not found|is turned off|[0-9])/.test($('#quarto_status').text())", 20))
  ui2_js(b, "$('#rtab-configure').click(); $('#rpt_codebook').prop('checked', true).trigger('change'); $('#rpt_title').val('').trigger('change'); $('#rtab-interpret').click(); true")
})

test_that("Harvard chosen as the reference style puts harvard.csl in the source folder", {
  b <- ui1_studio("factor_structure")
  expect_true(ui1_screen(b, "export"))
  ui2_js(b, "$('#rtab-configure').click(); true")
  expect_true(ui2_wait(b, "$('#rpane-configure').is(':visible') && !!document.getElementById('rpt_style')", 20))
  opts <- ui2_js(b, "$('#rpt_style option').map(function(){ return $(this).text(); }).get().concat(document.getElementById('rpt_style').selectize ? Object.values(document.getElementById('rpt_style').selectize.options).map(function(o){ return o.label; }) : []).join('|')")
  expect_match(opts, "^APA 7")
  skip_if(is.na(surveyframe:::sframe_quarto_find()$path), "Quarto is not installed, so APA 7 is the only style")
  expect_match(opts, "Harvard", fixed = TRUE)

  ui1_set(b, "rpt_style", "other")
  expect_true(ui2_wait(b, "$('#rpt_style_find').is(':visible') && $('#rpt_style_find').attr('target') === '_blank'"))
  ui1_set(b, "rpt_style", "harvard")
  expect_true(ui2_wait(b, "!$('#rpt_style_find').is(':visible')"))
  Sys.sleep(1)
  ui2_js(b, "$('#rtab-reproduce').click(); true")
  expect_true(ui2_wait(b, "!!$('#download_source_btn').attr('href') && $('#download_source_btn').attr('href') !== '#'", 30))
  zip_b64 <- ui2_js(b, paste0(
    "fetch($('#download_source_btn').attr('href')).then(function(r) { return r.arrayBuffer(); })",
    ".then(function(b) { var u = new Uint8Array(b), s = ''; for (var i = 0; i < u.length; i++) s += String.fromCharCode(u[i]); return btoa(s); })"),
    await = TRUE)
  zf <- tempfile(fileext = ".zip")
  writeBin(jsonlite::base64_dec(zip_b64), zf)
  listed <- utils::unzip(zf, list = TRUE)$Name
  expect_true("report_source/harvard.csl" %in% listed)
  expect_false("report_source/apa.csl" %in% listed)
  ui1_set(b, "rpt_style", "apa")
})

test_that("an interpretation box cites through the shared picker, and Manage references opens References", {
  b <- ui1_studio("factor_structure")
  expect_true(ui1_screen(b, "export"))
  ui2_js(b, "$('#rtab-interpret').click(); $('#export_interpretations_ui details').first().attr('open', true); true")
  expect_true(ui2_wait(b, "!!document.querySelector('#export_interpretations_ui textarea[data-cite]')", 60))
  expect_true(ui2_wait(b, "(function(){ var t = document.querySelector('#export_interpretations_ui textarea[data-cite]'); return !!window.studioPickers[t.id]; })()", 20))
  expect_true(ui2_wait(b, "window.studioKnownKeys.indexOf('surveyframe') >= 0", 20))
  expect_false(ui2_js(b, "!!document.getElementById('rpt_bibtex')"))

  ui2_js(b, "$('#rtab-configure').click(); true")
  expect_true(ui2_wait(b, "$('#rpt_manage_refs').is(':visible')"))
  ui2_js(b, "$('#rpt_manage_refs').click(); true")
  expect_true(ui2_wait(b, "$('#screen-references').hasClass('active')", 20))
  opts <- ui2_js(b, "Object.keys((document.getElementById('refs_cited_by').selectize || {options: {}}).options).join('|')")
  expect_match(opts, "plan:RQ2", fixed = TRUE)
})

test_that("with no instrument the gate replaces the body of References, Amendments and Report", {
  b <- ui1_studio("none", "design")
  editors <- c(references = "refs_bibtex", amendments = "amend_edit_design",
               export = "rpt_title")
  for (screen in names(editors)) {
    expect_true(ui1_screen(b, screen), info = screen)
    expect_true(ui2_wait(b, sprintf("$('#screen-%s').hasClass('screen-gated') && $('#screen-%s .next-stage').is(':visible')",
                                    screen, screen), 20), info = screen)
    expect_false(ui2_js(b, sprintf("$('#%s').is(':visible')", editors[[screen]])), info = screen)
    expect_true(ui2_js(b, sprintf("$('#screen-%s .screen-title').is(':visible')", screen)), info = screen)
  }
  expect_false(ui2_js(b, "$('#screen-export .report-tabs').is(':visible')"))
  expect_false(ui2_js(b, "$('#download_sframe_btn').is(':visible')"))
})

test_that("the Open card says Schema valid or Draft, with the version and count linked to Amendments", {
  b <- ui1_studio("factor_structure")
  expect_true(ui1_screen(b, "open"))
  expect_true(ui2_wait(b, "!!document.getElementById('open_schema_status')", 20))
  expect_match(ui1_text(b, "open_schema_status"), "^(Schema valid|Draft)$")
  expect_match(ui1_text(b, "open_status_version"), ", ([0-9]+ amendments?|no amendments)$")
  expect_identical(ui1_text(b, "open_status_version"), ui1_text(b, "open_version"))
  ui2_js(b, "$('#open_status_version').click(); true")
  expect_true(ui2_wait(b, "$('#screen-amendments').hasClass('active')", 20))
})

test_that("the sidebar is a labelled nav with aria-current, fragment links and browser history", {
  b <- ui1_studio("factor_structure")
  expect_identical(ui2_js(b, "$('nav.studio-nav-wrap').attr('aria-label')"), "Studio screens")
  expect_identical(ui2_js(b, "$('.studio-nav a[href=\"#\"]').length"), 0L)
  expect_true(ui1_screen(b, "quality"))
  expect_true(ui1_screen(b, "reliability"))
  expect_identical(ui2_js(b, "$('.studio-nav a[aria-current=\"page\"]').length"), 1L)
  expect_identical(ui2_js(b, "$('.studio-nav a[aria-current=\"page\"]').data('tab')"), "reliability")
  expect_identical(ui2_js(b, "location.hash"), "#reliability")

  ui2_js(b, "history.back(); true")
  expect_true(ui2_wait(b, "$('#screen-quality').hasClass('active') && $('.studio-nav a[aria-current=\"page\"]').data('tab') === 'quality'", 10))
  ui2_js(b, "history.forward(); true")
  expect_true(ui2_wait(b, "$('#screen-reliability').hasClass('active')", 10))

  # Plan is an entry like the others.
  expect_identical(ui2_js(b, "$('.studio-nav a[data-nav=\"plan\"]').attr('href')"), "#plan")
  ui2_js(b, "$('.studio-nav a[data-nav=\"plan\"]').click(); true")
  expect_true(ui2_wait(b, "location.hash === '#plan' && $('.studio-nav a[data-nav=\"plan\"]').attr('aria-current') === 'page'", 10))
  expect_true(ui1_screen(b, "open"))
})

test_that("at 390 x 844 the sidebar is a drawer and no screen is wider than the viewport", {
  b <- ui1_studio("factor_structure", width = 390, height = 844)
  on.exit(ui1_studio("factor_structure", width = 1280, height = 900), add = TRUE)
  expect_true(ui2_wait(b, "window.innerWidth === 390 && $('#studio_menu_btn').is(':visible')", 10))
  expect_identical(ui2_js(b, "$('#studio_menu_btn').attr('aria-expanded')"), "false")
  expect_false(ui2_js(b, "$('#studio_sidebar').css('visibility') === 'visible' && document.getElementById('studio_sidebar').getBoundingClientRect().right > 0"))

  ui2_js(b, "$('#studio_menu_btn').click(); true")
  expect_true(ui2_wait(b, "$('#studio_menu_btn').attr('aria-expanded') === 'true' && document.getElementById('studio_sidebar').getBoundingClientRect().left >= 0", 5))
  ui2_js(b, "$('#studio_sidebar a[data-tab=\"quality\"]').click(); true")
  expect_true(ui2_wait(b, "$('#screen-quality').hasClass('active') && $('#studio_menu_btn').attr('aria-expanded') === 'false'", 10))

  for (screen in sframe_studio_screens()) {
    expect_true(ui1_screen(b, screen), info = screen)
    Sys.sleep(2)
    w <- ui2_js(b, "Math.max(document.documentElement.scrollWidth, document.body.scrollWidth)")
    expect_lte(w, 390, label = paste("page width on", screen))
  }
  ui2_js(b, "$('#rtab-configure').click(); true")
  Sys.sleep(1)
  expect_lte(ui2_js(b, "document.documentElement.scrollWidth"), 390, label = "Report Configure tab width")
  ui2_js(b, "$('#rtab-interpret').click(); true")
})

test_that("the format toolbar shows on an interpretation box's focus, inserts Markdown and hides on blur", {
  b <- ui1_studio("factor_structure")
  expect_true(ui1_screen(b, "export"))
  ui2_js(b, "$('#rtab-interpret').click(); $('#export_interpretations_ui details').first().attr('open', true); true")
  ta <- "document.querySelector('#export_interpretations_ui textarea[data-cite]')"
  expect_true(ui2_wait(b, paste0("!!", ta, " && !!window.studioPickers[", ta, ".id]"), 60))
  bar <- paste0("(", ta, ".parentNode.querySelector('.sfcp-bar') || document.querySelector('.sfcp-bar'))")
  ui2_js(b, paste0("var t = ", ta, "; t.focus(); t.value = 'clear'; t.setSelectionRange(0, 5); true"))
  expect_true(ui2_wait(b, paste0("!", bar, ".hidden"), 5))
  ui2_key(b, "", "b", ctrl = TRUE)
  expect_true(ui2_wait(b, paste0(ta, ".value === '**clear**'"), 5))
  id <- ui2_js(b, paste0(ta, ".id"))
  ui2_js(b, paste0(ta, ".blur(); document.body.focus(); true"))
  expect_true(ui2_wait(b, paste0(bar, ".hidden"), 5))
  expect_true(ui2_wait(b, sprintf("Shiny.shinyapp.$inputValues['%s'] === '**clear**'", id), 10))
  ui2_js(b, paste0("var t = ", ta, "; t.value = ''; $(t).trigger('change'); true"))

  # The amendment dialog's deviation report takes the same toolbar.
  expect_true(ui1_screen(b, "quality"))
  ui2_js(b, "$('#quality_amend_btn').click(); true")
  expect_true(ui2_wait(b, ui1_modal_open, 20))
  expect_true(ui2_wait(b, "!!window.studioPickers['amend_dlg-deviation_report']", 10))
  ui2_js(b, "$('#amend_dlg-cancel').click(); true")
  expect_true(ui2_wait(b, paste0("!", ui1_modal_open), 20))
})

test_that("the builder's Open Collect and Manage references open Studio's screens", {
  b <- ui1_studio("factor_structure")
  expect_true(ui1_screen(b, "design"))
  frame <- "document.getElementById('design_frame').contentWindow"
  expect_true(ui2_wait(b, paste0(frame, ".S && typeof ", frame, ".studioGoto === 'function'"), 60))
  ui2_js(b, paste0("var w = ", frame, "; var btn = w.document.querySelector('button[onclick=\"studioGoto(\\'collect\\')\"]'); btn.click(); true"))
  expect_true(ui2_wait(b, "$('#screen-collect').hasClass('active') && location.hash === '#collect'", 10))
  expect_true(ui1_screen(b, "design"))
  ui2_js(b, paste0(frame, ".manageRefs(); true"))
  expect_true(ui2_wait(b, "$('#screen-references').hasClass('active')", 10))
  # A message from another window does nothing.
  ui2_js(b, "window.postMessage({type: 'goto', screen: 'collect'}, location.origin); true")
  Sys.sleep(1)
  expect_true(ui2_js(b, "$('#screen-references').hasClass('active')"))
})

test_that("inside Studio only the sidebar picks Build or Plan, and the builder's switch is hidden", {
  b <- ui1_studio("factor_structure")
  expect_true(ui1_screen(b, "design"))
  doc <- "document.getElementById('design_frame').contentWindow.document"
  expect_true(ui2_wait(b, paste0("!!", doc, ".querySelector('.tb-modes')"), 60))
  expect_true(ui2_js(b, paste0(doc, ".querySelector('.tb-modes').offsetParent === null")))
  mode <- paste0("(", doc, ".querySelector('.m-btn[aria-pressed=\"true\"]') || {dataset: {}}).dataset.mode")
  ui2_js(b, "$('.studio-nav a[data-nav=\"plan\"]').click(); true")
  expect_true(ui2_wait(b, paste0(mode, " === 'analyse'"), 30))
  expect_true(ui1_screen(b, "design"))
  expect_true(ui2_wait(b, paste0(mode, " === 'build'"), 30))
})

test_that("each screen's title and context line are 1 row at the top of its panel", {
  b <- ui1_studio("factor_structure")
  for (screen in sframe_studio_screens()) {
    expect_true(ui1_screen(b, screen), info = screen)
    expect_true(ui2_js(b, sprintf("$('#screen-%s').children().first().is('.screen-head') && $('#screen-%s > .screen-head h2.screen-title').length === 1", screen, screen)), info = screen)
    # The head is 1 compact row: at most 2 lines of the title's height.
    expect_lt(ui2_js(b, sprintf("$('#screen-%s > .screen-head').outerHeight()", screen)), 90, label = screen)
  }
  expect_true(ui1_screen(b, "design"))
  expect_true(ui2_wait(b, "$('#screen-design > .screen-head').text().indexOf('Editing: ') >= 0", 20))
})

test_that("Design's head holds the instrument's title and version, in Build and Plan and with unsaved changes (item 12h)", {
  b <- ui1_studio("factor_structure")
  ins <- surveyframe::sframe_demo("factor_structure")$instrument
  want <- paste0("Editing: ", ins$meta$title, " (", ins$meta$version, ")")
  head_has <- function() {
    ui2_wait(b, sprintf(paste0(
      "(function(){ var h = $('#screen-design > .screen-head'), s = document.getElementById('design_status');",
      "  return h.text().indexOf(%s) >= 0 && s.offsetWidth > 0 && s.offsetHeight > 0; })()"),
      jsonlite::toJSON(want, auto_unbox = TRUE)), 20)
  }
  expect_true(ui1_screen(b, "design"))
  expect_true(head_has(), label = "Build")
  ui2_js(b, "$('.studio-nav a[data-nav=\"plan\"]').click(); true")
  expect_true(ui2_wait(b, "$('#screen-design').hasClass('active')", 20))
  expect_true(head_has(), label = "Plan")
  # The unsaved note joins the line and does not replace it.
  ui2_js(b, "$('#design_unsaved').show(); true")
  expect_true(head_has(), label = "unsaved")
  expect_lt(ui2_js(b, "$('#screen-design > .screen-head').outerHeight()"), 90)
  ui2_js(b, "$('#design_unsaved').hide(); true")
  expect_true(ui1_screen(b, "design"))
})

test_that("no screen offers 2 controls for the same destination (item 12d)", {
  b <- ui1_studio("factor_structure")
  for (screen in sframe_studio_screens()) {
    expect_true(ui1_screen(b, screen), info = screen)
    Sys.sleep(1)
    dup <- ui2_js(b, sprintf(paste0(
      "(function(){ var seen = {}, d = [];",
      "  $('#screen-%s a[data-tab]:visible, #screen-%s a[data-nav]:visible').each(function() {",
      "    var k = $(this).attr('data-tab') || 'plan';",
      "    if (seen[k]) d.push(k); seen[k] = true; });",
      "  return d.join(','); })()"), screen, screen))
    expect_identical(dup, "", info = screen)
  }
  # The builder inside Studio shows no switch, Open, Export survey or Collect
  # and References controls of its own.
  expect_true(ui1_screen(b, "design"))
  doc <- "document.getElementById('design_frame').contentWindow.document"
  for (sel in c(".tb-modes", "#openBtn", "#exportBtn")) {
    expect_true(ui2_js(b, sprintf("(function(){ var e = %s.querySelector('%s'); return !e || e.offsetParent === null; })()", doc, sel)), info = sel)
  }
})

test_that("each screen has exactly 1 primary action, visible without scrolling at 1280 px (item 12e)", {
  b <- ui1_studio("factor_structure", width = 1280, height = 900)
  for (screen in setdiff(sframe_studio_screens(), "design")) {
    expect_true(ui1_screen(b, screen), info = screen)
    Sys.sleep(1.5)
    ui2_js(b, "window.scrollTo(0, 0); true")
    got <- ui2_js(b, sprintf(paste0(
      "(function(){ var p = $('#screen-%s .sf-primary:visible');",
      "  var r = p.length ? p[0].getBoundingClientRect() : null;",
      "  return p.length + ':' + $('#screen-%s .btn-primary:visible').length + ':' + (r && r.top >= 0 && r.bottom <= window.innerHeight); })()"),
      screen, screen))
    expect_identical(got, "1:1:true", info = screen)
  }
  expect_true(ui1_screen(b, "design"))
  doc <- "document.getElementById('design_frame').contentWindow.document"
  expect_true(ui2_wait(b, paste0("!!", doc, ".querySelector('#saveBtn.sf-primary')"), 60))
  expect_identical(ui2_js(b, paste0(doc, ".querySelectorAll('.sf-primary').length")), 1L)
  expect_true(ui2_js(b, paste0("(function(){ var s = ", doc, ".getElementById('saveBtn'), t = ", doc,
    ".querySelector('.topbar'); return t.firstElementChild === s && s.getBoundingClientRect().bottom <= window.innerHeight; })()")))
  expect_true(ui2_wait(b, paste0("parseInt(getComputedStyle(", doc, ".getElementById('saveBtn')).fontSize) >= 15"), 10))
})

test_that("Explore's Download CSV shows on every view and holds the responses the filters keep (12e gap)", {
  resp <- sframe_demo("input_types")$responses
  chosen <- sort(unique(as.character(resp$visit_type[!is.na(resp$visit_type)])))[1]
  expected <- sum(as.character(resp$visit_type) == chosen, na.rm = TRUE)
  expect_lt(expected, nrow(resp))

  b <- ui1_studio("input_types")
  expect_true(ui1_screen(b, "dashboard"))
  for (view in c("Overview", "Items", "Scales", "Data")) {
    ui2_js(b, sprintf("Shiny.setInputValue('dashboard_view', '%s'); $('input[name=dashboard_view][value=%s]').prop('checked', true); true", view, view))
    expect_true(ui2_wait(b, "$('#screen-dashboard .sf-primary:visible').length === 1 && $('#screen-dashboard .sf-primary:visible').attr('id') === 'dash_dl_csv'", 20), label = view)
  }
  # The Data view keeps its row hint.
  expect_true(ui2_wait(b, "$('#screen-dashboard').text().indexOf('Showing the first 200 of') >= 0", 20))

  ui2_js(b, "Shiny.setInputValue('dashboard_view', 'Overview'); $('input[name=dashboard_view][value=Overview]').prop('checked', true); true")
  expect_true(ui2_wait(b, "$('#dash_dl_csv').is(':visible') && $('#screen-dashboard').text().indexOf('Showing the first 200 of') < 0", 20))
  csv_rows <- function() {
    got <- b$Runtime$evaluate(
      "fetch($('#dash_dl_csv').attr('href')).then(function(r){ return r.text(); })",
      awaitPromise = TRUE, returnByValue = TRUE)$result$value
    nrow(utils::read.csv(text = got, check.names = FALSE))
  }
  expect_identical(csv_rows(), nrow(resp))
  ui2_js(b, sprintf("Shiny.setInputValue('dash_filter_visit_type', ['%s']); true", chosen))
  Sys.sleep(2)
  expect_identical(csv_rows(), expected)
  ui2_js(b, "Shiny.setInputValue('dash_filter_visit_type', []); true")
})

test_that("Responses puts the Google Sheet card first, with Read from Google Sheet as its primary (item 12f)", {
  b <- ui1_studio("factor_structure")
  expect_true(ui1_screen(b, "responses"))
  titles <- ui2_js(b, "$('#screen-responses > .card > .card-title').map(function(){ return $(this).text(); }).get().join('|')")
  expect_match(titles, "^Read responses from a deployed Google Sheet\\|Response data\\|Loading responses collected elsewhere")
  expect_identical(ui2_js(b, "$('#screen-responses .sf-primary:visible').attr('id')"), "load_sheet_btn")
  expect_true(ui2_js(b, "$('#load_responses_btn').hasClass('btn-outline')"))
  has_gs <- requireNamespace("googlesheets4", quietly = TRUE)
  expect_identical(ui2_js(b, "$('#sheet_pkg_missing').is(':visible')"), !has_gs)
})

test_that("the builder iframe and field_tools.js carry a version token (item 12g)", {
  b <- ui1_studio("factor_structure")
  token <- function(file) {
    path <- sframe_installed_path("inst", "builder", file)
    paste0(utils::packageVersion("surveyframe"), "-",
           substr(unname(tools::md5sum(path)), 1L, 8L))
  }
  frame <- ui2_js(b, "document.getElementById('design_frame').getAttribute('src')")
  expect_identical(frame, paste0("sfbuilder/survey_builder.html?host=studio&v=",
                                 token("survey_builder.html")))
  script <- ui2_js(b, "$('script[src^=\"sfbuilder/field_tools.js\"]').attr('src')")
  expect_identical(script, paste0("sfbuilder/field_tools.js?v=", token("field_tools.js")))
  # The token leaves the builder's Studio route on, which reads ?host=studio.
  expect_true(ui1_screen(b, "design"))
  expect_true(ui2_wait(b, "(function(){ var w = document.getElementById('design_frame').contentWindow; return !!(w && w.STUDIO_HOST); })()", 60))
})

test_that("at 1920 px every primary action, Save to Studio included, sizes to its label (item 12h)", {
  b <- ui1_studio("factor_structure", width = 1920, height = 1080)
  on.exit(ui1_studio("factor_structure", width = 1280, height = 900), add = TRUE)
  expect_true(ui2_wait(b, "window.innerWidth === 1920", 10))
  expect_true(ui1_screen(b, "design"))
  doc <- "document.getElementById('design_frame').contentWindow.document"
  save <- paste0(doc, ".getElementById('saveBtn')")
  expect_true(ui2_wait(b, paste0("(function(){ try { var s = ", save,
                                 "; return !!s && s.classList.contains('sf-primary') && s.offsetWidth > 0; } catch (e) { return false; } })()"), 60))
  # The stylesheet loads after the class is set, so wait for its rules.
  expect_true(ui2_wait(b, paste0("getComputedStyle(", save, ").justifySelf === 'start'"), 20))
  w <- ui2_js(b, paste0(save, ".getBoundingClientRect().width"))
  expect_lt(w, 300, label = "Save to Studio width")
  expect_gt(w, 60, label = "Save to Studio width")
  for (screen in sframe_studio_screens()) {
    expect_true(ui1_screen(b, screen), info = screen)
    widths <- ui2_js(b, sprintf("$('#screen-%s .sf-primary:visible').map(function(){ return this.getBoundingClientRect().width; }).get()", screen))
    for (x in unlist(widths)) expect_lt(x, 300, label = paste("primary width on", screen))
  }
})

# Contrast (UX-21): every visible text and background pair, measured from
# computed colours, meets WCAG 2.2 AA on every Studio screen and Report tab,
# in the hosted builder's Build and Plan, and in the survey template at the
# default, darkest, lightest and Studio's teal theme. Last but one, since
# the template pages replace Studio in the tab.
test_that("every Studio screen, the hosted builder and the template meet AA contrast (UX-21)", {
  fails <- list()
  measure <- function(where, d) {
    if (nrow(d)) fails[[where]] <<- d
    expect_identical(nrow(d), 0L, label = paste("pairs below AA on", where))
  }
  b <- ui1_studio("factor_structure", width = 1280, height = 900)
  for (s in sframe_studio_screens()) {
    expect_true(ui1_screen(b, s), info = s)
    Sys.sleep(2)
    measure(paste("Studio", s), ui1_contrast(b))
  }
  # The open screen is marked by more than colour: a bar and a bold label.
  expect_identical(ui2_js(b, "(function(){ var a = $('.studio-nav-item a.active'), o = $('.studio-nav-item a:not(.active)').first(); return a.length === 1 && parseInt(a.css('font-weight'), 10) >= 700 && parseInt(o.css('font-weight'), 10) < 700 && a.css('border-left-width') === '3px'; })()"), TRUE)
  for (t in c("configure", "interpret", "preview", "reproduce")) {
    ui2_js(b, sprintf("$('#rtab-%s').click(); true", t))
    Sys.sleep(1.5)
    measure(paste("Report tab", t), ui1_contrast(b))
  }
  expect_true(ui1_screen(b, "design"))
  doc <- "document.getElementById('design_frame').contentWindow.document"
  expect_true(ui2_wait(b, paste0("(function(){ try { return !!", doc, ".getElementById('saveBtn'); } catch (e) { return false; } })()"), 60))
  Sys.sleep(2)
  measure("builder Build", ui1_contrast(b, doc))
  ui2_js(b, "$('.studio-nav a[data-nav=\"plan\"]').click(); true")
  Sys.sleep(3)
  measure("builder Plan", ui1_contrast(b, doc))

  ins <- sframe_demo("factor_structure")$instrument
  for (col in c("#2563eb", "#000000", "#ffffff", "#16B3B1")) {
    ins$render$theme <- col
    f <- file.path(tempdir(), paste0("ui1-contrast-", substr(col, 2, 7), ".html"))
    suppressMessages(export_survey(ins, f, open = FALSE, overwrite = TRUE))
    ui2_navigate(b, paste0("file://", f))
    Sys.sleep(1.5)
    measure(paste("template", col, "welcome"), ui1_contrast(b))
    # The first page, with its first option chosen, so the checked state shows.
    ui2_js(b, "var c = document.getElementById('consent-chk'); if (c) c.checked = true; startSurvey(); true")
    Sys.sleep(1)
    ui2_js(b, "var i = document.querySelector('.likert-opt input, .choice-opt input'); if (i) i.click(); true")
    Sys.sleep(0.5)
    measure(paste("template", col, "page 1"), ui1_contrast(b))
    unlink(f)
  }
  if (length(fails)) print(fails)
  expect_true(ui1_reload("factor_structure"))
})

# Last, since it loads the page again, which starts Studio's session again.
test_that("sidebar groups fold, stay folded after a reload, and a fragment into a folded group opens it", {
  b <- ui1_studio("factor_structure")
  expect_true(ui1_screen(b, "open"))
  fold <- "$('.studio-nav-heading[data-group=\"collect\"] .studio-nav-fold')"
  expect_identical(ui2_js(b, paste0(fold, ".attr('aria-expanded')")), "true")
  ui2_js(b, paste0(fold, ".click(); true"))
  expect_identical(ui2_js(b, paste0(fold, ".attr('aria-expanded')")), "false")
  expect_false(ui2_js(b, "$('.studio-nav a[data-tab=\"responses\"]').is(':visible')"))
  # The group holding the open screen does not fold.
  expect_true(ui1_screen(b, "quality"))
  ui2_js(b, "$('.studio-nav-heading[data-group=\"analyse\"] .studio-nav-fold').click(); true")
  expect_identical(ui2_js(b, "$('.studio-nav-heading[data-group=\"analyse\"] .studio-nav-fold').attr('aria-expanded')"), "true")
  expect_true(ui1_screen(b, "open"))

  expect_true(ui1_reload("factor_structure"))
  expect_true(ui2_wait(b, paste0(fold, ".attr('aria-expanded') === 'false'"), 20))
  expect_false(ui2_js(b, "$('.studio-nav a[data-tab=\"responses\"]').is(':visible')"))

  ui2_js(b, "location.hash = '#responses'; true")
  expect_true(ui2_wait(b, paste0("$('#screen-responses').hasClass('active') && ", fold,
                                 ".attr('aria-expanded') === 'true'"), 20))
  expect_true(ui2_js(b, "$('.studio-nav a[data-tab=\"responses\"]').is(':visible')"))
  ui2_js(b, "localStorage.removeItem('sfstudio-fold-collect'); true")
})

ui1_close()
