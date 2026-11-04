/* inst/builder/field_tools.js
 *
 * The tools on SurveyBuilder's and SurveyStudio's long free-text fields: a
 * citation picker and a format toolbar, with no server, no editor library
 * and no new package. The field stores Markdown as typed, which the report
 * renders.
 *
 * The format toolbar appears when the field has focus and hides when focus
 * leaves both. Bold, italic, bulleted list, numbered list, link, cite,
 * subscript and superscript write **x**, *x*, "- ", "1. ", [x](url), the
 * picker's citation, ~x~ and ^x^ around the selection, and a preview line
 * under the field shows the result. Ctrl+B and Ctrl+I work in the field. The
 * toolbar is a labelled role=toolbar: arrow keys move along it, and Escape
 * returns to the field. Set options.toolbar to false for the picker alone,
 * which then adds a Cite button after the field instead.
 *
 *   var h = SurveyframeCitationPicker.attach(textarea, references, options);
 *   SurveyframeCitationPicker.updateReferences(references);
 *   h.destroy();
 *
 * `references` is the instrument's references as saved (CSL-JSON with
 * cited_by), or a function returning them, so no second store is kept.
 * Typing @ or /cite in the field, or pressing its Cite button, lists them
 * filtered as you type. Picking one asks for "Max (2000)" (@key) or
 * "(Max, 2000)" ([@key]). Inside an open [...] it adds "; @key". A key with
 * no reference is shown under the field with a message.
 *
 * Options: button (true, adds a Cite button after the field), label (the
 * field's name, for the button's accessible name), knownKeys (keys that
 * resolve without a record, such as built-in method references), onManage
 * (a function, shows a "Manage references" link), adapter (an object with
 * getText, getSelection, replaceRange and focus, for a field that is not a
 * plain input or textarea).
 *
 * The result list, the debounce and the cursor insertion are adapted from
 * QuartoPad (inst/www/js/citations.js and inst/www/js/editor.js at 5a5e300).
 * QuartoPad is MIT licensed:
 *   Copyright (c) 2026 Mohammed Ali Sharafuddin
 *   Permission is hereby granted, free of charge, to any person obtaining a
 *   copy of this software and associated documentation files (the
 *   "Software"), to deal in the Software without restriction, including
 *   without limitation the rights to use, copy, modify, merge, publish,
 *   distribute, sublicense, and/or sell copies of the Software, and to
 *   permit persons to whom the Software is furnished to do so, subject to
 *   the following conditions: The above copyright notice and this
 *   permission notice shall be included in all copies or substantial
 *   portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT
 *   WARRANTY OF ANY KIND.
 *
 * Keep this file ASCII. data-raw/inline_static_template.R copies it into
 * survey_builder.html, so run that script after any edit here.
 */
