// tests/testthat/fixtures/canonical/canon_hash.js
// Hash JSON texts with the canonical form block of a shipped HTML page, taken
// from the page at run time between its sframe-canon markers, so the code
// tested is the code shipped. Used by test-canonical-form.R.
// Usage: node canon_hash.js <page.html> <hash|seal> <texts.json> <out.json>
//   hash: each text's canonical string and sha256, with hash.value emptied
//   seal: each text with hash.value set as SurveyBuilder saves it
//   legacy: each text's legacy hash, from the page's sframe-legacy block
const fs = require('fs'), crypto = require('crypto');
const [page, mode, input, output] = process.argv.slice(2);
const html = fs.readFileSync(page, 'utf8');
const i = html.indexOf('// sframe-canon:begin'), j = html.indexOf('// sframe-canon:end');
const lib = new Function(html.slice(i, j) +
  '; return {sframeCanonStr: sframeCanonStr, sframeDuplicateKey: sframeDuplicateKey};')();
const li = html.indexOf('// sframe-legacy:begin'), lj = html.indexOf('// sframe-legacy:end');
const legacyStr = li < 0 ? null :
  new Function(html.slice(li, lj) + '; return sframeLegacyStr;')();
const sha = (s) => crypto.createHash('sha256').update(s, 'utf8').digest('hex');
const texts = JSON.parse(fs.readFileSync(input, 'utf8'));
const out = texts.map(function (t) {
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
