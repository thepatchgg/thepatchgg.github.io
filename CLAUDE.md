# Claude Guidance For The Patch

This repo powers `thepatchgg.github.io`, an Adopt Me-focused site with calculators, values, egg guides, pet pages, and weekly update articles.

The site is already in a strong state. Protect the existing quality. Do not "modernize" it into a generic app shell or rewrite major surfaces casually.

## Top Priorities

1. Preserve the visual identity.
2. Preserve trust in the values/data.
3. Keep user-facing copy player-friendly.
4. Do not break local assets, images, or navigation.
5. Do not push live without explicit user approval.

## Design Guardrails

- Preserve the restored "classic Patch" visual language.
- Do not replace the current look with a bland dashboard/app aesthetic.
- The homepage should stay tile-first and article-forward.
- Weekly/event article pages should keep the colorful editorial style rather than a plain product UI.
- The egg guide now uses a single-column, one-egg-per-row layout on purpose. Do not revert it back to cramped side-by-side cards unless explicitly requested.
- Keep the shared ribbon/header behavior consistent across pages. The normalized menu logic lives in `assets/js/patch-ribbon.js`.

## Copy Guardrails

- All public pages must read like finished user-facing content.
- Do not add internal notes, SEO strategy notes, admin reminders, rationale-for-traffic language, or "why we changed this" language to public pages.
- Avoid phrases like:
  - "this page gets traffic because..."
  - "shared benchmark file"
  - "reviewed in the system"
  - "this was rebuilt to..."
  - "legacy fallback"
- Exception: pages like `changelog.html`, `methodology.html`, and policy/trust pages can discuss process when appropriate.

## Value/Data Guardrails

- Never invent pet values.
- Before changing live values, verify against reliable current market references.
- Use exact dates when talking about current values or live events if there is any risk of ambiguity.
- The value system is intentionally split:
  - `data/adopt-me-values.json`
    Canonical benchmark/editorial values used across main value surfaces.
  - `data/adopt-me-calculator-overrides.json`
    Tracker-backed overrides for the large calculator catalog.
  - `data/adopt-me-calculator-manual-mappings.json`
    Edge-case manual mappings.
- The recurring value sync is audit-only by default. Candidate outputs belong in `data/value-sync-staging` until a human approves promotion.
- Do not casually overwrite the benchmark layer with a single public tracker's opinions. High-tier benchmark pets are editorial anchors and may intentionally differ slightly from public tools.
- Before changing any benchmark or spotlight pet, confirm it against at least two public market references. Do not rely on a single source when the sources disagree.
- If updating benchmark pets, be especially careful with:
  - Bat Dragon
  - Shadow Dragon
  - Owl
  - Parrot
  - Crow
  - Unicorn
  - Dragon
  - Dragonfruit Fox
  - Silverback Gorilla

## Egg/Pet Data Guardrails

- Egg guide data and egg calculator data should stay aligned.
- Use local exact egg assets in `assets/eggs` first.
- Do not switch critical images back to brittle hotlinked assets.
- Keep pet images local whenever possible.
- Egg guide sources and structure depend on:
  - `data/adopt-me-eggs.json`
  - `data/adopt-me-verified-eggs.json`
  - `assets/js/adopt-eggs.js`
  - `assets/js/adopt-egg-guide-data.js`
- Pet catalog/rarity data depends on:
  - `data/adopt-me-pet-catalog.json`

## Image/Asset Guardrails

- Broken images are a release blocker.
- Before wrapping up image-related work, verify:
  - egg images display
  - pet images display
  - benchmark pages still load local art
- Prefer local assets over remote dependencies for critical UI.

## Key Files

- `index.html`
  Homepage. Keep it article-forward and visually lively.
- `TRAFFIC_MONITORING.md`
  Source of truth for weekly traffic review, search/query interpretation, and content-expansion decisions.
- `DISCOVERY_NEXT_7_DAYS.md`
  Short-term growth checklist for the current live-update window and next-step discovery work.
- `VALUE_SYNC_PROCESS.md`
  Source of truth for the twice-weekly pet value refresh and audit workflow.
- `NEW_PET_RELEASE_PLAYBOOK.md`
  Source of truth for same-day new pet release coverage, channel checks, and the coverage audit workflow.
- `pet-value-calculator.html`
  Large calculator with 700+ pets and potion toggles.
- `neon-calculator.html`
  Preserve potion toggles and calculator usability.
- `articles/adopt-me-egg-guide.html`
  Single-column egg layout is intentional.
- `egg-value-calculator.html`
  Benchmark EV tool, not a replacement for the full egg guide.
- `articles/adopt-me-sugarfest-week4-chocolate-bunny-guide.html`
  Reference example for the restored colorful article aesthetic.
- `assets/css/patch-compat.css`
  Compatibility styling that keeps newer pages aligned with the older Patch look.
- `assets/js/patch-ribbon.js`
  Shared ribbon/header normalization.

## QA Expectations

Before considering a change "done", run:

- `powershell -ExecutionPolicy Bypass -File scripts/qa-site.ps1`
- `powershell -ExecutionPolicy Bypass -File scripts/qa-release.ps1`

For visual work, also preview locally and spot-check the affected pages.

## Release Safety

- Do not merge or push to `main` unless the user clearly asks for it.
- Prefer non-live prototypes for larger UI changes first.
- If a layout is being reconsidered, prototype it in a separate page or isolated branch before replacing the production page.

## Preferred Working Style

- Make focused changes instead of broad rewrites.
- Reuse existing patterns.
- Keep the site feeling handcrafted, colorful, and readable.
- When unsure, preserve what already looks good and only change the minimum necessary.
- For traffic or SEO-related work, read `TRAFFIC_MONITORING.md` before making recommendations.
- For short-term growth execution, also read `DISCOVERY_NEXT_7_DAYS.md` before proposing a fresh traffic plan from scratch.
- For value-refresh work, read `VALUE_SYNC_PROCESS.md` before changing pet values or calculator overrides.
- For newly released pets, read `NEW_PET_RELEASE_PLAYBOOK.md` before claiming a pet is fully covered across the site.
