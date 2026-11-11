// tests/testthat/fixtures/canonical/canon_hash.js
// Hash JSON texts with the canonical form block of a shipped HTML page, taken
// from the page at run time between its sframe-canon markers, so the code
// tested is the code shipped. Used by test-canonical-form.R.
// Usage: node canon_hash.js <page.html> <hash|seal> <texts.json> <out.json>
//   hash: each text's canonical string and sha256, with hash.value emptied
//   seal: each text with hash.value set as SurveyBuilder saves it
//   legacy: each text's legacy hash, from the page's sframe-legacy block
//   verdict: the verifier page's own verify() on each text, run on a stub
//     page: its banner (ok, legacy or fail), or refused with the message
const fs = require('fs'), crypto = require('crypto');
const [page, mode, input, output] = process.argv.slice(2);
const html = fs.readFileSync(page, 'utf8');
const i = html.indexOf('// sframe-canon:begin'), j = html.indexOf('// sframe-canon:end');
const lib = new Function(html.slice(i, j) +
  '; return {sframeCanonStr: sframeCanonStr, sframeDuplicateKey: sframeDuplicateKey,' +
  ' sframeEscapeProblem: sframeEscapeProblem};')();
const li = html.indexOf('// sframe-legacy:begin'), lj = html.indexOf('// sframe-legacy:end');
const legacyStr = li < 0 ? null :
  new Function(html.slice(li, lj) + '; return sframeLegacyStr;')();
const sha = (s) => crypto.createHash('sha256').update(s, 'utf8').digest('hex');
const texts = JSON.parse(fs.readFileSync(input, 'utf8'));
if (mode === 'verdict') {
  verdicts().then(function (out) { fs.writeFileSync(output, JSON.stringify(out), 'utf8'); });
  return;
}
const out = texts.map(function (t) {
  const bad = lib.sframeEscapeProblem(t);
  if (bad !== null) return { refused: bad };
  const dup = lib.sframeDuplicateKey(t);
  if (dup !== null) return { dup: dup };
  try {
    const p = JSON.parse(t);
    if (p && typeof p === 'object' && p.hash && typeof p.hash === 'object') p.hash.value = '';
    if (mode === 'legacy') return { hash: sha(legacyStr(p)) };
    const canon = lib.sframeCanonStr(p);
    if (mode === 'seal') {
      p.hash.value = sha(canon);
      return { text: JSON.stringify(p, null, 2) };
    }
    return { canon: canon, hash: sha(canon) };
  } catch (e) {
    return { error: e.message };
  }
});
fs.writeFileSync(output, JSON.stringify(out), 'utf8');

// The page's last inline script, run with a stub document whose elements take
// any listener, so verify() is the function the page ships.
async function verdicts() {
  const k = html.lastIndexOf('<script>'), e = html.indexOf('</script>', k);
  const els = {};
  const document = { getElementById: function (id) {
    return els[id] || (els[id] = { id: id, style: {}, innerHTML: '', value: '',
      addEventListener: function () {}, classList: { add: function () {}, remove: function () {} } });
  } };
  const window = {};
  const verify = new Function('window', 'document', 'FileReader',
    html.slice(k + 8, e) + '; return verify;')(window, document, function () {});
  const out = [];
  for (const t of texts) {
    const el = document.getElementById('result');
    el.innerHTML = '';
    await verify(t);
    const m = /class="banner (\w+)"/.exec(el.innerHTML);
    out.push(m ? { verdict: m[1] } :
      { verdict: 'refused', message: el.innerHTML.replace(/<[^>]+>/g, '') });
  }
  return out;
}
