(function () {
  const pet = window.ThePatchPendingPet;
  const root = document.getElementById("pending-pet-root");
  if (!pet || !root) return;
  const format = (value) => Number(value).toFixed(value < 0.1 ? 3 : 2).replace(/0+$/, "").replace(/\.$/, "");

  function render(estimate) {
    const matrix = estimate && estimate.values;
    const valueTag = matrix ? `${format(matrix.default.noPotion)} pts no potion` : "No live value";
    const marketCopy = matrix
      ? "The Patch is using a dated launch-market estimate reviewed September 5, 2026. Early values can move quickly as supply grows."
      : "Its live trade value is still forming.";
    const valueSection = matrix
      ? `<h2>Launch value estimate</h2><p>Current calculator lanes are based on a live Elvebredd table reviewed through JaeJaeValues on <strong>September 5, 2026</strong>. Treat these as volatile estimates, not guaranteed trade prices.</p><ul class="mini-list variant-list"><li><span>Normal</span><span>${format(matrix.default.noPotion)} NP / ${format(matrix.default.flyRide)} FR</span></li><li><span>Neon</span><span>${format(matrix.neon.noPotion)} NP / ${format(matrix.neon.flyRide)} FR</span></li><li><span>Mega</span><span>${format(matrix.mega.noPotion)} NP / ${format(matrix.mega.flyRide)} FR</span></li></ul>`
      : `<h2>Current value status</h2><p>The Patch has not assigned a calculator number yet. The pet is searchable in Trade Calc, but calculations stay disabled until reliable current market evidence supports a value lane.</p>`;
    root.innerHTML = `
    <section class="page-hero"><div class="shell detail-hero">
      <div class="detail-hero-copy"><nav class="crumbs" aria-label="Breadcrumb"><a href="/">Home</a><span aria-hidden="true">/</span><a href="/pets/">Pet library</a><span aria-hidden="true">/</span><span>${pet.name}</span></nav><div class="eyebrow">Fairytale Egg pet</div><h1>${pet.name}</h1><p>${pet.name} is a ${pet.rarity} pet released with the Fairytale Egg on August 29, 2026. ${marketCopy}</p><div class="cta-row"><a class="button primary" href="/pet-value-calculator.html">Open Trade Calculator</a><a class="button secondary" href="/articles/adopt-me-fairytale-egg-guide.html">Open egg page</a></div></div>
      <aside class="hero-panel detail-hero-panel"><div class="pet-row"><img class="pet-avatar detail-avatar" src="/assets/pets/${pet.slug}.png" alt="${pet.name}"><div class="pet-name"><strong>${pet.name}</strong><small>${pet.rarity} Fairytale Egg pet</small></div></div><div class="catalog-meta"><span class="tone tone-high">Launch estimate</span><span class="value-tag">${valueTag}</span></div><ul class="mini-list detail-kpis"><li><span>Released</span><span>Aug 29, 2026</span></li><li><span>Fairytale chance</span><span>${pet.chance}</span></li><li><span>Egg price</span><span>750 Bucks</span></li></ul></aside>
    </div></section>
    <section class="section"><div class="shell detail-grid"><section class="tool-card stack detail-main"><h2>How to get ${pet.name}</h2><p>Hatch the current <strong>Fairytale Egg</strong>, available for <strong>750 Bucks</strong>. ${pet.name} has a <strong>${pet.chance}</strong> individual chance from this egg.</p>${valueSection}</section><aside class="tool-card stack detail-sidebar"><h2>Origin snapshot</h2><ul class="mini-list variant-list"><li><span>Source</span><span>Fairytale Egg</span></li><li><span>Rarity</span><span>${pet.rarity}</span></li><li><span>Status</span><span>Current rotation</span></li></ul><div class="stack-actions"><a class="pill-link" href="https://www.playadopt.me/news/fairytale-egg" target="_blank" rel="noopener">Read official notes</a><a class="pill-link" href="${estimate && estimate.sourceUrl ? estimate.sourceUrl : "/methodology.html"}" target="_blank" rel="noopener">Value evidence</a><a class="pill-link" href="/pet-value-calculator.html">Search in calculator</a></div></aside></div></section>`;
  }

  fetch("/data/adopt-me-new-pet-overrides.json", { cache: "no-store" })
    .then((response) => response.ok ? response.json() : { pets: [] })
    .then((payload) => render((payload.pets || []).find((entry) => entry.slug === pet.slug)))
    .catch(() => render(null));
})();
