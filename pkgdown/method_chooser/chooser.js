// pkgdown/method_chooser/chooser.js
// The method chooser charts: from the research question to the plan's method
// ID. pkgdown/build_method_chooser.R opens chooser.html in headless Chrome,
// calls chooserSvg() for each chart and writes static SVG files, for the
// README (.github/readme/) and the Docs page (pkgdown/assets/docs/methods/).
// Every colour and font is written into the SVG as an attribute, since an
// SVG shown through <img> on GitHub cannot read the page's CSS or load web
// fonts. The card is white with GitHub's text colour, so it reads in GitHub's
// light and dark themes alike.
//
// A node: {t: label, k: kind, id: method ID, c: children, el: label on the
// arrow into it, skip: extra rows before its children, key: name for a cross
// link}. Kinds: root, kind (the kind of answer), design, ask (a question,
// drawn as a diamond), run (a plan method).

(function () {
  const N = (t, k, o = {}) => Object.assign({ t, k, c: [] }, o);
  const run = (t, id, o = {}) => N(t, "run", Object.assign({ id }, o));
  const kids = (n, ...c) => { n.c = c; return n; };
  const NORMAL = "Roughly normal, no extreme outliers?";

  const CHARTS = {
    difference: {
      title: "Difference between groups or occasions",
      desc: "Choose the scale, ordinal or categories branch by the kind of answer, then same people or different people, then the test. A third group or occasion leads to the test below each two-group test.",
      root: () => kids(N("Difference", "root"),
        kids(N("Scale score", "kind"),
          kids(N(NORMAL, "ask", { key: "a" }),
            kids(N("Same people", "design", { el: "Yes" }),
              kids(run("Paired t test", "t_test_pair"), run("Repeated-measures ANOVA", "repeated_anova", { el: "3+ occasions" }))),
            kids(N("Different people", "design", { el: "Yes" }),
              kids(run("Independent t test", "t_test_ind"),
                kids(run("One-way ANOVA", "anova_one", { el: "3+ groups" }),
                  run("Two-way ANOVA", "anova_two", { el: "2nd factor" }),
                  run("ANCOVA", "ancova", { el: "covariate" })))))),
        kids(N("Ordinal", "kind", { skip: 1, key: "ord" }),
          kids(N("Same people", "design"), kids(run("Wilcoxon signed-rank", "wilcoxon_pair"), run("Friedman", "friedman", { el: "3+ occasions" }))),
          kids(N("Different people", "design"), kids(run("Mann-Whitney U", "mann_whitney"), run("Kruskal-Wallis", "kruskal_wallis", { el: "3+ groups" })))),
        kids(N("Categories", "kind", { skip: 1 }),
          kids(N("Same people", "design"), kids(run("McNemar", "mcnemar"), run("Cochran's Q", "cochran_q", { el: "3+ occasions" }))),
          kids(N("Different people", "design"), kids(run("Chi-squared", "chi_square"), run("Fisher's exact", "fisher_exact", { el: "expected < 5" }))))),
      links: [["a", "ord", "No"]]
    },
    relationship: {
      title: "Relationship between variables",
      desc: "Scale scores that are linear and roughly normal go to Pearson correlation, otherwise to Spearman. Two categorical variables go to the chi-squared test.",
      root: () => kids(N("Relationship", "root"),
        kids(N("Scale scores", "kind"),
          kids(N("Linear, roughly normal, no extreme outliers?", "ask", { key: "a" }),
            kids(run("Pearson correlation", "correlation_pearson", { el: "Yes" }),
              run("Partial correlation", "partial_correlation", { el: "3rd variable held" })))),
        kids(N("Ordinal", "kind", { skip: 1, key: "ord" }),
          kids(run("Spearman correlation", "correlation_spearman"), run("Kendall's tau", "correlation_kendall", { el: "small n or ties" }))),
        kids(N("Categories", "kind", { skip: 1 }),
          kids(run("Chi-squared", "chi_square"), run("Fisher's exact", "fisher_exact", { el: "expected < 5" })))),
      links: [["a", "ord", "No"]]
    },
    prediction: {
      title: "Predict an outcome",
      desc: "The type of the outcome picks the regression model. A third variable that changes an effect is moderation, one that carries it is mediation.",
      root: () => kids(N("Prediction", "root"),
        kids(N("Scale outcome", "kind", { skip: 1 }), run("Linear regression", "regression_linear")),
        kids(N("Yes or no outcome", "kind"),
          kids(N("Separation or small sample?", "ask"),
            run("Binary logistic", "regression_logistic_binary", { el: "No" }),
            run("Firth logistic", "firth_logistic", { el: "Yes" }))),
        kids(N("Ordered categories", "kind", { skip: 1 }), run("Ordinal logistic", "regression_logistic_ordinal")),
        kids(N("3+ unordered choices", "kind", { skip: 1 }), run("Multinomial logistic", "regression_logistic_multinomial")),
        kids(N("A 3rd variable", "kind"),
          kids(N("Changes the effect", "design"), run("Moderation", "moderation")),
          kids(N("Carries the effect", "design"), run("Mediation", "mediation")))),
      links: []
    },
    measurement: {
      title: "Measure a construct",
      desc: "Reliability with alpha or omega. An unknown structure goes to the readiness check, then the exploratory factor analysis. A specified structure goes to CFA, CB-SEM or PLS-SEM syntax.",
      root: () => kids(N("Measurement", "root"),
        kids(N("Reliability", "kind", { skip: 1 }), run("Cronbach's alpha", "reliability_alpha"), run("McDonald's omega", "reliability_omega")),
        kids(N("Structure unknown", "kind", { skip: 1 }),
          kids(run("KMO and Bartlett", "efa_readiness"), run("Exploratory factor analysis", "efa_solution", { el: "then" }))),
        kids(N("Structure specified", "kind"),
          kids(N("Paths between constructs?", "ask"),
            run("CFA syntax", "cfa_lavaan_syntax", { el: "No" }),
            run("CB-SEM syntax", "sem_lavaan_syntax", { el: "Yes" }),
            run("PLS-SEM syntax", "pls_sem", { el: "Yes, to predict" })))),
      links: []
    }
  };

  // Literal colours: a white card with GitHub's text colour, the
  // surveyframe teal for methods and a red for the arrows.
  const C = {
    bg: "#ffffff", border: "#d0d7de", text: "#1f2328", muted: "#59636e",
    root: "#1f2328", onRoot: "#ffffff", kind: "#eaf4f4", accent: "#0a6f6d",
    onAccent: "#ffffff", design: "#ffffff", designLine: "#8c959f", edge: "#b3261e"
  };
  const SANS = "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans', Helvetica, Arial, sans-serif";
  const MONO = "ui-monospace, SFMono-Regular, 'SF Mono', Menlo, Consolas, 'Liberation Mono', monospace";

  // Fits GitHub's README column (about 880 px) and the site's content column.
  const GEOM = {
    compact: { BW: 108, COL: 118, PAD: 14, GAP: 46, size: { root: 14, kind: 13, design: 12.5, ask: 11.5, run: 12, id: 10.5, el: 11 } }
  };
  // A viewer's font can be wider than the one this runs with (Segoe UI is
  // wider than the Arial metrics Chrome uses on Linux), so text wraps at 88%
  // of the room it has.
  const SLACK = 0.88;

  const NS = "http://www.w3.org/2000/svg";
  const S = (t, a = {}, txt) => { const e = document.createElementNS(NS, t); for (const [k, v] of Object.entries(a)) e.setAttribute(k, v); if (txt != null) e.textContent = txt; return e; };
  const ctx = document.createElement("canvas").getContext("2d");
  const fontOf = (n, g) => {
    const w = { root: 600, kind: 600, design: 400, ask: 400, run: 600 }[n.k];
    return `${n.k === "ask" ? "italic " : ""}${w} ${g.size[n.k]}px Arial, sans-serif`;
  };
  function wrap(text, font, max) {
    ctx.font = font; const out = []; let cur = "";
    // A hyphenated word too wide for the line breaks after its hyphen.
    const words = [];
    for (const w of text.split(" ")) {
      if (w.includes("-") && ctx.measureText(w).width > max) w.split(/(?<=-)/).forEach(x => words.push(x));
      else words.push(w);
    }
    for (const w of words) { const t = cur ? cur + (cur.endsWith("-") ? "" : " ") + w : w; if (ctx.measureText(t).width > max && cur) { out.push(cur); cur = w; } else cur = t; }
    if (cur) out.push(cur);
    // 2 lines: move the break to the word boundary that evens them out, so
    // "Independent t test" reads "Independent / t test".
    if (out.length === 2) {
      const all = out.join(" ").split(" ");
      let best = out, bw = Math.max(...out.map(l => ctx.measureText(l).width));
      for (let i = 1; i < all.length; i++) {
        const a = all.slice(0, i).join(" "), b = all.slice(i).join(" ");
        const w = Math.max(ctx.measureText(a).width, ctx.measureText(b).width);
        if (w <= max && w < bw) { bw = w; best = [a, b]; }
      }
      return best;
    }
    return out;
  }
  function idLines(id, g) {
    ctx.font = `${g.size.id}px 'Liberation Mono', monospace`;
    // Liberation Mono, used here, is wider than SF Mono or Consolas, so no slack.
    const room = g.BW - 10, fit = t => ctx.measureText(t).width <= room;
    if (fit(id)) return [id];
    // Break after underscores, filling each line as far as it fits.
    const parts = id.split("_").map((p, i, a) => i < a.length - 1 ? p + "_" : p);
    const out = []; let cur = "";
    for (const p of parts) { if (cur && !fit(cur + p)) { out.push(cur); cur = p; } else cur += p; }
    out.push(cur);
    // 2 lines: even them out where an earlier break also fits.
    if (out.length === 2) {
      let best = out, bw = Math.max(...out.map(l => ctx.measureText(l).width));
      for (let i = 1; i < parts.length; i++) {
        const a = parts.slice(0, i).join(""), b = parts.slice(i).join("");
        const w = Math.max(ctx.measureText(a).width, ctx.measureText(b).width);
        if (w <= room && w < bw) { bw = w; best = [a, b]; }
      }
      return best;
    }
    return out;
  }
  const walk = (n, f) => { f(n); n.c.forEach(ch => walk(ch, f)); };

  function prepare(n, g) {
    const lh = g.size[n.k] + 3.5, ih = g.size.id + 3.5;
    if (n.k === "ask") {
      // The diamond grows until every line fits its sloping sides at that
      // line's height, with the slack for a wider viewer font.
      n._l = wrap(n.t, fontOf(n, g), (g.BW - 30) * SLACK); n._i = [];
      ctx.font = fontOf(n, g);
      const hw = g.BW / 2 + 10, widths = n._l.map(l => ctx.measureText(l).width / SLACK);
      let h = 54;
      const fits = h => n._l.every((l, i) => {
        const mid = (i - (n._l.length - 1) / 2) * lh, edge = Math.abs(mid) + lh / 2;
        return widths[i] / 2 + 3 <= hw * (1 - edge / (h / 2 + 6));
      });
      while (!fits(h) && h < 200) h += 2;
      n._h = h;
    } else {
      n._l = wrap(n.t, fontOf(n, g), (g.BW - 14) * SLACK); n._i = n.id ? idLines(n.id, g) : [];
      n._h = n._l.length * lh + n._i.length * ih + (n.k === "run" ? 16 : 18);
    }
  }
  function place(n, col, depth, keys, g) {
    n.depth = depth; if (n.key) keys[n.key] = n;
    const cd = depth + 1 + (n.skip || 0);
    if (!n.c.length) { n.cx = g.PAD + (col + 0.5) * g.COL; return 1; }
    let c = col; for (const ch of n.c) c += place(ch, c, cd, keys, g);
    n.cx = (n.c[0].cx + n.c[n.c.length - 1].cx) / 2; return c - col;
  }

  function chooserSvg(name, geom) {
    const spec = CHARTS[name], g = GEOM[geom], root = spec.root(), keys = {};
    walk(root, n => prepare(n, g));
    const cols = place(root, 0, 0, keys, g);
    // Each row is as tall as its tallest box.
    const rowH = []; walk(root, n => { rowH[n.depth] = Math.max(rowH[n.depth] || 0, n._h + (n.k === "ask" ? 12 : 0)); });
    for (let i = 0; i < rowH.length; i++) rowH[i] = rowH[i] || 40;
    const rowY = [g.PAD + 4]; for (let i = 1; i < rowH.length; i++) rowY[i] = rowY[i - 1] + rowH[i - 1] + g.GAP;
    const top = n => rowY[n.depth] + (rowH[n.depth] - n._h) / 2;
    // An arrow label sits right of its arrow; the card widens for one that
    // would run past the right edge.
    ctx.font = `600 ${g.size.el}px Arial, sans-serif`;
    let reach = g.PAD + cols * g.COL;
    walk(root, n => { if (n.el) reach = Math.max(reach, n.cx + 6 + ctx.measureText(n.el).width / SLACK + 4); });
    const W = Math.round(reach + g.PAD), H = Math.round(rowY[rowH.length - 1] + rowH[rowH.length - 1] + g.PAD);

    const svg = S("svg", { xmlns: NS, width: W, height: H, viewBox: `0 0 ${W} ${H}`, role: "img", "aria-labelledby": "t d" });
    svg.append(S("title", { id: "t" }, "Choosing a method in surveyframe: " + spec.title));
    svg.append(S("desc", { id: "d" }, spec.desc));
    svg.append(S("rect", { x: 0.5, y: 0.5, width: W - 1, height: H - 1, rx: 8, fill: C.bg, stroke: C.border }));
    const ge = S("g", { fill: "none", stroke: C.edge, "stroke-width": 1.5 });
    const ga = S("g", { fill: C.edge }), gb = S("g"), gl = S("g", { fill: C.text, "font-family": SANS, "font-weight": 600, "font-size": g.size.el });
    svg.append(ge, ga, gb, gl);
    const arrowDown = (x, y) => ga.append(S("path", { d: `M${x - 4.5},${y - 7} L${x + 4.5},${y - 7} L${x},${y} Z` }));

    walk(root, n => {
      if (!n.c.length) return;
      const y0 = top(n) + n._h + (n.k === "ask" ? 6 : 0);
      const ct = Math.min(...n.c.map(ch => top(ch) - (ch.k === "ask" ? 6 : 0)));
      const bus = ct - 22;
      ge.append(S("path", { d: `M${n.cx},${y0} V${bus}` }));
      if (n.c.length > 1) ge.append(S("path", { d: `M${n.c[0].cx},${bus} H${n.c[n.c.length - 1].cx}` }));
      for (const ch of n.c) {
        const t = top(ch) - (ch.k === "ask" ? 6 : 0);
        ge.append(S("path", { d: `M${ch.cx},${bus} V${t - 1}` })); arrowDown(ch.cx, t);
        if (ch.el) gl.append(S("text", { x: ch.cx + 6, y: bus + 14 }, ch.el));
      }
    });
    for (const [a, b, lab] of spec.links) {
      const A = keys[a], B = keys[b], dir = B.cx > A.cx ? 1 : -1;
      const y = top(A) + A._h / 2, x0 = A.cx + dir * (g.BW / 2 + 10);
      ge.append(S("path", { d: `M${x0},${y} H${B.cx - dir}` }));
      ga.append(S("path", { d: `M${B.cx - dir * 7},${y - 4.5} L${B.cx - dir * 7},${y + 4.5} L${B.cx},${y} Z` }));
      gl.append(S("text", { x: x0 + dir * 8, y: y - 6, "text-anchor": dir > 0 ? "start" : "end" }, lab));
    }
    walk(root, n => {
      const x = n.cx - g.BW / 2, y = top(n), h = n._h, box = S("g", { "data-box": n.id || n.t });
      const fill = { root: C.root, kind: C.kind, design: C.design, ask: C.bg, run: C.accent }[n.k];
      const color = { root: C.onRoot, run: C.onAccent }[n.k] || C.text;
      if (n.k === "ask") {
        const hw = g.BW / 2 + 10, cy = y + h / 2;
        box.append(S("polygon", { points: `${n.cx},${y - 6} ${n.cx + hw},${cy} ${n.cx},${y + h + 6} ${n.cx - hw},${cy}`, fill, stroke: C.accent, "stroke-width": 1.4 }));
      } else {
        const r = { x, y, width: g.BW, height: h, rx: n.k === "root" ? 7 : 5, fill };
        if (n.k === "kind") Object.assign(r, { stroke: C.accent, "stroke-width": 1.1 });
        if (n.k === "design") Object.assign(r, { stroke: C.designLine, "stroke-width": 1.1 });
        box.append(S("rect", r));
      }
      const lh = g.size[n.k] + 3.5, ih = g.size.id + 3.5;
      const total = n._l.length * lh + n._i.length * ih;
      let ty = y + h / 2 - total / 2 + g.size[n.k] * 0.8;
      const weight = { root: 600, kind: 600, design: 400, ask: 400, run: 600 }[n.k];
      for (const l of n._l) {
        const a = { x: n.cx, y: ty, "text-anchor": "middle", fill: color, "font-family": SANS, "font-size": g.size[n.k], "font-weight": weight };
        if (n.k === "ask") a["font-style"] = "italic";
        box.append(S("text", a, l)); ty += lh;
      }
      for (const l of n._i) {
        box.append(S("text", { x: n.cx, y: ty - 1, "text-anchor": "middle", fill: color, "font-family": MONO, "font-size": g.size.id, opacity: 0.92 }, l));
        ty += ih;
      }
      gb.append(box);
    });
    return svg;
  }

  // The run-level IDs, for the build script's check against the plan's
  // method switch().
  function chooserRunIds() {
    const ids = new Set();
    for (const k of Object.keys(CHARTS)) walk(CHARTS[k].root(), n => { if (n.k === "run") ids.add(n.id); });
    return [...ids];
  }

  // Text that crosses its box edge, measured in the browser. `font` swaps in
  // a wider family to stand in for a viewer's font.
  function chooserOverflow(markup, font) {
    const host = document.createElement("div"); host.innerHTML = markup; document.body.append(host);
    const svg = host.querySelector("svg"); const bad = [];
    if (font) svg.querySelectorAll("text").forEach(t => t.setAttribute("font-family", t.getAttribute("font-family").startsWith("ui-monospace") ? font.mono : font.sans));
    svg.querySelectorAll("g[data-box]").forEach(b => {
      const shape = b.querySelector("rect,polygon").getBBox();
      const isAsk = b.querySelector("polygon") !== null;
      b.querySelectorAll("text").forEach(t => {
        const r = t.getBBox();
        let left = shape.x + 2, right = shape.x + shape.width - 2;
        if (isAsk) {
          // The diamond's half-width at the line's edge farthest from its middle.
          const cx = shape.x + shape.width / 2, cy = shape.y + shape.height / 2;
          const far = Math.max(Math.abs(r.y - cy), Math.abs(r.y + r.height - cy));
          const half = (shape.width / 2) * (1 - far / (shape.height / 2));
          left = cx - half + 1; right = cx + half - 1;
        }
        if (r.x < left || r.x + r.width > right) bad.push(b.getAttribute("data-box") + ": " + t.textContent);
      });
    });
    host.remove(); return bad;
  }

  window.chooserSvg = (name, geom) => chooserSvg(name, geom).outerHTML;
  window.chooserRunIds = chooserRunIds;
  window.chooserOverflow = chooserOverflow;
  window.chooserCharts = Object.keys(CHARTS);
})();
