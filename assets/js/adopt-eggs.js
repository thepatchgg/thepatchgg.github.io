(function () {
  const DATA_PATH = "/data/adopt-me-eggs.json";
  const WIKI_IMAGE_BASE = "https://static.wikia.nocookie.net/adoptme/images/";

  function parsePercent(value) {
    return Number(String(value || "0").replace("%", "")) / 100;
  }

  function parseCost(costText) {
    const match = String(costText || "").match(/([\d,]+)/);
    const amount = match ? Number(match[1].replace(/,/g, "")) : 0;

    if (/robux/i.test(costText || "")) {
      return { amount, currency: "Robux" };
    }
    if (/ticket/i.test(costText || "")) {
      return { amount, currency: "Tickets" };
    }

    return { amount, currency: "Bucks" };
  }

  function slugifyPetName(name) {
    return String(name || "")
      .toLowerCase()
      .replace(/['"]/g, "")
      .replace(/&/g, " and ")
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
      .replace(/-{2,}/g, "-");
  }

  function buildRarityBuckets(egg) {
    return egg.pets.reduce((buckets, pet) => {
      const rarity = pet[2];
      if (!buckets[rarity]) {
        buckets[rarity] = [];
      }
      buckets[rarity].push(pet);
      return buckets;
    }, {});
  }

  async function loadEggs() {
    const response = await fetch(DATA_PATH, { cache: "no-store" });
    if (!response.ok) {
      throw new Error(`Unable to load egg data: ${response.status}`);
    }

    return response.json();
  }

  function summarizeEgg(egg, valuesPayload) {
    const rarityBuckets = buildRarityBuckets(egg);
    const benchmarkPets = [];

    Object.entries(rarityBuckets).forEach(([rarity, pets]) => {
      const rarityChance = parsePercent(egg.chances[rarity]);
      if (!rarityChance || !pets.length) {
        return;
      }

      const perPetChance = rarityChance / pets.length;
      pets.forEach((pet) => {
        const slug = slugifyPetName(pet[0]);
        const benchmark = valuesPayload.petIndex[slug];
        if (!benchmark) {
          return;
        }

        benchmarkPets.push({
          name: benchmark.name,
          slug: benchmark.slug,
          rarity,
          chance: perPetChance,
          benchmarkValue: benchmark.values.default,
          contribution: perPetChance * benchmark.values.default
        });
      });
    });

    const benchmarkChance = benchmarkPets.reduce((sum, pet) => sum + pet.chance, 0);
    const expectedValue = benchmarkPets.reduce((sum, pet) => sum + pet.contribution, 0);
    const cost = parseCost(egg.cost);

    return {
      ...egg,
      costAmount: cost.amount,
      currency: cost.currency,
      benchmarkPets: benchmarkPets.sort((left, right) => right.contribution - left.contribution),
      benchmarkChance,
      expectedValue,
      coveredBenchmarks: benchmarkPets.length
    };
  }

  function eggImageUrl(path) {
    return `${WIKI_IMAGE_BASE}${path}/revision/latest`;
  }

  window.ThePatchEggs = {
    DATA_PATH,
    eggImageUrl,
    loadEggs,
    parseCost,
    parsePercent,
    slugifyPetName,
    summarizeEgg
  };
})();
