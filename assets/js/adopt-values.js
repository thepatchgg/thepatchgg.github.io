(function () {
  const DATA_PATH = "/data/adopt-me-values.json";
  const NEW_PET_PROJECTIONS = [
    {
      slug: "bison",
      name: "Bison",
      rarity: "Rare",
      image: "/assets/pets/bison.png",
      values: {
        default: 0.75,
        fly: 0.5,
        ride: 0.5,
        noPotion: 0.3,
        neon: 2.25,
        neonFly: 1.98,
        neonRide: 1.98,
        neonNoPotion: 1.7,
        mega: 9.8,
        megaFly: 8.4,
        megaRide: 8.4,
        megaNoPotion: 7.5
      },
      note: "Temporary new-pet projection added June 2, 2026 while the normal value feed catches up."
    }
  ];
  const VARIANT_ORDER = [
    "default",
    "fly",
    "ride",
    "noPotion",
    "neon",
    "neonFly",
    "neonRide",
    "neonNoPotion",
    "mega",
    "megaFly",
    "megaRide",
    "megaNoPotion"
  ];
  const VARIANT_LABELS = {
    default: "Fly Ride",
    fly: "Fly",
    ride: "Ride",
    noPotion: "No Potion",
    neon: "Neon Fly Ride",
    neonFly: "Neon Fly",
    neonRide: "Neon Ride",
    neonNoPotion: "Neon No Potion",
    mega: "Mega Fly Ride",
    megaFly: "Mega Fly",
    megaRide: "Mega Ride",
    megaNoPotion: "Mega No Potion"
  };

  function formatValue(value) {
    if (typeof value !== "number" || !Number.isFinite(value)) {
      return "Pending";
    }

    if (value >= 1000) {
      return `${(value / 1000).toFixed(value % 1000 === 0 ? 0 : 1)}K`;
    }

    if (Number.isInteger(value)) {
      return String(value);
    }

    return value.toFixed(value < 10 ? 2 : 1).replace(/\.0$/, "");
  }

  function addNewPetProjections(payload) {
    if (!payload || !Array.isArray(payload.pets)) return;
    const seen = new Set(payload.pets.map((pet) => pet.slug));
    NEW_PET_PROJECTIONS.forEach((pet) => {
      if (!seen.has(pet.slug)) {
        payload.pets.push(pet);
        seen.add(pet.slug);
      }
    });
  }

  async function loadAdoptValues() {
    const response = await fetch(DATA_PATH, { cache: "no-store" });
    if (!response.ok) {
      throw new Error(`Unable to load value data: ${response.status}`);
    }

    const payload = await response.json();
    addNewPetProjections(payload);
    payload.pets.sort((a, b) => b.values.default - a.values.default);
    payload.petIndex = Object.fromEntries(payload.pets.map((pet) => [pet.slug, pet]));
    return payload;
  }

  function getVariantEntries(pet) {
    return VARIANT_ORDER
      .filter((key) => typeof pet.values[key] === "number")
      .map((key) => ({
        key,
        label: VARIANT_LABELS[key] || key,
        value: pet.values[key]
      }));
  }

  function getVariantValue(pet, variantKey) {
    return pet.values[variantKey] ?? pet.values.default;
  }

  function renderError(target, message) {
    target.innerHTML = `<div class="status-card error">${message}</div>`;
  }

  window.ThePatchValues = {
    DATA_PATH,
    VARIANT_ORDER,
    VARIANT_LABELS,
    formatValue,
    getVariantEntries,
    getVariantValue,
    loadAdoptValues,
    renderError
  };
})();
