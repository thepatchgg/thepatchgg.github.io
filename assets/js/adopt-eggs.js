(function () {
  const DATA_PATH = "/data/adopt-me-verified-eggs.json";
  const FULL_DATA_PATH = "/data/adopt-me-eggs.json";
  const WIKI_IMAGE_BASE = "https://static.wikia.nocookie.net/adoptme/images/";
  const LOCAL_EXACT_EGG_IDS = new Set([
    "aussie",
    "aztec",
    "basic",
    "blue",
    "christmas",
    "christmas-future",
    "cracked",
    "crystal",
    "danger",
    "diamond",
    "desert",
    "easter-2020",
    "endangered",
    "farm",
    "fossil",
    "fool",
    "garden",
    "golden",
    "japan",
    "jungle",
    "moon",
    "mythic",
    "ocean",
    "pet",
    "pink",
    "retired",
    "royal",
    "royal-aztec",
    "royal-desert",
    "royal-moon",
    "safari",
    "southeast-asia",
    "starter",
    "woodland"
    ,
    "urban",
    "wrapped-doll",
    "zodiac-minion"
  ]);
  const EGG_ART_PALETTES = {
    starter: { shell: "#f5d8a8", accent: "#4b7dd7", detail: "#724b2d", glow: "#ffe7b6" },
    blue: { shell: "#5aa6ff", accent: "#2f5fd4", detail: "#143167", glow: "#d7ebff" },
    pink: { shell: "#ff9ec8", accent: "#ff6daa", detail: "#8a3558", glow: "#ffe1ef" },
    cracked: { shell: "#f6f2e7", accent: "#d9b77e", detail: "#8f5c32", glow: "#ffe7b5" },
    pet: { shell: "#f9f4ea", accent: "#6fc2ff", detail: "#2f5d8a", glow: "#d9efff" },
    royal: { shell: "#fff6de", accent: "#f1c34f", detail: "#8a2f2f", glow: "#ffe9a7" },
    retired: { shell: "#efe8d9", accent: "#9ca6b8", detail: "#5b4634", glow: "#e7ddc1" },
    safari: { shell: "#f4d98d", accent: "#7a4e28", detail: "#4b2f17", glow: "#ffe9a1" },
    jungle: { shell: "#6fcf7e", accent: "#f4d84b", detail: "#27553a", glow: "#d9ffd8" },
    farm: { shell: "#ffffff", accent: "#111111", detail: "#f6b5c8", glow: "#fff0df" },
    christmas: { shell: "#4e8f48", accent: "#e84d4d", detail: "#f7d772", glow: "#d8ffdc" },
    aussie: { shell: "#a46a3c", accent: "#f3c08d", detail: "#5a3418", glow: "#ffd8a6" },
    golden: { shell: "#ffda61", accent: "#f6a406", detail: "#7c4d00", glow: "#fff1a3" },
    diamond: { shell: "#ccefff", accent: "#7dd8ff", detail: "#2f6b8f", glow: "#e5fbff" },
    "easter-2020": { shell: "#fff7e8", accent: "#ffd46d", detail: "#f08d8d", glow: "#fff3bf" },
    fossil: { shell: "#8ca96d", accent: "#6a4a2f", detail: "#35421f", glow: "#dfe8c2" },
    ocean: { shell: "#7fd3ff", accent: "#1f89d1", detail: "#0c496e", glow: "#dff7ff" },
    mythic: { shell: "#b98cff", accent: "#ffdb66", detail: "#59348a", glow: "#f1e4ff" },
    woodland: { shell: "#8ab362", accent: "#d14f3f", detail: "#365126", glow: "#e7f5d6" },
    "zodiac-minion": { shell: "#ffd7a1", accent: "#ff9e6e", detail: "#6e3f36", glow: "#fff0d4" },
    japan: { shell: "#fff1f1", accent: "#f46060", detail: "#4a6b47", glow: "#ffe1e1" },
    "southeast-asia": { shell: "#d8c883", accent: "#da5547", detail: "#2c6c63", glow: "#f9f1c6" },
    fool: { shell: "#6bd28d", accent: "#ff6b8b", detail: "#2d5b32", glow: "#e6ffef" },
    danger: { shell: "#ffdd7d", accent: "#ff6b42", detail: "#5a2b1e", glow: "#fff1bf" },
    "wrapped-doll": { shell: "#7ec2ff", accent: "#ef5757", detail: "#365b8a", glow: "#d9efff" },
    urban: { shell: "#f7efe0", accent: "#ff8a3d", detail: "#30343a", glow: "#fff2d8" },
    "christmas-future": { shell: "#d8f4ff", accent: "#a874ff", detail: "#365b8a", glow: "#eefaff" },
    "royal-desert": { shell: "#efd99f", accent: "#d59c2a", detail: "#6a3c22", glow: "#fff0c4" },
    desert: { shell: "#f0d088", accent: "#c46b2f", detail: "#74401d", glow: "#fff0c7" },
    garden: { shell: "#99db7f", accent: "#37a95f", detail: "#305a2f", glow: "#e8ffd7" },
    moon: { shell: "#cad1df", accent: "#7d89b5", detail: "#394055", glow: "#edf1ff" },
    "royal-moon": { shell: "#c9d2ec", accent: "#a4b3ff", detail: "#4b547e", glow: "#eef1ff" },
    aztec: { shell: "#efb15e", accent: "#2c8c65", detail: "#6c3317", glow: "#ffe8ba" },
    "royal-aztec": { shell: "#f3c66d", accent: "#f2df8d", detail: "#6c3317", glow: "#fff0be" },
    endangered: { shell: "#7db89b", accent: "#2f7f66", detail: "#1f463e", glow: "#dff6eb" },
    basic: { shell: "#f6f7fb", accent: "#58b7e7", detail: "#38506b", glow: "#eef9ff" },
    crystal: { shell: "#8ddaff", accent: "#c0f3ff", detail: "#2c5f8c", glow: "#e7fdff" }
  };
  const EGG_ART_VARIANTS = {
    starter: "starter",
    blue: "solid",
    pink: "solid",
    cracked: "cracked",
    pet: "band",
    royal: "royal",
    retired: "band",
    safari: "spots",
    jungle: "leaf",
    farm: "cow",
    christmas: "festive",
    aussie: "earth",
    golden: "gem",
    diamond: "gem",
    "easter-2020": "pastel",
    fossil: "fossil",
    ocean: "wave",
    mythic: "rune",
    woodland: "leaf",
    "zodiac-minion": "sun",
    japan: "sun",
    "southeast-asia": "tropical",
    fool: "confetti",
    danger: "warning",
    "wrapped-doll": "gift",
    urban: "city",
    "christmas-future": "future",
    "royal-desert": "royal",
    desert: "desert",
    garden: "garden",
    moon: "moon",
    "royal-moon": "royal-moon",
    aztec: "aztec",
    "royal-aztec": "royal-aztec",
    endangered: "paw",
    basic: "ticket",
    crystal: "crystal"
  };

  function parsePercent(value) {
    return Number(String(value || "0").replace("%", "")) / 100;
  }

  function parseChance(value) {
    if (value === null || value === undefined || value === "" || /varies/i.test(String(value))) {
      return null;
    }

    if (typeof value === "number") {
      return value;
    }

    return parsePercent(value);
  }

  function parseCost(costText) {
    const match = String(costText || "").match(/([\d,]+)/);
    const amount = match ? Number(match[1].replace(/,/g, "")) : 0;

    if (/^\s*free/i.test(costText || "")) {
      return { amount, currency: "Free" };
    }
    if (/robux/i.test(costText || "")) {
      return { amount, currency: "Robux" };
    }
    if (/ticket/i.test(costText || "")) {
      return { amount, currency: "Tickets" };
    }
    if (/star/i.test(costText || "")) {
      return { amount, currency: "Stars" };
    }
    if (/gingerbread/i.test(costText || "")) {
      return { amount, currency: "Gingerbread" };
    }
    if (/moon beam|golden aztec skull/i.test(costText || "")) {
      return { amount, currency: "Event" };
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

  function normalizePetEntry(entry) {
    if (!Array.isArray(entry)) {
      return entry || null;
    }

    if (entry.length === 2) {
      return {
        name: entry[0],
        rarity: entry[1]
      };
    }

    if (entry.length === 3 && (/%|Varies/i.test(String(entry[2])) || typeof entry[2] === "number")) {
      return {
        name: entry[0],
        rarity: entry[1],
        chance: entry[2]
      };
    }

    return {
      name: entry[0],
      image: entry[1],
      rarity: entry[2],
      chance: entry[3]
    };
  }

  function escapeSvgText(value) {
    return String(value || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&apos;");
  }

  function hashString(value) {
    return String(value || "").split("").reduce((total, character) => total + character.charCodeAt(0), 0);
  }

  function eggPalette(egg) {
    const id = typeof egg === "string" ? egg : egg && egg.id;
    if (id && EGG_ART_PALETTES[id]) {
      return EGG_ART_PALETTES[id];
    }

    const fallbackPalettes = Object.values(EGG_ART_PALETTES);
    return fallbackPalettes[hashString(id || "egg") % fallbackPalettes.length];
  }

  function eggLabel(egg) {
    const name = (egg && egg.name) || "Egg";
    const firstWord = name.replace(/\s+Egg$/i, "").split(/\s+/)[0] || "Egg";
    return firstWord.slice(0, 10).toUpperCase();
  }

  function eggVariant(egg) {
    const id = typeof egg === "string" ? egg : egg && egg.id;
    return EGG_ART_VARIANTS[id] || "band";
  }

  function eggPatternMarkup(egg, palette) {
    const variant = eggVariant(egg);
    switch (variant) {
      case "solid":
        return "";
      case "starter":
        return `
          <rect x="34" y="82" width="52" height="12" rx="6" fill="${palette.accent}" opacity="0.95"/>
          <text x="60" y="90.5" text-anchor="middle" font-family="Arial, sans-serif" font-size="7" font-weight="800" letter-spacing="1" fill="#ffffff">STARTER</text>
        `;
      case "cracked":
        return `
          <path d="M57 28l-7 12 8 8-8 10 7 10" fill="none" stroke="${palette.detail}" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>
          <circle cx="47" cy="74" r="4" fill="${palette.accent}" opacity="0.38"/>
          <circle cx="72" cy="63" r="4" fill="${palette.accent}" opacity="0.35"/>
        `;
      case "band":
        return `<path d="M33 72c8 5 18 8 27 8s19-3 27-8v11c-8 5-18 8-27 8s-19-3-27-8z" fill="${palette.accent}" opacity="0.96"/>`;
      case "royal":
        return `
          <path d="M33 72c8 5 18 8 27 8s19-3 27-8v11c-8 5-18 8-27 8s-19-3-27-8z" fill="${palette.accent}" opacity="0.96"/>
          <circle cx="47" cy="56" r="4" fill="#f7db72"/>
          <circle cx="60" cy="51" r="5" fill="#f7db72"/>
          <circle cx="73" cy="56" r="4" fill="#f7db72"/>
        `;
      case "spots":
        return `
          <ellipse cx="48" cy="48" rx="7" ry="5" fill="${palette.detail}" opacity="0.45"/>
          <ellipse cx="69" cy="57" rx="8" ry="6" fill="${palette.detail}" opacity="0.4"/>
          <ellipse cx="54" cy="72" rx="6" ry="5" fill="${palette.detail}" opacity="0.35"/>
        `;
      case "leaf":
        return `
          <path d="M45 43c6-7 15-8 24-2-5 7-13 10-24 8 0-2 0-4 0-6z" fill="${palette.accent}" opacity="0.58"/>
          <path d="M51 70c7-5 16-5 23 2-6 6-14 7-23 4-1-2 0-4 0-6z" fill="${palette.accent}" opacity="0.48"/>
        `;
      case "cow":
        return `
          <ellipse cx="46" cy="49" rx="8" ry="6" fill="#1f1f1f" opacity="0.82"/>
          <ellipse cx="70" cy="60" rx="10" ry="7" fill="#1f1f1f" opacity="0.82"/>
          <ellipse cx="58" cy="77" rx="14" ry="8" fill="#f7b7c8" opacity="0.72"/>
        `;
      case "festive":
        return `
          <path d="M38 41l44 40" stroke="#ffffff" stroke-width="4" opacity="0.8"/>
          <path d="M82 41l-44 40" stroke="${palette.accent}" stroke-width="4" opacity="0.9"/>
          <circle cx="60" cy="60" r="7" fill="#f7d772"/>
        `;
      case "earth":
        return `
          <path d="M38 47c9-4 18-4 27 1s15 5 20 2" fill="none" stroke="${palette.detail}" stroke-width="4" stroke-linecap="round" opacity="0.42"/>
          <path d="M36 68c12-5 23-5 35 1 7 3 12 4 15 3" fill="none" stroke="${palette.accent}" stroke-width="4" stroke-linecap="round" opacity="0.5"/>
        `;
      case "gem":
        return `
          <path d="M60 42l8 8-8 8-8-8z" fill="#ffffff" opacity="0.55"/>
          <path d="M60 62l11 11-11 11-11-11z" fill="${palette.detail}" opacity="0.28"/>
        `;
      case "pastel":
        return `
          <circle cx="46" cy="52" r="5" fill="#f7b7c8" opacity="0.85"/>
          <circle cx="60" cy="47" r="5" fill="#ffe27a" opacity="0.85"/>
          <circle cx="73" cy="55" r="5" fill="#9ed8ff" opacity="0.85"/>
          <circle cx="55" cy="70" r="5" fill="#c8f58b" opacity="0.85"/>
        `;
      case "fossil":
        return `
          <circle cx="60" cy="58" r="10" fill="none" stroke="${palette.detail}" stroke-width="4" opacity="0.42"/>
          <path d="M60 48v20M50 58h20" stroke="${palette.detail}" stroke-width="4" opacity="0.35" stroke-linecap="round"/>
        `;
      case "wave":
        return `
          <path d="M36 61c7-7 15-7 22 0s15 7 22 0" fill="none" stroke="${palette.detail}" stroke-width="4" stroke-linecap="round" opacity="0.48"/>
          <path d="M40 74c6-5 12-5 18 0s12 5 18 0" fill="none" stroke="#ffffff" stroke-width="3" stroke-linecap="round" opacity="0.45"/>
        `;
      case "rune":
        return `
          <path d="M60 39l10 16-10 16-10-16z" fill="none" stroke="${palette.accent}" stroke-width="4" opacity="0.7"/>
          <circle cx="60" cy="55" r="5" fill="${palette.accent}" opacity="0.35"/>
        `;
      case "sun":
        return `
          <circle cx="60" cy="56" r="10" fill="${palette.accent}" opacity="0.62"/>
          <path d="M60 39v-8M60 81v-8M43 56h-8M85 56h-8M49 45l-6-6M71 67l6 6M71 45l6-6M49 67l-6 6" stroke="${palette.detail}" stroke-width="3" stroke-linecap="round" opacity="0.58"/>
        `;
      case "tropical":
        return `
          <path d="M37 69c10-5 18-5 24 0 7 5 15 5 23-1" fill="none" stroke="${palette.accent}" stroke-width="5" stroke-linecap="round" opacity="0.75"/>
          <path d="M40 50c9-8 18-9 27-2" fill="none" stroke="${palette.detail}" stroke-width="4" stroke-linecap="round" opacity="0.5"/>
        `;
      case "confetti":
        return `
          <circle cx="46" cy="50" r="3" fill="#ff6b8b"/><circle cx="58" cy="44" r="3" fill="#ffe27a"/><circle cx="72" cy="52" r="3" fill="#8ee3ff"/>
          <circle cx="52" cy="68" r="3" fill="#9df18f"/><circle cx="68" cy="72" r="3" fill="#ffd0f5"/>
        `;
      case "warning":
        return `
          <path d="M38 75l44-34" stroke="#512014" stroke-width="6" opacity="0.7"/>
          <path d="M46 84l44-34" stroke="#512014" stroke-width="6" opacity="0.55"/>
        `;
      case "gift":
        return `
          <path d="M60 34v46" stroke="${palette.accent}" stroke-width="6"/>
          <path d="M36 58h48" stroke="${palette.accent}" stroke-width="6"/>
          <rect x="48" y="30" width="24" height="12" rx="6" fill="${palette.detail}" opacity="0.58"/>
        `;
      case "city":
        return `
          <path d="M38 82h44" stroke="${palette.detail}" stroke-width="6" opacity="0.6"/>
          <path d="M42 82v-16M52 82v-24M64 82v-18M74 82v-28" stroke="${palette.accent}" stroke-width="5" stroke-linecap="round" opacity="0.75"/>
        `;
      case "future":
        return `
          <path d="M44 48h32" stroke="${palette.accent}" stroke-width="4" stroke-linecap="round" opacity="0.85"/>
          <path d="M39 61h42" stroke="#ffffff" stroke-width="3" stroke-linecap="round" opacity="0.65"/>
          <path d="M46 73h28" stroke="${palette.detail}" stroke-width="4" stroke-linecap="round" opacity="0.72"/>
        `;
      case "desert":
        return `
          <path d="M49 44c7 5 9 11 6 18M67 50c-4 4-5 9-3 15M54 69c5 3 7 7 5 12" fill="none" stroke="${palette.detail}" stroke-width="3.5" stroke-linecap="round" opacity="0.4"/>
        `;
      case "garden":
        return `
          <circle cx="60" cy="58" r="4" fill="#fff3a6"/>
          <circle cx="60" cy="47" r="5" fill="${palette.accent}"/><circle cx="71" cy="58" r="5" fill="${palette.accent}"/><circle cx="60" cy="69" r="5" fill="${palette.accent}"/><circle cx="49" cy="58" r="5" fill="${palette.accent}"/>
        `;
      case "moon":
        return `
          <circle cx="48" cy="49" r="6" fill="${palette.detail}" opacity="0.35"/>
          <circle cx="71" cy="60" r="8" fill="${palette.detail}" opacity="0.3"/>
          <circle cx="56" cy="72" r="5" fill="${palette.detail}" opacity="0.28"/>
        `;
      case "royal-moon":
        return `
          <circle cx="48" cy="49" r="6" fill="${palette.detail}" opacity="0.3"/>
          <circle cx="71" cy="60" r="8" fill="${palette.detail}" opacity="0.28"/>
          <path d="M33 72c8 5 18 8 27 8s19-3 27-8v11c-8 5-18 8-27 8s-19-3-27-8z" fill="${palette.accent}" opacity="0.96"/>
          <circle cx="60" cy="50" r="5" fill="#f6e7a1"/>
        `;
      case "aztec":
      case "royal-aztec":
        return `
          <path d="M43 47l17-8 17 8-17 8z" fill="${palette.accent}" opacity="0.68"/>
          <path d="M43 70l17-8 17 8-17 8z" fill="${palette.detail}" opacity="0.42"/>
          ${variant === "royal-aztec" ? `<circle cx="60" cy="55" r="5" fill="#f2df8d"/>` : ""}
        `;
      case "paw":
        return `
          <circle cx="60" cy="67" r="7" fill="${palette.detail}" opacity="0.38"/>
          <circle cx="49" cy="57" r="4" fill="${palette.detail}" opacity="0.38"/>
          <circle cx="57" cy="52" r="4" fill="${palette.detail}" opacity="0.38"/>
          <circle cx="66" cy="52" r="4" fill="${palette.detail}" opacity="0.38"/>
          <circle cx="74" cy="57" r="4" fill="${palette.detail}" opacity="0.38"/>
        `;
      case "ticket":
        return `
          <path d="M36 74h48" stroke="${palette.accent}" stroke-width="6" stroke-linecap="round"/>
          <circle cx="47" cy="74" r="2" fill="#ffffff"/><circle cx="60" cy="74" r="2" fill="#ffffff"/><circle cx="73" cy="74" r="2" fill="#ffffff"/>
        `;
      case "crystal":
        return `
          <path d="M60 38l9 10-4 13H55l-4-13z" fill="#ffffff" opacity="0.42"/>
          <path d="M46 67l8-9 6 11-8 9z" fill="${palette.accent}" opacity="0.48"/>
          <path d="M74 67l-8-9-6 11 8 9z" fill="${palette.detail}" opacity="0.28"/>
        `;
      default:
        return "";
    }
  }

  function eggDisplayUrl(egg) {
    const palette = eggPalette(egg);
    const label = escapeSvgText(eggLabel(egg));
    const svg = `
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" role="img" aria-label="${escapeSvgText((egg && egg.name) || "Egg")}">
        <defs>
          <linearGradient id="shell" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stop-color="${palette.glow}"/>
            <stop offset="48%" stop-color="${palette.shell}"/>
            <stop offset="100%" stop-color="${palette.accent}"/>
          </linearGradient>
          <linearGradient id="shine" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stop-color="rgba(255,255,255,0.9)"/>
            <stop offset="100%" stop-color="rgba(255,255,255,0)"/>
          </linearGradient>
          <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
            <feDropShadow dx="0" dy="10" stdDeviation="8" flood-color="rgba(0,0,0,0.32)"/>
          </filter>
        </defs>
        <rect width="120" height="120" rx="26" fill="#0a0f1b"/>
        <circle cx="60" cy="60" r="42" fill="${palette.glow}" opacity="0.22"/>
        <g filter="url(#shadow)">
          <ellipse cx="60" cy="66" rx="30" ry="38" fill="url(#shell)"/>
          <path d="M60 26c7 0 14 2 19 5-4 6-10 9-19 9-8 0-14-3-18-9 5-3 11-5 18-5Z" fill="${palette.detail}" opacity="0.9"/>
          <path d="M44 44c5-8 13-12 24-12 6 0 11 1 15 3" fill="none" stroke="rgba(255,255,255,0.32)" stroke-width="4" stroke-linecap="round"/>
          ${eggPatternMarkup(egg, palette)}
          <ellipse cx="48" cy="46" rx="12" ry="18" fill="url(#shine)" opacity="0.28" transform="rotate(-18 48 46)"/>
        </g>
        <rect x="22" y="88" width="76" height="16" rx="8" fill="rgba(10,15,27,0.72)" stroke="rgba(255,255,255,0.08)"/>
        <text x="60" y="99" text-anchor="middle" font-family="Arial, sans-serif" font-size="9" font-weight="700" letter-spacing="1.2" fill="#f5f7fb">${label}</text>
      </svg>
    `.trim();

    return `data:image/svg+xml;utf8,${encodeURIComponent(svg)}`;
  }

  function buildRarityBuckets(egg) {
    if (!egg.pets) {
      return {};
    }
    return egg.pets.reduce((buckets, entry) => {
      const pet = normalizePetEntry(entry);
      if (!pet || !pet.rarity) {
        return buckets;
      }
      const rarity = pet.rarity;
      if (!buckets[rarity]) {
        buckets[rarity] = [];
      }
      buckets[rarity].push(pet);
      return buckets;
    }, {});
  }

  async function loadEggs(path = DATA_PATH) {
    const response = await fetch(path, { cache: "no-store" });
    if (!response.ok) {
      throw new Error(`Unable to load egg data: ${response.status}`);
    }

    return response.json();
  }

  function summarizeEgg(egg, valuesPayload) {
    if (Array.isArray(egg.benchmarkPets)) {
      const benchmarkPets = egg.benchmarkPets
        .map((pet) => {
          const benchmark = valuesPayload.petIndex[pet.slug];
          if (!benchmark) {
            return null;
          }

          const chance = Number(pet.chance || 0);
          return {
            name: benchmark.name,
            slug: benchmark.slug,
            rarity: pet.rarity || benchmark.rarity,
            chance,
            benchmarkValue: benchmark.values.default,
            contribution: chance * benchmark.values.default
          };
        })
        .filter(Boolean)
        .sort((left, right) => right.contribution - left.contribution);

      const benchmarkChance = benchmarkPets.reduce((sum, pet) => sum + pet.chance, 0);
      const expectedValue = benchmarkPets.reduce((sum, pet) => sum + pet.contribution, 0);
      const cost = parseCost(egg.cost);

      return {
        ...egg,
        costAmount: cost.amount,
        currency: cost.currency,
        benchmarkPets,
        benchmarkChance,
        expectedValue,
        coveredBenchmarks: benchmarkPets.length
      };
    }

    const rarityBuckets = buildRarityBuckets(egg);
    const benchmarkPets = [];
    const rarityChances = egg.rarityChances || egg.chances || {};

    Object.entries(rarityBuckets).forEach(([rarity, pets]) => {
      const rarityChance = parseChance(rarityChances[rarity]);
      if ((!rarityChance && rarityChance !== 0) || !pets.length) {
        return;
      }

      const petsWithoutExplicitChance = pets.filter((pet) => parseChance(pet.chance) === null);
      const perPetChance = petsWithoutExplicitChance.length ? rarityChance / petsWithoutExplicitChance.length : 0;

      pets.forEach((pet) => {
        const slug = pet.slug || slugifyPetName(pet.name);
        const benchmark = valuesPayload.petIndex[slug];
        if (!benchmark) {
          return;
        }

        const explicitChance = parseChance(pet.chance);
        const finalChance = explicitChance === null ? perPetChance : explicitChance;

        benchmarkPets.push({
          name: benchmark.name,
          slug: benchmark.slug,
          rarity,
          chance: finalChance,
          benchmarkValue: benchmark.values.default,
          contribution: finalChance * benchmark.values.default
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

  function localEggAssetUrl(egg) {
    return egg && egg.id && LOCAL_EXACT_EGG_IDS.has(egg.id)
      ? `/assets/eggs/${egg.id}.webp`
      : "";
  }

  function eggVisualUrl(egg) {
    return localEggAssetUrl(egg) || eggDisplayUrl(egg);
  }

  window.ThePatchEggs = {
    DATA_PATH,
    FULL_DATA_PATH,
    eggDisplayUrl,
    eggImageUrl,
    localEggAssetUrl,
    eggVisualUrl,
    loadEggs,
    parseCost,
    parseChance,
    parsePercent,
    normalizePetEntry,
    slugifyPetName,
    summarizeEgg
  };
})();
