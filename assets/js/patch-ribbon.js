(function () {
  function init() {
  const header = document.querySelector(".site-header");
  if (!header) return;

  const inner = header.querySelector(".header-inner");
  if (!inner) return;

  const pathname = window.location.pathname.replace(/\/index\.html$/, "/");
  const nav = header.querySelector('.main-nav, .nav[aria-label="Primary"]');
  const brand = header.querySelector(".site-logo, .brand");

  const links = [
    { href: "/", label: "Home", active: () => pathname === "/" },
    { href: "/articles/adopt-me-pet-value-list-2026.html", label: "Pet Values", active: () => pathname.includes("/adopt-me-pet-value-list-2026") || pathname.startsWith("/pets/") },
    { href: "/articles/adopt-me-pet-encyclopedia.html", label: "Pet Dex", active: () => pathname.includes("/adopt-me-pet-encyclopedia") },
    { href: "/articles/adopt-me-egg-guide.html", label: "Egg Guide", active: () => pathname.includes("/adopt-me-egg-guide") || pathname === "/egg-value-calculator.html" },
    { href: "/pet-value-calculator.html", label: "Trade Calc", active: () => pathname === "/pet-value-calculator.html" || pathname === "/inventory-planner.html" },
    { href: "/neon-calculator.html", label: "Neon Calc", active: () => pathname === "/neon-calculator.html" },
    { href: "/market-movers.html", label: "Movers", active: () => pathname === "/market-movers.html" },
    { href: "/trading-forum.html", label: "Trading Board", active: () => pathname === "/trading-forum.html" },
    { href: "/adopt-me.html", label: "All Guides", active: () => pathname === "/adopt-me.html" || pathname.startsWith("/articles/") && !pathname.includes("pet-value-list") && !pathname.includes("pet-encyclopedia") && !pathname.includes("egg-guide") }
  ];

  if (brand) {
    brand.className = "site-logo";
    brand.setAttribute("href", "/");
    brand.innerHTML = 'The <span>Patch</span> &#128062;';
  }

  if (nav) {
    nav.className = "main-nav";
    nav.setAttribute("aria-label", "Primary");
    nav.innerHTML = links.map((link) => {
      const active = link.active() ? ' class="active"' : "";
      return `<a href="${link.href}"${active}>${link.label}</a>`;
    }).join("");
  }

  if (!inner.querySelector(".header-cta")) {
    const cta = document.createElement("a");
    cta.href = "https://thepatchgg.substack.com";
    cta.className = "header-cta";
    cta.target = "_blank";
    cta.rel = "noopener";
    cta.textContent = "Subscribe Free";
    inner.appendChild(cta);
  }

  if (!inner.querySelector(".nav-toggle")) {
    const toggle = document.createElement("button");
    toggle.className = "nav-toggle";
    toggle.setAttribute("aria-label", "Toggle menu");
    toggle.innerHTML = "<span></span><span></span><span></span>";
    inner.appendChild(toggle);
  }

  const toggle = inner.querySelector(".nav-toggle");
  const mainNav = inner.querySelector(".main-nav");
  if (toggle && mainNav && !toggle.dataset.patchBound) {
    toggle.dataset.patchBound = "true";
    toggle.addEventListener("click", function () {
      const open = mainNav.dataset.mobileOpen === "true";
      if (open) {
        mainNav.removeAttribute("style");
        mainNav.dataset.mobileOpen = "false";
        return;
      }

      mainNav.style.display = "flex";
      mainNav.style.flexDirection = "column";
      mainNav.style.position = "absolute";
      mainNav.style.top = "60px";
      mainNav.style.left = "0";
      mainNav.style.right = "0";
      mainNav.style.background = "#0d0d0f";
      mainNav.style.padding = "12px 20px";
      mainNav.style.borderBottom = "1px solid #2a2a35";
      mainNav.style.zIndex = "99";
      mainNav.dataset.mobileOpen = "true";
    });
  }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init, { once: true });
  } else {
    init();
  }
})();
