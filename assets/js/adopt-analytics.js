(function () {
  function track(eventName, params) {
    if (typeof window.gtag !== "function" || !eventName) {
      return;
    }

    window.gtag("event", eventName, params || {});
  }

  function getLabel(node) {
    if (!node) {
      return "";
    }

    return (
      node.dataset.trackLabel ||
      node.getAttribute("aria-label") ||
      node.textContent ||
      node.value ||
      ""
    ).trim().slice(0, 100);
  }

  function bindTrackedClicks() {
    document.addEventListener("click", (event) => {
      const tracked = event.target.closest("[data-track-event]");
      if (tracked) {
        track(tracked.dataset.trackEvent, {
          page_path: window.location.pathname,
          cta_label: getLabel(tracked),
          cta_location: tracked.dataset.trackLocation || "unspecified"
        });
      }

      const link = event.target.closest("a[href]");
      if (!link) {
        return;
      }

      let href;
      try {
        href = new URL(link.href, window.location.origin);
      } catch (error) {
        return;
      }

      if (href.origin !== window.location.origin) {
        track("outbound_click", {
          page_path: window.location.pathname,
          outbound_domain: href.hostname,
          outbound_path: href.pathname,
          cta_label: getLabel(link)
        });
      }
    });
  }

  function bindToolInteractions() {
    document.querySelectorAll("[data-tool-name]").forEach((container) => {
      let sent = false;

      function markInteraction(event) {
        if (sent) {
          return;
        }

        if (!event.target.closest("button, input, select, textarea, a")) {
          return;
        }

        sent = true;
        track("tool_interaction", {
          page_path: window.location.pathname,
          tool_name: container.dataset.toolName
        });
      }

      container.addEventListener("click", markInteraction, true);
      container.addEventListener("change", markInteraction, true);
      container.addEventListener("input", markInteraction, true);
    });
  }

  function bindPatchEvents() {
    window.addEventListener("thepatch:watchlist", (event) => {
      const count = event.detail && Array.isArray(event.detail.slugs) ? event.detail.slugs.length : 0;
      track("watchlist_updated", {
        page_path: window.location.pathname,
        item_count: count
      });
    });

    window.addEventListener("thepatch:inventory", (event) => {
      const count = event.detail && Array.isArray(event.detail.lines) ? event.detail.lines.length : 0;
      track("inventory_updated", {
        page_path: window.location.pathname,
        line_count: count
      });
    });

    window.addEventListener("thepatch:newsletter", (event) => {
      const detail = event.detail || {};
      if (!detail.status) {
        return;
      }

      track(`newsletter_${detail.status}`, {
        page_path: window.location.pathname,
        newsletter_location: detail.location || "unknown"
      });
    });
  }

  function init() {
    bindTrackedClicks();
    bindToolInteractions();
    bindPatchEvents();
  }

  window.ThePatchAnalytics = {
    track
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
