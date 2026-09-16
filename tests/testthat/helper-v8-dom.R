# tests/testthat/helper-v8-dom.R
#
# Runs the exported static survey's own JavaScript under V8, against a stub
# DOM, so a test can drive what a participant does and read what would be
# stored.
#
# Before this, the template was tested by matching its source text, which
# passes with the behaviour wrong. The survey is exported through
# export_static_survey() first, so the script under test is the one a
# researcher deploys, with every placeholder filled.

# Just enough of document and window for the template to load and for its
# renderers, handlers, validation and submission to run. Elements are created
# on first lookup and kept, so a test can read an error message back.
static_dom_stub <- "
var __els = {};
function __mkClassList(){
  return { _s:{},
    add:function(c){ this._s[c]=1; },
    remove:function(c){ delete this._s[c]; },
    toggle:function(c,on){ if(on===undefined) on=!this._s[c]; if(on) this._s[c]=1; else delete this._s[c]; },
    contains:function(c){ return !!this._s[c]; } };
}
function __mkEl(id){
  return { id:id, value:'', textContent:'', innerHTML:'', hidden:false, checked:false,
    dataset:{}, style:{ setProperty:function(){} }, classList:__mkClassList(),
    querySelectorAll:function(){ return []; }, querySelector:function(){ return null; },
    scrollIntoView:function(){}, focus:function(){}, addEventListener:function(){} };
}
var document = {
  getElementById:function(id){
    if (id === 'sf-data') return { textContent: __sfData };
    if (!__els[id]) __els[id] = __mkEl(id);
    return __els[id];
  },
  body:{ dataset:{ endpoint: __endpoint }, classList:__mkClassList() },
  documentElement:{ style:{ setProperty:function(){} } },
  addEventListener:function(){},
  querySelector:function(){ return null; },
  querySelectorAll:function(){ return []; },
  createElement:function(){ return { click:function(){} }; }
};
var window = { scrollTo:function(){}, location:{ reload:function(){}, href:'' } };
var __posts = [];
function fetch(url, opts){
  __posts.push({ url:url, body:opts.body });
  return { catch:function(){ return this; } };
}
function setTimeout(){}
"

# Exports `instrument`, loads the survey's script into a fresh V8 context and
# returns the context. The survey is left on its first screen, unrendered.
static_survey_context <- function(instrument, endpoint_url = "") {
  skip_if_not_installed("V8")
  path <- tempfile(fileext = ".html")
  suppressMessages(export_static_survey(instrument, output_path = path,
                                        open = FALSE,
                                        endpoint_url = endpoint_url))
  html <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"),
                collapse = "\n")
  unlink(path)

  data_open <- '<script type="application/json" id="sf-data">'
  after_data <- strsplit(html, data_open, fixed = TRUE)[[1]][2]
  sf_data <- sub("</script>.*$", "", after_data)
  script <- sub("^.*?<script>", "", after_data)
  script <- sub("</script>\\s*</body>.*$", "", script)

  ctx <- V8::v8()
  ctx$assign("__sfData", sf_data)
  ctx$assign("__endpoint", endpoint_url)
  ctx$eval(static_dom_stub)
  ctx$eval(script)
  ctx
}

# Rendered HTML for one item, as the template's own renderer produces it.
static_render_item <- function(ctx, item_id) {
  ctx$eval(sprintf(
    "renderItem(SF.items.filter(function(i){ return i.id === %s; })[0])",
    jsonlite::toJSON(item_id, auto_unbox = TRUE)))
}

# Runs an inline event handler taken from rendered HTML, with `this` bound to
# a stand-in input carrying the given properties. Returns the input
# afterwards, so a test can see whether the handler rewrote what was typed.
static_fire_handler <- function(ctx, html, event, input = list()) {
  pattern <- sprintf('%s="([^"]*)"', event)
  handler <- regmatches(html, regexec(pattern, html))[[1]][2]
  if (is.na(handler)) stop("no ", event, " handler in rendered HTML")
  ctx$assign("__inp", input)
  ctx$eval(sprintf("(function(){ %s }).call(__inp);", handler))
  ctx$get("__inp")
}

static_responses <- function(ctx) ctx$get("responses")

# validatePage() over the named items. Returns TRUE when the page may advance.
static_validate <- function(ctx, item_ids) {
  ctx$eval(sprintf(
    "String(validatePage(SF.items.filter(function(i){ return %s.indexOf(i.id) >= 0; })))",
    jsonlite::toJSON(item_ids))) == "true"
}

static_error_text <- function(ctx, item_id) {
  ctx$eval(sprintf("document.getElementById('err_' + %s).textContent",
                   jsonlite::toJSON(item_id, auto_unbox = TRUE)))
}

# Submits and returns the row the survey would send, as a named list.
static_submit_row <- function(ctx) {
  ctx$eval("doSubmit();")
  csv <- ctx$get("window._lastCsv.csv")
  utils::read.csv(text = csv, colClasses = "character", check.names = FALSE,
                  na.strings = character())
}