(function(root){
'use strict';

var KEY='[A-Za-z0-9_](?:[A-Za-z0-9_:.#$%&+?<>~/-]*[A-Za-z0-9_])?';
var DEBOUNCE_MS=320;
var MSG_UNKNOWN='No reference with this key. Add it under References.';

function esc(s){
  return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;')
    .replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
}

// -- Display ------------------------------------------------------------------
function asArr(x){return Array.isArray(x)?x:(x==null?[]:[x]);}
function families(r){
  return asArr(r&&r.author).map(function(a){return a?(a.family||a.literal||''):'';})
    .filter(function(s){return s;});
}
function yearOf(r){
  var i=r&&r.issued;
  var d=i&&i['date-parts']&&i['date-parts'][0]&&i['date-parts'][0][0];
  if(d!=null&&d!=='')return String(d);
  if(i&&i.literal)return String(i.literal);
  return 'n.d.';
}
// 1 or 2 authors are named, 3 or more become "et al.", as R's in-text
// citations do. A work with no author is named by its title.
function who(r,and){
  var f=families(r);
  if(!f.length)return (r&&(r.title||r.id))||'';
  if(f.length===1)return f[0];
  if(f.length===2)return f[0]+' '+and+' '+f[1];
  return f[0]+' et al.';
}
function normalise(r){
  return {key:r.id,title:r.title||'',authorText:who(r,'&'),year:yearOf(r)};
}
function narrativeText(r){return who(r,'and')+' ('+yearOf(r)+')';}
function parentheticalText(r){return '('+who(r,'&')+', '+yearOf(r)+')';}

// Every word typed must appear in the key, the authors, the year or the title.
function filter(refs,query){
  var words=String(query||'').toLowerCase().split(/\s+/).filter(function(w){return w;});
  return asArr(refs).filter(function(r){return r&&r.id;}).filter(function(r){
    var n=normalise(r);
    var hay=[n.key,families(r).join(' '),n.year,n.title].join(' ').toLowerCase();
    return words.every(function(w){return hay.indexOf(w)>=0;});
  }).map(normalise);
}

// -- Text ---------------------------------------------------------------------
// Code blocks and code spans, as [start, end) ranges. Nothing inside them is
// a citation, and the picker never opens or inserts there.
function codeRanges(text){
  var out=[],m,re=/```[\s\S]*?(```|$)|`[^`\n]*`/g;
  text=String(text||'');
  while((m=re.exec(text))){out.push([m.index,m.index+m[0].length]);if(!m[0].length)re.lastIndex++;}
  return out;
}
function inCode(text,pos){
  text=String(text||'');
  if(codeRanges(text).some(function(r){return pos>r[0]&&pos<r[1];}))return true;
  // A code span still being typed has no closing backtick yet.
  var line=text.slice(text.lastIndexOf('\n',pos-1)+1,pos);
  return (line.match(/`/g)||[]).length%2===1;
}
// Whether `pos` sits inside an open [...], and whether that bracket already
// holds a citation.
function bracketAt(text,pos){
  for(var i=pos-1;i>=0;i--){
    var c=text.charAt(i);
    if(c===']')return {open:false};
    if(c==='['){
      var inner=text.slice(i+1,pos);
      return {open:true,hasCite:new RegExp('(^|[^A-Za-z0-9_])-?@'+KEY).test(inner)};
    }
  }
  return {open:false};
}
// What typing at `pos` opens: an @ after a space, a bracket, a semicolon or
// the start, or /cite after a space or the start. Returns the range the
// citation replaces, or null.
function trigger(text,pos){
  text=String(text||'');
  if(inCode(text,pos))return null;
  if(text.charAt(pos-1)==='@'){
    var b=pos>=2?text.charAt(pos-2):'';
    if(b===''||/[\s\[;(]/.test(b))return {start:pos-1,end:pos};
  }
  if(pos>=5&&text.slice(pos-5,pos)==='/cite'){
    var c=pos>=6?text.charAt(pos-6):'';
    if(c===''||/\s/.test(c))return {start:pos-5,end:pos};
  }
  return null;
}
// The text after a citation of `key` replaces [start, end). `style` is
// "narrative" (@key) or "parenthetical" ([@key]), and is not asked for
// inside an open bracket.
function insertion(text,start,end,key,style){
  text=String(text||'');
  var before=text.slice(0,start),after=text.slice(end),ins;
  var br=bracketAt(text,start);
  if(br.open&&br.hasCite){
    var trimmed=before.replace(/\s+$/,'');
    if(/;$/.test(trimmed)){before=trimmed+' ';ins='@'+key;}
    else{before=trimmed;ins='; @'+key;}
  }else if(br.open){
    ins='@'+key;
  }else{
    ins=style==='parenthetical'?'[@'+key+']':'@'+key;
  }
  if(/[A-Za-z0-9_]$/.test(before)&&!br.open)before+=' ';
  var out=before+ins+after;
  return {text:out,cursor:(before+ins).length,inserted:ins};
}
function needsStyle(text,start){return !bracketAt(String(text||''),start).open;}
// The cited keys in `text` with no reference among `known`, in order, once
// each. Code is skipped, and an address such as a@b.org is no citation.
function unknownKeys(text,known){
  text=String(text||'');
  var ranges=codeRanges(text),seen={},out=[],m;
  var set={};asArr(known).forEach(function(k){set[k]=true;});
  var re=new RegExp('(^|[^A-Za-z0-9_])-?@('+KEY+')','g');
  while((m=re.exec(text))){
    var at=m.index+m[1].length;
    var code=ranges.some(function(r){return at>=r[0]&&at<r[1];});
    var k=m[2];
    if(!code&&!set[k]&&!seen[k]){seen[k]=true;out.push(k);}
  }
  return out;
}

// -- Markdown -----------------------------------------------------------------
// Each edit returns {text, start, end}: the new text and the selection after.
function trimSel(text,start,end){
  while(start<end&&/\s/.test(text.charAt(start)))start++;
  while(end>start&&/\s/.test(text.charAt(end-1)))end--;
  return [start,end];
}
var PLACEHOLDER={'**':'bold text','*':'italic text','~':'sub','^':'sup'};
// **x**, *x*, ~x~ or ^x^ around the selection, or around a placeholder that
// is left selected. Pressed again on marked text, the marks come off.
function wrap(text,start,end,mark){
  text=String(text||'');
  var t=trimSel(text,start,end);start=t[0];end=t[1];
  var m=mark.length,before=text.slice(0,start),after=text.slice(end);
  var on=start<end&&before.slice(-m)===mark&&after.slice(0,m)===mark;
  // The * of a ** is bold, so italic on bold text adds its own marks.
  if(on&&mark==='*'&&((before.slice(-2)==='**'&&before.slice(-3)!=='***')||(after.slice(0,2)==='**'&&after.slice(0,3)!=='***')))on=false;
  if(on)return {text:before.slice(0,-m)+text.slice(start,end)+after.slice(m),start:start-m,end:end-m};
  var inner=start<end?text.slice(start,end):PLACEHOLDER[mark];
  // Pandoc's ~sub~ and ^sup^ hold no bare space.
  if(mark==='~'||mark==='^')inner=inner.replace(/\\?[ \t]/g,'\\ ');
  return {text:before+mark+inner+mark+after,start:start+m,end:start+m+inner.length};
}
// "- " or "1. " before every line the selection touches, or off again when
// every one has it. Pandoc starts a list only after a blank line, so 1 is
// added after a paragraph.
function list(text,start,end,kind){
  text=String(text||'');
  var ls=text.lastIndexOf('\n',start-1)+1;
  var le=text.indexOf('\n',(end>start&&text.charAt(end-1)==='\n')?end-1:end);
  if(le<0)le=text.length;
  var lines=text.slice(ls,le).split('\n');
  var re=kind==='numbered'?/^\d+\.[ \t]/:/^[-*+][ \t]/;
  var filled=lines.filter(function(l){return l.trim();});
  var all=filled.length>0&&filled.every(function(l){return re.test(l);});
  var k=0,block;
  if(!filled.length){block=kind==='numbered'?'1. ':'- ';}
  else block=lines.map(function(l){
    if(all)return l.replace(re,'');
    if(!l.trim())return l;
    k++;return (kind==='numbered'?k+'. ':'- ')+l.replace(/^(\d+\.|[-*+])[ \t]/,'');
  }).join('\n');
  var before=text.slice(0,ls),after=text.slice(le);
  if(!all&&before&&!/\n[ \t]*\n$/.test(before))before+='\n';
  var at=before.length+block.length;
  return {text:before+block+after,start:at,end:at};
}
// [selection](https://), with the address selected to be typed over.
function link(text,start,end){
  text=String(text||'');
  var t=trimSel(text,start,end);start=t[0];end=t[1];
  var label=start<end?text.slice(start,end):'link text',url='https://';
  var s=start+label.length+3;
  return {text:text.slice(0,start)+'['+label+']('+url+')'+text.slice(end),start:s,end:s+url.length};
}
// $x$ around the selection, or $$ on lines of their own when it spans whole
// lines. Pandoc's inline $ takes no space just inside it.
function math(text,start,end){
  text=String(text||'');
  var whole=start<end&&(start===0||text.charAt(start-1)==='\n')&&(end===text.length||text.charAt(end)==='\n');
  if(whole){
    var body=text.slice(start,end).replace(/\n+$/,'');
    var ins='$$\n'+body+'\n$$';
    return {text:text.slice(0,start)+ins+text.slice(start+body.length),start:start+3,end:start+3+body.length};
  }
  var t=trimSel(text,start,end);start=t[0];end=t[1];
  var inner=start<end?text.slice(start,end):'x^2';
  return {text:text.slice(0,start)+'$'+inner+'$'+text.slice(end),start:start+1,end:start+1+inner.length};
}
// The field's Markdown as HTML, for the preview line: emphasis, sub and
// superscript, links, lists, paragraphs and citations, shown as the report
// shows them where the reference is known. Everything is escaped first.
function preview(text,refs){
  var known={};asArr(refs).forEach(function(r){if(r&&r.id)known[r.id]=r;});
  var seg=new RegExp('^(.*?)(-?)@('+KEY+')(.*)$');
  // Code and equations are shown as typed, in monospace, so nothing inside
  // them is formatted. The builder has no math library, so TeX stays TeX.
  function inline(s){
    var held=[];
    function hold(html){held.push(html);return '\u0001'+(held.length-1)+'\u0001';}
    s=String(s).replace(/`([^`]+)`/g,function(a,c){return hold('<code>'+esc(c)+'</code>');});
    s=s.replace(/\$\$([^$]+)\$\$/g,function(a,c){return hold('<code>'+esc(c.trim())+'</code>');});
    s=s.replace(/\$(?=\S)([^$]*?\S)\$(?!\d)/g,function(a,c){return hold('<code>'+esc(c)+'</code>');});
    s=esc(s);
    s=s.replace(/\[([^\[\]]*@[^\[\]]*)\]/g,function(all,inner){
      var hit=0,parts=inner.split(';').map(function(p){
        var m=p.trim().match(seg);var r=m&&known[m[3]];
        if(!r)return p.trim();
        hit++;
        var body=esc(m[2]==='-'?yearOf(r):who(r,'&')+', '+yearOf(r));
        return (m[1].trim()?m[1].trim()+' ':'')+body+m[4];
      });
      return hit?'('+parts.join('; ')+')':all;
    });
    s=s.replace(new RegExp('(^|[^A-Za-z0-9_;&])@('+KEY+')','g'),function(all,p,k){
      return known[k]?p+esc(narrativeText(known[k])):all;
    });
    s=s.replace(/\[([^\[\]]+)\]\(((?:https?:\/\/|mailto:)[^\s()]+)\)/g,'<a href="$2" target="_blank" rel="noopener">$1</a>');
    s=s.replace(/\*\*(?=\S)([^*]*?\S)\*\*/g,'<strong>$1</strong>');
    s=s.replace(/\*(?=\S)([^*]*?\S)\*/g,'<em>$1</em>');
    s=s.replace(/~((?:\\ |[^~\s])+)~/g,function(a,x){return '<sub>'+x.replace(/\\ /g,' ')+'</sub>';});
    s=s.replace(/\^((?:\\ |[^\^\s])+)\^/g,function(a,x){return '<sup>'+x.replace(/\\ /g,' ')+'</sup>';});
    return s.replace(/\u0001(\d+)\u0001/g,function(a,i){return held[+i];});
  }
  var out=[],para=[],items=[],kind=null,eq=null;
  function flushPara(){if(para.length)out.push('<p>'+para.map(inline).join(' ')+'</p>');para=[];}
  function flushList(){if(items.length)out.push('<'+kind+'>'+items.map(function(x){return '<li>'+inline(x)+'</li>';}).join('')+'</'+kind+'>');items=[];kind=null;}
  String(text||'').split('\n').forEach(function(l){
    // A display equation, $$ on lines of their own.
    if(eq){if(l.trim()==='$$'){out.push('<pre>'+esc(eq.join('\n'))+'</pre>');eq=null;}else eq.push(l);return;}
    if(l.trim()==='$$'){flushPara();flushList();eq=[];return;}
    var b=l.match(/^[ \t]*[-*+][ \t]+(.*)$/),n=l.match(/^[ \t]*\d+\.[ \t]+(.*)$/);
    if(b||n){var k2=b?'ul':'ol';flushPara();if(kind&&kind!==k2)flushList();kind=k2;items.push((b||n)[1]);return;}
    flushList();
    if(!l.trim()){flushPara();return;}
    para.push(l.trim());
  });
  flushPara();flushList();
  if(eq)out.push('<p>$$</p>'+(eq.length?'<pre>'+esc(eq.join('\n'))+'</pre>':''));
  return out.join('');
}
// Whether the text holds anything the preview would format.
function hasMarkdown(text){return /[*~^\[`$]|(^|\s)@[A-Za-z0-9_]|^[ \t]*([-+]|\d+\.)[ \t]/m.test(String(text||''));}

// -- Fields -------------------------------------------------------------------
// The default adapter, for an input or a textarea. After an insertion it
// sends input and change events, so a Shiny input sees the new value.
function fieldAdapter(el){
  return {
    element:el,
    getText:function(){return el.value||'';},
    getSelection:function(){
      var s=typeof el.selectionStart==='number'?el.selectionStart:(el.value||'').length;
      var e=typeof el.selectionEnd==='number'?el.selectionEnd:s;
      return {start:s,end:e};
    },
    replaceRange:function(start,end,str,cursor){
      var v=el.value||'';
      el.value=v.slice(0,start)+str+v.slice(end);
      if(el.setSelectionRange){try{el.setSelectionRange(cursor,cursor);}catch(e){}}
      ['input','change'].forEach(function(t){
        var ev;
        try{ev=new Event(t,{bubbles:true});}
        catch(e){ev=document.createEvent('Event');ev.initEvent(t,true,true);}
        el.dispatchEvent(ev);
      });
    },
    focus:function(){if(el.focus)el.focus();}
  };
}

var TOOLS=[
  {id:'bold',label:'Bold',keys:'Ctrl+B',html:'<b>B</b>'},
  {id:'italic',label:'Italic',keys:'Ctrl+I',html:'<i>I</i>'},
  {id:'bullets',label:'Bulleted list',html:'&#8226; List'},
  {id:'numbers',label:'Numbered list',html:'1. List'},
  {id:'link',label:'Link',html:'Link'},
  {id:'cite',label:'Cite a reference',html:'@ Cite'},
  {id:'sub',label:'Subscript',html:'x<sub>2</sub>'},
  {id:'sup',label:'Superscript',html:'x<sup>2</sup>'},
  {id:'math',label:'Equation',html:'<i>f</i>(x)'}
];

var STYLE='.sfcp{position:fixed;z-index:10000;width:360px;max-width:calc(100vw - 16px);background:#fff;color:#1f2937;border:1px solid #cbd5e1;border-radius:8px;box-shadow:0 8px 24px rgba(15,23,42,.18);padding:10px;font:13px/1.4 system-ui,-apple-system,"Segoe UI",sans-serif}'
  +'.sfcp[hidden]{display:none}'
  +'.sfcp-h{font-weight:600;margin:0 0 6px}'
  +'.sfcp-l{display:block;font-size:12px;color:#475569;margin:0 0 3px}'
  +'.sfcp-q{width:100%;box-sizing:border-box;padding:5px 8px;border:1px solid #cbd5e1;border-radius:6px;font:inherit}'
  +'.sfcp-list{list-style:none;margin:6px 0 0;padding:0;max-height:220px;overflow:auto}'
  +'.sfcp-o{padding:5px 7px;border-radius:5px;cursor:pointer}'
  +'.sfcp-o[aria-selected="true"],.sfcp-o:hover{background:#e0e7ff}'
  +'.sfcp-k{font-family:ui-monospace,Menlo,Consolas,monospace;font-size:12px;color:#3730a3}'
  +'.sfcp-a{margin-left:6px}.sfcp-t{display:block;font-size:12px;color:#475569}'
  +'.sfcp-empty{margin:8px 0 2px;color:#475569}'
  +'.sfcp-st p{margin:8px 0 6px}.sfcp-st button{margin:0 6px 0 0;padding:5px 10px;border:1px solid #94a3b8;border-radius:6px;background:#f8fafc;font:inherit;cursor:pointer}'
  +'.sfcp-st button:focus,.sfcp-st button:hover{background:#e0e7ff}'
  +'.sfcp-m{display:inline-block;margin-top:8px;font-size:12px;color:#1d4ed8}'
  +'.sfcp-btn{margin:4px 0 0;padding:2px 8px;border:1px solid #cbd5e1;border-radius:5px;background:#f8fafc;font:12px system-ui,sans-serif;cursor:pointer}'
  +'.sfcp-msg{font-size:12px;color:#b91c1c;margin:3px 0 0}.sfcp-msg:empty{display:none}'
  +'.sfcp-bar{display:flex;flex-wrap:wrap;gap:3px;margin:3px 0 0}.sfcp-bar[hidden]{display:none}'
  +'.sfcp-tb{min-width:28px;height:24px;padding:0 7px;border:1px solid #cbd5e1;border-radius:4px;background:#f8fafc;color:#1f2937;font:12px system-ui,sans-serif;cursor:pointer}'
  +'.sfcp-tb:hover,.sfcp-tb:focus{background:#e0e7ff;outline:2px solid #6366f1;outline-offset:0}'
  +'.sfcp-pv{font-size:12px;color:#334155;background:#f8fafc;border-left:3px solid #c7d2fe;padding:4px 8px;margin:3px 0 0}.sfcp-pv:empty{display:none}'
  +'.sfcp-pv p{margin:0 0 3px}.sfcp-pv ul,.sfcp-pv ol{margin:0 0 3px;padding-left:18px}.sfcp-pv code,.sfcp-pv pre{font-family:ui-monospace,Menlo,Consolas,monospace;font-size:11px}.sfcp-pv pre{margin:0 0 3px;white-space:pre-wrap}'
  +'.sfcp-pv-l{display:block;font-size:10px;text-transform:uppercase;letter-spacing:.04em;color:#64748b}'
  +'.sfcp-bad{text-decoration:underline wavy #dc2626;text-underline-offset:3px;font-family:ui-monospace,Menlo,Consolas,monospace}';
function addStyle(){
  if(document.getElementById('sfcp-style'))return;
  var s=document.createElement('style');s.id='sfcp-style';s.textContent=STYLE;
  (document.head||document.body).appendChild(s);
}

var handles=[],seq=0,shared=null;

function attach(el,references,options){
  if(!el)return null;
  options=options||{};
  var n=++seq,a=options.adapter||fieldAdapter(el);
  var h={element:el,refs:references,options:options,n:n};
  var range=null,activeIdx=0,shown=[],picked=null,timer=null,busy=false,btn=null;
  addStyle();

  function refs(){var r=typeof h.refs==='function'?h.refs():h.refs;return asArr(r);}
  function known(){
    var k=refs().map(function(r){return r&&r.id;});
    var extra=typeof options.knownKeys==='function'?options.knownKeys():options.knownKeys;
    return k.concat(asArr(extra));
  }

  // The message under the field, for keys with no reference.
  var msg=document.createElement('div');
  msg.className='sfcp-msg';msg.id='sfcp-msg-'+n;msg.setAttribute('aria-live','polite');
  var after=el.nextSibling,bar=null,pv=null,useBar=options.toolbar!==false;
  if(useBar){
    bar=document.createElement('div');bar.className='sfcp-bar';bar.hidden=true;
    bar.setAttribute('role','toolbar');
    bar.setAttribute('aria-label','Format '+(options.label||'text'));
    if(el.id)bar.setAttribute('aria-controls',el.id);
    bar.innerHTML=TOOLS.map(function(t,i){
      var name=t.label+(t.keys?' ('+t.keys+')':'');
      return '<button type="button" class="sfcp-tb" data-tool="'+t.id+'" tabindex="'+(i?'-1':'0')+'" aria-label="'+esc(name)+'" title="'+esc(name)+'"'
        +(t.id==='cite'?' aria-haspopup="dialog"':'')+'>'+t.html+'</button>';
    }).join('');
    el.parentNode.insertBefore(bar,after);
    // The field keeps focus and its selection while a button is pressed.
    bar.addEventListener('mousedown',function(e){if(e.target.closest&&e.target.closest('.sfcp-tb'))e.preventDefault();});
    bar.addEventListener('click',function(e){
      var b=e.target.closest?e.target.closest('.sfcp-tb'):null;
      if(b)tool(b.getAttribute('data-tool'),b);
    });
    bar.addEventListener('keydown',function(e){
      var bs=Array.prototype.slice.call(bar.querySelectorAll('.sfcp-tb'));
      var i=bs.indexOf(document.activeElement),j=-1;
      if(e.key==='ArrowRight')j=(i+1)%bs.length;
      else if(e.key==='ArrowLeft')j=(i-1+bs.length)%bs.length;
      else if(e.key==='Home')j=0;
      else if(e.key==='End')j=bs.length-1;
      else if(e.key==='Escape'){e.preventDefault();e.stopPropagation();a.focus();return;}
      if(j<0)return;
      e.preventDefault();
      bs.forEach(function(b,k){b.setAttribute('tabindex',k===j?'0':'-1');});
      bs[j].focus();
    });
    bar.addEventListener('focusout',hideLater);
    el.addEventListener('focus',showBar);
    el.addEventListener('blur',hideLater);
    el.addEventListener('keydown',onKey);
  }else if(options.button!==false){
    btn=document.createElement('button');btn.type='button';btn.className='sfcp-btn';
    btn.textContent='Cite';
    btn.setAttribute('aria-label','Cite a reference'+(options.label?' in '+options.label:''));
    btn.setAttribute('aria-haspopup','dialog');
    btn.addEventListener('click',function(){var s=a.getSelection();open({start:s.start,end:s.end},btn);});
    el.parentNode.insertBefore(btn,after);
  }
  var anchor=bar||btn;
  el.parentNode.insertBefore(msg,anchor?anchor.nextSibling:after);
  if(useBar){
    pv=document.createElement('div');pv.className='sfcp-pv';pv.id='sfcp-pv-'+n;
    el.parentNode.insertBefore(pv,msg.nextSibling);
  }
  var described=(el.getAttribute('aria-describedby')||'').split(/\s+/).filter(function(x){return x;});
  if(described.indexOf(msg.id)<0){described.push(msg.id);el.setAttribute('aria-describedby',described.join(' '));}

  function showBar(){if(bar)bar.hidden=false;}
  function inside(x){return !!x&&(x===el||(bar&&bar.contains(x))||(shared&&shared.el.contains(x)));}
  // Hidden once focus has left the field, its toolbar and its picker.
  function hideLater(){
    if(!bar)return;
    setTimeout(function(){
      if(shared&&shared.owner===h)return;
      if(!inside(document.activeElement))bar.hidden=true;
    },0);
  }
  h._afterClose=hideLater;
  function apply(res){
    busy=true;
    a.replaceRange(0,a.getText().length,res.text,res.end);
    busy=false;
    if(el.setSelectionRange){try{el.setSelectionRange(res.start,res.end);}catch(e){}}
    a.focus();check();showPreview();
  }
  function tool(id,from){
    var s=a.getSelection(),t=a.getText();
    if(id==='bold')apply(wrap(t,s.start,s.end,'**'));
    else if(id==='italic')apply(wrap(t,s.start,s.end,'*'));
    else if(id==='sub')apply(wrap(t,s.start,s.end,'~'));
    else if(id==='sup')apply(wrap(t,s.start,s.end,'^'));
    else if(id==='bullets')apply(list(t,s.start,s.end,'bulleted'));
    else if(id==='numbers')apply(list(t,s.start,s.end,'numbered'));
    else if(id==='link')apply(link(t,s.start,s.end));
    else if(id==='math')apply(math(t,s.start,s.end));
    // A citation goes after the selection, which it leaves in place.
    else if(id==='cite')open({start:s.end,end:s.end},el);
  }
  function onKey(e){
    if(!(e.ctrlKey||e.metaKey)||e.altKey||e.shiftKey)return;
    var k=String(e.key||'').toLowerCase();
    if(k==='b'||k==='i'){e.preventDefault();e.stopPropagation();tool(k==='b'?'bold':'italic');}
  }
  function showPreview(){
    if(!pv)return;
    var t=a.getText();
    pv.innerHTML=hasMarkdown(t)?'<span class="sfcp-pv-l">Preview</span>'+preview(t,refs()):'';
  }

  function check(){
    showPreview();
    var bad=unknownKeys(a.getText(),known());
    if(!bad.length){msg.innerHTML='';el.removeAttribute('aria-invalid');return bad;}
    msg.innerHTML=bad.map(function(k){return '<span class="sfcp-bad">@'+esc(k)+'</span> '+esc(MSG_UNKNOWN);}).join('<br>');
    el.setAttribute('aria-invalid','true');
    return bad;
  }
  function later(){clearTimeout(timer);timer=setTimeout(check,DEBOUNCE_MS);}

  // -- The popover, 1 per page, shared by every field --------------------------
  function pop(){
    if(shared)return shared;
    var p=document.createElement('div');
    p.className='sfcp';p.hidden=true;p.setAttribute('role','dialog');
    p.setAttribute('aria-labelledby','sfcp-t');
    p.innerHTML='<div class="sfcp-h" id="sfcp-t">Cite a reference</div>'
      +'<div class="sfcp-pick"><label class="sfcp-l" for="sfcp-q">Search by key, author, year or title</label>'
      +'<input type="search" class="sfcp-q" id="sfcp-q" autocomplete="off" role="combobox" aria-autocomplete="list" aria-expanded="true" aria-controls="sfcp-list">'
      +'<ul class="sfcp-list" id="sfcp-list" role="listbox" aria-label="References"></ul>'
      +'<p class="sfcp-empty" id="sfcp-empty" hidden></p></div>'
      +'<div class="sfcp-st" id="sfcp-st" hidden><p id="sfcp-st-q">How should the citation read?</p>'
      +'<div role="group" aria-labelledby="sfcp-st-q"><button type="button" id="sfcp-narr" data-style="narrative"></button>'
      +'<button type="button" id="sfcp-paren" data-style="parenthetical"></button></div></div>'
      +'<a href="#" class="sfcp-m" id="sfcp-m" hidden>Manage references</a>';
    document.body.appendChild(p);
    shared={el:p,owner:null,returnTo:null};
    p.querySelector('#sfcp-q').addEventListener('input',function(){if(shared.owner)shared.owner._list();});
    p.addEventListener('keydown',function(e){if(shared.owner)shared.owner._key(e);});
    p.querySelector('#sfcp-list').addEventListener('mousedown',function(e){e.preventDefault();});
    p.querySelector('#sfcp-list').addEventListener('click',function(e){
      var li=e.target.closest?e.target.closest('.sfcp-o'):null;
      if(li&&shared.owner)shared.owner._pick(+li.getAttribute('data-i'));
    });
    p.querySelector('#sfcp-narr').addEventListener('click',function(){if(shared.owner)shared.owner._insert('narrative');});
    p.querySelector('#sfcp-paren').addEventListener('click',function(){if(shared.owner)shared.owner._insert('parenthetical');});
    p.querySelector('#sfcp-m').addEventListener('click',function(e){
      e.preventDefault();var o=shared.owner;if(!o)return;
      o._close(false);if(typeof o.options.onManage==='function')o.options.onManage();
    });
    document.addEventListener('mousedown',function(e){
      if(shared.owner&&!p.contains(e.target))shared.owner._close(false);
    },true);
    return shared;
  }
  function q(id){return pop().el.querySelector('#'+id);}

  function open(r,from){
    var P=pop();
    if(P.owner&&P.owner!==h)P.owner._close(false);
    if(inCode(a.getText(),r.start))return;
    range=r;picked=null;activeIdx=0;P.owner=h;P.returnTo=from||el;
    q('sfcp-st').hidden=true;q('sfcp-pick').hidden=false;
    q('sfcp-m').hidden=typeof options.onManage!=='function';
    q('sfcp-q').value='';
    var rect=el.getBoundingClientRect?el.getBoundingClientRect():{left:8,bottom:8};
    var vw=window.innerWidth||document.documentElement.clientWidth||800;
    var vh=window.innerHeight||document.documentElement.clientHeight||600;
    var left=Math.max(8,Math.min(rect.left,vw-368)),top=rect.bottom+4;
    if(top>vh-200)top=Math.max(8,(rect.top||top)-300);
    P.el.style.left=left+'px';P.el.style.top=top+'px';
    P.el.hidden=false;
    h._list();
    q('sfcp-q').focus();
  }
  h._list=function(){
    shown=filter(refs(),q('sfcp-q').value);
    if(activeIdx>=shown.length)activeIdx=0;
    var list=q('sfcp-list'),empty=q('sfcp-empty');
    list.innerHTML=shown.map(function(x,i){
      return '<li class="sfcp-o" role="option" id="sfcp-o-'+i+'" data-i="'+i+'" aria-selected="'+(i===activeIdx?'true':'false')+'">'
        +'<span class="sfcp-k">@'+esc(x.key)+'</span><span class="sfcp-a">'+esc(x.authorText)+' ('+esc(x.year)+')</span>'
        +'<span class="sfcp-t">'+esc(x.title)+'</span></li>';
    }).join('');
    var none=!refs().length;
    empty.hidden=shown.length>0;
    empty.textContent=none?'No references yet. Add them under References.':'No reference matches.';
    var input=q('sfcp-q');
    if(shown.length)input.setAttribute('aria-activedescendant','sfcp-o-'+activeIdx);
    else input.removeAttribute('aria-activedescendant');
  };
  function move(d){
    if(!shown.length)return;
    activeIdx=(activeIdx+d+shown.length)%shown.length;h._list();
    var li=q('sfcp-o-'+activeIdx);if(li&&li.scrollIntoView)li.scrollIntoView({block:'nearest'});
  }
  h._pick=function(i){
    var x=shown[i];if(!x)return;
    picked=refs().filter(function(r){return r.id===x.key;})[0];if(!picked)return;
    if(!needsStyle(a.getText(),range.start)){h._insert('narrative');return;}
    q('sfcp-narr').textContent=narrativeText(picked);
    q('sfcp-paren').textContent=parentheticalText(picked);
    q('sfcp-narr').setAttribute('aria-label','Narrative, '+narrativeText(picked)+', inserts @'+picked.id);
    q('sfcp-paren').setAttribute('aria-label','In brackets, '+parentheticalText(picked)+', inserts [@'+picked.id+']');
    q('sfcp-pick').hidden=true;q('sfcp-st').hidden=false;q('sfcp-narr').focus();
  };
  h._insert=function(style){
    if(!picked||!range)return;
    var res=insertion(a.getText(),range.start,range.end,picked.id,style);
    var cur=a.getText(),start=0,end=cur.length;
    h._close(true);
    busy=true;
    a.replaceRange(start,end,res.text,res.cursor);
    busy=false;
    check();
  };
  h._close=function(focusField){
    var P=shared;if(!P||P.owner!==h)return;
    P.el.hidden=true;P.owner=null;
    var back=focusField?el:P.returnTo;P.returnTo=null;
    if(back&&back.focus)back.focus();
    if(h._afterClose)h._afterClose();
  };
  h._key=function(e){
    var k=e.key;
    if(k==='Escape'){e.preventDefault();e.stopPropagation();h._close(false);return;}
    if(!q('sfcp-pick').hidden){
      if(k==='ArrowDown'){e.preventDefault();move(1);return;}
      if(k==='ArrowUp'){e.preventDefault();move(-1);return;}
      if(k==='Enter'){e.preventDefault();h._pick(activeIdx);return;}
    }
    if(k==='Tab'){
      var f=Array.prototype.filter.call(shared.el.querySelectorAll('input,button,a[href]'),function(x){
        for(var p=x;p&&p!==shared.el;p=p.parentNode)if(p.hidden)return false;return true;});
      if(!f.length)return;
      var i=f.indexOf(document.activeElement);
      if(e.shiftKey&&i<=0){e.preventDefault();f[f.length-1].focus();}
      else if(!e.shiftKey&&i===f.length-1){e.preventDefault();f[0].focus();}
    }
  };

  function onInput(){
    if(busy)return;
    later();
    var s=a.getSelection();
    if(s.start!==s.end)return;
    var t=trigger(a.getText(),s.start);
    if(t)open(t,el);
  }
  el.addEventListener('input',onInput);
  el.addEventListener('focus',check);
  h.check=check;
  h.open=function(){var s=a.getSelection();open({start:s.start,end:s.end},el);};
  h.updateReferences=function(r){h.refs=r;check();if(shared&&shared.owner===h)h._list();};
  h.destroy=function(){
    if(shared&&shared.owner===h)h._close(false);
    el.removeEventListener('input',onInput);el.removeEventListener('focus',check);
    clearTimeout(timer);
    if(btn&&btn.parentNode)btn.parentNode.removeChild(btn);
    if(bar){el.removeEventListener('focus',showBar);el.removeEventListener('blur',hideLater);el.removeEventListener('keydown',onKey);if(bar.parentNode)bar.parentNode.removeChild(bar);}
    if(pv&&pv.parentNode)pv.parentNode.removeChild(pv);
    if(msg.parentNode)msg.parentNode.removeChild(msg);
    el.removeAttribute('aria-invalid');
    var d=(el.getAttribute('aria-describedby')||'').split(/\s+/).filter(function(x){return x&&x!==msg.id;});
    if(d.length)el.setAttribute('aria-describedby',d.join(' '));else el.removeAttribute('aria-describedby');
    handles=handles.filter(function(x){return x!==h;});
  };
  handles.push(h);
  check();
  return h;
}

root.SurveyframeCitationPicker={
  attach:attach,
  updateReferences:function(r){handles.slice().forEach(function(h){h.updateReferences(r);});},
  checkAll:function(){handles.forEach(function(h){h.check();});},
  destroy:function(){handles.slice().forEach(function(h){h.destroy();});},
  // Pure helpers, for tests and for hosts that need them.
  normalise:normalise,filter:filter,trigger:trigger,insertion:insertion,
  unknownKeys:unknownKeys,wrap:wrap,list:list,link:link,math:math,preview:preview,hasMarkdown:hasMarkdown,
  narrativeText:narrativeText,parentheticalText:parentheticalText,
  message:MSG_UNKNOWN
};
})(typeof window!=='undefined'?window:this);
