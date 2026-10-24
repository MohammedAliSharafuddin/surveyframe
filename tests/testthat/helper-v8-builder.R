# tests/testthat/helper-v8-builder.R
#
# Runs SurveyBuilder's own script under V8, on the stub DOM from
# helper-v8-dom.R, so a test can open a .sframe file in the builder, act on
# it and read back the file the builder would save.
#
# The builder was tested by matching its source text, which passes with the
# behaviour wrong. A file saved here goes back through read_sframe(), so the
# hash, the validator and the amendment log all judge what the builder wrote.

# The builder's own script, the last <script> block in the page. The earlier
# blocks are the inlined static survey and collector templates.
builder_script <- function() {
  src <- sframe_installed_text("inst", "builder", "survey_builder.html")
  blocks <- regmatches(src, gregexpr("(?s)<script>.*?</script>", src,
                                     perl = TRUE))[[1]]
  body <- sub("(?s)^<script>", "", blocks[[length(blocks)]], perl = TRUE)
  sub("(?s)</script>$", "", body, perl = TRUE)
}

# What the builder reaches for beyond the survey template's needs. Storage is
# kept in memory, and crypto is absent, so hashing takes the builder's pure
# JavaScript route.
builder_extra_stub <- "
window.addEventListener = function(){};
var localStorage = { _d:{},
  getItem:function(k){ return this._d.hasOwnProperty(k) ? this._d[k] : null; },
  setItem:function(k,v){ this._d[k] = String(v); },
  removeItem:function(k){ delete this._d[k]; } };
var navigator = { userAgent:'v8', platform:'' };
function setInterval(){}
var __toasts = [];
// Element methods the builder calls that the survey template never does.
var __mkElBase = __mkEl;
__mkEl = function(id){
  var el = __mkElBase(id);
  el.removeAttribute = function(k){ delete this.attrs[k]; };
  el.hasAttribute = function(k){ return this.attrs[k] !== undefined; };
  el.appendChild = function(c){ return c; };
  el.contains = function(){ return false; };
  el.closest = function(){ return null; };
  el.blur = function(){};
  el.select = function(){};
  el.options = [];
  return el;
};
"

# A fresh builder, empty, as a researcher first sees it.
builder_context <- function() {
  skip_if_not_installed("V8")
  ctx <- V8::v8()
  ctx$assign("__sfData", "{}")
  ctx$assign("__endpoint", "")
  ctx$eval(static_dom_stub)
  ctx$eval(builder_extra_stub)
  ctx$eval(builder_script())
  # Toasts are recorded, so a test can read what the builder told the user.
  ctx$eval("toast = function(m, k){ __toasts.push({ msg:String(m), kind:k||'' }); };")
  ctx
}

# Opens `instrument` in the builder, through the file write_sframe() writes.
# `new_instrument` passes through, for a test that edits a demo directly.
builder_open <- function(ctx, instrument, new_instrument = FALSE) {
  path <- tempfile(fileext = ".sframe")
  on.exit(unlink(path))
  write_sframe(instrument, path, new_instrument = new_instrument)
  ctx$call("openSframeText", paste(readLines(path, warn = FALSE), collapse = "\n"))
  invisible(ctx)
}

# The file the builder's Save .sframe button would write, as a path.
builder_save <- function(ctx) {
  json <- ctx$eval("(function(){ var p = sframePayload();
    p.hash.value = window.sha256pure(JSON.stringify(sframeCanon(p)));
    return JSON.stringify(p, null, 2); })()")
  path <- tempfile(fileext = ".sframe")
  writeLines(json, path)
  path
}

builder_toasts <- function(ctx) ctx$get("__toasts")
