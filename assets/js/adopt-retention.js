(function () {
  const WATCHLIST_KEY = "thepatch.watchlist.v1";
  const INVENTORY_KEY = "thepatch.inventory.v1";
  const RECENT_PETS_KEY = "thepatch.recentPets.v1";

  function readJson(key, fallback) {
    try {
      const raw = window.localStorage.getItem(key);
      if (!raw) {
        return fallback;
      }

      const parsed = JSON.parse(raw);
      return parsed ?? fallback;
    } catch (error) {
      return fallback;
    }
  }

  function writeJson(key, value) {
    try {
      window.localStorage.setItem(key, JSON.stringify(value));
      return true;
    } catch (error) {
      return false;
    }
  }

  function dispatchChange(name, detail) {
    window.dispatchEvent(new CustomEvent(name, { detail }));
  }

  function normalizeWatchlist(list) {
    return [...new Set((Array.isArray(list) ? list : []).filter((slug) => typeof slug === "string" && slug.trim()))]
      .sort((left, right) => left.localeCompare(right));
  }

  function loadWatchlist() {
    return normalizeWatchlist(readJson(WATCHLIST_KEY, []));
  }

  function saveWatchlist(list) {
    const normalized = normalizeWatchlist(list);
    writeJson(WATCHLIST_KEY, normalized);
    dispatchChange("thepatch:watchlist", { slugs: normalized });
    return normalized;
  }

  function toggleWatchlist(slug) {
    const watchlist = new Set(loadWatchlist());

    if (watchlist.has(slug)) {
      watchlist.delete(slug);
    } else {
      watchlist.add(slug);
    }

    return saveWatchlist([...watchlist]);
  }

  function isWatched(slug) {
    return loadWatchlist().includes(slug);
  }

  function normalizeInventoryLine(line) {
    if (!line || typeof line.slug !== "string" || !line.slug.trim()) {
      return null;
    }

    return {
      slug: line.slug,
      variant: typeof line.variant === "string" && line.variant.trim() ? line.variant : "default",
      qty: Math.max(1, Number(line.qty || 1))
    };
  }

  function loadInventory() {
    const lines = readJson(INVENTORY_KEY, []);
    return (Array.isArray(lines) ? lines : [])
      .map(normalizeInventoryLine)
      .filter(Boolean);
  }

  function saveInventory(lines) {
    const normalized = (Array.isArray(lines) ? lines : [])
      .map(normalizeInventoryLine)
      .filter(Boolean);

    writeJson(INVENTORY_KEY, normalized);
    dispatchChange("thepatch:inventory", { lines: normalized });
    return normalized;
  }

  function clearInventory() {
    return saveInventory([]);
  }

  function normalizeRecentPets(list) {
    return (Array.isArray(list) ? list : [])
      .map((entry) => {
        if (!entry || typeof entry.slug !== "string" || !entry.slug.trim()) {
          return null;
        }

        const timestamp = Number(entry.viewedAt || Date.now());
        return {
          slug: entry.slug,
          viewedAt: Number.isFinite(timestamp) ? timestamp : Date.now()
        };
      })
      .filter(Boolean)
      .sort((left, right) => right.viewedAt - left.viewedAt)
      .slice(0, 8);
  }

  function loadRecentPets() {
    return normalizeRecentPets(readJson(RECENT_PETS_KEY, []));
  }

  function saveRecentPets(list) {
    const normalized = normalizeRecentPets(list);
    writeJson(RECENT_PETS_KEY, normalized);
    dispatchChange("thepatch:recentPets", { items: normalized });
    return normalized;
  }

  function pushRecentPet(slug) {
    if (typeof slug !== "string" || !slug.trim()) {
      return loadRecentPets();
    }

    const current = loadRecentPets().filter((entry) => entry.slug !== slug);
    current.unshift({
      slug,
      viewedAt: Date.now()
    });

    return saveRecentPets(current);
  }

  window.ThePatchRetention = {
    WATCHLIST_KEY,
    INVENTORY_KEY,
    RECENT_PETS_KEY,
    clearInventory,
    isWatched,
    loadInventory,
    loadRecentPets,
    loadWatchlist,
    pushRecentPet,
    saveInventory,
    saveRecentPets,
    saveWatchlist,
    toggleWatchlist
  };
})();
