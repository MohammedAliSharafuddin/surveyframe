/* inst/builder/citation_picker.js
 *
 * SurveyframeCitationPicker: 1 citation picker for SurveyBuilder and
 * SurveyStudio, with no server, no editor library and no new package.
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
  var after=el.nextSibling;
  if(options.button!==false){
    btn=document.createElement('button');btn.type='button';btn.className='sfcp-btn';
    btn.textContent='Cite';
    btn.setAttribute('aria-label','Cite a reference'+(options.label?' in '+options.label:''));
    btn.setAttribute('aria-haspopup','dialog');
    btn.addEventListener('click',function(){var s=a.getSelection();open({start:s.start,end:s.end},btn);});
    el.parentNode.insertBefore(btn,after);
  }
  el.parentNode.insertBefore(msg,btn?btn.nextSibling:after);
  var described=(el.getAttribute('aria-describedby')||'').split(/\s+/).filter(function(x){return x;});
  if(described.indexOf(msg.id)<0){described.push(msg.id);el.setAttribute('aria-describedby',described.join(' '));}

  function check(){
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
  unknownKeys:unknownKeys,narrativeText:narrativeText,parentheticalText:parentheticalText,
  message:MSG_UNKNOWN
};
})(typeof window!=='undefined'?window:this);
