(function () {
  const DATA_PATH = "/data/adopt-me-values.json";
  const VARIANT_LABELS = {
    default: "Default",
    noPotion: "No Potion",
    neon: "Neon",
    neonNoPotion: "Neon No Potion",
    mega: "Mega Neon",
    megaNoPotion: "Mega No Potion"
  };

  function formatValue(value) {
    if (value >= 1000) {
      return `${(value / 1000).toFixed(value % 1000 === 0 ? 0 : 1)}K`;
    }

    if (Number.isInteger(value)) {
      return String(value);
    }

    return value.toFixed(value < 10 ? 2 : 1).replace(/\.0$/, "");
  }

  async function loadAdoptValues() {
    const response = await fetch(DATA_PATH, { cache: "no-store" });
    if (!response.ok) {
      throw new Error(`Unable to load value data: ${response.status}`);
    }

    const payload = await response.json();
    payload.pets.sort((a, b) => b.values.default - a.values.default);
    payload.petIndex = Object.fromEntries(payload.pets.map((pet) => [pet.slug, pet]));
    return payload;
  }

  function getVariantEntries(pet) {
    return Object.keys(pet.values)
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
    VARIANT_LABELS,
    formatValue,
    getVariantEntries,
    getVariantValue,
    loadAdoptValues,
    renderError
  };
})();
