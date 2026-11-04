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

ui1_close()
