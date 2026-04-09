# Pre-Merge Checklist

This checklist is for release readiness only. It does not imply approval to merge or deploy.

## Current branch

- PR: `thepatchgg/thepatchgg.github.io#1`
- Branch: `codex/value-engine-phase1`
- Public site status: not live on `main`

## Merge blockers

- [ ] Desktop QA completed on the core pages
- [ ] Mobile QA completed on the core pages
- [ ] Newsletter flow verified
- [ ] Core calculators smoke-tested
- [ ] Watchlist and saved inventory persistence verified
- [ ] Analytics events confirmed in GA debug/realtime
- [ ] GitHub Actions `Site QA` workflow passes on the PR
- [ ] PR title and summary updated to match actual scope

## Local QA tools

- [ ] Preview server runs with `scripts/start-preview.ps1`
- [ ] Preview server stops cleanly with `scripts/stop-preview.ps1`
- [ ] Screenshot capture runs with `scripts/capture-release-screens.ps1` if the local browser environment supports it
- [ ] `scripts/qa-release.ps1` passes

## Core pages to review first

- [ ] `/`
- [ ] `/adopt-me.html`
- [ ] `/pet-value-calculator.html`
- [ ] `/neon-calculator.html`
- [ ] `/egg-value-calculator.html`
- [ ] `/market-movers.html`
- [ ] `/inventory-planner.html`
- [ ] `/articles/adopt-me-pet-value-list-2026.html`
- [ ] `/articles/adopt-me-pet-encyclopedia.html`
- [ ] `/pets/`
- [ ] 3 sample pet pages:
  - [ ] `/pets/bat-dragon.html`
  - [ ] `/pets/shadow-dragon.html`
  - [ ] `/pets/turtle.html`

## Desktop QA

For each core page above:

- [ ] Header/nav renders correctly
- [ ] Footer links render correctly
- [ ] No overlapping cards, buttons, or tables
- [ ] Typography and spacing look consistent
- [ ] Images load correctly
- [ ] Internal links land on the correct page
- [ ] No obvious stale event framing on live/product pages

## Mobile QA

Test at a narrow phone width and one medium tablet width.

- [ ] Header/nav stays usable
- [ ] Buttons remain tappable
- [ ] Tables are readable or scroll correctly
- [ ] Form fields are usable without layout breakage
- [ ] No clipped text, double-scroll, or horizontal overflow
- [ ] Hero sections do not become too tall or awkward
- [ ] Pet cards and CTA rows stack cleanly

## Functional smoke tests

### Homepage and guide hub

- [ ] Newsletter opens the Substack signup flow
- [ ] Home hero CTAs work
- [ ] Guides hub newsletter works

### Value and calculator surfaces

- [ ] Value list variant switcher changes displayed values
- [ ] Trade calculator can add pets to both sides and updates verdict
- [ ] Neon calculator updates for target and lane changes
- [ ] Egg calculator changes output when egg and hatch count change
- [ ] Market movers watch buttons update state
- [ ] Inventory planner saves, reloads, and clears correctly

### Benchmark library and pet pages

- [ ] Benchmark library search works
- [ ] Benchmark library filters work
- [ ] Recent pet tracking appears after opening pet pages
- [ ] Pet page watch button updates correctly
- [ ] Related pet links work

## Analytics QA

Use GA realtime or debug tooling before merge.

- [ ] `homepage_cta_click` appears
- [ ] `parent_cta_click` appears
- [ ] `tool_interaction` appears on each core tool
- [ ] `watchlist_updated` appears
- [ ] `inventory_updated` appears
- [ ] `newsletter_submit` appears
- [ ] `newsletter_invalid` appears
- [ ] `newsletter_success` appears
- [ ] `outbound_click` appears

## Content and trust checks

- [ ] Value language is consistent across homepage, value list, calculators, and pet pages
- [ ] Privacy and advertising pages are linked from visible surfaces
- [ ] Parent guide copy reads cleanly and has no encoding issues
- [ ] Archive/event pages are clearly marked as archives where intended
- [ ] No placeholder contact copy or fake-live UI remains on key pages

## PR hygiene before merge

- [ ] Update PR title to reflect full scope
- [ ] Update PR summary/body to reflect all phases actually included
- [ ] Confirm the draft status should be removed only after QA signoff
- [ ] Manual QA report filled in from `MANUAL_QA_REPORT_TEMPLATE.md`
- [ ] Release snapshot reviewed from `scripts/release-status.ps1`

## Merge sequence

Only do these after the checklist above is complete.

1. Mark final QA issues, if any
2. Fix remaining blockers
3. Re-run `scripts/qa-site.ps1`
4. Re-check the PR diff one last time
5. Mark PR ready for review
6. Merge into `main`
7. Verify GitHub Pages deployment
8. Smoke-test the public site after deploy

## Recommended hold points

Do not merge yet if any of these are unresolved:

- Broken mobile layout on core pages
- Newsletter or calculator flow failure
- Analytics events not appearing
- Value contradictions on live-product pages
- Obvious visual regressions on homepage, calculators, or pet pages
