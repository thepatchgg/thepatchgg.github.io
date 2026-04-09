(function () {
  function setWatchButton(button, active) {
    button.classList.toggle("active", active);
    button.textContent = active ? "Watching" : "Watch this pet";
  }

  function initPetPage() {
    const slug = window.THE_PATCH_PET_SLUG;
    const button = document.querySelector("[data-watch-pet]");
    if (!slug || !window.ThePatchRetention) {
      return;
    }

    window.ThePatchRetention.pushRecentPet(slug);

    if (!button) {
      return;
    }

    setWatchButton(button, window.ThePatchRetention.isWatched(slug));

    button.addEventListener("click", () => {
      const slugs = window.ThePatchRetention.toggleWatchlist(slug);
      setWatchButton(button, slugs.includes(slug));
    });

    window.addEventListener("thepatch:watchlist", (event) => {
      const slugs = event.detail && Array.isArray(event.detail.slugs) ? event.detail.slugs : [];
      setWatchButton(button, slugs.includes(slug));
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initPetPage);
  } else {
    initPetPage();
  }
})();
