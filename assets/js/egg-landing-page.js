(function () {
  const PAGE = window.ThePatchEggLanding || null;
  if (!PAGE || !PAGE.id) {
    return;
  }

  const RARITY_ORDER = ["Common", "Uncommon", "Rare", "Ultra-Rare", "Legendary"];
  const PET_OVERRIDES = {
    mole: { catalogName: "Mole Pet", slug: "mole-pet", image: "/assets/pets/mole-pet.png" },
    weevil: { catalogName: "Weevil Pet", slug: "weevil-pet", image: "/assets/pets/weevil-pet.png" },
    prayingmantis: { catalogName: "Praying Mantis Pet", slug: "praying-mantis-pet", image: "/assets/pets/praying-mantis-pet.png" },
    milkchoccybunny: { slug: "milk-choco-bunny", image: "/assets/pets/milk-choco-bunny.png" },
    whitechoccybunny: { slug: "white-choco-bunny", image: "/assets/pets/white-choco-bunny.png" },
    darkchoccybunny: { slug: "dark-choco-bunny", image: "/assets/pets/dark-choco-bunny.png" }
  };

  function normalizeName(value) {
    return String(value || "").toLowerCase().replace(/[^a-z0-9]+/g, "");
  }

  function formatPercent(decimal) {
    return `${(decimal * 100).toFixed(decimal >= 0.1 ? 1 : 2).replace(/\.0$/, "")}%`;
  }

  function parseChance(value) {
    if (value === null || value === undefined || value === "" || value === "Varies") {
      return null;
    }
    if (typeof value === "number") {
      return value;
    }
    return Number(String(value).replace("%", "")) / 100;
  }

  function toPetObject(pet) {
    if (Array.isArray(pet)) {
      if (pet.length === 2) {
        return { name: pet[0], rarity: pet[1] };
      }
      if (pet.length === 3 && /%|Varies/i.test(String(pet[2]))) {
        return { name: pet[0], rarity: pet[1], chance: pet[2] };
      }
      if (pet.length >= 3) {
        return { name: pet[0], image: pet[1], rarity: pet[2], chance: pet[3] };
      }
    }
    return pet;
  }

  function mergeEggPayload(basePayload, patchPayload) {
    const merged = new Map((basePayload.eggs || []).map((egg) => [egg.id, egg]));
    Object.entries((patchPayload && patchPayload.correctedEggs) || {}).forEach(([id, patch]) => {
      const current = merged.get(id) || { id, name: patch.name || id };
      merged.set(id, { ...current, ...patch, id: current.id || id });
    });
    ((patchPayload && patchPayload.extraEggs) || []).forEach((egg) => {
      merged.set(egg.id, egg);
    });
    return [...merged.values()];
  }

  function buildCatalogIndex(catalogPayload) {
    return new Map((catalogPayload.entries || []).map((entry) => [normalizeName(entry.name), entry]));
  }

  function normalizeEgg(rawEgg, valuePayload, catalogIndex) {
    const egg = { ...rawEgg };
    egg.rarityChances = egg.rarityChances || egg.chances || {};
    egg.pets = (egg.pets || []).map(toPetObject);

    const rarityGroups = {};
    egg.pets.forEach((pet) => {
      rarityGroups[pet.rarity] = rarityGroups[pet.rarity] || [];
      rarityGroups[pet.rarity].push(pet);
    });

    egg.pets = egg.pets.map((pet) => {
      const override = PET_OVERRIDES[normalizeName(pet.name)];
      const catalogEntry = catalogIndex.get(normalizeName(override?.catalogName || pet.name));
      const slug = override?.slug || pet.slug || catalogEntry?.slug || window.ThePatchEggs.slugifyPetName(pet.name);
      const image = override?.image || catalogEntry?.image || `/assets/pets/${slug}.png`;
      const explicitChance = parseChance(pet.chance);
      const rarityChance = parseChance((egg.rarityChances || {})[pet.rarity]);
      const petsInRarity = (rarityGroups[pet.rarity] || []).filter((item) => parseChance(item.chance) === null).length || 1;
      const computedChance = explicitChance !== null
        ? explicitChance
        : (egg.chanceMode === "variable" || rarityChance === null ? null : rarityChance / petsInRarity);
      const benchmark = valuePayload.petIndex[slug];

      return {
        ...pet,
        slug,
        image,
        benchmark,
        chanceValue: computedChance,
        chanceLabel: pet.chance === "Varies" ? "Varies" : (computedChance === null ? "Unknown" : formatPercent(computedChance))
      };
    });

    egg.petCount = egg.pets.length;
    egg.benchmarkPets = egg.pets.filter((pet) => pet.benchmark);
    return egg;
  }

  function setText(id, value) {
    const node = document.getElementById(id);
    if (node) {
      node.textContent = value;
    }
  }

  function setHtml(id, value) {
    const node = document.getElementById(id);
    if (node) {
      node.innerHTML = value;
    }
  }

  function renderMeta(egg) {
    const chips = [
      `<span class="egg-landing-pill ${egg.status === "available" ? "available" : "retired"}">${egg.status === "available" ? "Live" : "Retired"}</span>`,
      `<span class="egg-landing-pill">${egg.cost}</span>`,
      `<span class="egg-landing-pill">Released ${egg.released}</span>`,
      `<span class="egg-landing-pill">${egg.petCount} hatchable pets</span>`
    ];
    if (egg.retired) {
      chips.push(`<span class="egg-landing-pill">Retired ${egg.retired}</span>`);
    }
    return chips.join("");
  }

  function renderOdds(egg) {
    return RARITY_ORDER
      .filter((rarity) => egg.rarityChances && egg.rarityChances[rarity] !== undefined)
      .map((rarity) => `
        <div class="egg-odds-card">
          <strong>${egg.rarityChances[rarity]}</strong>
          <span>${rarity}</span>
        </div>
      `).join("");
  }

  function renderHighlightPets(egg) {
    const names = PAGE.highlightPets || [];
    const picks = names
      .map((name) => egg.pets.find((pet) => normalizeName(pet.name) === normalizeName(name)))
      .filter(Boolean);

    if (!picks.length) {
      return `<div class="egg-highlight-card"><h3>Full hatch pool included</h3><p>This page lists every pet in the ${egg.name} with its rarity and current pull chance.</p></div>`;
    }

    return picks.map((pet) => `
      <div class="egg-highlight-pet">
        <img src="${pet.image}" alt="${pet.name}" loading="lazy" onerror="this.style.display='none';">
        <div>
          <strong>${pet.name}</strong>
          <span>${pet.rarity} &#183; ${pet.chanceLabel} pull rate</span>
        </div>
      </div>
    `).join("");
  }

  function renderBenchmarkLinks(egg) {
    if (!egg.benchmarkPets.length) {
      return `<p>This egg does not currently feed directly into the featured benchmark pet pages, but the full hatch pool is still listed below.</p>`;
    }

    return egg.benchmarkPets.map((pet) => `
      <a class="egg-tool-link" href="/pets/${pet.slug}.html">
        <span>Open ${pet.name} value page</span>
      </a>
    `).join("");
  }

  function renderRaritySections(egg) {
    return RARITY_ORDER
      .map((rarity) => {
        const pets = egg.pets.filter((pet) => pet.rarity === rarity);
        if (!pets.length) {
          return "";
        }

        return `
          <section class="egg-rarity-group">
            <div class="egg-rarity-head">
              <strong>${rarity}</strong>
              <span class="egg-rarity-pill">${egg.rarityChances[rarity] || "Varies"} tier chance</span>
            </div>
            <div class="egg-pet-grid">
              ${pets.map((pet) => `
                <div class="egg-pet-card">
                  <div class="egg-pet-media">
                    <img src="${pet.image}" alt="${pet.name}" loading="lazy" onerror="this.style.display='none';this.nextElementSibling.style.display='block';">
                    <div class="egg-pet-fallback">${pet.name}</div>
                  </div>
                  <div class="egg-pet-meta">
                    <strong>${pet.name}</strong>
                    <span>${pet.rarity}</span>
                    <span>${pet.chanceLabel} pull rate</span>
                  </div>
                </div>
              `).join("")}
            </div>
          </section>
        `;
      })
      .filter(Boolean)
      .join("");
  }

  async function boot() {
    try {
      const [baseEggPayload, valuePayload, catalogPayload] = await Promise.all([
        window.ThePatchEggs.loadEggs(window.ThePatchEggs.FULL_DATA_PATH),
        window.ThePatchValues.loadAdoptValues(),
        fetch("/data/adopt-me-pet-catalog.json", { cache: "no-store" }).then((response) => {
          if (!response.ok) {
            throw new Error(`Unable to load pet catalog: ${response.status}`);
          }
          return response.json();
        })
      ]);

      const mergedEggs = mergeEggPayload(baseEggPayload, window.ThePatchEggGuideData || {});
      const catalogIndex = buildCatalogIndex(catalogPayload);
      const egg = mergedEggs
        .map((item) => normalizeEgg(item, valuePayload, catalogIndex))
        .find((item) => item.id === PAGE.id);

      if (!egg) {
        throw new Error(`Egg not found: ${PAGE.id}`);
      }

      setText("egg-live-title", egg.name);
      setText("egg-live-count", `${egg.petCount} hatchable pets`);
      setText("egg-live-status", egg.status === "available" ? "Live egg" : "Retired egg");
      setHtml("egg-page-meta", renderMeta(egg));
      setHtml("egg-odds-grid", renderOdds(egg));
      setHtml("egg-highlight-pets", renderHighlightPets(egg));
      setHtml("egg-benchmark-links", renderBenchmarkLinks(egg));
      setHtml("egg-rarity-stack", renderRaritySections(egg));

      const art = document.getElementById("egg-page-art");
      if (art) {
        art.src = window.ThePatchEggs.eggVisualUrl(egg);
        art.alt = egg.name;
        art.onerror = function () {
          this.onerror = null;
          this.src = window.ThePatchEggs.eggDisplayUrl(egg);
        };
      }
    } catch (error) {
      setHtml("egg-rarity-stack", `<div class="egg-landing-empty"><p>This egg page could not load the hatch data right now. Please refresh and try again.</p></div>`);
    }
  }

  boot();
})();
