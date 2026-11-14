// Name each heading permalink after its heading, in place of pkgdown's
// generic "anchor" (Codex WR82), so a screen reader says where it leads.
document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll("a.anchor").forEach(function (a) {
    var h = a.parentElement;
    if (!h) return;
    var text = h.textContent.trim();
    if (text) a.setAttribute("aria-label", "Link to the section " + text);
  });
});
