# tests/testthat/test-builder-role-aliases.R
#
# CX-16. A mediation block written in R names its roles x, mediator and y.
# SurveyBuilder's editor knew only predictor and outcome, so it opened with
# the first variable in both and Save disabled. The builder now carries R's
# role alias table, inlined by data-raw/inline_role_aliases.R, and an unset
# single role shows a placeholder instead of the first variable.

inlined_alias_line <- function() {
  builder <- readLines(system.file("builder", "survey_builder.html",
                                   package = "surveyframe"),
                       warn = FALSE, encoding = "UTF-8")
  start <- grep("/* ALIAS_TABLE_START", builder, fixed = TRUE)
  end <- grep("/* ALIAS_TABLE_END */", builder, fixed = TRUE)
  expect_length(start, 1)
  expect_length(end, 1)
  builder[(start + 1):(end - 1)]
}

alias_instrument <- function() {
  sf_instrument("Aliases", components = lapply(
    c("unused", "exposure", "mediator", "outcome"),
    function(id) sf_item(id, id, type = "numeric")))
}

test_that("the builder's inlined alias table is R's alias table", {
  expect_identical(
    inlined_alias_line(),
    paste0("var ROLE_ALIASES_BY_METHOD=", sframe_role_aliases_json(), ";"),
    info = "Run data-raw/inline_role_aliases.R to regenerate the builder.")
})

test_that("R reads every alias the table lists", {
  vars_for <- function(method, role, value) {
    roles <- stats::setNames(list(value), role)
    sframe_vars_for_method(method, roles, list())
  }
  for (method in names(sframe_role_aliases())) {
    for (role in names(sframe_role_aliases()[[method]])) {
      for (alias in sframe_role_aliases()[[method]][[role]]) {
        expect_identical(vars_for(method, alias, "v"), "v",
                         info = paste(method, alias))
      }
    }
  }
  # The mediation aliases the defect turned on.
  expect_identical(sframe_role_aliases()$mediation$predictor, "x")
  expect_true("y" %in% sframe_role_aliases()$mediation$outcome)
})

test_that("a mediation plan written with x, mediator and y opens as predictor, mediator, outcome", {
  ctx <- builder_context()
  builder_open(ctx, alias_instrument())
  opened <- ctx$eval("JSON.stringify((function(){
    var roles = {x:'exposure', mediator:'mediator', y:'outcome'};
    var out = {};
    ANALYSIS_REGISTRY.mediation.roles.forEach(function(r){
      out[r.id] = roleValueFor(roles, r.id, 'mediation'); });
    return out; })())")
  expect_identical(
    jsonlite::fromJSON(opened),
    list(predictor = "exposure", mediator = "mediator", outcome = "outcome"))
})

test_that("an unset single role shows a placeholder, not the first variable", {
  ctx <- builder_context()
  builder_open(ctx, alias_instrument())
  html <- ctx$eval("roleOptions(ANALYSIS_REGISTRY.mediation.roles[0], [])")
  expect_match(html, "^<option value=\"\" selected>Choose a variable</option>")
  expect_false(grepl("value=\"unused\" selected", html, fixed = TRUE))
  # A role that is set keeps its own variable selected, the placeholder not.
  set <- ctx$eval("roleOptions(ANALYSIS_REGISTRY.mediation.roles[0], ['exposure'])")
  expect_match(set, "^<option value=\"\">Choose a variable</option>")
  expect_match(set, "value=\"exposure\" selected", fixed = TRUE)
})
